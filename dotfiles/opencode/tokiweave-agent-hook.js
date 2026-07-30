// Tokiweave連携: opencodeのツール実行とセッション終了をTokiweaveの作業ログへ転送する。
//
// opencodeのイベント形状はClaude Code / Copilotのフック入力と異なる（ファイルパスが
// camelCaseのfilePathなど）ため、このプラグインでTokiweaveが解釈できる形へ正規化する。
// こうすることでイベントの判定ロジックはTokiweave側の1箇所に保てる。
//
// 作業内容の要約は、Tokiweaveが作業フォルダーに書かせる要約ファイルが本線。
// ただしopencodeはその指示に従わないことがあるため、Claude Codeの`Stop`フックと
// 同じ保険として、AIの最後の発言もセッションの一区切りごとに転送する。
//
// TOKIWEAVE_HOOK_COMMAND はTokiweave経由で起動したときのみ設定される。
// 通常のopencode利用では何もしない。
import { spawn } from "node:child_process";

const hookCommand = process.env.TOKIWEAVE_HOOK_COMMAND;

// opencode側のセッションIDのキー名。Tokiweaveが会話の再開に使う。
const SESSION_ID_KEYS = ["sessionID", "sessionId", "session_id"];

function firstString(source, keys) {
  if (!source || typeof source !== "object") return undefined;
  for (const key of keys) {
    const value = source[key];
    if (typeof value === "string" && value) return value;
  }
  return undefined;
}

// セッションIDの置き場所はイベントの種類によって違うため、候補を順に見る。
// 見つからなくても転送はそのまま続ける（再開ができないだけ）。
function findSessionId(...sources) {
  for (const source of sources) {
    const value = firstString(source, SESSION_ID_KEYS);
    if (value) return value;
  }
  return undefined;
}

// AIの発言を組み立てるための状態。message.part.updatedはroleを持たないため、
// message.updatedで拾ったroleと突き合わせる必要がある。
// 保険として使うだけなので、直近数件だけ覚えて古いものは捨てる。
const MAX_TRACKED_MESSAGES = 5;
const roleByMessage = new Map();
const textPartsByMessage = new Map();
/** テキストが更新されたmessageIDを、更新の新しい順に並べたもの。 */
const recentMessageIds = [];

function rememberMessageRole(message) {
  const id = firstString(message, ["id"]);
  const role = firstString(message, ["role"]);
  if (id && role) roleByMessage.set(id, role);
}

function rememberTextPart(part) {
  const messageId = firstString(part, ["messageID", "messageId"]);
  const partId = firstString(part, ["id"]);
  if (!messageId || !partId || typeof part.text !== "string") return;
  const parts = textPartsByMessage.get(messageId) ?? new Map();
  parts.set(partId, part.text);
  textPartsByMessage.set(messageId, parts);

  const at = recentMessageIds.indexOf(messageId);
  if (at !== -1) recentMessageIds.splice(at, 1);
  recentMessageIds.unshift(messageId);
  for (const stale of recentMessageIds.splice(MAX_TRACKED_MESSAGES)) {
    textPartsByMessage.delete(stale);
    roleByMessage.delete(stale);
  }
}

/** 直近のAIの発言。roleが分かっているものだけを対象にする。 */
function latestAssistantMessage() {
  for (const messageId of recentMessageIds) {
    if (roleByMessage.get(messageId) !== "assistant") continue;
    const text = [...(textPartsByMessage.get(messageId) ?? new Map()).values()]
      .join("")
      .trim();
    if (text) return text;
  }
  return undefined;
}

// 転送の失敗でエージェントの作業を止めないため、エラーは全て握り潰す。
function forward(payload) {
  try {
    const child = spawn("/bin/sh", ["-c", hookCommand], {
      stdio: ["pipe", "ignore", "ignore"],
    });
    child.on("error", () => {});
    child.stdin.on("error", () => {});
    child.stdin.end(JSON.stringify(payload));
  } catch {
    // 何もしない
  }
}

export const TokiweaveAgentHook = async () => {
  if (!hookCommand) return {};

  return {
    // Claude CodeのUserPromptSubmit相当。ユーザーが入力した依頼を作業ログへ残す。
    // opencodeはこのフックでしかユーザーの入力を渡してこないため、
    // 登録しないと依頼内容が空になる。
    "chat.message": async (input, output) => {
      const prompt = (output?.parts ?? [])
        .filter(
          (part) =>
            part?.type === "text" &&
            typeof part.text === "string" &&
            // 自動継続などの合成メッセージはユーザーの依頼ではない。
            !part.synthetic &&
            !part.ignored,
        )
        .map((part) => part.text.trim())
        .filter(Boolean)
        .join("\n")
        .trim();
      if (!prompt) return;
      forward({
        hook_event_name: "UserPromptSubmit",
        prompt,
        session_id: findSessionId(input, output?.message),
      });
    },

    // Claude CodeのPostToolUse相当。変更ファイルと検証コマンドの抽出元になる。
    "tool.execute.after": async (input, output) => {
      forward({
        hook_event_name: "PostToolUse",
        tool_name: input?.tool,
        session_id: findSessionId(input, output),
        // opencode側のキー名の揺れに備えて候補を順に見る。
        tool_input: {
          command: firstString(input?.args, ["command", "cmd"]),
          file_path: firstString(input?.args, [
            "filePath",
            "file_path",
            "path",
            "target_file",
          ]),
        },
      });
    },

    event: async ({ event }) => {
      const sessionId = findSessionId(
        event?.properties,
        event?.properties?.info,
        event,
      );
      switch (event?.type) {
        // roleはメッセージ側にしか無いので、ここで覚えておく。
        case "message.updated":
          rememberMessageRole(event.properties?.info);
          break;
        case "message.part.updated":
          if (event.properties?.part?.type === "text") {
            rememberTextPart(event.properties.part);
          }
          break;
        case "session.idle":
          forward({
            hook_event_name: "Stop",
            session_id: sessionId,
            // 要約ファイルが無かったときの保険。Tokiweave側で
            // 要約ファイルがあればそちらが優先される。
            last_assistant_message: latestAssistantMessage(),
          });
          break;
        case "session.error":
          forward({ hook_event_name: "StopFailure", session_id: sessionId });
          break;
        default:
          break;
      }
    },
  };
};

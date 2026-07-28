// Tokiweave連携: opencodeのツール実行とセッション終了をTokiweaveの作業ログへ転送する。
//
// opencodeのイベント形状はClaude Code / Copilotのフック入力と異なる（ファイルパスが
// camelCaseのfilePathなど）ため、このプラグインでTokiweaveが解釈できる形へ正規化する。
// こうすることでイベントの判定ロジックはTokiweave側の1箇所に保てる。
//
// TOKIWEAVE_HOOK_COMMAND はTokiweave経由で起動したときのみ設定される。
// 通常のopencode利用では何もしない。
import { spawn } from "node:child_process";

const hookCommand = process.env.TOKIWEAVE_HOOK_COMMAND;

function firstString(source, keys) {
  if (!source || typeof source !== "object") return undefined;
  for (const key of keys) {
    const value = source[key];
    if (typeof value === "string" && value) return value;
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
    // Claude CodeのPostToolUse相当。変更ファイルと検証コマンドの抽出元になる。
    "tool.execute.after": async ({ tool, args }) => {
      forward({
        hook_event_name: "PostToolUse",
        tool_name: tool,
        // opencode側のキー名の揺れに備えて候補を順に見る。
        tool_input: {
          command: firstString(args, ["command", "cmd"]),
          file_path: firstString(args, [
            "filePath",
            "file_path",
            "path",
            "target_file",
          ]),
        },
      });
    },

    event: async ({ event }) => {
      switch (event?.type) {
        case "session.idle":
          forward({ hook_event_name: "Stop" });
          break;
        case "session.error":
          forward({ hook_event_name: "StopFailure" });
          break;
        default:
          break;
      }
    },
  };
};

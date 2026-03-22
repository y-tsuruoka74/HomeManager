-- ==== Swap all windows between top and bottom displays (2枚想定) ====
local function relFrame(win, fromF)
  local f = win:frame()
  return {
    x = (f.x - fromF.x) / fromF.w,
    y = (f.y - fromF.y) / fromF.h,
    w = f.w / fromF.w,
    h = f.h / fromF.h,
  }
end

local function applyRelFrame(win, toF, r)
  win:setFrame({
    x = toF.x + r.x * toF.w,
    y = toF.y + r.y * toF.h,
    w = r.w * toF.w,
    h = r.h * toF.h
  }, 0) -- 0=ノーアニメで瞬時
end

local function windowsOn(screen)
  local list = {}
  for _, w in ipairs(hs.window.allWindows()) do
    if w:isStandard() and w:screen() == screen then
      table.insert(list, w)
    end
  end
  return list
end

local function swapBetween(screenA, screenB)
  local fA, fB = screenA:frame(), screenB:frame()
  -- 現在の座標を先にスナップショット（相対化）してから移動
  local snapA, snapB = {}, {}
  for _, w in ipairs(windowsOn(screenA)) do
    table.insert(snapA, {win = w, rel = relFrame(w, fA)})
  end
  for _, w in ipairs(windowsOn(screenB)) do
    table.insert(snapB, {win = w, rel = relFrame(w, fB)})
  end
  -- A→B, B→A の順で適用
  for _, s in ipairs(snapA) do
    s.win:moveToScreen(screenB, false, true, 0) -- スクリーン移動だけ先に
    applyRelFrame(s.win, fB, s.rel)
  end
  for _, s in ipairs(snapB) do
    s.win:moveToScreen(screenA, false, true, 0)
    applyRelFrame(s.win, fA, s.rel)
  end
end

local function swapTopBottom()
  local screens = hs.screen.allScreens()
  if #screens < 2 then return end
  -- y座標で上/下を判定（縦スタック前提）
  table.sort(screens, function(a, b) return a:frame().y < b:frame().y end)
  local top, bottom = screens[1], screens[#screens]
  swapBetween(top, bottom)
end

hs.hotkey.bind({"ctrl","shift"}, "space", swapTopBottom)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.alert.show("Hello World!")
end)

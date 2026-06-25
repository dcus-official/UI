-- =====================================================
-- Fluent UI + Liquid Glass + PlayerList 完全な使用例
-- =====================================================

local Library = require(game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts"):WaitForChild("UILib"):WaitForChild("Fluent"):WaitForChild("Library"))
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

-- =====================================================
-- ウィンドウ作成（Liquid Glass トグル対応）
-- =====================================================
local Window = Library:CreateWindow({
	Title = "🎮 Player Manager",
	SubTitle = "Advanced Player Control",
	TabWidth = 160,
	Size = UDim2.fromOffset(600, 400),
	Acrylic = true,
	Theme = "Dark",
	ShowSearch = false,
})

-- =====================================================
-- Tab1: プレイヤーテレポート
-- =====================================================
local Tab1 = Window:AddTab("Teleport")

local Section1 = Tab1:AddSection("Player Selection")

-- PlayerList を作成（複数選択対応、アイコン表示）
local PlayerTeleportList = Tab1:AddPlayerList({
	AutoUpdate = true,      -- プレイヤー参加/退出を自動検知
	Multi = false,          -- 単一選択モード
	UseIcon = true,         -- ユーザーアイコン表示
	Callback = function(value)
		-- value は Player オブジェクト（単一選択のため）
		if value then
			print("Selected player: " .. value.Name)
		end
	end
})

-- テレポートボタン
local TeleportButton = Section1:AddButton("Teleport to Selected", function()
	-- PlayerList から選択プレイヤーを取得（フレーム経由でアクセス）
	-- 実装: PlayerListの内部状態を取得する必要がある場合は構造を拡張
	print("Teleporting to player...")
end)

-- Teleport by Team Color
local Section1B = Tab1:AddSection("Teleport by Proximity")

local ProximityToggle = Section1B:AddToggle("AutoTeleport", {
	Title = "Auto Teleport on Spawn",
	Description = "Automatically teleport to nearest player",
	Default = false,
	Callback = function(Value)
		if Value then
			print("Auto-teleport enabled")
		else
			print("Auto-teleport disabled")
		end
	end
})

local ProximityRange = Section1B:AddSlider("TeleportRange", {
	Title = "Teleport Range",
	Description = "Maximum distance for auto-teleport",
	Default = 50,
	Min = 10,
	Max = 500,
	Rounding = 5,
	Callback = function(Value)
		print("Teleport range: " .. Value)
	end
})

-- =====================================================
-- Tab2: マルチプレイヤー管理
-- =====================================================
local Tab2 = Window:AddTab("Multi-Player")

local Section2 = Tab2:AddSection("Manage Multiple Players")

-- マルチプレイヤーリスト（複数選択対応）
local MultiPlayerList = Tab2:AddPlayerList({
	AutoUpdate = true,
	Multi = true,           -- 複数選択有効
	UseIcon = true,
	Callback = function(selectedPlayers)
		-- selectedPlayers はテーブル（複数のPlayer オブジェクト）
		if typeof(selectedPlayers) == "table" then
			print("Selected " .. #selectedPlayers .. " players:")
			for _, player in ipairs(selectedPlayers) do
				print("  - " .. player.DisplayName .. " (@" .. player.Name .. ")")
			end
		end
	end
})

-- 一括操作ボタン
local ActionButtons = Tab2:AddSection("Batch Actions")

local KickButton = ActionButtons:AddButton("Kick Selected Players", function()
	print("Kicking selected players... (requires admin)")
end)

local MessageButton = ActionButtons:AddButton("Send Message", function()
	print("Message sent to selected players")
end)

local FreezeButton = ActionButtons:AddButton("Freeze Selected", function()
	print("Freezing selected players' humanoids...")
end)

-- =====================================================
-- Tab3: ビジュアル設定 + Liquid Glass
-- =====================================================
local Tab3 = Window:AddTab("Settings")

local Section3 = Tab3:AddSection("Display Settings")

-- これは自動でUI設定に追加される（Liquid Glass トグル）
-- Library:ToggleLiquidGlass() は自動呼び出しされる
-- Acrylic トグルの直後に "Liquid Glass" トグルが表示される

-- Element:Visible() を使用した表示/非表示制御の例
local DebugToggle = Section3:AddToggle("ShowDebug", {
	Title = "Show Debug Info",
	Description = "Display additional debug information",
	Default = false,
	Callback = function(Value)
		-- 後で作成するDebugセクションの表示/非表示を制御
		if Value then
			DebugSection:Visible(true)
		else
			DebugSection:Visible(false)
		end
	end
})

local DebugSection = Tab3:AddSection("Debug Information")

local FPSCounter = DebugSection:AddLabel("FPS: 60")
local PlayerCountLabel = DebugSection:AddLabel("Players: " .. #Players:GetPlayers())

-- 初期状態：非表示
DebugSection:Visible(false)

-- DebugセクションのFPSを定期更新
spawn(function()
	while true do
		task.wait(0.5)
		local fps = math.round(1 / game:GetService("RunService").RenderStepped:Wait())
		pcall(function()
			if FPSCounter and FPSCounter.Container then
				FPSCounter.Container.Text = "FPS: " .. fps
			end
		end)
	end
end)

-- プレイヤー数を定期更新
Players.PlayerAdded:Connect(function()
	pcall(function()
		if PlayerCountLabel and PlayerCountLabel.Container then
			PlayerCountLabel.Container.Text = "Players: " .. #Players:GetPlayers()
		end
	end)
end)

Players.PlayerRemoving:Connect(function()
	pcall(function()
		if PlayerCountLabel and PlayerCountLabel.Container then
			PlayerCountLabel.Container.Text = "Players: " .. #Players:GetPlayers()
		end
	end)
end)

-- =====================================================
-- Tab4: 高度な機能
-- =====================================================
local Tab4 = Window:AddTab("Advanced")

local Section4 = Tab4:AddSection("Targeting System")

-- ターゲットプレイヤー選択
local TargetPlayer = Tab4:AddPlayerList({
	AutoUpdate = true,
	Multi = false,
	UseIcon = true,
	Callback = function(player)
		print("Target set to: " .. player.Name)
	end
})

local FollowToggle = Section4:AddToggle("FollowTarget", {
	Title = "Follow Target Player",
	Description = "Continuously follow the selected player",
	Default = false,
	Callback = function(Value)
		if Value then
			print("Following target player...")
		else
			print("Stopped following")
		end
	end
})

local FollowDistance = Section4:AddSlider("FollowDistance", {
	Title = "Follow Distance",
	Description = "Distance to maintain from target",
	Default = 5,
	Min = 1,
	Max = 50,
	Rounding = 1,
	Callback = function(Value)
		print("Follow distance set to: " .. Value)
	end
})

local Section4B = Tab4:AddSection("Advanced Filters")

local FilterByTeam = Tab4:AddToggle("FilterByTeam", {
	Title = "Filter by Team",
	Description = "Only show players from your team",
	Default = false,
	Callback = function(Value)
		print("Team filter: " .. tostring(Value))
	end
})

local FilterByDistance = Tab4:AddSlider("DistanceFilter", {
	Title = "Distance Filter (studs)",
	Description = "Only show players within distance",
	Default = 100,
	Min = 10,
	Max = 1000,
	Rounding = 10,
	Callback = function(Value)
		print("Distance filter: " .. Value .. " studs")
	end
})

-- =====================================================
-- Tab5: クイックアクション
-- =====================================================
local Tab5 = Window:AddTab("Quick Actions")

local Section5 = Tab5:AddSection("One-Click Commands")

-- クイックコマンド例
local QuickTPButton = Section5:AddButton("TP to Last Selected", function()
	print("Teleporting to last selected player...")
end)

local KillButton = Section5:AddButton("Remove Selected (Admin)", function()
	print("Removing selected players from game...")
end)

local SpecButton = Section5:AddButton("Spectate Selected", function()
	print("Spectating selected player...")
end)

local Section5B = Tab5:AddSection("UI Controls")

local MinimizeButton = Section5B:AddButton("Minimize Window", function()
	Window:MinimizeWindow()
end)

local ResetButton = Section5B:AddButton("Reset Settings", function()
	print("Settings reset to default")
	-- 設定を初期化する処理
end)

-- =====================================================
-- キーバインド設定
-- =====================================================
local Section6 = Tab3:AddSection("Keybinds")

local ToggleWindowKey = Section6:AddKeybind("ToggleWindow", {
	Title = "Toggle Window",
	Mode = "Toggle",
	Default = Enum.KeyCode.RightControl,
	Callback = function(Value)
		if Value == true then
			print("Window toggled")
		end
	end,
	ChangedCallback = function(Value)
		print("Toggle key changed to: " .. tostring(Value))
	end
})

local TeleportKey = Section6:AddKeybind("QuickTP", {
	Title = "Quick Teleport",
	Mode = "Hold",
	Default = Enum.KeyCode.T,
	Callback = function(Value)
		if Value == true then
			print("Quick TP activated!")
		end
	end,
	ChangedCallback = function(Value)
		print("Quick TP key changed to: " .. tostring(Value))
	end
})

-- =====================================================
-- 高度な例：PlayerList の活用パターン
-- =====================================================
local Tab6 = Window:AddTab("Patterns")

local Section7 = Tab6:AddSection("Advanced Usage Examples")

-- パターン1: フィルター付きプレイヤーリスト
local FilteredList = Tab6:AddPlayerList({
	AutoUpdate = true,
	Multi = true,
	UseIcon = true,
	Callback = function(selectedPlayers)
		print("Filtered selection callback:")
		if typeof(selectedPlayers) == "table" then
			for i, player in ipairs(selectedPlayers) do
				print(i .. ". " .. player.Name)
			end
		else
			print("Selected: " .. selectedPlayers.Name)
		end
	end
})

-- パターン2: UIの状態管理
local ToggleAdvancedUI = Section7:AddToggle("ShowAdvanced", {
	Title = "Show Advanced Options",
	Default = false,
	Callback = function(Value)
		-- セクション全体の表示/非表示を制御
		-- 通常、このような実装は CustomSection を作成することで可能
		print("Advanced options visibility: " .. tostring(Value))
	end
})

-- =====================================================
-- コンソール出力例
-- =====================================================
print("=" .. string.rep("=", 50))
print("✓ Fluent UI Library Initialized")
print("✓ Liquid Glass Module Ready")
print("✓ Player List System Active")
print("=" .. string.rep("=", 50))
print("")
print("利用可能な機能:")
print("  • PlayerList (アイコン表示、複数選択対応)")
print("  • Element:Visible() (UI要素の表示/非表示制御)")
print("  • Liquid Glass トグル (Acrylic ↔ LiquidGlass 切り替え)")
print("  • キーバインド (RightCtrl: ウィンドウ開閉, T: クイックTP)")
print("")
print("例: FilteredList に複数のプレイヤーを選択して、")
print("    カスタムアクションを実行できます。")
print("")

-- =====================================================
-- ゲーム内イベント連携例
-- =====================================================

-- プレイヤーが参加したときの通知
Players.PlayerAdded:Connect(function(player)
	print("🟢 Player joined: " .. player.Name)
	-- PlayerList が AutoUpdate=true なら自動更新される
end)

-- プレイヤーが退出したときの通知
Players.PlayerRemoving:Connect(function(player)
	print("🔴 Player left: " .. player.Name)
	-- PlayerList が AutoUpdate=true なら自動更新される
end)

-- =====================================================
-- 使用例：プレイヤーを選択してアクションを実行
-- =====================================================
--[[
local function teleportToPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Parent then
		return
	end
	
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	
	local targetChar = targetPlayer.Character
	if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
		return
	end
	
	character:MoveTo(targetChar.HumanoidRootPart.Position + Vector3.new(5, 0, 0))
end

-- 使用:
-- PlayerTeleportList のコールバックで teleportToPlayer(player) を呼び出す
--]]

return {
	Window = Window,
	PlayerLists = {
		Teleport = PlayerTeleportList,
		MultiPlayer = MultiPlayerList,
		Target = TargetPlayer,
		Filtered = FilteredList,
	}
}

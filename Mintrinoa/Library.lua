--[[
    Suwadisian Dynamic Randomization & Protection System
    CG: LinoriaLib v1.0.0 (Modified)
    Enhanced with OBS (Object Bypassing System)
]]

local _g = (getgenv or function() return _G or shared or {} end)()
if not _g._OBS then
    _g._OBS = {
        UINames = {},
        GlobalNames = {},
        UsedNames = {},
        Instances = {},
        Version = "2.0.1"
    }
end
local _OBS = _g._OBS

--// Random String Generator
local function _getRand(n, p)
    local c = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local s
    repeat
        s = ""
        for i = 1, (n or 16) do
            local idx = math.random(1, #c)
            s = s .. c:sub(idx, idx)
        end
        s = (p or "") .. s
    until not _OBS.UsedNames[s]
    _OBS.UsedNames[s] = true
    return s
end

--// Dynamic Registration
local function _regU(k)
    if not k then return end
    if not _OBS.UINames[k] then _OBS.UINames[k] = _getRand(24) end
    return _OBS.UINames[k]
end

local function _regG(k)
    if not k then return end
    if not _OBS.GlobalNames[k] then _OBS.GlobalNames[k] = _getRand(24) end
    return _OBS.GlobalNames[k]
end

--// Service Retrieval
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TextService")
local CG = game:GetService("CoreGui")
local TM = game:GetService("Teams")
local PL = game:GetService("Players")
local RS = game:GetService("RunService")
local TWS = game:GetService("TweenService")

local LocalPlayer = PL and (PL.LocalPlayer or (function()
    local p = PL.LocalPlayer
    while not p do p = PL.LocalPlayer task.wait() end
    return p
end)())

local Mouse = LocalPlayer and LocalPlayer:GetMouse()

--// Drawing Bypass
local DrawingLib = { drawing_replaced = true, new = function(...) error("Drawing is not supported.") end }
local IsBadDrawingLib = false
if typeof(getgenv) == "function" and typeof(getgenv().Drawing) == "table" then
    DrawingLib = getgenv().Drawing
end

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function() return CG or (LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")) end

--// Advanced Evasion Hook
local ProtectedInstances = {}
local ProtectedNames = {}

local function _protect(Instance)
    if not Instance then return end
    table.insert(_OBS.Instances, Instance)
    ProtectedInstances[Instance] = true
    ProtectedNames[Instance.Name] = true
    pcall(ProtectGui, Instance)
end

local function _setupEvasion()
    if not hookmetamethod or not checkcaller then return end
    
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(self, key)
        local isCaller = checkcaller()
        
        --// Internal Name Translation
        if isCaller and typeof(self) == "Instance" and typeof(key) == "string" then
            if _OBS.UINames[key] then
                local res = OldIndex(self, _OBS.UINames[key])
                if res then return res end
            end
        end

        --// Evasion Logic
        if not isCaller and typeof(self) == "Instance" then
            if ProtectedNames[key] then
                if self == game or ProtectedInstances[self] then
                    return nil
                end
            end
            if ProtectedInstances[self] then
                return nil
            end
        end
        return OldIndex(self, key)
    end)
    
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local Method = getnamecallmethod()
        local isCaller = checkcaller()
        local Args = { ... }

        --// Internal Name Translation
        if isCaller and typeof(self) == "Instance" then
            if Method == "FindFirstChild" or Method == "WaitForChild" then
                local Name = Args[1]
                if typeof(Name) == "string" and _OBS.UINames[Name] then
                    Args[1] = _OBS.UINames[Name]
                    return OldNamecall(self, table.unpack(Args))
                end
            end
        end

        --// Evasion Logic
        if not isCaller and typeof(self) == "Instance" then
            if Method == "FindFirstChild" or Method == "WaitForChild" or Method == "FindFirstChildOfClass" or Method == "FindFirstChildWhichIsA" then
                local Arg = Args[1]
                if typeof(Arg) == "string" and ProtectedNames[Arg] then 
                    if self == game or ProtectedInstances[self] then
                        return nil 
                    end
                end
            end
            if ProtectedInstances[self] then 
                return nil 
            end
        end
        return OldNamecall(self, ...)
    end)
end
_setupEvasion()

local function SafeParentUI(Instance, Parent)
    pcall(function()
        local Dest = Parent or CG or GetHUI()
        if typeof(Dest) == "function" then Dest = Dest() end
        Instance.Parent = Dest
    end)
    if not Instance.Parent and LocalPlayer then
        Instance.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
	if SkipHiddenUI then
		SafeParentUI(UI, CG)
		return
	end

	pcall(ProtectGui, UI)
	SafeParentUI(UI, GetHUI)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = _regU("MainScreenGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
_protect(ScreenGui)
ParentUI(ScreenGui)

local ModalElement = Instance.new("TextButton")
ModalElement.Name = _regU("ModalElement")
ModalElement.BackgroundTransparency = 1
ModalElement.Modal = false
ModalElement.Size = UDim2.fromScale(0, 0)
ModalElement.AnchorPoint = Vector2.zero
ModalElement.Text = ""
ModalElement.ZIndex = -999
ModalElement.Parent = ScreenGui



local LibraryMainOuterFrame = nil

local Toggles = {}
local Options = {}
local Labels = {}
local Buttons = {}
local Tooltips = {}
local Dialogues = {}

-- https://github.com/deividcomsono/Obsidian/blob/main/_L.lua#L30
local BaseURL = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    Cursor = {
        RobloxId = 9619665977,
        Path = "LinoriaLib/assets/Cursor.png",
        URL = BaseURL .. "assets/Cursor.png",

        Id = nil,
    },

    DropdownArrow = {
        RobloxId = 6282522798,
        Path = "LinoriaLib/assets/DropdownArrow.png",
        URL = BaseURL .. "assets/DropdownArrow.png",

        Id = nil,
    },

    Checker = {
        RobloxId = 12977615774,
        Path = "LinoriaLib/assets/Checker.png",
        URL = BaseURL .. "assets/Checker.png",

        Id = nil,
    },

    CheckerLong = {
        RobloxId = 12978095818,
        Path = "LinoriaLib/assets/CheckerLong.png",
        URL = BaseURL .. "assets/CheckerLong.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "LinoriaLib/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    }
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(AssetName: string, RobloxAssetId: number, URL: string, ForceRedownload: boolean?)
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local DPIScale = 1;
local _L = {
    Registry = {};
    RegistryMap = {};
    HudRegistry = {};

    -- colors and font --
    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);

    AccentColor = Color3.fromRGB(0, 85, 255);
    DisabledAccentColor = Color3.fromRGB(142, 142, 142);

    OutlineColor = Color3.fromRGB(50, 50, 50);
    DisabledOutlineColor = Color3.fromRGB(70, 70, 70);

    DisabledTextColor = Color3.fromRGB(142, 142, 142);

    RiskColor = Color3.fromRGB(255, 50, 50);

    GlowColor = Color3.fromRGB(220, 0, 0);
    GlowThickness = 36;
    GlowTransparency = 0.25;

    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.Code,

    -- frames --
    OpenedFrames = {};
    DependencyBoxes = {};
    DependencyGroupboxes = {};

    -- signals --
    UnloadSignals = {};
    Signals = {};

    -- gui --
    ActiveTab = nil;
    TotalTabs = 0;

    ScreenGui = ScreenGui;
    KeybindFrame = nil;
    KeybindContainer = nil;
    Window = { Holder = nil; Tabs = {}; };

    -- variables --
    VideoLink = "";
    
    Toggled = false;
    ToggleKeybind = nil;

    IsMobile = false;
    DevicePlatform = Enum.Platform.None;

    CanDrag = true;
    CantDragForced = false;

    Unloaded = false;

    -- notification --
    Notify = nil;
    NotifySide = "Left";
    ShowCustomCursor = true;
    ShowToggleFrameInKeybinds = true;
    NotifyOnError = false; -- true = _L:Notify for SafeCallback (still warns in the developer console)

    -- addons --
    SaveManager = nil;
    ThemeManager = nil;

    -- for better usage --
    Toggles = Toggles;
    Options = Options;
    Labels = Labels;
    Buttons = Buttons;
    Dialogues = Dialogues;
    ActiveDialog = nil;

    ImageManager = CustomImageManager;
    ShowCursorBinding = string.sub(tostring({}), 10);

    Modules = {};
}

_L.NotifySettings = {
    Position = 40,
    HorizontalPosition = 0,
    Animation = "Slide",
    SlideDirection = "Left",
    FadeTime = 0.4
}

_L.BackgroundSettings = {
    Blur = 0,
    Color = Color3.fromRGB(0, 0, 0),
    Transparency = 0.5
}

local BlurEffect = game:GetService("Lighting"):FindFirstChild("LinoriaBlur") or Instance.new("BlurEffect")
BlurEffect.Name = "LinoriaBlur"
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")
_L.BlurEffect = BlurEffect

local BackgroundFrame = Instance.new("Frame")
BackgroundFrame.Name = _regU("BackgroundFrame")
BackgroundFrame.BackgroundColor3 = _L.BackgroundSettings.Color
BackgroundFrame.BackgroundTransparency = 1
BackgroundFrame.Position = UDim2.new(0, 0, 0, -58)
BackgroundFrame.Size = UDim2.new(1, 0, 1, 58)
BackgroundFrame.ZIndex = -1
BackgroundFrame.Visible = false
BackgroundFrame.Parent = ScreenGui
_L.BackgroundFrame = BackgroundFrame

function _L.CallModule(Name)
    return _L.Modules[Name]
end

if RS:IsStudio() then
   _L.IsMobile = UIS.TouchEnabled and not UIS.MouseEnabled 
else
    pcall(function() _L.DevicePlatform = UIS:GetPlatform() end) -- For safety so the UI library doesn't error.
    _L.IsMobile = (_L.DevicePlatform == Enum.Platform.Android or _L.DevicePlatform == Enum.Platform.IOS)
end

_L.MinSize = if _L.IsMobile then Vector2.new(550, 200) else Vector2.new(550, 300)

--// Functions \\--
local function ApplyDPIScale(Position)
    return UDim2.new(Position.X.Scale, Position.X.Offset * DPIScale, Position.Y.Scale, Position.Y.Offset * DPIScale)
end

local function ApplyTextScale(TextSize)
    return TextSize * DPIScale
end

local function GetTableSize(t)
    local n = 0
    for _, _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function GetPlayers(ExcludeLocalPlayer, ReturnInstances)
    local PlayerList = PL:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)

        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    if ReturnInstances == true then
        return PlayerList
    end

    local FixedPlayerList = {}
    for _, player in next, PlayerList do
        FixedPlayerList[#FixedPlayerList + 1] = player.Name
    end

    return FixedPlayerList
end

local function GetTeams(ReturnInstances)
    local TeamList = TM:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    if ReturnInstances == true then
        return TeamList
    end

    local FixedTeamList = {}
    for _, team in next, TeamList do
        FixedTeamList[#FixedTeamList + 1] = team.Name
    end

    return FixedTeamList
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end

--// Icon Module \\--
type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons, Icons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string"
        and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

function _L:GetIcon(IconName: string)
    if not FetchIcons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end

    return Icon
end

function _L:GetCustomIcon(IconName: string)
    if not IsValidCustomIcon(IconName) then
        return _L:GetIcon(IconName)
    else
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end
end

function _L:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module
end

function _L:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * 2
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

--// Library Functions \\--
function _L:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in pairs(Template) do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = _L:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

function _L:SetDPIScale(value: number) 
    assert(type(value) == "number", "Expected type number for DPI scale but got " .. typeof(value))
    
    DPIScale = value / 100
    _L.MinSize = (if _L.IsMobile then Vector2.new(550, 200) else Vector2.new(550, 300)) * DPIScale
end

function _L:SafeCallback(Func, ...)
    -- https://github.com/deividcomsono/Obsidian/blob/main/_L.lua#L1100
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if _L.NotifyOnError then
            _L:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function _L:AttemptSave()
    if (not _L.SaveManager) then return end
    _L.SaveManager:Save()
end


function _L:Create(Class, Properties)
    local _Instance = Class
    if typeof(Class) == "string" then
        _Instance = Instance.new(Class)
    end

    local ReferenceName = if Properties and Properties.Name then Properties.Name else Class
    local ActualName = _regU(ReferenceName)
    
    _Instance.Name = ActualName
    _protect(_Instance)

    if Properties then
        for Property, Value in next, Properties do
            if Property == "Parent" or Property == "Name" then
                continue
            end

            local AdjustedValue = Value
            if (Property == "Size" or Property == "Position") and typeof(Value) == "UDim2" then
                AdjustedValue = ApplyDPIScale(Value)
            elseif Property == "TextSize" and typeof(Value) == "number" then
                AdjustedValue = ApplyTextScale(Value)
            end

            pcall(function()
                _Instance[Property] = AdjustedValue
            end)
        end

        if Properties.Parent then
            _Instance.Parent = Properties.Parent
        end
    end

    return _Instance
end

function _L:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1

    return _L:Create("UIStroke", {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    })
end

function _L:CreateLabel(Properties, IsHud)
    local _Instance = _L:Create("TextLabel", {
        BackgroundTransparency = 1;
        Font = _L.Font;
        TextColor3 = _L.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
        RichText = true;
    })

    _L:ApplyTextStroke(_Instance)

    _L:AddToRegistry(_Instance, {
        TextColor3 = "FontColor";
    }, IsHud)

    return _L:Create(_Instance, Properties)
end

--// UIGlow Module \\--
--// UIGlow Module \\--
local UIGlow = {}
do
    -- HOLDER テンプレートをコードで生成（別ファイル不要）
    local function createHolder()
        local holder = _L:Create("Frame", {
            Name = "HOLDER",
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, -40, 1, -40),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })

        -- 辺フレームのデータ { name, anchor, size, pos, gradientRotation, gradientTransparency }
        local edges = {
            { "TOP",    Vector2.new(0.5,1), UDim2.new(1,0,0,35), UDim2.new(0.5,0,0,0),   -90, {0,1} },
            { "BOTTOM", Vector2.new(0.5,0), UDim2.new(1,0,0,35), UDim2.new(0.5,0,1,0),    90, {0,1} },
            { "LEFT",   Vector2.new(1,0.5), UDim2.new(0,35,1,0), UDim2.new(0,0,0.5,0),     0, {1,0} },
            { "RIGHT",  Vector2.new(0,0.5), UDim2.new(0,35,1,0), UDim2.new(1,0,0.5,0),     0, {0,1} },
        }
        for _, e in ipairs(edges) do
            local f = _L:Create("Frame", {
                Name = e[1],
                Parent = holder,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 0.5,
                AnchorPoint = e[2],
                Size = e[3],
                Position = e[4]
            })
            _L:Create("UIGradient", {
                Rotation = e[5],
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                }),
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, e[6][1]),
                    NumberSequenceKeypoint.new(1, e[6][2])
                },
                Parent = f
            })
        end

        -- 角 ImageLabel のデータ { name, anchor, pos, rectOffset }
        local IMAGE_ID = "rbxassetid://93208570840427"
        local corners = {
            { "LEFT_TOP",     Vector2.new(1,1), UDim2.new(0,0,0,0),   Vector2.new(0,0)     },
            { "LEFT_BOTTOM",  Vector2.new(1,0), UDim2.new(0,0,1,0),   Vector2.new(0,232)   },
            { "RIGHT_TOP",    Vector2.new(0,1), UDim2.new(1,0,0,0),   Vector2.new(232,0)   },
            { "RIGHT_BOTTOM", Vector2.new(0,0), UDim2.new(1,0,1,0),   Vector2.new(232,232) },
        }
        for _, c in ipairs(corners) do
            _L:Create("ImageLabel", {
                Name = c[1],
                Parent = holder,
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Image = IMAGE_ID,
                ImageColor3 = Color3.fromRGB(0,0,0),
                ImageTransparency = 0.5,
                ScaleType = Enum.ScaleType.Fit,
                SliceCenter = Rect.new(512,512,1024,1024),
                ImageRectSize = Vector2.new(232,232),
                ImageRectOffset = c[4],
                AnchorPoint = c[2],
                Position = c[3],
                Size = UDim2.fromOffset(35,35)
            })
        end

        return holder
    end

    local HOLDER_TEMPLATE = createHolder()

    -- ── ヘルパー ──
    local function getCornerRadius(obj: GuiObject)
        local uc = obj:FindFirstChildOfClass("UICorner")
        if not uc then return 0 end
        return (math.min(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * uc.CornerRadius.Scale)
            + uc.CornerRadius.Offset
    end

    local function updateSizePos(obj: GuiObject, h: Frame, thickness: number)
        local center = obj.AbsolutePosition + obj.AbsoluteSize / 2
        h.Position = UDim2.fromOffset(
            (center - obj.Parent.AbsolutePosition).X,
            (center - obj.Parent.AbsolutePosition).Y
        )
        local cr = getCornerRadius(obj)
        h.Size = UDim2.fromOffset(obj.AbsoluteSize.X - 2*cr, obj.AbsoluteSize.Y - 2*cr)
        local t = thickness + cr
        
        local top = h:FindFirstChild("TOP")
        local bottom = h:FindFirstChild("BOTTOM")
        local left = h:FindFirstChild("LEFT")
        local right = h:FindFirstChild("RIGHT")

        if top then top.Size = UDim2.new(1,0,0,t) end
        if bottom then bottom.Size = UDim2.new(1,0,0,t) end
        if left then left.Size = UDim2.new(0,t,1,0) end
        if right then right.Size = UDim2.new(0,t,1,0) end

        for _, n in ipairs{"LEFT_TOP","LEFT_BOTTOM","RIGHT_TOP","RIGHT_BOTTOM"} do
            local corner = h:FindFirstChild(n)
            if corner then corner.Size = UDim2.fromOffset(t,t) end
        end
    end

    local function updateTransparency(h: Frame, tr: number)
        for _, n in ipairs{"LEFT_TOP","LEFT_BOTTOM","RIGHT_TOP","RIGHT_BOTTOM"} do
            local corner = h:FindFirstChild(n)
            if corner then corner.ImageTransparency = tr end
        end
        for _, n in ipairs{"TOP","BOTTOM","LEFT","RIGHT","HOLDER"} do
            local obj = n == "HOLDER" and h or h:FindFirstChild(n)
            if obj then obj.BackgroundTransparency = tr end
        end
        h.BackgroundTransparency = tr
    end

    local function updateColor(h: Frame, color: Color3)
        for _, n in ipairs{"LEFT_TOP","LEFT_BOTTOM","RIGHT_TOP","RIGHT_BOTTOM"} do
            local corner = h:FindFirstChild(n)
            if corner then corner.ImageColor3 = color end
        end
        for _, n in ipairs{"TOP","BOTTOM","LEFT","RIGHT"} do
            local edge = h:FindFirstChild(n)
            if edge then edge.BackgroundColor3 = color end
        end
        h.BackgroundColor3 = color
    end

    -- ── Public API ──
    function UIGlow.add(obj: GuiObject, transparency: number, thickness: number, color: Color3)
        local h = HOLDER_TEMPLATE:Clone()
        h.Parent = obj.Parent
        h.ZIndex = obj.ZIndex - 1

        updateSizePos(obj, h, thickness)
        updateTransparency(h, transparency)
        updateColor(h, color)

        h:SetAttribute("Transparency", transparency)
        h:SetAttribute("Color", color)

        h:GetAttributeChangedSignal("Transparency"):Connect(function()
            updateTransparency(h, h:GetAttribute("Transparency"))
        end)
        h:GetAttributeChangedSignal("Color"):Connect(function()
            updateColor(h, h:GetAttribute("Color"))
        end)
        obj:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            updateSizePos(obj, h, h:GetAttribute("Thickness") or thickness)
        end)
        obj:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            updateSizePos(obj, h, h:GetAttribute("Thickness") or thickness)
        end)
        obj:GetPropertyChangedSignal("Visible"):Connect(function()
            h.Visible = obj.Visible
        end)

        return h
    end

    function UIGlow.update(obj: GuiObject, transparency: number, thickness: number, color: Color3)
        local h = obj.Parent:FindFirstChild("HOLDER")
        if h then
            updateTransparency(h, transparency)
            updateColor(h, color)
            updateSizePos(obj, h, thickness)
            h:SetAttribute("Transparency", transparency)
            h:SetAttribute("Color", color)
            h:SetAttribute("Thickness", thickness)
        end
    end

    function UIGlow:Create(obj, info)
        local h = self.add(obj, info.Transparency or 0.5, info.Thickness or 25, info.Color or Color3.fromRGB(0,0,0))
        h.Visible = info.Enabled or false
        
        local glow = { Holder = h }
        function glow:Update(newInfo)
            if newInfo.Transparency then updateTransparency(h, newInfo.Transparency) end
            if newInfo.Color then updateColor(h, newInfo.Color) end
            if newInfo.Thickness then updateSizePos(obj, h, newInfo.Thickness) end
            if newInfo.Enabled ~= nil then h.Visible = newInfo.Enabled end
        end
        return glow
    end
end

function _L:MakeDraggable(Instance, Cutoff, IsMainWindow)
    Instance.Active = true

    if _L.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and _L.CantDragForced == true then
                    return
                end
           
                local ObjPos = Vector2.new(
                    Mouse.X - Instance.AbsolutePosition.X,
                    Mouse.Y - Instance.AbsolutePosition.Y
                )

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(
                        0,
                        Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                        0,
                        Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                    )

                    RS.RenderStepped:Wait()
                end
            end
        end)
    else
        local Dragging, DraggingInput, DraggingStart, StartPosition

        UIS.TouchStarted:Connect(function(Input)
            if IsMainWindow == true and _L.CantDragForced == true then
                Dragging = false
                return
            end

            if not Dragging and _L:MouseIsOverFrame(Instance, Input) and (IsMainWindow == true and (_L.CanDrag == true and _L.Window.Holder.Visible == true) or true) then
                DraggingInput = Input
                DraggingStart = Input.Position
                StartPosition = Instance.Position

                local OffsetPos = Input.Position - DraggingStart
                if OffsetPos.Y > (Cutoff or 40) then
                    Dragging = false
                    return
                end

                Dragging = true
            end
        end)
        UIS.TouchMoved:Connect(function(Input)
            if IsMainWindow == true and _L.CantDragForced == true then
                Dragging = false
                return
            end

            if Input == DraggingInput and Dragging and (IsMainWindow == true and (_L.CanDrag == true and _L.Window.Holder.Visible == true) or true) then
                local OffsetPos = Input.Position - DraggingStart

                Instance.Position = UDim2.new(
                    StartPosition.X.Scale,
                    StartPosition.X.Offset + OffsetPos.X,
                    StartPosition.Y.Scale,
                    StartPosition.Y.Offset + OffsetPos.Y
                )
            end
        end)
        UIS.TouchEnded:Connect(function(Input)
            if Input == DraggingInput then 
                Dragging = false
            end
        end)
    end
end

function _L:MakeDraggableUsingParent(Instance, Parent, Cutoff, IsMainWindow)
    Instance.Active = true

    if _L.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and _L.CantDragForced == true then
                    return
                end
  
                local ObjPos = Vector2.new(
                    Mouse.X - Parent.AbsolutePosition.X,
                    Mouse.Y - Parent.AbsolutePosition.Y
                )

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Parent.Position = UDim2.new(
                        0,
                        Mouse.X - ObjPos.X + (Parent.Size.X.Offset * Parent.AnchorPoint.X),
                        0,
                        Mouse.Y - ObjPos.Y + (Parent.Size.Y.Offset * Parent.AnchorPoint.Y)
                    )

                    RS.RenderStepped:Wait()
                end
            end
        end)
    else  
        _L:MakeDraggable(Parent, Cutoff, IsMainWindow)
    end
end

function _L:MakeResizable(Instance, MinSize)
    if _L.IsMobile then
        return
    end

    Instance.Active = true
    
    local ResizerImage_Size = 25 * DPIScale
    local ResizerImage_HoverTransparency = 0.5

    local Resizer = _L:Create("Frame", {
        SizeConstraint = Enum.SizeConstraint.RelativeXX;
        BackgroundColor3 = Color3.new(0, 0, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 30, 0, 30);
        Position = UDim2.new(1, -30, 1, -30);
        Visible = true;
        ClipsDescendants = true;
        ZIndex = 1;
        Parent = Instance;--_L.ScreenGui;
    })

    local ResizerImage = _L:Create("ImageButton", {
        BackgroundColor3 = _L.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(2, 0, 2, 0);
        Position = UDim2.new(1, -30, 1, -30);
        ZIndex = 2;
        Parent = Resizer;
    })

    local ResizerImageUICorner = _L:Create("UICorner", {
        CornerRadius = UDim.new(0.5, 0);
        Parent = ResizerImage;
    })

    _L:AddToRegistry(ResizerImage, { BackgroundColor3 = "AccentColor"; })

    Resizer.Size = UDim2.fromOffset(ResizerImage_Size, ResizerImage_Size)
    Resizer.Position = UDim2.new(1, -ResizerImage_Size, 1, -ResizerImage_Size)
    MinSize = MinSize or _L.MinSize

    local OffsetPos
    Resizer.Parent = Instance

    local function FinishResize(Transparency)
        ResizerImage.Position = UDim2.new()
        ResizerImage.Size = UDim2.new(2, 0, 2, 0)
        ResizerImage.Parent = Resizer
        ResizerImage.BackgroundTransparency = Transparency
        ResizerImageUICorner.Parent = ResizerImage
        OffsetPos = nil
    end

    ResizerImage.MouseButton1Down:Connect(function()
        if not OffsetPos then
            OffsetPos = Vector2.new(Mouse.X - (Instance.AbsolutePosition.X + Instance.AbsoluteSize.X), Mouse.Y - (Instance.AbsolutePosition.Y + Instance.AbsoluteSize.Y))

            ResizerImage.BackgroundTransparency = 1
            ResizerImage.Size = UDim2.fromOffset(_L.ScreenGui.AbsoluteSize.X, _L.ScreenGui.AbsoluteSize.Y)
            ResizerImage.Position = UDim2.new()
            ResizerImageUICorner.Parent = nil
            ResizerImage.Parent = _L.ScreenGui
        end
    end)

    ResizerImage.MouseMoved:Connect(function()
        if OffsetPos then		
            local MousePos = Vector2.new(Mouse.X - OffsetPos.X, Mouse.Y - OffsetPos.Y)
            local FinalSize = Vector2.new(math.clamp(MousePos.X - Instance.AbsolutePosition.X, MinSize.X, math.huge), math.clamp(MousePos.Y - Instance.AbsolutePosition.Y, MinSize.Y, math.huge))
            Instance.Size = UDim2.fromOffset(FinalSize.X, FinalSize.Y)
        end
    end)

    ResizerImage.MouseEnter:Connect(function()
        FinishResize(ResizerImage_HoverTransparency)
    end)

    ResizerImage.MouseLeave:Connect(function()
        FinishResize(1)
    end)

    ResizerImage.MouseButton1Up:Connect(function()
        FinishResize(ResizerImage_HoverTransparency)
    end)
end

function _L:AddToolTip(InfoStr, DisabledInfoStr, HoverInstance)
    InfoStr = typeof(InfoStr) == "string" and InfoStr or nil
    DisabledInfoStr = typeof(DisabledInfoStr) == "string" and DisabledInfoStr or nil

    local Tooltip = _L:Create("Frame", {
        BackgroundColor3 = _L.MainColor;
        BorderColor3 = _L.OutlineColor;

        ZIndex = 100;
        Parent = _L.ScreenGui;

        Visible = false;
    })

    local Label = _L:CreateLabel({
        Position = UDim2.fromOffset(3, 1);
        
        TextSize = 14;
        Text = InfoStr;
        TextColor3 = _L.FontColor;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1;

        Parent = Tooltip;
    })

    _L:AddToRegistry(Tooltip, {
        BackgroundColor3 = "MainColor";
        BorderColor3 = "OutlineColor";
    })

    _L:AddToRegistry(Label, {
        TextColor3 = "FontColor",
    })

    local TooltipTable = {
        Tooltip = Tooltip;
        Disabled = false;

        Signals = {};
    }
    local IsHovering = false

    local function UpdateText(Text)
        if Text == nil then return end

        local X, Y = _L:GetTextBounds(Text, _L.Font, 14 * DPIScale)

        Label.Text = Text
        Tooltip.Size = UDim2.fromOffset(X + 5, Y + 4)
        Label.Size = UDim2.fromOffset(X, Y)
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    UpdateText(InfoStr)

    GiveSignal(HoverInstance.MouseEnter:Connect(function()
        if _L:MouseIsOverOpenedFrame() then
            Tooltip.Visible = false
            return
        end

        if not TooltipTable.Disabled then
            if InfoStr == nil or InfoStr == "" then
                Tooltip.Visible = false
                return
            end

            if Label.Text ~= InfoStr then
                UpdateText(InfoStr)
            end
        else
            if DisabledInfoStr == nil or DisabledInfoStr == "" then
                Tooltip.Visible = false
                return
            end

            if Label.Text ~= DisabledInfoStr then 
                UpdateText(DisabledInfoStr)
            end
        end

        IsHovering = true

        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true

        while IsHovering do
            if TooltipTable.Disabled == true and DisabledInfoStr == nil then break end

            RS.Heartbeat:Wait()
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end

        IsHovering = false
        Tooltip.Visible = false
    end))

    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end))
    
    if LibraryMainOuterFrame then
        GiveSignal(LibraryMainOuterFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if LibraryMainOuterFrame.Visible == false then
                IsHovering = false
                Tooltip.Visible = false
            end
        end))
    end

    function TooltipTable:Destroy()
        for Idx = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Idx)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        Tooltip:Destroy()
    end

    table.insert(Tooltips, TooltipTable)
    return TooltipTable
end

function _L:MouseIsOverFrame(Frame, Input)
    local Pos = Mouse
    if _L.IsMobile and Input then 
        Pos = Input.Position
    end

    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then

        return true
    end

    return false
end

function _L:IsFrameInsideDialog(Frame)
    if not _L.ActiveDialog then return false end

    local Pos = Frame.AbsolutePosition
    local AbsPos, AbsSize = _L.ActiveDialog.Container.AbsolutePosition, _L.ActiveDialog.Container.AbsoluteSize
   
    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then

        return true
    end

    return false
end

function _L:MouseIsOverOpenedFrame(Input)
    -- Inside active dialog
    if _L.ActiveDialog then
        if _L:MouseIsOverFrame(_L.ActiveDialog.Container, Input) then
            return false
        end

        return true
    end

    -- Inside opened frames
    for Frame, _ in next, _L.OpenedFrames do
        if _L:MouseIsOverFrame(Frame, Input) then
            return true
        end
    end

    return false
end
function _L:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault, condition)
    local function undoHighlight()
        local Reg = _L.RegistryMap[Instance]

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = _L[ColorIdx] or ColorIdx

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx
            end
        end
    end

    local function doHighlight()
        if condition and not condition() then 
            undoHighlight()
            return 
        end

        if _L.ActiveDialog and not _L:IsFrameInsideDialog(Instance) then
            undoHighlight()
            return
        end

        local Reg = _L.RegistryMap[Instance]

        for Property, ColorIdx in next, Properties do
            Instance[Property] = _L[ColorIdx] or ColorIdx

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx
            end
        end
    end

    HighlightInstance.MouseEnter:Connect(doHighlight)
    HighlightInstance.MouseMoved:Connect(doHighlight)
    HighlightInstance.MouseLeave:Connect(undoHighlight)
end

function _L:UpdateDependencyBoxes()
    for _, Depbox in next, _L.DependencyBoxes do
        Depbox:Update()
    end
end

function _L:UpdateDependencyGroupboxes()
    for _, Depbox in next, _L.DependencyGroupboxes do
        Depbox:Update()
    end
end

function _L:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB
end

function _L:GetTextBounds(Text, Font, Size, Resolution)
    -- Ignores rich text formatting --
    if typeof(Resolution) == "number" then
        Resolution = Vector2.new(Resolution, 10000)
    end

    local Bounds = TS:GetTextSize(Text:gsub("<%/?[%w:]+[^>]*>", ""), Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end

function _L:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color)
    return Color3.fromHSV(H, S, V / 1.5)
end
_L.AccentColorDark = _L:GetDarkerColor(_L.AccentColor)

function _L:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #_L.Registry + 1
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    }

    table.insert(_L.Registry, Data)
    _L.RegistryMap[Instance] = Data

    if IsHud then
        table.insert(_L.HudRegistry, Data)
    end
end

function _L:RemoveFromRegistry(Instance)
    local Data = _L.RegistryMap[Instance]

    if Data then
        for Idx = #_L.Registry, 1, -1 do
            if _L.Registry[Idx] == Data then
                table.remove(_L.Registry, Idx)
            end
        end

        for Idx = #_L.HudRegistry, 1, -1 do
            if _L.HudRegistry[Idx] == Data then
                table.remove(_L.HudRegistry, Idx)
            end
        end

        _L.RegistryMap[Instance] = nil
    end
end

function _L:UpdateColorsUsingRegistry()
    -- TODO: Could have an "active" list of objects
    -- where the active list only contains Visible objects.

    -- IMPL: Could setup .Changed events on the AddToRegistry function
    -- that listens for the "Visible" propert being changed.
    -- Visible: true => Add to active list, and call UpdateColors function
    -- Visible: false => Remove from active list.

    -- The above would be especially efficient for a rainbow menu color or live color-changing.

    for Idx, Object in next, _L.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if typeof(ColorIdx) == "string" then
                Object.Instance[Property] = _L[ColorIdx]
            elseif typeof(ColorIdx) == "function" then
                Object.Instance[Property] = ColorIdx()
            end
        end
    end
end

function _L:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal) -- Only used for signals not attached to library instances, as those should be cleaned up on object destruction by Roblox
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(_L.Signals, Connection)
    end

    return Connection
end

function _L:Unload()
    for Idx = #_L.Signals, 1, -1 do
        local Connection = table.remove(_L.Signals, Idx)
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    for _, UnloadCallback in _L.UnloadSignals do
        _L:SafeCallback(UnloadCallback)
    end

    for _, Tooltip in Tooltips do
        _L:SafeCallback(Tooltip.Destroy, Tooltip)
    end

    _L.Unloaded = true
    ScreenGui:Destroy()

    getgenv().Linoria = nil
end

function _L:OnUnload(Callback)
    table.insert(_L.UnloadSignals, Callback)
end

_L:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if _L.Unloaded then
        return
    end

    if _L.RegistryMap[Instance] then
        _L:RemoveFromRegistry(Instance)
    end
end))

--// Templates \\--
local Templates = { -- TO-DO: do it for missing elements.
    --// Window \\--
    Window = {
        Title = "No Title",
        AutoShow = false,
        Position = UDim2.fromOffset(175, 50),
        Size = UDim2.fromOffset(0, 0),
        AnchorPoint = Vector2.zero,
        TabPadding = 1,
        MenuFadeTime = 0.2,
        NotifySide = "Left",
        TitleSide = "Left",
        -- TitlePos: "Left", "Center", "Right" (TitleSideの別名・拡張版)
        TitlePos = nil,
        -- TitleAnimated: タイトルのアニメーション設定
        TitleAnimated = {
            Type = "None",      -- "None", "Fade", "Slide"
            Speed = 0.3,        -- アニメーションの速さ (秒)
            Direction = "Left", -- Slideの場合: "Left","Right","Up","Down"
        },
        -- TabButtonSize: メインタブボタンサイズを手動指定 (UDim2 or nil=自動)
        TabButtonSize = nil,
        -- SubTabButtonSize: サブタブ(Tab内Tab)のボタンサイズ (UDim2 or nil=自動)
        SubTabButtonSize = nil,
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        Center = false,
        Glow = {
            Enabled = false,
            Thickness = 36,
            Color = Color3.fromRGB(220, 0, 0),
            Transparency = 0.25,
        },
        Intro = {
            Enabled = false,
            Title = "LinoriaX",
            SubTitle = "Made by @6j2r",
            Time = 5,
            ReleaseLog = {},
        }
    },

    --// Elements \\--
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    }
}

--// Addons \\--
local BaseAddons = {}
do
    local BaseAddonsFuncs = {}

        function BaseAddonsFuncs:AddKeyPicker(Idx, Info)
        local ParentObj = self
        local ToggleLabel = self.TextLabel
        --local Container = self.Container;

        assert(Info.Default, string.format("AddKeyPicker (IDX: %s): Missing default value.", tostring(Idx)))

        local KeyPicker = {
            Value = nil; -- Key
            Modifiers = {}; -- Modifiers
            DisplayValue = nil; -- Picker Text

            Toggled = false;
            Mode = Info.Mode or "Toggle"; -- Always, Toggle, Hold, Press
            Type = "KeyPicker";
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;
            SyncToggleState = Info.SyncToggleState or false;
        }

        Info.Text = Info.Text or ParentObj.Text or (ParentObj.TextLabel and ParentObj.TextLabel.Text) or "Keybind"

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label", "KeyPicker with the mode \"Press\" can be only applied on Labels.")
            
            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3"
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock"
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then continue end
                if not UIS:IsKeyDown(Input) then continue end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then 
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then continue end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then 
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UIS:IsMouseButtonPressed(Input.UserInputType) and not UIS:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UIS:IsKeyDown(Input.KeyCode) and not UIS:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then continue end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        local PickOuter = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        })

        local PickInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        })

        _L:AddToRegistry(PickInner, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local DisplayLabel = _L:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickInner;
        })

        -- Keybinds Text
        local KeybindsToggle = {}
        do
            local KeybindsToggleContainer = _L:Create("Frame", {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 18);
                Visible = false;
                ZIndex = 110;
                Parent = _L.KeybindContainer;
            })

            local KeybindsToggleOuter = _L:Create("Frame", {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 13, 0, 13);
                Position = UDim2.new(0, 0, 0, 6);
                Visible = true;
                ZIndex = 110;
                Parent = KeybindsToggleContainer;
            })

            _L:AddToRegistry(KeybindsToggleOuter, {
                BorderColor3 = "Black";
            })

            local KeybindsToggleInner = _L:Create("Frame", {
                BackgroundColor3 = _L.MainColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 111;
                Parent = KeybindsToggleOuter;
            })

            _L:AddToRegistry(KeybindsToggleInner, {
                BackgroundColor3 = "MainColor";
                BorderColor3 = "OutlineColor";
            })

            local KeybindsToggleLabel = _L:CreateLabel({
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 216, 1, 0);
                Position = UDim2.new(1, 6, 0, -1);
                TextSize = 14;
                Text = "";
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 111;
                Parent = KeybindsToggleInner;
            })

            _L:Create("UIListLayout", {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = KeybindsToggleLabel;
            })

            local KeybindsToggleRegion = _L:Create("Frame", {
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 170, 1, 0);
                ZIndex = 113;
                Parent = KeybindsToggleOuter;
            })

            _L:OnHighlight(KeybindsToggleRegion, KeybindsToggleOuter,
                { BorderColor3 = "AccentColor" },
                { BorderColor3 = "Black" },
                function()
                    return true
                end
            )

            function KeybindsToggle:Display(State)
                KeybindsToggleInner.BackgroundColor3 = State and _L.AccentColor or _L.MainColor
                KeybindsToggleInner.BorderColor3 = State and _L.AccentColorDark or _L.OutlineColor
                KeybindsToggleLabel.TextColor3 = State and _L.AccentColor or _L.FontColor

                _L.RegistryMap[KeybindsToggleInner].Properties.BackgroundColor3 = State and "AccentColor" or "MainColor"
                _L.RegistryMap[KeybindsToggleInner].Properties.BorderColor3 = State and "AccentColorDark" or "OutlineColor"
                _L.RegistryMap[KeybindsToggleLabel].Properties.TextColor3 = State and "AccentColor" or "FontColor"
            end

            function KeybindsToggle:SetText(Text)
                KeybindsToggleLabel.Text = Text
            end

            function KeybindsToggle:SetVisibility(bool)
                KeybindsToggleContainer.Visible = bool
            end

            function KeybindsToggle:SetNormal(bool)
                KeybindsToggle.Normal = bool

                KeybindsToggleOuter.BackgroundTransparency = if KeybindsToggle.Normal then 1 else 0

                KeybindsToggleInner.BackgroundTransparency = if KeybindsToggle.Normal then 1 else 0
                KeybindsToggleInner.BorderSizePixel = if KeybindsToggle.Normal then 0 else 1

                KeybindsToggleLabel.Position = if KeybindsToggle.Normal then UDim2.new(1, -13, 0, -1) else UDim2.new(1, 6, 0, -1)
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            _L:GiveSignal(KeybindsToggleRegion.InputBegan:Connect(function(Input)
                if _L.Unloaded then
                    return
                end

                if KeybindsToggle.Normal then return end
                                        
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            end))

            KeybindsToggle.Loaded = true
        end

        local ModeSelectOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 80, 0, 0);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        })

        local function UpdateMenuOuterPos()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y)
        end

        UpdateMenuOuterPos()
        ToggleLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateMenuOuterPos)

        local ModeSelectInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 0, 3);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        })

        _L:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        _L:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        })

        local Modes = Info.Modes or { "Always", "Toggle", "Hold" }
        local ModeButtons = {}
        local UnbindButton = {}

        for Idx, Mode in next, Modes do
            local ModeButton = {}

            local Label = _L:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            })
            ModeSelectInner.Size = ModeSelectInner.Size + UDim2.new(0, 0, 0, 15)
            ModeSelectOuter.Size = ModeSelectOuter.Size + UDim2.new(0, 0, 0, 18)

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Label.TextColor3 = _L.AccentColor
                _L.RegistryMap[Label].Properties.TextColor3 = "AccentColor"

                ModeSelectOuter.Visible = false
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Label.TextColor3 = _L.FontColor
                _L.RegistryMap[Label].Properties.TextColor3 = "FontColor"
            end

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select()
                end
            end)

            if Mode == KeyPicker.Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        -- Create Unbind button --
        do
            local UnbindInner = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.new(0, 0, 0, ModeSelectInner.Size.Y.Offset + 3);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 15;
                Parent = ModeSelectOuter;
            })

            ModeSelectOuter.Size = ModeSelectOuter.Size + UDim2.new(0, 0, 0, 18)

            _L:AddToRegistry(UnbindInner, {
                BackgroundColor3 = "BackgroundColor";
                BorderColor3 = "OutlineColor";
            })

            local UnbindLabel = _L:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = "Unbind Key";
                ZIndex = 16;
                Parent = UnbindInner;
            })

            KeyPicker.SetValue = function(...) end --// make luau lsp shut up
            function UnbindButton:UnbindKey()
                KeyPicker:SetValue({ nil, KeyPicker.Mode, {} })
                ModeSelectOuter.Visible = false
            end

            UnbindLabel.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    UnbindButton:UnbindKey()
                end
            end)
        end

        function KeyPicker:Display(Text)
            DisplayLabel.Text = Text or KeyPicker.DisplayValue

            PickOuter.Size = UDim2.new(0, 999999, 0, 18)
            RS.RenderStepped:Wait()
            PickOuter.Size = UDim2.new(0, math.max(28, DisplayLabel.TextBounds.X + 8), 0, 18)
        end

        function KeyPicker:Update()
            if Info.NoUI then
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = _L.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.SetValue and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if KeybindsToggle.Loaded then
                KeybindsToggle:SetNormal(not ShowToggle)

                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:SetText(string.format("[%s] %s (%s)", tostring(KeyPicker.DisplayValue), Info.Text, KeyPicker.Mode))
                KeybindsToggle:Display(State)
            end

            local YSize = 0
            local XSize = 0

            for _, Frame in next, _L.KeybindContainer:GetChildren() do
                if Frame:IsA("Frame") and Frame.Visible then
                    YSize = YSize + 18
                    local Label = Frame:FindFirstChild("TextLabel", true)
                    if not Label then continue end
                    
                    local LabelSize = Label.TextBounds.X + 20
                    if (LabelSize > XSize) then
                        XSize = LabelSize
                    end
                end
            end

            _L.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 220), 0, (YSize + 23 + 6) * DPIScale)
            UpdateMenuOuterPos()
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    return UIS:IsMouseButtonPressed(SpecialKeys[Key]) and not UIS:GetFocusedTextBox()
                else
                    return UIS:IsKeyDown(Enum.KeyCode[Key]) and not UIS:GetFocusedTextBox()
                end

            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:SetValue(Data, SkipCallback)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, UserInputType = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end
                
                if SpecialKeys[Key] == nil then 
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers = VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0 then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value) else KeyPicker.Value

            DisplayLabel.Text = KeyPicker.DisplayValue

            if Mode ~= nil and ModeButtons[Mode] ~= nil then 
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Display()
            KeyPicker:Update()

            if SkipCallback == true then return end
            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            _L:SafeCallback(KeyPicker.ChangedCallback, UserInputType, NewModifiers)
            _L:SafeCallback(KeyPicker.Changed, UserInputType, NewModifiers)
        end

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            -- Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker:DoClick()
            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            _L:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            _L:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:SetModePickerVisibility(bool)
            ModeSelectOuter.Visible = bool
        end

        function KeyPicker:GetModePickerVisibility()
            return ModeSelectOuter.Visible
        end

        PickOuter.InputBegan:Connect(function(PickerInput)
            if PickerInput.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame() then
                Picking = true

                KeyPicker:Display("...")

                -- Wait for an non modifier key --
                local Input
                local ActiveModifiers = {}

                local GetInput = function()
                    Input = UIS.InputBegan:Wait()
                    if UIS:GetFocusedTextBox() then
                        return true
                    end

                    return false
                end

                repeat
                    task.wait()

                    -- Wait for any input --
                    KeyPicker:Display("...")

                    if GetInput() then
                        Picking = false
                        KeyPicker:Update()
                        return
                    end

                    -- Escape --
                    if Input.KeyCode == Enum.KeyCode.Escape then
                        break
                    end

                    -- Handle modifier keys --
                    if IsModifierInput(Input) then
                        local StopLoop = false

                        repeat
                            task.wait()
                            if UIS:IsKeyDown(Input.KeyCode) then
                                task.wait(0.075)

                                if UIS:IsKeyDown(Input.KeyCode) then
                                    -- Add modifier to the key list --
                                    if not table.find(ActiveModifiers, ModifiersInput[Input.KeyCode]) then
                                        ActiveModifiers[#ActiveModifiers + 1] = ModifiersInput[Input.KeyCode]
                                        KeyPicker:Display(table.concat(ActiveModifiers, " + ") .. " + ...")
                                    end

                                    -- Wait for another input --
                                    if GetInput() then
                                        StopLoop = true
                                        break -- Invalid Input
                                    end

                                    -- Escape --
                                    if Input.KeyCode == Enum.KeyCode.Escape then
                                        break
                                    end

                                    -- Stop loop if its a normal key --
                                    if not IsModifierInput(Input) then
                                        break
                                    end
                                else
                                    if not table.find(ActiveModifiers, ModifiersInput[Input.KeyCode]) then
                                        break -- Modifier is meant to be used as a normal key --
                                    end
                                end
                            end
                        until false

                        if StopLoop then
                            Picking = false
                            KeyPicker:Update()
                            return
                        end
                    end

                    break -- Input found, end loop
                until false

                local Key = "Unknown"
                if SpecialKeysInput[Input.UserInputType] ~= nil then
                    Key = SpecialKeysInput[Input.UserInputType]
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                    Key = Input.KeyCode == Enum.KeyCode.Escape and "None" or Input.KeyCode.Name
                end

                ActiveModifiers = if Input.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

                KeyPicker.Toggled = false
                KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

                -- RS.RenderStepped:Wait()
                repeat task.wait() until not IsInputDown(Input) or UIS:GetFocusedTextBox()
                Picking = false

            elseif PickerInput.UserInputType == Enum.UserInputType.MouseButton2 and not _L:MouseIsOverOpenedFrame() then
                local visible = KeyPicker:GetModePickerVisibility()
                
                if visible == false then
                    for _, option in next, Options do
                        if option.Type == "KeyPicker" then
                            option:SetModePickerVisibility(false)
                        end
                    end
                end

                KeyPicker:SetModePickerVisibility(not visible)
            end
        end)

        _L:GiveSignal(UIS.InputBegan:Connect(function(Input)
            if _L.Unloaded then
                return
            end

            if KeyPicker.Value == "Unknown" then return end
        
            if (not Picking) and (not UIS:GetFocusedTextBox()) then
                local Key = KeyPicker.Value
                local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
                local HoldingKey = false

                if HoldingModifiers then
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            HoldingKey = true
                        end
                    elseif SpecialKeysInput[Input.UserInputType] == Key then
                        HoldingKey = true
                    end
                end

                if KeyPicker.Mode == "Toggle" then
                    if HoldingKey then
                        KeyPicker.Toggled = not KeyPicker.Toggled
                        KeyPicker:DoClick()
                    end
                elseif KeyPicker.Mode == "Press" then
                    if HoldingKey then
                        KeyPicker:DoClick()
                    end
                end

                KeyPicker:Update()
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    KeyPicker:SetModePickerVisibility(false)
                end
            end
        end))

        _L:GiveSignal(UIS.InputEnded:Connect(function(Input)
            if _L.Unloaded then
                return
            end

            if (not Picking) then
                KeyPicker:Update()
            end
        end))
        
        KeyPicker:SetValue({ Info.Default, Info.Mode or "Toggle", Info.DefaultModifiers }, true)
        KeyPicker.DisplayFrame = PickOuter

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        Options[Idx] = KeyPicker

        return self
    end

    function BaseAddonsFuncs:AddColorPicker(Idx, Info)
        local ParentObj = self
        local ToggleLabel = self.TextLabel
        --local Container = self.Container;

        assert(Info.Default, string.format("AddColorPicker (IDX: %s): Missing default value.", tostring(Idx)))

        local ColorPicker = {
            Value = Info.Default;

            Transparency = Info.Transparency or 0;
            Type = "ColorPicker";
            Title = typeof(Info.Title) == "string" and Info.Title or "Color picker",
            Callback = Info.Callback or function(Color) end;
            Changed = nil,
        }

        local PreviousValues = {
            Value = nil,
            Transparency = nil
        }

        local function RunCallback()
            local NewValue = ColorPicker.Value
            local NewTransparency = ColorPicker.Transparency

            if NewValue == PreviousValues.Value and NewTransparency == PreviousValues.Transparency then
                return
            end

            PreviousValues.Value = ColorPicker.Value
            PreviousValues.Transparency = ColorPicker.Transparency

            _L:SafeCallback(ColorPicker.Callback, ColorPicker.Value, ColorPicker.Transparency)
            _L:SafeCallback(ColorPicker.Changed, ColorPicker.Value, ColorPicker.Transparency)
        end

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color:ToHSV()

            ColorPicker.Hue = H
            ColorPicker.Sat = S
            ColorPicker.Vib = V
        end

        ColorPicker:SetHSVFromRGB(ColorPicker.Value)

        local DisplayFrame = _L:Create("Frame", {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = _L:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        })

        -- Transparency image taken from https://github.com/matas3535/SplixPrivateDrawingLibrary/blob/main/_L.lua cus i'm lazy
        _L:Create("ImageLabel", {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = "rbxassetid://12977615774";
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        })

        -- 1/16/23
        -- Rewrote this to be placed inside the Library ScreenGui
        -- There was some issue which caused RelativeOffset to be way off
        -- Thus the color picker would never show

        local PickerFrameOuter = _L:Create("Frame", {
            Name = "Color";
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        })

        DisplayFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18)
        end)

        local PickerFrameInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        })

        local Highlight = _L:Create("Frame", {
            BackgroundColor3 = _L.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        })

        local SatVibMapOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        })

        local SatVibMapInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        })

        local SatVibMap = _L:Create("ImageLabel", {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = "rbxassetid://4155801252";
            Parent = SatVibMapInner;
        })

        local CursorOuter = _L:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = "rbxassetid://9619665977";
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        })

        _L:Create("ImageLabel", {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = "rbxassetid://9619665977";
            ZIndex = 20;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        })

        local HueSelectorInner = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        })

        local HueCursor = _L:Create("Frame", { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 18;
            Parent = HueSelectorInner;
        })

        local HueBoxOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner;
        })

        local HueBoxInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        })

        _L:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        })

        local HueBox = _L:Create("TextBox", {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = _L.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = "Hex color",
            Text = "#FFFFFF",
            TextColor3 = _L.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        })

        _L:ApplyTextStroke(HueBox)

        local RgbBoxBase = _L:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner
        })

        local RgbBox = _L:Create(RgbBoxBase:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextBox"), {
            Text = "255, 255, 255",
            PlaceholderText = "RGB color",
            TextColor3 = _L.FontColor
        })

        local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor
        
        if Info.Transparency then 
            TransparencyBoxOuter = _L:Create("Frame", {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameInner;
            })

            TransparencyBoxInner = _L:Create("Frame", {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 19;
                Parent = TransparencyBoxOuter;
            })

            _L:AddToRegistry(TransparencyBoxInner, { BorderColor3 = "OutlineColor" })

            _L:Create("ImageLabel", {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = "rbxassetid://12978095818";
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            })

            TransparencyCursor = _L:Create("Frame", { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxInner;
            })
        end

        -- local DisplayLabel = 
        _L:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title,--Info.Default;
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        })

        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = _L:Create("Frame", {
                BorderColor3 = Color3.new(),
                ZIndex = 14,

                Visible = false,
                Parent = ScreenGui
            })

            ContextMenu.Inner = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            })

            _L:Create("UIListLayout", {
                Name = "Layout",
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            })

            _L:Create("UIPadding", {
                Name = "Padding",
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            })

            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                )
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA("TextLabel") then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                )
            end

            DisplayFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            _L:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = "BackgroundColor";
                BorderColor3 = "OutlineColor";
            })

            function ContextMenu:Show()
                if _L.IsMobile then
                    _L.CanDrag = false
                end

                self.Container.Visible = true
            end

            function ContextMenu:Hide()
                if _L.IsMobile then
                    _L.CanDrag = true
                end
                
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if typeof(Callback) ~= "function" then
                    Callback = function() end
                end

                local Button = _L:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                _L:OnHighlight(Button, Button, 
                    { TextColor3 = "AccentColor" },
                    { TextColor3 = "FontColor" }
                )

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    Callback()
                end)
            end

            ContextMenu:AddOption("Copy color", function()
                _L.ColorClipboard = ColorPicker.Value
                _L:Notify("Copied color!", 2)
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            ContextMenu:AddOption("Paste color", function()
                if not _L.ColorClipboard then
                    _L:Notify("You have not copied a color!", 2)
                    return
                end

                ColorPicker:SetValueRGB(_L.ColorClipboard)
            end)

            ContextMenu:AddOption("Copy HEX", function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                _L:Notify("Copied hex code to clipboard!", 2)
            end)

            ContextMenu:AddOption("Copy RGB", function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ", "))
                _L:Notify("Copied RGB values to clipboard!", 2)
            end)
        end
        ColorPicker.ContextMenu = ContextMenu

        _L:AddToRegistry(PickerFrameInner, { BackgroundColor3 = "BackgroundColor"; BorderColor3 = "OutlineColor"; })
        _L:AddToRegistry(Highlight, { BackgroundColor3 = "AccentColor"; })
        _L:AddToRegistry(SatVibMapInner, { BackgroundColor3 = "BackgroundColor"; BorderColor3 = "OutlineColor"; })

        _L:AddToRegistry(HueBoxInner, { BackgroundColor3 = "MainColor"; BorderColor3 = "OutlineColor"; })
        _L:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = "MainColor"; BorderColor3 = "OutlineColor"; })
        _L:AddToRegistry(RgbBox, { TextColor3 = "FontColor", })
        _L:AddToRegistry(HueBox, { TextColor3 = "FontColor", })

        local SequenceTable = {}

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
        end

        -- local HueSelectorGradient =
        _L:Create("UIGradient", {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        })

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)

            _L:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = _L:GetDarkerColor(ColorPicker.Value);
            })

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0)
            end

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0)

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ", ")
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, ColorPicker)
        end

        function ColorPicker:Show()
            for Frame, Val in next, _L.OpenedFrames do
                if Frame.Name == "Color" then
                    Frame.Visible = false
                    _L.OpenedFrames[Frame] = nil
                end
            end

            PickerFrameOuter.Visible = true
            _L.OpenedFrames[PickerFrameOuter] = true
        end

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false
            _L.OpenedFrames[PickerFrameOuter] = nil
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

            ColorPicker.Transparency = Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()

            RunCallback()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Display()

            RunCallback()
        end

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == "Color3" then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinX = SatVibMap.AbsolutePosition.X
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                    local MinY = SatVibMap.AbsolutePosition.Y
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX)
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))
                    ColorPicker:Display()

                    RunCallback()

                    RS.RenderStepped:Wait()
                end

                _L:AttemptSave()
            end
        end)

        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinY = HueSelectorInner.AbsolutePosition.Y
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY))
                    ColorPicker:Display()

                    RunCallback()

                    RS.RenderStepped:Wait()
                end

                _L:AttemptSave()
            end
        end)

        DisplayFrame.InputBegan:Connect(function(Input)
            if _L:MouseIsOverOpenedFrame(Input) then
                return
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end)

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                        local MinX = TransparencyBoxInner.AbsolutePosition.X
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX))
                        ColorPicker:Display()

                        RunCallback()

                        RS.RenderStepped:Wait()
                    end

                    _L:AttemptSave()
                end
            end)
        end

        _L:GiveSignal(UIS.InputBegan:Connect(function(Input)
            if _L.Unloaded then
                return
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ColorPicker:Hide()
                end

                if not _L:MouseIsOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide()
                end
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not _L:MouseIsOverFrame(ContextMenu.Container) and not _L:MouseIsOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end))

        ColorPicker:Display()
        ColorPicker.DisplayFrame = DisplayFrame

        ColorPicker.Default = ColorPicker.Value

        Options[Idx] = ColorPicker

        return self
    end

    function BaseAddonsFuncs:AddDropdown(Idx, Info)
        Info.ReturnInstanceInstead = if typeof(Info.ReturnInstanceInstead) == "boolean" then Info.ReturnInstanceInstead else false

        if Info.SpecialType == "Player" then
            Info.ExcludeLocalPlayer = if typeof(Info.ExcludeLocalPlayer) == "boolean" then Info.ExcludeLocalPlayer else false

            Info.Values = GetPlayers(Info.ExcludeLocalPlayer, Info.ReturnInstanceInstead)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams(Info.ReturnInstanceInstead)
            Info.AllowNull = true
        end

        assert(Info.Values, string.format("AddDropdown (IDX: %s): Missing dropdown value list.", tostring(Idx)))
        if not (Info.AllowNull or Info.Default) then
            Info.Default = 1
            warn(string.format("AddDropdown (IDX: %s): Missing default value, selected the first index instead. Pass `AllowNull` as true if this was intentional.", tostring(Idx)))
        end

        Info.Searchable = if typeof(Info.Searchable) == "boolean" then Info.Searchable else false
        Info.FormatDisplayValue = if typeof(Info.FormatDisplayValue) == "function" then Info.FormatDisplayValue else nil
        Info.FormatListValue = if typeof(Info.FormatListValue) == "function" then Info.FormatListValue else nil

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            DisabledValues = Info.DisabledValues or {};

            Multi = Info.Multi;
            Type = "Dropdown";
            SpecialType = Info.SpecialType; -- can be either "Player" or "Team"
            Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
            Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
            Callback = Info.Callback or function(Value) end;
            Changed = Info.Changed or function(Value) end;

            OriginalText = Info.Text; Text = Info.Text;
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer;
            ReturnInstanceInstead = Info.ReturnInstanceInstead;
        }

        local Tooltip

        local ParentObj = self
        local ToggleLabel = self.TextLabel
        local Container = self.Container

        local RelativeOffset = 0

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA("UIListLayout") then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset
            end
        end

        local DropdownOuter = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            Size = UDim2.new(0, 60, 0, 18);
            Visible = Dropdown.Visible;
            ZIndex = 6;
            Parent = ToggleLabel;
        })

        _L:AddToRegistry(DropdownOuter, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local DropdownInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        })

        _L:AddToRegistry(DropdownInner, {
            BackgroundColor3 = "BackgroundColor";
        })

        -- 右端の区切り線
        local DropdownDivider = _L:Create("Frame", {
            BackgroundColor3 = _L.OutlineColor;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(1, 0);
            Position = UDim2.new(1, -22, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 7;
            Parent = DropdownInner;
        })
        _L:AddToRegistry(DropdownDivider, { BackgroundColor3 = "OutlineColor" })

        local DropdownInnerSearch
        if Info.Searchable then
            DropdownInnerSearch = _L:Create("TextBox", {
                BackgroundTransparency = 1;
                Visible = false;

                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(0.9, -5, 1, 0);

                Font = _L.Font;
                PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
                PlaceholderText = "Search...";

                Text = "";
                TextColor3 = _L.FontColor;
                TextSize = 14;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Left;

                ClearTextOnFocus = false;

                ZIndex = 7;
                Parent = DropdownOuter;
            })

            _L:ApplyTextStroke(DropdownInnerSearch)

            _L:AddToRegistry(DropdownInnerSearch, {
                TextColor3 = "FontColor";
            })
        end

        -- 右端の「+」ラベル
        local DropdownArrow = _L:CreateLabel({
            AnchorPoint = Vector2.new(1, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -1, 0.5, 0);
            Size = UDim2.new(0, 20, 1, 0);
            TextSize = 16;
            Text = "+";
            TextXAlignment = Enum.TextXAlignment.Center;
            ZIndex = 8;
            Parent = DropdownInner;
        })

        local ItemList = _L:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -27, 1, 0);
            TextSize = 14;
            Text = "--";
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = false;
            TextTruncate = Enum.TextTruncate.AtEnd;
            RichText = true;
            ZIndex = 7;
            Parent = DropdownInner;
        })

        _L:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = "AccentColor" },
            { BorderColor3 = "OutlineColor" },
            function()
                return not Dropdown.Disabled
            end
        )

        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            Tooltip = _L:AddToolTip(Info.Tooltip, Info.DisabledTooltip, DropdownOuter)
            Tooltip.Disabled = Dropdown.Disabled
        end

        local MAX_DROPDOWN_ITEMS = if typeof(Info.MaxVisibleDropdownItems) == "number" then math.clamp(Info.MaxVisibleDropdownItems, 4, 16) else 8

        local ListOuter = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        })
        _L:AddToRegistry(ListOuter, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local OpenedXSizeForList = 0

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1)
        end

        local function RecalculateListSize(YSize)
            local Y = YSize or math.clamp(GetTableSize(Dropdown.Values) * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
            ListOuter.Size = UDim2.fromOffset(ListOuter.Visible and OpenedXSizeForList or DropdownOuter.AbsoluteSize.X + 0.5, Y)
        end

        RecalculateListPosition()
        RecalculateListSize()

        DropdownOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(RecalculateListPosition)
        DropdownOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(RecalculateListSize)

        local ListInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        })

        _L:AddToRegistry(ListInner, {
            BackgroundColor3 = "BackgroundColor";
        })

        local Scrolling = _L:Create("ScrollingFrame", {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;

            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = _L.AccentColor,
        })

        _L:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = "AccentColor"
        })

        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        })

        function Dropdown:UpdateColors()
            ItemList.TextColor3 = Dropdown.Disabled and _L.DisabledAccentColor or _L.FontColor
            DropdownArrow.TextColor3 = Dropdown.Disabled and _L.DisabledAccentColor or _L.FontColor
        end

        function Dropdown:GenerateDisplayText(SelectedValue)
            local Str = ""

            if Info.Multi and typeof(SelectedValue) == "table" then
                for Idx, Value in next, Dropdown.Values do
                    if SelectedValue[Value] then
                        Str = Str .. tostring(Info.FormatDisplayValue and Info.FormatDisplayValue(Value) or Value) .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
                Str = (Str == "" and "--" or Str)
            else
                if not SelectedValue then
                    return "--"
                end

                Str = tostring(Info.FormatDisplayValue and Info.FormatDisplayValue(SelectedValue) or SelectedValue)
            end

            return Str
        end

        function Dropdown:Display()
            local Str = Dropdown:GenerateDisplayText(Dropdown.Value)
            ItemList.Text = Str

            local X = ListOuter.Visible and OpenedXSizeForList or _L:GetTextBounds(ItemList.Text, _L.Font, ItemList.TextSize, Vector2.new(ToggleLabel.AbsoluteSize.X, math.huge)) + 26
            DropdownOuter.Size = UDim2.new(0, X, 0, 18)
        end

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {}

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value)
                end

                return T
            else
                return Dropdown.Value and 1 or 0
            end
        end

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local Buttons = {}

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA("UIListLayout") then
                    Element:Destroy()
                end
            end

            local Count = 0
            OpenedXSizeForList = DropdownOuter.AbsoluteSize.X + 0.5

            for Idx, Value in next, Values do
                local StringValue = tostring(Info.FormatListValue and Info.FormatListValue(Value) or Value)
                if Info.Searchable and not string.lower(StringValue):match(string.lower(DropdownInnerSearch.Text)) then
                    continue
                end

                local IsDisabled = table.find(DisabledValues, StringValue)
                local Table = {}

                Count = Count + 1

                local Button = _L:Create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = _L.MainColor;
                    BorderColor3 = _L.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20);
                    Text = "";
                    ZIndex = 23;
                    Parent = Scrolling;
                })

                _L:AddToRegistry(Button, {
                    BackgroundColor3 = "MainColor";
                    BorderColor3 = "OutlineColor";
                })

                local ButtonLabel = _L:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 14;
                    Text = Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    RichText = true;
                    ZIndex = 25;
                    Parent = Button;
                })

                _L:OnHighlight(Button, Button,
                    { BorderColor3 = IsDisabled and "DisabledAccentColor" or "AccentColor", ZIndex = 24 },
                    { BorderColor3 = "OutlineColor", ZIndex = 23 }
                )

                local Selected

                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value]
                    else
                        Selected = Dropdown.Value == Value
                    end

                    ButtonLabel.TextColor3 = Selected and _L.AccentColor or (IsDisabled and _L.DisabledAccentColor or _L.FontColor)
                    _L.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and "AccentColor" or (IsDisabled and "DisabledAccentColor" or "FontColor")
                end

                if not IsDisabled then
                    Button.MouseButton1Click:Connect(function(Input)
                        local Try = not Selected

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try

                                if Selected then
                                    Dropdown.Value[Value] = true
                                else
                                    Dropdown.Value[Value] = nil
                                end
                            else
                                Selected = Try

                                if Selected then
                                    Dropdown.Value = Value
                                else
                                    Dropdown.Value = nil
                                end

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton()
                                end
                            end

                            Table:UpdateButton()
                            Dropdown:Display()
                            
                            _L:UpdateDependencyBoxes()
                            _L:UpdateDependencyGroupboxes()
                            _L:SafeCallback(Dropdown.Callback, Dropdown.Value)
                            _L:SafeCallback(Dropdown.Changed, Dropdown.Value)

                            _L:AttemptSave()
                        end
                    end)
                end

                Table:UpdateButton()
                Dropdown:Display()

                local Str = Dropdown:GenerateDisplayText(Value)
                local X = _L:GetTextBounds(Str, _L.Font, ItemList.TextSize, Vector2.new(ToggleLabel.AbsoluteSize.X, math.huge)) + 26
                if X > OpenedXSizeForList then
                    OpenedXSizeForList = X
                end

                Buttons[Button] = Table
            end
            
            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * (20 * DPIScale)) + 1)

            -- Workaround for silly roblox bug - not sure why it happens but sometimes the dropdown list will be empty
            -- ... and for some reason refreshing the Visible property fixes the issue??????? thanks roblox!
            Scrolling.Visible = false
            Scrolling.Visible = true

            local Y = math.clamp(Count * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
            RecalculateListSize(Y)
        end

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValues(NewValues)
            if typeof(NewValues) == "table" then
                for _, val in pairs(NewValues) do
                    table.insert(Dropdown.Values, val)
                end
            elseif typeof(NewValues) == "string" then
                table.insert(Dropdown.Values, NewValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(NewValues)
            if NewValues then
                Dropdown.DisabledValues = NewValues
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in pairs(DisabledValues) do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetVisible(Visibility)
            Dropdown.Visible = Visibility

            DropdownOuter.Visible = Dropdown.Visible
            if not Dropdown.Visible then 
                Dropdown:CloseDropdown()
            end
        end

        function Dropdown:SetDisabled(Disabled)
            Dropdown.Disabled = Disabled

            if Tooltip then
                Tooltip.Disabled = Disabled
            end

            if Disabled then
                Dropdown:CloseDropdown()
            end

            Dropdown:Display()
            Dropdown:UpdateColors()
        end

        function Dropdown:OpenDropdown()
            if Dropdown.Disabled then
                return
            end

            if _L.IsMobile then
                _L.CanDrag = false
            end

            if Info.Searchable then
                ItemList.Visible = false
                DropdownInnerSearch.Text = ""
                DropdownInnerSearch.Visible = true
            end
            
            ListOuter.Visible = true
            _L.OpenedFrames[ListOuter] = true
            DropdownArrow.Text = "-"

            Dropdown:Display()
            RecalculateListSize()
        end

        function Dropdown:CloseDropdown()
            if _L.IsMobile then         
                _L.CanDrag = true
            end

            if Info.Searchable then
                DropdownInnerSearch.Text = ""
                DropdownInnerSearch.Visible = false
                ItemList.Visible = true
            end
        
            ListOuter.Visible = false
            _L.OpenedFrames[ListOuter] = nil
            DropdownArrow.Text = "+"

            Dropdown:Display()
            RecalculateListSize()
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func

            -- if Dropdown.Disabled then
            --     return;
            -- end;

            -- _L:SafeCallback(Func, Dropdown.Value);
        end

        function Dropdown:SetValue(Value)
            if Dropdown.Multi then
                local Table = {}

                for Val, Active in pairs(Value or {}) do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and table.find(Dropdown.Values, Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if table.find(Dropdown.Values, Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:BuildDropdownList()

            if not Dropdown.Disabled then
                _L:SafeCallback(Dropdown.Callback, Dropdown.Value)
                _L:SafeCallback(Dropdown.Changed, Dropdown.Value)
            end
        end

        function Dropdown:SetText(...)
            -- This is an Compat dropdown for Toggles, it doesn't have an TextLabel --
            return
        end

        DropdownOuter.InputBegan:Connect(function(Input)
            if Dropdown.Disabled then
                return
            end

            if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown()
                else
                    Dropdown:OpenDropdown()
                end
            end
        end)

        if Info.Searchable then
            DropdownInnerSearch:GetPropertyChangedSignal("Text"):Connect(function()
                Dropdown:BuildDropdownList()
            end)
        end

        UIS.InputBegan:Connect(function(Input)
            if Dropdown.Disabled then
                return
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - (20 * DPIScale) - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown()
                end
            end
        end)

        Dropdown:BuildDropdownList()
        Dropdown:Display()

        local Defaults = {}

        if typeof(Info.Default) == "string" then
            local DefaultIdx = table.find(Dropdown.Values, Info.Default)
            if DefaultIdx then
                table.insert(Defaults, DefaultIdx)
            end

        elseif typeof(Info.Default) == "table" then
            for _, Value in next, Info.Default do
                local DefaultIdx = table.find(Dropdown.Values, Value)
                if DefaultIdx then
                    table.insert(Defaults, DefaultIdx)
                end
            end

        elseif typeof(Info.Default) == "number" and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index]
                end

                if (not Info.Multi) then break end
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()
        end

        task.delay(0.1, Dropdown.UpdateColors, Dropdown)

        Dropdown.DisplayFrame = DropdownOuter
        if ParentObj.Addons then
            table.insert(ParentObj.Addons, Dropdown)
        end

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        return self
    end

    BaseAddons.__index = BaseAddonsFuncs
    BaseAddons.__namecall = function(Table, Key, ...)
        return BaseAddonsFuncs[Key](...)
    end
end

--// Groupbox Addons \\--
local BaseGroupbox = {}
do
    local BaseGroupboxFuncs = {}

    function BaseGroupboxFuncs:AddBlank(Size, Visible)
        local Groupbox = self
        local Container = Groupbox.Container

        return _L:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            Visible = if typeof(Visible) == "boolean" then Visible else true;
            ZIndex = 1;
            Parent = Container;
        })
    end

    function BaseGroupboxFuncs:AddDivider(...)
        local Params = select(1, ...)
        local Text
        local MarginTop = 2
        local MarginBottom = 9

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 2
            MarginBottom = Params.MarginBottom or Params.Margin or 9
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = self.Container

        Groupbox:AddBlank(MarginTop)

        local DividerOuter
        if Text then
            DividerOuter = _L:Create("Frame", {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, -4, 0, 14);
                ZIndex = 5;
                Parent = Container;
            })

            _L:CreateLabel({
                AutomaticSize = Enum.AutomaticSize.X;
                BackgroundTransparency = 1;
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.fromScale(1, 0);
                Text = Text;
                TextSize = 14;
                TextTransparency = 0.5;
                TextXAlignment = Enum.TextXAlignment.Center;
                ZIndex = 6;
                Parent = DividerOuter;
                RichText = true;
            })

            local X = select(1, _L:GetTextBounds(Text, _L.Font, 14 * DPIScale))
            local SizeX = math.floor(X / 2) + (10 * DPIScale)

            local LeftOuter = _L:Create("Frame", {
                AnchorPoint = Vector2.new(0, 0.5);
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromScale(0, 0.5);
                Size = UDim2.new(0.5, -SizeX, 0, 5);
                ZIndex = 5;
                Parent = DividerOuter;
            })
            local LeftInner = _L:Create("Frame", {
                BackgroundColor3 = _L.MainColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = LeftOuter;
            })

            local RightOuter = _L:Create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5);
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromScale(1, 0.5);
                Size = UDim2.new(0.5, -SizeX, 0, 5);
                ZIndex = 5;
                Parent = DividerOuter;
            })
            local RightInner = _L:Create("Frame", {
                BackgroundColor3 = _L.MainColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = RightOuter;
            })

            _L:AddToRegistry(LeftOuter, { BorderColor3 = "Black"; })
            _L:AddToRegistry(LeftInner, { BackgroundColor3 = "MainColor"; BorderColor3 = "OutlineColor"; })
            _L:AddToRegistry(RightOuter, { BorderColor3 = "Black"; })
            _L:AddToRegistry(RightInner, { BackgroundColor3 = "MainColor"; BorderColor3 = "OutlineColor"; })
        else
            DividerOuter = _L:Create("Frame", {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 5);
                ZIndex = 5;
                Parent = Container;
            })

            local DividerInner = _L:Create("Frame", {
                BackgroundColor3 = _L.MainColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = DividerOuter;
            })

            _L:AddToRegistry(DividerOuter, {
                BorderColor3 = "Black";
            })

            _L:AddToRegistry(DividerInner, {
                BackgroundColor3 = "MainColor";
                BorderColor3 = "OutlineColor";
            })
        end

        Groupbox:AddBlank(MarginBottom)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, {
            Holder = DividerOuter,
            Type = "Divider",
        })
    end

    function BaseGroupboxFuncs:AddLabel(...)
        local Data = {}

        if select(2, ...) ~= nil and typeof(select(2, ...)) == "table" then
            if select(1, ...) ~= nil then
                assert(typeof(select(1, ...)) == "string", "Expected string for Idx, got " .. typeof(select(1, ...)))
            end
            
            local Params = select(2, ...)

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Idx = select(1, ...)
        else
            Data.Text = select(1, ...) or ""
            Data.DoesWrap = select(2, ...) or false
            Data.Idx = select(3, ...) or nil
        end

        Data.OriginalText = Data.Text
        
        local Label = {
            Type = "Label"
        }

        -- local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container

        local TextLabel = _L:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Data.Text;
            TextWrapped = Data.DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
            RichText = true;
        })

        if Data.DoesWrap then
            local Y = select(2, _L:GetTextBounds(Data.Text, _L.Font, 14 * DPIScale, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            _L:Create("UIListLayout", {
                Padding = UDim.new(0, 4 * DPIScale);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            })
        end

        Label.TextLabel = TextLabel
        Label.Container = Container

        function Label:SetText(Text)
            TextLabel.Text = Text

            if Data.DoesWrap then
                local Y = select(2, _L:GetTextBounds(Text, _L.Font, 14 * DPIScale, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize()
        end

        if (not Data.DoesWrap) then
            setmetatable(Label, BaseAddons)
        end

        -- Blank = 
        Groupbox:AddBlank(5)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, Label)
        
        if Data.Idx then
            -- Options[Data.Idx] = Label;
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        return Label
    end

    function BaseGroupboxFuncs:AddParagraph(Idx, Info)
        local Paragraph = {
            Type = "Paragraph",
            Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        }

        local Groupbox = self
        local Container = Groupbox.Container

        local ParagraphFrame = _L:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            Visible = Paragraph.Visible;
            ZIndex = 5;
            Parent = Container;
        })

        local ListLayout = _L:Create("UIListLayout", {
            Padding = UDim.new(0, 2);
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ParagraphFrame;
        })

        local TitleLabel = _L:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 14;
            Text = Info.Title or "Title";
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            LayoutOrder = 1;
            Parent = ParagraphFrame;
            RichText = true;
        })

        local Divider = _L:Create("Frame", {
            BackgroundColor3 = _L.OutlineColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 5;
            LayoutOrder = 2;
            Parent = ParagraphFrame;
        })
        _L:AddToRegistry(Divider, { BackgroundColor3 = "OutlineColor" })

        local ContentLabel = _L:CreateLabel({
            Size = UDim2.new(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 14;
            Text = Info.Content or "Content";
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 5;
            LayoutOrder = 3;
            Parent = ParagraphFrame;
            RichText = true;
        })

        function Paragraph:SetTitle(Text)
            TitleLabel.Text = Text
            Groupbox:Resize()
        end

        function Paragraph:SetContent(Text)
            ContentLabel.Text = Text
            Groupbox:Resize()
        end

        function Paragraph:SetVisible(Visibility)
            Paragraph.Visible = Visibility
            ParagraphFrame.Visible = Visibility
            Groupbox:Resize()
        end

        Groupbox:AddBlank(5)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, Paragraph)
        if Idx then Options[Idx] = Paragraph end

        return Paragraph
    end
    
    function BaseGroupboxFuncs:AddButton(...)
        local Button = typeof(select(1, ...)) == "table" and select(1, ...) or {
            Text = select(1, ...),
            Func = select(2, ...)
        }
        Button.OriginalText = Button.Text
        Button.Func = Button.Func or Button.Callback
        assert(typeof(Button.Func) == "function", "AddButton: `Func` callback is missing.")

        local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container
        local IsVisible = if typeof(Button.Visible) == "boolean" then Button.Visible else true

        local function CreateBaseButton(Button)
            local Outer = _L:Create("Frame", {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                Visible = IsVisible;
                ZIndex = 5;
            })

            local Inner = _L:Create("Frame", {
                BackgroundColor3 = _L.MainColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            })

            local Label = _L:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Inner;
                RichText = true;
            })

            _L:Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            })

            _L:AddToRegistry(Outer, {
                BorderColor3 = "Black";
            })

            _L:AddToRegistry(Inner, {
                BackgroundColor3 = "MainColor";
                BorderColor3 = "OutlineColor";
            })

            _L:OnHighlight(Outer, Outer,
                { BorderColor3 = "AccentColor" },
                { BorderColor3 = "Black" }
            )

            return Outer, Inner, Label
        end

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new("BindableEvent")
                local connection = event:Once(function(...)

                    if typeof(validator) == "function" and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)
                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)
                return bindable.Event:Wait()
            end

            local function ValidateClick(Input)
                if _L:MouseIsOverOpenedFrame(Input) then
                    return false
                end

                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    return true
                elseif Input.UserInputType == Enum.UserInputType.Touch then
                    return true
                else
                    return false
                end
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if Button.Disabled then
                    return
                end

                if not ValidateClick(Input) then return end
                if Button.Locked then return end

                if Button.DoubleClick then
                    _L:RemoveFromRegistry(Button.Label)
                    _L:AddToRegistry(Button.Label, { TextColor3 = "AccentColor" })

                    Button.Label.TextColor3 = _L.AccentColor
                    Button.Label.Text = "Are you sure?"
                    Button.Locked = true

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                    _L:RemoveFromRegistry(Button.Label)
                    _L:AddToRegistry(Button.Label, { TextColor3 = "FontColor" })

                    Button.Label.TextColor3 = _L.FontColor
                    Button.Label.Text = Button.Text
                    task.defer(rawset, Button, "Locked", false)

                    if clicked then
                        _L:SafeCallback(Button.Func)
                    end

                    return
                end

                _L:SafeCallback(Button.Func)
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button:AddButton(...)
            local SubButton = typeof(select(1, ...)) == "table" and select(1, ...) or {
                Text = select(1, ...),
                Func = select(2, ...)
            }
            SubButton.OriginalText = SubButton.Text
            SubButton.Func = SubButton.Func or SubButton.Callback
            assert(typeof(SubButton.Func) == "function", "AddButton: `Func` callback is missing.")

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20 * DPIScale)

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.new(1, -3, 0, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer

            function SubButton:UpdateColors()
                SubButton.Label.TextColor3 = SubButton.Disabled and _L.DisabledAccentColor or Color3.new(1, 1, 1)
            end

            function SubButton:AddToolTip(tooltip, disabledTooltip)
                if typeof(tooltip) == "string" or typeof(disabledTooltip) == "string" then
                    if SubButton.TooltipTable then
                        SubButton.TooltipTable:Destroy()
                    end
                
                    SubButton.TooltipTable = _L:AddToolTip(tooltip, disabledTooltip, self.Outer)
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                return SubButton
            end

            function SubButton:SetDisabled(Disabled)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = Disabled
                end

                SubButton:UpdateColors()
            end

            function SubButton:SetText(Text)
                if typeof(Text) == "string" then
                    SubButton.Text = Text
                    SubButton.Label.Text = SubButton.Text
                end
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable = SubButton:AddToolTip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Outer)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            task.delay(0.1, SubButton.UpdateColors, SubButton)
            InitEvents(SubButton)

            table.insert(Buttons, SubButton)
            return SubButton
        end

        function Button:UpdateColors()
            Button.Label.TextColor3 = Button.Disabled and _L.DisabledAccentColor or Color3.new(1, 1, 1)
        end

        function Button:AddToolTip(tooltip, disabledTooltip)
            if typeof(tooltip) == "string" or typeof(disabledTooltip) == "string" then
                if Button.TooltipTable then
                    Button.TooltipTable:Destroy()
                end

                Button.TooltipTable = _L:AddToolTip(tooltip, disabledTooltip, self.Outer)
                Button.TooltipTable.Disabled = Button.Disabled
            end

            return Button
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Button:AddToolTip(Button.Tooltip, Button.DisabledTooltip, Button.Outer)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        function Button:SetVisible(Visibility)
            IsVisible = Visibility

            Button.Outer.Visible = IsVisible
            if Blank then Blank.Visible = IsVisible end

            Groupbox:Resize()
        end

        function Button:SetText(Text)
            if typeof(Text) == "string" then
                Button.Text = Text
                Button.Label.Text = Button.Text
            end
        end

        function Button:SetDisabled(Disabled)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Disabled
            end

            Button:UpdateColors()
        end

        task.delay(0.1, Button.UpdateColors, Button)
        Blank = Groupbox:AddBlank(5, IsVisible)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, Button)
        table.insert(Buttons, Button)

        return Button
    end

    function BaseGroupboxFuncs:AddInput(Idx, Info)
        assert(Info.Text, string.format("AddInput (IDX: %s): Missing `Text` string.", tostring(Idx)))

        Info.ClearTextOnFocus = if typeof(Info.ClearTextOnFocus) == "boolean" then Info.ClearTextOnFocus else true

        local Textbox = {
            Value = Info.Default or "";
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
            Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
            AllowEmpty = if typeof(Info.AllowEmpty) == "boolean" then Info.AllowEmpty else true;
            EmptyReset = if typeof(Info.EmptyReset) == "string" then Info.EmptyReset else "---";
            Type = "Input";

            Callback = Info.Callback or function(Value) end;
        }

        local Groupbox = self
        local Container = Groupbox.Container
        local Blank

        local InputLabel = _L:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        })

        Groupbox:AddBlank(1)

        local TextBoxOuter = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        })

        local TextBoxInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        })

        _L:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        _L:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = "AccentColor" },
            { BorderColor3 = "Black" }
        )

        local TooltipTable
        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            TooltipTable = _L:AddToolTip(Info.Tooltip, Info.DisabledTooltip, TextBoxOuter)
            TooltipTable.Disabled = Textbox.Disabled
        end

        _L:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        })

        local TextBoxContainer = _L:Create("Frame", {
            BackgroundTransparency = 1;
            ClipsDescendants = true;

            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);

            ZIndex = 7;
            Parent = TextBoxInner;
        })

        local Box = _L:Create("TextBox", {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),

            Font = _L.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder or "";

            Text = Info.Default or (if Textbox.AllowEmpty == false then Textbox.EmptyReset else "---");
            TextColor3 = _L.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;

            TextEditable = not Textbox.Disabled;
            ClearTextOnFocus = not Textbox.Disabled and Info.ClearTextOnFocus;

            ZIndex = 7;
            Parent = TextBoxContainer;
        })

        _L:ApplyTextStroke(Box)

        _L:AddToRegistry(Box, {
            TextColor3 = "FontColor";
        })

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func

            -- if Textbox.Disabled then
            --     return;
            -- end;

            -- _L:SafeCallback(Func, Textbox.Value);
        end

        function Textbox:UpdateColors()
            Box.TextColor3 = Textbox.Disabled and _L.DisabledAccentColor or _L.FontColor

            _L.RegistryMap[Box].Properties.TextColor3 = Textbox.Disabled and "DisabledAccentColor" or "FontColor"
        end

        function Textbox:Display()
            TextBoxOuter.Visible = Textbox.Visible
            InputLabel.Visible = Textbox.Visible
            if Blank then Blank.Visible = Textbox.Visible end

            Groupbox:Resize()
        end

        function Textbox:SetValue(Text)
            if not Textbox.AllowEmpty and Trim(Text) == "" then
                Text = Textbox.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Textbox.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text
            Box.Text = Text

            if not Textbox.Disabled then
                _L:SafeCallback(Textbox.Callback, Textbox.Value)
                _L:SafeCallback(Textbox.Changed, Textbox.Value)
            end
        end

        function Textbox:SetVisible(Visibility)
            Textbox.Visible = Visibility

            Textbox:Display()
        end

        function Textbox:SetDisabled(Disabled)
            Textbox.Disabled = Disabled

            Box.TextEditable = not Disabled
            Box.ClearTextOnFocus = not Disabled and Info.ClearTextOnFocus

            if TooltipTable then
                TooltipTable.Disabled = Disabled
            end

            Textbox:UpdateColors()
        end

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then return end

                Textbox:SetValue(Box.Text)
                _L:AttemptSave()
            end)
        else
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                Textbox:SetValue(Box.Text)
                _L:AttemptSave()
            end)
        end

        -- https://devforum.roblox.com/t/how-to-make-textboxes-follow-current-cursor-position/1368429/6
        -- thank you nicemike40 :)

        local function Update()
            local PADDING = 2
            local reveal = TextBoxContainer.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                -- we aren't focused, or we fit so be normal
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                -- we are focused and don't fit, so adjust position
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    -- calculate pixel width of text from start to cursor
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TS:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                    -- check if we're inside the box with the cursor
                    local currentCursorPos = Box.Position.X.Offset + width

                    -- adjust if necessary
                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal("Text"):Connect(Update)
        Box:GetPropertyChangedSignal("CursorPosition"):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        Blank = Groupbox:AddBlank(5, Textbox.Visible)
        task.delay(0.1, Textbox.UpdateColors, Textbox)
        Textbox:Display()
        Groupbox:Resize()

        Textbox.Default = Textbox.Value

        table.insert(Groupbox.Elements, Textbox)
        Options[Idx] = Textbox

        return Textbox
    end

    function BaseGroupboxFuncs:AddToggle(Idx, Info)
        assert(Info.Text, string.format("AddInput (IDX: %s): Missing `Text` string.", tostring(Idx)))

        local Toggle = {
            Value = Info.Default or false;
            Type = "Toggle";
            Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
            Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
            Risky = if typeof(Info.Risky) == "boolean" then Info.Risky else false;
            OriginalText = Info.Text; Text = Info.Text;

            Callback = Info.Callback or function(Value) end;
            Addons = {};
        }

        local Blank
        local Tooltip
        local Groupbox = self
        local Container = Groupbox.Container

        local ToggleContainer = _L:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 13);
            Visible = Toggle.Visible;
            ZIndex = 5;
            Parent = Container;
        })

        local ToggleOuter = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13, 0, 13);
            Visible = Toggle.Visible;
            ZIndex = 5;
            Parent = ToggleContainer;
        })

        _L:AddToRegistry(ToggleOuter, {
            BorderColor3 = "Black";
        })

        local ToggleInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        })

        _L:AddToRegistry(ToggleInner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        local ToggleLabel = _L:CreateLabel({
            Size = UDim2.new(1, -19, 0, 11); -- size of toggle box (13) + size offset of previous layout (6)
            Position = UDim2.new(0, 19, 0, 0);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleContainer;
            RichText = true;
        })

        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        })

        local ToggleRegion = _L:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        })

        _L:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = "AccentColor" },
            { BorderColor3 = "Black" },
            function()
                if Toggle.Disabled then
                    return false
                end

                for _, Addon in next, Toggle.Addons do
                    if _L:MouseIsOverFrame(Addon.DisplayFrame) then return false end
                end
                return true
            end
        )

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            Tooltip = _L:AddToolTip(Info.Tooltip, Info.DisabledTooltip, ToggleRegion)
            Tooltip.Disabled = Toggle.Disabled
        end

        function Toggle:Display()
            if Toggle.Disabled then
                ToggleLabel.TextColor3 = _L.DisabledTextColor

                ToggleInner.BackgroundColor3 = Toggle.Value and _L.DisabledAccentColor or _L.MainColor
                ToggleInner.BorderColor3 = _L.DisabledOutlineColor

                _L.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and "DisabledAccentColor" or "MainColor"
                _L.RegistryMap[ToggleInner].Properties.BorderColor3 = "DisabledOutlineColor"
                _L.RegistryMap[ToggleLabel].Properties.TextColor3 = "DisabledTextColor"

                return
            end

            ToggleLabel.TextColor3 = Toggle.Risky and _L.RiskColor or Color3.new(1, 1, 1)

            ToggleInner.BackgroundColor3 = Toggle.Value and _L.AccentColor or _L.MainColor
            ToggleInner.BorderColor3 = Toggle.Value and _L.AccentColorDark or _L.OutlineColor

            _L.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            _L.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and "AccentColorDark" or "OutlineColor"

            _L.RegistryMap[ToggleLabel].Properties.TextColor3 = Toggle.Risky and "RiskColor" or nil
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func

            -- if Toggle.Disabled then
            --     return;
            -- end;

            -- _L:SafeCallback(Func, Toggle.Value);
        end

        function Toggle:SetValue(Bool)
            if Toggle.Disabled then
                return
            end

            Bool = (not not Bool)

            Toggle.Value = Bool
            Toggle:Display()

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                _L:SafeCallback(Toggle.Callback, Toggle.Value)
                _L:SafeCallback(Toggle.Changed, Toggle.Value)
            end

            _L:UpdateDependencyBoxes()
            _L:UpdateDependencyGroupboxes()
        end

        function Toggle:SetVisible(Visibility)
            Toggle.Visible = Visibility

            ToggleOuter.Visible = Toggle.Visible
            if Blank then Blank.Visible = Toggle.Visible end

            Groupbox:Resize()
        end

        function Toggle:SetDisabled(Disabled)
            Toggle.Disabled = Disabled

            if Tooltip then
                Tooltip.Disabled = Disabled
            end

            Toggle:Display()
        end

        function Toggle:SetText(Text)
            if typeof(Text) == "string" then
                Toggle.Text = Text
                ToggleLabel.Text = Toggle.Text
            end
        end

        ToggleRegion.InputBegan:Connect(function(Input)
            if Toggle.Disabled then
                return
            end

            if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                for _, Addon in next, Toggle.Addons do
                    if _L:MouseIsOverFrame(Addon.DisplayFrame) then return end
                end

                Toggle:SetValue(not Toggle.Value) -- Why was it not like this from the start?
                _L:AttemptSave()
            end
        end)

        if Toggle.Risky == true then
            _L:RemoveFromRegistry(ToggleLabel)

            ToggleLabel.TextColor3 = _L.RiskColor
            _L:AddToRegistry(ToggleLabel, { TextColor3 = "RiskColor" })
        end

        Toggle:Display()
        Blank = Groupbox:AddBlank(Info.BlankSize or 5 + 2, Toggle.Visible)
        Groupbox:Resize()

        Toggle.TextLabel = ToggleLabel
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Default = Toggle.Value

        table.insert(Groupbox.Elements, Toggle)
        Toggles[Idx] = Toggle

        _L:UpdateDependencyBoxes()
        _L:UpdateDependencyGroupboxes()

        return Toggle
    end

    function BaseGroupboxFuncs:AddSlider(Idx, Info)
        assert(Info.Default,    string.format("AddSlider (IDX: %s): Missing default value.", tostring(Idx)))
        assert(Info.Text,       string.format("AddSlider (IDX: %s): Missing slider text.", tostring(Idx)))
        assert(Info.Min,        string.format("AddSlider (IDX: %s): Missing minimum value.", tostring(Idx)))
        assert(Info.Max,        string.format("AddSlider (IDX: %s): Missing maximum value.", tostring(Idx)))
        assert(Info.Rounding,   string.format("AddSlider (IDX: %s): Missing rounding value.", tostring(Idx)))

        local Slider = {
            Value = Info.Default;

            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            MaxSize = 232;
            Type = "Slider";
            Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
            Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
            OriginalText = Info.Text; Text = Info.Text;

            Prefix = typeof(Info.Prefix) == "string" and Info.Prefix or "";
            Suffix = typeof(Info.Suffix) == "string" and Info.Suffix or "";

            Callback = Info.Callback or function(Value) end;
        }

        local Blanks = {}
        local SliderText = nil
        local Groupbox = self
        local Container = Groupbox.Container
        local Tooltip

        if not Info.Compact then
            SliderText = _L:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                Visible = Slider.Visible;
                ZIndex = 5;
                Parent = Container;
                RichText = true;
            })

            table.insert(Blanks, Groupbox:AddBlank(3, Slider.Visible))
        end

        local SliderOuter = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 13);
            Visible = Slider.Visible;
            ZIndex = 5;
            Parent = Container;
        })

        SliderOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            Slider.MaxSize = SliderOuter.AbsoluteSize.X - 2
        end)

        _L:AddToRegistry(SliderOuter, {
            BorderColor3 = "Black";
        })

        local SliderInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        })

        _L:AddToRegistry(SliderInner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        local Fill = _L:Create("Frame", {
            BackgroundColor3 = _L.AccentColor;
            BorderColor3 = _L.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        })

        _L:AddToRegistry(Fill, {
            BackgroundColor3 = "AccentColor";
            BorderColor3 = "AccentColorDark";
        })

        local HideBorderRight = _L:Create("Frame", {
            BackgroundColor3 = _L.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 8;
            Parent = Fill;
        })

        _L:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = "AccentColor";
        })

        local DisplayLabel = _L:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = "Infinite";
            ZIndex = 9;
            Parent = SliderInner;
            RichText = true;
        })

        _L:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = "AccentColor" },
            { BorderColor3 = "Black" },
            function()
                return not Slider.Disabled
            end
        )

        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            Tooltip = _L:AddToolTip(Info.Tooltip, Info.DisabledTooltip, SliderOuter)
            Tooltip.Disabled = Slider.Disabled
        end

        function Slider:UpdateColors()
            if SliderText then
                SliderText.TextColor3 = Slider.Disabled and _L.DisabledAccentColor or Color3.new(1, 1, 1)
            end
            DisplayLabel.TextColor3 = Slider.Disabled and _L.DisabledAccentColor or Color3.new(1, 1, 1)

            HideBorderRight.BackgroundColor3 = Slider.Disabled and _L.DisabledAccentColor or _L.AccentColor

            Fill.BackgroundColor3 = Slider.Disabled and _L.DisabledAccentColor or _L.AccentColor
            Fill.BorderColor3 = Slider.Disabled and _L.DisabledOutlineColor or _L.AccentColorDark

            _L.RegistryMap[HideBorderRight].Properties.BackgroundColor3 = Slider.Disabled and "DisabledAccentColor" or "AccentColor"

            _L.RegistryMap[Fill].Properties.BackgroundColor3 = Slider.Disabled and "DisabledAccentColor" or "AccentColor"
            _L.RegistryMap[Fill].Properties.BorderColor3 = Slider.Disabled and "DisabledOutlineColor" or "AccentColorDark"
        end
        
        function Slider:Display()
            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                local FormattedValue = (Slider.Value == 0 or Slider.Value == -0) and "0" or tostring(Slider.Value)
                if Info.Compact then
                    DisplayLabel.Text = string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, FormattedValue, Slider.Suffix)

                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, FormattedValue, Slider.Suffix)

                else
                    DisplayLabel.Text = string.format("%s%s%s/%s%s%s", 
                        Slider.Prefix, FormattedValue, Slider.Suffix,
                        Slider.Prefix, tostring(Slider.Max), Slider.Suffix)
                end
            end

            local X = _L:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, 1)
            Fill.Size = UDim2.new(X, 0, 1, 0)

            -- I have no idea what this is
            HideBorderRight.Visible = not (X == 1 or X == 0)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func

            -- if Slider.Disabled then
            --     return;
            -- end;
            
            -- _L:SafeCallback(Func, Slider.Value);
        end

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value)
            end

            return tonumber(string.format("%." .. Slider.Rounding .. "f", Value))
        end

        function Slider:GetValueFromXScale(X)
            return Round(_L:MapValue(X, 0, 1, Slider.Min, Slider.Max))
        end
        
        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")
            
            Slider.Value = math.clamp(Slider.Value, Slider.Min, Value)
            Slider.Max = Value
            Slider:Display()
        end
        
        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider.Value = math.clamp(Slider.Value, Value, Slider.Max)
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:SetValue(Str)
            if Slider.Disabled then
                return
            end

            local Num = tonumber(Str)

            if (not Num) then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            if not Slider.Disabled then
                _L:SafeCallback(Slider.Callback, Slider.Value)
                _L:SafeCallback(Slider.Changed, Slider.Value)
            end
        end

        function Slider:SetVisible(Visibility)
            Slider.Visible = Visibility

            if SliderText then SliderText.Visible = Slider.Visible end
            SliderOuter.Visible = Slider.Visible

            for _, Blank in pairs(Blanks) do
                Blank.Visible = Slider.Visible
            end

            Groupbox:Resize()
        end

        function Slider:SetDisabled(Disabled)
            Slider.Disabled = Disabled

            if Tooltip then
                Tooltip.Disabled = Disabled
            end

            Slider:UpdateColors()
        end

        function Slider:SetText(Text)
            if typeof(Text) == "string" then
                Slider.Text = Text

                if SliderText then SliderText.Text = Slider.Text end
                Slider:Display()
            end
        end

        function Slider:SetPrefix(Prefix)
            if typeof(Prefix) == "string" then
                Slider.Prefix = Prefix
                Slider:Display()
            end
        end

        function Slider:SetSuffix(Suffix)
            if typeof(Suffix) == "string" then
                Slider.Suffix = Suffix
                Slider:Display()
            end
        end

        SliderInner.InputBegan:Connect(function(Input)
            if Slider.Disabled then
                return
            end

            if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                if _L.IsMobile then
                    _L.CanDrag = false
                end

                local Sides = {}
                if _L.Window then
                    Sides = _L.Window.Tabs[_L.ActiveTab]:GetSides()
                end

                for _, Side in pairs(Sides) do
                    if typeof(Side) == "Instance" then
                        if Side:IsA("ScrollingFrame") then
                            Side.ScrollingEnabled = false
                        end
                    end
                end

                local mPos = Mouse.X
                local gPos = Fill.AbsoluteSize.X
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos)

                while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local nMPos = Mouse.X
                    local nXOffset = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize) -- what in tarnation are these variable names
                    local nXScale = _L:MapValue(nXOffset, 0, Slider.MaxSize, 0, 1)

                    local nValue = Slider:GetValueFromXScale(nXScale)
                    local OldValue = Slider.Value
                    Slider.Value = nValue

                    Slider:Display()

                    if nValue ~= OldValue then
                        _L:SafeCallback(Slider.Callback, Slider.Value)
                        _L:SafeCallback(Slider.Changed, Slider.Value)
                    end

                    RS.RenderStepped:Wait()
                end

                if _L.IsMobile then
                    _L.CanDrag = true
                end
                
                for _, Side in pairs(Sides) do
                    if typeof(Side) == "Instance" then
                        if Side:IsA("ScrollingFrame") then
                            Side.ScrollingEnabled = true
                        end
                    end
                end

                _L:AttemptSave()
            end
        end)

        task.delay(0.1, Slider.UpdateColors, Slider)
        Slider:Display()
        table.insert(Blanks, Groupbox:AddBlank(Info.BlankSize or 6, Slider.Visible))
        Groupbox:Resize()

        Slider.Default = Slider.Value

        table.insert(Groupbox.Elements, Slider)
        Options[Idx] = Slider

        return Slider
    end

    function BaseGroupboxFuncs:AddDropdown(Idx, Info)
        Info.ReturnInstanceInstead = if typeof(Info.ReturnInstanceInstead) == "boolean" then Info.ReturnInstanceInstead else false

        if Info.SpecialType == "Player" then
            Info.ExcludeLocalPlayer = if typeof(Info.ExcludeLocalPlayer) == "boolean" then Info.ExcludeLocalPlayer else false

            Info.Values = GetPlayers(Info.ExcludeLocalPlayer, Info.ReturnInstanceInstead)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams(Info.ReturnInstanceInstead)
            Info.AllowNull = true
        end

        assert(Info.Values, string.format("AddDropdown (IDX: %s): Missing dropdown value list.", tostring(Idx)))
        if not (Info.AllowNull or Info.Default) then
            Info.Default = 1
            warn(string.format("AddDropdown (IDX: %s): Missing default value, selected the first index instead. Pass `AllowNull` as true if this was intentional.", tostring(Idx)))
        end
        
        Info.Searchable = if typeof(Info.Searchable) == "boolean" then Info.Searchable else false
        Info.FormatDisplayValue = if typeof(Info.FormatDisplayValue) == "function" then Info.FormatDisplayValue else nil
        Info.FormatListValue = if typeof(Info.FormatListValue) == "function" then Info.FormatListValue else nil

        if (not Info.Text) then
            Info.Compact = true
        end

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            DisabledValues = Info.DisabledValues or {};

            Multi = Info.Multi;
            Type = "Dropdown";
            SpecialType = Info.SpecialType; -- can be either "Player" or "Team"
            Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
            Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
            Callback = Info.Callback or function(Value) end;
            Changed = Info.Changed or function(Value) end;

            OriginalText = Info.Text; Text = Info.Text;
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer;
            ReturnInstanceInstead = Info.ReturnInstanceInstead;
        }

        local DropdownLabel
        local Blank
        local CompactBlank
        local Tooltip
        local Groupbox = self
        local Container = Groupbox.Container

        local RelativeOffset = 0

        if not Info.Compact then
            DropdownLabel = _L:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                Visible = Dropdown.Visible;
                ZIndex = 5;
                Parent = Container;
                RichText = true;
            })

            CompactBlank = Groupbox:AddBlank(3, Dropdown.Visible)
        end

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA("UIListLayout") then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset
            end
        end

        local DropdownOuter = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            Size = UDim2.new(1, -4, 0, 20);
            Visible = Dropdown.Visible;
            ZIndex = 5;
            Parent = Container;
        })

        _L:AddToRegistry(DropdownOuter, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local DropdownInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        })

        _L:AddToRegistry(DropdownInner, {
            BackgroundColor3 = "BackgroundColor";
        })

        -- 右端の区切り線 (画像スタイル)
        local DropdownDivider = _L:Create("Frame", {
            BackgroundColor3 = _L.OutlineColor;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(1, 0);
            Position = UDim2.new(1, -22, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 7;
            Parent = DropdownInner;
        })
        _L:AddToRegistry(DropdownDivider, { BackgroundColor3 = "OutlineColor" })

        local DropdownInnerSearch
        if Info.Searchable then
            DropdownInnerSearch = _L:Create("TextBox", {
                BackgroundTransparency = 1;
                Visible = false;

                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(0.9, -5, 1, 0);

                Font = _L.Font;
                PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
                PlaceholderText = "Search...";

                Text = "";
                TextColor3 = _L.FontColor;
                TextSize = 14;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Left;

                ClearTextOnFocus = false;

                ZIndex = 7;
                Parent = DropdownOuter;
            })

            _L:ApplyTextStroke(DropdownInnerSearch)

            _L:AddToRegistry(DropdownInnerSearch, {
                TextColor3 = "FontColor";
            })
        end

        -- 右端の「+」ラベル（画像スタイル）
        local DropdownArrow = _L:CreateLabel({
            AnchorPoint = Vector2.new(1, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -1, 0.5, 0);
            Size = UDim2.new(0, 20, 1, 0);
            TextSize = 16;
            Text = "+";
            TextXAlignment = Enum.TextXAlignment.Center;
            ZIndex = 8;
            Parent = DropdownInner;
        })

        local ItemList = _L:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -27, 1, 0);
            TextSize = 14;
            Text = "--";
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = false;
            TextTruncate = Enum.TextTruncate.AtEnd;
            RichText = true;
            ZIndex = 7;
            Parent = DropdownInner;
        })

        _L:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = "AccentColor" },
            { BorderColor3 = "OutlineColor" },
            function()
                return not Dropdown.Disabled
            end
        )

        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            Tooltip = _L:AddToolTip(Info.Tooltip, Info.DisabledTooltip, DropdownOuter)
            Tooltip.Disabled = Dropdown.Disabled
        end

        local MAX_DROPDOWN_ITEMS = if typeof(Info.MaxVisibleDropdownItems) == "number" then math.clamp(Info.MaxVisibleDropdownItems, 4, 16) else 8

        local ListOuter = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        })
        _L:AddToRegistry(ListOuter, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local ListGlow = UIGlow:Create(ListOuter, {
            Enabled = false,
            Thickness = 15,
            Color = _L.AccentColor,
            Transparency = 0.4
        })

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1)
        end

        local function RecalculateListSize(YSize)
            local Y = YSize or math.clamp(GetTableSize(Dropdown.Values) * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X + 0.5, Y)
        end

        RecalculateListPosition()
        RecalculateListSize()

        DropdownOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(RecalculateListPosition)

        local ListInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        })

        _L:AddToRegistry(ListInner, {
            BackgroundColor3 = "BackgroundColor";
        })

        local Scrolling = _L:Create("ScrollingFrame", {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;

            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = _L.AccentColor,
        })

        _L:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = "AccentColor"
        })

        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        })

        function Dropdown:UpdateColors()
            if DropdownLabel then
                DropdownLabel.TextColor3 = Dropdown.Disabled and _L.DisabledAccentColor or _L.FontColor
            end

            ItemList.TextColor3 = Dropdown.Disabled and _L.DisabledAccentColor or _L.FontColor
            DropdownArrow.TextColor3 = Dropdown.Disabled and _L.DisabledAccentColor or _L.FontColor
        end

        function Dropdown:Display()
            local Values = Dropdown.Values
            local Str = ""

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. tostring(Info.FormatDisplayValue and Info.FormatDisplayValue(Value) or Value) .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
                ItemList.Text = (Str == "" and "--" or Str)
            else
                if not Dropdown.Value then
                    ItemList.Text = "--"
                    return
                end

                ItemList.Text = tostring(Info.FormatDisplayValue and Info.FormatDisplayValue(Dropdown.Value) or Dropdown.Value)
            end
        end

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {}

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value)
                end

                return T
            else
                return Dropdown.Value and 1 or 0
            end
        end

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local Buttons = {}

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA("UIListLayout") then
                    Element:Destroy()
                end
            end

            local Count = 0
            for Idx, Value in next, Values do
                local StringValue = tostring(Info.FormatListValue and Info.FormatListValue(Value) or Value)
                if Info.Searchable and not string.lower(StringValue):match(string.lower(DropdownInnerSearch.Text)) then
                    continue
                end

                local IsDisabled = table.find(DisabledValues, StringValue)
                local Table = {}

                Count = Count + 1

                local Button = _L:Create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = _L.MainColor;
                    BorderColor3 = _L.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20);
                    Text = "";
                    ZIndex = 23;
                    Parent = Scrolling;
                })

                _L:AddToRegistry(Button, {
                    BackgroundColor3 = "MainColor";
                    BorderColor3 = "OutlineColor";
                })

                local ButtonLabel = _L:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 14;
                    Text = Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    RichText = true;
                    ZIndex = 25;
                    Parent = Button;
                })

                _L:OnHighlight(Button, Button,
                    { BorderColor3 = IsDisabled and "DisabledAccentColor" or "AccentColor", ZIndex = 24 },
                    { BorderColor3 = "OutlineColor", ZIndex = 23 }
                )

                local Selected

                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value]
                    else
                        Selected = Dropdown.Value == Value
                    end

                    ButtonLabel.TextColor3 = Selected and _L.AccentColor or (IsDisabled and _L.DisabledAccentColor or _L.FontColor)
                    _L.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and "AccentColor" or (IsDisabled and "DisabledAccentColor" or "FontColor")
                end

                if not IsDisabled then
                    Button.MouseButton1Click:Connect(function(Input)
                        local Try = not Selected

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try

                                if Selected then
                                    Dropdown.Value[Value] = true
                                else
                                    Dropdown.Value[Value] = nil
                                end
                            else
                                Selected = Try

                                if Selected then
                                    Dropdown.Value = Value
                                else
                                    Dropdown.Value = nil
                                end

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton()
                                end
                            end

                            Table:UpdateButton()
                            Dropdown:Display()
                            
                            _L:UpdateDependencyBoxes()
                            _L:UpdateDependencyGroupboxes()
                            _L:SafeCallback(Dropdown.Callback, Dropdown.Value)
                            _L:SafeCallback(Dropdown.Changed, Dropdown.Value)

                            _L:AttemptSave()
                        end
                    end)
                end

                Table:UpdateButton()
                Dropdown:Display()

                Buttons[Button] = Table
            end

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * (20 * DPIScale)) + 1)

            -- Workaround for silly roblox bug - not sure why it happens but sometimes the dropdown list will be empty
            -- ... and for some reason refreshing the Visible property fixes the issue??????? thanks roblox!
            Scrolling.Visible = false
            Scrolling.Visible = true

            local Y = math.clamp(Count * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
            RecalculateListSize(Y)
        end

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValues(NewValues)
            if typeof(NewValues) == "table" then
                for _, val in pairs(NewValues) do
                    table.insert(Dropdown.Values, val)
                end
            elseif typeof(NewValues) == "string" then
                table.insert(Dropdown.Values, NewValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(NewValues)
            if NewValues then
                Dropdown.DisabledValues = NewValues
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in pairs(DisabledValues) do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetVisible(Visibility)
            Dropdown.Visible = Visibility

            DropdownOuter.Visible = Dropdown.Visible
            if DropdownLabel then DropdownLabel.Visible = Dropdown.Visible end

            if Blank then Blank.Visible = Dropdown.Visible end
            if CompactBlank then CompactBlank.Visible = Dropdown.Visible end

            if not Dropdown.Visible then Dropdown:CloseDropdown() end

            Groupbox:Resize()
        end

        function Dropdown:SetDisabled(Disabled)
            Dropdown.Disabled = Disabled

            if Tooltip then
                Tooltip.Disabled = Disabled
            end

            if Disabled then
                Dropdown:CloseDropdown()
            end

            Dropdown:Display()
            Dropdown:UpdateColors()
        end

        function Dropdown:OpenDropdown()
            if Dropdown.Disabled then
                return
            end

            if _L.IsMobile then
                _L.CanDrag = false
            end

            if Info.Searchable then
                ItemList.Visible = false
                DropdownInnerSearch.Text = ""
                DropdownInnerSearch.Visible = true
            end

            ListOuter.Visible = true
            ListGlow:Update({ Enabled = true, Color = _L.AccentColor })
            ListOuter.BorderColor3 = _L.AccentColor
            _L.OpenedFrames[ListOuter] = true
            DropdownArrow.Text = "-"

            RecalculateListSize()
        end

        function Dropdown:CloseDropdown()
            if _L.IsMobile then            
                _L.CanDrag = true
            end

            if Info.Searchable then
                DropdownInnerSearch.Text = ""
                DropdownInnerSearch.Visible = false
                ItemList.Visible = true
            end

            ListOuter.Visible = false
            ListGlow:Update({ Enabled = false })
            ListOuter.BorderColor3 = _L.OutlineColor
            _L.OpenedFrames[ListOuter] = nil
            DropdownArrow.Text = "+"
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func

            -- if Dropdown.Disabled then
            --     return;
            -- end;

            -- _L:SafeCallback(Func, Dropdown.Value);
        end

        function Dropdown:SetValue(Value)
            if Dropdown.Multi then
                local Table = {}

                for Val, Active in pairs(Value or {}) do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and table.find(Dropdown.Values, Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if table.find(Dropdown.Values, Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:BuildDropdownList()

            if not Dropdown.Disabled then
                _L:SafeCallback(Dropdown.Callback, Dropdown.Value)
                _L:SafeCallback(Dropdown.Changed, Dropdown.Value)
            end
        end

        function Dropdown:SetText(Text)
            if typeof(Text) == "string" then
                if Info.Compact then Info.Compact = false end
                Dropdown.Text = Text

                if DropdownLabel then DropdownLabel.Text = Dropdown.Text end
                Dropdown:Display()
            end
        end

        DropdownOuter.InputBegan:Connect(function(Input)
            if Dropdown.Disabled then
                return
            end

            if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown()
                else
                    Dropdown:OpenDropdown()
                end
            end
        end)

        if Info.Searchable then
            DropdownInnerSearch:GetPropertyChangedSignal("Text"):Connect(function()
                Dropdown:BuildDropdownList()
            end)
        end

        UIS.InputBegan:Connect(function(Input)
            if Dropdown.Disabled then
                return
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - (20 * DPIScale) - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown()
                end
            end
        end)

        Dropdown:BuildDropdownList()
        Dropdown:Display()

        local Defaults = {}

        if typeof(Info.Default) == "string" then
            local DefaultIdx = table.find(Dropdown.Values, Info.Default)
            if DefaultIdx then
                table.insert(Defaults, DefaultIdx)
            end
        elseif typeof(Info.Default) == "table" then
            for _, Value in next, Info.Default do
                local DefaultIdx = table.find(Dropdown.Values, Value)
                if DefaultIdx then
                    table.insert(Defaults, DefaultIdx)
                end
            end
        elseif typeof(Info.Default) == "number" and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index]
                end

                if (not Info.Multi) then break end
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()
        end

        task.delay(0.1, Dropdown.UpdateColors, Dropdown)
        Blank = Groupbox:AddBlank(Info.BlankSize or 5, Dropdown.Visible)
        Groupbox:Resize()

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        table.insert(Groupbox.Elements, Dropdown)
        Options[Idx] = Dropdown

        return Dropdown
    end

    function BaseGroupboxFuncs:AddViewport(Idx, Info)
        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local Viewport = {
            Object = if Info.Clone then Info.Object:Clone() else Info.Object,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Height = if typeof(Info.Height) == "number" and Info.Height > 0 then Info.Height else 200,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = Viewport.Object:GetPivot().Position

            Viewport.Camera.CFrame =
                CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor,
            BorderColor3 = _L.OutlineColor,
            BorderSizePixel = 1,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 6,
            Parent = Holder,
        })

        _L:AddToRegistry(Box, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        _L:Create("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = _L:Create("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
            ZIndex = 7
        })

        ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end
            
            for _, Side in pairs(_L.Window.Tabs[_L.ActiveTab]:GetSides()) do
                if typeof(Side) == "Instance" then
                    if Side:IsA("ScrollingFrame") then
                        Side.ScrollingEnabled = false
                    end
                end
            end
        end)

        ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in pairs(_L.Window.Tabs[_L.ActiveTab]:GetSides()) do
                if typeof(Side) == "Instance" then
                    if Side:IsA("ScrollingFrame") then
                        Side.ScrollingEnabled = true
                    end
                end
            end
        end)

        ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = true
                LastMousePos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch and not Pinching then
                Dragging = true
                LastMousePos = input.Position
            end
        end)

        _L:GiveSignal(UIS.InputEnded:Connect(function(input)
            if _L.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = false
            elseif input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        _L:GiveSignal(UIS.InputChanged:Connect(function(input)
            if _L.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = Viewport.Object:GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end)

        _L:GiveSignal(UIS.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
            if _L.Unloaded then
                return
            end

            if not Viewport.Interactive or not _L:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        Viewport.Object.Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            Viewport.Object.Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")
            Viewport.Height = Height

            Holder.Size = UDim2.new(1, -4, 0, Viewport.Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            if Blank then Blank.Visible = Viewport.Visible end

            Groupbox:Resize()
        end

        Viewport:SetHeight(Viewport.Height)

        Blank = Groupbox:AddBlank(10, Viewport.Visible)
        Groupbox:Resize()

        Viewport.Holder = Holder
        Viewport.Container = Container

        table.insert(Groupbox.Elements, Viewport)
        Options[Idx] = Viewport

        _L:UpdateDependencyBoxes()
        _L:UpdateDependencyGroupboxes()

        return Viewport
    end

    function BaseGroupboxFuncs:AddImage(Idx, Info)
        local Image = {
            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = if typeof(Info.Height) == "number" and Info.Height > 0 then Info.Height else 200,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = tonumber(Info.BackgroundTransparency) or 0,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor,
            BorderColor3 = _L.OutlineColor,
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 6,
            Parent = Holder,
        })

        _L:AddToRegistry(Box, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        _L:Create("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = Image.Image,
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ImageRectOffset = Image.RectOffset,
            ImageRectSize = Image.RectSize,
            ScaleType = Image.ScaleType,
            ZIndex = 7,
            Parent = Box,
        }

        local Icon = _L:GetCustomIcon(ImageProperties.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = _L:Create("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")
            Image.Height = Height

            Holder.Size = UDim2.new(1, -4, 0, Image.Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = _L:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            NewImage = Icon.Url
            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            ImageLabel.Image = NewImage
            Image.Image = NewImage
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            if Blank then Blank.Visible = Image.Visible end

            Groupbox:Resize()
        end

        Image:SetHeight(Image.Height)

        Blank = Groupbox:AddBlank(10, Image.Visible)
        Groupbox:Resize()

        Image.Holder = Holder
        Image.Container = Container

        table.insert(Groupbox.Elements, Image)
        Options[Idx] = Image

        _L:UpdateDependencyBoxes()
        _L:UpdateDependencyGroupboxes()

        return Image
    end

    function BaseGroupboxFuncs:AddVideo(Idx, Info)
        Info = _L:Validate(Info, Templates.Video)

        local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor,
            BorderColor3 = _L.OutlineColor,
            BorderSizePixel = 1,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 6,
            Parent = Holder,
        })

        _L:AddToRegistry(Box, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        })

        _L:Create("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = _L:Create("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            ZIndex = 7,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, -4, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            if Blank then Blank.Visible = Video.Visible end

            Groupbox:Resize()
        end

        Video:SetHeight(Video.Height)

        Blank = Groupbox:AddBlank(10, Video.Visible)
        Groupbox:Resize()

        Video.Holder = Holder
        Video.Container = Container
        Video.VideoFrame = VideoFrameInstance

        table.insert(Groupbox.Elements, Video)
        Options[Idx] = Video

        _L:UpdateDependencyBoxes()
        _L:UpdateDependencyGroupboxes()

        return Video
    end

    function BaseGroupboxFuncs:AddUIPassthrough(Idx, Info)
        Info = _L:Validate(Info, Templates.UIPassthrough)

        local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder
        pcall(function() Passthrough.Instance.ZIndex = 7 end)

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, -4, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
            pcall(function() Passthrough.Instance.ZIndex = 7 end)
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            if Blank then Blank.Visible = Passthrough.Visible end

            Groupbox:Resize()
        end

        Passthrough:SetHeight(Passthrough.Height)

        Blank = Groupbox:AddBlank(10, Passthrough.Visible)
        Groupbox:Resize()

        Passthrough.Holder = Holder
        Passthrough.Container = Container

        table.insert(Groupbox.Elements, Passthrough)
        Options[Idx] = Passthrough

        _L:UpdateDependencyBoxes()
        _L:UpdateDependencyGroupboxes()

        return Passthrough
    end

    function BaseGroupboxFuncs:AddDependencyBox()
        local Depbox = {
            Elements = {};
            Dependencies = {};
            TableType = "DepBox";
        }

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = _L:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        })

        local Frame = _L:Create("Frame", {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        })

        local Layout = _L:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        })

        function Depbox:Resize()
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
            Groupbox:Resize()
        end

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Depbox:Resize()
        end)

        Holder:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end)

        function Depbox:Update()
            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1]
                local Value = Dependency[2]

                if if Elem.Multi then not table.find(Elem:GetActiveValues(), Value) else Elem.Value ~= Value then
                    Holder.Visible = false
                    Depbox:Resize()
                    return
                end
            end

            Holder.Visible = true
            Depbox:Resize()
        end

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(typeof(Dependency) == "table", "SetupDependencies: Dependency is not of type `table`.")
                assert(Dependency[1], "SetupDependencies: Dependency is missing element argument.")
                assert(Dependency[2] ~= nil, "SetupDependencies: Dependency is missing value argument.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        Depbox.Container = Frame

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.Elements, Depbox)
        table.insert(_L.DependencyBoxes, Depbox)

        return Depbox
    end

    function BaseGroupboxFuncs:AddDependencyGroupbox()
        local ParentGroupbox = self
        local Tab = ParentGroupbox.Tab

        local DepGroupbox = {
            Elements = {};
            Dependencies = {};
            TableType = "DepGroupbox";
        }

        local BoxOuter = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 0, 507 + 2);
            ZIndex = 2;
            Parent = ParentGroupbox.Side == 1 and Tab.LeftSideFrame or Tab.RightSideFrame;
        })

        _L:AddToRegistry(BoxOuter, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local BoxInner = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = Color3.new(0, 0, 0);
            -- BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, -2, 1, -2);
            Position = UDim2.new(0, 1, 0, 1);
            ZIndex = 4;
            Parent = BoxOuter;
        })

        _L:AddToRegistry(BoxInner, {
            BackgroundColor3 = "BackgroundColor";
        })

        local Highlight = _L:Create("Frame", {
            BackgroundColor3 = _L.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 5;
            Parent = BoxInner;
        })

        _L:AddToRegistry(Highlight, {
            BackgroundColor3 = "AccentColor";
        })

        local Container = _L:Create("Frame", {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 4, 0, 10);
            Size = UDim2.new(1, -4, 1, -10);
            ZIndex = 1;
            Parent = BoxInner;
        })

        _L:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Container;
        })

        function DepGroupbox:Resize()
            local Size = 0

            for _, Element in next, DepGroupbox.Container:GetChildren() do
                if (not Element:IsA("UIListLayout")) and Element.Visible then
                    Size = Size + Element.Size.Y.Offset
                end
            end

            BoxOuter.Size = UDim2.new(1, 0, 0, (10 * DPIScale + Size) + 2 + 2)
        end

        function DepGroupbox:Update()
            for _, Dependency in next, DepGroupbox.Dependencies do
                local Elem = Dependency[1]
                local Value = Dependency[2]

                if if Elem.Multi then not table.find(Elem:GetActiveValues(), Value) else Elem.Value ~= Value then
                    BoxOuter.Visible = false
                    DepGroupbox:Resize()
                    return
                end
            end

            BoxOuter.Visible = true
            DepGroupbox:Resize()
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in pairs(Dependencies) do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        DepGroupbox.Container = Container
        setmetatable(DepGroupbox, BaseGroupbox)

        DepGroupbox:Resize()

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(_L.DependencyGroupboxes, DepGroupbox)

        return DepGroupbox
    end

    BaseGroupbox.__index = BaseGroupboxFuncs
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return BaseGroupboxFuncs[Key](...)
    end
end

--// Keybinds UI \\--
do
    local KeybindOuter = _L:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 10, 0.5, 0);
        Size = UDim2.new(0, 210, 0, 20);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    })

    local KeybindInner = _L:Create("Frame", {
        BackgroundColor3 = _L.MainColor;
        BorderColor3 = _L.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    })

    _L:AddToRegistry(KeybindInner, {
        BackgroundColor3 = "MainColor";
        BorderColor3 = "OutlineColor";
    }, true)

    local ColorFrame = _L:Create("Frame", {
        BackgroundColor3 = _L.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = KeybindInner;
    })

    _L:AddToRegistry(ColorFrame, {
        BackgroundColor3 = "AccentColor";
    }, true)

    local _KeybindLabel = _L:CreateLabel({
        Size = UDim2.new(1, 0, 0, 20);
        Position = UDim2.fromOffset(5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,

        Text = "Keybinds";
        ZIndex = 104;
        Parent = KeybindInner;
    })
    _L:MakeDraggable(KeybindOuter)

    local KeybindContainer = _L:Create("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, -20);
        Position = UDim2.new(0, 0, 0, 20);
        ZIndex = 1;
        Parent = KeybindInner;
    })

    _L:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    })

    _L:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    _L.KeybindFrame = KeybindOuter
    _L.KeybindContainer = KeybindContainer
    _L:MakeDraggable(KeybindOuter)
end

--// Watermark \\--
do
    local WatermarkOuter = _L:Create("Frame", {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    })

    local WatermarkInner = _L:Create("Frame", {
        BackgroundColor3 = _L.MainColor;
        BorderColor3 = _L.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    })

    _L:AddToRegistry(WatermarkInner, {
        BorderColor3 = "AccentColor";
    })

    local InnerFrame = _L:Create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    })

    local Gradient = _L:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
            ColorSequenceKeypoint.new(1, _L.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    })

    _L:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                ColorSequenceKeypoint.new(1, _L.MainColor),
            })
        end
    })

    local WatermarkLabel = _L:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    })

    _L.Watermark = WatermarkOuter
    _L.WatermarkText = WatermarkLabel
    _L:MakeDraggable(_L.Watermark)

    function _L:SetWatermarkVisibility(Bool)
        _L.Watermark.Visible = Bool
    end

    function _L:SetWatermark(Text)
        local X, Y = _L:GetTextBounds(Text, _L.Font, 14)
        _L.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3)
        _L:SetWatermarkVisibility(true)

        _L.WatermarkText.Text = Text
    end
end

--// Notifications \\--
do
    _L.LeftNotificationArea = _L:Create("Frame", {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 11000;
        Parent = ScreenGui;
    })

    _L:Create("UIListLayout", {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = _L.LeftNotificationArea;
    })


    _L.RightNotificationArea = _L:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0);
        BackgroundTransparency = 1;
        Position = UDim2.new(1, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 11000;
        Parent = ScreenGui;
    })

    _L:Create("UIListLayout", {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = _L.RightNotificationArea;
    })
        
    function _L:SetNotifySide(Side: string)
        _L.NotifySide = Side
    end

    function _L:Notify(...)
        local Data = {}
        local Info = select(1, ...)

        if typeof(Info) == "table" then
            Data.Title = Info.Title and tostring(Info.Title) or ""
            Data.Description = tostring(Info.Description)
            Data.Time = Info.Time or 5
            Data.SoundId = Info.SoundId
            Data.Steps = Info.Steps
            Data.Persist = Info.Persist
            Data.Icon = Info.Icon
            Data.IconColor = Info.IconColor
        else
            Data.Title = ""
            Data.Description = tostring(Info)
            Data.Time = select(2, ...) or 5
            Data.SoundId = select(3, ...)
        end
        Data.Destroyed = false

        local DeletedInstance = false
        local DeleteConnection = nil
        if typeof(Data.Time) == "Instance" then
            DeleteConnection = Data.Time.Destroying:Connect(function()
                DeletedInstance = true
                DeleteConnection:Disconnect()
                DeleteConnection = nil
            end)
        end

        local Side = string.lower(_L.NotifySide)
        local XSize, YSize = _L:GetTextBounds(Data.Description, _L.Font, 14)
        YSize = YSize + 7

        local NotifyOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 0, 0, YSize);
            ClipsDescendants = true;
            ZIndex = 11000;
            Visible = false;
            Name = "Notif";
            Parent = Side == "left" and _L.LeftNotificationArea or _L.RightNotificationArea;
        })

        local NotifyInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 11001;
            Parent = NotifyOuter;
        })

        _L:AddToRegistry(NotifyInner, {
            BackgroundColor3 = "MainColor";
            BorderColor3 = "OutlineColor";
        }, true)

        local InnerFrame = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 11002;
            Parent = NotifyInner;
        })

        local Gradient = _L:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                ColorSequenceKeypoint.new(1, _L.MainColor),
            });
            Rotation = -90;
            Parent = InnerFrame;
        })

        _L:AddToRegistry(Gradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                    ColorSequenceKeypoint.new(1, _L.MainColor),
                })
            end
        })

        local ExtraWidth = 0
        local TextPosition = Side == "left" and UDim2.new(0, 4, 0, 0) or UDim2.new(1, -4, 0, 0)
        local TextSizeOffsetX = -4
        local TextSizeOffsetY = 0

        local IconLabel
        if Data.Icon then
            local ParsedIcon = _L:GetCustomIcon(Data.Icon)
            if ParsedIcon then
                ExtraWidth = ExtraWidth + 20
                TextSizeOffsetX = TextSizeOffsetX - 20
                TextSizeOffsetY = TextSizeOffsetY - 2

                if Side == "left" then
                    TextPosition = UDim2.new(0, 24, 0, 0)
                end

                IconLabel = _L:Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = if Side == "left" then UDim2.new(0, 6, 0.5, 0) else UDim2.new(0, 4, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    Image = ParsedIcon.Url,
                    ImageColor3 = Data.IconColor or _L.FontColor,
                    ImageRectOffset = ParsedIcon.ImageRectOffset,
                    ImageRectSize = ParsedIcon.ImageRectSize,
                    ZIndex = 11004,
                    Parent = InnerFrame,
                })
                
                if not Data.IconColor then
                    _L:AddToRegistry(IconLabel, {
                        ImageColor3 = "FontColor";
                    }, true)
                end
                
                if Side == "right" then
                    TextPosition = UDim2.new(1, -8, 0, 0)
                end
            end
        end

        local NotifyLabel = _L:CreateLabel({
            AnchorPoint = Side == "left" and Vector2.new(0, 0) or Vector2.new(1, 0);
            Position = TextPosition;
            Size = UDim2.new(1, TextSizeOffsetX, 1, TextSizeOffsetY);
            Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. tostring(Data.Description);
            TextXAlignment = Side == "left" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right;
            TextSize = 14;
            ZIndex = 11003;
            RichText = true;
            Parent = InnerFrame;
        })

        local SideColor = _L:Create("Frame", {
            AnchorPoint = Side == "left" and Vector2.new(0, 0) or Vector2.new(1, 0);
            Position = Side == "left" and UDim2.new(0, -1, 0, -1) or UDim2.new(1, -1, 0, -1);
            BackgroundColor3 = _L.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 3, 1, 2);
            ZIndex = 11004;
            Parent = NotifyOuter;
        })

        _L:AddToRegistry(SideColor, {
            BackgroundColor3 = "AccentColor";
        }, true)

        function Data:Resize()
            XSize, YSize = _L:GetTextBounds(NotifyLabel.Text, _L.Font, 14)
            YSize = YSize + 7
            
            local TargetSize = UDim2.new(0, XSize * DPIScale + 8 + 4 + ExtraWidth, 0, YSize)
            if _L.NotifySettings.Animation == "Fade" then
                NotifyOuter.Size = TargetSize
                -- Fade in logic handled below in the initial show
            else
                pcall(NotifyOuter.TweenSize, NotifyOuter, TargetSize, "Out", "Quad", 0.4, true)
            end
        end

        function Data:ChangeTitle(NewText)
            NewText = NewText == nil and "" or tostring(NewText)
            Data.Title = NewText
            NotifyLabel.Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. tostring(Data.Description)
            Data:Resize()
        end

        function Data:ChangeDescription(NewText)
            if NewText == nil then return end
            NewText = tostring(NewText)
            Data.Description = NewText
            NotifyLabel.Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. tostring(Data.Description)
            Data:Resize()
        end

        function Data:ChangeStep(...)
        end

        function Data:Destroy()
            Data.Destroyed = true

            if typeof(Data.Time) == "Instance" then
                pcall(Data.Time.Destroy, Data.Time)
            end
            
            if DeleteConnection then
                DeleteConnection:Disconnect()
            end

            local FadeTime = _L.NotifySettings.FadeTime or 0.4
            if _L.NotifySettings.Animation == "Fade" then
                for _, v in pairs(NotifyOuter:GetDescendants()) do
                    if v:IsA("TextLabel") then
                        TWS:Create(v, TweenInfo.new(FadeTime), { TextTransparency = 1 }):Play()
                        TWS:Create(v, TweenInfo.new(FadeTime), { TextStrokeTransparency = 1 }):Play()
                    elseif v:IsA("Frame") then
                        TWS:Create(v, TweenInfo.new(FadeTime), { BackgroundTransparency = 1 }):Play()
                    elseif v:IsA("ImageLabel") then
                        TWS:Create(v, TweenInfo.new(FadeTime), { ImageTransparency = 1 }):Play()
                    elseif v:IsA("UIStroke") then
                        TWS:Create(v, TweenInfo.new(FadeTime), { Transparency = 1 }):Play()
                    end
                end
                TWS:Create(NotifyOuter, TweenInfo.new(FadeTime), { BackgroundTransparency = 1 }):Play()
                task.wait(FadeTime)
            else
                local TargetSize = UDim2.new(0, 0, 0, YSize)
                if _L.NotifySettings.SlideDirection == "Right" and Side == "left" then
                    -- If we are on left but want to slide right to disappear, we need to move it while resizing
                    TWS:Create(NotifyOuter, TweenInfo.new(0.4), { Position = NotifyOuter.Position + UDim2.fromOffset(NotifyOuter.AbsoluteSize.X, 0) }):Play()
                end
                pcall(NotifyOuter.TweenSize, NotifyOuter, TargetSize, "Out", "Quad", 0.4, true)
                task.wait(0.4)
            end
            
            NotifyOuter:Destroy()
        end

        Data:Resize()

        if Data.SoundId then
            _L:Create("Sound", {
                SoundId = "rbxassetid://" .. tostring(Data.SoundId):gsub("rbxassetid://", "");
                Volume = 3;
                PlayOnRemove = true;
                Parent = game:GetService("SoundService");
            }):Destroy()
        end

        NotifyOuter.Visible = true
        if _L.NotifySettings.Animation == "Fade" then
            local FadeTime = _L.NotifySettings.FadeTime or 0.4
            NotifyOuter.Size = UDim2.new(0, XSize * DPIScale + 8 + 4 + ExtraWidth, 0, YSize)
            for _, v in pairs(NotifyOuter:GetDescendants()) do
                if v:IsA("TextLabel") then
                    local Target = v.TextTransparency
                    v.TextTransparency = 1
                    TWS:Create(v, TweenInfo.new(FadeTime), { TextTransparency = Target }):Play()
                    local StrokeTarget = v.TextStrokeTransparency
                    v.TextStrokeTransparency = 1
                    TWS:Create(v, TweenInfo.new(FadeTime), { TextStrokeTransparency = StrokeTarget }):Play()
                elseif v:IsA("Frame") then
                    local Target = v.BackgroundTransparency
                    v.BackgroundTransparency = 1
                    TWS:Create(v, TweenInfo.new(FadeTime), { BackgroundTransparency = Target }):Play()
                elseif v:IsA("ImageLabel") then
                    local Target = v.ImageTransparency
                    v.ImageTransparency = 1
                    TWS:Create(v, TweenInfo.new(FadeTime), { ImageTransparency = Target }):Play()
                elseif v:IsA("UIStroke") then
                    local Target = v.Transparency
                    v.Transparency = 1
                    TWS:Create(v, TweenInfo.new(FadeTime), { Transparency = Target }):Play()
                end
            end
        else
            pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize * DPIScale + 8 + 4 + ExtraWidth, 0, YSize), "Out", "Quad", 0.4, true)
        end

        task.delay(0.4, function()
            if Data.Persist then
                return
            elseif typeof(Data.Time) == "Instance" then
                repeat
                    task.wait()
                until DeletedInstance or Data.Destroyed
            else
                task.wait(Data.Time or 5)
            end

            if not Data.Destroyed then
                Data:Destroy()
            end
        end)

        return Data
    end
end


--// Window \\--
function _L:CreateWindow(...)
    local Arguments = { ... }
    local WindowInfo = Templates.Window

    if typeof(Arguments[1]) == "table" then
        WindowInfo = _L:Validate(Arguments[1], Templates.Window)
    else
        WindowInfo = _L:Validate({
            Title = Arguments[1],
            AutoShow = Arguments[2] or false
        }, Templates.Window)
    end

    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RS:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    if WindowInfo.Size == UDim2.fromOffset(0, 0) then
        WindowInfo.Size = if _L.IsMobile then UDim2.fromOffset(550, math.clamp(ViewportSize.Y - 35, 200, 600)) else UDim2.fromOffset(550, 600)
    end

    _L.NotifySide = WindowInfo.NotifySide
    _L.ShowCustomCursor = WindowInfo.ShowCustomCursor

    if WindowInfo.TabPadding <= 0 then WindowInfo.TabPadding = 1 end
    if WindowInfo.Center then WindowInfo.Position = UDim2.new(0.5, -WindowInfo.Size.X.Offset / 2, 0.5, -WindowInfo.Size.Y.Offset / 2) end

    local Window = {
        Tabs = {};

        OriginalTitle = WindowInfo.Title; 
        Title = WindowInfo.Title;
    }

    local Outer = _L:Create("Frame", {
        AnchorPoint = WindowInfo.AnchorPoint;
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = WindowInfo.Position;
        Size = WindowInfo.Size;
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
        Name = "Window";
    })
    
    local GlowObj = UIGlow:Create(Outer, WindowInfo.Glow)
    Window.Glow = GlowObj
    LibraryMainOuterFrame = Outer
    _L:MakeDraggable(Outer, 25, true)
    if WindowInfo.Resizable then _L:MakeResizable(Outer, _L.MinSize) end

    local Inner = _L:Create("Frame", {
        BackgroundColor3 = _L.MainColor;
        BorderColor3 = _L.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 1;
        Parent = Outer;
    })


    _L:AddToRegistry(Inner, {
        BackgroundColor3 = "MainColor";
        BorderColor3 = "AccentColor";
    })

    local TitleText = ""
    local GameText = ""

    if typeof(WindowInfo.Title) == "table" then
        TitleText = WindowInfo.Title.Name or ""
        if WindowInfo.Title.GameName then
            GameText = '<font color="rgb(255,0,0)">[' .. WindowInfo.Title.GameName .. ']</font>'
        end
    else
        TitleText = WindowInfo.Title or ""
    end
    -- TitlePos が指定されていれば優先、なければ TitleSide を使用
    local _TitlePos = WindowInfo.TitlePos or WindowInfo.TitleSide or "Left"
    local _TitleAnimated = WindowInfo.TitleAnimated or { Type = "None" }
    local _TitleAlignEnum = (
        _TitlePos == "Center" and Enum.TextXAlignment.Center
        or _TitlePos == "Right" and Enum.TextXAlignment.Right
        or Enum.TextXAlignment.Left
    )
    local _TitleLabelX = (_TitlePos == "Center" and UDim2.new(0,0,0,0) or UDim2.new(0,7,0,0))
    local _TitleLabelW = (_TitlePos == "Center" and UDim2.new(1,0,0,25) or UDim2.new(1,-7,0,25))

    -- Slide 用クリップフレームを作る（Slide以外でも共通のラッパーを使う）
    local TitleClipFrame = _L:Create("Frame", {
        BackgroundTransparency = 1;
        ClipsDescendants = _TitleAnimated.Type == "Slide";
        Position = _TitleLabelX;
        Size = _TitleLabelW;
        ZIndex = 1;
        Parent = Inner;
    })

    local WindowLabel = _L:CreateLabel({
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        Text = TitleText;
        TextXAlignment = _TitleAlignEnum;
        ZIndex = 1;
        Parent = TitleClipFrame;
        RichText = true;
    })

    -- Title アニメーション
    do
        local AnimType  = _TitleAnimated.Type  or "None"
        local AnimSpeed = _TitleAnimated.Speed or 0.3
        local AnimDir   = _TitleAnimated.Direction or "Left"

        if AnimType == "Fade" then
            -- フェードイン→アウト ループ
            task.spawn(function()
                while TitleClipFrame and TitleClipFrame.Parent do
                    TWS:Create(WindowLabel, TweenInfo.new(AnimSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { TextTransparency = 0.85 }):Play()
                    task.wait(AnimSpeed)
                    TWS:Create(WindowLabel, TweenInfo.new(AnimSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { TextTransparency = 0 }):Play()
                    task.wait(AnimSpeed + 0.6)
                end
            end)

        elseif AnimType == "Slide" then
            -- テキストが指定方向にスライドしてループ
            task.spawn(function()
                local function getSlideOffset()
                    if AnimDir == "Left"  then return UDim2.new(0, -TitleClipFrame.AbsoluteSize.X - 10, 0, 0), UDim2.new(1, 10, 0, 0)
                    elseif AnimDir == "Right" then return UDim2.new(1, 10, 0, 0), UDim2.new(0, -TitleClipFrame.AbsoluteSize.X - 10, 0, 0)
                    elseif AnimDir == "Up"    then return UDim2.new(0, 0, -1, -10), UDim2.new(0, 0, 1, 10)
                    else return UDim2.new(0, 0, 1, 10), UDim2.new(0, 0, -1, -10) end
                end
                task.wait(0.5) -- レイアウト確定待ち
                while TitleClipFrame and TitleClipFrame.Parent do
                    local exitPos, enterPos = getSlideOffset()
                    -- スライドアウト
                    TWS:Create(WindowLabel, TweenInfo.new(AnimSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                        { Position = exitPos }):Play()
                    task.wait(AnimSpeed)
                    -- 瞬間移動して入り直す
                    WindowLabel.Position = enterPos
                    TWS:Create(WindowLabel, TweenInfo.new(AnimSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { Position = UDim2.new(0, 0, 0, 0) }):Play()
                    task.wait(AnimSpeed + 1.5)
                end
            end)
        end
    end

    if GameText ~= "" then
        local GameLabel = _L:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, -7, 0, 25);
            Text = GameText;
            TextXAlignment = Enum.TextXAlignment.Right;
            ZIndex = 1;
            Parent = Inner;
            RichText = true;
        })
    end

    local MainSectionOuter = _L:Create("Frame", {
        BackgroundColor3 = _L.BackgroundColor;
        BorderColor3 = _L.OutlineColor;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 1, -33);
        ZIndex = 1;
        Parent = Inner;
    })

    _L:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = "BackgroundColor";
        BorderColor3 = "OutlineColor";
    })

    local MainSectionInner = _L:Create("Frame", {
        BackgroundColor3 = _L.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    })

    _L:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = "BackgroundColor";
    })

    local TabArea = _L:Create("ScrollingFrame", {
        ScrollingDirection = Enum.ScrollingDirection.X;
        CanvasSize = UDim2.new(0, 0, 2, 0);
        HorizontalScrollBarInset = Enum.ScrollBarInset.Always;
        AutomaticCanvasSize = Enum.AutomaticSize.XY;
        ScrollBarThickness = 0;
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8 - WindowInfo.TabPadding, 0, 4);
        Size = UDim2.new(1, -10, 0, 26);
        ZIndex = 1;
        Parent = MainSectionInner;
    })

    local TabListLayout = _L:Create("UIListLayout", {
        Padding = UDim.new(0, WindowInfo.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        Parent = TabArea;
    })

    _L:Create("Frame", {
        BackgroundColor3 = _L.BackgroundColor;
        BorderColor3 = _L.OutlineColor;
        Size = UDim2.new(0, 0, 0, 0);
        LayoutOrder = -1;
        BackgroundTransparency = 1;
        ZIndex = 1;
        Parent = TabArea;
    })
    _L:Create("Frame", {
        BackgroundColor3 = _L.BackgroundColor;
        BorderColor3 = _L.OutlineColor;
        Size = UDim2.new(0, 0, 0, 0);
        LayoutOrder = 9999999;
        BackgroundTransparency = 1;
        ZIndex = 1;
        Parent = TabArea;
    })

    local TabContainer = _L:Create("Frame", {
        BackgroundColor3 = _L.MainColor;
        BorderColor3 = _L.OutlineColor;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        ZIndex = 2;
        Parent = MainSectionInner;
    })
    
    local InnerVideoBackground = _L:Create("VideoFrame", {
        BackgroundColor3 = _L.MainColor;
        BorderMode = Enum.BorderMode.Inset;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 2;
        Visible = false;
        Volume = 0;
        Looped = true;
        Parent = TabContainer;
    })
    _L.InnerVideoBackground = InnerVideoBackground

    local BackgroundImage = _L:Create("ImageLabel", {
        Image = "";
        Position = UDim2.fromScale(0, 0);
        Size = UDim2.fromScale(1, 1);
        ScaleType = Enum.ScaleType.Stretch;
        ZIndex = 2;
        BackgroundTransparency = 1;
        ImageTransparency = 0.75;
        Parent = TabContainer;
        Visible = false;
    })

    _L:AddToRegistry(TabContainer, {
        BackgroundColor3 = "MainColor";
        BorderColor3 = "OutlineColor";
    })

    function Window:SetWindowTitle(Title)
        if typeof(Title) == "string" then
            Window.Title = Title
            WindowLabel.Text = Window.Title
        end
    end

    function Window:SetBackgroundImage(NewImage)
        if tonumber(NewImage) then
            NewImage = "rbxassetid://" .. NewImage
        end

        assert(typeof(NewImage) == "string", "Image must be a string.")

        local Icon = _L:GetCustomIcon(NewImage)
        if not Icon then
            BackgroundImage.Visible = false
            return
        end
        
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        BackgroundImage.Image = Icon.Url
        BackgroundImage.ImageRectOffset = Icon.ImageRectOffset
        BackgroundImage.ImageRectSize = Icon.ImageRectSize

        BackgroundImage.Visible = true
    end

    function Window:AddDialog(Idx, Info)
        assert(Info.Title, "AddDialog: Missing `Title` string.")
        assert(Info.Description, "AddDialog: Missing `Description` string.")

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = _L:Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = LibraryMainOuterFrame,
        })
        TWS:Create(DialogOverlay, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = _L:Create("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = _L.BackgroundColor,
            BorderColor3 = Color3.new(0, 0, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            ZIndex = 9001,
            Visible = true,
            Parent = DialogOverlay,
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
        })

        local DialogInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor,
            BorderColor3 = _L.AccentColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 9002,
            Parent = DialogFrame,
        })

        _L:AddToRegistry(DialogFrame, {
            BackgroundColor3 = "BackgroundColor",
        })

        _L:AddToRegistry(DialogInner, {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "AccentColor",
        })

        local InnerContainer = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 9003,
            Parent = DialogInner,
        })
        local DialogScale = _L:Create("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TWS:Create(DialogScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = 1
        }):Play()

        _L:Create("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerListLayout = _L:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 9003,
            Parent = InnerContainer,
        })
        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        _L:Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 9003,
            Parent = HeaderContainer,
        })
        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        local TitleLabel = _L:CreateLabel({
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title or "Dialog",
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 9003,
            Parent = TitleRow,
            RichText = true,
        })
        if Info.TitleColor then
            TitleLabel.TextColor3 = Info.TitleColor
        else
            _L:AddToRegistry(TitleLabel, { TextColor3 = "FontColor" })
        end

        local DescriptionLabel = _L:CreateLabel({
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description or "Description",
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 9003,
            LayoutOrder = 2,
            Parent = HeaderContainer,
            RichText = true,
        })
        if Info.DescriptionColor then
            DescriptionLabel.TextColor3 = Info.DescriptionColor
        else
            _L:AddToRegistry(DescriptionLabel, { TextColor3 = "FontColor" })
        end

        DialogContainer = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            Visible = false,
            ZIndex = 9003,
            Parent = InnerContainer,
        })
        
        local _Sep2 = _L:Create("Frame", {
            BackgroundColor3 = _L.OutlineColor,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 9003,
            Parent = InnerContainer,
        })
        _L:AddToRegistry(_Sep2, {
            BackgroundColor3 = "OutlineColor",
        })

        ButtonsHolder = _L:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 9002,
            Parent = InnerContainer,
        })
        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        _L:Create("UIPadding", {
            PaddingTop = UDim.new(0, 0),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Elements = {},
            Container = DialogContainer,
        }

        function Dialog:Resize()
            local MaxWidth = LibraryMainOuterFrame.AbsoluteSize.X * 0.75
            local MinWidth = 400 * DPIScale

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in pairs(FooterButtonsList) do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8 * DPIScale) + (30 * DPIScale)
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            local DescY = select(2, _L:GetTextBounds(DescriptionLabel.Text, _L.Font, 14 * DPIScale, TargetWidth - (30 * DPIScale)))
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in pairs(DialogContainer:GetChildren()) do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end

            if HasElements then
                for _, v in pairs(DialogContainer:GetDescendants()) do
                    if not v:IsA("GuiObject") then continue end
                    if v:GetAttribute("ZIndexApplied") then continue end
                    
                    v:SetAttribute("ZIndexApplied", true)
                    v.ZIndex = v.ZIndex + 9003
                end
            end

            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            TWS:Create(DialogScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.95 }):Play()
            TWS:Create(DialogOverlay, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
            
            task.delay(0.1, function()
                DialogOverlay:Destroy()
            end)

            if _L.Dialogues then _L.Dialogues[Idx] = nil end
            _L.ActiveDialog = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0
            local Variant = ButtonInfo.Variant or "Primary"

            local BtnInnerColor = _L.MainColor
            local BtnBorderColor = _L.OutlineColor
            local DestructiveColor = Color3.fromRGB(220, 38, 38)

            if Variant == "Primary" then
                BtnBorderColor = _L.AccentColor
            elseif Variant == "Secondary" then
                BtnInnerColor = _L.BackgroundColor
                BtnBorderColor = _L.OutlineColor
            elseif Variant == "Destructive" then
                BtnBorderColor = DestructiveColor
            elseif Variant == "Ghost" then
                BtnBorderColor = _L.MainColor
            end

            local LabelX = select(1, _L:GetTextBounds(ButtonInfo.Title or ButtonIdx, _L.Font, 14 * DPIScale))
            local BtnW = LabelX + (24 * DPIScale)
            local BtnH = 20 * DPIScale

            local ButtonContainer = _L:Create("Frame", {
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderColor3 = Color3.new(0, 0, 0),
                Size = UDim2.fromOffset(BtnW, BtnH),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 9003,
                Parent = ButtonsHolder,
            })
            _L:AddToRegistry(ButtonContainer, { BorderColor3 = "Black" })

            local TextBtn = _L:Create("TextButton", {
                BackgroundColor3 = BtnInnerColor,
                BorderColor3 = BtnBorderColor,
                BorderMode = Enum.BorderMode.Inset,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 9004,
                Parent = ButtonContainer,
            })

            if Variant == "Primary" then
                _L:AddToRegistry(TextBtn, { BackgroundColor3 = "MainColor", BorderColor3 = "AccentColor" })
            elseif Variant == "Secondary" then
                _L:AddToRegistry(TextBtn, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
            elseif Variant == "Ghost" then
                _L:AddToRegistry(TextBtn, { BackgroundColor3 = "MainColor", BorderColor3 = "MainColor" })
            end

            _L:Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
                }),
                Rotation = 90,
                Parent = TextBtn,
            })

            local HighlightBorderColor = Variant == "Destructive" and DestructiveColor or _L.AccentColor
            ButtonContainer.MouseEnter:Connect(function()
                ButtonContainer.BorderColor3 = HighlightBorderColor
            end)
            ButtonContainer.MouseLeave:Connect(function()
                ButtonContainer.BorderColor3 = Color3.new(0, 0, 0)
            end)

            local TextColor = _L.FontColor
            if Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = _L:CreateLabel({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14 * DPIScale,
                ZIndex = 9005,
                Parent = TextBtn,
            })

            if Variant ~= "Destructive" then
                _L:AddToRegistry(BtnLabel, { TextColor3 = "FontColor" })
            end

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = _L:Create("Frame", {
                    BackgroundColor3 = _L.AccentColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                _L:AddToRegistry(ProgressBar, { BackgroundColor3 = "AccentColor" })
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TWS:Create(TextBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 }):Play()
                        TWS:Create(BtnLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.5 }):Play()
                    else
                        TWS:Create(TextBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
                        TWS:Create(BtnLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
                    end
                end
            }

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end

                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end

                if Info.AutoDismiss ~= false then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TWS:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()
                
                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)

                    if ProgressBar then
                        TWS:Create(ProgressBar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        if Info.FooterButtons then
            for BIdx, BInfo in pairs(Info.FooterButtons) do
                if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
                Dialog:AddFooterButton(BIdx, BInfo)
            end
        end

        setmetatable(Dialog, BaseGroupbox)

        _L.Dialogues[Idx] = Dialog
        _L.ActiveDialog = Dialog

        Dialog:Resize()

        return Dialog
    end

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
            DependencyGroupboxes = {};
            WarningBox = {
                Bottom = false,
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = ""
            };
            OriginalName = Name; 
            Name = Name;
            TableType = "Tab";
        }

        local TabButtonWidth = _L:GetTextBounds(Tab.Name, _L.Font, 16)
        local _TabBtnSize = (typeof(WindowInfo.TabButtonSize) == "UDim2")
            and WindowInfo.TabButtonSize
            or UDim2.new(0, TabButtonWidth + 8 + 4, 0.85, 0)

        local TabButton = _L:Create("Frame", {
            BackgroundColor3 = _L.BackgroundColor;
            BorderColor3 = _L.OutlineColor;
            Size = _TabBtnSize;
            ZIndex = 1;
            Parent = TabArea;
        })

        _L:AddToRegistry(TabButton, {
            BackgroundColor3 = "BackgroundColor";
            BorderColor3 = "OutlineColor";
        })

        local TabButtonLabel = _L:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Tab.Name;
            ZIndex = 1;
            Parent = TabButton;
        })

        local Blocker = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Parent = TabButton;
        })

        _L:AddToRegistry(Blocker, {
            BackgroundColor3 = "MainColor";
        })

        local TabFrame = _L:Create("Frame", {
            Name = "TabFrame",
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            Parent = TabContainer;
        })

        local TopBarLabelStroke
        local TopBarHighlight
        local TopBar, TopBarInner, TopBarLabel, TopBarTextLabel, TopBarScrollingFrame
do
            TopBar = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = Color3.fromRGB(248, 51, 51);
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.new(0, 7, 0, 7);
                Size = UDim2.new(1, -13, 0, 0);
                ZIndex = 2;
                Parent = TabFrame;
                Visible = false;
            })

            TopBarInner = _L:Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(117, 22, 17);
                BorderColor3 = Color3.new();
                -- BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = TopBar;
            })

            TopBarHighlight = _L:Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 75, 75);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 5;
                Parent = TopBarInner;
            })

            TopBarScrollingFrame = _L:Create("ScrollingFrame", {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = UDim2.new(1, -8, 1, 0);
                CanvasSize = UDim2.new(0, 0, 0, 0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarThickness = 3;
                ZIndex = 5;
                Parent = TopBarInner;
            })

            TopBarLabel = _L:Create("TextLabel", {
                BackgroundTransparency = 1;
                Font = _L.Font;
                TextStrokeTransparency = 0;
                RichText = true;

                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = "Text";
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Color3.fromRGB(255, 55, 55);
                ZIndex = 5;
                Parent = TopBarScrollingFrame;
            })

            TopBarLabelStroke = _L:ApplyTextStroke(TopBarLabel)
            TopBarLabelStroke.Color = Color3.fromRGB(174, 3, 3)

            TopBarTextLabel = _L:CreateLabel({
                RichText = true;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, 0, 0, 14);
                TextSize = 14;
                Text = "Text";
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                ZIndex = 5;
                Parent = TopBarScrollingFrame;
            })
            
            _L:Create("Frame", {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 5);
                Visible = true;
                ZIndex = 1;
                Parent = TopBarInner;
            })
        end
        
        local LeftSide = _L:Create("ScrollingFrame", {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 7, 0, 7);
            Size = UDim2.new(0.5, -10, 1, -14);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = "";
            TopImage = "";
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        })

        local RightSide = _L:Create("ScrollingFrame", {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 5, 0, 7);
            Size = UDim2.new(0.5, -10, 1, -14);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = "";
            TopImage = "";
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        })

        Tab.LeftSideFrame = LeftSide
        Tab.RightSideFrame = RightSide

        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        })

        _L:Create("UIListLayout", {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        })

        if _L.IsMobile then
            local SidesValues = {
                ["Left"] = tick(),
                ["Right"] = tick(),
            }

            LeftSide:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                _L.CanDrag = false

                local ChangeTick = tick()
                SidesValues.Left = ChangeTick
                task.wait(0.15)

                if SidesValues.Left == ChangeTick then
                    _L.CanDrag = true
                end
            end)

            RightSide:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                _L.CanDrag = false

                local ChangeTick = tick()
                SidesValues.Right = ChangeTick
                task.wait(0.15)
                
                if SidesValues.Right == ChangeTick then
                    _L.CanDrag = true
                end
            end)
        end

        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y)
            end)
        end

        function Tab:Resize()
            if TopBar.Visible == true then
                local MaximumSize = math.floor(TabFrame.AbsoluteSize.Y / 3.25)
                local Size = 27 + select(2, _L:GetTextBounds(TopBarTextLabel.Text, _L.Font, 14, Vector2.new(TopBarTextLabel.AbsoluteSize.X, math.huge)))

                if Tab.WarningBox.LockSize == true and Size >= MaximumSize then 
                    Size = MaximumSize
                end

                if Tab.WarningBox.Bottom == true then
                    TopBar.Position = UDim2.new(0, 7, 1, -(Size + 7))
                else
                    TopBar.Position = UDim2.new(0, 7, 0, 7)
                end

                TopBar.Size = UDim2.new(1, -13, 0, Size)
                Size = Size + 10
                
                if TopBar.Position.Y.Offset > 0 then
                    LeftSide.Position = UDim2.new(0, 7, 0, 7 + Size)
                    LeftSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
            
                    RightSide.Position = UDim2.new(0.5, 5, 0, 7 + Size)
                    RightSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
                else
                    LeftSide.Position = UDim2.new(0, 7, 0, 7)
                    LeftSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
            
                    RightSide.Position = UDim2.new(0.5, 5, 0, 7)
                    RightSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
                end
            else
                LeftSide.Position = UDim2.new(0, 7, 0, 7)
                LeftSide.Size = UDim2.new(0.5, -10, 1, -14)
        
                RightSide.Position = UDim2.new(0.5, 5, 0, 7)
                RightSide.Size = UDim2.new(0.5, -10, 1, -14)
            end
        end

        function Tab:UpdateWarningBox(Info)
            if typeof(Info.Bottom) == "boolean"     then Tab.WarningBox.Bottom      = Info.Bottom end
            if typeof(Info.IsNormal) == "boolean"   then Tab.WarningBox.IsNormal      = Info.IsNormal end
            if typeof(Info.LockSize) == "boolean"   then Tab.WarningBox.LockSize    = Info.LockSize end
            if typeof(Info.Visible) == "boolean"    then Tab.WarningBox.Visible     = Info.Visible end
            if typeof(Info.Title) == "string"       then Tab.WarningBox.Title       = Info.Title end
            if typeof(Info.Text) == "string"        then Tab.WarningBox.Text        = Info.Text end

            TopBar.Visible = Tab.WarningBox.Visible
            TopBarLabel.Text = Tab.WarningBox.Title
            TopBarTextLabel.Text = Tab.WarningBox.Text
            if TopBar.Visible then Tab:Resize()
end

            TopBar.BorderColor3 = Tab.WarningBox.IsNormal == true and Color3.fromRGB(27, 42, 53) or Color3.fromRGB(248, 51, 51)
            TopBarInner.BorderColor3 = Tab.WarningBox.IsNormal == true and _L.OutlineColor or Color3.fromRGB(0, 0, 0)
            TopBarInner.BackgroundColor3 = Tab.WarningBox.IsNormal == true and _L.BackgroundColor or Color3.fromRGB(117, 22, 17)
            TopBarHighlight.BackgroundColor3 = Tab.WarningBox.IsNormal == true and _L.AccentColor or Color3.fromRGB(255, 75, 75)
             
            TopBarLabel.TextColor3 = Tab.WarningBox.IsNormal == true and _L.FontColor or Color3.fromRGB(255, 55, 55)
            TopBarLabelStroke.Color = Tab.WarningBox.IsNormal == true and _L.Black or Color3.fromRGB(174, 3, 3)

            if not _L.RegistryMap[TopBarInner] then _L:AddToRegistry(TopBarInner, {}) end
            if not _L.RegistryMap[TopBarHighlight] then _L:AddToRegistry(TopBarHighlight, {}) end
            if not _L.RegistryMap[TopBarLabel] then _L:AddToRegistry(TopBarLabel, {}) end
            if not _L.RegistryMap[TopBarLabelStroke] then _L:AddToRegistry(TopBarLabelStroke, {}) end

            _L.RegistryMap[TopBarInner].Properties.BorderColor3 = Tab.WarningBox.IsNormal == true and "OutlineColor" or nil
            _L.RegistryMap[TopBarInner].Properties.BackgroundColor3 = Tab.WarningBox.IsNormal == true and "BackgroundColor" or nil
            _L.RegistryMap[TopBarHighlight].Properties.BackgroundColor3 = Tab.WarningBox.IsNormal == true and "AccentColor" or nil

            _L.RegistryMap[TopBarLabel].Properties.TextColor3 = Tab.WarningBox.IsNormal == true and "FontColor" or nil
            _L.RegistryMap[TopBarLabelStroke].Properties.Color = Tab.WarningBox.IsNormal == true and "Black" or nil
        end

        function Tab:ShowTab()
            _L.ActiveTab = Name
            for _, Tab in next, Window.Tabs do
                Tab:HideTab()
            end

            Blocker.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = _L.MainColor
            _L.RegistryMap[TabButton].Properties.BackgroundColor3 = "MainColor"
            TabFrame.Visible = true

            Tab:Resize()
        end
        Tab.Show = Tab.ShowTab

        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1
            TabButton.BackgroundColor3 = _L.BackgroundColor
            _L.RegistryMap[TabButton].Properties.BackgroundColor3 = "BackgroundColor"
            TabFrame.Visible = false
        end
        Tab.Hide = Tab.HideTab

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position
            TabListLayout:ApplyLayout()
        end

        function Tab:GetSides()
            return { ["Left"] = LeftSide, ["Right"] = RightSide }
        end

        function Tab:SetName(Name)
            if typeof(Name) == "string" then
                Tab.Name = Name

                local TabButtonWidth = _L:GetTextBounds(Tab.Name, _L.Font, 16)
                TabButton.Size = (typeof(WindowInfo.TabButtonSize) == "UDim2")
                    and WindowInfo.TabButtonSize
                    or UDim2.new(0, TabButtonWidth + 8 + 4, 0.85, 0)
                TabButtonLabel.Text = Tab.Name
            end
        end

        function Tab:AddGroupbox(Info)
            local Groupbox = {
                Elements = {};
                Side = Info.Side;
                Tab = Tab;
                TableType = "Groupbox";
            }

            local BoxOuter = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 507 + 2);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            })

            _L:AddToRegistry(BoxOuter, {
                BackgroundColor3 = "BackgroundColor";
                BorderColor3 = "OutlineColor";
            })

            local BoxInner = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                -- BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            })

            _L:AddToRegistry(BoxInner, {
                BackgroundColor3 = "BackgroundColor";
            })

            local Highlight = _L:Create("Frame", {
                BackgroundColor3 = _L.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 5;
                Parent = BoxInner;
            })

            _L:AddToRegistry(Highlight, {
                BackgroundColor3 = "AccentColor";
            })

            -- local GroupboxLabel = 
            _L:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = BoxInner;
            })

            local Container = _L:Create("Frame", {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 1;
                Parent = BoxInner;
            })

            local ListLayout = _L:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            })

            function Groupbox:Resize()
                BoxOuter.Size = UDim2.new(1, 0, 0, (20 * DPIScale + ListLayout.AbsoluteContentSize.Y) + 2 + 2)
            end

            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Groupbox:Resize()
            end)

            Groupbox.Container = Container
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:AddBlank(3)
            Groupbox:Resize()

            Tab.Groupboxes[Info.Name] = Groupbox

            return Groupbox
        end

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; })
        end

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; })
        end

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            }

            local BoxOuter = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = _L.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            })

            _L:AddToRegistry(BoxOuter, {
                BackgroundColor3 = "BackgroundColor";
                BorderColor3 = "OutlineColor";
            })

            local BoxInner = _L:Create("Frame", {
                BackgroundColor3 = _L.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                -- BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            })

            _L:AddToRegistry(BoxInner, {
                BackgroundColor3 = "BackgroundColor";
            })

            local Highlight = _L:Create("Frame", {
                BackgroundColor3 = _L.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 10;
                Parent = BoxInner;
            })

            _L:AddToRegistry(Highlight, {
                BackgroundColor3 = "AccentColor";
            })

            local TabboxButtons = _L:Create("Frame", {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 5;
                Parent = BoxInner;
            })

            _L:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            })

            function Tabbox:AddTab(Name)
                local Tab = {
                    Elements = {};
                    Container = nil;
                    TableType = "TabboxTab";
                }

                local Button = _L:Create("Frame", {
                    BackgroundColor3 = _L.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                })

                _L:AddToRegistry(Button, {
                    BackgroundColor3 = "MainColor";
                })

                -- local ButtonLabel = 
                _L:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                    RichText = true;
                })

                local Block = _L:Create("Frame", {
                    BackgroundColor3 = _L.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                })

                _L:AddToRegistry(Block, {
                    BackgroundColor3 = "BackgroundColor";
                })

                local Container = _L:Create("Frame", {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 4, 0, 20);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 1;
                    Visible = false;
                    Parent = BoxInner;
                })

                _L:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                })

                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide()
                    end

                    Container.Visible = true
                    Block.Visible = true

                    Button.BackgroundColor3 = _L.BackgroundColor
                    _L.RegistryMap[Button].Properties.BackgroundColor3 = "BackgroundColor"

                    Tab:Resize()
                end

                function Tab:Hide()
                    Container.Visible = false
                    Block.Visible = false

                    Button.BackgroundColor3 = _L.MainColor
                    _L.RegistryMap[Button].Properties.BackgroundColor3 = "MainColor"
                end

                function Tab:Resize()
                    local TabCount = 0

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1
                    end

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA("UIListLayout") then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0)
                        end
                    end

                    if (not Container.Visible) then
                        return
                    end

                    local Size = 0

                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA("UIListLayout")) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset
                        end
                    end

                    BoxOuter.Size = UDim2.new(1, 0, 0, (20 * DPIScale + Size) + 2 + 2)
                end

                Button.InputBegan:Connect(function(Input)
                    if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not _L:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                        Tab:Show()
                        Tab:Resize()
                    end
                end)

                Tab.Container = Container
                Tabbox.Tabs[Name] = Tab

                setmetatable(Tab, BaseGroupbox)

                Tab:AddBlank(3)
                Tab:Resize()

                -- Show first tab (number is 2 cus of the UIListLayout that also sits in that instance)
                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show()
                end

                return Tab
            end

            Tab.Tabboxes[Info.Name or ""] = Tabbox

            return Tabbox
        end

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; })
        end

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; })
        end

        --[[ Tab:AddTab(Info)
             メインタブ内にサブタブ行を追加する。
             Info = { Name = "名前", Icon = "rbxassetid://...", Side = 1/2 }
             戻り値のオブジェクトから AddLeftGroupbox / AddRightGroupbox が使える。

             例:
                local Target = Tab:AddTab({ Name = "Target", Icon = "rbxassetid://65974846" })
                Target:AddLeftGroupbox("Aim Assist")
        ]]
        do
            -- サブタブ行のコンテナ（まだなければ作る）
            Tab._SubTabContainer = nil
            Tab._SubTabButtonRow = nil
            Tab._SubTabs = {}
            Tab._SubTabActive = nil

            local function _EnsureSubTabRow()
                if Tab._SubTabContainer then return end

                -- LeftSide / RightSide の上に全幅のサブタブ行フレームを追加
                local SubTabRow = _L:Create("Frame", {
                    BackgroundColor3 = _L.BackgroundColor;
                    BorderColor3 = _L.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Position = UDim2.new(0, 7, 0, 7);
                    Size = UDim2.new(1, -14, 0, 26);
                    ZIndex = 3;
                    Parent = TabFrame;
                })
                _L:AddToRegistry(SubTabRow, {
                    BackgroundColor3 = "BackgroundColor";
                    BorderColor3 = "OutlineColor";
                })

                local SubTabInner = _L:Create("Frame", {
                    BackgroundColor3 = _L.MainColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 0, 0);
                    Size = UDim2.new(1, 0, 1, 0);
                    ZIndex = 3;
                    Parent = SubTabRow;
                })
                _L:AddToRegistry(SubTabInner, { BackgroundColor3 = "MainColor" })

                _L:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    Parent = SubTabInner;
                })

                Tab._SubTabButtonRow = SubTabInner
                Tab._SubTabContainer = SubTabRow

                -- LeftSide/RightSide を下にずらす
                local shift = 34
                LeftSide.Position  = UDim2.new(0, 7, 0, 7 + shift)
                LeftSide.Size      = UDim2.new(0.5, -10, 1, -14 - shift)
                RightSide.Position = UDim2.new(0.5, 5, 0, 7 + shift)
                RightSide.Size     = UDim2.new(0.5, -10, 1, -14 - shift)
            end

            function Tab:AddTab(Info)
                if typeof(Info) == "string" then
                    Info = { Name = Info }
                end
                Info = Info or {}
                local SubTabName = Info.Name or ("SubTab_" .. (#Tab._SubTabs + 1))
                local SubTabIcon = Info.Icon

                _EnsureSubTabRow()

                -- ボタンサイズ決定
                local _SubBtnSize = (typeof(WindowInfo.SubTabButtonSize) == "UDim2")
                    and WindowInfo.SubTabButtonSize
                    or UDim2.new(0, _L:GetTextBounds(SubTabName, _L.Font, 14) + (SubTabIcon and 28 or 0) + 12, 1, 0)

                -- ボタンフレーム
                local BtnFrame = _L:Create("Frame", {
                    BackgroundColor3 = _L.BackgroundColor;
                    BorderColor3 = _L.OutlineColor;
                    Size = _SubBtnSize;
                    ZIndex = 4;
                    Parent = Tab._SubTabButtonRow;
                })
                _L:AddToRegistry(BtnFrame, {
                    BackgroundColor3 = "BackgroundColor";
                    BorderColor3 = "OutlineColor";
                })

                -- ボタン内部（アクティブ時はMainColor）
                local BtnInner = _L:Create("Frame", {
                    BackgroundColor3 = _L.MainColor;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 1, 0);
                    ZIndex = 4;
                    Parent = BtnFrame;
                })
                _L:AddToRegistry(BtnInner, { BackgroundColor3 = "MainColor" })

                -- アクティブ下線ブロッカー
                local BtnBlocker = _L:Create("Frame", {
                    BackgroundColor3 = _L.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, -1);
                    Size = UDim2.new(1, 0, 0, 2);
                    BackgroundTransparency = 1;
                    ZIndex = 6;
                    Parent = BtnFrame;
                })
                _L:AddToRegistry(BtnBlocker, { BackgroundColor3 = "BackgroundColor" })

                -- アイコン
                if SubTabIcon then
                    local IconImg = _L:Create("ImageLabel", {
                        AnchorPoint = Vector2.new(0, 0.5);
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0, 4, 0.5, 0);
                        Size = UDim2.new(0, 16, 0, 16);
                        Image = SubTabIcon;
                        ZIndex = 5;
                        Parent = BtnInner;
                    })
                end

                -- ラベル
                local LabelOffsetX = SubTabIcon and 22 or 0
                local BtnLabel = _L:CreateLabel({
                    Position = UDim2.new(0, LabelOffsetX + 4, 0, 0);
                    Size = UDim2.new(1, -(LabelOffsetX + 8), 1, -1);
                    Text = SubTabName;
                    TextSize = 14;
                    ZIndex = 5;
                    Parent = BtnInner;
                    RichText = true;
                })

                -- コンテンツフレーム（LeftSide/RightSide の代わりとなる2つのScrollingFrame）
                local SubLeft = _L:Create("ScrollingFrame", {
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Position = LeftSide.Position;
                    Size = LeftSide.Size;
                    CanvasSize = UDim2.new(0, 0, 0, 0);
                    BottomImage = "";
                    TopImage = "";
                    ScrollBarThickness = 0;
                    ZIndex = 2;
                    Visible = false;
                    Parent = TabFrame;
                })
                local SubRight = _L:Create("ScrollingFrame", {
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Position = RightSide.Position;
                    Size = RightSide.Size;
                    CanvasSize = UDim2.new(0, 0, 0, 0);
                    BottomImage = "";
                    TopImage = "";
                    ScrollBarThickness = 0;
                    ZIndex = 2;
                    Visible = false;
                    Parent = TabFrame;
                })

                _L:Create("UIListLayout", {
                    Padding = UDim.new(0, 8);
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    Parent = SubLeft;
                })
                _L:Create("UIListLayout", {
                    Padding = UDim.new(0, 8);
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    Parent = SubRight;
                })

                for _, Side in next, { SubLeft, SubRight } do
                    Side:WaitForChild("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y)
                    end)
                end

                -- SubTab オブジェクト（AddLeftGroupbox / AddRightGroupbox を持つ）
                local SubTab = {
                    Elements = {};
                    LeftSideFrame = SubLeft;
                    RightSideFrame = SubRight;
                    Tab = Tab;
                    TableType = "SubTab";
                    Name = SubTabName;
                }

                function SubTab:AddGroupbox(GInfo)
                    local Groupbox = {
                        Elements = {};
                        Side = GInfo.Side;
                        Tab = SubTab;
                        TableType = "Groupbox";
                    }

                    local BoxOuter = _L:Create("Frame", {
                        BackgroundColor3 = _L.BackgroundColor;
                        BorderColor3 = _L.OutlineColor;
                        BorderMode = Enum.BorderMode.Inset;
                        Size = UDim2.new(1, 0, 0, 507 + 2);
                        ZIndex = 2;
                        Parent = GInfo.Side == 1 and SubLeft or SubRight;
                    })
                    _L:AddToRegistry(BoxOuter, {
                        BackgroundColor3 = "BackgroundColor";
                        BorderColor3 = "OutlineColor";
                    })

                    local BoxInner = _L:Create("Frame", {
                        BackgroundColor3 = _L.BackgroundColor;
                        BorderColor3 = Color3.new(0, 0, 0);
                        Size = UDim2.new(1, -2, 1, -2);
                        Position = UDim2.new(0, 1, 0, 1);
                        ZIndex = 4;
                        Parent = BoxOuter;
                    })
                    _L:AddToRegistry(BoxInner, { BackgroundColor3 = "BackgroundColor" })

                    local Highlight = _L:Create("Frame", {
                        BackgroundColor3 = _L.AccentColor;
                        BorderSizePixel = 0;
                        Size = UDim2.new(1, 0, 0, 2);
                        ZIndex = 5;
                        Parent = BoxInner;
                    })
                    _L:AddToRegistry(Highlight, { BackgroundColor3 = "AccentColor" })

                    _L:CreateLabel({
                        Size = UDim2.new(1, 0, 0, 18);
                        Position = UDim2.new(0, 4, 0, 2);
                        TextSize = 14;
                        Text = GInfo.Name;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 5;
                        Parent = BoxInner;
                    })

                    local Container = _L:Create("Frame", {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0, 4, 0, 20);
                        Size = UDim2.new(1, -4, 1, -20);
                        ZIndex = 1;
                        Parent = BoxInner;
                    })

                    local ListLayout = _L:Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical;
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        Parent = Container;
                    })

                    function Groupbox:Resize()
                        BoxOuter.Size = UDim2.new(1, 0, 0, (20 * DPIScale + ListLayout.AbsoluteContentSize.Y) + 2 + 2)
                    end

                    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        Groupbox:Resize()
                    end)

                    Groupbox.Container = Container
                    setmetatable(Groupbox, BaseGroupbox)

                    Groupbox:AddBlank(3)
                    Groupbox:Resize()

                    return Groupbox
                end

                function SubTab:AddLeftGroupbox(Name)
                    return SubTab:AddGroupbox({ Side = 1; Name = Name; })
                end
                function SubTab:AddRightGroupbox(Name)
                    return SubTab:AddGroupbox({ Side = 2; Name = Name; })
                end

                -- サブタブの表示切替
                local function ShowSubTab()
                    -- 他のサブタブを隠す
                    for _, st in next, Tab._SubTabs do
                        if st ~= SubTab then
                            st._Left.Visible  = false
                            st._Right.Visible = false
                            st._BtnInner.BackgroundColor3 = _L.MainColor
                            _L.RegistryMap[st._BtnInner].Properties.BackgroundColor3 = "MainColor"
                            st._Blocker.BackgroundTransparency = 1
                        end
                    end
                    -- このタブを表示
                    SubLeft.Visible  = true
                    SubRight.Visible = true
                    BtnInner.BackgroundColor3 = _L.BackgroundColor
                    _L.RegistryMap[BtnInner].Properties.BackgroundColor3 = "BackgroundColor"
                    BtnBlocker.BackgroundTransparency = 0
                    Tab._SubTabActive = SubTab
                end

                SubTab._Left    = SubLeft
                SubTab._Right   = SubRight
                SubTab._BtnInner = BtnInner
                SubTab._Blocker = BtnBlocker

                BtnFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        ShowSubTab()
                    end
                end)

                table.insert(Tab._SubTabs, SubTab)

                -- 最初のサブタブは自動表示
                if #Tab._SubTabs == 1 then
                    ShowSubTab()
                end

                -- ボタン幅を均等再配分
                local function RedistributeSubButtons()
                    local count = #Tab._SubTabs
                    for _, st in next, Tab._SubTabs do
                        if typeof(WindowInfo.SubTabButtonSize) == "UDim2" then
                            st._BtnInner.Parent.Size = WindowInfo.SubTabButtonSize
                        else
                            st._BtnInner.Parent.Size = UDim2.new(1/count, 0, 1, 0)
                        end
                    end
                end
                RedistributeSubButtons()

                return SubTab
            end -- Tab:AddTab
        end -- do

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Tab:ShowTab()
            end
        end)

        TopBar:GetPropertyChangedSignal("Visible"):Connect(function()
            Tab:Resize()
        end)

        -- This was the first tab added, so we show it by default.
        _L.TotalTabs = _L.TotalTabs + 1
        if _L.TotalTabs == 1 then
            Tab:ShowTab()
        end

        Window.Tabs[Name] = Tab
        return Tab
    end

    local TransparencyCache = {}
    local Toggled = false
    local Fading = false
    
    function Window:Toggle(Toggling)
        if typeof(Toggling) == "boolean" and Toggling == Toggled then return end
        if Fading then return end

        local FadeTime = WindowInfo.MenuFadeTime
        Fading = true
        Toggled = (not Toggled)

        _L.Toggled = Toggled
        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = _L.Toggled
        end

        if Toggled then
            -- A bit scuffed, but if we're going from not toggled -> toggled we want to show the frame immediately so that the fade is visible.
            Outer.Visible = true

            if DrawingLib.drawing_replaced ~= true and IsBadDrawingLib ~= true then
                IsBadDrawingLib = not (pcall(function()
                    local Cursor = DrawingLib.new("Triangle")
                    Cursor.Thickness = 1
                    Cursor.Filled = true
                    Cursor.Visible = _L.ShowCustomCursor

                    local CursorOutline = DrawingLib.new("Triangle")
                    CursorOutline.Thickness = 1
                    CursorOutline.Filled = false
                    CursorOutline.Color = Color3.new(0, 0, 0)
                    CursorOutline.Visible = _L.ShowCustomCursor
                    
                    local OldMouseIconState = UIS.MouseIconEnabled
                    local ShowCursorBinding = _L.ShowCursorBinding
                    pcall(function() RS:UnbindFromRenderStep(ShowCursorBinding) end)
                    RS:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Camera.Value - 1, function()
                        UIS.MouseIconEnabled = not _L.ShowCustomCursor
                        local mPos = UIS:GetMouseLocation()
                        local X, Y = mPos.X, mPos.Y
                        Cursor.Color = _L.AccentColor
                        Cursor.PointA = Vector2.new(X, Y)
                        Cursor.PointB = Vector2.new(X + 16, Y + 6)
                        Cursor.PointC = Vector2.new(X + 6, Y + 16)
                        Cursor.Visible = _L.ShowCustomCursor
                        CursorOutline.PointA = Cursor.PointA
                        CursorOutline.PointB = Cursor.PointB
                        CursorOutline.PointC = Cursor.PointC
                        CursorOutline.Visible = _L.ShowCustomCursor
                        if not Toggled or (not ScreenGui or not ScreenGui.Parent) then
                            UIS.MouseIconEnabled = OldMouseIconState
                            if Cursor then Cursor:Destroy() end
                            if CursorOutline then CursorOutline:Destroy() end
                            RS:UnbindFromRenderStep(ShowCursorBinding)
                        end
                    end)
                end))
            end

            if _L.BackgroundFrame then
                _L.BackgroundFrame.Visible = true
                TWS:Create(_L.BackgroundFrame, TweenInfo.new(FadeTime), { BackgroundTransparency = _L.BackgroundSettings.Transparency }):Play()
            end
            if _L.BlurEffect then
                TWS:Create(_L.BlurEffect, TweenInfo.new(FadeTime), { Size = _L.BackgroundSettings.Blur }):Play()
            end
        end

        for _, Option in Options do
            task.spawn(function()
                if Option.Type == "Dropdown" then
                    Option:CloseDropdown()

                elseif Option.Type == "KeyPicker" then
                    Option:SetModePickerVisibility(false)

                elseif Option.Type == "ColorPicker" then
                    Option.ContextMenu:Hide()
                    Option:Hide()
                end
            end)
        end

        for _, Desc in next, Outer:GetDescendants() do
            local Properties = {}

            if Desc:IsA("ImageLabel") then
                table.insert(Properties, "ImageTransparency")
                table.insert(Properties, "BackgroundTransparency")

            elseif Desc:IsA("TextLabel") or Desc:IsA("TextBox") then
                table.insert(Properties, "TextTransparency")

            elseif Desc:IsA("Frame") or Desc:IsA("ScrollingFrame") then
                table.insert(Properties, "BackgroundTransparency")
                
            elseif Desc:IsA("UIStroke") then
                table.insert(Properties, "Transparency")
            end

            local Cache = TransparencyCache[Desc]

            if (not Cache) then
                Cache = {}
                TransparencyCache[Desc] = Cache
            end

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop]
                end

                if Cache[Prop] == 1 then
                    continue
                end

                TWS:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play()
            end
        end

        if not Toggled then
            if _L.BackgroundFrame then
                TWS:Create(_L.BackgroundFrame, TweenInfo.new(FadeTime), { BackgroundTransparency = 1 }):Play()
            end
            if _L.BlurEffect then
                TWS:Create(_L.BlurEffect, TweenInfo.new(FadeTime), { Size = 0 }):Play()
            end
        end

        task.wait(FadeTime)
        Outer.Visible = Toggled
        if not Toggled and _L.BackgroundFrame then
            _L.BackgroundFrame.Visible = false
        end
        Fading = false
    end

    function Window:AddUIManager(Tab)
        return _L:AddUIManager(Tab)
    end

    function _L:Toggle(Toggling)
        return Window:Toggle(Toggling)
    end

    function _L:SetGlow(Index, Color, Thickness, Transparency, Enabled)
        local TargetWindow = _L.Window
        if TargetWindow and TargetWindow.Glow then
            TargetWindow.Glow:Update({
                Color = Color,
                Thickness = Thickness,
                Transparency = Transparency,
                Enabled = Enabled
            })
        end
    end

    function _L:AddUIManager(Tab)
        local Tabbox = Tab:AddLeftTabbox("UI Manager")

        local NotifyTab = Tabbox:AddTab("Notify")
        local BackgroundTab = Tabbox:AddTab("Background")

        -- Notify Tab
        local function UpdateNotifyPosition()
            local hPos = _L.NotifySettings.HorizontalPosition or 0
            local vPos = _L.NotifySettings.Position or 40
            
            _L.LeftNotificationArea.Position = UDim2.new(hPos, 0, 0, vPos)
            _L.LeftNotificationArea.AnchorPoint = Vector2.new(hPos, 0)
            
            _L.RightNotificationArea.Position = UDim2.new(hPos, 0, 0, vPos)
            _L.RightNotificationArea.AnchorPoint = Vector2.new(hPos, 0)
            
            Library:Notify({
                Title = "Notify Preview",
                Content = "Adjusting notification position...",
                Duration = 0.5
            })
        end

        NotifyTab:AddSlider("NotifyPosition", {
            Text = "Vertical Position",
            Min = 0, Max = 1000, Default = _L.NotifySettings.Position,
            Rounding = 0,
            Callback = function(Value)
                _L.NotifySettings.Position = Value
                UpdateNotifyPosition()
            end
        })

        NotifyTab:AddSlider("NotifyPositionX", {
            Text = "Horizontal Position (%)",
            Min = 0, Max = 100, Default = (_L.NotifySettings.HorizontalPosition or 0) * 100,
            Rounding = 0,
            Callback = function(Value)
                _L.NotifySettings.HorizontalPosition = Value / 100
                UpdateNotifyPosition()
            end
        })

        local SampleTimer = 0
        _L.Options.NotifyPosition:OnChanged(function(Value)
            _L.NotifySettings.Position = Value
            _L.LeftNotificationArea.Position = UDim2.new(0, 0, 0, Value)
            _L.RightNotificationArea.Position = UDim2.new(1, 0, 0, Value)

            if not _L.SampleNotification or _L.SampleNotification.Destroyed then
                _L.SampleNotification = _L:Notify({
                    Title = "Sample",
                    Description = "This is a sample notification.",
                    Persist = true
                })
            end
            
            SampleTimer = tick()
            local MyTimer = SampleTimer
            task.delay(1.5, function()
                if SampleTimer == MyTimer then
                    if _L.SampleNotification and not _L.SampleNotification.Destroyed then
                        _L.SampleNotification:Destroy()
                        _L.SampleNotification = nil
                    end
                end
            end)
        end)

        NotifyTab:AddDropdown("NotifyAnimation", {
            Text = "Animation",
            Values = { "Slide", "Fade" },
            Default = _L.NotifySettings.Animation,
            Callback = function(Value)
                _L.NotifySettings.Animation = Value
            end
        })

        local SlideDropdown = NotifyTab:AddDropdown("NotifySlideDirection", {
            Text = "Slide Direction",
            Values = { "Left", "Right" },
            Default = _L.NotifySettings.SlideDirection,
            Callback = function(Value)
                _L.NotifySettings.SlideDirection = Value
            end
        })
        
        local FadeSlider = NotifyTab:AddSlider("NotifyFadeTime", {
            Text = "Fade Time",
            Min = 0.1, Max = 2, Default = _L.NotifySettings.FadeTime,
            Rounding = 1,
            Callback = function(Value)
                _L.NotifySettings.FadeTime = Value
            end
        })

        _L.Options.NotifyAnimation:OnChanged(function(Value)
            SlideDropdown:SetVisible(Value == "Slide")
            FadeSlider:SetVisible(Value == "Fade")
        end)

        -- Background Tab
        BackgroundTab:AddSlider("BackgroundBlur", {
            Text = "Blur",
            Min = 0, Max = 50, Default = _L.BackgroundSettings.Blur,
            Rounding = 0,
            Callback = function(Value)
                _L.BackgroundSettings.Blur = Value
                if _L.Toggled and _L.BlurEffect then
                    _L.BlurEffect.Size = Value
                end
            end
        })

        BackgroundTab:AddLabel("Color"):AddColorPicker("BackgroundColorPicker", {
            Default = _L.BackgroundSettings.Color,
            Callback = function(Value)
                _L.BackgroundSettings.Color = Value
                if _L.BackgroundFrame then
                    _L.BackgroundFrame.BackgroundColor3 = Value
                end
            end
        })

        BackgroundTab:AddSlider("BackgroundTransparency", {
            Text = "Transparency",
            Min = 0, Max = 100, Default = _L.BackgroundSettings.Transparency * 100,
            Rounding = 0,
            Callback = function(Value)
                _L.BackgroundSettings.Transparency = Value / 100
                if _L.Toggled and _L.BackgroundFrame then
                    _L.BackgroundFrame.BackgroundTransparency = Value / 100
                end
            end
        })
    end

    _L:GiveSignal(UIS.InputBegan:Connect(function(Input, Processed) -- :sob:
        if _L.Unloaded then
            return
        end
        
        if typeof(_L.ToggleKeybind) == "table" and _L.ToggleKeybind.Type == "KeyPicker" then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == _L.ToggleKeybind.Value then
                task.spawn(_L.Toggle)
            end

        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(_L.Toggle)
        end
    end))

    if _L.IsMobile then
        local ToggleUIOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0.008, 0, 0.018, 0);
            Size = UDim2.new(0, 77, 0, 30);
            ZIndex = 200;
            Visible = true;
            Parent = ScreenGui;
        })
    
        local ToggleUIInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 201;
            Parent = ToggleUIOuter;
        })
    
        _L:AddToRegistry(ToggleUIInner, {
            BorderColor3 = "AccentColor";
        })
    
        local ToggleUIInnerFrame = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 202;
            Parent = ToggleUIInner;
        })
    
        local ToggleUIGradient = _L:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                ColorSequenceKeypoint.new(1, _L.MainColor),
            });
            Rotation = -90;
            Parent = ToggleUIInnerFrame;
        })
    
        _L:AddToRegistry(ToggleUIGradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                    ColorSequenceKeypoint.new(1, _L.MainColor),
                })
            end
        })
    
        local ToggleUIButton = _L:Create("TextButton", {
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -4, 1, 0);
            BackgroundTransparency = 1;
            Font = _L.Font;
            Text = "Toggle UI";
            TextColor3 = _L.FontColor;
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextStrokeTransparency = 0;
            ZIndex = 203;
            Parent = ToggleUIInnerFrame;
        })
    
        _L:MakeDraggableUsingParent(ToggleUIButton, ToggleUIOuter)

        ToggleUIButton.MouseButton1Down:Connect(function()
            _L:Toggle()
        end)

        -- Lock
        local LockUIOuter = _L:Create("Frame", {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0.008, 0, 0.075, 0);
            Size = UDim2.new(0, 77, 0, 30);
            ZIndex = 200;
            Visible = true;
            Parent = ScreenGui;
        })
    
        local LockUIInner = _L:Create("Frame", {
            BackgroundColor3 = _L.MainColor;
            BorderColor3 = _L.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 201;
            Parent = LockUIOuter;
        })
    
        _L:AddToRegistry(LockUIInner, {
            BorderColor3 = "AccentColor";
        })
    
        local LockUIInnerFrame = _L:Create("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 202;
            Parent = LockUIInner;
        })
    
        local LockUIGradient = _L:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                ColorSequenceKeypoint.new(1, _L.MainColor),
            });
            Rotation = -90;
            Parent = LockUIInnerFrame;
        })
    
        _L:AddToRegistry(LockUIGradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor)),
                    ColorSequenceKeypoint.new(1, _L.MainColor),
                })
            end
        })
    
        local LockUIButton = _L:Create("TextButton", {
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -4, 1, 0);
            BackgroundTransparency = 1;
            Font = _L.Font;
            Text = "Lock UI";
            TextColor3 = _L.FontColor;
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextStrokeTransparency = 0;
            ZIndex = 203;
            Parent = LockUIInnerFrame;
        })
    
        _L:MakeDraggableUsingParent(LockUIButton, LockUIOuter)
        
        LockUIButton.MouseButton1Down:Connect(function()
            _L.CantDragForced = not _L.CantDragForced
            LockUIButton.Text = _L.CantDragForced and "Unlock UI" or "Lock UI"
        end)
    end

    Window:SetBackgroundImage(WindowInfo.BackgroundImage or "")
    if WindowInfo.Intro and WindowInfo.Intro.Enabled then
        task.spawn(function()
            local IntroInfo = WindowInfo.Intro
            
            local HiddenElements = {}
            for _, v in next, Outer:GetDescendants() do
                if v:IsA("GuiObject") then
                    local Props = {}
                    if v:IsA("TextLabel") or v:IsA("TextBox") then table.insert(Props, "TextTransparency") end
                    if v:IsA("ImageLabel") then table.insert(Props, "ImageTransparency") end
                    if v:IsA("Frame") or v:IsA("ScrollingFrame") then table.insert(Props, "BackgroundTransparency") end
                    if v:IsA("UIStroke") then table.insert(Props, "Transparency") end
                    
                    local Cache = {}
                    for _, p in next, Props do
                        Cache[p] = v[p]
                        v[p] = 1
                    end
                    HiddenElements[v] = Cache
                end
            end
            
            Outer.Visible = true
            if _L.BackgroundFrame then
                _L.BackgroundFrame.Visible = true
                TWS:Create(_L.BackgroundFrame, TweenInfo.new(0.5), { BackgroundTransparency = _L.BackgroundSettings.Transparency }):Play()
            end
            if _L.BlurEffect then
                TWS:Create(_L.BlurEffect, TweenInfo.new(0.5), { Size = _L.BackgroundSettings.Blur }):Play()
            end
            TWS:Create(Outer, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
            TWS:Create(Inner, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()

            local Cover = _L:Create("Frame", {
                Name = "IntroCover",
                Parent = Inner,
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 99,
            })
            _L:Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, _L:GetDarkerColor(_L.MainColor, 0.7)),
                    ColorSequenceKeypoint.new(1, _L.MainColor),
                }),
                Rotation = 45,
                Parent = Cover,
            })
            
            local Logo = _L:Create("ImageLabel", {
                Name = "IntroLogo",
                Parent = Cover,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.4, 0),
                Size = UDim2.fromOffset(0, 0),
                Image = "rbxassetid://10723433935",
                BackgroundTransparency = 1,
                ImageTransparency = 1,
                ZIndex = 100,
            })
            
            local Title = _L:CreateLabel({
                Parent = Cover,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.6, 10),
                Size = UDim2.new(1, 0, 0, 30),
                Text = IntroInfo.Title,
                TextSize = 26,
                Font = Enum.Font.GothamBold,
                TextTransparency = 1,
                ZIndex = 101,
            })
            
            local SubTitle = _L:CreateLabel({
                Parent = Cover,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.65, 10),
                Size = UDim2.new(1, 0, 0, 20),
                Text = IntroInfo.SubTitle,
                TextSize = 14,
                TextTransparency = 1,
                ZIndex = 101,
            })

            local ProgressContainer = _L:Create("Frame", {
                Name = "ProgressContainer",
                Parent = Cover,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -30),
                Size = UDim2.new(0.7, 0, 0, 2),
                BackgroundColor3 = _L.OutlineColor,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            local ProgressBar = _L:Create("Frame", {
                Name = "ProgressBar",
                Parent = ProgressContainer,
                Size = UDim2.fromScale(0, 1),
                BackgroundColor3 = WindowInfo.AccentColor or _L.AccentColor,
                BorderSizePixel = 0,
                ZIndex = 101,
            })
            --[[
            local ProgressGlow = _L:Create("ImageLabel", {
                Parent = ProgressBar,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 5, 0.5, 0),
                Size = UDim2.fromOffset(40, 20),
                Image = "rbxassetid://6015667317",
                ImageColor3 = _L.AccentColor,
                BackgroundTransparency = 1,
                ImageTransparency = 0.5,
                ZIndex = 102,
            })]]

            local LogPanel = _L:Create("Frame", {
                Name = "LogPanel",
                Parent = Cover,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.fromScale(0.8, 0),
                BackgroundColor3 = _L.MainColor,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 105,
                Visible = false,
            })
            _L:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = LogPanel })
            local LogStroke = _L:Create("UIStroke", {
                Color = _L.AccentColor,
                Thickness = 1,
                Transparency = 0,
                Parent = LogPanel,
            })
            _L:AddToRegistry(LogPanel, { BackgroundColor3 = "MainColor" })
            _L:AddToRegistry(LogStroke, { Color = "AccentColor" })

            local LogList = _L:Create("ScrollingFrame", {
                Parent = LogPanel,
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.fromOffset(10, 10),
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ZIndex = 106,
            })
            _L:Create("UIListLayout", { Parent = LogList, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

            for i, v in ipairs(IntroInfo.ReleaseLog or {}) do
                local Item = _L:CreateLabel({
                    Parent = LogList,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = v,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 107,
                })
            end

            task.wait(0.5)
            
            TWS:Create(Logo, TweenInfo.new(1, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(100, 100), ImageTransparency = 0 }):Play()
            
            local RotationConnection = RS.RenderStepped:Connect(function()
                Logo.Rotation = Logo.Rotation + 2
            end)
            
            task.spawn(function()
                local t = 0
                while Logo.Parent do
                    t = t + task.wait()
                    local scale = 1 + math.sin(t * 3) * 0.05
                    Logo.Size = UDim2.fromOffset(100 * scale, 100 * scale)
                end
            end)

            task.wait(0.8)
            
            TWS:Create(Title, TweenInfo.new(0.8, Enum.EasingStyle.Quart), { TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.6, 0) }):Play()
            task.wait(0.2)
            TWS:Create(SubTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quart), { TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.65, 0) }):Play()
            
            task.wait(0.2)
            TWS:Create(ProgressContainer, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
            TWS:Create(ProgressBar, TweenInfo.new(IntroInfo.Time, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) }):Play()

            -- Auto-open Release Notes midway
            task.delay(IntroInfo.Time * 0.3, function()
                LogPanel.Visible = true
                TWS:Create(LogPanel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.fromScale(0.8, 0.5)
                }):Play()
            end)

            task.wait(IntroInfo.Time)
            
            TWS:Create(Cover, TweenInfo.new(0.8, Enum.EasingStyle.Quart), { BackgroundTransparency = 1 }):Play()
            for _, v in next, Cover:GetDescendants() do
                local Props = {}
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then Props.TextTransparency = 1 end
                if v:IsA("ImageLabel") or v:IsA("ImageButton") then Props.ImageTransparency = 1 end
                if v:IsA("Frame") or v:IsA("ScrollingFrame") then Props.BackgroundTransparency = 1 end
                if v:IsA("UIStroke") then Props.Transparency = 1 end
                
                if next(Props) then
                    TWS:Create(v, TweenInfo.new(0.5), Props):Play()
                end
            end

            task.wait(0.8)
            RotationConnection:Disconnect()
            Cover:Destroy()
            
            for obj, cache in next, HiddenElements do
                for p, v in next, cache do
                    TWS:Create(obj, TweenInfo.new(0.5), { [p] = v }):Play()
                end
            end
            
            _L.Toggled = true
            if _L.BackgroundFrame then
                _L.BackgroundFrame.Visible = true
                _L.BackgroundFrame.BackgroundTransparency = _L.BackgroundSettings.Transparency
            end
            if _L.BlurEffect then
                _L.BlurEffect.Size = _L.BackgroundSettings.Blur
            end
        end)
    elseif WindowInfo.AutoShow then
        task.spawn(_L.Toggle)
    end

    Window.Holder = Outer
    _L.Window = Window

    return Window
end

local function OnPlayerChange()
    if _L.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(false, true), GetPlayers(true, true)
    local StringPlayerList, StringExcludedPlayerList = GetPlayers(false, false), GetPlayers(true, false)

    for _, Value in next, Options do
        if Value.SetValues and Value.Type == "Dropdown" and Value.SpecialType == "Player" then
            Value:SetValues(
                if Value.ReturnInstanceInstead then
                    (if Value.ExcludeLocalPlayer then ExcludedPlayerList else PlayerList)
                else
                    (if Value.ExcludeLocalPlayer then StringExcludedPlayerList else StringPlayerList)
            )
        end
    end
end

local function OnTeamChange()
    if _L.Unloaded then
        return
    end
    
    local TeamList = GetTeams(false)
    local StringTeamList = GetTeams(true)

    for _, Value in next, Options do
        if Value.SetValues and Value.Type == "Dropdown" and Value.SpecialType == "Team" then
            Value:SetValues(if Value.ReturnInstanceInstead then TeamList else StringTeamList)
        end
    end
end

_L:GiveSignal(PL.PlayerAdded:Connect(OnPlayerChange))
_L:GiveSignal(PL.PlayerRemoving:Connect(OnPlayerChange))

_L:GiveSignal(TM.ChildAdded:Connect(OnTeamChange))
_L:GiveSignal(TM.ChildRemoved:Connect(OnTeamChange))

--// Modules Integration \\--
_L.Modules["SaveManager"] = (function()
    local cloneref = (cloneref or clonereference or function(instance: any)
        return instance
    end)
    local clonefunction = (clonefunction or copyfunction or function(func) 
        return func 
    end)

    local HttpService: HttpService = cloneref(game:GetService("HttpService"))
    local isfolder, isfile, listfiles = isfolder, isfile, listfiles;

    local assert = function(condition, errorMessage) 
        if (not condition) then
            error(if errorMessage then errorMessage else "assert failed", 3)
        end
    end

    if typeof(clonefunction) == "function" then
        local isfolder_copy, isfile_copy, listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)
        local isfolder_success, isfolder_error = pcall(function()
            return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
        end)
        if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
            isfolder = function(folder) local success, data = pcall(isfolder_copy, folder) return (if success then data else false) end
            isfile = function(file) local success, data = pcall(isfile_copy, file) return (if success then data else false) end
            listfiles = function(folder) local success, data = pcall(listfiles_copy, folder) return (if success then data else {}) end
        end
    end

    local SaveManager = {} do
        SaveManager.Folder = "LinoriaLibSettings"
        SaveManager.SubFolder = ""
        SaveManager.Ignore = {}
        SaveManager.Library = nil
        SaveManager.UseLoadingOrder = false
        SaveManager.LoadingOrder = {}
        SaveManager.Parser = {
            Toggle = {
                Save = function(idx, object) return { type = 'Toggle', idx = idx, value = object.Value } end,
                Load = function(idx, data)
                    local object = SaveManager.Library.Toggles[idx]
                    if object and object.Value ~= data.value then object:SetValue(data.value) end
                end,
            },
            Slider = {
                Save = function(idx, object) return { type = 'Slider', idx = idx, value = tostring(object.Value) } end,
                Load = function(idx, data)
                    local object = SaveManager.Library.Options[idx]
                    if object and object.Value ~= data.value then object:SetValue(data.value) end
                end,
            },
            Dropdown = {
                Save = function(idx, object) return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi } end,
                Load = function(idx, data)
                    local object = SaveManager.Library.Options[idx]
                    if object and object.Value ~= data.value then object:SetValue(data.value) end
                end,
            },
            ColorPicker = {
                Save = function(idx, object) return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency } end,
                Load = function(idx, data)
                    if SaveManager.Library.Options[idx] then SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency) end
                end,
            },
            KeyPicker = {
                Save = function(idx, object) return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers } end,
                Load = function(idx, data)
                    if SaveManager.Library.Options[idx] then SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode, data.modifiers }) end
                end,
            },
            Input = {
                Save = function(idx, object) return { type = 'Input', idx = idx, text = object.Value } end,
                Load = function(idx, data)
                    local object = SaveManager.Library.Options[idx]
                    if object and object.Value ~= data.text and type(data.text) == 'string' then SaveManager.Library.Options[idx]:SetValue(data.text) end
                end,
            },
        }
        function SaveManager:SetLibrary(library) self.Library = library end
        function SaveManager:SetLoadingOrder(enabled, order) self.UseLoadingOrder = enabled; if typeof(order) == "table" then self.LoadingOrder = order end end
        function SaveManager:IgnoreThemeSettings() self:SetIgnoreIndexes({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', "VideoLink" }) end
        function SaveManager:CheckSubFolder(createFolder)
            if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end
            if createFolder == true then if not isfolder(self.Folder .. "/settings/" .. self.SubFolder) then makefolder(self.Folder .. "/settings/" .. self.SubFolder) end end
            return true
        end
        function SaveManager:GetPaths()
            local paths = {}; local parts = self.Folder:split('/')
            for idx = 1, #parts do local path = table.concat(parts, '/', 1, idx); if not table.find(paths, path) then paths[#paths + 1] = path end end
            paths[#paths + 1] = self.Folder .. '/themes'; paths[#paths + 1] = self.Folder .. '/settings'
            if self:CheckSubFolder(false) then
                local subFolder = self.Folder .. "/settings/" .. self.SubFolder; parts = subFolder:split('/')
                for idx = 1, #parts do local path = table.concat(parts, '/', 1, idx); if not table.find(paths, path) then paths[#paths + 1] = path end end
            end
            return paths
        end
        function SaveManager:BuildFolderTree() local paths = self:GetPaths(); for i = 1, #paths do local str = paths[i]; if isfolder(str) then continue end; makefolder(str) end end
        function SaveManager:CheckFolderTree() if isfolder(self.Folder) then return end; SaveManager:BuildFolderTree(); task.wait(0.1) end
        function SaveManager:SetIgnoreIndexes(list) for _, key in next, list do self.Ignore[key] = true end end
        function SaveManager:SetFolder(folder) self.Folder = folder; self:BuildFolderTree() end
        function SaveManager:SetSubFolder(folder) self.SubFolder = folder; self:BuildFolderTree() end
        function SaveManager:Save(name)
            if (not name) then return false, 'no config file is selected' end
            SaveManager:CheckFolderTree()
            local fullPath = self.Folder .. '/settings/' .. name .. '.json'
            if SaveManager:CheckSubFolder(true) then fullPath = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. '.json' end
            local data = { objects = {} }
            for idx, toggle in next, self.Library.Toggles do if not toggle.Type then continue end; if not self.Parser[toggle.Type] then continue end; if self.Ignore[idx] then continue end; table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle)) end
            for idx, option in next, self.Library.Options do if not option.Type then continue end; if not self.Parser[option.Type] then continue end; if self.Ignore[idx] then continue end; table.insert(data.objects, self.Parser[option.Type].Save(idx, option)) end
            local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
            if not success then return false, 'failed to encode data' end
            writefile(fullPath, encoded); return true
        end
        function SaveManager:Load(name)
            if (not name) then return false, 'no config file is selected' end
            SaveManager:CheckFolderTree()
            local file = self.Folder .. '/settings/' .. name .. '.json'
            if SaveManager:CheckSubFolder(true) then file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. '.json' end
            if not isfile(file) then return false, 'invalid file' end
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
            if not success then return false, 'decode error' end
            if self.UseLoadingOrder == true and typeof(self.LoadingOrder) == "table" then table.sort(decoded.objects, function(a, b) local aIndex = table.find(self.LoadingOrder, a.type) or math.huge; local bIndex = table.find(self.LoadingOrder, b.type) or math.huge; return aIndex < bIndex end) end
            for _, option in decoded.objects do if not option.type then continue end; if not self.Parser[option.type] then continue end; if self.Ignore[option.idx] then continue end; task.spawn(self.Parser[option.type].Load, option.idx, option) end
            return true
        end
        function SaveManager:Delete(name)
            if (not name) then return false, 'no config file is selected' end
            local file = self.Folder .. '/settings/' .. name .. '.json'
            if SaveManager:CheckSubFolder(true) then file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. '.json' end
            if not isfile(file) then return false, 'invalid file' end
            local success = pcall(delfile, file); if not success then return false, 'delete file error' end
            return true
        end
        function SaveManager:RefreshConfigList()
            local success, data = pcall(function()
                SaveManager:CheckFolderTree(); local list = {}; local out = {}
                if SaveManager:CheckSubFolder(true) then list = listfiles(self.Folder .. "/settings/" .. self.SubFolder) else list = listfiles(self.Folder .. "/settings") end
                if typeof(list) ~= "table" then list = {} end
                for i = 1, #list do
                    local file = list[i]
                    if file:sub(-5) == '.json' then
                        local pos = file:find('.json', 1, true); local start = pos; local char = file:sub(pos, pos)
                        while char ~= '/' and char ~= '\\' and char ~= '' do pos = pos - 1; char = file:sub(pos, pos) end
                        if char == '/' or char == '\\' then table.insert(out, file:sub(pos + 1, start - 1)) end
                    end
                end
                return out
            end)
            if (not success) then if self.Library then self.Library:Notify('Failed to load config list: ' .. tostring(data)) else warn('Failed to load config list: ' .. tostring(data)) end; return {} end
            return data
        end
        function SaveManager:GetAutoloadConfig()
            SaveManager:CheckFolderTree(); local autoLoadPath = self.Folder .. "/settings/autoload.txt"
            if SaveManager:CheckSubFolder(true) then autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt" end
            if isfile(autoLoadPath) then local successRead, name = pcall(readfile, autoLoadPath); if not successRead then return "none" end; name = tostring(name); return if name == "" then "none" else name end
            return "none"
        end
        function SaveManager:LoadAutoloadConfig()
            SaveManager:CheckFolderTree(); local autoLoadPath = self.Folder .. "/settings/autoload.txt"
            if SaveManager:CheckSubFolder(true) then autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt" end
            if isfile(autoLoadPath) then
                local successRead, name = pcall(readfile, autoLoadPath)
                if not successRead then self.Library:Notify('Failed to load autoload config: write file error'); return end
                local success, err = self:Load(name)
                if not success then self.Library:Notify('Failed to load autoload config: ' .. err); return end
                self.Library:Notify(string.format('Auto loaded config %q', name))
            end
        end
        function SaveManager:SaveAutoloadConfig(name)
            SaveManager:CheckFolderTree(); local autoLoadPath = self.Folder .. "/settings/autoload.txt"
            if SaveManager:CheckSubFolder(true) then autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt" end
            local success = pcall(writefile, autoLoadPath, name); if not success then return false, 'write file error' end
            return true, ""
        end
        function SaveManager:DeleteAutoLoadConfig()
            SaveManager:CheckFolderTree(); local autoLoadPath = self.Folder .. "/settings/autoload.txt"
            if SaveManager:CheckSubFolder(true) then autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt" end
            local success = pcall(delfile, autoLoadPath); if not success then return false, 'delete file error' end
            return true, ""
        end
        function SaveManager:BuildConfigSection(tab)
            assert(self.Library, 'SaveManager:BuildConfigSection -> Must set SaveManager.Library'); local section = tab:AddRightGroupbox('Configuration')
            section:AddInput('SaveManager_ConfigName', { Text = 'Config name' })
            section:AddButton('Create config', function()
                local name = self.Library.Options.SaveManager_ConfigName.Value
                if name:gsub(' ', '') == '' then self.Library:Notify('Invalid config name (empty)', 2); return end
                local success, err = self:Save(name)
                if not success then self.Library:Notify('Failed to create config: ' .. err); return end
                self.Library:Notify(string.format('Created config %q', name))
                self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList()); self.Library.Options.SaveManager_ConfigList:SetValue(nil)
            end)
            section:AddDivider()
            section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })
            section:AddButton('Load config', function()
                local name = self.Library.Options.SaveManager_ConfigList.Value; local success, err = self:Load(name)
                if not success then self.Library:Notify('Failed to load config: ' .. err); return end
                self.Library:Notify(string.format('Loaded config %q', name))
            end)
            section:AddButton('Overwrite config', function()
                local name = self.Library.Options.SaveManager_ConfigList.Value; local success, err = self:Save(name)
                if not success then self.Library:Notify('Failed to overwrite config: ' .. err); return end
                self.Library:Notify(string.format('Overwrote config %q', name))
            end)
            section:AddButton('Delete config', function()
                local name = self.Library.Options.SaveManager_ConfigList.Value; local success, err = self:Delete(name)
                if not success then self.Library:Notify('Failed to delete config: ' .. err); return end
                self.Library:Notify(string.format('Deleted config %q', name))
                self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList()); self.Library.Options.SaveManager_ConfigList:SetValue(nil)
            end)
            section:AddButton('Refresh list', function() self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList()); self.Library.Options.SaveManager_ConfigList:SetValue(nil) end)
            section:AddButton('Set as autoload', function()
                local name = self.Library.Options.SaveManager_ConfigList.Value; local success, err = self:SaveAutoloadConfig(name)
                if not success then self.Library:Notify('Failed to set autoload config: ' .. err); return end
                self.Library:Notify(string.format('Set %q to auto load', name)); self.AutoloadConfigLabel:SetText('Current autoload config: ' .. name)
            end)
            section:AddButton('Reset autoload', function()
                local success, err = self:DeleteAutoLoadConfig()
                if not success then self.Library:Notify('Failed to set autoload config: ' .. err); return end
                self.Library:Notify('Set autoload to none'); self.AutoloadConfigLabel:SetText('Current autoload config: none')
            end)
            self.AutoloadConfigLabel = section:AddLabel("Current autoload config: " .. self:GetAutoloadConfig(), true)
            self:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
        end
        SaveManager:BuildFolderTree()
    end
    return SaveManager
end)()

_L.Modules["ThemeManager"] = (function()
    local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
    local clonefunction = (clonefunction or copyfunction or function(func) return func end)
    local httprequest = request or http_request or (http and http.request)
    local getassetfunc = getcustomasset
    local HttpService: HttpService = cloneref(game:GetService("HttpService"))
    local isfolder, isfile, listfiles = isfolder, isfile, listfiles;
    local assert = function(condition, errorMessage) if (not condition) then error(if errorMessage then errorMessage else "assert failed", 3) end end
    if typeof(clonefunction) == "function" then
        local isfolder_copy, isfile_copy, listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)
        local isfolder_success, isfolder_error = pcall(function() return isfolder_copy("test" .. tostring(math.random(1000000, 9999999))) end)
        if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
            isfolder = function(folder) local success, data = pcall(isfolder_copy, folder) return (if success then data else false) end
            isfile = function(file) local success, data = pcall(isfile_copy, file) return (if success then data else false) end
            listfiles = function(folder) local success, data = pcall(listfiles_copy, folder) return (if success then data else {}) end
        end
    end

    local ThemeManager = {} do
        local ThemeFields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor", "VideoLink", "GlowColor", "GlowThickness", "GlowTransparency" }
        ThemeManager.Folder = "LinoriaLibSettings"
        ThemeManager.Library = nil
        ThemeManager.BuiltInThemes = {
            ['Default']       = { 1, { FontColor = "ffffff", MainColor = "1c1c1c", AccentColor = "0055ff", BackgroundColor = "141414", OutlineColor = "323232", GlowColor = "dc0000", GlowThickness = 36, GlowTransparency = 25 } },
            ['BBot']          = { 2, { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414", GlowColor = "7e48a3", GlowThickness = 36, GlowTransparency = 25 } },
            ['Fatality']      = { 3, { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d", GlowColor = "c50754", GlowThickness = 36, GlowTransparency = 25 } },
            ['Jester']        = { 4, { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737", GlowColor = "db4467", GlowThickness = 36, GlowTransparency = 25 } },
            ['Mint']          = { 5, { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737", GlowColor = "3db488", GlowThickness = 36, GlowTransparency = 25 } },
            ['Tokyo Night']   = { 6, { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232", GlowColor = "6759b3", GlowThickness = 36, GlowTransparency = 25 } },
            ['Ubuntu']        = { 7, { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919", GlowColor = "e2581e", GlowThickness = 36, GlowTransparency = 25 } },
            ['Quartz']        = { 8, { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f", GlowColor = "426e87", GlowThickness = 36, GlowTransparency = 25 } },
        }
        function ApplyBackgroundVideo(videoLink)
            if typeof(videoLink) ~= "string" or not (getassetfunc and writefile and readfile and isfile) or not (ThemeManager.Library and ThemeManager.Library.InnerVideoBackground) then return; end;
            local videoInstance = ThemeManager.Library.InnerVideoBackground; local extension = videoLink:match(".*/(.-)?") or videoLink:match(".*/(.-)$"); extension = tostring(extension);
            local filename = string.sub(extension, 0, -6); local _, domain = videoLink:match("^(https?://)([^/]+)"); domain = tostring(domain);
            if videoLink == "" then videoInstance:Pause(); videoInstance.Video = ""; videoInstance.Visible = false; return end
            if #extension > 5 and string.sub(extension, -5) ~= ".webm" then return; end;
            local videoFile = ThemeManager.Folder .. "/themes/" .. string.gsub(domain .. filename, 0, 249) .. ".webm";
            if not isfile(videoFile) then local success, requestRes = pcall(httprequest, { Url = videoLink, Method = 'GET' }); if not (success and typeof(requestRes) == "table" and typeof(requestRes.Body) == "string") then return; end; writefile(videoFile, requestRes.Body) end
            videoInstance.Video = getassetfunc(videoFile); videoInstance.Visible = true; videoInstance:Play();
        end
        function ThemeManager:SetLibrary(library) self.Library = library end
        function ThemeManager:GetPaths() local paths = {}; local parts = self.Folder:split('/'); for idx = 1, #parts do paths[#paths + 1] = table.concat(parts, '/', 1, idx) end; paths[#paths + 1] = self.Folder .. '/themes'; return paths end
        function ThemeManager:BuildFolderTree() local paths = self:GetPaths(); for i = 1, #paths do local str = paths[i]; if isfolder(str) then continue end; makefolder(str) end end
        function ThemeManager:CheckFolderTree() if isfolder(self.Folder) then return end; self:BuildFolderTree(); task.wait(0.1) end
        function ThemeManager:SetFolder(folder) self.Folder = folder; self:BuildFolderTree() end
        function ThemeManager:ApplyTheme(theme)
            local customThemeData = self:GetCustomTheme(theme); local data = customThemeData or self.BuiltInThemes[theme]; if not data then return end
            if self.Library.InnerVideoBackground ~= nil then self.Library.InnerVideoBackground.Visible = false end
            local scheme = data[2]
            for idx, col in next, customThemeData or scheme do
                if idx == "VideoLink" then 
                    self.Library[idx] = col; 
                    if self.Library.Options[idx] then self.Library.Options[idx]:SetValue(col) end; 
                    ApplyBackgroundVideo(col)
                elseif idx == "GlowThickness" or idx == "GlowTransparency" then
                    local val = tonumber(col)
                    self.Library[idx] = val
                    if self.Library.Options[idx] then self.Library.Options[idx]:SetValue(val) end
                else 
                    self.Library[idx] = Color3.fromHex(col); 
                    if self.Library.Options[idx] then self.Library.Options[idx]:SetValueRGB(Color3.fromHex(col)) end 
                end
            end
            self:ThemeUpdate()
        end
        function ThemeManager:ThemeUpdate()
            if self.Library.InnerVideoBackground ~= nil then self.Library.InnerVideoBackground.Visible = false end
            for i, field in next, ThemeFields do 
                if self.Library.Options and self.Library.Options[field] then 
                    self.Library[field] = self.Library.Options[field].Value
                    if field == "VideoLink" then ApplyBackgroundVideo(self.Library.Options[field].Value) end 
                end 
            end
            self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor); self.Library:UpdateColorsUsingRegistry()

            if self.Library.Window and self.Library.Window.Glow then
                self.Library.Window.Glow:Update({
                    Color = self.Library.GlowColor,
                    Thickness = self.Library.GlowThickness,
                    Transparency = self.Library.GlowTransparency / 100
                })
            end
        end
        function ThemeManager:GetCustomTheme(file)
            local path = self.Folder .. '/themes/' .. file .. '.json'; if not isfile(path) then return nil end
            local data = readfile(path); local success, decoded = pcall(HttpService.JSONDecode, HttpService, data); if not success then return nil end
            return decoded
        end
        function ThemeManager:LoadDefault()
            local theme = 'Default'; local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')
            local isDefault = true
            if content then if self.BuiltInThemes[content] then theme = content elseif self:GetCustomTheme(content) then theme = content; isDefault = false; end elseif self.BuiltInThemes[self.DefaultTheme] then theme = self.DefaultTheme end
            if isDefault then self.Library.Options.ThemeManager_ThemeList:SetValue(theme) else self:ApplyTheme(theme) end
        end
        function ThemeManager:SaveDefault(theme) writefile(self.Folder .. '/themes/default.txt', theme) end
        function ThemeManager:SaveCustomTheme(file)
            if file:gsub(' ', '') == '' then self.Library:Notify('Invalid file name for theme (empty)', 3); return end
            local theme = {}
            for _, field in next, ThemeFields do 
                if field == "VideoLink" then 
                    theme[field] = self.Library.Options[field].Value 
                elseif field == "GlowThickness" or field == "GlowTransparency" then
                    theme[field] = self.Library.Options[field].Value
                else 
                    theme[field] = self.Library.Options[field].Value:ToHex() 
                end 
            end
            writefile(self.Folder .. '/themes/' .. file .. '.json', HttpService:JSONEncode(theme))
        end
        function ThemeManager:Delete(name)
            if (not name) then return false, 'no config file is selected' end
            local file = self.Folder .. '/themes/' .. name .. '.json'; if not isfile(file) then return false, 'invalid file' end
            local success = pcall(delfile, file); if not success then return false, 'delete file error' end; return true
        end
        function ThemeManager:ReloadCustomThemes()
            local list = listfiles(self.Folder .. '/themes'); local out = {}
            for i = 1, #list do local file = list[i]; if file:sub(-5) == '.json' then local pos = file:find('.json', 1, true); local start = pos; local char = file:sub(pos, pos)
                while char ~= '/' and char ~= '\\' and char ~= '' do pos = pos - 1; char = file:sub(pos, pos) end; if char == '/' or char == '\\' then table.insert(out, file:sub(pos + 1, start - 1)) end end end
            return out
        end
        function ThemeManager:CreateThemeManager(groupbox)
            groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
            groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
            groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
            groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
            groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });
            groupbox:AddDivider()
            groupbox:AddLabel('Glow color') :AddColorPicker('GlowColor', { Default = self.Library.GlowColor });
            groupbox:AddSlider('GlowThickness', { Text = 'Glow Thickness', Min = 0, Max = 100, Default = self.Library.GlowThickness, Rounding = 0 })
            groupbox:AddSlider('GlowTransparency', { Text = 'Glow Transparency', Min = 0, Max = 100, Default = self.Library.GlowTransparency, Rounding = 0 })
            groupbox:AddDivider()
            groupbox:AddInput('VideoLink', { Text = '.webm Video Background (Link)', Default = self.Library.VideoLink });
            local ThemesArray = {}; for Name, Theme in next, self.BuiltInThemes do table.insert(ThemesArray, Name) end
            table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)
            groupbox:AddDivider()
            groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })
            groupbox:AddButton('Set as default', function() self:SaveDefault(self.Library.Options.ThemeManager_ThemeList.Value); self.Library:Notify(string.format('Set default theme to %q', self.Library.Options.ThemeManager_ThemeList.Value)) end)
            self.Library.Options.ThemeManager_ThemeList:OnChanged(function() self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value) end)
            groupbox:AddDivider()
            groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
            groupbox:AddButton('Create theme', function() 
                local name = self.Library.Options.ThemeManager_CustomThemeName.Value; if name:gsub(" ", "") == "" then self.Library:Notify("Invalid theme name (empty)", 2); return end
                self:SaveCustomTheme(name); self.Library:Notify(string.format("Created theme %q", name)); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes()); self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end)
            groupbox:AddDivider()
            groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
            groupbox:AddButton('Load theme', function() local name = self.Library.Options.ThemeManager_CustomThemeList.Value; self:ApplyTheme(name); self.Library:Notify(string.format('Loaded theme %q', name)) end)
            groupbox:AddButton('Overwrite theme', function() local name = self.Library.Options.ThemeManager_CustomThemeList.Value; self:SaveCustomTheme(name); self.Library:Notify(string.format('Overwrote config %q', name)) end)
            groupbox:AddButton('Delete theme', function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value; local success, err = self:Delete(name)
                if not success then self.Library:Notify('Failed to delete theme: ' .. err); return end
                self.Library:Notify(string.format('Deleted theme %q', name)); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes()); self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end)
            groupbox:AddButton('Refresh list', function() self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes()); self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil) end)
            groupbox:AddButton('Set as default', function() if self.Library.Options.ThemeManager_CustomThemeList.Value ~= nil and self.Library.Options.ThemeManager_CustomThemeList.Value ~= '' then self:SaveDefault(self.Library.Options.ThemeManager_CustomThemeList.Value); self.Library:Notify(string.format('Set default theme to %q', self.Library.Options.ThemeManager_CustomThemeList.Value)) end end)
            groupbox:AddButton('Reset default', function() local success = pcall(delfile, self.Folder .. '/themes/default.txt'); if not success then self.Library:Notify('Failed to reset default: delete file error'); return end; self.Library:Notify('Set default theme to nothing'); self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes()); self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil) end)
            self:LoadDefault()
            local function UpdateTheme() self:ThemeUpdate() end
            self.Library.Options.BackgroundColor:OnChanged(UpdateTheme); self.Library.Options.MainColor:OnChanged(UpdateTheme); self.Library.Options.AccentColor:OnChanged(UpdateTheme); self.Library.Options.OutlineColor:OnChanged(UpdateTheme); self.Library.Options.FontColor:OnChanged(UpdateTheme)
            self.Library.Options.GlowColor:OnChanged(UpdateTheme); self.Library.Options.GlowThickness:OnChanged(UpdateTheme); self.Library.Options.GlowTransparency:OnChanged(UpdateTheme)
        end
        function ThemeManager:CreateGroupBox(tab) assert(self.Library, 'ThemeManager:CreateGroupBox -> Must set ThemeManager.Library first!'); return tab:AddLeftGroupbox('Themes') end
        function ThemeManager:ApplyToTab(tab) assert(self.Library, 'ThemeManager:ApplyToTab -> Must set ThemeManager.Library first!'); local groupbox = self:CreateGroupBox(tab); self:CreateThemeManager(groupbox) end
        function ThemeManager:ApplyToGroupbox(groupbox) assert(self.Library, 'ThemeManager:ApplyToGroupbox -> Must set ThemeManager.Library first!'); self:CreateThemeManager(groupbox) end
        ThemeManager:BuildFolderTree()
    end
    return ThemeManager
end)()

_L.SaveManager = _L.Modules["SaveManager"]
_L.ThemeManager = _L.Modules["ThemeManager"]

--// Rainbow Handler \\--
local RainbowStep = 0
local Hue = 0

_L:GiveSignal(RS.RenderStepped:Connect(function(Delta)
    if _L.Unloaded then
        return
    end

    RainbowStep = RainbowStep + Delta
    if RainbowStep >= (1 / 60) then
        RainbowStep = 0

        Hue = Hue + (1 / 400)

        if Hue > 1 then
            Hue = 0
        end

        _L.CurrentRainbowHue = Hue
        _L.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1)
    end
end))

_g[_regG("\x4c\x69\x62\x72\x61\x72\x79")] = _L
_g[_regG("\x4c\x69\x6e\x6f\x72\x69\x61")] = _L

return _L

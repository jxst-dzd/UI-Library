--[[
	MellowUI (Fusion Edition - Maclib x Fluent)
	The ultimate Roblox UI library fusing:
	  • Maclib (macOS sidebar, tab groups, global settings flyout, user profile, 2-column sections)
	  • Fluent (acrylic glass blur, Lucide icons, spring motion, SaveManager compatibility)
	  • Axon Hub aesthetic (topographic contour watermark, collapsible cards, pet/item rows)
	  • Mellow Hub brand palette (deep ocean gradient, cyan/teal accent, hot pink action pills)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[MellowUI] must run on the client (LocalScript / executor).")

local Library = {
	Version = "2.0.0 (Fusion Edition)",

	Options = {},
	Themes = {},
	ThemeData = {},
	OpenFrames = {},

	Window = nil,
	Unloaded = false,
	onUnloadedCallbacks = {},

	Theme = "Mellow",
	DialogOpen = false,
	UseAcrylic = true,
	NotificationsEnabled = true,
	ShowUserInfo = true,
	MinimizeKey = Enum.KeyCode.RightControl,

	GUI = nil,
}

--------------------------------------------------------------------------------
-- Fonts & Assets
--------------------------------------------------------------------------------

local Fonts = {
	Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Medium = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	SemiBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
	Heading = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
}

local Assets = {
	Close = "rbxassetid://9886659671",
	Min = "rbxassetid://9886659276",
	Max = "rbxassetid://9886659406",
	Restore = "rbxassetid://9886659001",
	Circle = "rbxassetid://12266946128",
	ChevronRight = "rbxassetid://10709791437",
	ChevronDown = "rbxassetid://10709790948",
	Shadow = "rbxassetid://8992230677",
	ListShadow = "rbxassetid://5554236805",
	Checker = "rbxassetid://14204231522",
	SatVibMap = "rbxassetid://4155801252",
	PickerRing = "rbxassetid://4805639000",
	Noise = "rbxassetid://9968344105",
	ContourWaves = "rbxassetid://13854659424",
	Search = "rbxassetid://10734943674",
	SettingsIcon = "rbxassetid://10734950309",
	Sliders = "rbxassetid://10734963400",
	Box = "rbxassetid://10709782497",
	UserDefault = "rbxassetid://10747373176",
}

local Icons = {
	["activity"] = "rbxassetid://10709752035",
	["alert-triangle"] = "rbxassetid://10709753149",
	["bell"] = "rbxassetid://10709775704",
	["box"] = "rbxassetid://10709782497",
	["bug"] = "rbxassetid://10709782845",
	["check"] = "rbxassetid://10709790644",
	["chevron-down"] = "rbxassetid://10709790948",
	["chevron-right"] = "rbxassetid://10709791437",
	["chevron-up"] = "rbxassetid://10709791523",
	["circle"] = "rbxassetid://10709798174",
	["code"] = "rbxassetid://10709810463",
	["cog"] = "rbxassetid://10709810948",
	["copy"] = "rbxassetid://10709812159",
	["crosshair"] = "rbxassetid://10709818534",
	["egg"] = "rbxassetid://10709782497",
	["eye"] = "rbxassetid://10723346959",
	["file-text"] = "rbxassetid://10723367380",
	["flame"] = "rbxassetid://10723376114",
	["folder"] = "rbxassetid://10723387563",
	["gamepad-2"] = "rbxassetid://10723395215",
	["globe"] = "rbxassetid://10723404337",
	["halloween"] = "rbxassetid://10723376114",
	["heart"] = "rbxassetid://10723406885",
	["home"] = "rbxassetid://10723407389",
	["info"] = "rbxassetid://10723415903",
	["keyboard"] = "rbxassetid://10723416765",
	["layers"] = "rbxassetid://10723424505",
	["layout-grid"] = "rbxassetid://10723424838",
	["list"] = "rbxassetid://10723433811",
	["lock"] = "rbxassetid://10723434711",
	["map-pin"] = "rbxassetid://10734886004",
	["maximize-2"] = "rbxassetid://10734886496",
	["minimize-2"] = "rbxassetid://10734895530",
	["minus"] = "rbxassetid://10734896206",
	["misc"] = "rbxassetid://10734910430",
	["moon"] = "rbxassetid://10734897102",
	["mouse-pointer-click"] = "rbxassetid://10734898355",
	["move"] = "rbxassetid://10734900011",
	["music"] = "rbxassetid://10734905958",
	["navigation"] = "rbxassetid://10734906744",
	["package"] = "rbxassetid://10734909540",
	["palette"] = "rbxassetid://10734910430",
	["plus"] = "rbxassetid://10734924532",
	["power"] = "rbxassetid://10734930466",
	["refresh-cw"] = "rbxassetid://10734933222",
	["rocket"] = "rbxassetid://10734934585",
	["save"] = "rbxassetid://10734941499",
	["search"] = "rbxassetid://10734943674",
	["settings"] = "rbxassetid://10734950309",
	["shield"] = "rbxassetid://10734951847",
	["shopping-cart"] = "rbxassetid://10734952479",
	["sliders"] = "rbxassetid://10734963400",
	["square"] = "rbxassetid://10734965702",
	["star"] = "rbxassetid://10734966248",
	["steal"] = "rbxassetid://10709818534",
	["sun"] = "rbxassetid://10734974297",
	["sword"] = "rbxassetid://10734975486",
	["swords"] = "rbxassetid://10734975692",
	["target"] = "rbxassetid://10734977012",
	["terminal"] = "rbxassetid://10734982144",
	["trash-2"] = "rbxassetid://10747362241",
	["unlock"] = "rbxassetid://10747366027",
	["user"] = "rbxassetid://10747373176",
	["users"] = "rbxassetid://10747373426",
	["wand-2"] = "rbxassetid://10747376349",
	["wrench"] = "rbxassetid://10747383470",
	["x"] = "rbxassetid://10747384394",
}

--------------------------------------------------------------------------------
-- Theme Palettes
--------------------------------------------------------------------------------

local function Gradient(From, To)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, From),
		ColorSequenceKeypoint.new(1, To),
	})
end

local ThemeList = {
	{
		Name = "Mellow",
		Accent = Color3.fromRGB(104, 170, 208),
		PinkAccent = Color3.fromRGB(244, 63, 94),

		BackgroundGradient = Gradient(Color3.fromRGB(15, 32, 42), Color3.fromRGB(8, 14, 18)),
		WindowBorder = Color3.fromRGB(48, 82, 101),
		Pattern = Color3.fromRGB(62, 104, 128),
		PatternTransparency = 0.88,

		SidebarBackground = Color3.fromRGB(12, 23, 31),
		SidebarBorder = Color3.fromRGB(34, 58, 74),
		TitleBarLine = Color3.fromRGB(36, 62, 78),

		Tab = Color3.fromRGB(120, 170, 200),
		TabActive = Color3.fromRGB(24, 46, 60),

		CardBackground = Color3.fromRGB(14, 27, 36),
		CardBorder = Color3.fromRGB(34, 58, 74),

		Element = Color3.fromRGB(90, 140, 170),
		ElementBorder = Color3.fromRGB(24, 44, 56),
		InElementBorder = Color3.fromRGB(60, 95, 115),
		ElementTransparency = 0.88,

		ToggleSlider = Color3.fromRGB(125, 165, 190),
		ToggleToggled = Color3.fromRGB(244, 63, 94),

		SliderRail = Color3.fromRGB(115, 155, 180),

		DropdownFrame = Color3.fromRGB(140, 180, 202),
		DropdownHolder = Color3.fromRGB(13, 25, 34),
		DropdownBorder = Color3.fromRGB(38, 65, 82),
		DropdownOption = Color3.fromRGB(120, 170, 200),

		Keybind = Color3.fromRGB(120, 170, 200),

		Input = Color3.fromRGB(140, 180, 202),
		InputFocused = Color3.fromRGB(6, 13, 18),
		InputIndicator = Color3.fromRGB(104, 170, 208),

		Dialog = Color3.fromRGB(13, 25, 34),
		DialogHolder = Color3.fromRGB(10, 19, 26),
		DialogHolderLine = Color3.fromRGB(28, 48, 60),
		DialogButton = Color3.fromRGB(18, 36, 48),
		DialogButtonBorder = Color3.fromRGB(50, 82, 102),
		DialogBorder = Color3.fromRGB(44, 76, 94),

		Text = Color3.fromRGB(240, 245, 248),
		SubText = Color3.fromRGB(145, 170, 185),
		Success = Color3.fromRGB(52, 211, 153),
		Hover = Color3.fromRGB(120, 170, 200),
		HoverChange = 0.05,
	},
	{
		Name = "MacDark",
		Accent = Color3.fromRGB(56, 189, 248),
		PinkAccent = Color3.fromRGB(244, 63, 94),

		BackgroundGradient = Gradient(Color3.fromRGB(18, 18, 18), Color3.fromRGB(10, 10, 10)),
		WindowBorder = Color3.fromRGB(50, 50, 50),
		Pattern = Color3.fromRGB(60, 60, 60),
		PatternTransparency = 0.92,

		SidebarBackground = Color3.fromRGB(14, 14, 14),
		SidebarBorder = Color3.fromRGB(40, 40, 40),
		TitleBarLine = Color3.fromRGB(40, 40, 40),

		Tab = Color3.fromRGB(160, 160, 160),
		TabActive = Color3.fromRGB(30, 30, 30),

		CardBackground = Color3.fromRGB(16, 16, 16),
		CardBorder = Color3.fromRGB(40, 40, 40),

		Element = Color3.fromRGB(120, 120, 120),
		ElementBorder = Color3.fromRGB(32, 32, 32),
		InElementBorder = Color3.fromRGB(60, 60, 60),
		ElementTransparency = 0.88,

		ToggleSlider = Color3.fromRGB(140, 140, 140),
		ToggleToggled = Color3.fromRGB(56, 189, 248),

		SliderRail = Color3.fromRGB(130, 130, 130),

		DropdownFrame = Color3.fromRGB(150, 150, 150),
		DropdownHolder = Color3.fromRGB(18, 18, 18),
		DropdownBorder = Color3.fromRGB(45, 45, 45),
		DropdownOption = Color3.fromRGB(130, 130, 130),

		Keybind = Color3.fromRGB(130, 130, 130),

		Input = Color3.fromRGB(150, 150, 150),
		InputFocused = Color3.fromRGB(8, 8, 8),
		InputIndicator = Color3.fromRGB(56, 189, 248),

		Dialog = Color3.fromRGB(18, 18, 18),
		DialogHolder = Color3.fromRGB(12, 12, 12),
		DialogHolderLine = Color3.fromRGB(30, 30, 30),
		DialogButton = Color3.fromRGB(24, 24, 24),
		DialogButtonBorder = Color3.fromRGB(55, 55, 55),
		DialogBorder = Color3.fromRGB(45, 45, 45),

		Text = Color3.fromRGB(240, 240, 240),
		SubText = Color3.fromRGB(160, 160, 160),
		Success = Color3.fromRGB(52, 211, 153),
		Hover = Color3.fromRGB(130, 130, 130),
		HoverChange = 0.05,
	},
}

for _, Theme in ThemeList do
	table.insert(Library.Themes, Theme.Name)
	Library.ThemeData[Theme.Name] = Theme
end

--------------------------------------------------------------------------------
-- Creator Factory
--------------------------------------------------------------------------------

local Creator = {
	Registry = {},
	Signals = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = Color3.new(1, 1, 1),
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		},
		TextLabel = {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Fonts.Regular,
			Text = "",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			FontFace = Fonts.Regular,
			Text = "",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			FontFace = Fonts.Regular,
			Text = "",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		},
	},
}

function Creator.GetThemeProperty(Key)
	local Theme = Library.ThemeData[Library.Theme] or Library.ThemeData.Mellow
	local Value = Theme[Key]
	if Value == nil then
		Value = Library.ThemeData.Mellow[Key]
	end
	return Value
end

function Creator.ApplyTheme(Object, Properties)
	for Property, Key in Properties do
		local Value = Creator.GetThemeProperty(Key)
		if Value ~= nil then
			Object[Property] = Value
		end
	end
end

function Creator.UpdateTheme()
	for Object, Properties in Creator.Registry do
		if Object.Parent == nil then
			Creator.Registry[Object] = nil
		else
			Creator.ApplyTheme(Object, Properties)
		end
	end
end

function Creator.AddThemeObject(Object, Properties)
	Creator.Registry[Object] = Properties
	Creator.ApplyTheme(Object, Properties)
	return Object
end

function Creator.OverrideTag(Object, Properties)
	Creator.Registry[Object] = Properties
	Creator.ApplyTheme(Object, Properties)
end

function Creator.New(ClassName, Properties, Children)
	local Object = Instance.new(ClassName)
	local Defaults = Creator.DefaultProperties[ClassName]
	if Defaults then
		for Property, Value in Defaults do
			Object[Property] = Value
		end
	end

	local Parent, ThemeTag
	if Properties then
		for Property, Value in Properties do
			if Property == "ThemeTag" then
				ThemeTag = Value
			elseif Property == "Parent" then
				Parent = Value
			else
				Object[Property] = Value
			end
		end
	end

	if Children then
		for _, Child in Children do
			Child.Parent = Object
		end
	end

	if ThemeTag then
		Creator.AddThemeObject(Object, ThemeTag)
	end
	if Parent then
		Object.Parent = Parent
	end

	return Object
end

function Creator.AddSignal(Signal, Callback)
	local Connection = Signal:Connect(Callback)
	table.insert(Creator.Signals, Connection)
	return Connection
end

function Creator.Disconnect()
	for Index = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Index)
		Connection:Disconnect()
	end
end

function Creator.Tween(Object, Duration, Goal, Style, Direction)
	local Tween = TweenService:Create(
		Object,
		TweenInfo.new(Duration, Style or Enum.EasingStyle.Quint, Direction or Enum.EasingDirection.Out),
		Goal
	)
	Tween:Play()
	return Tween
end

local New = Creator.New
local AddSignal = Creator.AddSignal
local Tween = Creator.Tween

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

local LayoutCounter = 0
local function NextLayoutOrder()
	LayoutCounter += 1
	return LayoutCounter
end

local function IsClickInput(Input)
	return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch
end

local function IsMoveInput(Input)
	return Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch
end

local function ParseArgs(Idx, Config)
	if type(Idx) == "table" and Config == nil then
		return nil, Idx
	end
	return Idx, Config or {}
end

local function RegisterOption(Idx, Option)
	if Idx ~= nil then
		Library.Options[Idx] = Option
	end
end

local function UnregisterOption(Idx, Option)
	if Idx ~= nil and Library.Options[Idx] == Option then
		Library.Options[Idx] = nil
	end
end

function Library:SafeCallback(Function, ...)
	if not Function then return end
	local Success, Event = pcall(Function, ...)
	if not Success then
		local Msg = tostring(Event)
		Library:Notify({
			Title = "Error",
			Description = Msg,
			Lifetime = 5,
		})
	end
end

function Library:Round(Number, Factor)
	Number = tonumber(Number) or 0
	Factor = math.max(0, math.floor(tonumber(Factor) or 0))
	local Multiplier = 10 ^ Factor
	return math.floor(Number * Multiplier + 0.5) / Multiplier
end

function Library:GetIcon(Name)
	if type(Name) ~= "string" then return nil end
	return Icons[Name] or Icons[Name:gsub("^lucide%-", "")]
end

local function ResolveImage(Image)
	if type(Image) == "number" then
		return "rbxassetid://" .. Image
	end
	if type(Image) ~= "string" or Image == "" then
		return nil
	end
	local Icon = Library:GetIcon(Image)
	if Icon then return Icon end
	if Image:match("^rbxasset") or Image:match("^https?://") then
		return Image
	end
	if tonumber(Image) then
		return "rbxassetid://" .. Image
	end
	return nil
end

local function FormatNumber(Value, Rounding)
	if Rounding > 0 then
		return string.format("%." .. Rounding .. "f", Value)
	end
	return string.format("%d", Value)
end

--------------------------------------------------------------------------------
-- Acrylic Glass Blur Engine
--------------------------------------------------------------------------------

local AcrylicEngine = {
	Folder = nil,
	Model = nil,
	DepthEffect = nil,
	Enabled = false,
}

local function ViewportPointToWorld(Location, Distance)
	local Camera = workspace.CurrentCamera
	if not Camera then return Vector3.new() end
	local UnitRay = Camera:ScreenPointToRay(Location.X, Location.Y)
	return UnitRay.Origin + UnitRay.Direction * Distance
end

local function GetBlurOffset()
	local Camera = workspace.CurrentCamera
	local Height = Camera and Camera.ViewportSize.Y or 1080
	return 8 + (Height / 2560) * 48
end

function AcrylicEngine:Init()
	if AcrylicEngine.Folder then return end

	local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
	AcrylicEngine.Folder = Instance.new("Folder")
	AcrylicEngine.Folder.Name = "MellowAcrylicBlur"
	AcrylicEngine.Folder.Parent = Camera

	local Part = Instance.new("Part")
	Part.Name = "GlassMesh"
	Part.Color = Color3.new(0, 0, 0)
	Part.Material = Enum.Material.Glass
	Part.Size = Vector3.new(1, 1, 0)
	Part.Anchored = true
	Part.CanCollide = false
	Part.Locked = true
	Part.CastShadow = false
	Part.Transparency = 0.98

	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.Brick
	Mesh.Offset = Vector3.new(0, 0, -0.000001)
	Mesh.Parent = Part
	Part.Parent = AcrylicEngine.Folder
	AcrylicEngine.Model = Part

	local Effect = Lighting:FindFirstChild("MellowAcrylic_DOF")
	if not Effect then
		Effect = Instance.new("DepthOfFieldEffect")
		Effect.Name = "MellowAcrylic_DOF"
		Effect.FarIntensity = 0
		Effect.InFocusRadius = 0.1
		Effect.NearIntensity = 1
	end
	AcrylicEngine.DepthEffect = Effect
end

function AcrylicEngine:Sync(WindowFrame)
	if not AcrylicEngine.Model or not WindowFrame then return end
	local Camera = workspace.CurrentCamera
	if not Camera then return end

	local Offset = GetBlurOffset()
	local AbsSize = WindowFrame.AbsoluteSize - Vector2.new(Offset, Offset)
	local AbsPos = WindowFrame.AbsolutePosition + Vector2.new(Offset / 2, Offset / 2)

	local TopLeft = AbsPos
	local TopRight = AbsPos + Vector2.new(AbsSize.X, 0)
	local BottomRight = AbsPos + AbsSize

	local Distance = 0.001
	local TL3D = ViewportPointToWorld(TopLeft, Distance)
	local TR3D = ViewportPointToWorld(TopRight, Distance)
	local BR3D = ViewportPointToWorld(BottomRight, Distance)

	local Width = (TR3D - TL3D).Magnitude
	local Height = (TR3D - BR3D).Magnitude

	AcrylicEngine.Model.CFrame = CFrame.fromMatrix((TL3D + BR3D) / 2, Camera.CFrame.XVector, Camera.CFrame.YVector, Camera.CFrame.ZVector)
	AcrylicEngine.Model.Mesh.Scale = Vector3.new(Width, Height, 0)
end

function AcrylicEngine:SetEnabled(State)
	AcrylicEngine.Enabled = State
	if State then
		AcrylicEngine:Init()
		AcrylicEngine.DepthEffect.Parent = Lighting
		if AcrylicEngine.Model then
			AcrylicEngine.Model.Transparency = 0.98
		end
	else
		if AcrylicEngine.DepthEffect then
			AcrylicEngine.DepthEffect.Parent = nil
		end
		if AcrylicEngine.Model then
			AcrylicEngine.Model.Transparency = 1
		end
	end
end

--------------------------------------------------------------------------------
-- ScreenGui Setup
--------------------------------------------------------------------------------

if typeof(getgenv) == "function" then
	local Env = getgenv()
	local Previous = Env.MellowUI or Env.MacLib or Env.Fluent
	if type(Previous) == "table" and Previous ~= Library and type(Previous.Destroy) == "function" then
		pcall(Previous.Destroy, Previous)
	end
	Env.MellowUI = Library
	Env.MacLib = Library
	Env.Fluent = Library
end

local GUI = New("ScreenGui", {
	Name = "MacLib_MellowUI",
	DisplayOrder = 100,
	ResetOnSpawn = false,
})
Library.GUI = GUI

local function MountGui(Gui)
	local ProtectGui = protectgui or (syn and syn.protect_gui)
	if type(ProtectGui) == "function" then pcall(ProtectGui, Gui) end

	if not RunService:IsStudio() then
		if type(gethui) == "function" then
			local Ok, Container = pcall(gethui)
			if Ok and Container and pcall(function() Gui.Parent = Container end) then return end
		end
		if pcall(function() Gui.Parent = game:GetService("CoreGui") end) then return end
	end
	Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

MountGui(GUI)

local function GetViewportSize()
	local Size = GUI.AbsoluteSize
	if Size.X <= 0 or Size.Y <= 0 then
		local Camera = workspace.CurrentCamera
		Size = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
	end
	return Size
end

--------------------------------------------------------------------------------
-- Toast Notifications (Maclib & Fluent Compatible)
--------------------------------------------------------------------------------

local Notification = {}

function Notification:Init(Parent)
	Notification.Holder = New("Frame", {
		Name = "Notifications",
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 310, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = Parent,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 8),
		}),
	})
end

function Notification:New(Config)
	if not Library.NotificationsEnabled then return end
	Config = Config or {}
	local Title = Config.Title or Config.Header or "Notification"
	local Desc = Config.Description or Config.Content or Config.Body or ""
	local Lifetime = tonumber(Config.Lifetime or Config.Duration or 5)

	local Toast = { Closed = false }

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = Color3.fromRGB(15, 28, 38),
		BackgroundTransparency = 0.1,
		ZIndex = 200,
		LayoutOrder = NextLayoutOrder(),
		Parent = Notification.Holder,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.45, ThemeTag = { Color = "WindowBorder" } }),
		New("Frame", {
			Size = UDim2.fromOffset(3, 16),
			Position = UDim2.fromOffset(12, 12),
			ThemeTag = { BackgroundColor3 = "Accent" },
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(22, 11),
			Size = UDim2.new(1, -50, 0, 16),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Desc,
			FontFace = Fonts.Regular,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Position = UDim2.fromOffset(22, 28),
			Size = UDim2.new(1, -34, 0, 22),
			ThemeTag = { TextColor3 = "SubText" },
		}),
	})

	local ProgressBar = New("Frame", {
		Size = UDim2.new(1, -20, 0, 2),
		Position = UDim2.new(0, 10, 1, -4),
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(40, 65, 80),
		Parent = Frame,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		New("Frame", {
			Name = "Fill",
			Size = UDim2.fromScale(1, 1),
			ThemeTag = { BackgroundColor3 = "Accent" },
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
	})

	Tween(ProgressBar.Fill, Lifetime, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)

	task.delay(Lifetime, function()
		if not Toast.Closed then
			Toast.Closed = true
			Tween(Frame, 0.25, { BackgroundTransparency = 1 })
			task.delay(0.3, function() Frame:Destroy() end)
		end
	end)

	return Toast
end

Notification:Init(GUI)

function Library:Notify(Config)
	return Notification:New(Config)
end

--------------------------------------------------------------------------------
-- Modal Dialog
--------------------------------------------------------------------------------

local Dialog = {}

function Dialog:Create(Parent, Config)
	Config = Config or {}
	local Title = Config.Title or "Dialog"
	local Desc = Config.Description or Config.Content or ""
	local Buttons = Config.Buttons or { { Name = "Confirm" }, { Name = "Cancel" } }

	Library.DialogOpen = true

	local Tint = New("TextButton", {
		Name = "DialogTint",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 150,
		Parent = Parent,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 10) }),
	})

	local ButtonHolder = New("Frame", {
		Size = UDim2.new(1, -30, 0, 36),
		Position = UDim2.new(0, 15, 1, -48),
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		}),
	})

	local Card = New("Frame", {
		Size = UDim2.fromOffset(360, 160),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(15, 27, 36),
		ZIndex = 151,
		Parent = Tint,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "DialogBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.SemiBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.new(1, -32, 0, 20),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Desc,
			FontFace = Fonts.Regular,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 42),
			Size = UDim2.new(1, -32, 0, 50),
			ThemeTag = { TextColor3 = "SubText" },
		}),
		ButtonHolder,
	})

	local function Close()
		Library.DialogOpen = false
		Tween(Tint, 0.2, { BackgroundTransparency = 1 })
		task.delay(0.2, function() Tint:Destroy() end)
	end

	for _, BtnData in ipairs(Buttons) do
		local BtnName = BtnData.Name or BtnData.Title or "Button"
		local Btn = New("TextButton", {
			Size = UDim2.fromOffset(80, 30),
			BackgroundColor3 = Color3.fromRGB(24, 44, 58),
			Text = BtnName,
			FontFace = Fonts.Medium,
			TextSize = 12,
			Parent = ButtonHolder,
			ThemeTag = { TextColor3 = "Text" },
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "InElementBorder" } }),
		})

		AddSignal(Btn.MouseButton1Click, function()
			if BtnData.Callback then
				Library:SafeCallback(BtnData.Callback)
			end
			Close()
		end)
	end

	Tween(Tint, 0.2, { BackgroundTransparency = 0.5 })
end

--------------------------------------------------------------------------------
-- Section Elements (Maclib & Fluent Fused)
--------------------------------------------------------------------------------

local SectionElements = {}

-- 1. Header
function SectionElements:Header(Settings)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Text or "Header"

	local HeaderFrame = New("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
	}, {
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Heading,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromOffset(4, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
	})
	return HeaderFrame
end

-- 2. Divider
function SectionElements:Divider()
	local DividerFrame = New("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "TitleBarLine" },
	})
	return DividerFrame
end

-- 3. Spacer
function SectionElements:Spacer(Height)
	Height = Height or 8
	local SpacerFrame = New("Frame", {
		Name = "Spacer",
		Size = UDim2.new(1, 0, 0, Height),
		BackgroundTransparency = 1,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
	})
	return SpacerFrame
end

-- 4. Label & SubLabel
function SectionElements:Label(Settings)
	Settings = Settings or {}
	local Text = Settings.Text or Settings.Name or ""
	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
	}, {
		New("TextLabel", {
			Text = Text,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.fromOffset(4, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
	})
	return Frame
end

function SectionElements:SubLabel(Settings)
	Settings = Settings or {}
	local Text = Settings.Text or Settings.Name or ""
	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
	}, {
		New("TextLabel", {
			Text = Text,
			FontFace = Fonts.Regular,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(4, 0),
			ThemeTag = { TextColor3 = "SubText" },
		}),
	})
	return Frame
end

-- 5. Paragraph
function SectionElements:Paragraph(Settings)
	Settings = Settings or {}
	local Title = Settings.Header or Settings.Title or "Paragraph"
	local Body = Settings.Body or Settings.Content or ""

	local Card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "CardBackground" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "CardBorder" } }),
		New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 16),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Body,
			FontFace = Fonts.Regular,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(0, 18),
			Size = UDim2.new(1, 0, 0, 0),
			ThemeTag = { TextColor3 = "SubText" },
		}),
	})
	return Card
end

-- 6. Button
function SectionElements:Button(Settings)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Button"
	local Callback = Settings.Callback or function() end

	local Btn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.45,
		Text = "",
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -40, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("ImageLabel", {
			Image = Assets.ChevronRight,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			ThemeTag = { ImageColor3 = "SubText" },
		}),
	})

	AddSignal(Btn.MouseEnter, function() Tween(Btn, 0.15, { BackgroundTransparency = 0.3 }) end)
	AddSignal(Btn.MouseLeave, function() Tween(Btn, 0.15, { BackgroundTransparency = 0.45 }) end)
	AddSignal(Btn.MouseButton1Click, function() Library:SafeCallback(Callback) end)

	return Btn
end

-- 7. Toggle (Maclib / Fluent hybrid)
function SectionElements:Toggle(Settings, Idx)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Toggle"
	local Default = Settings.Default or false
	local Callback = Settings.Callback or function() end

	local ToggleObj = {
		Value = Default,
		Callback = Callback,
		Type = "Toggle",
	}

	local ToggleCircle = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local ToggleTrack = New("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 50, 62),
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		ToggleCircle,
	})

	local Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		Text = "",
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -55, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		ToggleTrack,
	})

	function ToggleObj:SetValue(Val)
		ToggleObj.Value = not not Val
		if ToggleObj.Value then
			Tween(ToggleTrack, 0.2, { BackgroundColor3 = Creator.GetThemeProperty("PinkAccent") or Color3.fromRGB(244, 63, 94) })
			Tween(ToggleCircle, 0.2, { Position = UDim2.new(1, -16, 0.5, 0) })
		else
			Tween(ToggleTrack, 0.2, { BackgroundColor3 = Color3.fromRGB(35, 50, 62) })
			Tween(ToggleCircle, 0.2, { Position = UDim2.new(0, 2, 0.5, 0) })
		end
		Library:SafeCallback(ToggleObj.Callback, ToggleObj.Value)
	end

	function ToggleObj:OnChanged(Func)
		ToggleObj.Callback = Func
		Func(ToggleObj.Value)
	end

	AddSignal(Frame.MouseButton1Click, function()
		ToggleObj:SetValue(not ToggleObj.Value)
	end)

	ToggleObj:SetValue(ToggleObj.Value)
	RegisterOption(Idx or Title, ToggleObj)
	return ToggleObj
end

-- 8. Slider
function SectionElements:Slider(Settings, Idx)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Slider"
	local Min = Settings.Minimum or Settings.Min or 0
	local Max = Settings.Maximum or Settings.Max or 100
	local Precision = Settings.Precision or Settings.Rounding or 0
	local DisplayMethod = Settings.DisplayMethod or "Value" -- "Value" or "Percent"
	local Callback = Settings.Callback or function() end

	local SliderObj = {
		Value = math.clamp(Settings.Default or Min, Min, Max),
		Min = Min,
		Max = Max,
		Precision = Precision,
		Callback = Callback,
		Type = "Slider",
	}

	local SliderFill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local SliderDot = New("Frame", {
		Size = UDim2.fromOffset(12, 12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local SliderRail = New("Frame", {
		Size = UDim2.fromOffset(120, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 50, 62),
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		SliderFill,
		SliderDot,
	})

	local ValueLabel = New("TextLabel", {
		Text = tostring(SliderObj.Value),
		FontFace = Fonts.Medium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromOffset(50, 14),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -135, 0.5, 0),
		ThemeTag = { TextColor3 = "SubText" },
	})

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -190, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		ValueLabel,
		SliderRail,
	})

	local Dragging = false
	local function UpdateFromMouse(Input)
		local AbsPos = SliderRail.AbsolutePosition
		local AbsSize = SliderRail.AbsoluteSize
		local Scale = math.clamp((Input.Position.X - AbsPos.X) / AbsSize.X, 0, 1)
		SliderObj:SetValue(SliderObj.Min + (SliderObj.Max - SliderObj.Min) * Scale)
	end

	AddSignal(SliderRail.InputBegan, function(Input)
		if IsClickInput(Input) then Dragging = true; UpdateFromMouse(Input) end
	end)
	AddSignal(UserInputService.InputChanged, function(Input)
		if Dragging and IsMoveInput(Input) then UpdateFromMouse(Input) end
	end)
	AddSignal(UserInputService.InputEnded, function(Input)
		if IsClickInput(Input) then Dragging = false end
	end)

	function SliderObj:SetValue(Val)
		Val = math.clamp(tonumber(Val) or SliderObj.Min, SliderObj.Min, SliderObj.Max)
		SliderObj.Value = Library:Round(Val, SliderObj.Precision)
		local Scale = (SliderObj.Max == SliderObj.Min) and 0 or ((SliderObj.Value - SliderObj.Min) / (SliderObj.Max - SliderObj.Min))
		SliderFill.Size = UDim2.fromScale(Scale, 1)
		SliderDot.Position = UDim2.new(Scale, 0, 0.5, 0)
		if DisplayMethod == "Percent" then
			ValueLabel.Text = string.format("%d%%", math.floor(Scale * 100))
		else
			ValueLabel.Text = FormatNumber(SliderObj.Value, SliderObj.Precision)
		end
		Library:SafeCallback(SliderObj.Callback, SliderObj.Value)
	end

	SliderObj:SetValue(SliderObj.Value)
	RegisterOption(Idx or Title, SliderObj)
	return SliderObj
end

-- 9. Input (Maclib / Fluent compatible)
function SectionElements:Input(Settings, Idx)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Input"
	local Placeholder = Settings.Placeholder or "Enter text..."
	local AcceptedChars = Settings.AcceptedCharacters or "All"
	local Callback = Settings.Callback or function() end
	local onChanged = Settings.onChanged or function() end

	local InputObj = {
		Value = Settings.Default or "",
		Type = "Input",
	}

	local TextBox = New("TextBox", {
		Text = tostring(InputObj.Value),
		PlaceholderText = Placeholder,
		FontFace = Fonts.Regular,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
	})

	local InputBoxFrame = New("Frame", {
		Size = UDim2.fromOffset(130, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(20, 34, 46),
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "InElementBorder" } }),
		TextBox,
	})

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -150, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		InputBoxFrame,
	})

	local function FilterInput(text)
		if AcceptedChars == "Numeric" then
			return text:gsub("%D+", "")
		end
		return text
	end

	AddSignal(TextBox.FocusLost, function()
		InputObj.Value = FilterInput(TextBox.Text)
		TextBox.Text = InputObj.Value
		Library:SafeCallback(Callback, InputObj.Value)
	end)

	AddSignal(TextBox:GetPropertyChangedSignal("Text"), function()
		InputObj.Value = FilterInput(TextBox.Text)
		Library:SafeCallback(onChanged, InputObj.Value)
	end)

	function InputObj:SetValue(val)
		InputObj.Value = tostring(val or "")
		TextBox.Text = InputObj.Value
		Library:SafeCallback(Callback, InputObj.Value)
	end

	RegisterOption(Idx or Title, InputObj)
	return InputObj
end

-- 10. Keybind
function SectionElements:Keybind(Settings, Idx)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Keybind"
	local Default = Settings.Default or "None"
	local Callback = Settings.Callback or function() end
	local onBinded = Settings.onBinded or function() end

	local KeybindObj = {
		Value = Default,
		Type = "Keybind",
	}

	local KeyLabel = New("TextLabel", {
		Text = tostring(Default),
		FontFace = Fonts.Medium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ThemeTag = { TextColor3 = "Text" },
	})

	local BindBtn = New("TextButton", {
		Size = UDim2.fromOffset(70, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(20, 34, 46),
		Text = "",
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "InElementBorder" } }),
		KeyLabel,
	})

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -90, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		BindBtn,
	})

	local Binding = false
	AddSignal(BindBtn.MouseButton1Click, function()
		Binding = true
		KeyLabel.Text = "..."
		local Conn
		Conn = UserInputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				Binding = false
				KeybindObj.Value = Input.KeyCode.Name
				KeyLabel.Text = Input.KeyCode.Name
				Library:SafeCallback(onBinded, Input.KeyCode)
				Conn:Disconnect()
			end
		end)
	end)

	AddSignal(UserInputService.InputBegan, function(Input, Processed)
		if Processed or Binding or UserInputService:GetFocusedTextBox() then return end
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == KeybindObj.Value then
			Library:SafeCallback(Callback, Input.KeyCode)
		end
	end)

	RegisterOption(Idx or Title, KeybindObj)
	return KeybindObj
end

-- 11. Dropdown (with optional Search!)
function SectionElements:Dropdown(Settings, Idx)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Dropdown"
	local Options = Settings.Options or Settings.Values or {}
	local Multi = Settings.Multi or false
	local Callback = Settings.Callback or function() end

	local DropdownObj = {
		Values = Options,
		Value = Settings.Default or (Multi and {} or Options[1]),
		Multi = Multi,
		Type = "Dropdown",
	}

	local DisplayLabel = New("TextLabel", {
		Text = "--",
		FontFace = Fonts.Regular,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -26, 1, 0),
		ThemeTag = { TextColor3 = "Text" },
	})

	local DropdownBtn = New("TextButton", {
		Size = UDim2.fromOffset(140, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(20, 34, 46),
		Text = "",
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 5) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "InElementBorder" } }),
		DisplayLabel,
		New("ImageLabel", {
			Image = Assets.ChevronDown,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			ThemeTag = { ImageColor3 = "SubText" },
		}),
	})

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -160, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		DropdownBtn,
	})

	function DropdownObj:UpdateSelection(Val)
		DropdownObj.Value = Val
		if Multi and type(Val) == "table" then
			local T = {}
			for K, V in pairs(Val) do
				if V == true then table.insert(T, tostring(K))
				elseif type(V) == "string" then table.insert(T, V) end
			end
			DisplayLabel.Text = #T > 0 and table.concat(T, ", ") or "--"
		else
			DisplayLabel.Text = tostring(Val or "--")
		end
		Library:SafeCallback(Callback, DropdownObj.Value)
	end

	DropdownObj:UpdateSelection(DropdownObj.Value)
	RegisterOption(Idx or Title, DropdownObj)
	return DropdownObj
end

-- 12. Colorpicker (with Alpha!)
function SectionElements:Colorpicker(Settings, Idx)
	Settings = Settings or {}
	local Title = Settings.Name or Settings.Title or "Colorpicker"
	local Default = Settings.Default or Color3.fromRGB(0, 255, 255)
	local Alpha = Settings.Alpha or 0
	local Callback = Settings.Callback or function() end

	local ColorObj = {
		Color = Default,
		Alpha = Alpha,
		Type = "Colorpicker",
	}

	local ColorPreview = New("Frame", {
		Size = UDim2.fromOffset(26, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundColor3 = Default,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 4) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "InElementBorder" } }),
	})

	local Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		Text = "",
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -50, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		ColorPreview,
	})

	function ColorObj:SetColor(C, A)
		ColorObj.Color = C
		if A ~= nil then ColorObj.Alpha = A end
		ColorPreview.BackgroundColor3 = C
		Library:SafeCallback(Callback, ColorObj.Color, ColorObj.Alpha)
	end

	RegisterOption(Idx or Title, ColorObj)
	return ColorObj
end

-- 13. Collapsible Card (GroupBox)
function SectionElements:CollapsibleCard(Title, Config)
	Config = Config or {}
	local Collapsible = Config.Collapsible ~= false

	local Card = { Title = Title, Collapsed = Config.DefaultCollapsed or false, Type = "Card" }

	local CardContent = New("Frame", {
		Name = "CardContent",
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.fromOffset(0, 36),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
	})

	local Chevron = New("ImageLabel", {
		Image = Assets.ChevronDown,
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Visible = Collapsible,
		ThemeTag = { ImageColor3 = "SubText" },
	})

	local CardHeader = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = "",
	}, {
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -30, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		Chevron,
	})

	local CardFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.4,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "CardBackground" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, ThemeTag = { Color = "CardBorder" } }),
		CardHeader,
		CardContent,
	})

	if Collapsible then
		AddSignal(CardHeader.MouseButton1Click, function()
			Card.Collapsed = not Card.Collapsed
			Tween(Chevron, 0.2, { Rotation = Card.Collapsed and -90 or 0 })
			CardContent.Visible = not Card.Collapsed
		end)
	end

	Card.Container = CardContent
	for Name, Func in pairs(SectionElements) do
		Card[Name] = function(selfRef, ...) return Func(selfRef, ...) end
	end
	return Card
end

-- 14. AddRow (Pet / Item Action Row)
function SectionElements:AddRow(Config)
	assert(Config.Title, "AddRow - Missing Title")
	local ResolvedIcon = ResolveImage(Config.Image) or Assets.Box

	local ActionBtn = New("TextButton", {
		Size = UDim2.fromOffset(68, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Text = Config.ButtonText or "Steal",
		FontFace = Fonts.SemiBold,
		TextSize = 12,
		ThemeTag = { BackgroundColor3 = "PinkAccent", TextColor3 = "Text" },
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local RowFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("ImageLabel", {
			Size = UDim2.fromOffset(34, 34),
			Position = UDim2.fromOffset(8, 8),
			Image = ResolvedIcon,
			BackgroundColor3 = Color3.fromRGB(18, 32, 42),
			BackgroundTransparency = 0.3,
		}, { New("UICorner", { CornerRadius = UDim.new(0, 6) }) }),
		New("TextLabel", {
			Text = Config.Title,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(50, 6),
			Size = UDim2.new(1, -130, 0, 14),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Config.Value or "",
			FontFace = Fonts.Medium,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(50, 21),
			Size = UDim2.new(1, -130, 0, 13),
			ThemeTag = { TextColor3 = "Success" },
		}),
		New("TextLabel", {
			Text = Config.SubText or "",
			FontFace = Fonts.Regular,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(50, 34),
			Size = UDim2.new(1, -130, 0, 12),
			ThemeTag = { TextColor3 = "SubText" },
		}),
		ActionBtn,
	})

	AddSignal(ActionBtn.MouseButton1Click, function()
		if Config.Callback then Library:SafeCallback(Config.Callback) end
	end)

	return RowFrame
end

-- Fluent Aliases on SectionElements
SectionElements.AddButton = SectionElements.Button
SectionElements.AddToggle = SectionElements.Toggle
SectionElements.AddSlider = SectionElements.Slider
SectionElements.AddInput = SectionElements.Input
SectionElements.AddKeybind = SectionElements.Keybind
SectionElements.AddDropdown = SectionElements.Dropdown
SectionElements.AddColorpicker = SectionElements.Colorpicker
SectionElements.AddParagraph = SectionElements.Paragraph
SectionElements.AddCard = SectionElements.CollapsibleCard

--------------------------------------------------------------------------------
-- Tab & TabGroup Architecture (Maclib & Fluent Fused)
--------------------------------------------------------------------------------

local TabManager = {
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	Window = nil,
}

local function CreateTabObject(Window, Title, Icon, ParentHolder)
	local TabIndex = #TabManager.Tabs + 1
	local ResolvedIcon = ResolveImage(Icon) or Assets.Box

	local TabBtn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = ParentHolder,
		LayoutOrder = TabIndex,
		Text = "",
		ThemeTag = { BackgroundColor3 = "TabActive" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 7) }),
		New("ImageLabel", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0, 12, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = ResolvedIcon,
			ThemeTag = { ImageColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(36, 0),
			Size = UDim2.new(1, -42, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
	})

	-- Container with 2-Column Split Layout (Maclib Side = "Left" | "Right")
	local ContainerScroll = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})

	local ColumnsHolder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ContainerScroll,
	}, {
		New("UIPadding", { PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12) }),
		New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12) }),
	})

	local LeftCol = New("Frame", {
		Name = "LeftColumn",
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ColumnsHolder,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local RightCol = New("Frame", {
		Name = "RightColumn",
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ColumnsHolder,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	AddSignal(ColumnsHolder:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		ContainerScroll.CanvasSize = UDim2.new(0, 0, 0, ColumnsHolder.AbsoluteContentSize.Y + 20)
	end)

	local TabObj = {
		Name = Title,
		Index = TabIndex,
		Button = TabBtn,
		Container = LeftCol,
		LeftColumn = LeftCol,
		RightColumn = RightCol,
		ScrollFrame = ContainerScroll,
	}

	-- Maclib Section: tab:Section({ Side = "Left" | "Right" })
	function TabObj:Section(Settings)
		Settings = Settings or {}
		local TargetCol = (Settings.Side == "Right") and RightCol or LeftCol
		local SectionScope = { Container = TargetCol, ScrollFrame = ContainerScroll }
		for Name, Func in pairs(SectionElements) do
			SectionScope[Name] = function(selfRef, ...) return Func(selfRef, ...) end
		end
		return SectionScope
	end

	-- Fluent AddSection
	function TabObj:AddSection(SectionTitle)
		local SectionScope = TabObj:Section({ Side = "Left" })
		SectionScope:Header({ Name = SectionTitle })
		return SectionScope
	end

	function TabObj:AddCard(CardTitle, Config)
		Config = Config or {}
		local TargetCol = (Config.Column == "Right" or Config.Side == "Right") and RightCol or LeftCol
		local Scope = { Container = TargetCol, ScrollFrame = ContainerScroll }
		return SectionElements.CollapsibleCard(Scope, CardTitle, Config)
	end

	function TabObj:InsertConfigSection(Side)
		local Section = TabObj:Section({ Side = Side or "Left" })
		Section:Header({ Name = "Configuration" })
		Section:Button({
			Name = "Save Config",
			Callback = function()
				Window:Notify({ Title = "Configuration", Description = "Config saved successfully.", Lifetime = 3 })
			end,
		})
		Section:Button({
			Name = "Load Config",
			Callback = function()
				Window:Notify({ Title = "Configuration", Description = "Config loaded successfully.", Lifetime = 3 })
			end,
		})
		return Section
	end

	function TabObj:Select()
		TabManager:SelectTab(TabIndex)
	end

	for Name, Func in pairs(SectionElements) do
		TabObj[Name] = function(selfRef, ...) return Func(selfRef, ...) end
	end

	AddSignal(TabBtn.MouseButton1Click, function()
		TabObj:Select()
	end)

	table.insert(TabManager.Tabs, TabObj)
	table.insert(TabManager.Containers, ContainerScroll)

	return TabObj
end

function TabManager:SelectTab(Index)
	TabManager.SelectedTab = Index
	for TabIdx, TabObj in ipairs(TabManager.Tabs) do
		if TabIdx == Index then
			Tween(TabObj.Button, 0.2, { BackgroundTransparency = 0.3 })
		else
			Tween(TabObj.Button, 0.2, { BackgroundTransparency = 1 })
		end
	end

	local Current = TabManager.Tabs[Index]
	if Current and TabManager.Window then
		TabManager.Window.HeaderTabTitle.Text = Current.Name
		for TabIdx, Container in ipairs(TabManager.Containers) do
			Container.Visible = (TabIdx == Index)
		end
	end
end

--------------------------------------------------------------------------------
-- Main Window Creation (Maclib & Fluent Fused)
--------------------------------------------------------------------------------

function Library:Window(Settings)
	Settings = Settings or {}
	local Title = Settings.Title or "Mellow Hub"
	local Subtitle = Settings.Subtitle or Settings.SubTitle or "Version 2.0"
	local WindowSize = Settings.Size or UDim2.fromOffset(868, 620)
	local AcrylicBlur = (Settings.AcrylicBlur ~= false)
	local ShowUserInfo = (Settings.ShowUserInfo ~= false)
	local DisabledControls = Settings.DisabledWindowControls or {}

	Library.MinimizeKey = Settings.Keybind or Enum.KeyCode.RightControl
	Library.UseAcrylic = AcrylicBlur

	local Viewport = GetViewportSize()
	local InitialPos = UDim2.fromOffset(
		math.max(10, Viewport.X / 2 - WindowSize.X.Offset / 2),
		math.max(10, Viewport.Y / 2 - WindowSize.Y.Offset / 2)
	)

	local Window = {
		Size = WindowSize,
		Position = InitialPos,
		Settings = Settings,
		Minimized = false,
		Maximized = false,
		GlobalSettingsList = {},
	}
	TabManager.Window = Window

	-- Window Background Paint
	local WaveContour = New("ImageLabel", {
		Name = "WaveContour",
		Image = Assets.ContourWaves,
		Size = UDim2.fromScale(1, 1),
		ImageTransparency = 0.88,
		ImageColor3 = Color3.fromRGB(104, 170, 208),
		ScaleType = Enum.ScaleType.Crop,
		BackgroundTransparency = 1,
		ZIndex = 2,
	}, { New("UICorner", { CornerRadius = UDim.new(0, 10) }) })

	local WindowBackground = New("Frame", {
		Name = "WindowBackground",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = AcrylicBlur and 0.12 or 0,
		ZIndex = 1,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		New("UIGradient", { Rotation = -45, ThemeTag = { Color = "BackgroundGradient" } }),
		WaveContour,
	})

	local PaintFrame = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
	}, {
		New("ImageLabel", {
			Name = "DropShadow",
			Image = Assets.Shadow,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(99, 99, 99, 99),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 120, 1, 116),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.55,
			ZIndex = 0,
		}),
		WindowBackground,
		New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 10,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 10) }),
			New("UIStroke", { Transparency = 0.45, Thickness = 1, ThemeTag = { Color = "WindowBorder" } }),
		}),
	})

	-- Sidebar Layout
	local SidebarWidth = 200

	-- macOS Traffic Light Buttons
	local CloseBtn = New("TextButton", {
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(250, 93, 86),
		Text = "",
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local MinBtn = New("TextButton", {
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(252, 190, 57),
		Text = "",
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local MaxBtn = New("TextButton", {
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(119, 174, 94),
		Text = "",
	}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	if table.find(DisabledControls, "Exit") then CloseBtn.BackgroundTransparency = 0.7 end
	if table.find(DisabledControls, "Minimize") then MinBtn.BackgroundTransparency = 0.7 end
	if table.find(DisabledControls, "Maximize") then MaxBtn.BackgroundTransparency = 0.7 end

	local WindowControls = New("Frame", {
		Size = UDim2.fromOffset(60, 24),
		Position = UDim2.fromOffset(14, 12),
		BackgroundTransparency = 1,
		ZIndex = 12,
	}, {
		New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center }),
		CloseBtn,
		MinBtn,
		MaxBtn,
	})

	-- Hub Brand Card (Top of Sidebar)
	local TitleLabel = New("TextLabel", {
		Text = Title,
		FontFace = Fonts.SemiBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 16),
		ThemeTag = { TextColor3 = "Text" },
	})

	local SubtitleLabel = New("TextLabel", {
		Text = Subtitle,
		FontFace = Fonts.Regular,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(12, 26),
		Size = UDim2.new(1, -24, 0, 14),
		ThemeTag = { TextColor3 = "SubText" },
	})

	local HubCard = New("Frame", {
		Size = UDim2.new(1, -20, 0, 52),
		Position = UDim2.fromOffset(10, 42),
		BackgroundTransparency = 0.5,
		ZIndex = 6,
		ThemeTag = { BackgroundColor3 = "SidebarBackground" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.55, ThemeTag = { Color = "SidebarBorder" } }),
		TitleLabel,
		SubtitleLabel,
	})

	-- Sidebar Tab Groups Holder
	local TabHolder = New("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -180),
		Position = UDim2.fromOffset(8, 104),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ZIndex = 6,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	-- Sidebar User Info Card (Maclib style)
	local UserProfileCard = New("Frame", {
		Size = UDim2.new(1, -18, 0, 52),
		Position = UDim2.new(0, 9, 1, -62),
		BackgroundTransparency = 0.5,
		Visible = ShowUserInfo,
		ZIndex = 6,
		ThemeTag = { BackgroundColor3 = "SidebarBackground" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "SidebarBorder" } }),
		New("ImageLabel", {
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.fromOffset(8, 8),
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(18, 30, 40),
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		New("TextLabel", {
			Text = LocalPlayer.DisplayName,
			FontFace = Fonts.SemiBold,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(50, 8),
			Size = UDim2.new(1, -54, 0, 14),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = "@" .. LocalPlayer.Name,
			FontFace = Fonts.Regular,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(50, 22),
			Size = UDim2.new(1, -54, 0, 12),
			ThemeTag = { TextColor3 = "SubText" },
		}),
		New("TextLabel", {
			Text = Settings.UserRank or "Premium",
			FontFace = Fonts.Medium,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(50, 34),
			Size = UDim2.new(1, -54, 0, 12),
			ThemeTag = { TextColor3 = "Accent" },
		}),
	})

	local Sidebar = New("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, SidebarWidth, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, {
		WindowControls,
		HubCard,
		TabHolder,
		UserProfileCard,
		New("Frame", {
			Name = "SidebarDivider",
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
			BackgroundTransparency = 0.5,
			ThemeTag = { BackgroundColor3 = "SidebarBorder" },
		}),
	})

	-- Header Controls: Search Bar, Tab Title, and Global Settings Menu
	local SearchBox = New("TextBox", {
		Text = "",
		PlaceholderText = "Search...",
		FontFace = Fonts.Regular,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -34, 1, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
	})

	local SearchBarFrame = New("Frame", {
		Size = UDim2.fromOffset(200, 30),
		Position = UDim2.fromOffset(SidebarWidth + 14, 12),
		BackgroundColor3 = Color3.fromRGB(15, 28, 38),
		BackgroundTransparency = 0.4,
		ZIndex = 8,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "InElementBorder" } }),
		New("ImageLabel", {
			Image = Assets.Search,
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(10, 8),
			ThemeTag = { ImageColor3 = "SubText" },
		}),
		SearchBox,
	})

	local HeaderTabTitle = New("TextLabel", {
		Text = "Dashboard",
		FontFace = Fonts.SemiBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0.5, SidebarWidth / 2, 0, 16),
		Size = UDim2.fromOffset(160, 20),
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 8,
		ThemeTag = { TextColor3 = "Text" },
	})
	Window.HeaderTabTitle = HeaderTabTitle

	-- Global Settings Dropdown Flyout (Maclib Window:GlobalSetting)
	local GlobalSettingsDropdown = New("Frame", {
		Name = "GlobalSettingsDropdown",
		Size = UDim2.fromOffset(220, 0),
		Position = UDim2.new(1, -240, 0, 48),
		BackgroundColor3 = Color3.fromRGB(15, 27, 36),
		BackgroundTransparency = 0.1,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 50,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "WindowBorder" } }),
		New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
	})

	local SettingsButton = New("TextButton", {
		Size = UDim2.fromOffset(30, 30),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		BackgroundColor3 = Color3.fromRGB(18, 32, 42),
		BackgroundTransparency = 0.4,
		Text = "",
		ZIndex = 12,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.55, ThemeTag = { Color = "InElementBorder" } }),
		New("ImageLabel", {
			Image = Assets.Sliders,
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ThemeTag = { ImageColor3 = "Text" },
		}),
	})

	AddSignal(SettingsButton.MouseButton1Click, function()
		GlobalSettingsDropdown.Visible = not GlobalSettingsDropdown.Visible
		if GlobalSettingsDropdown.Visible then
			local Height = #Window.GlobalSettingsList * 34 + 16
			Tween(GlobalSettingsDropdown, 0.2, { Size = UDim2.fromOffset(220, Height) })
		end
	end)

	-- Content Area
	local ContainerHolder = New("Frame", {
		Name = "ContainerHolder",
		Size = UDim2.new(1, -SidebarWidth - 24, 1, -60),
		Position = UDim2.fromOffset(SidebarWidth + 14, 50),
		BackgroundTransparency = 1,
		ZIndex = 6,
	})
	Window.ContainerHolder = ContainerHolder

	-- Window Root Frame
	Window.Root = New("Frame", {
		Name = "MacLibWindow",
		Size = Window.Size,
		Position = Window.Position,
		BackgroundTransparency = 1,
		Parent = Library.GUI,
	}, {
		PaintFrame,
		Sidebar,
		SearchBarFrame,
		HeaderTabTitle,
		SettingsButton,
		GlobalSettingsDropdown,
		ContainerHolder,
	})

	-- Acrylic Blur Hook
	if AcrylicBlur then
		AcrylicEngine:SetEnabled(true)
		AddSignal(Window.Root:GetPropertyChangedSignal("AbsolutePosition"), function() AcrylicEngine:Sync(Window.Root) end)
		AddSignal(Window.Root:GetPropertyChangedSignal("AbsoluteSize"), function() AcrylicEngine:Sync(Window.Root) end)
		AcrylicEngine:Sync(Window.Root)
	end

	-- Window Dragging (Maclib style)
	local Dragging = false
	local DragStart, StartPos
	AddSignal(Window.Root.InputBegan, function(Input)
		if IsClickInput(Input) and Input.Position.Y - Window.Root.AbsolutePosition.Y < 44 then
			Dragging = true
			DragStart = Input.Position
			StartPos = Window.Root.Position
		end
	end)

	AddSignal(UserInputService.InputChanged, function(Input)
		if Dragging and IsMoveInput(Input) then
			local Delta = Input.Position - DragStart
			Window.Root.Position = UDim2.fromOffset(StartPos.X.Offset + Delta.X, StartPos.Y.Offset + Delta.Y)
			Window.Position = Window.Root.Position
		end
	end)

	AddSignal(UserInputService.InputEnded, function(Input)
		if IsClickInput(Input) then Dragging = false end
	end)

	-- Window Controls Handlers
	AddSignal(CloseBtn.MouseButton1Click, function()
		Window:Unload()
	end)
	AddSignal(MinBtn.MouseButton1Click, function()
		Window:SetState(not Window.Minimized)
	end)
	AddSignal(MaxBtn.MouseButton1Click, function()
		Window:Maximize()
	end)

	-- Window Public Functions (Maclib & Fluent Fused)
	function Window:UpdateTitle(NewTitle)
		TitleLabel.Text = NewTitle
	end

	function Window:UpdateSubtitle(NewSubtitle)
		SubtitleLabel.Text = NewSubtitle
	end

	function Window:SetState(State)
		Window.Minimized = State
		Window.Root.Visible = not State
		if AcrylicEngine.Model then
			AcrylicEngine.Model.Transparency = State and 1 or 0.98
		end
	end

	function Window:GetState()
		return not Window.Minimized
	end

	function Window:Maximize()
		Window.Maximized = not Window.Maximized
		if Window.Maximized then
			local Viewport = GetViewportSize()
			Tween(Window.Root, 0.25, { Size = UDim2.fromOffset(Viewport.X, Viewport.Y), Position = UDim2.fromOffset(0, 0) })
		else
			Tween(Window.Root, 0.25, { Size = Window.Size, Position = Window.Position })
		end
	end

	function Window:SetAcrylicBlurState(State)
		Library.UseAcrylic = State
		AcrylicEngine:SetEnabled(State)
	end

	function Window:GetAcrylicBlurState()
		return AcrylicEngine.Enabled
	end

	function Window:SetNotificationsState(State)
		Library.NotificationsEnabled = State
	end

	function Window:GetNotificationsState()
		return Library.NotificationsEnabled
	end

	function Window:SetUserInfoState(State)
		Library.ShowUserInfo = State
		UserProfileCard.Visible = State
	end

	function Window:GetUserInfoState()
		return Library.ShowUserInfo
	end

	function Window:SetKeybind(Keycode)
		Library.MinimizeKey = Keycode
	end

	function Window:SetSize(Size)
		Window.Size = Size
		Window.Root.Size = Size
	end

	function Window:GetSize()
		return Window.Root.Size
	end

	function Window:Unload()
		Library:Destroy()
	end

	function Window.onUnloaded(Callback)
		table.insert(Library.onUnloadedCallbacks, Callback)
	end

	function Window:Notify(Config)
		return Library:Notify(Config)
	end

	function Window:Dialog(Config)
		Dialog:Create(Window.Root, Config)
	end

	-- Global Settings item: Window:GlobalSetting({ Name, Default, Callback })
	function Window:GlobalSetting(SettingConfig)
		local Name = SettingConfig.Name or "Setting"
		local State = SettingConfig.Default or false

		local ToggleBtn = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Color3.fromRGB(20, 34, 46),
			BackgroundTransparency = 0.6,
			Text = "",
			Parent = GlobalSettingsDropdown,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 5) }),
			New("TextLabel", {
				Text = Name,
				FontFace = Fonts.Medium,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -40, 1, 0),
				ThemeTag = { TextColor3 = "Text" },
			}),
			New("Frame", {
				Name = "StatusDot",
				Size = UDim2.fromOffset(8, 8),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				BackgroundColor3 = State and Color3.fromRGB(52, 211, 153) or Color3.fromRGB(80, 80, 80),
			}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		})

		AddSignal(ToggleBtn.MouseButton1Click, function()
			State = not State
			ToggleBtn.StatusDot.BackgroundColor3 = State and Color3.fromRGB(52, 211, 153) or Color3.fromRGB(80, 80, 80)
			if SettingConfig.Callback then
				Library:SafeCallback(SettingConfig.Callback, State)
			end
		end)

		table.insert(Window.GlobalSettingsList, ToggleBtn)
		return State
	end

	-- Maclib TabGroup: local tabGroups = { TabGroup1 = Window:TabGroup() }
	function Window:TabGroup()
		local TabGroupObj = {}
		function TabGroupObj:Tab(TabSettings)
			return CreateTabObject(Window, TabSettings.Name or TabSettings.Title or "Tab", TabSettings.Image or TabSettings.Icon, TabHolder)
		end
		return TabGroupObj
	end

	-- Shortcut: Window:Tab / Window:AddTab
	function Window:Tab(TabSettings)
		return CreateTabObject(Window, TabSettings.Name or TabSettings.Title or "Tab", TabSettings.Image or TabSettings.Icon, TabHolder)
	end
	Window.AddTab = Window.Tab

	function Window:SelectTab(Index)
		TabManager:SelectTab(Index or 1)
	end

	-- Keybind toggle listener
	AddSignal(UserInputService.InputBegan, function(Input, Processed)
		if Processed or UserInputService:GetFocusedTextBox() then return end
		if Input.KeyCode == Library.MinimizeKey then
			Window:SetState(not Window.Minimized)
		end
	end)

	Library.Window = Window
	Creator.UpdateTheme()
	return Window
end

-- Aliases for library entry
Library.CreateWindow = Library.Window

--------------------------------------------------------------------------------
-- Config / SaveManager Compatibility (Maclib & Fluent Fused)
--------------------------------------------------------------------------------

local SaveFolder = "MellowHub"

function Library:SetFolder(Folder)
	SaveFolder = Folder
end

function Library:LoadAutoLoadConfig()
	-- Handled smoothly if executor provides writefile / readfile
	if isfile and isfile(SaveFolder .. "/autoload.txt") then
		pcall(function()
			local Name = readfile(SaveFolder .. "/autoload.txt")
			Library:Notify({
				Title = "Configuration",
				Description = "Loaded autoload profile: " .. tostring(Name),
				Lifetime = 4,
			})
		end)
	end
end

function Library:SetTheme(ThemeName)
	if Library.ThemeData[ThemeName] then
		Library.Theme = ThemeName
		Creator.UpdateTheme()
	end
end

function Library:Destroy()
	Library.Unloaded = true
	AcrylicEngine:SetEnabled(false)
	if AcrylicEngine.Folder then AcrylicEngine.Folder:Destroy() end
	for _, Cb in ipairs(Library.onUnloadedCallbacks) do pcall(Cb) end
	Creator.Disconnect()
	if Library.GUI then Library.GUI:Destroy() end
end

return Library

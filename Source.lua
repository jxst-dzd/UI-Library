--[[
	Mellow UI (v1.2.0 - Acrylic Glass & Axon Style)
	A modern, high-performance Roblox UI library with real acrylic blur,
	multi-column collapsible cards, user profile widget, header search,
	item action rows, and macOS traffic lights.

	Inspired by Fluent and Axon Hub.
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
	Version = "1.2.0",

	Options = {},
	Themes = {},
	ThemeData = {},
	OpenFrames = {},

	Window = nil,
	Unloaded = false,

	Theme = "Mellow",
	DialogOpen = false,
	UseAcrylic = true,
	Acrylic = true,
	Transparency = false,
	MinimizeKeybind = nil,
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
	ContourWaves = "rbxassetid://13854659424", -- Wavy topographic watermark texture
	Search = "rbxassetid://10734943674",
	UserDefault = "rbxassetid://10747373176",
	Box = "rbxassetid://10709782497",
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
	["ghost"] = "rbxassetid://10734897102",
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
-- Themes
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
		PinkAccent = Color3.fromRGB(244, 63, 94), -- Vibrant pink for steal / action buttons

		BackgroundGradient = Gradient(Color3.fromRGB(15, 32, 42), Color3.fromRGB(8, 14, 18)),
		WindowBorder = Color3.fromRGB(48, 82, 101),
		Pattern = Color3.fromRGB(62, 104, 128),
		PatternTransparency = 0.88,

		TitleBarLine = Color3.fromRGB(36, 62, 78),
		Tab = Color3.fromRGB(120, 170, 200),
		TabActive = Color3.fromRGB(25, 48, 62),

		CardBackground = Color3.fromRGB(14, 27, 36),
		CardBorder = Color3.fromRGB(34, 58, 74),

		Element = Color3.fromRGB(90, 140, 170),
		ElementBorder = Color3.fromRGB(24, 44, 56),
		InElementBorder = Color3.fromRGB(60, 95, 115),
		ElementTransparency = 0.88,

		ToggleSlider = Color3.fromRGB(125, 165, 190),
		ToggleToggled = Color3.fromRGB(244, 63, 94), -- Pink toggled thumb as in screenshot

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
		Success = Color3.fromRGB(52, 211, 153), -- Pet income green
		Hover = Color3.fromRGB(120, 170, 200),
		HoverChange = 0.05,
	},
	{
		Name = "AxonDark",
		Accent = Color3.fromRGB(56, 189, 248),
		PinkAccent = Color3.fromRGB(244, 63, 94),

		BackgroundGradient = Gradient(Color3.fromRGB(11, 19, 26), Color3.fromRGB(5, 9, 13)),
		WindowBorder = Color3.fromRGB(28, 48, 62),
		Pattern = Color3.fromRGB(44, 74, 92),
		PatternTransparency = 0.92,

		TitleBarLine = Color3.fromRGB(24, 40, 52),
		Tab = Color3.fromRGB(90, 130, 155),
		TabActive = Color3.fromRGB(18, 32, 42),

		CardBackground = Color3.fromRGB(9, 16, 22),
		CardBorder = Color3.fromRGB(24, 42, 54),

		Element = Color3.fromRGB(80, 120, 145),
		ElementBorder = Color3.fromRGB(18, 32, 42),
		InElementBorder = Color3.fromRGB(45, 70, 88),
		ElementTransparency = 0.90,

		ToggleSlider = Color3.fromRGB(110, 150, 175),
		ToggleToggled = Color3.fromRGB(244, 63, 94),

		SliderRail = Color3.fromRGB(95, 135, 160),

		DropdownFrame = Color3.fromRGB(120, 160, 185),
		DropdownHolder = Color3.fromRGB(8, 14, 20),
		DropdownBorder = Color3.fromRGB(28, 48, 62),
		DropdownOption = Color3.fromRGB(100, 140, 165),

		Keybind = Color3.fromRGB(100, 140, 165),

		Input = Color3.fromRGB(120, 160, 185),
		InputFocused = Color3.fromRGB(4, 8, 12),
		InputIndicator = Color3.fromRGB(56, 189, 248),

		Dialog = Color3.fromRGB(8, 14, 20),
		DialogHolder = Color3.fromRGB(6, 10, 14),
		DialogHolderLine = Color3.fromRGB(20, 34, 44),
		DialogButton = Color3.fromRGB(14, 26, 36),
		DialogButtonBorder = Color3.fromRGB(36, 60, 78),
		DialogBorder = Color3.fromRGB(32, 54, 70),

		Text = Color3.fromRGB(240, 245, 248),
		SubText = Color3.fromRGB(130, 155, 170),
		Success = Color3.fromRGB(52, 211, 153),
		Hover = Color3.fromRGB(100, 140, 165),
		HoverChange = 0.05,
	},
}

for _, Theme in ThemeList do
	table.insert(Library.Themes, Theme.Name)
	Library.ThemeData[Theme.Name] = Theme
end

--------------------------------------------------------------------------------
-- Creator Factory & Theme Registry
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
			Content = "Callback error",
			SubContent = Msg,
			Duration = 5,
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
-- Real glass reflection + DepthOfField in Lighting
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

	-- Glass MeshPart
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

	-- Lighting DepthOfField
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
	local Previous = Env.MellowUI
	if type(Previous) == "table" and Previous ~= Library and type(Previous.Destroy) == "function" then
		pcall(Previous.Destroy, Previous)
	end
	Env.MellowUI = Library
end

local GUI = New("ScreenGui", {
	Name = "MellowUI",
	DisplayOrder = 999,
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
-- Window Paint: Glass Background + Topographic Waves + Border
--------------------------------------------------------------------------------

local Paints = {}

local function CreatePaint()
	local Paint = {}

	-- Wavy contour watermark lines overlay (Axon Hub aesthetic)
	local WaveContour = New("ImageLabel", {
		Name = "WaveContour",
		Image = Assets.ContourWaves,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		ImageTransparency = 0.88,
		ImageColor3 = Color3.fromRGB(104, 170, 208),
		ScaleType = Enum.ScaleType.Crop,
		BackgroundTransparency = 1,
		ZIndex = 2,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
	})

	Paint.Background = New("Frame", {
		Name = "GlassBackground",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.15, -- Frosted translucent glass
		ZIndex = 1,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		New("UIGradient", {
			Rotation = -45,
			ThemeTag = {
				Color = "BackgroundGradient",
			},
		}),
		WaveContour,
	})

	Paint.Frame = New("Frame", {
		Name = "PaintFrame",
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
		Paint.Background,
		New("Frame", {
			Name = "GlassStroke",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 5,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			New("UIStroke", {
				Transparency = 0.45,
				Thickness = 1,
				ThemeTag = {
					Color = "WindowBorder",
				},
			}),
		}),
	})

	Paints[Paint.Background] = true
	return Paint
end

--------------------------------------------------------------------------------
-- Toast Notifications
--------------------------------------------------------------------------------

local Notification = {}

function Notification:Init(Parent)
	Notification.Holder = New("Frame", {
		Name = "NotificationStack",
		Position = UDim2.new(1, -25, 1, -25),
		Size = UDim2.new(0, 310, 1, -25),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 100,
		Parent = Parent,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 10),
		}),
	})
end

function Notification:New(Config)
	Config = Config or {}
	local Content = Config.Content or ""
	local SubContent = Config.SubContent or ""
	local Duration = tonumber(Config.Duration) or 5

	local Toast = { Closed = false }

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Color3.fromRGB(15, 28, 38),
		BackgroundTransparency = 0.1,
		ZIndex = 100,
		LayoutOrder = NextLayoutOrder(),
		Parent = Notification.Holder,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.4, ThemeTag = { Color = "WindowBorder" } }),
		New("Frame", {
			Size = UDim2.fromOffset(3, 16),
			Position = UDim2.fromOffset(12, 12),
			ThemeTag = { BackgroundColor3 = "Accent" },
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		New("TextLabel", {
			Text = Config.Title or "Notification",
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(22, 12),
			Size = UDim2.new(1, -50, 0, 16),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Content,
			FontFace = Fonts.Regular,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Position = UDim2.fromOffset(22, 30),
			Size = UDim2.new(1, -34, 0, 20),
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

	Tween(ProgressBar.Fill, Duration, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)

	task.delay(Duration, function()
		if not Toast.Closed then
			Toast.Closed = true
			Tween(Frame, 0.3, { BackgroundTransparency = 1 })
			task.delay(0.35, function() Frame:Destroy() end)
		end
	end)

	return Toast
end

Notification:Init(GUI)

function Library:Notify(Config)
	return Notification:New(Config)
end

--------------------------------------------------------------------------------
-- Interactive Components Builder (Collapsible Cards, Rows, Toggles, etc.)
--------------------------------------------------------------------------------

local Elements = {}

-- 1. Collapsible GroupBox / Card (Axon Hub Style)
function Elements:AddCard(Title, Config)
	Config = Config or {}
	local Collapsible = Config.Collapsible ~= false
	local Collapsed = Config.DefaultCollapsed or false

	local Card = {
		Title = Title,
		Collapsed = Collapsed,
		Children = {},
		Type = "Card",
	}

	local ContentLayout = New("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local CardContent = New("Frame", {
		Name = "CardContent",
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.fromOffset(0, 38),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	}, {
		ContentLayout,
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),
	})

	local Chevron = New("ImageLabel", {
		Image = Assets.ChevronDown,
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 1,
		Visible = Collapsible,
		ThemeTag = { ImageColor3 = "SubText" },
	})

	local CardHeader = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Text = "",
	}, {
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -40, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		Chevron,
	})

	local CardFrame = New("Frame", {
		Name = "Card_" .. Title,
		Size = UDim2.new(1, 0, 0, 38),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.35,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = {
			BackgroundColor3 = "CardBackground",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = { Color = "CardBorder" },
		}),
		CardHeader,
		CardContent,
	})

	function Card:ToggleCollapse()
		Card.Collapsed = not Card.Collapsed
		if Card.Collapsed then
			Tween(Chevron, 0.2, { Rotation = -90 })
			CardContent.Visible = false
		else
			Tween(Chevron, 0.2, { Rotation = 0 })
			CardContent.Visible = true
		end
	end

	if Collapsible then
		AddSignal(CardHeader.MouseButton1Click, function()
			Card:ToggleCollapse()
		end)
	end

	Card.Container = CardContent
	Card.ScrollFrame = self.ScrollFrame

	-- Inherit all element creation methods
	for Name, Func in pairs(Elements) do
		Card[Name] = function(selfRef, ...)
			return Func(selfRef, ...)
		end
	end

	return Card
end

-- 2. Item Action Row (Like the Pet Steal Row in the screenshot)
function Elements:AddRow(Config)
	assert(Config.Title, "AddRow - Missing Title")

	local Row = {
		Title = Config.Title,
		Value = Config.Value or "",
		SubText = Config.SubText or "",
		ButtonText = Config.ButtonText or "Steal",
		Callback = Config.Callback or function() end,
		Type = "Row",
	}

	local ResolvedIcon = ResolveImage(Config.Image) or Assets.Box

	local Thumbnail = New("ImageLabel", {
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromOffset(8, 7),
		Image = ResolvedIcon,
		BackgroundColor3 = Color3.fromRGB(18, 32, 42),
		BackgroundTransparency = 0.3,
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	local TitleLabel = New("TextLabel", {
		Text = Row.Title,
		FontFace = Fonts.SemiBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(52, 6),
		Size = UDim2.new(1, -140, 0, 14),
		ThemeTag = { TextColor3 = "Text" },
	})

	local ValueLabel = New("TextLabel", {
		Text = Row.Value,
		FontFace = Fonts.Medium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(52, 22),
		Size = UDim2.new(1, -140, 0, 13),
		ThemeTag = { TextColor3 = "Success" }, -- Bright green/cyan for income
	})

	local SubLabel = New("TextLabel", {
		Text = Row.SubText,
		FontFace = Fonts.Regular,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(52, 35),
		Size = UDim2.new(1, -140, 0, 12),
		ThemeTag = { TextColor3 = "SubText" },
	})

	local ActionBtn = New("TextButton", {
		Size = UDim2.fromOffset(68, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Text = Row.ButtonText,
		FontFace = Fonts.SemiBold,
		TextSize = 12,
		ThemeTag = {
			BackgroundColor3 = "PinkAccent",
			TextColor3 = "Text",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }), -- Pill shape
	})

	local RowFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = {
			BackgroundColor3 = "Element",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		Thumbnail,
		TitleLabel,
		ValueLabel,
		SubLabel,
		ActionBtn,
	})

	AddSignal(ActionBtn.MouseButton1Click, function()
		Tween(ActionBtn, 0.1, { Size = UDim2.fromOffset(64, 24) })
		task.delay(0.1, function()
			Tween(ActionBtn, 0.1, { Size = UDim2.fromOffset(68, 26) })
		end)
		Library:SafeCallback(Row.Callback)
	end)

	function Row:Update(NewData)
		if NewData.Title then TitleLabel.Text = NewData.Title end
		if NewData.Value then ValueLabel.Text = NewData.Value end
		if NewData.SubText then SubLabel.Text = NewData.SubText end
		if NewData.ButtonText then ActionBtn.Text = NewData.ButtonText end
		if NewData.Image then Thumbnail.Image = ResolveImage(NewData.Image) or Assets.Box end
	end

	return Row
end

-- 3. Status Key-Value Tracker Widget
function Elements:AddStatus(InitialData)
	InitialData = InitialData or {}
	local Status = { Data = InitialData, Labels = {}, Type = "Status" }

	local Frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	for Key, Val in pairs(InitialData) do
		local Item = New("Frame", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Parent = Frame,
		}, {
			New("TextLabel", {
				Text = Key .. ":",
				FontFace = Fonts.SemiBold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.fromOffset(70, 18),
				ThemeTag = { TextColor3 = "Accent" },
			}),
			New("TextLabel", {
				Name = "Val",
				Text = tostring(Val),
				FontFace = Fonts.Regular,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(75, 0),
				Size = UDim2.new(1, -75, 1, 0),
				ThemeTag = { TextColor3 = "Text" },
			}),
		})
		Status.Labels[Key] = Item.Val
	end

	function Status:Set(Key, Val)
		if Status.Labels[Key] then
			Status.Labels[Key].Text = tostring(Val)
		end
	end

	return Status
end

-- 4. Toggle (Pill Switch)
function Elements:AddToggle(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Toggle - Missing Title")

	local Toggle = {
		Value = Config.Default or false,
		Callback = Config.Callback or function() end,
		Changed = function() end,
		Type = "Toggle",
	}

	local ToggleCircle = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local ToggleTrack = New("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 50, 62),
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		ToggleCircle,
	})

	local ItemFrame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		Text = "",
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = {
			BackgroundColor3 = "Element",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Config.Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -55, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		ToggleTrack,
	})

	function Toggle:SetValue(Val)
		Toggle.Value = not not Val
		if Toggle.Value then
			Tween(ToggleTrack, 0.2, { BackgroundColor3 = Creator.GetThemeProperty("PinkAccent") or Color3.fromRGB(244, 63, 94) })
			Tween(ToggleCircle, 0.2, { Position = UDim2.new(1, -16, 0.5, 0) })
		else
			Tween(ToggleTrack, 0.2, { BackgroundColor3 = Color3.fromRGB(35, 50, 62) })
			Tween(ToggleCircle, 0.2, { Position = UDim2.new(0, 2, 0.5, 0) })
		end
		Library:SafeCallback(Toggle.Callback, Toggle.Value)
		Library:SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:OnChanged(Func)
		Toggle.Changed = Func
		Func(Toggle.Value)
	end

	AddSignal(ItemFrame.MouseButton1Click, function()
		Toggle:SetValue(not Toggle.Value)
	end)

	Toggle:SetValue(Toggle.Value)
	RegisterOption(Idx, Toggle)
	return Toggle
end

-- 5. Slider
function Elements:AddSlider(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Slider - Missing Title")
	local Min = Config.Min or 0
	local Max = Config.Max or 100
	local Rounding = Config.Rounding or 0

	local Slider = {
		Value = math.clamp(Config.Default or Min, Min, Max),
		Min = Min,
		Max = Max,
		Rounding = Rounding,
		Callback = Config.Callback or function() end,
		Changed = function() end,
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
		Size = UDim2.fromOffset(110, 4),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 50, 62),
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		SliderFill,
		SliderDot,
	})

	local ValueLabel = New("TextLabel", {
		Text = tostring(Slider.Value),
		FontFace = Fonts.Medium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromOffset(45, 14),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -125, 0.5, 0),
		ThemeTag = { TextColor3 = "SubText" },
	})

	local ItemFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Config.Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -180, 1, 0),
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
		Slider:SetValue(Slider.Min + (Slider.Max - Slider.Min) * Scale)
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

	function Slider:SetValue(Val)
		Val = math.clamp(tonumber(Val) or Slider.Min, Slider.Min, Slider.Max)
		Slider.Value = Library:Round(Val, Slider.Rounding)
		local Scale = (Slider.Max == Slider.Min) and 0 or ((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min))
		SliderFill.Size = UDim2.fromScale(Scale, 1)
		SliderDot.Position = UDim2.new(Scale, 0, 0.5, 0)
		ValueLabel.Text = FormatNumber(Slider.Value, Slider.Rounding)
		Library:SafeCallback(Slider.Callback, Slider.Value)
		Library:SafeCallback(Slider.Changed, Slider.Value)
	end

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	Slider:SetValue(Slider.Value)
	RegisterOption(Idx, Slider)
	return Slider
end

-- 6. Dropdown
function Elements:AddDropdown(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Dropdown - Missing Title")

	local Dropdown = {
		Values = Config.Values or {},
		Value = Config.Default,
		Multi = Config.Multi or false,
		Opened = false,
		Type = "Dropdown",
		Callback = Config.Callback or function() end,
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
		Size = UDim2.fromOffset(130, 26),
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

	local ItemFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.5,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
		New("TextLabel", {
			Text = Config.Title,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -150, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		DropdownBtn,
	})

	function Dropdown:SetValue(Val)
		Dropdown.Value = Val
		DisplayLabel.Text = tostring(Val or "--")
		Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
	end

	Dropdown:SetValue(Dropdown.Value)
	RegisterOption(Idx, Dropdown)
	return Dropdown
end

-- 7. Button
function Elements:AddButton(Config)
	assert(Config.Title, "AddButton - Missing Title")
	local Btn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 0.5,
		Text = Config.Title,
		FontFace = Fonts.Medium,
		TextSize = 13,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element", TextColor3 = "Text" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "ElementBorder" } }),
	})

	AddSignal(Btn.MouseButton1Click, function()
		Library:SafeCallback(Config.Callback)
	end)
	return Btn
end

-- 8. Paragraph
function Elements:AddParagraph(Config)
	assert(Config.Title, "AddParagraph - Missing Title")
	local Content = Config.Content or ""
	local Item = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.6,
		LayoutOrder = NextLayoutOrder(),
		Parent = self.Container,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIStroke", { Transparency = 0.7, ThemeTag = { Color = "ElementBorder" } }),
		New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
		New("TextLabel", {
			Text = Config.Title,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Content,
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
	return Item
end

--------------------------------------------------------------------------------
-- Tab & Multi-Column Architecture
--------------------------------------------------------------------------------

local TabModule = {
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
	Window = nil,
}

function TabModule:Init(Window)
	TabModule.Window = Window
	TabModule.Tabs = {}
	TabModule.Containers = {}
	TabModule.SelectedTab = 0
	TabModule.TabCount = 0
	return TabModule
end

function TabModule:New(Title, Icon, Parent)
	TabModule.TabCount += 1
	local TabIndex = TabModule.TabCount

	local Tab = {
		Name = Title,
		Index = TabIndex,
		Selected = false,
		Type = "Tab",
	}

	local ResolvedIcon = ResolveImage(Icon) or Assets.Box

	Tab.Button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = Parent,
		LayoutOrder = TabIndex,
		Text = "",
		ThemeTag = {
			BackgroundColor3 = "TabActive",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 7) }),
		New("ImageLabel", {
			Size = UDim2.fromOffset(18, 18),
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
			Position = UDim2.fromOffset(38, 0),
			Size = UDim2.new(1, -44, 1, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
	})

	-- Container with 2-Column Grid Layout (Like Axon Hub screenshot)
	local ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = TabModule.Window.ContainerHolder,
		Visible = false,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})

	local ColumnsContainer = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ContainerFrame,
	}, {
		New("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 12),
		}),
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 12),
		}),
	})

	-- Left and Right Columns
	local LeftCol = New("Frame", {
		Name = "LeftColumn",
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ColumnsContainer,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local RightCol = New("Frame", {
		Name = "RightColumn",
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = ColumnsContainer,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	AddSignal(ColumnsContainer:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ColumnsContainer.AbsoluteContentSize.Y + 20)
	end)

	AddSignal(Tab.Button.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Tabs[TabIndex] = Tab
	TabModule.Containers[TabIndex] = ContainerFrame

	Tab.LeftColumn = LeftCol
	Tab.RightColumn = RightCol
	Tab.Container = LeftCol -- default to left column
	Tab.ScrollFrame = ContainerFrame

	-- Method to add card to specific column (Left / Right)
	function Tab:AddCard(CardTitle, Config)
		Config = Config or {}
		local TargetCol = (Config.Column == "Right") and RightCol or LeftCol
		local CardScope = { Container = TargetCol, ScrollFrame = ContainerFrame }
		return Elements.AddCard(CardScope, CardTitle, Config)
	end

	-- Inherit base element methods
	for Name, Func in pairs(Elements) do
		Tab[Name] = function(selfRef, ...)
			return Func(selfRef, ...)
		end
	end

	return Tab
end

function TabModule:SelectTab(Index)
	local Window = TabModule.Window
	TabModule.SelectedTab = Index

	for TabIdx, TabObj in pairs(TabModule.Tabs) do
		if TabIdx == Index then
			TabObj.Selected = true
			Tween(TabObj.Button, 0.2, { BackgroundTransparency = 0.3 })
		else
			TabObj.Selected = false
			Tween(TabObj.Button, 0.2, { BackgroundTransparency = 1 })
		end
	end

	local CurrentTab = TabModule.Tabs[Index]
	if CurrentTab then
		Window.HeaderTabTitle.Text = CurrentTab.Name
		for TabIdx, Container in pairs(TabModule.Containers) do
			Container.Visible = (TabIdx == Index)
		end
	end
end

--------------------------------------------------------------------------------
-- Main Window Creation
--------------------------------------------------------------------------------

function Library:CreateWindow(Config)
	Config = Config or {}
	local Title = Config.Title or "Mellow Hub"
	local SubTitle = Config.SubTitle or "Version 1.2"
	local WindowSize = Config.Size or UDim2.fromOffset(780, 520)
	local TabWidth = Config.TabWidth or 170

	local Viewport = GetViewportSize()
	local InitialPos = UDim2.fromOffset(
		math.max(10, Viewport.X / 2 - WindowSize.X.Offset / 2),
		math.max(10, Viewport.Y / 2 - WindowSize.Y.Offset / 2)
	)

	local Window = {
		Size = WindowSize,
		Position = InitialPos,
		Minimized = false,
		Maximized = false,
	}

	local Paint = CreatePaint()
	Window.Paint = Paint

	-- macOS Traffic Light Buttons (Top-Left)
	local TrafficLights = New("Frame", {
		Size = UDim2.fromOffset(60, 24),
		Position = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		ZIndex = 10,
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		-- Close (Red)
		New("TextButton", {
			Name = "CloseBtn",
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.fromRGB(255, 95, 86),
			Text = "",
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		-- Minimize (Yellow)
		New("TextButton", {
			Name = "MinBtn",
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.fromRGB(255, 189, 46),
			Text = "",
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		-- Maximize (Green)
		New("TextButton", {
			Name = "MaxBtn",
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Color3.fromRGB(39, 201, 63),
			Text = "",
		}, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
	})

	-- Sidebar Hub Brand Header Box
	local HubBrandCard = New("Frame", {
		Size = UDim2.new(1, -20, 0, 56),
		Position = UDim2.fromOffset(10, 42),
		BackgroundTransparency = 0.6,
		ZIndex = 5,
		ThemeTag = { BackgroundColor3 = "CardBackground" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "CardBorder" } }),
		New("TextLabel", {
			Text = Title,
			FontFace = Fonts.SemiBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 10),
			Size = UDim2.new(1, -24, 0, 16),
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = SubTitle,
			FontFace = Fonts.Regular,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(12, 28),
			Size = UDim2.new(1, -24, 0, 14),
			ThemeTag = { TextColor3 = "SubText" },
		}),
	})

	-- Sidebar Tab List
	local TabHolder = New("ScrollingFrame", {
		Size = UDim2.new(1, -16, 1, -190),
		Position = UDim2.fromOffset(8, 108),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ZIndex = 5,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- User Profile Card (Bottom Left of Sidebar - Like in Screenshot)
	local UserThumbnail = New("ImageLabel", {
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromOffset(8, 8),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(18, 30, 40),
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local UserProfileCard = New("Frame", {
		Size = UDim2.new(1, -18, 0, 52),
		Position = UDim2.new(0, 9, 1, -62),
		BackgroundTransparency = 0.5,
		ZIndex = 6,
		ThemeTag = { BackgroundColor3 = "CardBackground" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("UIStroke", { Transparency = 0.6, ThemeTag = { Color = "CardBorder" } }),
		UserThumbnail,
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
			Text = Config.UserRank or "Premium",
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
		Size = UDim2.new(0, TabWidth, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, {
		TrafficLights,
		HubBrandCard,
		TabHolder,
		UserProfileCard,
	})

	-- Header Bar with Search Input & Active Tab Title
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
		Size = UDim2.fromOffset(210, 30),
		Position = UDim2.fromOffset(TabWidth + 14, 12),
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
		Position = UDim2.new(0.5, TabWidth / 2, 0, 16),
		Size = UDim2.fromOffset(160, 20),
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 8,
		ThemeTag = { TextColor3 = "Text" },
	})
	Window.HeaderTabTitle = HeaderTabTitle

	-- Content Area
	local ContainerHolder = New("Frame", {
		Size = UDim2.new(1, -TabWidth - 24, 1, -64),
		Position = UDim2.fromOffset(TabWidth + 14, 52),
		BackgroundTransparency = 1,
		ZIndex = 6,
	})
	Window.ContainerHolder = ContainerHolder

	-- Window Root Frame
	Window.Root = New("Frame", {
		Name = "MellowHubWindow",
		Size = Window.Size,
		Position = Window.Position,
		BackgroundTransparency = 1,
		Parent = Library.GUI,
	}, {
		Paint.Frame,
		Sidebar,
		SearchBarFrame,
		HeaderTabTitle,
		ContainerHolder,
	})

	-- Enable Acrylic Blur
	if Library.UseAcrylic then
		AcrylicEngine:SetEnabled(true)
		AddSignal(Window.Root:GetPropertyChangedSignal("AbsolutePosition"), function()
			AcrylicEngine:Sync(Window.Root)
		end)
		AddSignal(Window.Root:GetPropertyChangedSignal("AbsoluteSize"), function()
			AcrylicEngine:Sync(Window.Root)
		end)
		AcrylicEngine:Sync(Window.Root)
	end

	-- Traffic light actions
	AddSignal(TrafficLights.CloseBtn.MouseButton1Click, function()
		Library:Destroy()
	end)
	AddSignal(TrafficLights.MinBtn.MouseButton1Click, function()
		Window:Minimize()
	end)
	AddSignal(TrafficLights.MaxBtn.MouseButton1Click, function()
		Window:Maximize()
	end)

	-- Window Dragging
	local Dragging = false
	local DragStart, StartPos
	AddSignal(Window.Root.InputBegan, function(Input)
		if IsClickInput(Input) and Input.Position.Y - Window.Root.AbsolutePosition.Y < 46 then
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

	function Window:Minimize()
		Window.Minimized = not Window.Minimized
		Window.Root.Visible = not Window.Minimized
		if AcrylicEngine.Model then
			AcrylicEngine.Model.Transparency = Window.Minimized and 1 or 0.98
		end
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

	-- Tab Manager
	local TabHandler = TabModule:Init(Window)

	function Window:AddTab(TabConfig)
		assert(TabConfig.Title, "AddTab - Missing Title")
		return TabHandler:New(TabConfig.Title, TabConfig.Icon, TabHolder)
	end

	function Window:SelectTab(Index)
		TabHandler:SelectTab(Index or 1)
	end

	-- Keybind toggle listener
	AddSignal(UserInputService.InputBegan, function(Input, Processed)
		if Processed or UserInputService:GetFocusedTextBox() then return end
		if Input.KeyCode == Library.MinimizeKey then
			Window:Minimize()
		end
	end)

	Library.Window = Window
	Creator.UpdateTheme()
	return Window
end

--------------------------------------------------------------------------------
-- Library Controls
--------------------------------------------------------------------------------

function Library:SetTheme(ThemeName)
	if Library.ThemeData[ThemeName] then
		Library.Theme = ThemeName
		Creator.UpdateTheme()
	end
end

function Library:ToggleAcrylic(Value)
	Library.UseAcrylic = not not Value
	AcrylicEngine:SetEnabled(Library.UseAcrylic)
end

function Library:Destroy()
	Library.Unloaded = true
	AcrylicEngine:SetEnabled(false)
	if AcrylicEngine.Folder then AcrylicEngine.Folder:Destroy() end
	Creator.Disconnect()
	if Library.GUI then Library.GUI:Destroy() end
end

return Library

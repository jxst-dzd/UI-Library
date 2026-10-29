--[[
	Mellow UI
	A Fluent-style Roblox interface library built for Mellow Hub.

	Layout, behaviour and public API are modelled on Fluent by dawid-scripts (MIT License):
	https://github.com/dawid-scripts/Fluent
	The API is intentionally compatible, so Fluent's SaveManager / InterfaceManager addons work unchanged.

	Usage:
		local MellowUI = loadstring(readfile("MellowUI.lua"))()   -- executor
		local MellowUI = require(path.to.MellowUI)                 -- Studio (ModuleScript, client side)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[MellowUI] must run on the client (LocalScript / executor).")

local Library = {
	Version = "1.0.0",

	Options = {},
	Themes = {}, -- ordered list of theme names (Fluent compatible)
	ThemeData = {}, -- theme name -> theme table
	OpenFrames = {}, -- dropdowns, closed when the window is minimized

	Window = nil,
	Unloaded = false,

	Theme = "Mellow",
	DialogOpen = false,
	UseAcrylic = false, -- acrylic blur is not implemented; kept for Fluent addon compatibility
	Acrylic = false,
	Transparency = false,
	MinimizeKeybind = nil,
	MinimizeKey = Enum.KeyCode.LeftControl,

	GUI = nil,
}

--------------------------------------------------------------------------------
-- Static data
--------------------------------------------------------------------------------

local Fonts = {
	Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Medium = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	SemiBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
	Heading = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
}
local MeasureFont = Enum.Font.Gotham -- legacy enum used for TextService measurements

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
	ScrollTop = "rbxassetid://6276641225",
	ScrollMid = "rbxassetid://6889812721",
	ScrollBottom = "rbxassetid://6889812791",
}

-- Curated Lucide icons (https://lucide.dev). Any "rbxassetid://" string can also be passed directly.
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
	["eye"] = "rbxassetid://10723346959",
	["file-text"] = "rbxassetid://10723367380",
	["flame"] = "rbxassetid://10723376114",
	["folder"] = "rbxassetid://10723387563",
	["gamepad-2"] = "rbxassetid://10723395215",
	["globe"] = "rbxassetid://10723404337",
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
-- "Mellow" is sampled from the Mellow Hub logo:
--   background gradient (20,47,62) -> (10,17,23), stripes (48,82,101), white mark.
-- Every theme falls back to "Mellow" for keys it does not define.
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

		BackgroundGradient = Gradient(Color3.fromRGB(20, 47, 62), Color3.fromRGB(10, 17, 23)),
		WindowBorder = Color3.fromRGB(48, 82, 101),
		Pattern = Color3.fromRGB(62, 104, 128),
		PatternTransparency = 0.72,

		TitleBarLine = Color3.fromRGB(48, 82, 101),
		Tab = Color3.fromRGB(120, 170, 200),

		Element = Color3.fromRGB(100, 150, 180),
		ElementBorder = Color3.fromRGB(7, 15, 21),
		InElementBorder = Color3.fromRGB(70, 106, 128),
		ElementTransparency = 0.88,

		ToggleSlider = Color3.fromRGB(125, 165, 190),
		ToggleToggled = Color3.fromRGB(10, 19, 26),

		SliderRail = Color3.fromRGB(115, 155, 180),

		DropdownFrame = Color3.fromRGB(150, 190, 212),
		DropdownHolder = Color3.fromRGB(15, 31, 41),
		DropdownBorder = Color3.fromRGB(40, 68, 85),
		DropdownOption = Color3.fromRGB(120, 170, 200),

		Keybind = Color3.fromRGB(120, 170, 200),

		Input = Color3.fromRGB(150, 190, 212),
		InputFocused = Color3.fromRGB(6, 13, 18),
		InputIndicator = Color3.fromRGB(130, 170, 192),

		Dialog = Color3.fromRGB(15, 31, 41),
		DialogHolder = Color3.fromRGB(11, 23, 31),
		DialogHolderLine = Color3.fromRGB(8, 17, 23),
		DialogButton = Color3.fromRGB(20, 41, 54),
		DialogButtonBorder = Color3.fromRGB(56, 92, 113),
		DialogBorder = Color3.fromRGB(48, 82, 101),
		DialogInput = Color3.fromRGB(22, 44, 58),
		DialogInputLine = Color3.fromRGB(130, 170, 192),

		Text = Color3.fromRGB(240, 245, 248),
		SubText = Color3.fromRGB(150, 174, 188),
		Hover = Color3.fromRGB(120, 170, 200),
		HoverChange = 0.05,
	},
	{
		Name = "Midnight",
		Accent = Color3.fromRGB(96, 160, 200),

		BackgroundGradient = Gradient(Color3.fromRGB(14, 26, 35), Color3.fromRGB(5, 9, 12)),
		WindowBorder = Color3.fromRGB(34, 56, 70),
		Pattern = Color3.fromRGB(44, 74, 92),
		PatternTransparency = 0.78,

		TitleBarLine = Color3.fromRGB(34, 56, 70),
		Tab = Color3.fromRGB(100, 140, 165),

		Element = Color3.fromRGB(80, 120, 145),
		ElementBorder = Color3.fromRGB(4, 8, 11),
		InElementBorder = Color3.fromRGB(52, 80, 98),
		ElementTransparency = 0.9,

		DropdownHolder = Color3.fromRGB(10, 20, 27),
		DropdownBorder = Color3.fromRGB(30, 50, 63),

		Dialog = Color3.fromRGB(10, 20, 27),
		DialogHolder = Color3.fromRGB(7, 14, 19),
		DialogHolderLine = Color3.fromRGB(5, 10, 14),
		DialogButton = Color3.fromRGB(14, 28, 37),
		DialogButtonBorder = Color3.fromRGB(42, 70, 86),
		DialogBorder = Color3.fromRGB(34, 56, 70),
		DialogInput = Color3.fromRGB(16, 32, 42),

		SubText = Color3.fromRGB(135, 158, 172),
	},
	{
		Name = "Dark",
		Accent = Color3.fromRGB(96, 205, 255),

		BackgroundGradient = Gradient(Color3.fromRGB(42, 42, 42), Color3.fromRGB(28, 28, 28)),
		WindowBorder = Color3.fromRGB(80, 80, 80),
		Pattern = Color3.fromRGB(90, 90, 90),
		PatternTransparency = 0.85,

		TitleBarLine = Color3.fromRGB(75, 75, 75),
		Tab = Color3.fromRGB(120, 120, 120),

		Element = Color3.fromRGB(120, 120, 120),
		ElementBorder = Color3.fromRGB(35, 35, 35),
		InElementBorder = Color3.fromRGB(90, 90, 90),
		ElementTransparency = 0.87,

		ToggleSlider = Color3.fromRGB(120, 120, 120),
		ToggleToggled = Color3.fromRGB(0, 0, 0),

		SliderRail = Color3.fromRGB(120, 120, 120),

		DropdownFrame = Color3.fromRGB(160, 160, 160),
		DropdownHolder = Color3.fromRGB(45, 45, 45),
		DropdownBorder = Color3.fromRGB(35, 35, 35),
		DropdownOption = Color3.fromRGB(120, 120, 120),

		Keybind = Color3.fromRGB(120, 120, 120),

		Input = Color3.fromRGB(160, 160, 160),
		InputFocused = Color3.fromRGB(10, 10, 10),
		InputIndicator = Color3.fromRGB(150, 150, 150),

		Dialog = Color3.fromRGB(45, 45, 45),
		DialogHolder = Color3.fromRGB(35, 35, 35),
		DialogHolderLine = Color3.fromRGB(30, 30, 30),
		DialogButton = Color3.fromRGB(45, 45, 45),
		DialogButtonBorder = Color3.fromRGB(80, 80, 80),
		DialogBorder = Color3.fromRGB(70, 70, 70),
		DialogInput = Color3.fromRGB(55, 55, 55),
		DialogInputLine = Color3.fromRGB(160, 160, 160),

		Text = Color3.fromRGB(240, 240, 240),
		SubText = Color3.fromRGB(170, 170, 170),
		Hover = Color3.fromRGB(120, 120, 120),
		HoverChange = 0.07,
	},
}

for _, Theme in ThemeList do
	table.insert(Library.Themes, Theme.Name)
	Library.ThemeData[Theme.Name] = Theme
end

--------------------------------------------------------------------------------
-- Creator: instance factory + theme registry + signal tracking
--------------------------------------------------------------------------------

local Creator = {
	-- Strong table on purpose: Instance keys in weak tables can be collected while still parented.
	-- Destroyed objects (Parent == nil) are pruned in UpdateTheme.
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
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			AutoButtonColor = false,
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

-- Replaces an object's theme tags and applies them immediately (only to that object).
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

	-- Generalized iteration (not ipairs) so optional `cond and X or nil` children are allowed.
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

-- Connects a signal and tracks it for Library:Destroy(). An optional Bucket collects
-- connections an element must release in its own :Destroy().
function Creator.AddSignal(Signal, Callback, Bucket)
	local Connection = Signal:Connect(Callback)
	table.insert(Creator.Signals, Connection)
	if Bucket then
		table.insert(Bucket, Connection)
	end
	return Connection
end

function Creator.Disconnect()
	for Index = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Index)
		Connection:Disconnect()
	end
end

function Creator.DisconnectBucket(Bucket)
	for Index = #Bucket, 1, -1 do
		local Connection = table.remove(Bucket, Index)
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

-- Allows both Tab:AddToggle("Idx", { ... }) and Tab:AddToggle({ ... }).
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
	if not Function then
		return
	end

	local Success, Event = pcall(Function, ...)
	if not Success then
		local Message = tostring(Event)
		local _, Index = Message:find(":%d+: ")
		Library:Notify({
			Title = "Interface",
			Content = "Callback error",
			SubContent = Index and Message:sub(Index + 1) or Message,
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
	if type(Name) ~= "string" then
		return nil
	end
	return Icons[Name] or Icons[Name:gsub("^lucide%-", "")]
end

-- Accepts a Lucide icon name, "rbxassetid://..." / "rbxasset://..." / URL, a numeric id,
-- or (executor only) a local file path loaded through getcustomasset.
local function ResolveImage(Image)
	if type(Image) == "number" then
		return "rbxassetid://" .. Image
	end
	if type(Image) ~= "string" or Image == "" then
		return nil
	end

	local Icon = Library:GetIcon(Image)
	if Icon then
		return Icon
	end
	if Image:match("^rbxasset") or Image:match("^https?://") then
		return Image
	end
	if tonumber(Image) then
		return "rbxassetid://" .. Image
	end

	local GetCustomAsset = getcustomasset or getsynasset
	if type(GetCustomAsset) == "function" and type(isfile) == "function" then
		local Ok, Exists = pcall(isfile, Image)
		if Ok and Exists then
			local Loaded, Asset = pcall(GetCustomAsset, Image)
			if Loaded then
				return Asset
			end
		end
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
-- ScreenGui
--------------------------------------------------------------------------------

-- Re-executing the script replaces the previous instance instead of stacking GUIs.
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
	if type(ProtectGui) == "function" then
		pcall(ProtectGui, Gui)
	end

	if not RunService:IsStudio() then
		if type(gethui) == "function" then
			local Ok, Container = pcall(gethui)
			if Ok and Container and pcall(function()
				Gui.Parent = Container
			end) then
				return
			end
		end

		if pcall(function()
			Gui.Parent = game:GetService("CoreGui")
		end) then
			return
		end
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
-- Paint: themed window background (gradient + logo stripes + border + shadow)
--------------------------------------------------------------------------------

local Paints = {} -- Background frame -> true (strong; pruned when destroyed)

local function GetBackgroundTransparency()
	return Library.Transparency and 0.12 or 0
end

-- Diagonal stripes that mirror the Mellow Hub logo. A CanvasGroup is used because
-- ClipsDescendants does not clip rotated children, while a CanvasGroup (with UICorner) does.
local function CreatePattern()
	local Pattern = New("CanvasGroup", {
		Name = "Pattern",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 3,
		ThemeTag = {
			GroupTransparency = "PatternTransparency",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})

	local Spacing, Start, Count = 125, -300, 22 -- covers windows up to the 2048px max width
	for Index = 0, Count - 1 do
		New("Frame", {
			Name = "Stripe",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, Start + Index * Spacing, 0.5, 0),
			Size = UDim2.fromOffset(3, 2400),
			Rotation = 14,
			Parent = Pattern,
			ThemeTag = {
				BackgroundColor3 = "Pattern",
			},
		})
	end

	return Pattern
end

local function CreatePaint(WithPattern)
	local Paint = {}

	Paint.Background = New("Frame", {
		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = GetBackgroundTransparency(),
		ZIndex = 2,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIGradient", {
			Rotation = -45, -- light corner bottom-left, dark corner top-right (like the logo)
			ThemeTag = {
				Color = "BackgroundGradient",
			},
		}),
	})

	Paint.Frame = New("Frame", {
		Name = "Paint",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
	}, {
		New("ImageLabel", {
			Name = "Shadow",
			Image = Assets.Shadow,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(99, 99, 99, 99),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 120, 1, 116),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.6,
			ZIndex = 1,
		}),
		Paint.Background,
		WithPattern and CreatePattern() or nil,
		New("Frame", {
			Name = "Border",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 4,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			New("UIStroke", {
				Transparency = 0.35,
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
-- Notifications
--------------------------------------------------------------------------------

local Notification = {}

function Notification:Init(Parent)
	Notification.Holder = New("Frame", {
		Name = "Notifications",
		Position = UDim2.new(1, -30, 1, -30),
		Size = UDim2.new(0, 310, 1, -30),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 100,
		Parent = Parent,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 12),
		}),
	})
end

function Notification:New(Config)
	Config = Config or {}
	local Content = Config.Content or ""
	local SubContent = Config.SubContent or ""
	local Duration = tonumber(Config.Duration)

	local NewNotification = {
		Closed = false,
	}

	local Paint = CreatePaint(false)

	NewNotification.Title = New("TextLabel", {
		Position = UDim2.fromOffset(24, 17),
		Size = UDim2.new(1, -60, 0, 12),
		Text = Config.Title or "Notification",
		RichText = true,
		FontFace = Fonts.Medium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local AccentBar = New("Frame", {
		Position = UDim2.fromOffset(14, 16),
		Size = UDim2.fromOffset(3, 14),
		ZIndex = 2,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})

	NewNotification.ContentLabel = New("TextLabel", {
		Text = Content,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		TextWrapped = true,
		Visible = Content ~= "",
		LayoutOrder = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	NewNotification.SubContentLabel = New("TextLabel", {
		Text = SubContent,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		TextWrapped = true,
		Visible = SubContent ~= "",
		LayoutOrder = 2,
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	NewNotification.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 40),
		Size = UDim2.new(1, -28, 0, 0),
		ZIndex = 2,
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 3),
		}),
		NewNotification.ContentLabel,
		NewNotification.SubContentLabel,
	})

	NewNotification.CloseButton = New("TextButton", {
		Position = UDim2.new(1, -14, 0, 13),
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, {
		New("ImageLabel", {
			Image = Assets.Close,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ThemeTag = {
				ImageColor3 = "Text",
			},
		}),
	})

	local Progress = New("Frame", {
		Position = UDim2.new(0, 10, 1, -5),
		Size = UDim2.new(1, -20, 0, 2),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Visible = Duration ~= nil,
	}, {
		New("Frame", {
			Name = "Fill",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.3,
			ThemeTag = {
				BackgroundColor3 = "Accent",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
	})

	NewNotification.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.new(1, 60, 0, 0),
	}, {
		Paint.Frame,
		AccentBar,
		NewNotification.Title,
		NewNotification.CloseButton,
		NewNotification.LabelHolder,
		Progress,
	})

	NewNotification.Holder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 58),
		LayoutOrder = NextLayoutOrder(),
		Parent = Notification.Holder,
	}, {
		NewNotification.Root,
	})

	local function Resize()
		local ContentHeight = (Content ~= "" or SubContent ~= "") and NewNotification.LabelHolder.AbsoluteSize.Y or 0
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, 58 + ContentHeight)
	end
	AddSignal(NewNotification.LabelHolder:GetPropertyChangedSignal("AbsoluteSize"), Resize)

	AddSignal(NewNotification.CloseButton.MouseButton1Click, function()
		NewNotification:Close()
	end)

	function NewNotification:Open()
		Resize()
		Tween(NewNotification.Root, 0.5, { Position = UDim2.fromScale(0, 0) })
		if Duration then
			Tween(Progress.Fill, Duration, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)
		end
	end

	function NewNotification:Close()
		if NewNotification.Closed then
			return
		end
		NewNotification.Closed = true
		Tween(NewNotification.Root, 0.4, { Position = UDim2.new(1, 60, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.4, function()
			NewNotification.Holder:Destroy()
		end)
	end

	NewNotification:Open()
	if Duration then
		task.delay(Duration, function()
			NewNotification:Close()
		end)
	end

	return NewNotification
end

Notification:Init(GUI)

function Library:Notify(Config)
	return Notification:New(Config)
end

--------------------------------------------------------------------------------
-- Dialog Module
--------------------------------------------------------------------------------

local Dialog = {
	Window = nil,
}

function Dialog:Init(Window)
	Dialog.Window = Window
	return Dialog
end

function Dialog:Create()
	local NewDialog = {
		Buttons = 0,
	}

	NewDialog.TintFrame = New("TextButton", {
		Name = "DialogTint",
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = Dialog.Window.Root,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})

	NewDialog.ButtonHolder = New("Frame", {
		Size = UDim2.new(1, -40, 1, -20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	NewDialog.ButtonHolderFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 1, -60),
		ThemeTag = {
			BackgroundColor3 = "DialogHolder",
		},
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			ThemeTag = {
				BackgroundColor3 = "DialogHolderLine",
			},
		}),
		NewDialog.ButtonHolder,
	})

	NewDialog.Title = New("TextLabel", {
		FontFace = Fonts.SemiBold,
		Text = "Dialog",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -40, 0, 24),
		Position = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	NewDialog.Scale = New("UIScale", {
		Scale = 1.08,
	})

	NewDialog.Root = New("CanvasGroup", {
		Size = UDim2.fromOffset(320, 175),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		GroupTransparency = 1,
		Parent = NewDialog.TintFrame,
		ThemeTag = {
			BackgroundColor3 = "Dialog",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ThemeTag = {
				Color = "DialogBorder",
			},
		}),
		NewDialog.Scale,
		NewDialog.Title,
		NewDialog.ButtonHolderFrame,
	})

	function NewDialog:Open()
		Library.DialogOpen = true
		Tween(NewDialog.TintFrame, 0.25, { BackgroundTransparency = 0.55 })
		Tween(NewDialog.Root, 0.25, { GroupTransparency = 0 })
		Tween(NewDialog.Scale, 0.25, { Scale = 1 })
	end

	function NewDialog:Close()
		Library.DialogOpen = false
		Tween(NewDialog.TintFrame, 0.2, { BackgroundTransparency = 1 })
		Tween(NewDialog.Root, 0.2, { GroupTransparency = 1 })
		Tween(NewDialog.Scale, 0.2, { Scale = 0.95 })
		task.delay(0.22, function()
			NewDialog.TintFrame:Destroy()
		end)
	end

	function NewDialog:Button(Title, Callback)
		NewDialog.Buttons += 1
		Title = Title or "Button"

		local Btn = New("TextButton", {
			Size = UDim2.new(1 / NewDialog.Buttons, -(((NewDialog.Buttons - 1) * 10) / NewDialog.Buttons), 0, 32),
			FontFace = Fonts.Medium,
			Text = Title,
			TextSize = 13,
			BackgroundTransparency = 0.2,
			Parent = NewDialog.ButtonHolder,
			ThemeTag = {
				BackgroundColor3 = "DialogButton",
				TextColor3 = "Text",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			New("UIStroke", {
				Transparency = 0.5,
				ThemeTag = {
					Color = "DialogButtonBorder",
				},
			}),
		})

		for _, Child in NewDialog.ButtonHolder:GetChildren() do
			if Child:IsA("TextButton") then
				Child.Size = UDim2.new(1 / NewDialog.Buttons, -(((NewDialog.Buttons - 1) * 10) / NewDialog.Buttons), 0, 32)
			end
		end

		AddSignal(Btn.MouseEnter, function()
			Tween(Btn, 0.15, { BackgroundTransparency = 0 })
		end)
		AddSignal(Btn.MouseLeave, function()
			Tween(Btn, 0.15, { BackgroundTransparency = 0.2 })
		end)
		AddSignal(Btn.MouseButton1Click, function()
			Library:SafeCallback(Callback)
			NewDialog:Close()
		end)

		return Btn
	end

	return NewDialog
end

--------------------------------------------------------------------------------
-- Base Component: Element Frame
--------------------------------------------------------------------------------

local function CreateElementFrame(Title, Desc, Parent, Clickable)
	local Element = {}

	Element.TitleLabel = New("TextLabel", {
		FontFace = Fonts.Medium,
		Text = Title or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Element.DescLabel = New("TextLabel", {
		FontFace = Fonts.Regular,
		Text = Desc or "",
		TextColor3 = Color3.fromRGB(170, 170, 170),
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Visible = (Desc ~= nil and Desc ~= ""),
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	Element.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 3),
		}),
		New("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		}),
		Element.TitleLabel,
		Element.DescLabel,
	})

	Element.Border = New("UIStroke", {
		Transparency = 0.55,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ThemeTag = {
			Color = "ElementBorder",
		},
	})

	Element.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = Creator.GetThemeProperty("ElementTransparency"),
		Parent = Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = NextLayoutOrder(),
		ThemeTag = {
			BackgroundColor3 = "Element",
			BackgroundTransparency = "ElementTransparency",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Element.Border,
		Element.LabelHolder,
	})

	function Element:SetTitle(Text)
		Element.TitleLabel.Text = Text or ""
	end

	function Element:SetDesc(Text)
		if Text == nil or Text == "" then
			Element.DescLabel.Visible = false
			Element.DescLabel.Text = ""
		else
			Element.DescLabel.Visible = true
			Element.DescLabel.Text = Text
		end
	end

	function Element:Destroy()
		Element.Frame:Destroy()
	end

	if Clickable then
		AddSignal(Element.Frame.MouseEnter, function()
			local Base = Creator.GetThemeProperty("ElementTransparency")
			local HoverDelta = Creator.GetThemeProperty("HoverChange") or 0.05
			Tween(Element.Frame, 0.15, { BackgroundTransparency = math.clamp(Base - HoverDelta, 0, 1) })
		end)
		AddSignal(Element.Frame.MouseLeave, function()
			local Base = Creator.GetThemeProperty("ElementTransparency")
			Tween(Element.Frame, 0.15, { BackgroundTransparency = Base })
		end)
		AddSignal(Element.Frame.MouseButton1Down, function()
			local Base = Creator.GetThemeProperty("ElementTransparency")
			local HoverDelta = Creator.GetThemeProperty("HoverChange") or 0.05
			Tween(Element.Frame, 0.1, { BackgroundTransparency = math.clamp(Base + HoverDelta, 0, 1) })
		end)
		AddSignal(Element.Frame.MouseButton1Up, function()
			local Base = Creator.GetThemeProperty("ElementTransparency")
			local HoverDelta = Creator.GetThemeProperty("HoverChange") or 0.05
			Tween(Element.Frame, 0.15, { BackgroundTransparency = math.clamp(Base - HoverDelta, 0, 1) })
		end)
	end

	return Element
end

--------------------------------------------------------------------------------
-- UI Elements Implementations
--------------------------------------------------------------------------------

local Elements = {}

-- 1. Paragraph
function Elements:AddParagraph(Config)
	assert(type(Config) == "table", "Paragraph - Missing Config table")
	assert(Config.Title, "Paragraph - Missing Title")

	local Element = CreateElementFrame(Config.Title, Config.Content or "", self.Container, false)
	Element.Frame.BackgroundTransparency = 0.94
	Element.Border.Transparency = 0.7

	local ParagraphObj = {
		Type = "Paragraph",
		Frame = Element.Frame,
		SetTitle = function(_, Text) Element:SetTitle(Text) end,
		SetDesc = function(_, Text) Element:SetDesc(Text) end,
		Destroy = function() Element:Destroy() end,
	}

	return ParagraphObj
end

-- 2. Button
function Elements:AddButton(Config)
	assert(type(Config) == "table", "Button - Missing Config table")
	assert(Config.Title, "Button - Missing Title")
	local Callback = Config.Callback or function() end

	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, true)
	Element.LabelHolder.Size = UDim2.new(1, -40, 0, 0)

	local IconImage = Config.Icon and ResolveImage(Config.Icon) or Assets.ChevronRight

	local ButtonIco = New("ImageLabel", {
		Image = IconImage,
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = Element.Frame,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	AddSignal(Element.Frame.MouseButton1Click, function()
		Library:SafeCallback(Callback)
	end)

	local ButtonObj = {
		Type = "Button",
		Frame = Element.Frame,
		SetTitle = function(_, Text) Element:SetTitle(Text) end,
		SetDesc = function(_, Text) Element:SetDesc(Text) end,
		Destroy = function() Element:Destroy() end,
	}

	return ButtonObj
end

-- 3. Toggle
function Elements:AddToggle(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Toggle - Missing Title")

	local Toggle = {
		Value = Config.Default or false,
		Callback = Config.Callback or function(Value) end,
		Changed = function(Value) end,
		Type = "Toggle",
	}

	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, true)
	Element.DescLabel.Size = UDim2.new(1, -56, 0, 14)

	Toggle.SetTitle = function(_, Text) Element:SetTitle(Text) end
	Toggle.SetDesc = function(_, Text) Element:SetDesc(Text) end

	local ToggleCircle = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 2, 0.5, 0),
		Image = Assets.Circle,
		ImageTransparency = 0.3,
		ThemeTag = {
			ImageColor3 = "ToggleSlider",
		},
	})

	local ToggleBorder = New("UIStroke", {
		Transparency = 0.5,
		ThemeTag = {
			Color = "ToggleSlider",
		},
	})

	local ToggleSlider = New("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Parent = Element.Frame,
		BackgroundTransparency = 1,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 9),
		}),
		ToggleBorder,
		ToggleCircle,
	})

	function Toggle:OnChanged(Func)
		Toggle.Changed = Func
		Func(Toggle.Value)
	end

	function Toggle:SetValue(Value)
		Value = not not Value
		Toggle.Value = Value

		Creator.OverrideTag(ToggleBorder, { Color = Toggle.Value and "Accent" or "ToggleSlider" })
		Creator.OverrideTag(ToggleCircle, { ImageColor3 = Toggle.Value and "ToggleToggled" or "ToggleSlider" })
		Tween(ToggleCircle, 0.22, { Position = UDim2.new(0, Toggle.Value and 20 or 2, 0.5, 0) })
		Tween(ToggleSlider, 0.22, { BackgroundTransparency = Toggle.Value and 0 or 1 })
		ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.3

		Library:SafeCallback(Toggle.Callback, Toggle.Value)
		Library:SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:Destroy()
		Element:Destroy()
		UnregisterOption(Idx, Toggle)
	end

	AddSignal(Element.Frame.MouseButton1Click, function()
		Toggle:SetValue(not Toggle.Value)
	end)

	Toggle:SetValue(Toggle.Value)
	RegisterOption(Idx, Toggle)
	return Toggle
end

-- 4. Slider
function Elements:AddSlider(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Slider - Missing Title")
	assert(Config.Min ~= nil, "Slider - Missing Min")
	assert(Config.Max ~= nil, "Slider - Missing Max")

	local Min = Config.Min
	local Max = Config.Max
	local Rounding = Config.Rounding or 0

	local Slider = {
		Value = math.clamp(Config.Default or Min, Min, Max),
		Min = Min,
		Max = Max,
		Rounding = Rounding,
		Callback = Config.Callback or function(Value) end,
		Changed = function(Value) end,
		Type = "Slider",
	}

	local Dragging = false
	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, false)
	Element.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Slider.SetTitle = function(_, Text) Element:SetTitle(Text) end
	Slider.SetDesc = function(_, Text) Element:SetDesc(Text) end

	local SliderDot = New("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = Assets.Circle,
		ZIndex = 3,
		ThemeTag = {
			ImageColor3 = "Accent",
		},
	})

	local SliderFill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 2,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})

	local SliderRail = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
	}, {
		SliderDot,
	})

	local SliderDisplay = New("TextLabel", {
		FontFace = Fonts.Medium,
		Text = tostring(Slider.Value),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 60, 0, 14),
		Position = UDim2.new(0, -8, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	local SliderInner = New("Frame", {
		Size = UDim2.new(0, 140, 0, 5),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundTransparency = 0.4,
		Parent = Element.Frame,
		ThemeTag = {
			BackgroundColor3 = "SliderRail",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		SliderDisplay,
		SliderFill,
		SliderRail,
	})

	local function UpdateSliderFromMouse(Input)
		local AbsPos = SliderRail.AbsolutePosition
		local AbsSize = SliderRail.AbsoluteSize
		local Scale = math.clamp((Input.Position.X - AbsPos.X) / AbsSize.X, 0, 1)
		local Value = Slider.Min + ((Slider.Max - Slider.Min) * Scale)
		Slider:SetValue(Value)
	end

	AddSignal(SliderRail.InputBegan, function(Input)
		if IsClickInput(Input) then
			Dragging = true
			UpdateSliderFromMouse(Input)
		end
	end)

	AddSignal(UserInputService.InputChanged, function(Input)
		if Dragging and IsMoveInput(Input) then
			UpdateSliderFromMouse(Input)
		end
	end)

	AddSignal(UserInputService.InputEnded, function(Input)
		if IsClickInput(Input) and Dragging then
			Dragging = false
		end
	end)

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	function Slider:SetValue(Value)
		Value = math.clamp(tonumber(Value) or Slider.Min, Slider.Min, Slider.Max)
		Value = Library:Round(Value, Slider.Rounding)
		Slider.Value = Value

		local Scale = (Slider.Max == Slider.Min) and 0 or ((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min))
		SliderDot.Position = UDim2.new(Scale, 0, 0.5, 0)
		SliderFill.Size = UDim2.fromScale(Scale, 1)
		SliderDisplay.Text = FormatNumber(Slider.Value, Slider.Rounding)

		Library:SafeCallback(Slider.Callback, Slider.Value)
		Library:SafeCallback(Slider.Changed, Slider.Value)
	end

	function Slider:Destroy()
		Element:Destroy()
		UnregisterOption(Idx, Slider)
	end

	Slider:SetValue(Slider.Value)
	RegisterOption(Idx, Slider)
	return Slider
end

-- 5. Dropdown
function Elements:AddDropdown(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Dropdown - Missing Title")

	local Dropdown = {
		Values = Config.Values or {},
		Value = Config.Default,
		Multi = Config.Multi or false,
		AllowNull = Config.AllowNull or false,
		Buttons = {},
		Opened = false,
		Type = "Dropdown",
		Callback = Config.Callback or function(Value) end,
		Changed = function(Value) end,
	}

	if Dropdown.Multi and type(Dropdown.Value) ~= "table" then
		Dropdown.Value = {}
	end

	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, false)
	Element.DescLabel.Size = UDim2.new(1, -180, 0, 14)

	Dropdown.SetTitle = function(_, Text) Element:SetTitle(Text) end
	Dropdown.SetDesc = function(_, Text) Element:SetDesc(Text) end

	local DropdownDisplay = New("TextLabel", {
		FontFace = Fonts.Regular,
		Text = "--",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 0, 14),
		Position = UDim2.new(0, 10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local DropdownIco = New("ImageLabel", {
		Image = Assets.ChevronDown,
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			ImageColor3 = "SubText",
		},
	})

	local DropdownInner = New("TextButton", {
		Size = UDim2.fromOffset(160, 30),
		Position = UDim2.new(1, -12, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.85,
		Parent = Element.Frame,
		ThemeTag = {
			BackgroundColor3 = "DropdownFrame",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		DropdownIco,
		DropdownDisplay,
	})

	local DropdownListLayout = New("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local DropdownScrollFrame = New("ScrollingFrame", {
		Size = UDim2.new(1, -8, 1, -10),
		Position = UDim2.fromOffset(5, 5),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 0.8,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		DropdownListLayout,
	})

	local DropdownHolderFrame = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = 0.4,
			ThemeTag = {
				Color = "DropdownBorder",
			},
		}),
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = Assets.ListShadow,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277),
			Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
			Position = UDim2.fromOffset(-15, -15),
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.25,
			ZIndex = 0,
		}),
		DropdownScrollFrame,
	})

	local DropdownHolderCanvas = New("Frame", {
		Name = "DropdownCanvas",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(160, 0),
		Parent = Library.GUI,
		Visible = false,
		ZIndex = 60,
	}, {
		DropdownHolderFrame,
	})
	table.insert(Library.OpenFrames, DropdownHolderCanvas)

	local function RecalculatePosition()
		if not Dropdown.Opened then return end
		local AbsPos = DropdownInner.AbsolutePosition
		local AbsSize = DropdownInner.AbsoluteSize
		local Viewport = GetViewportSize()

		local Height = DropdownHolderCanvas.Size.Y.Offset
		local Y = AbsPos.Y + AbsSize.Y + 4
		if Y + Height > Viewport.Y - 10 then
			Y = AbsPos.Y - Height - 4
		end

		DropdownHolderCanvas.Position = UDim2.fromOffset(AbsPos.X, Y)
	end

	local function RecalculateSize()
		local ItemCount = #Dropdown.Values
		local TotalHeight = math.min(ItemCount * 33 + 10, 220)
		DropdownHolderCanvas.Size = UDim2.fromOffset(math.max(DropdownInner.AbsoluteSize.X, 160), TotalHeight)
		DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y + 6)
	end

	AddSignal(DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y + 6)
	end)

	function Dropdown:Display()
		if Dropdown.Multi then
			local SelectedList = {}
			for _, Value in ipairs(Dropdown.Values) do
				if Dropdown.Value[Value] then
					table.insert(SelectedList, tostring(Value))
				end
			end
			DropdownDisplay.Text = #SelectedList > 0 and table.concat(SelectedList, ", ") or "--"
		else
			DropdownDisplay.Text = Dropdown.Value ~= nil and tostring(Dropdown.Value) or "--"
		end
	end

	function Dropdown:Open()
		Dropdown.Opened = true
		RecalculateSize()
		RecalculatePosition()
		DropdownHolderCanvas.Visible = true
		Tween(DropdownIco, 0.2, { Rotation = 180 })
	end

	function Dropdown:Close()
		Dropdown.Opened = false
		DropdownHolderCanvas.Visible = false
		Tween(DropdownIco, 0.2, { Rotation = 0 })
	end

	AddSignal(DropdownInner.MouseButton1Click, function()
		if Dropdown.Opened then
			Dropdown:Close()
		else
			Dropdown:Open()
		end
	end)

	AddSignal(UserInputService.InputBegan, function(Input)
		if IsClickInput(Input) and Dropdown.Opened then
			local MousePos = UserInputService:GetMouseLocation()
			local CanvasPos = DropdownHolderCanvas.AbsolutePosition
			local CanvasSize = DropdownHolderCanvas.AbsoluteSize
			local InnerPos = DropdownInner.AbsolutePosition
			local InnerSize = DropdownInner.AbsoluteSize

			local InCanvas = (MousePos.X >= CanvasPos.X and MousePos.X <= CanvasPos.X + CanvasSize.X and
				MousePos.Y >= CanvasPos.Y and MousePos.Y <= CanvasPos.Y + CanvasSize.Y)
			local InInner = (MousePos.X >= InnerPos.X and MousePos.X <= InnerPos.X + InnerSize.X and
				MousePos.Y >= InnerPos.Y and MousePos.Y <= InnerPos.Y + InnerSize.Y)

			if not InCanvas and not InInner then
				Dropdown:Close()
			end
		end
	end)

	AddSignal(DropdownInner:GetPropertyChangedSignal("AbsolutePosition"), RecalculatePosition)

	function Dropdown:BuildList()
		for _, Child in DropdownScrollFrame:GetChildren() do
			if Child:IsA("TextButton") then
				Child:Destroy()
			end
		end

		Dropdown.Buttons = {}

		for _, Val in ipairs(Dropdown.Values) do
			local ButtonSelector = New("Frame", {
				Size = UDim2.fromOffset(3, 14),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				ThemeTag = {
					BackgroundColor3 = "Accent",
				},
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			})

			local ItemButton = New("TextButton", {
				Size = UDim2.new(1, -4, 0, 30),
				BackgroundTransparency = 1,
				Text = "",
				Parent = DropdownScrollFrame,
				ThemeTag = {
					BackgroundColor3 = "DropdownOption",
				},
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
				ButtonSelector,
				New("TextLabel", {
					FontFace = Fonts.Regular,
					Text = tostring(Val),
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -18, 1, 0),
					Position = UDim2.fromOffset(12, 0),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ThemeTag = {
						TextColor3 = "Text",
					},
				}),
			})

			local function UpdateState()
				local IsSelected = false
				if Dropdown.Multi then
					IsSelected = Dropdown.Value[Val] == true
				else
					IsSelected = Dropdown.Value == Val
				end

				ButtonSelector.BackgroundTransparency = IsSelected and 0 or 1
				ItemButton.BackgroundTransparency = IsSelected and 0.82 or 1
			end

			AddSignal(ItemButton.MouseEnter, function()
				Tween(ItemButton, 0.15, { BackgroundTransparency = 0.85 })
			end)
			AddSignal(ItemButton.MouseLeave, function()
				UpdateState()
			end)
			AddSignal(ItemButton.MouseButton1Click, function()
				if Dropdown.Multi then
					Dropdown.Value[Val] = not Dropdown.Value[Val]
					if not Dropdown.Value[Val] then
						Dropdown.Value[Val] = nil
					end
				else
					if Dropdown.Value == Val and Dropdown.AllowNull then
						Dropdown.Value = nil
					else
						Dropdown.Value = Val
					end
					Dropdown:Close()
				end

				Dropdown:Display()
				Dropdown:BuildList()
				Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
				Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
			end)

			UpdateState()
			table.insert(Dropdown.Buttons, ItemButton)
		end

		RecalculateSize()
	end

	function Dropdown:SetValues(NewValues)
		Dropdown.Values = NewValues or {}
		Dropdown:BuildList()
		Dropdown:Display()
	end

	function Dropdown:SetValue(Val)
		if Dropdown.Multi then
			Dropdown.Value = {}
			if type(Val) == "table" then
				for K, V in pairs(Val) do
					if type(K) == "string" and V == true then
						Dropdown.Value[K] = true
					elseif type(V) == "string" then
						Dropdown.Value[V] = true
					end
				end
			end
		else
			Dropdown.Value = Val
		end

		Dropdown:Display()
		Dropdown:BuildList()
		Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
		Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
	end

	function Dropdown:OnChanged(Func)
		Dropdown.Changed = Func
		Func(Dropdown.Value)
	end

	function Dropdown:Destroy()
		DropdownHolderCanvas:Destroy()
		Element:Destroy()
		UnregisterOption(Idx, Dropdown)
	end

	Dropdown:BuildList()
	Dropdown:Display()
	RegisterOption(Idx, Dropdown)
	return Dropdown
end

-- 6. Input
function Elements:AddInput(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Input - Missing Title")

	local InputObj = {
		Value = Config.Default or "",
		Numeric = Config.Numeric or false,
		Finished = Config.Finished or false,
		Callback = Config.Callback or function(Value) end,
		Changed = function(Value) end,
		Type = "Input",
	}

	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, false)
	Element.DescLabel.Size = UDim2.new(1, -180, 0, 14)

	InputObj.SetTitle = function(_, Text) Element:SetTitle(Text) end
	InputObj.SetDesc = function(_, Text) Element:SetDesc(Text) end

	local InputIndicator = New("Frame", {
		Size = UDim2.new(1, -4, 0, 1),
		Position = UDim2.new(0, 2, 1, -1),
		BackgroundTransparency = 0.5,
		ThemeTag = {
			BackgroundColor3 = "InputIndicator",
		},
	})

	local TextBox = New("TextBox", {
		FontFace = Fonts.Regular,
		Text = tostring(InputObj.Value),
		PlaceholderText = Config.Placeholder or "...",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		ClearTextOnFocus = false,
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})

	local InputFrame = New("Frame", {
		Size = UDim2.fromOffset(160, 30),
		Position = UDim2.new(1, -12, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.85,
		Parent = Element.Frame,
		ThemeTag = {
			BackgroundColor3 = "Input",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		TextBox,
		InputIndicator,
	})

	AddSignal(TextBox.Focused, function()
		Tween(InputIndicator, 0.2, { Size = UDim2.new(1, -2, 0, 2), Position = UDim2.new(0, 1, 1, -2), BackgroundTransparency = 0 })
		Creator.OverrideTag(InputIndicator, { BackgroundColor3 = "Accent" })
	end)

	local function ApplyValue(Text)
		if InputObj.Numeric then
			local Num = tonumber(Text)
			if Num == nil and Text ~= "" then
				TextBox.Text = tostring(InputObj.Value)
				return
			end
		end

		InputObj.Value = TextBox.Text
		Library:SafeCallback(InputObj.Callback, InputObj.Value)
		Library:SafeCallback(InputObj.Changed, InputObj.Value)
	end

	AddSignal(TextBox.FocusLost, function(EnterPressed)
		Tween(InputIndicator, 0.2, { Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0, 2, 1, -1), BackgroundTransparency = 0.5 })
		Creator.OverrideTag(InputIndicator, { BackgroundColor3 = "InputIndicator" })

		if InputObj.Finished then
			if EnterPressed then
				ApplyValue(TextBox.Text)
			end
		else
			ApplyValue(TextBox.Text)
		end
	end)

	AddSignal(TextBox:GetPropertyChangedSignal("Text"), function()
		if not InputObj.Finished then
			ApplyValue(TextBox.Text)
		end
	end)

	function InputObj:SetValue(Text)
		InputObj.Value = tostring(Text or "")
		TextBox.Text = InputObj.Value
		Library:SafeCallback(InputObj.Callback, InputObj.Value)
		Library:SafeCallback(InputObj.Changed, InputObj.Value)
	end

	function InputObj:OnChanged(Func)
		InputObj.Changed = Func
		Func(InputObj.Value)
	end

	function InputObj:Destroy()
		Element:Destroy()
		UnregisterOption(Idx, InputObj)
	end

	RegisterOption(Idx, InputObj)
	return InputObj
end

-- 7. Keybind
function Elements:AddKeybind(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Keybind - Missing Title")

	local Keybind = {
		Value = Config.Default or "None",
		Mode = Config.Mode or "Toggle", -- "Toggle", "Hold", "Always"
		Toggled = false,
		Callback = Config.Callback or function(Value) end,
		ChangedCallback = Config.ChangedCallback or function(Key) end,
		Clicked = function(Value) end,
		Changed = function(Key) end,
		Type = "Keybind",
	}

	local Picking = false
	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, true)

	Keybind.SetTitle = function(_, Text) Element:SetTitle(Text) end
	Keybind.SetDesc = function(_, Text) Element:SetDesc(Text) end

	local KeybindDisplayLabel = New("TextLabel", {
		FontFace = Fonts.Medium,
		Text = tostring(Keybind.Value),
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local KeybindDisplayFrame = New("TextButton", {
		Size = UDim2.fromOffset(0, 30),
		Position = UDim2.new(1, -12, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.85,
		Parent = Element.Frame,
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		ThemeTag = {
			BackgroundColor3 = "Keybind",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		KeybindDisplayLabel,
	})

	function Keybind:GetState()
		if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
			return false
		end

		if Keybind.Mode == "Always" then
			return true
		elseif Keybind.Mode == "Hold" then
			if Keybind.Value == "None" or Keybind.Value == nil then
				return false
			end
			if Keybind.Value == "MB1" then
				return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			elseif Keybind.Value == "MB2" then
				return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			else
				local KeyCode = Enum.KeyCode[Keybind.Value]
				return KeyCode and UserInputService:IsKeyDown(KeyCode) or false
			end
		else
			return Keybind.Toggled
		end
	end

	function Keybind:SetValue(Key, Mode)
		Keybind.Value = Key or Keybind.Value
		Keybind.Mode = Mode or Keybind.Mode
		KeybindDisplayLabel.Text = tostring(Keybind.Value)
	end

	function Keybind:OnClick(Func)
		Keybind.Clicked = Func
	end

	function Keybind:OnChanged(Func)
		Keybind.Changed = Func
		Func(Keybind.Value)
	end

	local function DoTrigger()
		Library:SafeCallback(Keybind.Callback, Keybind.Toggled)
		Library:SafeCallback(Keybind.Clicked, Keybind.Toggled)
	end

	AddSignal(KeybindDisplayFrame.MouseButton1Click, function()
		Picking = true
		KeybindDisplayLabel.Text = "..."

		local Connection
		Connection = UserInputService.InputBegan:Connect(function(Input)
			local KeyName = nil
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				KeyName = Input.KeyCode.Name
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
				KeyName = "MB1"
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
				KeyName = "MB2"
			end

			if KeyName then
				Picking = false
				Keybind.Value = KeyName
				KeybindDisplayLabel.Text = KeyName
				Library:SafeCallback(Keybind.ChangedCallback, KeyName)
				Library:SafeCallback(Keybind.Changed, KeyName)
				Connection:Disconnect()
			end
		end)
	end)

	AddSignal(UserInputService.InputBegan, function(Input)
		if Picking or UserInputService:GetFocusedTextBox() then return end

		local Matches = false
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Keybind.Value then
			Matches = true
		elseif Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Value == "MB1" then
			Matches = true
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and Keybind.Value == "MB2" then
			Matches = true
		end

		if Matches then
			if Keybind.Mode == "Toggle" then
				Keybind.Toggled = not Keybind.Toggled
				DoTrigger()
			elseif Keybind.Mode == "Hold" then
				Keybind.Toggled = true
				DoTrigger()
			end
		end
	end)

	AddSignal(UserInputService.InputEnded, function(Input)
		if Picking or Keybind.Mode ~= "Hold" then return end

		local Matches = false
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Keybind.Value then
			Matches = true
		elseif Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Value == "MB1" then
			Matches = true
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and Keybind.Value == "MB2" then
			Matches = true
		end

		if Matches then
			Keybind.Toggled = false
			DoTrigger()
		end
	end)

	function Keybind:Destroy()
		Element:Destroy()
		UnregisterOption(Idx, Keybind)
	end

	RegisterOption(Idx, Keybind)
	return Keybind
end

-- 8. Colorpicker
function Elements:AddColorpicker(Idx, Config)
	Idx, Config = ParseArgs(Idx, Config)
	assert(Config.Title, "Colorpicker - Missing Title")

	local Colorpicker = {
		Value = Config.Default or Color3.fromRGB(96, 205, 255),
		Transparency = Config.Transparency or 0,
		Callback = Config.Callback or function(Color) end,
		Changed = function(Color, Transparency) end,
		Type = "Colorpicker",
	}

	local H, S, V = Colorpicker.Value:ToHSV()

	local Element = CreateElementFrame(Config.Title, Config.Description, self.Container, true)

	Colorpicker.SetTitle = function(_, Text) Element:SetTitle(Text) end
	Colorpicker.SetDesc = function(_, Text) Element:SetDesc(Text) end

	local ColorPreview = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colorpicker.Value,
		BackgroundTransparency = Colorpicker.Transparency,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})

	local ColorPreviewHolder = New("Frame", {
		Size = UDim2.fromOffset(26, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Parent = Element.Frame,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("ImageLabel", {
			Image = Assets.Checker,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(20, 20),
			Size = UDim2.fromScale(1, 1),
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		}),
		ColorPreview,
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
	})

	-- Modal dialog for picking HSV color
	local function OpenColorDialog()
		if not Library.Window then return end

		local DialogObj = Library.Window:CreateDialog()
		DialogObj.Title.Text = Config.Title or "Select Color"
		DialogObj.Root.Size = UDim2.fromOffset(360, 280)

		local SatVibMap = New("ImageLabel", {
			Image = Assets.SatVibMap,
			Size = UDim2.fromOffset(180, 140),
			Position = UDim2.fromOffset(20, 56),
			BackgroundColor3 = Color3.fromHSV(H, 1, 1),
			Parent = DialogObj.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})

		local PickerRing = New("ImageLabel", {
			Image = Assets.PickerRing,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(S, 0, 1 - V, 0),
			BackgroundTransparency = 1,
			Parent = SatVibMap,
		})

		-- Hue Bar
		local HueBar = New("Frame", {
			Size = UDim2.fromOffset(14, 140),
			Position = UDim2.fromOffset(212, 56),
			Parent = DialogObj.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
					ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
					ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.5, 1, 1)),
					ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
					ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
					ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
				}),
			}),
		})

		local HueDot = New("Frame", {
			Size = UDim2.new(1, 4, 0, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, H, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = HueBar,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		})

		-- Color info side panel
		local PreviewBox = New("Frame", {
			Size = UDim2.fromOffset(90, 40),
			Position = UDim2.fromOffset(242, 56),
			BackgroundColor3 = Colorpicker.Value,
			Parent = DialogObj.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			New("UIStroke", {
				Transparency = 0.5,
				ThemeTag = {
					Color = "DialogBorder",
				},
			}),
		})

		local HexLabel = New("TextLabel", {
			FontFace = Fonts.Medium,
			Text = "#" .. Colorpicker.Value:ToHex():upper(),
			TextSize = 13,
			Size = UDim2.fromOffset(90, 24),
			Position = UDim2.fromOffset(242, 102),
			BackgroundTransparency = 1,
			Parent = DialogObj.Root,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		local function RefreshDialogUI()
			local CurrentColor = Color3.fromHSV(H, S, V)
			SatVibMap.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
			PickerRing.Position = UDim2.new(S, 0, 1 - V, 0)
			HueDot.Position = UDim2.new(0.5, 0, H, 0)
			PreviewBox.BackgroundColor3 = CurrentColor
			HexLabel.Text = "#" .. CurrentColor:ToHex():upper()
			Colorpicker:SetValueRGB(CurrentColor, Colorpicker.Transparency)
		end

		local DraggingSat = false
		AddSignal(SatVibMap.InputBegan, function(Input)
			if IsClickInput(Input) then
				DraggingSat = true
				local Pos = Input.Position
				local AbsPos = SatVibMap.AbsolutePosition
				local AbsSize = SatVibMap.AbsoluteSize
				S = math.clamp((Pos.X - AbsPos.X) / AbsSize.X, 0, 1)
				V = 1 - math.clamp((Pos.Y - AbsPos.Y) / AbsSize.Y, 0, 1)
				RefreshDialogUI()
			end
		end)

		local DraggingHue = false
		AddSignal(HueBar.InputBegan, function(Input)
			if IsClickInput(Input) then
				DraggingHue = true
				local Pos = Input.Position
				local AbsPos = HueBar.AbsolutePosition
				local AbsSize = HueBar.AbsoluteSize
				H = math.clamp((Pos.Y - AbsPos.Y) / AbsSize.Y, 0, 1)
				RefreshDialogUI()
			end
		end)

		AddSignal(UserInputService.InputChanged, function(Input)
			if IsMoveInput(Input) then
				if DraggingSat then
					local Pos = Input.Position
					local AbsPos = SatVibMap.AbsolutePosition
					local AbsSize = SatVibMap.AbsoluteSize
					S = math.clamp((Pos.X - AbsPos.X) / AbsSize.X, 0, 1)
					V = 1 - math.clamp((Pos.Y - AbsPos.Y) / AbsSize.Y, 0, 1)
					RefreshDialogUI()
				elseif DraggingHue then
					local Pos = Input.Position
					local AbsPos = HueBar.AbsolutePosition
					local AbsSize = HueBar.AbsoluteSize
					H = math.clamp((Pos.Y - AbsPos.Y) / AbsSize.Y, 0, 1)
					RefreshDialogUI()
				end
			end
		end)

		AddSignal(UserInputService.InputEnded, function(Input)
			if IsClickInput(Input) then
				DraggingSat = false
				DraggingHue = false
			end
		end)

		DialogObj:Button("Done", function()
			RefreshDialogUI()
		end)

		DialogObj:Open()
	end

	AddSignal(Element.Frame.MouseButton1Click, OpenColorDialog)

	function Colorpicker:SetValueRGB(Color, Transparency)
		Colorpicker.Value = Color
		Colorpicker.Transparency = Transparency or Colorpicker.Transparency
		H, S, V = Colorpicker.Value:ToHSV()

		ColorPreview.BackgroundColor3 = Colorpicker.Value
		ColorPreview.BackgroundTransparency = Colorpicker.Transparency

		Library:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
		Library:SafeCallback(Colorpicker.Changed, Colorpicker.Value, Colorpicker.Transparency)
	end

	function Colorpicker:OnChanged(Func)
		Colorpicker.Changed = Func
		Func(Colorpicker.Value, Colorpicker.Transparency)
	end

	function Colorpicker:Destroy()
		Element:Destroy()
		UnregisterOption(Idx, Colorpicker)
	end

	RegisterOption(Idx, Colorpicker)
	return Colorpicker
end

--------------------------------------------------------------------------------
-- Tab & Section Architecture
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
		Name = Title or "Tab",
		Index = TabIndex,
		Selected = false,
		Type = "Tab",
	}

	local ResolvedIcon = ResolveImage(Icon)

	Tab.Button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = Parent,
		LayoutOrder = TabIndex,
		ThemeTag = {
			BackgroundColor3 = "Tab",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		New("ImageLabel", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = ResolvedIcon or "",
			Visible = ResolvedIcon ~= nil,
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		}),
		New("TextLabel", {
			Text = Tab.Name,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, ResolvedIcon and -38 or -20, 1, 0),
			Position = ResolvedIcon and UDim2.fromOffset(34, 0) or UDim2.fromOffset(12, 0),
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		}),
	})

	local ContainerLayout = New("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = TabModule.Window.ContainerHolder,
		Visible = false,
		ScrollBarImageTransparency = 0.85,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		ContainerLayout,
		New("UIPadding", {
			PaddingRight = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 10),
		}),
	})

	AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Tab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 14)
	end)

	AddSignal(Tab.Button.MouseEnter, function()
		if not Tab.Selected then
			Tween(Tab.Button, 0.15, { BackgroundTransparency = 0.92 })
		end
	end)
	AddSignal(Tab.Button.MouseLeave, function()
		if not Tab.Selected then
			Tween(Tab.Button, 0.15, { BackgroundTransparency = 1 })
		end
	end)
	AddSignal(Tab.Button.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Tabs[TabIndex] = Tab
	TabModule.Containers[TabIndex] = Tab.ContainerFrame

	Tab.Container = Tab.ContainerFrame
	Tab.ScrollFrame = Tab.ContainerFrame

	function Tab:AddSection(SectionTitle)
		local Section = {
			Type = "Section",
		}

		local SectionLayout = New("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		local SectionContainer = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.fromOffset(0, 24),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
		}, {
			SectionLayout,
		})

		local SectionRoot = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = NextLayoutOrder(),
			Parent = Tab.ContainerFrame,
		}, {
			New("TextLabel", {
				Text = SectionTitle,
				FontFace = Fonts.Heading,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			SectionContainer,
		})

		Section.Container = SectionContainer
		Section.ScrollFrame = Tab.ContainerFrame

		for Name, Func in pairs(Elements) do
			Section[Name] = function(self, ...)
				return Func(self, ...)
			end
		end

		return Section
	end

	for Name, Func in pairs(Elements) do
		Tab[Name] = function(self, ...)
			return Func(self, ...)
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
			Tween(TabObj.Button, 0.2, { BackgroundTransparency = 0.86 })
		else
			TabObj.Selected = false
			Tween(TabObj.Button, 0.2, { BackgroundTransparency = 1 })
		end
	end

	local CurrentTab = TabModule.Tabs[Index]
	if CurrentTab then
		Window.TabDisplay.Text = CurrentTab.Name

		local TabPos = CurrentTab.Button.AbsolutePosition.Y - Window.TabHolder.AbsolutePosition.Y
		Tween(Window.Selector, 0.25, { Position = UDim2.fromOffset(0, TabPos + 17) })

		for TabIdx, Container in pairs(TabModule.Containers) do
			Container.Visible = (TabIdx == Index)
		end
	end
end

--------------------------------------------------------------------------------
-- Window Implementation
--------------------------------------------------------------------------------

function Library:CreateWindow(Config)
	assert(type(Config) == "table", "CreateWindow - Config must be a table")
	assert(Config.Title, "CreateWindow - Missing Title")

	if Library.Window then
		print("[MellowUI] Window already exists.")
		return Library.Window
	end

	Library.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
	Library.Theme = Config.Theme or "Mellow"
	local InitialSize = Config.Size or UDim2.fromOffset(580, 460)
	local TabWidth = Config.TabWidth or 160

	local Viewport = GetViewportSize()
	local InitialPos = UDim2.fromOffset(
		math.max(10, Viewport.X / 2 - InitialSize.X.Offset / 2),
		math.max(10, Viewport.Y / 2 - InitialSize.Y.Offset / 2)
	)

	local Window = {
		Size = InitialSize,
		Position = InitialPos,
		TabWidth = TabWidth,
		Minimized = false,
		Maximized = false,
		OldSize = InitialSize,
		OldPosition = InitialPos,
	}

	local Paint = CreatePaint(true)
	Window.Paint = Paint

	-- Tab Selector indicator line
	local Selector = New("Frame", {
		Size = UDim2.fromOffset(3, 18),
		Position = UDim2.fromOffset(0, 17),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 5,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
	Window.Selector = Selector

	Window.TabHolder = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 2),
		}),
	})

	local TabFrame = New("Frame", {
		Size = UDim2.new(0, TabWidth, 1, -54),
		Position = UDim2.new(0, 0, 0, 48),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 4,
	}, {
		Window.TabHolder,
		Selector,
	})

	Window.TabDisplay = New("TextLabel", {
		FontFace = Fonts.Heading,
		Text = "Dashboard",
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -TabWidth - 36, 0, 24),
		Position = UDim2.fromOffset(TabWidth + 18, 52),
		BackgroundTransparency = 1,
		ZIndex = 4,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	Window.ContainerHolder = New("Frame", {
		Size = UDim2.new(1, -TabWidth - 28, 1, -90),
		Position = UDim2.fromOffset(TabWidth + 16, 82),
		BackgroundTransparency = 1,
		ZIndex = 4,
	})

	-- Resizing handle at bottom-right
	local ResizeHandle = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(1, -18, 1, -18),
		BackgroundTransparency = 1,
		ZIndex = 10,
	})

	Window.Root = New("Frame", {
		Name = "MellowWindow",
		Size = Window.Size,
		Position = Window.Position,
		BackgroundTransparency = 1,
		Parent = Library.GUI,
	}, {
		Paint.Frame,
		TabFrame,
		Window.TabDisplay,
		Window.ContainerHolder,
		ResizeHandle,
	})

	-- TitleBar setup
	local TitleBarFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = Window.Root,
		ZIndex = 6,
	}, {
		New("Frame", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.fromOffset(14, 0),
			BackgroundTransparency = 1,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 8),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			New("TextLabel", {
				Text = Config.Title,
				FontFace = Fonts.SemiBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
			New("TextLabel", {
				Text = Config.SubTitle or "",
				FontFace = Fonts.Regular,
				TextSize = 12,
				TextTransparency = 0.4,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.X,
				Visible = (Config.SubTitle ~= nil and Config.SubTitle ~= ""),
				BackgroundTransparency = 1,
				ThemeTag = {
					TextColor3 = "Text",
				},
			}),
		}),
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundTransparency = 0.4,
			ThemeTag = {
				BackgroundColor3 = "TitleBarLine",
			},
		}),
	})

	local function CreateBarButton(Icon, OffsetX, Callback)
		local Btn = New("TextButton", {
			Size = UDim2.fromOffset(30, 30),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, OffsetX, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = TitleBarFrame,
			Text = "",
			ThemeTag = {
				BackgroundColor3 = "Text",
			},
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			New("ImageLabel", {
				Image = Icon,
				Size = UDim2.fromOffset(16, 16),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				ThemeTag = {
					ImageColor3 = "Text",
				},
			}),
		})

		AddSignal(Btn.MouseEnter, function()
			Tween(Btn, 0.15, { BackgroundTransparency = 0.9 })
		end)
		AddSignal(Btn.MouseLeave, function()
			Tween(Btn, 0.15, { BackgroundTransparency = 1 })
		end)
		AddSignal(Btn.MouseButton1Click, Callback)
		return Btn
	end

	CreateBarButton(Assets.Close, -10, function()
		Window:Dialog({
			Title = "Close Interface",
			Content = "Are you sure you want to unload Mellow Hub?",
			Buttons = {
				{
					Title = "Unload",
					Callback = function()
						Library:Destroy()
					end,
				},
				{
					Title = "Cancel",
				},
			},
		})
	end)

	local MaxBtn = CreateBarButton(Assets.Max, -44, function()
		Window:Maximize()
	end)

	CreateBarButton(Assets.Min, -78, function()
		Window:Minimize()
	end)

	-- Dragging logic
	local Dragging = false
	local DragStart, StartPos
	AddSignal(TitleBarFrame.InputBegan, function(Input)
		if IsClickInput(Input) and not Window.Maximized then
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
		if IsClickInput(Input) then
			Dragging = false
		end
	end)

	-- Resizing logic
	local Resizing = false
	local ResizeStart, StartSize
	AddSignal(ResizeHandle.InputBegan, function(Input)
		if IsClickInput(Input) and not Window.Maximized then
			Resizing = true
			ResizeStart = Input.Position
			StartSize = Window.Root.Size
		end
	end)

	AddSignal(UserInputService.InputChanged, function(Input)
		if Resizing and IsMoveInput(Input) then
			local Delta = Input.Position - ResizeStart
			local NewW = math.clamp(StartSize.X.Offset + Delta.X, 480, 2048)
			local NewH = math.clamp(StartSize.Y.Offset + Delta.Y, 360, 2048)
			Window.Root.Size = UDim2.fromOffset(NewW, NewH)
			Window.Size = Window.Root.Size
		end
	end)

	AddSignal(UserInputService.InputEnded, function(Input)
		if IsClickInput(Input) then
			Resizing = false
		end
	end)

	-- Maximize / Restore
	function Window:Maximize()
		Window.Maximized = not Window.Maximized
		if Window.Maximized then
			Window.OldSize = Window.Root.Size
			Window.OldPosition = Window.Root.Position
			local Viewport = GetViewportSize()
			Tween(Window.Root, 0.25, { Size = UDim2.fromOffset(Viewport.X, Viewport.Y), Position = UDim2.fromOffset(0, 0) })
		else
			Tween(Window.Root, 0.25, { Size = Window.OldSize, Position = Window.OldPosition })
		end
	end

	-- Minimize / Toggle UI
	function Window:Minimize()
		Window.Minimized = not Window.Minimized
		Window.Root.Visible = not Window.Minimized

		for _, Flyout in ipairs(Library.OpenFrames) do
			Flyout.Visible = false
		end
	end

	-- Keybind toggle listener
	AddSignal(UserInputService.InputBegan, function(Input, Processed)
		if Processed or UserInputService:GetFocusedTextBox() then return end

		local KeyToMatch = Library.MinimizeKey
		if Library.MinimizeKeybind and Library.MinimizeKeybind.Value then
			local BindName = Library.MinimizeKeybind.Value
			if Enum.KeyCode[BindName] then
				KeyToMatch = Enum.KeyCode[BindName]
			end
		end

		if Input.KeyCode == KeyToMatch then
			Window:Minimize()
		end
	end)

	-- Dialog integration
	local DialogHandler = Dialog:Init(Window)
	function Window:CreateDialog()
		return DialogHandler:Create()
	end

	function Window:Dialog(DialogConfig)
		local DialogInstance = DialogHandler:Create()
		DialogInstance.Title.Text = DialogConfig.Title or "Dialog"

		local ContentLabel = New("TextLabel", {
			FontFace = Fonts.Regular,
			Text = DialogConfig.Content or "",
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Size = UDim2.new(1, -40, 0, 50),
			Position = UDim2.fromOffset(20, 54),
			BackgroundTransparency = 1,
			Parent = DialogInstance.Root,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		for _, Btn in ipairs(DialogConfig.Buttons or {}) do
			DialogInstance:Button(Btn.Title, Btn.Callback)
		end

		DialogInstance:Open()
		return DialogInstance
	end

	-- Tab management
	local TabHandler = TabModule:Init(Window)

	function Window:AddTab(TabConfig)
		assert(type(TabConfig) == "table", "AddTab - Missing TabConfig table")
		assert(TabConfig.Title, "AddTab - Missing Title")
		return TabHandler:New(TabConfig.Title, TabConfig.Icon, Window.TabHolder)
	end

	function Window:SelectTab(Index)
		TabHandler:SelectTab(Index or 1)
	end

	Library.Window = Window
	Creator.UpdateTheme()

	return Window
end

--------------------------------------------------------------------------------
-- Library Controls & Lifetime
--------------------------------------------------------------------------------

function Library:SetTheme(ThemeName)
	if Library.ThemeData[ThemeName] then
		Library.Theme = ThemeName
		Creator.UpdateTheme()
	end
end

function Library:ToggleTransparency(Value)
	Library.Transparency = not not Value
	local TransparencyVal = GetBackgroundTransparency()
	for Background in pairs(Paints) do
		if Background.Parent then
			Background.BackgroundTransparency = TransparencyVal
		end
	end
end

function Library:ToggleAcrylic(Value)
	Library.Acrylic = not not Value
end

function Library:Destroy()
	Library.Unloaded = true
	Creator.Disconnect()
	if Library.GUI then
		Library.GUI:Destroy()
	end
end

return Library

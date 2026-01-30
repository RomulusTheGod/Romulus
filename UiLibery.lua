if (game:GetService("CoreGui")):FindFirstChild("NoxHub") and (game:GetService("CoreGui")):FindFirstChild("ScreenGui") then
	(game:GetService("CoreGui")).NoxHub:Destroy();
	(game:GetService("CoreGui")).ScreenGui:Destroy();
end;

-- Novo esquema de cores: Preto, Branco, Vermelho e Cinza
_G.Primary = Color3.fromRGB(45, 45, 45); -- Cinza médio para elementos
_G.Dark = Color3.fromRGB(26, 26, 26); -- Cinza escuro para fundo
_G.Third = Color3.fromRGB(230, 57, 70); -- Vermelho para detalhes

function CreateRounded(Parent, Size)
	local Rounded = Instance.new("UICorner");
	Rounded.Name = "Rounded";
	Rounded.Parent = Parent;
	Rounded.CornerRadius = UDim.new(0, Size);
end;
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
function MakeDraggable(topbarobject, object)
	local Dragging = nil;
	local DragInput = nil;
	local DragStart = nil;
	local StartPosition = nil;
	local function Update(input)
		local Delta = input.Position - DragStart;
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y);
		local Tween = TweenService:Create(object, TweenInfo.new(0.15), {
			Position = pos
		});
		Tween:Play();
	end;
	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true;
			DragStart = input.Position;
			StartPosition = object.Position;
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false;
				end;
			end);
		end;
	end);
	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input;
		end;
	end);
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input);
		end;
	end);
end;
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Parent = game.CoreGui;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
local OutlineButton = Instance.new("Frame");
OutlineButton.Name = "OutlineButton";
OutlineButton.Parent = ScreenGui;
OutlineButton.ClipsDescendants = true;
OutlineButton.BackgroundColor3 = _G.Dark;
OutlineButton.BackgroundTransparency = 0;
OutlineButton.Position = UDim2.new(0, 10, 0, 10);
OutlineButton.Size = UDim2.new(0, 50, 0, 50);
CreateRounded(OutlineButton, 6);
local ImageButton = Instance.new("ImageButton");
ImageButton.Parent = OutlineButton;
ImageButton.Position = UDim2.new(0.5, 0, 0.5, 0);
ImageButton.Size = UDim2.new(0, 40, 0, 40);
ImageButton.AnchorPoint = Vector2.new(0.5, 0.5);
ImageButton.BackgroundColor3 = _G.Dark;
ImageButton.ImageColor3 = Color3.fromRGB(255, 255, 255);
ImageButton.ImageTransparency = 0;
ImageButton.BackgroundTransparency = 0;
ImageButton.Image = "rbxassetid://13940080072";
ImageButton.AutoButtonColor = false;
MakeDraggable(ImageButton, OutlineButton);
CreateRounded(ImageButton, 4);
ImageButton.MouseButton1Click:connect(function()
	(game.CoreGui:FindFirstChild("NoxHub")).Enabled = not (game.CoreGui:FindFirstChild("NoxHub")).Enabled;
end);
local NotificationFrame = Instance.new("ScreenGui");
NotificationFrame.Name = "NotificationFrame";
NotificationFrame.Parent = game.CoreGui;
NotificationFrame.ZIndexBehavior = Enum.ZIndexBehavior.Global;
local NotificationList = {};
local function RemoveOldestNotification()
	if #NotificationList > 0 then
		local removed = table.remove(NotificationList, 1);
		removed[1]:TweenPosition(UDim2.new(0.5, 0, -0.2, 0), "Out", "Quad", 0.4, true, function()
			removed[1]:Destroy();
		end);
	end;
end;
spawn(function()
	while wait() do
		if #NotificationList > 0 then
			wait(2);
			RemoveOldestNotification();
		end;
	end;
end);
local Update = {};
function Update:Notify(desc)
	local Frame = Instance.new("Frame");
	local Image = Instance.new("ImageLabel");
	local Title = Instance.new("TextLabel");
	local Desc = Instance.new("TextLabel");
	local OutlineFrame = Instance.new("Frame");
	OutlineFrame.Name = "OutlineFrame";
	OutlineFrame.Parent = NotificationFrame;
	OutlineFrame.ClipsDescendants = true;
	OutlineFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13);
	OutlineFrame.AnchorPoint = Vector2.new(0.5, 1);
	OutlineFrame.BackgroundTransparency = 0;
	OutlineFrame.Position = UDim2.new(0.5, 0, -0.2, 0);
	OutlineFrame.Size = UDim2.new(0, 412, 0, 72);
	Frame.Name = "Frame";
	Frame.Parent = OutlineFrame;
	Frame.ClipsDescendants = true;
	Frame.AnchorPoint = Vector2.new(0.5, 0.5);
	Frame.BackgroundColor3 = _G.Dark;
	Frame.BackgroundTransparency = 0;
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0);
	Frame.Size = UDim2.new(0, 400, 0, 60);
	Image.Name = "Icon";
	Image.Parent = Frame;
	Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	Image.BackgroundTransparency = 1;
	Image.Position = UDim2.new(0, 8, 0, 8);
	Image.Size = UDim2.new(0, 45, 0, 45);
	Image.Image = "rbxassetid://13940080072";
	Title.Parent = Frame;
	Title.BackgroundColor3 = _G.Primary;
	Title.BackgroundTransparency = 1;
	Title.Position = UDim2.new(0, 55, 0, 14);
	Title.Size = UDim2.new(0, 10, 0, 20);
	Title.Font = Enum.Font.GothamBold;
	Title.Text = "NoxHub";
	Title.TextColor3 = Color3.fromRGB(255, 255, 255);
	Title.TextSize = 16;
	Title.TextXAlignment = Enum.TextXAlignment.Left;
	Desc.Parent = Frame;
	Desc.BackgroundColor3 = _G.Primary;
	Desc.BackgroundTransparency = 1;
	Desc.Position = UDim2.new(0, 55, 0, 33);
	Desc.Size = UDim2.new(0, 10, 0, 10);
	Desc.Font = Enum.Font.GothamSemibold;
	Desc.TextTransparency = 0.2;
	Desc.Text = desc;
	Desc.TextColor3 = Color3.fromRGB(200, 200, 200);
	Desc.TextSize = 12;
	Desc.TextXAlignment = Enum.TextXAlignment.Left;
	CreateRounded(Frame, 4);
	CreateRounded(OutlineFrame, 6);
	OutlineFrame:TweenPosition(UDim2.new(0.5, 0, 0.1 + (#NotificationList) * 0.1, 0), "Out", "Quad", 0.4, true);
	table.insert(NotificationList, {
		OutlineFrame,
		title
	});
end;
function Update:StartLoad()
	local Loader = Instance.new("ScreenGui");
	Loader.Parent = game.CoreGui;
	Loader.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	Loader.DisplayOrder = 1000;
	local LoaderFrame = Instance.new("Frame");
	LoaderFrame.Name = "LoaderFrame";
	LoaderFrame.Parent = Loader;
	LoaderFrame.ClipsDescendants = true;
	LoaderFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13);
	LoaderFrame.BackgroundTransparency = 0;
	LoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	LoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
	LoaderFrame.Size = UDim2.new(1.5, 0, 1.5, 0);
	LoaderFrame.BorderSizePixel = 0;
	local MainLoaderFrame = Instance.new("Frame");
	MainLoaderFrame.Name = "MainLoaderFrame";
	MainLoaderFrame.Parent = LoaderFrame;
	MainLoaderFrame.ClipsDescendants = true;
	MainLoaderFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13);
	MainLoaderFrame.BackgroundTransparency = 0;
	MainLoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	MainLoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
	MainLoaderFrame.Size = UDim2.new(0.5, 0, 0.5, 0);
	MainLoaderFrame.BorderSizePixel = 0;
	local TitleLoader = Instance.new("TextLabel");
	TitleLoader.Parent = MainLoaderFrame;
	TitleLoader.Text = "NoxHub";
	TitleLoader.Font = Enum.Font.FredokaOne;
	TitleLoader.TextSize = 50;
	TitleLoader.TextColor3 = Color3.fromRGB(255, 255, 255);
	TitleLoader.BackgroundTransparency = 1;
	TitleLoader.AnchorPoint = Vector2.new(0.5, 0.5);
	TitleLoader.Position = UDim2.new(0.5, 0, 0.3, 0);
	TitleLoader.Size = UDim2.new(0.8, 0, 0.2, 0);
	TitleLoader.TextTransparency = 0;
	local DescriptionLoader = Instance.new("TextLabel");
	DescriptionLoader.Parent = MainLoaderFrame;
	DescriptionLoader.Text = "Loading..";
	DescriptionLoader.Font = Enum.Font.Gotham;
	DescriptionLoader.TextSize = 15;
	DescriptionLoader.TextColor3 = Color3.fromRGB(255, 255, 255);
	DescriptionLoader.BackgroundTransparency = 1;
	DescriptionLoader.AnchorPoint = Vector2.new(0.5, 0.5);
	DescriptionLoader.Position = UDim2.new(0.5, 0, 0.6, 0);
	DescriptionLoader.Size = UDim2.new(0.8, 0, 0.2, 0);
	DescriptionLoader.TextTransparency = 0;
	local LoadingBarBackground = Instance.new("Frame");
	LoadingBarBackground.Parent = MainLoaderFrame;
	LoadingBarBackground.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
	LoadingBarBackground.AnchorPoint = Vector2.new(0.5, 0.5);
	LoadingBarBackground.Position = UDim2.new(0.5, 0, 0.7, 0);
	LoadingBarBackground.Size = UDim2.new(0.7, 0, 0.05, 0);
	LoadingBarBackground.ClipsDescendants = true;
	LoadingBarBackground.BorderSizePixel = 0;
	LoadingBarBackground.ZIndex = 2;
	local LoadingBar = Instance.new("Frame");
	LoadingBar.Parent = LoadingBarBackground;
	LoadingBar.BackgroundColor3 = _G.Third;
	LoadingBar.Size = UDim2.new(0, 0, 1, 0);
	LoadingBar.ZIndex = 3;
	CreateRounded(LoadingBarBackground, 3);
	CreateRounded(LoadingBar, 3);
	local tweenService = game:GetService("TweenService");
	local dotCount = 0;
	local running = true;
	local barTweenInfoPart1 = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local barTweenPart1 = tweenService:Create(LoadingBar, barTweenInfoPart1, {
		Size = UDim2.new(0.25, 0, 1, 0)
	});
	local barTweenInfoPart2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
	local barTweenPart2 = tweenService:Create(LoadingBar, barTweenInfoPart2, {
		Size = UDim2.new(1, 0, 1, 0)
	});
	barTweenPart1:Play();
	function Update:Loaded()
		barTweenPart2:Play();
	end;
	barTweenPart1.Completed:Connect(function()
		running = true;
		barTweenPart2.Completed:Connect(function()
			wait(1);
			running = false;
			DescriptionLoader.Text = "Loaded!";
			wait(0.5);
			Loader:Destroy();
		end);
	end);
	spawn(function()
		while running do
			dotCount = (dotCount + 1) % 4;
			local dots = string.rep(".", dotCount);
			DescriptionLoader.Text = "Please wait" .. dots;
			wait(0.5);
		end;
	end);
end;
local SettingsLib = {
	SaveSettings = true,
	LoadAnimation = true
};
(getgenv()).LoadConfig = function()
	if readfile and writefile and isfile and isfolder then
		if not isfolder("NoxHub") then
			makefolder("NoxHub");
		end;
		if not isfolder("NoxHub/Library/") then
			makefolder("NoxHub/Library/");
		end;
		if not isfile(("NoxHub/Library/" .. game.Players.LocalPlayer.Name .. ".json")) then
			writefile("NoxHub/Library/" .. game.Players.LocalPlayer.Name .. ".json", (game:GetService("HttpService")):JSONEncode(SettingsLib));
		else
			SettingsLib = (game:GetService("HttpService")):JSONDecode(readfile("NoxHub/Library/" .. game.Players.LocalPlayer.Name .. ".json"));
		end;
	end;
end;
(getgenv()).SaveConfig = function()
	if writefile and isfile and isfolder then
		if not isfolder("NoxHub") then
			makefolder("NoxHub");
		end;
		if not isfolder("NoxHub/Library/") then
			makefolder("NoxHub/Library/");
		end;
		writefile("NoxHub/Library/" .. game.Players.LocalPlayer.Name .. ".json", (game:GetService("HttpService")):JSONEncode(SettingsLib));
	end;
end;
(getgenv()).LoadConfig();
local Library = {};
function Library:Window(WindowConfig)
	WindowConfig.Name = WindowConfig.Name or "NoxHub";
	WindowConfig.Size = WindowConfig.Size or UDim2.new(0, 500, 0, 400);
	WindowConfig.TabWidth = WindowConfig.TabWidth or 150;
	local NoxHub = Instance.new("ScreenGui");
	NoxHub.Name = "NoxHub";
	NoxHub.Parent = game.CoreGui;
	NoxHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	local OutlineMain = Instance.new("Frame");
	OutlineMain.Name = "OutlineMain";
	OutlineMain.Parent = NoxHub;
	OutlineMain.BackgroundColor3 = Color3.fromRGB(13, 13, 13);
	OutlineMain.Position = UDim2.new(0.5, 0, 0.5, 0);
	OutlineMain.AnchorPoint = Vector2.new(0.5, 0.5);
	OutlineMain.Size = UDim2.new(WindowConfig.Size.X.Scale, WindowConfig.Size.X.Offset + 15, WindowConfig.Size.Y.Scale, WindowConfig.Size.Y.Offset + 15);
	OutlineMain.BackgroundTransparency = 0;
	CreateRounded(OutlineMain, 6);
	local Main = Instance.new("Frame");
	Main.Name = "Main";
	Main.Parent = OutlineMain;
	Main.BackgroundColor3 = _G.Dark;
	Main.Position = UDim2.new(0, 7.5, 0, 7.5);
	Main.Size = WindowConfig.Size;
	Main.BackgroundTransparency = 0;
	CreateRounded(Main, 4);
	local Config = Instance.new("Frame");
	Config.Name = "Config";
	Config.Parent = Main;
	Config.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	Config.BackgroundTransparency = 1;
	Config.Size = WindowConfig.Size;
	local Top = Instance.new("Frame");
	Top.Name = "Top";
	Top.Parent = Main;
	Top.BackgroundColor3 = _G.Primary;
	Top.BackgroundTransparency = 0;
	Top.Size = UDim2.new(1, 0, 0, 40);
	CreateRounded(Top, 4);
	local BottomCover = Instance.new("Frame");
	BottomCover.Name = "BottomCover";
	BottomCover.Parent = Top;
	BottomCover.BackgroundColor3 = _G.Primary;
	BottomCover.BorderSizePixel = 0;
	BottomCover.Position = UDim2.new(0, 0, 1, -4);
	BottomCover.Size = UDim2.new(1, 0, 0, 4);
	local Title = Instance.new("TextLabel");
	Title.Name = "Title";
	Title.Parent = Top;
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	Title.BackgroundTransparency = 1;
	Title.Position = UDim2.new(0, 10, 0, 0);
	Title.Size = UDim2.new(0.5, 0, 1, 0);
	Title.Font = Enum.Font.GothamBold;
	Title.Text = WindowConfig.Name;
	Title.TextColor3 = Color3.fromRGB(255, 255, 255);
	Title.TextSize = 16;
	Title.TextXAlignment = Enum.TextXAlignment.Left;
	local DragButton = Instance.new("ImageButton");
	DragButton.Name = "DragButton";
	DragButton.Parent = Top;
	DragButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	DragButton.BackgroundTransparency = 1;
	DragButton.Position = UDim2.new(1, -30, 0.5, 0);
	DragButton.AnchorPoint = Vector2.new(0, 0.5);
	DragButton.Size = UDim2.new(0, 20, 0, 20);
	DragButton.Image = "rbxassetid://11963352306";
	DragButton.ImageColor3 = Color3.fromRGB(255, 255, 255);
	local SettingsButton = Instance.new("ImageButton");
	SettingsButton.Name = "SettingsButton";
	SettingsButton.Parent = Top;
	SettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	SettingsButton.BackgroundTransparency = 1;
	SettingsButton.Position = UDim2.new(1, -55, 0.5, 0);
	SettingsButton.AnchorPoint = Vector2.new(0, 0.5);
	SettingsButton.Size = UDim2.new(0, 20, 0, 20);
	SettingsButton.Image = "rbxassetid://10734950309";
	SettingsButton.ImageColor3 = Color3.fromRGB(255, 255, 255);
	local SettingsFrame = Instance.new("Frame");
	SettingsFrame.Name = "SettingsFrame";
	SettingsFrame.Parent = Main;
	SettingsFrame.BackgroundColor3 = _G.Dark;
	SettingsFrame.Position = UDim2.new(0, 8, 0, Top.Size.Y.Offset);
	SettingsFrame.Size = UDim2.new(Config.Size.X.Scale, Config.Size.X.Offset - 16, Config.Size.Y.Scale, Config.Size.Y.Offset - Top.Size.Y.Offset - 8);
	SettingsFrame.Visible = false;
	SettingsFrame.BackgroundTransparency = 0;
	CreateRounded(SettingsFrame, 4);
	SettingsButton.MouseButton1Click:Connect(function()
		SettingsFrame.Visible = not SettingsFrame.Visible;
	end);
	local SettingsTitle = Instance.new("TextLabel");
	SettingsTitle.Name = "SettingsTitle";
	SettingsTitle.Parent = SettingsFrame;
	SettingsTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	SettingsTitle.BackgroundTransparency = 1;
	SettingsTitle.Position = UDim2.new(0, 10, 0, 10);
	SettingsTitle.Size = UDim2.new(1, -20, 0, 30);
	SettingsTitle.Font = Enum.Font.GothamBold;
	SettingsTitle.Text = "Settings";
	SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
	SettingsTitle.TextSize = 20;
	SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left;
	local SettingsDesc = Instance.new("TextLabel");
	SettingsDesc.Name = "SettingsDesc";
	SettingsDesc.Parent = SettingsFrame;
	SettingsDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	SettingsDesc.BackgroundTransparency = 1;
	SettingsDesc.Position = UDim2.new(0, 10, 0, 35);
	SettingsDesc.Size = UDim2.new(1, -20, 0, 20);
	SettingsDesc.Font = Enum.Font.Gotham;
	SettingsDesc.Text = "Customize your experience";
	SettingsDesc.TextColor3 = Color3.fromRGB(180, 180, 180);
	SettingsDesc.TextSize = 13;
	SettingsDesc.TextXAlignment = Enum.TextXAlignment.Left;
	local SettingsMenuList = Instance.new("Frame");
	SettingsMenuList.Name = "SettingsMenuList";
	SettingsMenuList.Parent = SettingsFrame;
	SettingsMenuList.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	SettingsMenuList.BackgroundTransparency = 1;
	SettingsMenuList.Position = UDim2.new(0, 0, 0, 70);
	SettingsMenuList.Size = UDim2.new(1, 0, 1, -70);
	CreateRounded(SettingsMenuList, 4);
	local ScrollSettings = Instance.new("ScrollingFrame");
	ScrollSettings.Name = "ScrollSettings";
	ScrollSettings.Parent = SettingsMenuList;
	ScrollSettings.Active = true;
	ScrollSettings.BackgroundColor3 = Color3.fromRGB(13, 13, 13);
	ScrollSettings.Position = UDim2.new(0, 0, 0, 0);
	ScrollSettings.BackgroundTransparency = 1;
	ScrollSettings.Size = UDim2.new(1, 0, 1, 0);
	ScrollSettings.ScrollBarThickness = 3;
	ScrollSettings.ScrollingDirection = Enum.ScrollingDirection.Y;
	CreateRounded(SettingsMenuList, 4);
	local SettingsListLayout = Instance.new("UIListLayout");
	SettingsListLayout.Name = "SettingsListLayout";
	SettingsListLayout.Parent = ScrollSettings;
	SettingsListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	SettingsListLayout.Padding = UDim.new(0, 8);
	local PaddingScroll = Instance.new("UIPadding");
	PaddingScroll.Name = "PaddingScroll";
	PaddingScroll.Parent = ScrollSettings;
	function CreateCheckbox(title, state, callback)
		local checked = state or false;
		local Background = Instance.new("Frame");
		Background.Name = "Background";
		Background.Parent = ScrollSettings;
		Background.ClipsDescendants = true;
		Background.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
		Background.BackgroundTransparency = 1;
		Background.Size = UDim2.new(1, 0, 0, 20);
		local Title = Instance.new("TextLabel");
		Title.Name = "Title";
		Title.Parent = Background;
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		Title.BackgroundTransparency = 1;
		Title.Position = UDim2.new(0, 60, 0.5, 0);
		Title.Size = UDim2.new(1, -60, 0, 20);
		Title.Font = Enum.Font.Code;
		Title.AnchorPoint = Vector2.new(0, 0.5);
		Title.Text = title or "";
		Title.TextSize = 15;
		Title.TextColor3 = Color3.fromRGB(255, 255, 255);
		Title.TextXAlignment = Enum.TextXAlignment.Left;
		local Checkbox = Instance.new("ImageButton");
		Checkbox.Name = "Checkbox";
		Checkbox.Parent = Background;
		Checkbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
		Checkbox.BackgroundTransparency = 0;
		Checkbox.AnchorPoint = Vector2.new(0, 0.5);
		Checkbox.Position = UDim2.new(0, 30, 0.5, 0);
		Checkbox.Size = UDim2.new(0, 20, 0, 20);
		Checkbox.Image = "rbxassetid://10709790644";
		Checkbox.ImageTransparency = 1;
		Checkbox.ImageColor3 = Color3.fromRGB(255, 255, 255);
		CreateRounded(Checkbox, 3);
		Checkbox.MouseButton1Click:Connect(function()
			checked = not checked;
			if checked then
				Checkbox.ImageTransparency = 0;
				Checkbox.BackgroundColor3 = _G.Third;
			else
				Checkbox.ImageTransparency = 1;
				Checkbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
			end;
			pcall(callback, checked);
		end);
		if checked then
			Checkbox.ImageTransparency = 0;
			Checkbox.BackgroundColor3 = _G.Third;
		else
			Checkbox.ImageTransparency = 1;
			Checkbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
		end;
		pcall(callback, checked);
	end;
	function CreateButton(title, callback)
		local Background = Instance.new("Frame");
		Background.Name = "Background";
		Background.Parent = ScrollSettings;
		Background.ClipsDescendants = true;
		Background.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
		Background.BackgroundTransparency = 1;
		Background.Size = UDim2.new(1, 0, 0, 30);
		local Button = Instance.new("TextButton");
		Button.Name = "Button";
		Button.Parent = Background;
		Button.BackgroundColor3 = _G.Third;
		Button.BackgroundTransparency = 0;
		Button.Size = UDim2.new(0.8, 0, 0, 30);
		Button.Font = Enum.Font.Code;
		Button.Text = title or "Button";
		Button.AnchorPoint = Vector2.new(0.5, 0);
		Button.Position = UDim2.new(0.5, 0, 0, 0);
		Button.TextColor3 = Color3.fromRGB(255, 255, 255);
		Button.TextSize = 15;
		Button.AutoButtonColor = false;
		Button.MouseButton1Click:Connect(function()
			callback();
		end);
		CreateRounded(Button, 3);
	end;
	CreateCheckbox("Save Settings", SettingsLib.SaveSettings, function(state)
		SettingsLib.SaveSettings = state;
		(getgenv()).SaveConfig();
	end);
	CreateCheckbox("Loading Animation", SettingsLib.LoadAnimation, function(state)
		SettingsLib.LoadAnimation = state;
		(getgenv()).SaveConfig();
	end);
	CreateButton("Reset Config", function()
		if isfolder("NoxHub") then
			delfolder("NoxHub");
		end;
		Update:Notify("Config has been reseted!");
	end);
	local Tab = Instance.new("Frame");
	Tab.Name = "Tab";
	Tab.Parent = Main;
	Tab.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
	Tab.Position = UDim2.new(0, 8, 0, Top.Size.Y.Offset);
	Tab.BackgroundTransparency = 1;
	Tab.Size = UDim2.new(0, WindowConfig.TabWidth, Config.Size.Y.Scale, Config.Size.Y.Offset - Top.Size.Y.Offset - 8);
	local BtnStroke = Instance.new("UIStroke");
	local ScrollTab = Instance.new("ScrollingFrame");
	ScrollTab.Name = "ScrollTab";
	ScrollTab.Parent = Tab;
	ScrollTab.Active = true;
	ScrollTab.BackgroundColor3 = Color3.fromRGB(13, 13, 13);
	ScrollTab.Position = UDim2.new(0, 0, 0, 0);
	ScrollTab.BackgroundTransparency = 1;
	ScrollTab.Size = UDim2.new(1, 0, 1, 0);
	ScrollTab.ScrollBarThickness = 0;
	ScrollTab.ScrollingDirection = Enum.ScrollingDirection.Y;
	CreateRounded(Tab, 4);
	local TabListLayout = Instance.new("UIListLayout");
	TabListLayout.Name = "TabListLayout";
	TabListLayout.Parent = ScrollTab;
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	TabListLayout.Padding = UDim.new(0, 2);
	local PPD = Instance.new("UIPadding");
	PPD.Name = "PPD";
	PPD.Parent = ScrollTab;
	local Page = Instance.new("Frame");
	Page.Name = "Page";
	Page.Parent = Main;
	Page.BackgroundColor3 = _G.Dark;
	Page.Position = UDim2.new(0, Tab.Size.X.Offset + 18, 0, Top.Size.Y.Offset);
	Page.Size = UDim2.new(Config.Size.X.Scale, Config.Size.X.Offset - Tab.Size.X.Offset - 25, Config.Size.Y.Scale, Config.Size.Y.Offset - Top.Size.Y.Offset - 8);
	Page.BackgroundTransparency = 1;
	CreateRounded(Page, 4);
	local MainPage = Instance.new("Frame");
	MainPage.Name = "MainPage";
	MainPage.Parent = Page;
	MainPage.ClipsDescendants = true;
	MainPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	MainPage.BackgroundTransparency = 1;
	MainPage.Size = UDim2.new(1, 0, 1, 0);
	local PageList = Instance.new("Folder");
	PageList.Name = "PageList";
	PageList.Parent = MainPage;
	local UIPageLayout = Instance.new("UIPageLayout");
	UIPageLayout.Parent = PageList;
	UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	UIPageLayout.EasingDirection = Enum.EasingDirection.InOut;
	UIPageLayout.EasingStyle = Enum.EasingStyle.Quad;
	UIPageLayout.FillDirection = Enum.FillDirection.Vertical;
	UIPageLayout.Padding = UDim.new(0, 10);
	UIPageLayout.TweenTime = 0;
	UIPageLayout.GamepadInputEnabled = false;
	UIPageLayout.ScrollWheelInputEnabled = false;
	UIPageLayout.TouchInputEnabled = false;
	MakeDraggable(Top, OutlineMain);
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Insert then
			(game.CoreGui:FindFirstChild("NoxHub")).Enabled = not (game.CoreGui:FindFirstChild("NoxHub")).Enabled;
		end;
	end);
	local Dragging = false;
	DragButton.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true;
		end;
	end);
	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false;
		end;
	end);
	UserInputService.InputChanged:Connect(function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			OutlineMain.Size = UDim2.new(0, math.clamp(Input.Position.X - Main.AbsolutePosition.X + 15, WindowConfig.Size.X.Offset + 15, math.huge), 0, math.clamp(Input.Position.Y - Main.AbsolutePosition.Y + 15, WindowConfig.Size.Y.Offset + 15, math.huge));
			Main.Size = UDim2.new(0, math.clamp(Input.Position.X - Main.AbsolutePosition.X, WindowConfig.Size.X.Offset, math.huge), 0, math.clamp(Input.Position.Y - Main.AbsolutePosition.Y, WindowConfig.Size.Y.Offset, math.huge));
			Page.Size = UDim2.new(0, math.clamp(Input.Position.X - Page.AbsolutePosition.X - 8, WindowConfig.Size.X.Offset - Tab.Size.X.Offset - 25, math.huge), 0, math.clamp(Input.Position.Y - Page.AbsolutePosition.Y - 8, WindowConfig.Size.Y.Offset - Top.Size.Y.Offset - 10, math.huge));
			Tab.Size = UDim2.new(0, WindowConfig.TabWidth, 0, math.clamp(Input.Position.Y - Tab.AbsolutePosition.Y - 8, WindowConfig.Size.Y.Offset - Top.Size.Y.Offset - 10, math.huge));
		end;
	end);
	local uitab = {};
	function uitab:Tab(text, img)
		local BtnStroke = Instance.new("UIStroke");
		local TabButton = Instance.new("TextButton");
		local title = Instance.new("TextLabel");
		local TUICorner = Instance.new("UICorner");
		local UICorner = Instance.new("UICorner");
		local Title = Instance.new("TextLabel");
		TabButton.Parent = ScrollTab;
		TabButton.Name = text .. "Unique";
		TabButton.Text = "";
		TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
		TabButton.BackgroundTransparency = 1;
		TabButton.Size = UDim2.new(1, 0, 0, 35);
		TabButton.Font = Enum.Font.Nunito;
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255);
		TabButton.TextSize = 12;
		TabButton.TextTransparency = 0.9;
		local SelectedTab = Instance.new("Frame");
		SelectedTab.Name = "SelectedTab";
		SelectedTab.Parent = TabButton;
		SelectedTab.BackgroundColor3 = _G.Third;
		SelectedTab.BackgroundTransparency = 0;
		SelectedTab.Size = UDim2.new(0, 3, 0, 0);
		SelectedTab.Position = UDim2.new(0, 0, 0.5, 0);
		SelectedTab.AnchorPoint = Vector2.new(0, 0.5);
		UICorner.CornerRadius = UDim.new(0, 2);
		UICorner.Parent = SelectedTab;
		Title.Parent = TabButton;
		Title.Name = "Title";
		Title.BackgroundColor3 = Color3.fromRGB(150, 150, 150);
		Title.BackgroundTransparency = 1;
		Title.Position = UDim2.new(0, 30, 0.5, 0);
		Title.Size = UDim2.new(0, 100, 0, 30);
		Title.Font = Enum.Font.Roboto;
		Title.Text = text;
		Title.AnchorPoint = Vector2.new(0, 0.5);
		Title.TextColor3 = Color3.fromRGB(255, 255, 255);
		Title.TextTransparency = 0.3;
		Title.TextSize = 14;
		Title.TextXAlignment = Enum.TextXAlignment.Left;
		local IDK = Instance.new("ImageLabel");
		IDK.Name = "IDK";
		IDK.Parent = TabButton;
		IDK.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		IDK.BackgroundTransparency = 1;
		IDK.ImageTransparency = 0.3;
		IDK.Position = UDim2.new(0, 7, 0.5, 0);
		IDK.Size = UDim2.new(0, 15, 0, 15);
		IDK.AnchorPoint = Vector2.new(0, 0.5);
		IDK.Image = img or "rbxassetid://10734950309";
		local MainFrame = Instance.new("ScrollingFrame");
		MainFrame.Name = text .. "Page";
		MainFrame.Parent = PageList;
		MainFrame.Active = true;
		MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		MainFrame.BackgroundTransparency = 1;
		MainFrame.BorderSizePixel = 0;
		MainFrame.Size = UDim2.new(1, 0, 1, 0);
		MainFrame.ScrollBarThickness = 3;
		MainFrame.ScrollingDirection = Enum.ScrollingDirection.Y;
		local MainFramePage = Instance.new("Frame");
		MainFramePage.Name = "MainFramePage";
		MainFramePage.Parent = MainFrame;
		MainFramePage.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		MainFramePage.BackgroundTransparency = 1;
		MainFramePage.Size = UDim2.new(1, 0, 1, 0);
		local PageListLayout = Instance.new("UIListLayout");
		PageListLayout.Parent = MainFramePage;
		PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		PageListLayout.Padding = UDim.new(0, 5);
		MainFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			MainFrame.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y);
		end);
		TabButton.MouseButton1Click:Connect(function()
			for i, v in next, ScrollTab:GetChildren() do
				if v:IsA("TextButton") then
					(TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 1
					})):Play();
					(TweenService:Create(v.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextTransparency = 0.3
					})):Play();
					(TweenService:Create(v.IDK, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 0.3
					})):Play();
					(TweenService:Create(v.SelectedTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 3, 0, 0)
					})):Play();
				end;
			end;
			(TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.9
			})):Play();
			(TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			})):Play();
			(TweenService:Create(IDK, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			})):Play();
			(TweenService:Create(SelectedTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 3, 0, 20)
			})):Play();
			for i, v in next, PageList:GetChildren() do
				if v.Name == (text .. "Page") then
					currentpage = v.Name;
					UIPageLayout:JumpTo(v);
				end;
			end;
		end);
		if abc == false then
			abc = true;
			for i, v in next, ScrollTab:GetChildren() do
				if v:IsA("TextButton") then
					(TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 1
					})):Play();
					(TweenService:Create(v.Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextTransparency = 0.3
					})):Play();
					(TweenService:Create(v.IDK, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 0.3
					})):Play();
					(TweenService:Create(v.SelectedTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 3, 0, 0)
					})):Play();
				end;
			end;
			(TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.9
			})):Play();
			(TweenService:Create(Title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			})):Play();
			(TweenService:Create(IDK, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			})):Play();
			(TweenService:Create(SelectedTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 3, 0, 20)
			})):Play();
			for i, v in next, PageList:GetChildren() do
				if v.Name == (text .. "Page") then
					currentpage = v.Name;
					UIPageLayout:JumpTo(v);
				end;
			end;
		end;
		local main = {};
		function main:Button(text, callback)
			local Button = Instance.new("TextButton");
			local UICorner = Instance.new("UICorner");
			local Title = Instance.new("TextLabel");
			Button.Name = "Button";
			Button.Parent = MainFramePage;
			Button.BackgroundColor3 = _G.Primary;
			Button.BackgroundTransparency = 0.8;
			Button.Size = UDim2.new(1, 0, 0, 35);
			Button.AutoButtonColor = false;
			Button.Font = Enum.Font.SourceSans;
			Button.Text = "";
			Button.TextColor3 = Color3.fromRGB(0, 0, 0);
			Button.TextSize = 14;
			UICorner.CornerRadius = UDim.new(0, 3);
			UICorner.Parent = Button;
			Title.Name = "Title";
			Title.Parent = Button;
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Title.BackgroundTransparency = 1;
			Title.Size = UDim2.new(1, 0, 1, 0);
			Title.Font = Enum.Font.Cartoon;
			Title.Text = text;
			Title.TextColor3 = Color3.fromRGB(255, 255, 255);
			Title.TextSize = 15;
			Button.MouseButton1Click:Connect(function()
				pcall(callback);
			end);
			Button.MouseEnter:Connect(function()
				(TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.6
				})):Play();
			end);
			Button.MouseLeave:Connect(function()
				(TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.8
				})):Play();
			end);
		end;
		function main:Toggle(text, config, callback)
			local toggled = config or false;
			local Toggle = Instance.new("Frame");
			local UICorner = Instance.new("UICorner");
			local Title = Instance.new("TextLabel");
			local ToggleFrame = Instance.new("Frame");
			local UICorner_2 = Instance.new("UICorner");
			local UICorner_3 = Instance.new("UICorner");
			local UICorner_4 = Instance.new("UICorner");
			local UICorner_5 = Instance.new("UICorner");
			local ToggleImage = Instance.new("TextButton");
			local Circle = Instance.new("Frame");
			Toggle.Name = "Toggle";
			Toggle.Parent = MainFramePage;
			Toggle.BackgroundColor3 = _G.Primary;
			Toggle.BackgroundTransparency = 0.8;
			Toggle.Size = UDim2.new(1, 0, 0, 35);
			UICorner.CornerRadius = UDim.new(0, 3);
			UICorner.Parent = Toggle;
			Title.Name = "Title";
			Title.Parent = Toggle;
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Title.BackgroundTransparency = 1;
			Title.Position = UDim2.new(0, 10, 0, 0);
			Title.Size = UDim2.new(1, 0, 1, 0);
			Title.Font = Enum.Font.Cartoon;
			Title.Text = text;
			Title.TextColor3 = Color3.fromRGB(255, 255, 255);
			Title.TextSize = 15;
			Title.TextXAlignment = Enum.TextXAlignment.Left;
			ToggleFrame.Name = "ToggleFrame";
			ToggleFrame.Parent = Toggle;
			ToggleFrame.BackgroundColor3 = _G.Dark;
			ToggleFrame.BackgroundTransparency = 1;
			ToggleFrame.Position = UDim2.new(1, -10, 0.5, 0);
			ToggleFrame.Size = UDim2.new(0, 35, 0, 20);
			ToggleFrame.AnchorPoint = Vector2.new(1, 0.5);
			UICorner_5.CornerRadius = UDim.new(0, 3);
			UICorner_5.Parent = ToggleFrame;
			ToggleImage.Name = "ToggleImage";
			ToggleImage.Parent = ToggleFrame;
			ToggleImage.BackgroundColor3 = Color3.fromRGB(60, 60, 60);
			ToggleImage.BackgroundTransparency = 0;
			ToggleImage.Position = UDim2.new(0, 0, 0, 0);
			ToggleImage.AnchorPoint = Vector2.new(0, 0);
			ToggleImage.Size = UDim2.new(1, 0, 1, 0);
			ToggleImage.Text = "";
			ToggleImage.AutoButtonColor = false;
			CreateRounded(ToggleImage, 3);
			Circle.Name = "Circle";
			Circle.Parent = ToggleImage;
			Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Circle.BackgroundTransparency = 0;
			Circle.Position = UDim2.new(0, 3, 0.5, 0);
			Circle.Size = UDim2.new(0, 14, 0, 14);
			Circle.AnchorPoint = Vector2.new(0, 0.5);
			UICorner_4.CornerRadius = UDim.new(0, 2);
			UICorner_4.Parent = Circle;
			ToggleImage.MouseButton1Click:Connect(function()
				if toggled == false then
					toggled = true;
					Circle:TweenPosition(UDim2.new(0, 17, 0.5, 0), "Out", "Sine", 0.2, true);
					(TweenService:Create(ToggleImage, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = _G.Third,
						BackgroundTransparency = 0
					})):Play();
				else
					toggled = false;
					Circle:TweenPosition(UDim2.new(0, 4, 0.5, 0), "Out", "Sine", 0.2, true);
					(TweenService:Create(ToggleImage, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(60, 60, 60),
						BackgroundTransparency = 0
					})):Play();
				end;
				pcall(callback, toggled);
			end);
			if config == true then
				toggled = true;
				Circle:TweenPosition(UDim2.new(0, 17, 0.5, 0), "Out", "Sine", 0.4, true);
				(TweenService:Create(ToggleImage, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = _G.Third,
					BackgroundTransparency = 0
				})):Play();
				pcall(callback, toggled);
			end;
		end;
		function main:Dropdown(text, option, var, callback)
			local isdropping = false;
			local Dropdown = Instance.new("Frame");
			local DropdownFrameScroll = Instance.new("Frame");
			local UICorner = Instance.new("UICorner");
			local UICorner_2 = Instance.new("UICorner");
			local UICorner_3 = Instance.new("UICorner");
			local UICorner_4 = Instance.new("UICorner");
			local DropTitle = Instance.new("TextLabel");
			local DropScroll = Instance.new("ScrollingFrame");
			local UIListLayout = Instance.new("UIListLayout");
			local UIPadding = Instance.new("UIPadding");
			local DropButton = Instance.new("TextButton");
			local HideButton = Instance.new("TextButton");
			local SelectItems = Instance.new("TextButton");
			local DropImage = Instance.new("ImageLabel");
			local UIStroke = Instance.new("UIStroke");
			Dropdown.Name = "Dropdown";
			Dropdown.Parent = MainFramePage;
			Dropdown.BackgroundColor3 = _G.Primary;
			Dropdown.BackgroundTransparency = 0.8;
			Dropdown.ClipsDescendants = false;
			Dropdown.Size = UDim2.new(1, 0, 0, 40);
			UICorner.CornerRadius = UDim.new(0, 3);
			UICorner.Parent = Dropdown;
			DropTitle.Name = "DropTitle";
			DropTitle.Parent = Dropdown;
			DropTitle.BackgroundColor3 = _G.Primary;
			DropTitle.BackgroundTransparency = 1;
			DropTitle.Size = UDim2.new(1, 0, 0, 30);
			DropTitle.Font = Enum.Font.Cartoon;
			DropTitle.Text = text;
			DropTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			DropTitle.TextSize = 15;
			DropTitle.TextXAlignment = Enum.TextXAlignment.Left;
			DropTitle.Position = UDim2.new(0, 15, 0, 5);
			DropTitle.AnchorPoint = Vector2.new(0, 0);
			SelectItems.Name = "SelectItems";
			SelectItems.Parent = Dropdown;
			SelectItems.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
			SelectItems.TextColor3 = Color3.fromRGB(255, 255, 255);
			SelectItems.BackgroundTransparency = 0;
			SelectItems.Position = UDim2.new(1, -5, 0, 5);
			SelectItems.Size = UDim2.new(0, 100, 0, 30);
			SelectItems.AnchorPoint = Vector2.new(1, 0);
			SelectItems.Font = Enum.Font.GothamMedium;
			SelectItems.AutoButtonColor = false;
			SelectItems.TextSize = 9;
			SelectItems.ZIndex = 1;
			SelectItems.ClipsDescendants = true;
			SelectItems.Text = "   Select Items";
			SelectItems.TextXAlignment = Enum.TextXAlignment.Left;
			local ArrowDown = Instance.new("ImageLabel");
			ArrowDown.Name = "ArrowDown";
			ArrowDown.Parent = Dropdown;
			ArrowDown.BackgroundColor3 = _G.Primary;
			ArrowDown.BackgroundTransparency = 1;
			ArrowDown.AnchorPoint = Vector2.new(1, 0);
			ArrowDown.Position = UDim2.new(1, -110, 0, 10);
			ArrowDown.Size = UDim2.new(0, 20, 0, 20);
			ArrowDown.Image = "rbxassetid://10709790948";
			ArrowDown.ImageTransparency = 0;
			ArrowDown.ImageColor3 = Color3.fromRGB(255, 255, 255);
			CreateRounded(SelectItems, 3);
			CreateRounded(DropScroll, 3);
			DropdownFrameScroll.Name = "DropdownFrameScroll";
			DropdownFrameScroll.Parent = Dropdown;
			DropdownFrameScroll.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
			DropdownFrameScroll.BackgroundTransparency = 0;
			DropdownFrameScroll.ClipsDescendants = true;
			DropdownFrameScroll.Size = UDim2.new(1, 0, 0, 100);
			DropdownFrameScroll.Position = UDim2.new(0, 5, 0, 40);
			DropdownFrameScroll.Visible = false;
			DropdownFrameScroll.AnchorPoint = Vector2.new(0, 0);
			UICorner_4.Parent = DropdownFrameScroll;
			UICorner_4.CornerRadius = UDim.new(0, 3);
			DropScroll.Name = "DropScroll";
			DropScroll.Parent = DropdownFrameScroll;
			DropScroll.ScrollingDirection = Enum.ScrollingDirection.Y;
			DropScroll.Active = true;
			DropScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			DropScroll.BackgroundTransparency = 1;
			DropScroll.BorderSizePixel = 0;
			DropScroll.Position = UDim2.new(0, 0, 0, 10);
			DropScroll.Size = UDim2.new(1, 0, 0, 80);
			DropScroll.AnchorPoint = Vector2.new(0, 0);
			DropScroll.ClipsDescendants = true;
			DropScroll.ScrollBarThickness = 3;
			DropScroll.ZIndex = 3;
			local PaddingDrop = Instance.new("UIPadding");
			PaddingDrop.PaddingLeft = UDim.new(0, 10);
			PaddingDrop.PaddingRight = UDim.new(0, 10);
			PaddingDrop.Parent = DropScroll;
			PaddingDrop.Name = "PaddingDrop";
			UIListLayout.Parent = DropScroll;
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
			UIListLayout.Padding = UDim.new(0, 1);
			UIPadding.Parent = DropScroll;
			UIPadding.PaddingLeft = UDim.new(0, 5);
			for i, v in next, option do
				local Item = Instance.new("TextButton");
				local CRNRitems = Instance.new("UICorner");
				local UICorner_5 = Instance.new("UICorner");
				local ItemPadding = Instance.new("UIPadding");
				Item.Name = "Item";
				Item.Parent = DropScroll;
				Item.BackgroundColor3 = _G.Primary;
				Item.BackgroundTransparency = 1;
				Item.Size = UDim2.new(1, 0, 0, 30);
				Item.Font = Enum.Font.Nunito;
				Item.Text = tostring(v);
				Item.TextColor3 = Color3.fromRGB(255, 255, 255);
				Item.TextSize = 13;
				Item.TextTransparency = 0.4;
				Item.TextXAlignment = Enum.TextXAlignment.Left;
				Item.ZIndex = 4;
				ItemPadding.Parent = Item;
				ItemPadding.PaddingLeft = UDim.new(0, 8);
				UICorner_5.Parent = Item;
				UICorner_5.CornerRadius = UDim.new(0, 3);
				local SelectedItems = Instance.new("Frame");
				SelectedItems.Name = "SelectedItems";
				SelectedItems.Parent = Item;
				SelectedItems.BackgroundColor3 = _G.Third;
				SelectedItems.BackgroundTransparency = 1;
				SelectedItems.Size = UDim2.new(0, 3, 0.4, 0);
				SelectedItems.Position = UDim2.new(0, -8, 0.5, 0);
				SelectedItems.AnchorPoint = Vector2.new(0, 0.5);
				SelectedItems.ZIndex = 4;
				CRNRitems.Parent = SelectedItems;
				CRNRitems.CornerRadius = UDim.new(0, 2);
				if var then
					pcall(callback, var);
					SelectItems.Text = "   " .. var;
					activeItem = tostring(var);
					for i, v in next, DropScroll:GetChildren() do
						if v:IsA("TextButton") then
							local SelectedItems = v:FindFirstChild("SelectedItems");
							if activeItem == v.Text then
								v.BackgroundTransparency = 0.7;
								v.TextTransparency = 0;
								if SelectedItems then
									SelectedItems.BackgroundTransparency = 0;
								end;
							end;
						end;
					end;
				end;
				Item.MouseButton1Click:Connect(function()
					SelectItems.ClipsDescendants = true;
					callback(Item.Text);
					activeItem = Item.Text;
					for i, v in next, DropScroll:GetChildren() do
						if v:IsA("TextButton") then
							local SelectedItems = v:FindFirstChild("SelectedItems");
							if activeItem == v.Text then
								v.BackgroundTransparency = 0.7;
								v.TextTransparency = 0;
								if SelectedItems then
									SelectedItems.BackgroundTransparency = 0;
								end;
							else
								v.BackgroundTransparency = 1;
								v.TextTransparency = 0.4;
								if SelectedItems then
									SelectedItems.BackgroundTransparency = 1;
								end;
							end;
						end;
					end;
					SelectItems.Text = "   " .. Item.Text;
				end);
			end;
			DropScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y);
			SelectItems.MouseButton1Click:Connect(function()
				if isdropping == false then
					isdropping = true;
					(TweenService:Create(DropdownFrameScroll, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, -10, 0, 100),
						Visible = true
					})):Play();
					(TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, 0, 0, 145)
					})):Play();
					(TweenService:Create(ArrowDown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Rotation = 180
					})):Play();
				elseif isdropping == true then
					isdropping = false;
					(TweenService:Create(DropdownFrameScroll, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, -10, 0, 0),
						Visible = false
					})):Play();
					(TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, 0, 0, 40)
					})):Play();
					(TweenService:Create(ArrowDown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Rotation = 0
					})):Play();
				end;
			end);
		end;
		function main:Slider(text, min, max, start, callback)
			local dragging = false;
			local Slider = Instance.new("Frame");
			local UICorner = Instance.new("UICorner");
			local Title = Instance.new("TextLabel");
			local SliderFrame = Instance.new("Frame");
			local UICorner_2 = Instance.new("UICorner");
			local SliderButton = Instance.new("TextButton");
			local UICorner_3 = Instance.new("UICorner");
			local SliderCount = Instance.new("Frame");
			local UICorner_4 = Instance.new("UICorner");
			local SliderCountText = Instance.new("TextLabel");
			Slider.Name = "Slider";
			Slider.Parent = MainFramePage;
			Slider.BackgroundColor3 = _G.Primary;
			Slider.BackgroundTransparency = 0.8;
			Slider.Size = UDim2.new(1, 0, 0, 45);
			UICorner.CornerRadius = UDim.new(0, 3);
			UICorner.Parent = Slider;
			Title.Name = "Title";
			Title.Parent = Slider;
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Title.BackgroundTransparency = 1;
			Title.Position = UDim2.new(0, 10, 0, 0);
			Title.Size = UDim2.new(1, 0, 0, 20);
			Title.Font = Enum.Font.Cartoon;
			Title.Text = text;
			Title.TextColor3 = Color3.fromRGB(255, 255, 255);
			Title.TextSize = 15;
			Title.TextXAlignment = Enum.TextXAlignment.Left;
			SliderFrame.Name = "SliderFrame";
			SliderFrame.Parent = Slider;
			SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
			SliderFrame.Position = UDim2.new(0, 10, 0, 25);
			SliderFrame.Size = UDim2.new(1, -50, 0, 10);
			UICorner_2.CornerRadius = UDim.new(0, 2);
			UICorner_2.Parent = SliderFrame;
			SliderButton.Name = "SliderButton";
			SliderButton.Parent = SliderFrame;
			SliderButton.BackgroundColor3 = _G.Third;
			SliderButton.Size = UDim2.new(0, 0, 1, 0);
			SliderButton.AutoButtonColor = false;
			SliderButton.Font = Enum.Font.SourceSans;
			SliderButton.Text = "";
			SliderButton.TextColor3 = Color3.fromRGB(0, 0, 0);
			SliderButton.TextSize = 14;
			UICorner_3.CornerRadius = UDim.new(0, 2);
			UICorner_3.Parent = SliderButton;
			SliderCount.Name = "SliderCount";
			SliderCount.Parent = Slider;
			SliderCount.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
			SliderCount.Position = UDim2.new(1, -35, 0, 22);
			SliderCount.Size = UDim2.new(0, 30, 0, 16);
			UICorner_4.CornerRadius = UDim.new(0, 2);
			UICorner_4.Parent = SliderCount;
			SliderCountText.Name = "SliderCountText";
			SliderCountText.Parent = SliderCount;
			SliderCountText.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			SliderCountText.BackgroundTransparency = 1;
			SliderCountText.Size = UDim2.new(1, 0, 1, 0);
			SliderCountText.Font = Enum.Font.Gotham;
			SliderCountText.Text = tostring(start);
			SliderCountText.TextColor3 = Color3.fromRGB(255, 255, 255);
			SliderCountText.TextSize = 10;
			SliderButton:GetPropertyChangedSignal("Size"):Connect(function()
				SliderCountText.Text = tostring(math.floor((SliderButton.Size.X.Scale * max) / (max - min)) * (max - min));
			end);
			local function move(input)
				local pos = UDim2.new(math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1), 0, 1, 0);
				SliderButton:TweenSize(pos, "Out", "Sine", 0.1, true);
				local value = math.floor(((pos.X.Scale * max) / (max - min)) * (max - min));
				pcall(callback, value);
			end;
			SliderButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true;
				end;
			end);
			SliderButton.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false;
				end;
			end);
			SliderFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true;
					move(input);
				end;
			end);
			SliderFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false;
				end;
			end);
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					move(input);
				end;
			end);
			local initialPos = UDim2.new(((start or 0) - min) / (max - min), 0, 1, 0);
			SliderButton.Size = initialPos;
		end;
		function main:Textbox(text, placeholder, callback)
			local Textbox = Instance.new("Frame");
			local UICorner = Instance.new("UICorner");
			local Title = Instance.new("TextLabel");
			local TextboxFrame = Instance.new("Frame");
			local UICorner_2 = Instance.new("UICorner");
			local TextBox = Instance.new("TextBox");
			Textbox.Name = "Textbox";
			Textbox.Parent = MainFramePage;
			Textbox.BackgroundColor3 = _G.Primary;
			Textbox.BackgroundTransparency = 0.8;
			Textbox.Size = UDim2.new(1, 0, 0, 45);
			UICorner.CornerRadius = UDim.new(0, 3);
			UICorner.Parent = Textbox;
			Title.Name = "Title";
			Title.Parent = Textbox;
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Title.BackgroundTransparency = 1;
			Title.Position = UDim2.new(0, 10, 0, 0);
			Title.Size = UDim2.new(1, 0, 0, 20);
			Title.Font = Enum.Font.Cartoon;
			Title.Text = text;
			Title.TextColor3 = Color3.fromRGB(255, 255, 255);
			Title.TextSize = 15;
			Title.TextXAlignment = Enum.TextXAlignment.Left;
			TextboxFrame.Name = "TextboxFrame";
			TextboxFrame.Parent = Textbox;
			TextboxFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
			TextboxFrame.Position = UDim2.new(0, 10, 0, 25);
			TextboxFrame.Size = UDim2.new(1, -20, 0, 15);
			UICorner_2.CornerRadius = UDim.new(0, 2);
			UICorner_2.Parent = TextboxFrame;
			TextBox.Parent = TextboxFrame;
			TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			TextBox.BackgroundTransparency = 1;
			TextBox.Size = UDim2.new(1, 0, 1, 0);
			TextBox.Font = Enum.Font.Code;
			TextBox.PlaceholderText = placeholder or "";
			TextBox.Text = "";
			TextBox.TextColor3 = Color3.fromRGB(255, 255, 255);
			TextBox.TextSize = 12;
			TextBox.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					pcall(callback, TextBox.Text);
				end;
			end);
		end;
		function main:Label(text)
			local Label = Instance.new("Frame");
			local UICorner = Instance.new("UICorner");
			local Title = Instance.new("TextLabel");
			Label.Name = "Label";
			Label.Parent = MainFramePage;
			Label.BackgroundColor3 = _G.Primary;
			Label.BackgroundTransparency = 0.8;
			Label.Size = UDim2.new(1, 0, 0, 30);
			UICorner.CornerRadius = UDim.new(0, 3);
			UICorner.Parent = Label;
			Title.Name = "Title";
			Title.Parent = Label;
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Title.BackgroundTransparency = 1;
			Title.Size = UDim2.new(1, 0, 1, 0);
			Title.Font = Enum.Font.Cartoon;
			Title.Text = text;
			Title.TextColor3 = Color3.fromRGB(255, 255, 255);
			Title.TextSize = 15;
			local function updateText()
				Title.Text = text;
			end;
			return {
				UpdateText = function(self, newtext)
					text = newtext;
					updateText();
				end
			};
		end;
		return main;
	end;
	return uitab;
end;
if SettingsLib.LoadAnimation == true then
	Update:StartLoad();
	wait(2);
	Update:Loaded();
end;
return Library;

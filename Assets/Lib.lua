local Services = setmetatable({
    cloneref = cloneref,
    Request = (syn and syn.Request) or http_request or Request or (type(Http) == 'table' and Http.Request) or nil,
    workspace = cloneref(game:GetService'Workspace'),
    LocalPlayer = cloneref(game:GetService'Players').LocalPlayer,
    Camera = cloneref(game:GetService'Workspace').CurrentCamera,
    Mobile = cloneref(game:GetService'UserInputService').PreferredInput,
    MarketplaceService = cloneref(game:GetService'MarketplaceService'),
    TextService = cloneref(game:GetService'TextService'),
    GuiService = cloneref(game:GetService'GuiService'),
    RunService = cloneref(game:GetService'RunService'),
    TweenService = cloneref(game:GetService'TweenService'),
    UserInputService = cloneref(game:GetService'UserInputService'),
    HttpService = cloneref(game:GetService'HttpService'),
    CoreGui = cloneref(game:GetService'CoreGui'),
    game = game,
}, {
    __index = function(self, Key)
        local ok, Value = pcall(function()
            return cloneref(game:GetService(Key))
    end)

        if ok and Value then
            rawset(self, Key, Value)

            return Value
        end
    end,
})

local GuiInset = Services.GuiService:GetGuiInset().Y;
local NewColorSequence = ColorSequence.new;
local NewColorSequenceKeypoint = ColorSequenceKeypoint.new;
local NewNumberSequence = NumberSequence.new;
local NewNumberSequenceKeypoint = NumberSequenceKeypoint.new;

-- File I/O compatibility layer
local isfile = isfile or function(path)
	local success = pcall(function()
		return readfile(path)
	end)
	return success
end

local isfolder = isfolder or function(path)
	return false
end

local makefolder = makefolder or function(path)
	-- Placeholder - folder creation not supported
end

local listfiles = listfiles or function(path)
	return {}
end

local writefile = writefile or function(path, content)
	-- Placeholder - file writing not supported
end

local readfile = readfile or function(path)
	return ""
end

local delfile = delfile or function(path)
	-- Placeholder - file deletion not supported
end

local appendfile = appendfile or function(path, content)
	-- Placeholder - file appending not supported
end

local Library = {
    Flags = {};
    Toggles = {};
    Options = {};
    Connections = {};
    Directory = "Vision";
    Folders = { "/Fonts", "/Configs", "/Logs" };
    CurrentlyOpen = nil;
    AnimationSpeed = 1;
    LogFile = "Vision/Logs/Session.log";
};

Library.UIElements = {};
Library._NotifyTransparency = 0.5;
Library._NotifyMaxHeight = 300;

local Palette = {
Default = {
Top = Color3.fromHex("161616");
Bottom = Color3.fromHex("1E1E1E");
ContentTop = Color3.fromHex("151515");
ContentBottom = Color3.fromHex("171717");
FooterTop = Color3.fromHex("151515");
FooterBottom = Color3.fromHex("1F1F1F");
Outline = Color3.fromHex("000105");
InnerOutline = Color3.fromHex("252527");
TitleTop = Color3.fromHex("F3F4F8");
TitleBottom = Color3.fromHex("557294");
TabActive = Color3.fromHex("557294");
Accent = Color3.fromHex("557294");
TabInactive = Color3.fromHex("BFC4CC");
};
};
Library.Palette = Palette;

Library.Accent          = Palette.Default.Accent;
Library.AccentParts     = {};
Library.AccentGradients = {};
Library.AccentCallbacks = {};

local function LightenAccent(C)
return C:Lerp(Color3.fromRGB(255, 255, 255), 0.6);
end;

function Library.RegisterAccent(self, Inst, Prop) 
Prop = Prop or "BackgroundColor3";
table.insert(self.AccentParts, { Inst = Inst, Prop = Prop });
Inst[Prop] = self.Accent;
end

function Library.RegisterAccentGradient(self, Gradient) 
table.insert(self.AccentGradients, Gradient);
Gradient.Color = NewColorSequence({
NewColorSequenceKeypoint(0,   self.Accent);
NewColorSequenceKeypoint(0.5, LightenAccent(self.Accent));
NewColorSequenceKeypoint(1,   self.Accent);
});
end

Library.Keybinds         = {};
Library.KeybindListeners = {};

function Library.RegisterKeybind(self, Entry) 
if typeof(Entry) ~= "table" then return end;
table.insert(self.Keybinds, Entry);
self.NotifyKeybind(self);
return Entry;
end

function Library.NotifyKeybind(self) 
for _, Fn in self.KeybindListeners do Fn() end;
end

function Library.OnKeybindChange(self, Fn) 
if typeof(Fn) ~= "function" then return end;
table.insert(self.KeybindListeners, Fn);
Fn();
end

local AccentClock = 0;

local function accentUpdateLoop(Dt) 
    AccentClock = AccentClock + Dt * 0.4
    local Off = (AccentClock % 2) - 1
    local OffsetV = Vector2.new(Off, 0)
    for _, G in Library.AccentGradients do
        if G and G.Parent then
            G.Offset = OffsetV
        end
    end
end

Services.RunService.Heartbeat:Connect(accentUpdateLoop)

function Library.OnAccent(self, Fn) 
if typeof(Fn) ~= "function" then return end;
table.insert(self.AccentCallbacks, Fn);
Fn(self.Accent);
end

function Library.SetAccent(self, C) 
if typeof(C) ~= "Color3" then return end;
self.Accent = C;
for _, P in self.AccentParts do
if P.Inst and P.Inst.Parent then
P.Inst[P.Prop] = C;
end;
end;
for _, G in self.AccentGradients do
if G and G.Parent then
G.Color = NewColorSequence({
NewColorSequenceKeypoint(0,   C);
NewColorSequenceKeypoint(0.5, LightenAccent(C));
NewColorSequenceKeypoint(1,   C);
});
end;
end;
for _, Fn in self.AccentCallbacks do
if type(Fn) == "function" then
Fn(C);
end;
end;
end

for _, FolderPath in Library.Folders do
makefolder(Library.Directory .. FolderPath);
end;

if isfile(Library.LogFile) then
delfile(Library.LogFile);
end;
writefile(Library.LogFile, Library.Directory .. " has started\n");

local LogStart = tick();

function Library.Log(self, Text) 
local Stamp = string.format("%.3f", tick() - LogStart);
appendfile(self.LogFile, "[" .. Stamp .. "s] " .. tostring(Text) .. "\n");
end

Library.KeyNames = {
[Enum.UserInputType.MouseButton1] = "MB1";
[Enum.UserInputType.MouseButton2] = "MB2";
[Enum.UserInputType.MouseButton3] = "MB3";

[Enum.KeyCode.LeftShift] = "LS";
[Enum.KeyCode.RightShift] = "RS";
[Enum.KeyCode.LeftControl] = "LC";
[Enum.KeyCode.RightControl] = "RC";
[Enum.KeyCode.LeftAlt] = "LA";
[Enum.KeyCode.RightAlt] = "RA";
[Enum.KeyCode.CapsLock] = "CAPS";
[Enum.KeyCode.Insert] = "INS";
[Enum.KeyCode.Backspace] = "BS";
[Enum.KeyCode.Return] = "Ent";
[Enum.KeyCode.Escape] = "ESC";
[Enum.KeyCode.Space] = "SPC";

[Enum.KeyCode.Zero] = "0";
[Enum.KeyCode.One] = "1";
[Enum.KeyCode.Two] = "2";
[Enum.KeyCode.Three] = "3";
[Enum.KeyCode.Four] = "4";
[Enum.KeyCode.Five] = "5";
[Enum.KeyCode.Six] = "6";
[Enum.KeyCode.Seven] = "7";
[Enum.KeyCode.Eight] = "8";
[Enum.KeyCode.Nine] = "9";

[Enum.KeyCode.KeypadZero] = "Num0";
[Enum.KeyCode.KeypadOne] = "Num1";
[Enum.KeyCode.KeypadTwo] = "Num2";
[Enum.KeyCode.KeypadThree] = "Num3";
[Enum.KeyCode.KeypadFour] = "Num4";
[Enum.KeyCode.KeypadFive] = "Num5";
[Enum.KeyCode.KeypadSix] = "Num6";
[Enum.KeyCode.KeypadSeven] = "Num7";
[Enum.KeyCode.KeypadEight] = "Num8";
[Enum.KeyCode.KeypadNine] = "Num9";

[Enum.KeyCode.Minus] = "-";
[Enum.KeyCode.Equals] = "=";
[Enum.KeyCode.Tilde] = "~";
[Enum.KeyCode.LeftBracket] = "[";
[Enum.KeyCode.RightBracket] = "]";
[Enum.KeyCode.LeftParenthesis] = "(";
[Enum.KeyCode.RightParenthesis] = ")";
[Enum.KeyCode.Semicolon] = ",";
[Enum.KeyCode.Quote] = "'";
[Enum.KeyCode.BackSlash] = "\\";
[Enum.KeyCode.Comma] = ",";
[Enum.KeyCode.Period] = ".";
[Enum.KeyCode.Slash] = "/";
[Enum.KeyCode.Asterisk] = "*";
[Enum.KeyCode.Plus] = "+";
[Enum.KeyCode.Backquote] = "`";
};

function Library.Connection(self, Signal, Callback) 
local Conn = Signal:Connect(Callback);
table.insert(self.Connections, Conn);
return Conn;
end

function Library.CreateInstance(self, ClassName, Properties) 
local Inst = Instance.new(ClassName);
for K, V in (Properties or {}) do
Inst[K] = V;
end;
return Inst;
end

function Library.Tween(self, Inst, Info, Props) 
local Speed = self.AnimationSpeed or 1;
if Speed < 0.05 then Speed = 0.05 end;
local Scale = 1 / Speed;
local Style = self.EasingStyle      or Info.EasingStyle;
local Dir   = self.EasingDirection  or Info.EasingDirection;
if Scale == 1 and Style == Info.EasingStyle and Dir == Info.EasingDirection then
return Services.TweenService:Create(Inst, Info, Props);
end;
local Scaled = TweenInfo.new(Info.Time * Scale, Style, Dir, Info.RepeatCount, Info.Reverses, Info.DelayTime);
return Services.TweenService:Create(Inst, Scaled, Props);
end

Library._ActiveDraggers = {};

function Library._RegisterDragger(self, Handler) 
if typeof(Handler) ~= "function" then return end;
local Self = self;
if not Self._DispatcherConn then
Self._DispatcherConn = Services.UserInputService.InputChanged:Connect(function(Input)
local Ut = Input.UserInputType;
if Ut ~= Enum.UserInputType.MouseMovement and Ut ~= Enum.UserInputType.Touch then
return;
end;
local List = Self._ActiveDraggers;
for I = 1, #List do
List[I](Input);
end;
end);
table.insert(Self.Connections, Self._DispatcherConn);
end;
table.insert(Self._ActiveDraggers, Handler);
return Handler;
end

function Library._UnregisterDragger(self, Handler) 
if not Handler then return end;
local List = self._ActiveDraggers;
if not List then return end;
for I = #List, 1, -1 do
if List[I] == Handler then
List[I] = List[#List];
List[#List] = nil;
return;
end;
end;
end

function Library.IsEffectivelyVisible(self, Inst) 
local Cur = Inst;
while Cur do
if Cur:IsA("ScreenGui") then return Cur.Enabled end;
if Cur:IsA("GuiObject") and not Cur.Visible then return false end;
Cur = Cur.Parent;
end;
return false;
end

function Library.Debounce(self, Delay, Fn) 
local Token = 0;
return function(...)
Token = Token + 1;
local Mine = Token;
local Args = { ... };
task.delay(Delay, function()
if Mine == Token then Fn(table.unpack(Args)) end;
end);
end;
end

function Library.RegisterFont(self, Name, Url, Weight, Style) 
local Folder = self.Directory .. "/Fonts";
local TtfPath = Folder .. "/" .. Name .. ".ttf";
local DescPath = Folder .. "/" .. Name .. ".font";

if not isfile(TtfPath) then
        self.Log(self, "Downloading font " .. Name .. "...");
        writefile(TtfPath, game:HttpGet(Url));
        self.Log(self, "Font " .. Name .. " downloaded.");
else
        self.Log(self, "Font " .. Name .. " already exists, skipping download.");
end;
if isfile(DescPath) then
delfile(DescPath);
end;

writefile(DescPath, Services.HttpService:JSONEncode({
name = Name;
faces = {
{ name = "Regular", weight = Weight or 400, style = Style or "normal", assetId = getcustomasset(TtfPath) };
};
}));

self.Log(self, "Registered font " .. Name);
return getcustomasset(DescPath);
end

function Library.Draggable(self, TargetFrame, DragHandle) 
local Handle = DragHandle or TargetFrame;
local Dragging = false;
local DragStart, StartPosition;
local DragInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);

local function Set(Input)
if not DragStart or not StartPosition then return end;
local Delta = Input.Position - DragStart;
Library.Tween(Library,TargetFrame, DragInfo, {
Position = UDim2.new(
StartPosition.X.Scale,
StartPosition.X.Offset + Delta.X,
StartPosition.Y.Scale,
StartPosition.Y.Offset + Delta.Y
);
}):Play();
end;

self.Connection(self, Handle.InputBegan, function(Input)
if self._Resizing then return end;
if
Input.UserInputType ~= Enum.UserInputType.MouseButton1
and Input.UserInputType ~= Enum.UserInputType.Touch
then
return;
end;
Dragging      = true;
DragStart     = Input.Position;
StartPosition = TargetFrame.Position;
end);

self.Connection(self, Handle.InputEnded, function(Input)
if
Input.UserInputType == Enum.UserInputType.MouseButton1
or Input.UserInputType == Enum.UserInputType.Touch
then
Dragging = false;
end;
end);

self.Connection(self,Services.UserInputService.InputChanged, function(Input)
if
Input.UserInputType ~= Enum.UserInputType.MouseMovement
and Input.UserInputType ~= Enum.UserInputType.Touch
then
return;
end;
if Dragging then Set(Input) end;
end);
end

function Library.Resizable(self, TargetFrame, Minimum, Maximum) 
Minimum = Minimum or Vector2.new(TargetFrame.Size.X.Offset, TargetFrame.Size.Y.Offset);
local ResizeInfo = TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);

local Grip = self.CreateInstance(self,"TextButton", {
Parent                 = TargetFrame;
AnchorPoint            = Vector2.new(1, 1);
BorderColor3           = Color3.fromRGB(0, 0, 0);
Size                   = UDim2.new(0, 8, 0, 8);
Position               = UDim2.new(1, 0, 1, 0);
Name                   = "\0";
BorderSizePixel        = 0;
BackgroundTransparency = 1;
AutoButtonColor        = false;
Visible                = true;
Text                   = "";
});

local Resizing  = false;
local Start     = UDim2.new();
local Delta     = UDim2.new();
local ResizeMax = TargetFrame.Parent.AbsoluteSize - TargetFrame.AbsoluteSize;

self.Connection(self,Grip.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Resizing = true;
Start    = TargetFrame.Size - UDim2.new(0, Input.Position.X, 0, Input.Position.Y);
end;
end);

self.Connection(self,Grip.InputEnded, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Resizing = false;
end;
end);

self.Connection(self,Services.UserInputService.InputChanged, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
ResizeMax = Maximum or (TargetFrame.Parent.AbsoluteSize - TargetFrame.AbsoluteSize);
Delta = Start + UDim2.new(0, Input.Position.X, 0, Input.Position.Y);
Delta = UDim2.new(
0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X),
0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y)
);
Library.Tween(Library,TargetFrame, ResizeInfo, { Size = Delta }):Play();
end;
end);

return Grip;
end

function Library.IsPointerInput(self, Input) 
return Input.UserInputType == Enum.UserInputType.MouseButton1
or Input.UserInputType == Enum.UserInputType.Touch;
end

function Library.BindResizeHandleGhost(self, clipInst, circleInst, getSize, setSize, onFinish) 
if not clipInst then return end;
clipInst.Active = true;
local defaultTrans = circleInst.BackgroundTransparency;

clipInst.InputBegan:Connect(function(Input)
if not self.IsPointerInput(self,Input) then return end;

circleInst.BackgroundTransparency = 1;
self._Resizing = true;

local startX = Input.Position.X;
local startY = Input.Position.Y;
local startW, startH = 0, 0;
if type(getSize) == 'function' then
startW, startH = getSize();
end;

local minW = 280;
local minH = 400;

local dragging = true;
local dragInput = Input;

local moveConn = Services.UserInputService.InputChanged:Connect(function(mInput)
if mInput.UserInputType == Enum.UserInputType.MouseMovement
or mInput.UserInputType == Enum.UserInputType.Touch then
dragInput = mInput;
end;
end);

local rsConn;
rsConn = Services.RunService.RenderStepped:Connect(function()
if not dragging then rsConn:Disconnect(); return end;
local dx = dragInput.Position.X - startX;
local dy = dragInput.Position.Y - startY;
local nw = math.max(startW + dx, minW);
local nh = math.max(startH + dy, minH);
if type(setSize) == 'function' then
setSize(nw, nh);
end;
end);

local endConn;
endConn = Services.UserInputService.InputEnded:Connect(function(eInput)
if not self.IsPointerInput(self,eInput) then return end;
dragging = false;
moveConn:Disconnect();
endConn:Disconnect();
self._Resizing = false;

circleInst.BackgroundTransparency = defaultTrans;

if type(onFinish) == 'function' then
onFinish();
end;
end);
end);
end

local ProggyCleanFont;
do
local Asset = Library.RegisterFont(Library,"ProggyClean", "https://github.com/networph-private874612748471/curly-octo-memory/raw/refs/heads/main/fs-tahoma-8px.ttf", 400, "normal");
if Asset then
ProggyCleanFont = Font.new(Asset, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
else
warn("[ Vision ] Failed to load ProggyClean font.");
ProggyCleanFont = Font.new(Enum.Font.Code, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
end;
end;

function Library.Tooltip(self, Inst, Text) 
if not Inst or not Text or Text == "" then return end;

if not self._TooltipFrame then
local Gui = self.CreateInstance(self,"ScreenGui", {
Name           = "Tooltip";
Parent         = (gethui and gethui()) or Services.CoreGui;
IgnoreGuiInset = true;
ResetOnSpawn   = false;
ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
DisplayOrder   = 9999;
});
local Frame = self.CreateInstance(self,"CanvasGroup", {
Name              = "Box";
Parent            = Gui;
Size              = UDim2.new(0, 0, 0, 0);
AutomaticSize     = Enum.AutomaticSize.XY;
BackgroundColor3  = Color3.fromHex("000000");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 200;
});
self.CreateInstance(self,"UIPadding", {
Parent = Frame; PaddingLeft = UDim.new(0, 1); PaddingRight = UDim.new(0, 1);
PaddingTop = UDim.new(0, 1); PaddingBottom = UDim.new(0, 1);
});
local Gray = self.CreateInstance(self,"Frame", {
Parent           = Frame;
Size             = UDim2.new(0, 0, 0, 0);
AutomaticSize    = Enum.AutomaticSize.XY;
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIPadding", {
Parent = Gray; PaddingLeft = UDim.new(0, 1); PaddingRight = UDim.new(0, 1);
PaddingTop = UDim.new(0, 1); PaddingBottom = UDim.new(0, 1);
});
local Inside = self.CreateInstance(self,"Frame", {
Parent           = Gray;
Size             = UDim2.new(0, 0, 0, 0);
AutomaticSize    = Enum.AutomaticSize.XY;
BackgroundColor3 = Color3.fromHex("131313");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIPadding", {
Parent = Inside; PaddingLeft = UDim.new(0, 6); PaddingRight = UDim.new(0, 6);
PaddingTop = UDim.new(0, 3); PaddingBottom = UDim.new(0, 3);
});
local Lbl = self.CreateInstance(self,"TextLabel", {
Name                   = "Text";
Parent                 = Inside;
Size                   = UDim2.new(0, 0, 0, 0);
AutomaticSize          = Enum.AutomaticSize.XY;
BackgroundTransparency = 1;
Text                   = "";
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

self._TooltipGui   = Gui;
self._TooltipFrame = Frame;
self._TooltipLabel = Lbl;
end;

local Frame    = self._TooltipFrame;
local Lbl      = self._TooltipLabel;
local InInfo   = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local OutInfo  = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
local SwapInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In);

self.Connection(self,Inst.MouseEnter, function()
self._TooltipActive = Inst;
self._TooltipToken  = (self._TooltipToken or 0) + 1;
local Mine = self._TooltipToken;

local function FadeIn()
Lbl.Text                = tostring(Text);
Frame.Visible           = true;
Frame.GroupTransparency = 1;
Library.Tween(Library,Frame, InInfo, { GroupTransparency = 0 }):Play();
end;

if Frame.Visible and Frame.GroupTransparency < 1 then
Library.Tween(Library,Frame, SwapInfo, { GroupTransparency = 1 }):Play();
task.delay(SwapInfo.Time, function()
if self._TooltipToken == Mine then FadeIn() end;
end);
else
FadeIn();
end;
end);
self.Connection(self,Inst.MouseMoved, function(X, Y)
if self._TooltipActive ~= Inst then return end;
Frame.Position = UDim2.fromOffset(X + 14, Y + 6);
end);
self.Connection(self,Inst.MouseLeave, function()
if self._TooltipActive ~= Inst then return end;
self._TooltipActive = nil;
local Mine = (self._TooltipToken or 0) + 1;
self._TooltipToken = Mine;
Library.Tween(Library,Frame, OutInfo, { GroupTransparency = 1 }):Play();
task.delay(OutInfo.Time, function()
if self._TooltipToken == Mine then Frame.Visible = false end;
end);
end);
end

function Library.Window(self, Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local IsMobile = Services.UserInputService.TouchEnabled;
local Width     = tonumber(Opts.Width)     or (IsMobile and 280 or 400);
local Height    = tonumber(Opts.Height)    or (IsMobile and 400 or 700);
local MinWidth  = tonumber(Opts.MinWidth)  or (IsMobile and 200 or 280);
local MinHeight = tonumber(Opts.MinHeight) or (IsMobile and 300 or 400);
-- Make mobile sizes even smaller
if IsMobile then
    Width = Width * 0.85
    Height = Height * 0.85
    MinWidth = MinWidth * 0.85
    MinHeight = MinHeight * 0.85
end
if Width  < MinWidth  then Width  = MinWidth  end;
if Height < MinHeight then Height = MinHeight end;

local Gui = self.CreateInstance(self,"ScreenGui", {
Name = "NetworphTallWindow";
Parent = (gethui and gethui()) or Services.CoreGui;
IgnoreGuiInset = true;
ResetOnSpawn = false;
ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
});

local Outer = self.CreateInstance(self,"Frame", {
Name = "Outer";
Parent = Gui;
AnchorPoint = Vector2.new(0.5, 0.5);
Position = UDim2.new(0.5, 0, 0.5, 0);
Size = UDim2.fromOffset(Width, Height);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel = 0;
});
self.CreateInstance(self,"UIGradient", {
Parent   = Outer;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("212121"));
NewColorSequenceKeypoint(1, Color3.fromHex("1A1A1A"));
});
});
self.CreateInstance(self,"UIStroke", {
Parent          = Outer;
Color           = Color3.fromHex("000000");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
LineJoinMode    = Enum.LineJoinMode.Miter;
});

local InnerOutline = self.CreateInstance(self,"Frame", {
Name = "InnerOutline";
Parent = Outer;
Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2);
BackgroundTransparency = 1;
BorderSizePixel = 0;
});
self.CreateInstance(self,"UIStroke", {
Parent          = InnerOutline;
Color           = Color3.fromHex("393939");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
LineJoinMode    = Enum.LineJoinMode.Miter;
});

local TopLine = self.CreateInstance(self,"Frame", {
Name = "TopLine";
Parent = Outer;
Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 0, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel = 0;
ZIndex = 10;
});
local TopLineGradient = self.CreateInstance(self,"UIGradient", {
Parent = TopLine;
Rotation = 0;
});
Library.RegisterAccentGradient(Library,TopLineGradient);

local TitleText = tostring(Opts.Title or Opts.Name or "Networph");
local Title = self.CreateInstance(self,"TextLabel", {
Name                   = "Title";
Parent                 = Outer;
AnchorPoint            = Vector2.new(0.5, 0);
Position               = UDim2.new(0.5, 0, 0, (IsMobile and 4 or 9));
Size                   = UDim2.new(1, -12, 0, (IsMobile and 12 or 18));
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = TitleText;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = (IsMobile and 8 or 12);
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Title.FontFace = ProggyCleanFont end;

local Content = self.CreateInstance(self,"Frame", {
Name             = "Content";
Parent           = Outer;
Position         = UDim2.new(0, 5, 0, (IsMobile and 18 or 34));
Size             = UDim2.new(1, -10, 1, -(IsMobile and 22 or 39));
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIGradient", {
Parent   = Content;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
NewColorSequenceKeypoint(1, Color3.fromHex("101010"));
});
});

local function ContentEdge(Name, Anchor, Pos, Sz, Color)
self.CreateInstance(self,"Frame", {
Name             = Name;
Parent           = Content;
AnchorPoint      = Anchor;
Position         = Pos;
Size             = Sz;
BackgroundColor3 = Color3.fromHex(Color);
BorderSizePixel  = 0;
ZIndex           = 10;
});
end;
ContentEdge("LeftBlack",   Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),   "000000");
ContentEdge("LeftGray",    Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2),  "393939");
ContentEdge("RightBlack",  Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),   "000000");
ContentEdge("RightGray",   Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2),  "393939");
ContentEdge("BottomBlack", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),   "000000");
ContentEdge("BottomGray",  Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1),  "393939");

self:Draggable(Outer);
do
local scClip = self.CreateInstance(self,"Frame", {
Active                  = true;
AnchorPoint             = Vector2.new(1, 1);
BackgroundTransparency  = 1;
ClipsDescendants        = true;
Position                = UDim2.new(1, 0, 1, 0);
Size                    = UDim2.fromOffset(22, 22);
ZIndex                  = 300;
Parent                  = Outer;
});
local scCircle = self.CreateInstance(self,"Frame", {
AnchorPoint             = Vector2.new(0, 0);
BackgroundColor3        = self.Accent;
BackgroundTransparency  = 0.4;
BorderSizePixel         = 0;
Position                = UDim2.fromOffset(0, 0);
Size                    = UDim2.fromOffset(44, 44);
ZIndex                  = 301;
Parent                  = scClip;
});
self:RegisterAccent(scCircle, "BackgroundColor3");
self.CreateInstance(self,"UICorner", { CornerRadius = UDim.new(1, 0); Parent = scCircle });

scClip.MouseEnter:Connect(function()
scCircle.BackgroundTransparency = 0.65;
end);
scClip.MouseLeave:Connect(function()
scCircle.BackgroundTransparency = 0.4;
end);

self:BindResizeHandleGhost(scClip, scCircle, function()
return Outer.Size.X.Offset, Outer.Size.Y.Offset;
end, function(w, h)
local minW = MinWidth;
local minH = MinHeight;
local nw = math.max(math.floor(tonumber(w) or Outer.Size.X.Offset), minW);
local nh = math.max(math.floor(tonumber(h) or Outer.Size.Y.Offset), minH);
Outer.Size = UDim2.fromOffset(nw, nh);
end);
end;

local Window = { Gui = Gui, Outer = Outer, TopLine = TopLine, Content = Content };
Window._Tabs = {};

-- Mobile toggle button (only visible on mobile)
if IsMobile then
    local MobileToggle = Library.CreateInstance(Library,"TextButton", {
        Name                   = "MobileToggle";
        Parent                 = (gethui and gethui()) or Services.CoreGui;
        AnchorPoint            = Vector2.new(1, 1);
        Position               = UDim2.new(1, -10, 1, -10);
        Size                   = UDim2.fromOffset(40, 40);
        BackgroundColor3       = Library.Accent;
        BackgroundTransparency = 0.2;
        BorderSizePixel        = 0;
        AutoButtonColor        = false;
        Text                   = "☰";
        TextColor3             = Color3.fromHex("FFFFFF");
        TextSize               = 20;
        TextXAlignment         = Enum.TextXAlignment.Center;
        TextYAlignment         = Enum.TextYAlignment.Center;
        ZIndex                 = 1000;
    });
    Library.CreateInstance(Library,"UICorner", {
        Parent = MobileToggle;
        CornerRadius = UDim.new(0, 8);
    });
    Library.CreateInstance(Library,"UIStroke", {
        Parent          = MobileToggle;
        Color           = Color3.fromHex("000000");
        Thickness       = 2;
        Transparency    = 0;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    });
    
    Library.RegisterAccent(Library,MobileToggle, "BackgroundColor3");
    
    MobileToggle.MouseButton1Click:Connect(function()
        Window:Toggle();
    end);
    
    Window.MobileToggle = MobileToggle;
end

function Window:Tab(NameOrOpts)
local TabOpts = typeof(NameOrOpts) == "table" and NameOrOpts or { Name = tostring(NameOrOpts) };
local TabName = tostring(TabOpts.Name or TabOpts.Title or "Tab");

if not self._Tabs then
    self._Tabs = {}
end

if not self.TabBar then
self.TabBar = Library.CreateInstance(Library,"Frame", {
Name                   = "TabBar";
Parent                 = self.Content;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, (IsMobile and 12 or 24));
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ZIndex                 = 5;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = self.TabBar;
FillDirection = Enum.FillDirection.Horizontal;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 0);
});
end;

local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Tab_" .. TabName;
Parent                 = self.TabBar;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
LayoutOrder            = (self._Tabs and #self._Tabs or 0) + 1;
});

local Bg = Library.CreateInstance(Library,"Frame", {
Name             = "Bg";
Parent           = Btn;
Position         = UDim2.new(0, 0, 0, 0);
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local Gradient = Library.CreateInstance(Library,"UIGradient", {
Parent   = Bg;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
});
});

local function MakePiece(Name, Anchor, Pos, Sz, Color, ZIdx)
return Library.CreateInstance(Library,"Frame", {
Name                   = Name;
Parent                 = Bg;
AnchorPoint            = Anchor;
Position               = Pos;
Size                   = Sz;
BackgroundColor3       = Color3.fromHex(Color);
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = ZIdx;
});
end;

local TopBlack    = MakePiece("TopBlack",    Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 1), "000000", 4);
local TopGray     = MakePiece("TopGray",     Vector2.new(0, 0), UDim2.new(0, 0, 0, 1), UDim2.new(1, 0, 0, 1), "393939", 4);
local BottomBlack = MakePiece("BottomBlack", Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 1), "000000", 4);
local BottomGray  = MakePiece("BottomGray",  Vector2.new(0, 1), UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), "393939", 4);
local LeftBlack   = MakePiece("LeftBlack",   Vector2.new(0, 0), UDim2.new(0, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000", 3);
local LeftGray    = MakePiece("LeftGray",    Vector2.new(0, 0), UDim2.new(0, 1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
local RightBlack  = MakePiece("RightBlack",  Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.new(0, 1, 1, 0), "000000", 3);
local RightGray   = MakePiece("RightGray",   Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);

local Separator = Library.CreateInstance(Library,"Frame", {
Name                   = "Separator";
Parent                 = Bg;
AnchorPoint            = Vector2.new(1, 0);
Position               = UDim2.new(1, 0, 0, 2);
Size                   = UDim2.new(0, 1, 1, -4);
BackgroundColor3       = Color3.fromHex("393939");
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = 2;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Bg;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = TabName;
TextSize               = 12;
TextColor3             = Color3.fromHex("8C8F99");
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local TopGradient = Library.CreateInstance(Library,"Frame", {
Name                   = "TopGradient";
Parent                 = Bg;
AnchorPoint            = Vector2.new(0, 0);
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 1);
BackgroundColor3       = Color3.fromHex("FFFFFF");
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = 5;
});
local TabTopGradient = Library.CreateInstance(Library,"UIGradient", {
Parent   = TopGradient;
Rotation = 0;
});
Library.RegisterAccentGradient(Library,TabTopGradient);

local Page = Library.CreateInstance(Library,"CanvasGroup", {
Name                   = "Page_" .. TabName;
Parent                 = self.Content;
Position               = UDim2.new(0, 0, 0, (IsMobile and 12 or 24));
Size                   = UDim2.new(1, 0, 1, -(IsMobile and 12 or 24));
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Visible                = false;
GroupTransparency      = 1;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = Page;
PaddingLeft   = UDim.new(0, (IsMobile and 2 or 6));
PaddingRight  = UDim.new(0, (IsMobile and 2 or 6));
PaddingTop    = UDim.new(0, (IsMobile and 4 or 11));
PaddingBottom = UDim.new(0, (IsMobile and 2 or 6));
});

local LeftColumn = Library.CreateInstance(Library,"ScrollingFrame", {
Name                   = "Left";
Parent                 = Page;
AnchorPoint            = Vector2.new(0, 0);
Position               = UDim2.new(0, 0, 0, -2);
Size                   = UDim2.new(0.5, -3, 1, 2);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
CanvasSize             = UDim2.new(0, 0, 0, 0);
AutomaticCanvasSize    = Enum.AutomaticSize.Y;
ScrollBarThickness     = 0;
ScrollingDirection     = Enum.ScrollingDirection.Y;
ClipsDescendants       = true;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = LeftColumn;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 6);
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = LeftColumn;
PaddingTop    = UDim.new(0, 4);
PaddingBottom = UDim.new(0, 6);
});

local RightColumn = Library.CreateInstance(Library,"ScrollingFrame", {
Name                   = "Right";
Parent                 = Page;
AnchorPoint            = Vector2.new(1, 0);
Position               = UDim2.new(1, 0, 0, -2);
Size                   = UDim2.new(0.5, -3, 1, 2);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
CanvasSize             = UDim2.new(0, 0, 0, 0);
AutomaticCanvasSize    = Enum.AutomaticSize.Y;
ScrollBarThickness     = 0;
ScrollingDirection     = Enum.ScrollingDirection.Y;
ClipsDescendants       = true;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = RightColumn;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 6);
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = RightColumn;
PaddingTop    = UDim.new(0, 4);
PaddingBottom = UDim.new(0, 6);
});

local TabRef = {
Name        = TabName;
Button      = Btn;
Bg          = Bg;
Label       = Lbl;
Page        = Page;
Left        = LeftColumn;
Right       = RightColumn;
Gradient    = Gradient;
Separator   = Separator;
TopBlack    = TopBlack;
TopGray     = TopGray;
BottomBlack = BottomBlack;
BottomGray  = BottomGray;
LeftBlack   = LeftBlack;
LeftGray    = LeftGray;
RightBlack  = RightBlack;
RightGray   = RightGray;
TopGradient = TopGradient;
Active      = false;
IsLeft      = false;
IsRight     = false;
};

local PageInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local BgInfo   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local InactiveA, InactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
local ActiveA,   ActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
local GradT      = TabRef.Active and 1 or 0;
local GradTarget = GradT;
local function ApplyGrad()
Gradient.Color = NewColorSequence({
NewColorSequenceKeypoint(0, InactiveA:Lerp(ActiveA, GradT));
NewColorSequenceKeypoint(1, InactiveB:Lerp(ActiveB, GradT));
});
end;
Gradient.Enabled = true;
ApplyGrad();
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if math.abs(GradTarget - GradT) < 0.001 then
if GradT ~= GradTarget then GradT = GradTarget; ApplyGrad() end;
return;
end;
GradT = GradT + (GradTarget - GradT) * (1 - math.exp(-Dt * 16));
ApplyGrad();
end);

function TabRef:SetActive(State)
self.Active = State;
if State then
if self.Page and self.Page.Parent then
    self.Page.Visible = true;
    Library.Tween(Library,self.Page, PageInfo, { GroupTransparency = 0 }):Play();
end
local Lo = self.IsLeft  and 1 or 0;
local Ro = self.IsRight and 1 or 0;
if Bg and Bg.Parent then
    Library.Tween(Library,Bg, BgInfo, {
    Position = UDim2.new(0, Lo, 0, 1);
    Size     = UDim2.new(1, -Lo - Ro, 1, -1);
    }):Play();
end
GradTarget          = 1;
if Bg and Bg.Parent then
    Bg.BackgroundColor3 = Color3.fromHex("FFFFFF");
end
if Lbl and Lbl.Parent then
    Library.Tween(Library,Lbl, BgInfo, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
end
if TopGradient and TopGradient.Parent then
    TopGradient.Position = UDim2.new(0, 0, 0, 0);
    TopGradient.Size     = UDim2.new(1, 0, 0, 1);
end
else
local P = self.Page;
if P and P.Parent then
    Library.Tween(Library,P, PageInfo, { GroupTransparency = 1 }):Play();
    task.delay(PageInfo.Time, function()
    if not self.Active then P.Visible = false end;
    end);
end
if Bg and Bg.Parent then
    Library.Tween(Library,Bg, BgInfo, {
    Position = UDim2.new(0, 0, 0, 0);
    Size     = UDim2.new(1, 0, 1, 0);
    }):Play();
end
GradTarget          = 0;
if Bg and Bg.Parent then
    Bg.BackgroundColor3 = Color3.fromHex("FFFFFF");
end
if Lbl and Lbl.Parent then
    Library.Tween(Library,Lbl, BgInfo, { TextColor3 = Color3.fromHex("8C8F99") }):Play();
end
end;
end;

function TabRef:Section(SecOpts)
SecOpts = typeof(SecOpts) == "table" and SecOpts or { Name = tostring(SecOpts) };
local SecName = tostring(SecOpts.Name or SecOpts.Title or "section");
local Side    = string.lower(tostring(SecOpts.Side or "Left"));
local Column  = (Side == "right") and self.Right or self.Left;

local Sec = Library.CreateInstance(Library,"Frame", {
Name                   = "Section_" .. SecName;
Parent                 = Column;
Size                   = UDim2.new(1, 0, 0, 0);
AutomaticSize          = Enum.AutomaticSize.Y;
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local function Edge(Anchor, Pos, Sz, Color)
Library.CreateInstance(Library,"Frame", {
Parent           = Sec;
AnchorPoint      = Anchor;
Position         = Pos;
Size             = Sz;
BackgroundColor3 = Color3.fromHex(Color);
BorderSizePixel  = 0;
ZIndex           = 5;
});
end;
Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000"); 
local TopLine = Library.CreateInstance(Library,"Frame", {
Name             = "TopLine";
Parent           = Sec;
AnchorPoint      = Vector2.new(0, 0);
Position         = UDim2.new(0, 0, 0, 1);
Size             = UDim2.new(1, 0, 0, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
ZIndex           = 5;
});
local SecTopGradient = Library.CreateInstance(Library,"UIGradient", {
Parent   = TopLine;
Rotation = 0;
});
Library.RegisterAccentGradient(Library,SecTopGradient);
Edge(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000"); 
Edge(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939"); 
Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000"); 
Edge(Vector2.new(0, 0), UDim2.new(0, 1, 0, 2),  UDim2.new(0, 1, 1, -3), "393939"); 
Edge(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000"); 
Edge(Vector2.new(1, 0), UDim2.new(1, -1, 0, 2), UDim2.new(0, 1, 1, -3), "393939"); 

local TitleCover = Library.CreateInstance(Library,"Frame", {
Name             = "TitleCover";
Parent           = Sec;
Position         = UDim2.new(0, 7, 0, 0);
Size             = UDim2.new(0, 0, 0, 2);
BackgroundColor3 = Color3.fromHex("161616");
BorderSizePixel  = 0;
ZIndex           = 6;
});

local GradTop    = Color3.fromHex("161616");
local GradBottom = Color3.fromHex("101010");
local function UpdateCoverColor()
local Ch = self.Page.Parent.AbsoluteSize.Y;
if Ch <= 0 then return end;
local T = math.clamp(
(TitleCover.AbsolutePosition.Y - self.Page.Parent.AbsolutePosition.Y) / Ch,
0, 1
);
TitleCover.BackgroundColor3 = GradTop:Lerp(GradBottom, T);
end;
TitleCover:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateCoverColor);
self.Page.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCoverColor);
task.defer(UpdateCoverColor);

local SecTitle = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Title";
Parent                 = Sec;
AnchorPoint            = Vector2.new(0, 0.5);
Position               = UDim2.new(0, 11, 0, 2);
AutomaticSize          = Enum.AutomaticSize.X;
Size                   = UDim2.new(0, 0, 0, 14);
BackgroundTransparency = 1;
Text                   = SecName;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
ZIndex                 = 7;
});
if ProggyCleanFont then SecTitle.FontFace = ProggyCleanFont end;

local function UpdateCover()
TitleCover.Size = UDim2.new(0, SecTitle.AbsoluteSize.X + 8, 0, 2);
end;
SecTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCover);
UpdateCover();

local Body = Library.CreateInstance(Library,"Frame", {
Name                   = "Body";
Parent                 = Sec;
Position               = UDim2.new(0, 8, 0, 12);
Size                   = UDim2.new(1, -16, 0, 0);
AutomaticSize          = Enum.AutomaticSize.Y;
BackgroundTransparency = 1;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = Body;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 4);
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = Body;
PaddingBottom = UDim.new(0, 8);
});

local SecRef = { Name = SecName, Frame = Sec, Title = SecTitle, Body = Body };

function SecRef:Toggle(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Toggle");
local Default  = Opts.Default == true;
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
local State    = Default;
Library.Flags[Flag] = State;

local Risk = Opts.Risk and string.lower(tostring(Opts.Risk))
or (Opts.Risky and "risky") or (Opts.Warning and "warning") or nil;
local OnColor  = Color3.fromHex("FFFFFF");
local OffColor = Color3.fromHex("8C8F99");
if Risk == "risky" or Risk == "danger" or Risk == "red" then
OnColor  = Color3.fromHex("FF8585");
OffColor = OnColor:Lerp(Color3.fromHex("4A4A4A"), 0.45);
elseif Risk == "warning" or Risk == "warn" or Risk == "yellow" then
OnColor  = Color3.fromHex("FFD27B");
OffColor = OnColor:Lerp(Color3.fromHex("4A4A4A"), 0.45);
end;

local Row = Library.CreateInstance(Library,"TextButton", {
Name                   = "Toggle_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 16);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
});

local Box = Library.CreateInstance(Library,"Frame", {
Name             = "Box";
Parent           = Row;
AnchorPoint      = Vector2.new(0, 0.5);
Position         = UDim2.new(0, 0, 0.5, 0);
Size             = UDim2.fromOffset(14, 14);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Name             = "Gray";
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Name             = "Inside";
Parent           = BoxGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("131313");
BorderSizePixel  = 0;
});

local Fill = Library.CreateInstance(Library,"Frame", {
Name                   = "Fill";
Parent                 = BoxInside;
AnchorPoint            = Vector2.new(0.5, 0.5);
Position               = UDim2.new(0.5, 0, 0.5, 0);
Size                   = UDim2.new(0, 0, 0, 0);
BackgroundColor3       = Color3.fromHex("3972EC");
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.RegisterAccent(Library,Fill);

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Row;
AnchorPoint            = Vector2.new(0, 0.5);
Position               = UDim2.new(0, 20, 0.5, 0);
Size                   = UDim2.new(1, -20, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local TweenIn  = TweenInfo.new(0.16, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out);
local TweenOut = TweenInfo.new(0.14, Enum.EasingStyle.Quad,  Enum.EasingDirection.In);

local function Render()
local Info = State and TweenIn or TweenOut;
Library.Tween(Library,Fill, Info, {
Size                   = State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0);
BackgroundTransparency = State and 0 or 1;
}):Play();
Library.Tween(Library,Lbl, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextColor3 = State and OnColor or OffColor;
}):Play();
end;
Fill.Size                   = State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0);
Fill.BackgroundTransparency = State and 0 or 1;
Lbl.TextColor3              = State and OnColor or OffColor;

local Listeners = {};
local function SetState(V, Fire)
V = V == true;
if V == State then return end;
State = V;
Library.Flags[Flag] = State;
Render();
if Fire ~= false then Callback(State) end;
for _, Fn in Listeners do Fn(State) end;
end;

Row.MouseButton1Click:Connect(function() SetState(not State) end);

if Opts.Tooltip then Library.Tooltip(Library,Row, Opts.Tooltip) end;

local Obj = { Container = Row, Box = Box, Fill = Fill };
function Obj:Get() return State end;
function Obj:Set(V) SetState(V) end;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Toggle", Obj = Obj };
end
function Obj:OnChange(Fn)
if typeof(Fn) ~= "function" then return end;
table.insert(Listeners, Fn);
Fn(State);
end;

function Obj:AddKeybind(BindOpts)
if self._HasKeybind then return self end;
self._HasKeybind = true;
BindOpts = typeof(BindOpts) == "table" and BindOpts or {};
local BindMode = string.lower(tostring(BindOpts.Mode or "Toggle"));
local Key      = BindOpts.Default;
local KeybindName = tostring(BindOpts.Name or Name);
local KeybindCallback = typeof(BindOpts.Callback) == "function" and BindOpts.Callback or function() end;

local function KeyText(K)
if K == nil then return "None" end;
if typeof(K) == "EnumItem" then return Library.KeyNames[K] or K.Name end;
return tostring(K);
end;

local KBoxW = 48;
local Off = self._RightOffset or 0;

local KBtn = Library.CreateInstance(Library,"TextButton", {
Name             = "Keybind";
Parent           = Row;
AnchorPoint      = Vector2.new(1, 0.5);
Position         = UDim2.new(1, -Off, 0.5, 0);
Size             = UDim2.fromOffset(KBoxW, 16);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
local KGray = Library.CreateInstance(Library,"Frame", {
Name             = "Gray";
Parent           = KBtn;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local KInside = Library.CreateInstance(Library,"Frame", {
Name             = "Inside";
Parent           = KGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = KInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});
local KLbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Display";
Parent                 = KInside;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
Text                   = KeyText(Key);
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then KLbl.FontFace = ProggyCleanFont end;

local Listening = false;
local ListenConn;
local function Refresh()
if Listening then
KLbl.Text       = "...";
KLbl.TextColor3 = Library.Accent;
else
KLbl.Text       = KeyText(Key);
KLbl.TextColor3 = Color3.fromHex("FFFFFF");
end;
end;
local function CancelListen()
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Listening = false;
Refresh();
end;
local function StartListen()
if Listening then CancelListen(); return end;
Listening = true;
Refresh();
task.defer(function()
if not Listening then return end;
ListenConn = Services.UserInputService.InputBegan:Connect(function(Input)
local T = Input.UserInputType;
if T == Enum.UserInputType.Keyboard then
local K = Input.KeyCode;
if K == Enum.KeyCode.Escape then
CancelListen();
else
Key = K;
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Refresh();
Library.NotifyKeybind(Library);
KeybindCallback(Key, BindMode);
end;
elseif T == Enum.UserInputType.MouseButton1
or T == Enum.UserInputType.MouseButton2
or T == Enum.UserInputType.MouseButton3 then
Key = T;
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Refresh();
Library.NotifyKeybind(Library);
KeybindCallback(Key, BindMode);
end;
end);
end);
end;

KBtn.MouseButton1Click:Connect(StartListen);
KBtn.MouseButton2Click:Connect(function()
if Listening then CancelListen() end;
Key = nil;
Refresh();
Library.NotifyKeybind(Library);
KeybindCallback(Key, BindMode);
end);

local function KeyMatches(Input)
if Key == nil or typeof(Key) ~= "EnumItem" then return false end;
if Key.EnumType == Enum.KeyCode then
return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key;
elseif Key.EnumType == Enum.UserInputType then
return Input.UserInputType == Key;
end;
return false;
end;
Library.Connection(Library,Services.UserInputService.InputBegan, function(Input, GameProc)
if GameProc then return end;
if Listening then return end;
if Services.UserInputService:GetFocusedTextBox() then return end;
if not KeyMatches(Input) then return end;
if BindMode == "hold" then
SetState(true);
else
SetState(not State);
end;
end);
Library.Connection(Library,Services.UserInputService.InputEnded, function(Input)
if BindMode ~= "hold" then return end;
if not KeyMatches(Input) then return end;
SetState(false);
end);

Library.RegisterKeybind(Library, {
Name     = KeybindName;
Mode     = BindMode;
GetKey   = function() return Key end;
GetState = function() return State end;
});

self._RightOffset = Off + KBoxW + 4;
Lbl.Size = UDim2.new(1, -20 - self._RightOffset, 1, 0);
self.Keybind        = KBtn;
self.KeybindDisplay = KLbl;
return self;
end;

function Obj:AddColorpicker(CpOpts)
CpOpts = typeof(CpOpts) == "table" and CpOpts or {};
local Color    = typeof(CpOpts.Default) == "Color3" and CpOpts.Default or Color3.fromRGB(255,255,255);
local Alpha    = tonumber(CpOpts.Alpha) or 1;
local Callback = typeof(CpOpts.Callback) == "function" and CpOpts.Callback or function() end;
self._Colors   = (self._Colors or 0) + 1;
local Flag     = tostring(CpOpts.Flag or CpOpts.Pointer or ("_" .. Name .. "Color" .. self._Colors));
local H, Sa, Va = Color3.toHSV(Color);
local A         = math.clamp(Alpha, 0, 1);
Library.Flags[Flag] = Color;

local SwW, SwH = 25, 15;
local Off = self._RightOffset or 0;

local Swatch = Library.CreateInstance(Library,"TextButton", {
Name             = "ToggleSwatch";
Parent           = Row;
AnchorPoint      = Vector2.new(1, 0.5);
Position         = UDim2.new(1, -Off, 0.5, 0);
Size             = UDim2.fromOffset(SwW, SwH);
AutoButtonColor  = false;
Text             = "";
BackgroundColor3 = Color3.fromHex("000105");
BorderSizePixel  = 0;
});
local SwInline = Library.CreateInstance(Library,"Frame", {
Parent           = Swatch;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("252527");
BorderSizePixel  = 0;
});
local SwHandle = Library.CreateInstance(Library,"Frame", {
Parent           = SwInline;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"ImageLabel", {
Parent                 = SwHandle;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Image                  = "rbxassetid://18274452449";
ScaleType              = Enum.ScaleType.Tile;
TileSize               = UDim2.new(0, 6, 0, 6);
ZIndex                 = 2;
});
local SwFill = Library.CreateInstance(Library,"Frame", {
Parent                 = SwHandle;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundColor3       = Color;
BackgroundTransparency = 1 - Alpha;
BorderSizePixel        = 0;
ZIndex                 = 3;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = SwFill;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromRGB(255, 255, 255));
NewColorSequenceKeypoint(1, Color3.fromRGB(167, 167, 167));
});
});

self._RightOffset = Off + SwW + 4;
Lbl.Size = UDim2.new(1, -20 - self._RightOffset, 1, 0);

local PickerHolder = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "TogglePicker";
Parent            = Gui;
Size              = UDim2.new(0, 218, 0, 248);
BackgroundColor3  = Color3.fromHex("131313");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 50;
});
local PickerOuterStroke = Library.CreateInstance(Library,"UIStroke", {
Parent          = PickerHolder;
Color           = Color3.fromHex("000000");
Thickness       = 1;
Transparency    = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local PickerInner = Library.CreateInstance(Library,"Frame", {
Parent                 = PickerHolder;
Position               = UDim2.new(0, 1, 0, 1);
Size                   = UDim2.new(1, -2, 1, -2);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
local PickerInnerStroke = Library.CreateInstance(Library,"UIStroke", {
Parent          = PickerInner;
Color           = Color3.fromHex("393939");
Thickness       = 1;
Transparency    = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local PickerBody = Library.CreateInstance(Library,"Frame", {
Parent                 = PickerHolder;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = PickerBody;
PaddingTop    = UDim.new(0, 8);
PaddingBottom = UDim.new(0, 8);
PaddingLeft   = UDim.new(0, 8);
PaddingRight  = UDim.new(0, 8);
});
local MainBg = Library.CreateInstance(Library,"Frame", {
Parent                 = PickerBody;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local TabBar = Library.CreateInstance(Library,"Frame", {
Name                   = "TabBar";
Parent                 = MainBg;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 20);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
local CpInactiveSeq = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
});
local CpActiveSeq = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
NewColorSequenceKeypoint(1, Color3.fromHex("151515"));
});
local CpAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
local CpInactiveA, CpInactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
local CpActiveA,   CpActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
local CpOutlineNames = { "TopBlack", "TopGray", "BottomBlack", "BottomGray", "LeftBlack", "LeftGray", "RightBlack", "RightGray" };
local ColorPage, AnimationsPanel;
local CpTabToken = 0;

local TabButtons = {};
local function MakeCpTab(Name, Idx, Total)
local Btn = Library.CreateInstance(Library,"TextButton", {
Parent                 = TabBar;
Size                   = UDim2.new(1 / Total, 0, 1, 0);
Position               = UDim2.new((Idx - 1) / Total, 0, 0, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
});
local Bg = Library.CreateInstance(Library,"Frame", {
Name             = "Bg";
Parent           = Btn;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local BgGrad = Library.CreateInstance(Library,"UIGradient", {
Parent   = Bg;
Rotation = 90;
Color    = CpInactiveSeq;
});
local function MakePiece(Anchor, Pos, Sz, Color, ZIdx)
return Library.CreateInstance(Library,"Frame", {
Parent                 = Bg;
AnchorPoint            = Anchor;
Position               = Pos;
Size                   = Sz;
BackgroundColor3       = Color3.fromHex(Color);
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = ZIdx;
});
end;
local TopBlack    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
local TopGray     = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(1, -2, 0, 1), "393939", 4);
local BottomBlack = MakePiece(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
local BottomGray  = MakePiece(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939", 4);
local LeftBlack   = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
local LeftGray    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2), "393939", 3);
local RightBlack  = MakePiece(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
local RightGray   = MakePiece(Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
local TopGradient = Library.CreateInstance(Library,"Frame", {
Parent                 = Bg;
AnchorPoint            = Vector2.new(0, 0);
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 1);
BackgroundColor3       = Color3.fromHex("FFFFFF");
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = 5;
});
local Grad = Library.CreateInstance(Library,"UIGradient", { Parent = TopGradient; Rotation = 0 });
Library.RegisterAccentGradient(Library,Grad);
local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Bg;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextSize               = 12;
TextColor3             = Color3.fromHex("FFFFFF");
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
ZIndex                 = 6;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Entry = {
Btn = Btn, Bg = Bg, Lbl = Lbl, BgGrad = BgGrad, TopGradient = TopGradient;
TopBlack = TopBlack, TopGray = TopGray;
BottomBlack = BottomBlack, BottomGray = BottomGray;
LeftBlack = LeftBlack, LeftGray = LeftGray;
RightBlack = RightBlack, RightGray = RightGray;
GradT = 0; GradTarget = 0;
};
local function ApplyGrad()
BgGrad.Color = NewColorSequence({
NewColorSequenceKeypoint(0, CpInactiveA:Lerp(CpActiveA, Entry.GradT));
NewColorSequenceKeypoint(1, CpInactiveB:Lerp(CpActiveB, Entry.GradT));
});
end;
ApplyGrad();
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if math.abs(Entry.GradTarget - Entry.GradT) < 0.001 then
if Entry.GradT ~= Entry.GradTarget then
Entry.GradT = Entry.GradTarget;
ApplyGrad();
end;
return;
end;
Entry.GradT = Entry.GradT + (Entry.GradTarget - Entry.GradT) * (1 - math.exp(-Dt * 16));
ApplyGrad();
end);
table.insert(TabButtons, Entry);
return Btn;
end;
local ColorTabBtn = MakeCpTab("Color", 1, 2);
local AnimationsTabBtn = MakeCpTab("Animations", 2, 2);

local function SetCpTab(I)
for i, T in TabButtons do
if i == I then
T.GradTarget = 1;
Library.Tween(Library,T.TopGradient, CpAnimInfo, { BackgroundTransparency = 0 }):Play();
for _, N in CpOutlineNames do
Library.Tween(Library,T[N], CpAnimInfo, { BackgroundTransparency = 1 }):Play();
end;
else
T.GradTarget = 0;
Library.Tween(Library,T.TopGradient, CpAnimInfo, { BackgroundTransparency = 1 }):Play();
for _, N in CpOutlineNames do
Library.Tween(Library,T[N], CpAnimInfo, { BackgroundTransparency = 0 }):Play();
end;
end;
end;
if ColorPage and AnimationsPanel then
CpTabToken = CpTabToken + 1;
local Mine = CpTabToken;
ColorPage.Visible       = true;
AnimationsPanel.Visible = true;
if I == 1 then
Library.Tween(Library,ColorPage,       CpAnimInfo, { GroupTransparency = 0 }):Play();
Library.Tween(Library,AnimationsPanel, CpAnimInfo, { GroupTransparency = 1 }):Play();
else
Library.Tween(Library,ColorPage,       CpAnimInfo, { GroupTransparency = 1 }):Play();
Library.Tween(Library,AnimationsPanel, CpAnimInfo, { GroupTransparency = 0 }):Play();
end;
task.delay(CpAnimInfo.Time, function()
if CpTabToken ~= Mine then return end;
if I == 1 then AnimationsPanel.Visible = false end;
if I == 2 then ColorPage.Visible       = false end;
end);
end;
end;
SetCpTab(1);
ColorTabBtn.MouseButton1Click:Connect(function() SetCpTab(1) end);
AnimationsTabBtn.MouseButton1Click:Connect(function() SetCpTab(2) end);

ColorPage = Library.CreateInstance(Library,"CanvasGroup", {
Name                   = "ColorPage";
Parent                 = MainBg;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
GroupTransparency      = 0;
ZIndex                 = 54;
});

local SatValArea = Library.CreateInstance(Library,"Frame", {
Parent           = ColorPage;
Position         = UDim2.new(0, 0, 0, 24);
Size             = UDim2.new(1, -30, 1, -66);
BackgroundColor3 = Color3.fromRGB(255, 0, 0);
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIStroke", {
Parent          = SatValArea;
Color           = Color3.fromHex("000105");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local SatLayer = Library.CreateInstance(Library,"TextButton", {
Parent           = SatValArea;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
Library.CreateInstance(Library,"UIGradient", {
Parent       = SatLayer;
Rotation     = 270;
Transparency = NewNumberSequence({
NewNumberSequenceKeypoint(0, 0);
NewNumberSequenceKeypoint(1, 1);
});
Color = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromRGB(0, 0, 0));
NewColorSequenceKeypoint(1, Color3.fromRGB(0, 0, 0));
});
});
local ValLayer = Library.CreateInstance(Library,"TextButton", {
Parent           = SatValArea;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
Library.CreateInstance(Library,"UIGradient", {
Parent       = ValLayer;
Transparency = NewNumberSequence({
NewNumberSequenceKeypoint(0, 0);
NewNumberSequenceKeypoint(1, 1);
});
});
local SatValMarker = Library.CreateInstance(Library,"Frame", {
Parent           = SatValArea;
Size             = UDim2.new(0, 2, 0, 2);
BorderSizePixel  = 1;
BorderColor3     = Color3.fromRGB(0, 0, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
});
local HueArea = Library.CreateInstance(Library,"TextButton", {
Parent           = ColorPage;
AnchorPoint      = Vector2.new(1, 0);
Position         = UDim2.new(1, -14, 0, 24);
Size             = UDim2.new(0, 12, 1, -66);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
Library.CreateInstance(Library,"UIStroke", {
Parent          = HueArea;
Color           = Color3.fromHex("000105");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = HueArea;
Rotation = 270;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0,    Color3.fromRGB(255, 0, 0));
NewColorSequenceKeypoint(0.17, Color3.fromRGB(255, 255, 0));
NewColorSequenceKeypoint(0.33, Color3.fromRGB(0, 255, 0));
NewColorSequenceKeypoint(0.5,  Color3.fromRGB(0, 255, 255));
NewColorSequenceKeypoint(0.67, Color3.fromRGB(0, 0, 255));
NewColorSequenceKeypoint(0.83, Color3.fromRGB(255, 0, 255));
NewColorSequenceKeypoint(1,    Color3.fromRGB(255, 0, 0));
});
});
local HueMarker = Library.CreateInstance(Library,"Frame", {
Parent           = HueArea;
Size             = UDim2.new(1, 0, 0, 2);
BorderSizePixel  = 1;
BorderColor3     = Color3.fromRGB(0, 0, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
});
local AlphaArea = Library.CreateInstance(Library,"TextButton", {
Parent           = ColorPage;
AnchorPoint      = Vector2.new(1, 0);
Position         = UDim2.new(1, 0, 0, 24);
Size             = UDim2.new(0, 12, 1, -66);
BackgroundColor3 = Color;
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
Library.CreateInstance(Library,"UIStroke", {
Parent          = AlphaArea;
Color           = Color3.fromHex("000105");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local AlphaCheckers = Library.CreateInstance(Library,"ImageLabel", {
Parent                 = AlphaArea;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Image                  = "rbxassetid://18274452449";
ScaleType              = Enum.ScaleType.Tile;
TileSize               = UDim2.new(0, 6, 0, 6);
});
Library.CreateInstance(Library,"UIGradient", {
Parent       = AlphaCheckers;
Rotation     = 270;
Transparency = NewNumberSequence({
NewNumberSequenceKeypoint(0, 0);
NewNumberSequenceKeypoint(1, 1);
});
});
local AlphaMarker = Library.CreateInstance(Library,"Frame", {
Parent           = AlphaArea;
Size             = UDim2.new(1, 0, 0, 2);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 1;
BorderColor3     = Color3.fromRGB(0, 0, 0);
});

local function MakeInput(YOffFromBottom)
local Box = Library.CreateInstance(Library,"Frame", {
Parent           = ColorPage;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, -YOffFromBottom);
Size             = UDim2.new(1, 0, 0, 18);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local Gray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local Inside = Library.CreateInstance(Library,"Frame", {
Parent           = Gray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = Inside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});
local Input = Library.CreateInstance(Library,"TextBox", {
Parent                 = Inside;
Size                   = UDim2.new(1, -6, 1, 0);
Position               = UDim2.new(0, 3, 0, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ClearTextOnFocus       = false;
Text                   = "";
PlaceholderColor3      = Color3.fromHex("5E626B");
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
ClipsDescendants       = true;
});
if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
return Input, Box;
end;

local HexInput, HexBox = MakeInput(0);
HexInput.PlaceholderText = "Hex";
local RgbInput, RgbBox = MakeInput(20);
RgbInput.PlaceholderText = "R, G, B";

AnimationsPanel = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "AnimationsPanel";
Parent            = MainBg;
Position          = UDim2.new(0, 0, 0, 28);
Size              = UDim2.new(1, 0, 1, -28);
BackgroundColor3  = Color3.fromHex("131313");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 55;
});
local Mode  = "Solid";
local Speed = 50;
local function FontIt(L) if ProggyCleanFont then L.FontFace = ProggyCleanFont end end;
local function AnimLbl(Text, Y)
local L = Library.CreateInstance(Library,"TextLabel", {
Parent                 = AnimationsPanel;
Position               = UDim2.new(0, 0, 0, Y);
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
Text                   = Text;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
});
FontIt(L);
end;

AnimLbl("Mode", 0);
local ModeBox = Library.CreateInstance(Library,"TextButton", {
Parent           = AnimationsPanel;
Position         = UDim2.new(0, 0, 0, 14);
Size             = UDim2.new(1, 0, 0, 21);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
local ModeBoxGray = Library.CreateInstance(Library,"Frame", {
Parent = ModeBox; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
});
local ModeInside = Library.CreateInstance(Library,"Frame", {
Parent = ModeBoxGray; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent = ModeInside; Rotation = 90;
Color = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});
local ModeVal = Library.CreateInstance(Library,"TextLabel", {
Parent = ModeInside; Position = UDim2.new(0, 4, 0, 0); Size = UDim2.new(1, -14, 1, 0);
BackgroundTransparency = 1; Text = Mode; TextColor3 = Color3.fromHex("FFFFFF"); TextSize = 12;
TextXAlignment = Enum.TextXAlignment.Left; TextYAlignment = Enum.TextYAlignment.Center;
}); FontIt(ModeVal);
local ModeArrow = Library.CreateInstance(Library,"Frame", {
Parent = ModeInside; AnchorPoint = Vector2.new(1, 0.5);
Position = UDim2.new(1, -4, 0.5, 0); Size = UDim2.fromOffset(7, 7);
BackgroundTransparency = 1; BorderSizePixel = 0;
});
Library.CreateInstance(Library,"Frame", {
Parent = ModeArrow; AnchorPoint = Vector2.new(0.5, 0.5);
Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.fromOffset(7, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
});
local ModeArrowV = Library.CreateInstance(Library,"Frame", {
Parent = ModeArrow; AnchorPoint = Vector2.new(0.5, 0.5);
Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.fromOffset(1, 7);
BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
});
local function SetModeArrow(Plus) ModeArrowV.Visible = Plus end;

local ModePopup = Library.CreateInstance(Library,"CanvasGroup", {
Parent            = AnimationsPanel;
Position          = UDim2.new(0, 0, 0, 36);
Size              = UDim2.new(1, 0, 0, 44);
BackgroundColor3  = Color3.fromHex("000000");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 60;
});
local ModePopupGray = Library.CreateInstance(Library,"Frame", {
Parent = ModePopup; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0; ZIndex = 60;
});
local ModePopupInside = Library.CreateInstance(Library,"Frame", {
Parent = ModePopupGray; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0; ZIndex = 61;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent = ModePopupInside; FillDirection = Enum.FillDirection.Vertical;
SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 0);
});
local ModeOptionBtns = {};
local function RefreshModeOpts()
for N, B in ModeOptionBtns do
B.TextColor3 = (N == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
end;
end;
Library.OnAccent(Library,function() RefreshModeOpts() end);
local ModePopupOpen = false;
local ModePopupToken = 0;
local ModePopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
local ModePopupBaseY = 36;
local ModePopupSlide = 6;
local function CloseModePopup()
if not ModePopupOpen then return end;
ModePopupOpen = false;
ModePopupToken = ModePopupToken + 1;
local Mine = ModePopupToken;
SetModeArrow(true);
Library.Tween(Library,ModePopup, ModePopupInfo, {
GroupTransparency = 1;
Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
}):Play();
task.delay(ModePopupInfo.Time, function()
if ModePopupToken == Mine then ModePopup.Visible = false end;
end);
end;
local function OpenModePopup()
if ModePopupOpen then return end;
ModePopupOpen = true;
ModePopupToken = ModePopupToken + 1;
SetModeArrow(false);
ModePopup.GroupTransparency = 1;
ModePopup.Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
ModePopup.Visible           = true;
Library.Tween(Library,ModePopup, ModePopupInfo, {
GroupTransparency = 0;
Position          = UDim2.new(0, 0, 0, ModePopupBaseY);
}):Play();
end;
local function AddModeOpt(Name, Idx)
local Btn = Library.CreateInstance(Library,"TextButton", {
Parent = ModePopupInside; Size = UDim2.new(1, 0, 0, 14);
BackgroundTransparency = 1; BorderSizePixel = 0; AutoButtonColor = false;
Text = Name; TextColor3 = (Name == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
TextSize = 12; TextXAlignment = Enum.TextXAlignment.Left; LayoutOrder = Idx; ZIndex = 62;
});
Library.CreateInstance(Library,"UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
FontIt(Btn);
ModeOptionBtns[Name] = Btn;
Btn.MouseButton1Click:Connect(function()
Mode = Name; ModeVal.Text = Mode; RefreshModeOpts();
CloseModePopup();
end);
end;
AddModeOpt("Solid",   1);
AddModeOpt("Rainbow", 2);
AddModeOpt("Fading",  3);
ModeBox.MouseButton1Click:Connect(function()
if ModePopupOpen then CloseModePopup() else OpenModePopup() end;
end);

AnimLbl("Speed", 42);
local SpeedVal = Library.CreateInstance(Library,"TextLabel", {
Parent = AnimationsPanel; AnchorPoint = Vector2.new(1, 0);
Position = UDim2.new(1, 0, 0, 42); Size = UDim2.new(0, 40, 0, 12);
BackgroundTransparency = 1; Text = "50%"; TextColor3 = Color3.fromHex("8C8F99"); TextSize = 12;
TextXAlignment = Enum.TextXAlignment.Right;
}); FontIt(SpeedVal);
local SpTrack = Library.CreateInstance(Library,"TextButton", {
Parent = AnimationsPanel; Position = UDim2.new(0, 0, 0, 58);
Size = UDim2.new(1, 0, 0, 10); BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel = 0; AutoButtonColor = false; Text = "";
});
Library.CreateInstance(Library,"Frame", {
Parent = SpTrack; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
});
local SpInside = Library.CreateInstance(Library,"Frame", {
Parent = SpTrack:FindFirstChildOfClass("Frame"); Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0;
});
local SpFill = Library.CreateInstance(Library,"Frame", {
Parent = SpInside; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(0.5, -2, 1, -2); BackgroundColor3 = Library.Accent; BorderSizePixel = 0;
});
Library.RegisterAccent(Library,SpFill);
local SpDragging = false;
local SpVisualT = 0.5;
local SpTargetT = 0.5;
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if math.abs(SpTargetT - SpVisualT) < 0.001 then return end;
local Alpha = 1 - math.exp(-Dt * 14);
SpVisualT = SpVisualT + (SpTargetT - SpVisualT) * Alpha;
SpFill.Size = UDim2.new(SpVisualT, -2, 1, -2);
end);
local function SpUpdate(Px)
local Ax, Aw = SpInside.AbsolutePosition.X, SpInside.AbsoluteSize.X;
if Aw <= 0 then return end;
local T = math.clamp((Px - Ax) / Aw, 0, 1);
Speed = math.floor(T * 100 + 0.5);
SpTargetT = T;
SpeedVal.Text = Speed .. "%";
end;
Library.Connection(Library,SpTrack.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
SpDragging = true; SpUpdate(Input.Position.X);
end;
end);
Library.Connection(Library,SpTrack.InputEnded, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
SpDragging = false;
end;
end);
Library.Connection(Library,Services.UserInputService.InputChanged, function(Input)
if not SpDragging then return end;
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
SpUpdate(Input.Position.X);
end;
end);

local function RgbString(C)
return string.format("%d, %d, %d", math.round(C.R * 255), math.round(C.G * 255), math.round(C.B * 255));
end;

local function ApplyState()
local C = Color3.fromHSV(H, Sa, Va);
Color                              = C;
SwFill.BackgroundColor3            = C;
SwFill.BackgroundTransparency      = 1 - A;
AlphaArea.BackgroundColor3         = C;
SatValArea.BackgroundColor3        = Color3.fromHSV(H, 1, 1);
local SOff = (Sa < 1) and 0 or -3;
local VOff = ((1 - Va) < 1) and 0 or -3;
SatValMarker.Position = UDim2.new(Sa, SOff, 1 - Va, VOff);
local HOff = ((1 - H) < 1) and 0 or -2;
HueMarker.Position = UDim2.new(0, 0, 1 - H, HOff);
local AOff = ((1 - A) < 1) and 0 or -2;
AlphaMarker.Position = UDim2.new(0, 0, 1 - A, AOff);
if not RgbInput:IsFocused() then RgbInput.Text = RgbString(C) end;
if not HexInput:IsFocused() then HexInput.Text = C:ToHex() end;
Library.Flags[Flag] = C;
Callback(C, A);
end;
ApplyState();

local FadeColorA = Color3.fromRGB(255, 0, 0);
local FadeColorB = Color3.fromRGB(0, 0, 255);
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if Mode == "Rainbow" then
H = (H + Dt * (Speed / 100)) % 1;
ApplyState();
elseif Mode == "Fading" then
local T = (math.sin(tick() * (Speed / 25)) + 1) * 0.5;
local C = FadeColorA:Lerp(FadeColorB, T);
H, Sa, Va = Color3.toHSV(C);
ApplyState();
end;
end);

RgbInput.FocusLost:Connect(function()
local r, g, b = string.match(RgbInput.Text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)");
r, g, b = tonumber(r), tonumber(g), tonumber(b);
if r and g and b and r <= 255 and g <= 255 and b <= 255 then
H, Sa, Va = Color3.toHSV(Color3.fromRGB(r, g, b));
end;
ApplyState();
end);
HexInput.FocusLost:Connect(function()
local Text = string.gsub(HexInput.Text, "^#", "");
if #Text == 6 then
local ok, C = pcall(Color3.fromHex, Text);
if ok and C then H, Sa, Va = Color3.toHSV(C) end;
end;
ApplyState();
end);

local DraggingSat, DraggingHue, DraggingAlpha = false, false, false;
local Open = false;
local PickerIn  = TweenInfo.new(0.2,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local PickerOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
local SlideOff  = 10;
local function AnchorXY()
local AbsP = Swatch.AbsolutePosition;
return AbsP.X - PickerHolder.AbsoluteSize.X + Swatch.AbsoluteSize.X, AbsP.Y + Swatch.AbsoluteSize.Y + 65;
end;
local function SetVisible(B)
if B == Open then return end;
Open = B;
local X, Y = AnchorXY();
if Open then
PickerHolder.Visible           = true;
PickerHolder.Position          = UDim2.fromOffset(X, Y - SlideOff);
PickerHolder.GroupTransparency = 1;
PickerOuterStroke.Transparency = 1;
PickerInnerStroke.Transparency = 1;
Library.Tween(Library,PickerHolder, PickerIn, {
Position          = UDim2.fromOffset(X, Y);
GroupTransparency = 0;
}):Play();
Library.Tween(Library,PickerOuterStroke, PickerIn, { Transparency = 0 }):Play();
Library.Tween(Library,PickerInnerStroke, PickerIn, { Transparency = 0 }):Play();
else
Library.Tween(Library,PickerHolder, PickerOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
Library.Tween(Library,PickerOuterStroke, PickerOut, { Transparency = 1 }):Play();
Library.Tween(Library,PickerInnerStroke, PickerOut, { Transparency = 1 }):Play();
task.delay(PickerOut.Time, function()
if not Open then PickerHolder.Visible = false end;
end);
end;
end;

local function HookDown(Inst, Setter)
Library.Connection(Library,Inst.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Setter(true);
end;
end);
end;
Library.Connection(Library,Swatch.MouseButton1Click, function() SetVisible(not Open) end);
HookDown(SatLayer,  function(B) DraggingSat   = B end);
HookDown(ValLayer,  function(B) DraggingSat   = B end);
HookDown(HueArea,   function(B) DraggingHue   = B end);
HookDown(AlphaArea, function(B) DraggingAlpha = B end);

Library.Connection(Library,Services.UserInputService.InputEnded, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 then
DraggingSat = false; DraggingHue = false; DraggingAlpha = false;
end;
end);
Library.Connection(Library,Services.UserInputService.InputChanged, function(Input)
if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end;
if not (DraggingSat or DraggingHue or DraggingAlpha) then return end;
local M = Services.UserInputService:GetMouseLocation();
local Mx, My = M.X, M.Y - GuiInset;
if DraggingSat then
local Ap, Sz = SatValArea.AbsolutePosition, SatValArea.AbsoluteSize;
Sa = Sz.X > 0 and math.clamp((Mx - Ap.X) / Sz.X, 0, 1) or 0;
Va = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
elseif DraggingHue then
local Ap, Sz = HueArea.AbsolutePosition, HueArea.AbsoluteSize;
H = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
elseif DraggingAlpha then
local Ap, Sz = AlphaArea.AbsolutePosition, AlphaArea.AbsoluteSize;
A = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
end;
ApplyState();
end);
Library.Connection(Library,Services.UserInputService.InputBegan, function(Input)
if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
if not Open then return end;
local M = Services.UserInputService:GetMouseLocation();
local Mx, My = M.X, M.Y - GuiInset;
local function Inside(F)
local Ap, Sz = F.AbsolutePosition, F.AbsoluteSize;
return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
end;
if not Inside(PickerHolder) and not Inside(Swatch) then
SetVisible(false);
end;
end);

return self;
end;

if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Row.Visible = S end);
end;
return Obj;
end;

function SecRef:Slider(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Slider");
local Min      = tonumber(Opts.Min) or 0;
local Max      = tonumber(Opts.Max) or 100;
local Step     = tonumber(Opts.Step) or 1;
local Suffix   = tostring(Opts.Suffix or "");
local Decimals = tonumber(Opts.Decimals) or 0;
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
local Value    = math.clamp(tonumber(Opts.Default) or Min, Min, Max);
Library.Flags[Flag] = Value;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Slider_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 26);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, -40, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});

local ValLbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Value";
Parent                 = Container;
AnchorPoint            = Vector2.new(1, 0);
Position               = UDim2.new(1, 0, 0, 0);
Size                   = UDim2.new(0, 40, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
TextColor3             = Color3.fromHex("8C8F99");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Right;
TextYAlignment         = Enum.TextYAlignment.Center;
Text                   = "";
});
if ProggyCleanFont then
Lbl.FontFace    = ProggyCleanFont;
ValLbl.FontFace = ProggyCleanFont;
end;

local Track = Library.CreateInstance(Library,"TextButton", {
Name             = "Track";
Parent           = Container;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, 0);
Size             = UDim2.new(1, 0, 0, 10);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
local TrackGray = Library.CreateInstance(Library,"Frame", {
Parent           = Track;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local TrackInside = Library.CreateInstance(Library,"Frame", {
Parent           = TrackGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("131313");
BorderSizePixel  = 0;
});

local Fill = Library.CreateInstance(Library,"Frame", {
Name             = "Fill";
Parent           = TrackInside;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(0, 0, 1, -2);
BackgroundColor3 = Color3.fromHex("3972EC");
BorderSizePixel  = 0;
});
Library.RegisterAccent(Library,Fill);

local function FormatVal(V)
if Decimals > 0 then
return string.format("%." .. Decimals .. "f", V) .. Suffix;
end;
return tostring(math.round(V)) .. Suffix;
end;

local VisualT = (Value - Min) / (Max - Min);
local TargetT = VisualT;

local function Render()
TargetT = (Value - Min) / (Max - Min);
ValLbl.Text = FormatVal(Value);
end;
Render();
Fill.Size = UDim2.new(VisualT, -2, 1, -2);

Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if math.abs(TargetT - VisualT) < 0.001 then return end;
local Alpha = 1 - math.exp(-Dt * 14);
VisualT   = VisualT + (TargetT - VisualT) * Alpha;
Fill.Size = UDim2.new(VisualT, -2, 1, -2);
end);

local function SetVal(V, Fire)
V = math.clamp(math.floor((V - Min) / Step + 0.5) * Step + Min, Min, Max);
if V == Value then return end;
Value = V;
Library.Flags[Flag] = Value;
Render();
if Fire ~= false then Callback(Value) end;
end;

Track.InputBegan:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
local function UpdateFromInput(Px)
local AbsX, AbsW = TrackInside.AbsolutePosition.X, TrackInside.AbsoluteSize.X;
if AbsW <= 0 then return end;
local T = math.clamp((Px - AbsX) / AbsW, 0, 1);
SetVal(Min + T * (Max - Min));
end;
UpdateFromInput(Input.Position.X);
local Update;
Update = Services.UserInputService.InputChanged:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
UpdateFromInput(Input.Position.X);
end;
end);
Track.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Update:Disconnect();
end;
end);
end;
end);

if Opts.Tooltip then Library.Tooltip(Library,Container, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Container.Visible = S end);
end;

local Obj = { Container = Container, Track = Track, Fill = Fill };
function Obj:Get() return Value end;
function Obj:Set(V) SetVal(tonumber(V) or Value) end;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Slider", Obj = Obj };
end
return Obj;
end;

function SecRef:Button(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Button");
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;

local Row = Library.CreateInstance(Library,"Frame", {
Name                   = "ButtonRow_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 21);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = Row;
FillDirection = Enum.FillDirection.Horizontal;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 4);
});

local Buttons = {};
local function Resize()
local N = #Buttons;
if N == 0 then return end;
local Gap = 4 * (N - 1);
for _, B in Buttons do
B.Btn.Size = UDim2.new(1 / N, -(Gap / N), 1, 0);
end;
end;

local function MakeBtn(BtnName, BtnCB, Confirm)
local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Btn_" .. BtnName;
Parent                 = Row;
BackgroundColor3       = Color3.fromHex("000000");
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
LayoutOrder            = #Buttons + 1;
});
local BGray = Library.CreateInstance(Library,"Frame", {
Parent           = Btn;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BInside = Library.CreateInstance(Library,"Frame", {
Parent           = BGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});
local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = BInside;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = BtnName;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local ClickIn  = TweenInfo.new(0.1,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local ClickOut = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local function FlashBg()
Library.Tween(Library,BInside, ClickIn, { BackgroundColor3 = Color3.fromHex("DDDDDD") }):Play();
task.delay(ClickIn.Time, function()
Library.Tween(Library,BInside, ClickOut, { BackgroundColor3 = Color3.fromHex("FFFFFF") }):Play();
end);
end;
if Confirm then
local Confirming = false;
local Token      = 0;
Btn.MouseButton1Click:Connect(function()
if Confirming then
Confirming = false;
Token = Token + 1;
Lbl.Text = BtnName;
Library.Tween(Library,Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
FlashBg();
BtnCB();
else
Confirming = true;
Token = Token + 1;
local Mine = Token;
Lbl.Text = "Confirm?";
Library.Tween(Library,Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
task.delay(3, function()
if Token == Mine then
Confirming = false;
Lbl.Text = BtnName;
Library.Tween(Library,Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
end;
end);
end;
end);
else
Btn.MouseButton1Click:Connect(function()
FlashBg();
Library.Tween(Library,Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
task.delay(ClickIn.Time, function()
Library.Tween(Library,Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
end);
BtnCB();
end);
end;

local BRef = { Btn = Btn, Label = Lbl };
table.insert(Buttons, BRef);
Resize();
return BRef;
end;

MakeBtn(Name, Callback, Opts.Confirm);

if Opts.Tooltip then Library.Tooltip(Library,Row, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Row.Visible = S end);
end;

local Obj = { Container = Row };
function Obj:Button(MoreOpts)
MoreOpts = typeof(MoreOpts) == "table" and MoreOpts or {};
local N = tostring(MoreOpts.Name or MoreOpts.Title or MoreOpts.Text or "Button");
local CB = typeof(MoreOpts.Callback) == "function" and MoreOpts.Callback or function() end;
MakeBtn(N, CB, MoreOpts.Confirm);
return self;
end;
return Obj;
end;

function SecRef:Row(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Height = tonumber(Opts.Height) or 21;

local Row = Library.CreateInstance(Library,"Frame", {
Name                   = "Row";
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, Height);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = Row;
FillDirection = Enum.FillDirection.Horizontal;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 4);
});

local Elements = {};
local Weights = {};

local function Resize()
local TotalWeight = 0;
for _, W in ipairs(Weights) do
TotalWeight = TotalWeight + W;
end
if TotalWeight == 0 then return end;

local Gap = 4 * (#Elements - 1);
for i, Element in ipairs(Elements) do
local Weight = Weights[i] or 1;
Element.Size = UDim2.new(Weight / TotalWeight, -(Gap * Weight / TotalWeight), 1, 0);
end;
end;

local Obj = { Container = Row };

function Obj:Slider(SliderOpts)
SliderOpts = typeof(SliderOpts) == "table" and SliderOpts or {};
local Name     = tostring(SliderOpts.Name or SliderOpts.Title or SliderOpts.Text or "Slider");
local Min      = tonumber(SliderOpts.Min) or 0;
local Max      = tonumber(SliderOpts.Max) or 100;
local Step     = tonumber(SliderOpts.Step) or 1;
local Suffix   = tostring(SliderOpts.Suffix or "");
local Decimals = tonumber(SliderOpts.Decimals) or 0;
local Callback = typeof(SliderOpts.Callback) == "function" and SliderOpts.Callback or function() end;
local Flag     = tostring(SliderOpts.Flag or SliderOpts.Pointer or ("_" .. Name));
local Value    = math.clamp(tonumber(SliderOpts.Default) or Min, Min, Max);
local Weight   = tonumber(SliderOpts.Weight) or 1;

Library.Flags[Flag] = Value;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Slider", Obj = nil };
end

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Slider_" .. Name;
Parent                 = Row;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
LayoutOrder            = #Elements + 1;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Track = Library.CreateInstance(Library,"Frame", {
Name             = "Track";
Parent           = Container;
Position         = UDim2.new(0, 0, 0, 16);
Size             = UDim2.new(1, 0, 0, 6);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local TrackGray = Library.CreateInstance(Library,"Frame", {
Name             = "Gray";
Parent           = Track;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local Fill = Library.CreateInstance(Library,"Frame", {
Name             = "Fill";
Parent           = TrackGray;
Size             = UDim2.new(0, 0, 1, 0);
BackgroundColor3 = Library.Accent;
BorderSizePixel  = 0;
});
Library.RegisterAccent(Library,Fill);

local ValLbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "ValueLabel";
Parent                 = Container;
Position               = UDim2.new(1, 0, 0, 0);
AnchorPoint            = Vector2.new(1, 0);
Size                   = UDim2.new(0, 40, 0, 12);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = tostring(Value);
TextColor3             = Color3.fromHex("A0A0A0");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Right;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then ValLbl.FontFace = ProggyCleanFont end;

local function DisplayText()
return tostring(Decimals > 0 and string.format("%." .. Decimals .. "f", Value) or math.floor(Value)) .. Suffix;
end;

local function Render()
local Progress = (Value - Min) / (Max - Min);
Fill.Size = UDim2.new(Progress, 0, 1, 0);
ValLbl.Text = DisplayText();
end;

local function SetVal(V)
if V == Value then return end;
Value = math.clamp(tonumber(V) or Value, Min, Max);
Library.Flags[Flag] = Value;
Render();
if Callback(Value) ~= false then end;
end;

Track.InputBegan:Connect(function(Input)
if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
return;
end;
local Update;
Update = Library.Connection(Library,Services.UserInputService.InputChanged, function(Input)
if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then
return;
end;
local RelX = (Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X;
SetVal(Min + RelX * (Max - Min));
end);
local RelX = (Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X;
SetVal(Min + RelX * (Max - Min));
Track.InputEnded:Connect(function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Update:Disconnect();
end;
end);
end);

if SliderOpts.Tooltip then Library.Tooltip(Library,Container, SliderOpts.Tooltip) end;
if SliderOpts.Dependency and typeof(SliderOpts.Dependency.OnChange) == "function" then
SliderOpts.Dependency:OnChange(function(S) Container.Visible = S end);
end;

local SliderObj = { Container = Container, Track = Track, Fill = Fill };
function SliderObj:Get() return Value end;
function SliderObj:Set(V) SetVal(tonumber(V) or Value) end;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Slider", Obj = SliderObj };
end

table.insert(Elements, Container);
table.insert(Weights, Weight);
Resize();
Render();

return self, SliderObj;
end;

function Obj:Button(ButtonOpts)
ButtonOpts = typeof(ButtonOpts) == "table" and ButtonOpts or {};
local Name     = tostring(ButtonOpts.Name or ButtonOpts.Title or ButtonOpts.Text or "Button");
local Callback = typeof(ButtonOpts.Callback) == "function" and ButtonOpts.Callback or function() end;
local Weight   = tonumber(ButtonOpts.Weight) or 1;

local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Btn_" .. Name;
Parent                 = Row;
BackgroundColor3       = Color3.fromHex("000000");
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
LayoutOrder            = #Elements + 1;
});
local BGray = Library.CreateInstance(Library,"Frame", {
Parent           = Btn;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BInside = Library.CreateInstance(Library,"Frame", {
Parent           = BGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("191919"));
NewColorSequenceKeypoint(1, Color3.fromHex("262626"));
});
});
local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name             = "Label";
Parent           = BInside;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel  = 0;
Text             = Name;
TextColor3       = Color3.fromHex("FFFFFF");
TextSize         = 12;
TextXAlignment   = Enum.TextXAlignment.Center;
TextYAlignment   = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local ClickIn = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local ClickOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

local function FlashBg()
local OriginalColor = BInside.BackgroundColor3;
BInside.BackgroundColor3 = Library.Accent;
task.delay(0.1, function()
BInside.BackgroundColor3 = OriginalColor;
end);
end;

if ButtonOpts.Confirm then
local Confirming = false;
local Token = 0;
Btn.MouseButton1Click:Connect(function()
if Confirming then
Confirming = false;
Token = Token + 1;
Lbl.Text = Name;
Library.Tween(Library,Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
FlashBg();
Callback();
else
Confirming = true;
Token = Token + 1;
local Mine = Token;
Lbl.Text = "Confirm?";
Library.Tween(Library,Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
task.delay(3, function()
if Token == Mine then
Confirming = false;
Lbl.Text = Name;
Library.Tween(Library,Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
end;
end);
end;
end);
else
Btn.MouseButton1Click:Connect(function()
FlashBg();
Library.Tween(Library,Lbl, ClickIn, { TextColor3 = Library.Accent }):Play();
task.delay(ClickIn.Time, function()
Library.Tween(Library,Lbl, ClickOut, { TextColor3 = Color3.fromHex("FFFFFF") }):Play();
end);
Callback();
end);
end;

if ButtonOpts.Tooltip then Library.Tooltip(Library,Btn, ButtonOpts.Tooltip) end;
if ButtonOpts.Dependency and typeof(ButtonOpts.Dependency.OnChange) == "function" then
ButtonOpts.Dependency:OnChange(function(S) Btn.Visible = S end);
end;

table.insert(Elements, Btn);
table.insert(Weights, Weight);
Resize();

return self;
end;

function Obj:Dropdown(DropdownOpts)
DropdownOpts = typeof(DropdownOpts) == "table" and DropdownOpts or {};
local Name     = tostring(DropdownOpts.Name or DropdownOpts.Title or DropdownOpts.Text or "Dropdown");
local Options  = typeof(DropdownOpts.Options) == "table" and DropdownOpts.Options or {};
local Callback = typeof(DropdownOpts.Callback) == "function" and DropdownOpts.Callback or function() end;
local Flag     = tostring(DropdownOpts.Flag or DropdownOpts.Pointer or ("_" .. Name));
local Multi    = DropdownOpts.Multi == true;
local Weight   = tonumber(DropdownOpts.Weight) or 1;

local Value;
if Multi then
Value = {};
if typeof(DropdownOpts.Default) == "table" then
for _, V in DropdownOpts.Default do Value[tostring(V)] = true end;
elseif DropdownOpts.Default ~= nil then
Value[tostring(DropdownOpts.Default)] = true;
end;
else
Value = DropdownOpts.Default ~= nil and tostring(DropdownOpts.Default) or Options[1];
end;
Library.Flags[Flag] = Value;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Dropdown", Obj = nil };
end;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Dropdown_" .. Name;
Parent                 = Row;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
LayoutOrder            = #Elements + 1;
});

local Box = Library.CreateInstance(Library,"TextButton", {
Name             = "Box";
Parent           = Container;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Parent           = BoxGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BoxInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});

local ValLbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Value";
Parent                 = BoxInside;
Position               = UDim2.new(0, 4, 0, 0);
Size                   = UDim2.new(1, -14, 1, 0);
BackgroundTransparency = 1;
Text                   = "";
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
TextTruncate           = Enum.TextTruncate.AtEnd;
ClipsDescendants       = true;
});
local Arrow = Library.CreateInstance(Library,"Frame", {
Name                   = "Arrow";
Parent                 = BoxInside;
AnchorPoint            = Vector2.new(1, 0.5);
Position               = UDim2.new(1, -4, 0.5, 0);
Size                   = UDim2.fromOffset(7, 7);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.CreateInstance(Library,"Frame", {
Name             = "Horiz";
Parent           = Arrow;
AnchorPoint      = Vector2.new(0.5, 0.5);
Position         = UDim2.new(0.5, 0, 0.5, 0);
Size             = UDim2.fromOffset(7, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local ArrowV = Library.CreateInstance(Library,"Frame", {
Name             = "Vert";
Parent           = Arrow;
AnchorPoint      = Vector2.new(0.5, 0.5);
Position         = UDim2.new(0.5, 0, 0.5, 0);
Size             = UDim2.fromOffset(1, 7);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local function SetArrow(Plus) ArrowV.Visible = Plus end;
if ProggyCleanFont then
ValLbl.FontFace = ProggyCleanFont;
end;

local Popup = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "DropdownPopup";
Parent            = Gui;
Size              = UDim2.new(0, 100, 0, 142);
BackgroundColor3  = Color3.fromHex("000000");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 50;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = Popup;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});
local PopupGray = Library.CreateInstance(Library,"Frame", {
Parent           = Popup;
Position         = UDim2.new(0, 0, 0, 0);
Size             = UDim2.new(1, 0, 0, 142);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
ZIndex           = 50;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = PopupGray;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});
local PopupInside = Library.CreateInstance(Library,"Frame", {
Parent                 = PopupGray;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 140);
BackgroundColor3       = Color3.fromHex("131313");
BorderSizePixel        = 0;
ZIndex                 = 50;
});
Library.CreateInstance(Library,"ScrollingFrame", {
Parent        = PopupInside;
Size          = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel  = 0;
ScrollBarThickness = 4;
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
});
local ScrollContent = PopupInside:FindFirstChildOfClass("ScrollingFrame")
Library.CreateInstance(Library,"UIListLayout", {
Parent        = ScrollContent;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 0);
});

local Open = false;
local OptionButtons = {};
local ClosePopup;

local function IsSelected(Opt)
Opt = tostring(Opt);
if Multi then return Value[Opt] == true end;
return Opt == Value;
end;

local function DisplayText()
if not Multi then return tostring(Value) end;
local Sel = {};
for _, Opt in Options do
if Value[tostring(Opt)] then table.insert(Sel, tostring(Opt)) end;
end;
return (#Sel > 0) and table.concat(Sel, ", ") or "None";
end;

local OptColorInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local function RefreshColors()
for _, B in OptionButtons do
local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
Library.Tween(Library,B, OptColorInfo, { TextColor3 = Target }):Play();
end;
end;

local DropdownObj = { Container = Container, Box = Box };
function DropdownObj:Get() return Value end;
function DropdownObj:Set(NewValue)
if Multi then
if typeof(NewValue) == "table" then
Value = {};
for _, V in NewValue do Value[tostring(V)] = true end;
else
Value[tostring(NewValue)] = not Value[tostring(NewValue)];
end;
else
Value = tostring(NewValue);
end;
Library.Flags[Flag] = Value;
ValLbl.Text = DisplayText();
RefreshColors();
Callback(Value);
end;
if Flag ~= "" then
Library.UIElements[Flag].Obj = DropdownObj;
end;

ValLbl.Text = DisplayText();

local function BuildOptions()
for _, C in ScrollContent:GetChildren() do
if C:IsA("TextButton") then C:Destroy() end;
end;
table.clear(OptionButtons);
for I, Opt in Options do
local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Option_" .. tostring(Opt);
Parent                 = ScrollContent;
Size                   = UDim2.new(1, 0, 0, 14);
BackgroundColor3       = Color3.fromHex("131313");
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = tostring(Opt);
TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
LayoutOrder            = I;
ZIndex                 = 51;
});
Library.CreateInstance(Library,"UIPadding", {
Parent      = Btn;
PaddingLeft = UDim.new(0, 5);
});
if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
Btn.MouseButton1Click:Connect(function()
DropdownObj:Set(Btn.Text);
if not Multi and ClosePopup then ClosePopup() end;
end);
table.insert(OptionButtons, Btn);
end;
if ScrollContent then
ScrollContent.CanvasSize = UDim2.new(0, 0, 0, #Options * 14)
end
end;
BuildOptions();
Library.OnAccent(Library,RefreshColors);

local PopupIn  = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local PopupOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
local SlideOff = 10;
local PopupGap = 60;

local function AnchorXY()
local AbsPos  = Box.AbsolutePosition;
local AbsSize = Box.AbsoluteSize;
Popup.Size = UDim2.new(0, AbsSize.X, 0, 142);
return AbsPos.X, AbsPos.Y + AbsSize.Y + PopupGap;
end;

ClosePopup = function()
if not Open then return end;
Open = false;
local X, Y = AnchorXY();
Library.Tween(Library,Popup, PopupOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
task.delay(PopupOut.Time, function()
if not Open then Popup.Visible = false end;
end);
SetArrow(true);
end;

Box.MouseButton1Click:Connect(function()
Open = not Open;
local X, Y = AnchorXY();
if Open then
if Library.ActiveDropdownList then
local Existing = Library.ActiveDropdownList;
Library.ActiveDropdownList = nil;
Existing.Visible = false;
end;
Popup.Visible           = true;
Popup.Position          = UDim2.fromOffset(X, Y - SlideOff);
Popup.GroupTransparency = 1;
Library.Tween(Library,Popup, PopupIn, {
Position          = UDim2.fromOffset(X, Y);
GroupTransparency = 0;
}):Play();
SetArrow(false);
Library.ActiveDropdownList = Popup;
else
Library.Tween(Library,Popup, PopupOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
task.delay(PopupOut.Time, function()
if not Open then Popup.Visible = false end;
end);
SetArrow(true);
end;
end);

Library.Connection(Library,Services.UserInputService.InputBegan, function(Input)
if not Open then return end;
if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
local Mx, My = Input.Position.X, Input.Position.Y;
local function InAbs(Inst)
local P, S = Inst.AbsolutePosition, Inst.AbsoluteSize;
return Mx >= P.X and Mx <= P.X + S.X and My >= P.Y and My <= P.Y + S.Y;
end;
if InAbs(Box) or InAbs(Popup) then return end;
Open = false;
local X, Y = AnchorXY();
Library.Tween(Library,Popup, PopupOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
task.delay(PopupOut.Time, function()
if not Open then Popup.Visible = false end;
end);
SetArrow(true);
end);

table.insert(Elements, Container);
table.insert(Weights, Weight);
Resize();

return self, DropdownObj;
end;

function Obj:Textbox(TextboxOpts)
TextboxOpts = typeof(TextboxOpts) == "table" and TextboxOpts or {};
local Name        = tostring(TextboxOpts.Name or TextboxOpts.Title or TextboxOpts.Text or "Textbox");
local Default     = tostring(TextboxOpts.Default or "");
local Placeholder = tostring(TextboxOpts.Placeholder or "...");
local Numeric     = TextboxOpts.Numeric == true;
local Callback    = typeof(TextboxOpts.Callback) == "function" and TextboxOpts.Callback or function() end;
local Flag        = tostring(TextboxOpts.Flag or TextboxOpts.Pointer or ("_" .. Name));
local Weight      = tonumber(TextboxOpts.Weight) or 1;

Library.Flags[Flag] = Default;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Textbox", Obj = nil };
end;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Textbox_" .. Name;
Parent                 = Row;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
LayoutOrder            = #Elements + 1;
});

local Box = Library.CreateInstance(Library,"Frame", {
Name             = "Box";
Parent           = Container;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Parent           = BoxGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BoxInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B")),
NewColorSequenceKeypoint(1, Color3.fromHex("121212")),
});
});

local Input = Library.CreateInstance(Library,"TextBox", {
Name                   = "Input";
Parent                 = BoxInside;
Position               = UDim2.new(0, 4, 0, 0);
Size                   = UDim2.new(1, -8, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ClearTextOnFocus       = false;
Text                   = Default;
PlaceholderText        = Placeholder;
PlaceholderColor3      = Color3.fromHex("5E626B");
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
ClipsDescendants       = true;
});
if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;

local TextboxObj = { Container = Container, Input = Input };
function TextboxObj:Get() return Input.Text end;
function TextboxObj:Set(NewValue)
Input.Text = tostring(NewValue or "");
Library.Flags[Flag] = Input.Text;
Callback(Input.Text);
end;
if Flag ~= "" then
Library.UIElements[Flag].Obj = TextboxObj;
end;

local function Commit(V, Fire)
V = tostring(V);
if Numeric then
local Num = tonumber(V);
V = Num and tostring(Num) or "";
end;
Input.Text = V;
Library.Flags[Flag] = V;
if Fire ~= false then Callback(V) end;
end;

Input.FocusLost:Connect(function()
Commit(Input.Text);
end);

if Numeric then
Input:GetPropertyChangedSignal("Text"):Connect(function()
local NewText = Input.Text:gsub("[^0-9.-]", "");
if Input.Text ~= NewText then
Input.Text = NewText;
end;
end);
end;

table.insert(Elements, Container);
table.insert(Weights, Weight);
Resize();

return self, TextboxObj;
end;

function Obj:Keybind(KeybindOpts)
KeybindOpts = typeof(KeybindOpts) == "table" and KeybindOpts or {};
local Name     = tostring(KeybindOpts.Name or KeybindOpts.Title or KeybindOpts.Text or "Keybind");
local Default  = KeybindOpts.Default;
local Mode     = tostring(KeybindOpts.Mode or "Toggle");
local Callback = typeof(KeybindOpts.Callback) == "function" and KeybindOpts.Callback or function() end;
local Flag     = tostring(KeybindOpts.Flag or KeybindOpts.Pointer or ("_" .. Name));
local Weight   = tonumber(KeybindOpts.Weight) or 1;

local Key = Default;
Library.Flags[Flag] = Key;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Keybind", Obj = nil };
end;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Keybind_" .. Name;
Parent                 = Row;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
LayoutOrder            = #Elements + 1;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Btn";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 12);
Size                   = UDim2.new(1, 0, 1, -12);
BackgroundColor3       = Color3.fromHex("000000");
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
ZIndex                 = 2;
});
local BGray = Library.CreateInstance(Library,"Frame", {
Parent           = Btn;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BInside = Library.CreateInstance(Library,"Frame", {
Parent           = BGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("191919")),
NewColorSequenceKeypoint(1, Color3.fromHex("262626")),
});
});
local Val = Library.CreateInstance(Library,"TextLabel", {
Name             = "Value";
Parent           = BInside;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel  = 0;
Text             = Library.KeyNames[Key] or tostring(Key);
TextColor3       = Color3.fromHex("A0A0A0");
TextSize         = 12;
TextXAlignment   = Enum.TextXAlignment.Right;
TextYAlignment   = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Val.FontFace = ProggyCleanFont end;

local KeybindObj = { Container = Container, Btn = Btn };
function KeybindObj:Get() return Key end;
function KeybindObj:Set(NewKey)
Key = NewKey;
Library.Flags[Flag] = Key;
Val.Text = Library.KeyNames[Key] or tostring(Key);
Callback(Key);
end;
if Flag ~= "" then
Library.UIElements[Flag].Obj = KeybindObj;
end;

local Listening = false;
local ListenConn;
local function CancelListen()
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Val.Text = Library.KeyNames[Key] or tostring(Key);
end;

local function StartListen()
Listening = true;
Val.Text = "...";
ListenConn = Services.UserInputService.InputBegan:Connect(function(Input)
local T = Input.UserInputType;
if T == Enum.UserInputType.Keyboard then
local K = Input.KeyCode;
if K == Enum.KeyCode.Escape then
CancelListen();
else
Key = K;
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
KeybindObj:Set(Key);
Library.NotifyKeybind(Library);
end;
elseif T == Enum.UserInputType.MouseButton1
or T == Enum.UserInputType.MouseButton2
or T == Enum.UserInputType.MouseButton3 then
Key = T;
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
KeybindObj:Set(Key);
Library.NotifyKeybind(Library);
end;
end);
end;

Btn.MouseButton1Click:Connect(StartListen);
Btn.MouseButton2Click:Connect(function()
if Listening then CancelListen() end;
Key = nil;
KeybindObj:Set(nil);
end);

table.insert(Elements, Container);
table.insert(Weights, Weight);
Resize();

return self, KeybindObj;
end;



if Opts.Tooltip then Library.Tooltip(Library,Row, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Row.Visible = S end);
end;

return Obj;
end;

function SecRef:Colorpicker(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Color");
local Color    = typeof(Opts.Default) == "Color3" and Opts.Default or Color3.fromRGB(255, 255, 255);
local Alpha    = tonumber(Opts.Alpha) or 1;
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
local H, S, V  = Color3.toHSV(Color);
local A        = math.clamp(Alpha, 0, 1);

local Row = Library.CreateInstance(Library,"Frame", {
Name                   = "Colorpicker_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 18);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Row;
AnchorPoint            = Vector2.new(0, 0.5);
Position               = UDim2.new(0, 0, 0.5, 0);
Size                   = UDim2.new(1, -32, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Swatch = Library.CreateInstance(Library,"TextButton", {
Name             = "Swatch";
Parent           = Row;
AnchorPoint      = Vector2.new(1, 0.5);
Position         = UDim2.new(1, 0, 0.5, 0);
Size             = UDim2.new(0, 27, 0, 15);
AutoButtonColor  = false;
Text             = "";
BackgroundColor3 = Color3.fromHex("000105");
BorderSizePixel  = 0;
});
local SwatchInline = Library.CreateInstance(Library,"Frame", {
Name             = "Inline";
Parent           = Swatch;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("252527");
BorderSizePixel  = 0;
});
local SwatchHandle = Library.CreateInstance(Library,"Frame", {
Name             = "Handle";
Parent           = SwatchInline;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"ImageLabel", {
Name             = "Checkers";
Parent           = SwatchHandle;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel  = 0;
Image            = "rbxassetid://18274452449";
ScaleType        = Enum.ScaleType.Tile;
TileSize         = UDim2.new(0, 6, 0, 6);
ZIndex           = 2;
});
local SwatchFill = Library.CreateInstance(Library,"Frame", {
Name                   = "Fill";
Parent                 = SwatchHandle;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundColor3       = Color;
BackgroundTransparency = 1 - Alpha;
BorderSizePixel        = 0;
ZIndex                 = 3;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = SwatchFill;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromRGB(255, 255, 255));
NewColorSequenceKeypoint(1, Color3.fromRGB(167, 167, 167));
});
});

local PickerHolder = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "Picker_" .. Name;
Parent            = Gui;
Size              = UDim2.new(0, 218, 0, 248);
BackgroundColor3  = Color3.fromHex("131313");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 50;
});
local PickerOuterStroke = Library.CreateInstance(Library,"UIStroke", {
Parent          = PickerHolder;
Color           = Color3.fromHex("000000");
Thickness       = 1;
Transparency    = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local PickerInner = Library.CreateInstance(Library,"Frame", {
Name                   = "InnerOutline";
Parent                 = PickerHolder;
Position               = UDim2.new(0, 1, 0, 1);
Size                   = UDim2.new(1, -2, 1, -2);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ZIndex                 = 51;
});
local PickerInnerStroke = Library.CreateInstance(Library,"UIStroke", {
Parent          = PickerInner;
Color           = Color3.fromHex("393939");
Thickness       = 1;
Transparency    = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local PickerBody = Library.CreateInstance(Library,"Frame", {
Name                   = "Body";
Parent                 = PickerHolder;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ZIndex                 = 52;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = PickerBody;
PaddingTop    = UDim.new(0, 8);
PaddingBottom = UDim.new(0, 8);
PaddingLeft   = UDim.new(0, 8);
PaddingRight  = UDim.new(0, 8);
});

local MainBg = Library.CreateInstance(Library,"Frame", {
Name                   = "Main";
Parent                 = PickerBody;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ZIndex                 = 53;
});

local TabBar = Library.CreateInstance(Library,"Frame", {
Name                   = "TabBar";
Parent                 = MainBg;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 20);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ZIndex                 = 54;
});

local CpInactiveSeq = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
});
local CpActiveSeq = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("161616"));
NewColorSequenceKeypoint(1, Color3.fromHex("151515"));
});

local CpAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
local CpInactiveA, CpInactiveB = Color3.fromHex("1F1F1F"), Color3.fromHex("181818");
local CpActiveA,   CpActiveB   = Color3.fromHex("161616"), Color3.fromHex("151515");
local CpOutlineNames = { "TopBlack", "TopGray", "BottomBlack", "BottomGray", "LeftBlack", "LeftGray", "RightBlack", "RightGray" };
local ColorPage, AnimationsPanel;
local CpTabToken = 0;

local TabButtons = {};
local function MakeCpTab(Name, Idx, Total)
local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Tab_" .. Name;
Parent                 = TabBar;
Size                   = UDim2.new(1 / Total, 0, 1, 0);
Position               = UDim2.new((Idx - 1) / Total, 0, 0, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
});
local Bg = Library.CreateInstance(Library,"Frame", {
Name             = "Bg";
Parent           = Btn;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local BgGrad = Library.CreateInstance(Library,"UIGradient", {
Parent   = Bg;
Rotation = 90;
Color    = CpInactiveSeq;
});
local function MakePiece(Anchor, Pos, Sz, Color, ZIdx)
return Library.CreateInstance(Library,"Frame", {
Parent                 = Bg;
AnchorPoint            = Anchor;
Position               = Pos;
Size                   = Sz;
BackgroundColor3       = Color3.fromHex(Color);
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = ZIdx;
});
end;
local TopBlack    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
local TopGray     = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(1, -2, 0, 1), "393939", 4);
local BottomBlack = MakePiece(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000", 4);
local BottomGray  = MakePiece(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939", 4);
local LeftBlack   = MakePiece(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
local LeftGray    = MakePiece(Vector2.new(0, 0), UDim2.new(0, 1, 0, 1),  UDim2.new(0, 1, 1, -2), "393939", 3);
local RightBlack  = MakePiece(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000", 3);
local RightGray   = MakePiece(Vector2.new(1, 0), UDim2.new(1, -1, 0, 1), UDim2.new(0, 1, 1, -2), "393939", 3);
local TopGradient = Library.CreateInstance(Library,"Frame", {
Parent                 = Bg;
AnchorPoint            = Vector2.new(0, 0);
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 1);
BackgroundColor3       = Color3.fromHex("FFFFFF");
BorderSizePixel        = 0;
BackgroundTransparency = 1;
ZIndex                 = 5;
});
local Grad = Library.CreateInstance(Library,"UIGradient", { Parent = TopGradient; Rotation = 0 });
Library.RegisterAccentGradient(Library,Grad);
local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Bg;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Name;
TextSize               = 12;
TextColor3             = Color3.fromHex("FFFFFF");
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
ZIndex                 = 6;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Entry = {
Btn = Btn, Bg = Bg, Lbl = Lbl, BgGrad = BgGrad, TopGradient = TopGradient;
TopBlack = TopBlack, TopGray = TopGray;
BottomBlack = BottomBlack, BottomGray = BottomGray;
LeftBlack = LeftBlack, LeftGray = LeftGray;
RightBlack = RightBlack, RightGray = RightGray;
GradT = 0; GradTarget = 0;
};
local function ApplyGrad()
BgGrad.Color = NewColorSequence({
NewColorSequenceKeypoint(0, CpInactiveA:Lerp(CpActiveA, Entry.GradT));
NewColorSequenceKeypoint(1, CpInactiveB:Lerp(CpActiveB, Entry.GradT));
});
end;
ApplyGrad();
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if math.abs(Entry.GradTarget - Entry.GradT) < 0.001 then
if Entry.GradT ~= Entry.GradTarget then
Entry.GradT = Entry.GradTarget;
ApplyGrad();
end;
return;
end;
Entry.GradT = Entry.GradT + (Entry.GradTarget - Entry.GradT) * (1 - math.exp(-Dt * 16));
ApplyGrad();
end);
table.insert(TabButtons, Entry);
return Btn;
end;
local ColorTabBtn = MakeCpTab("Color", 1, 2);
local AnimationsTabBtn = MakeCpTab("Animations", 2, 2);

local function SetCpTab(I)
for i, T in TabButtons do
if i == I then
T.GradTarget = 1;
Library.Tween(Library,T.TopGradient, CpAnimInfo, { BackgroundTransparency = 0 }):Play();
for _, N in CpOutlineNames do
Library.Tween(Library,T[N], CpAnimInfo, { BackgroundTransparency = 1 }):Play();
end;
else
T.GradTarget = 0;
Library.Tween(Library,T.TopGradient, CpAnimInfo, { BackgroundTransparency = 1 }):Play();
for _, N in CpOutlineNames do
Library.Tween(Library,T[N], CpAnimInfo, { BackgroundTransparency = 0 }):Play();
end;
end;
end;
if ColorPage and AnimationsPanel then
CpTabToken = CpTabToken + 1;
local Mine = CpTabToken;
ColorPage.Visible       = true;
AnimationsPanel.Visible = true;
if I == 1 then
Library.Tween(Library,ColorPage,       CpAnimInfo, { GroupTransparency = 0 }):Play();
Library.Tween(Library,AnimationsPanel, CpAnimInfo, { GroupTransparency = 1 }):Play();
else
Library.Tween(Library,ColorPage,       CpAnimInfo, { GroupTransparency = 1 }):Play();
Library.Tween(Library,AnimationsPanel, CpAnimInfo, { GroupTransparency = 0 }):Play();
end;
task.delay(CpAnimInfo.Time, function()
if CpTabToken ~= Mine then return end;
if I == 1 then AnimationsPanel.Visible = false end;
if I == 2 then ColorPage.Visible = false end;
end);
end;
end;
SetCpTab(1);
ColorTabBtn.MouseButton1Click:Connect(function() SetCpTab(1) end);
AnimationsTabBtn.MouseButton1Click:Connect(function() SetCpTab(2) end);

ColorPage = Library.CreateInstance(Library,"CanvasGroup", {
Name                   = "ColorPage";
Parent                 = MainBg;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
GroupTransparency      = 0;
ZIndex                 = 54;
});

AnimationsPanel = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "AnimationsPanel";
Parent            = MainBg;
Position          = UDim2.new(0, 0, 0, 28);
Size              = UDim2.new(1, 0, 1, -28);
BackgroundColor3  = Color3.fromHex("131313");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 55;
});
local Mode  = "Solid";
local Speed = 50;

local function FontIt(L) if ProggyCleanFont then L.FontFace = ProggyCleanFont end end;
local function AnimLbl(Text, Y)
local L = Library.CreateInstance(Library,"TextLabel", {
Parent                 = AnimationsPanel;
Position               = UDim2.new(0, 0, 0, Y);
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
Text                   = Text;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
});
FontIt(L);
return L;
end;

AnimLbl("Mode", 0);
local ModeBox = Library.CreateInstance(Library,"TextButton", {
Parent           = AnimationsPanel;
Position         = UDim2.new(0, 0, 0, 14);
Size             = UDim2.new(1, 0, 0, 21);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
Library.CreateInstance(Library,"Frame", {
Parent           = ModeBox;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local ModeInside = Library.CreateInstance(Library,"Frame", {
Parent           = ModeBox:FindFirstChildOfClass("Frame");
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = ModeInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});
local ModeVal = Library.CreateInstance(Library,"TextLabel", {
Parent                 = ModeInside;
Position               = UDim2.new(0, 4, 0, 0);
Size                   = UDim2.new(1, -14, 1, 0);
BackgroundTransparency = 1;
Text                   = Mode;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
}); FontIt(ModeVal);
local ModeArrow = Library.CreateInstance(Library,"Frame", {
Parent                 = ModeInside;
AnchorPoint            = Vector2.new(1, 0.5);
Position               = UDim2.new(1, -4, 0.5, 0);
Size                   = UDim2.fromOffset(7, 7);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.CreateInstance(Library,"Frame", {
Parent           = ModeArrow;
AnchorPoint      = Vector2.new(0.5, 0.5);
Position         = UDim2.new(0.5, 0, 0.5, 0);
Size             = UDim2.fromOffset(7, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local ModeArrowV = Library.CreateInstance(Library,"Frame", {
Parent           = ModeArrow;
AnchorPoint      = Vector2.new(0.5, 0.5);
Position         = UDim2.new(0.5, 0, 0.5, 0);
Size             = UDim2.fromOffset(1, 7);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local function SetModeArrow(Plus) ModeArrowV.Visible = Plus end;

local ModePopup = Library.CreateInstance(Library,"CanvasGroup", {
Parent            = AnimationsPanel;
Position          = UDim2.new(0, 0, 0, 36);
Size              = UDim2.new(1, 0, 0, 44);
BackgroundColor3  = Color3.fromHex("000000");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 60;
});
local ModePopupGray = Library.CreateInstance(Library,"Frame", {
Parent           = ModePopup;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
ZIndex           = 60;
});
local ModePopupInside = Library.CreateInstance(Library,"Frame", {
Parent           = ModePopupGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("131313");
BorderSizePixel  = 0;
ZIndex           = 61;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = ModePopupInside;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 0);
});
local ModeOptionBtns = {};
local function RefreshModeOpts()
for N, B in ModeOptionBtns do
B.TextColor3 = (N == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
end;
end;
Library.OnAccent(Library,function() RefreshModeOpts() end);
local ModePopupOpen = false;
local ModePopupToken = 0;
local ModePopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
local ModePopupBaseY = 36;
local ModePopupSlide = 6;
local function CloseModePopup()
if not ModePopupOpen then return end;
ModePopupOpen = false;
ModePopupToken = ModePopupToken + 1;
local Mine = ModePopupToken;
SetModeArrow(true);
Library.Tween(Library,ModePopup, ModePopupInfo, {
GroupTransparency = 1;
Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
}):Play();
task.delay(ModePopupInfo.Time, function()
if ModePopupToken == Mine then ModePopup.Visible = false end;
end);
end;
local function OpenModePopup()
if ModePopupOpen then return end;
ModePopupOpen = true;
ModePopupToken = ModePopupToken + 1;
SetModeArrow(false);
ModePopup.GroupTransparency = 1;
ModePopup.Position          = UDim2.new(0, 0, 0, ModePopupBaseY - ModePopupSlide);
ModePopup.Visible           = true;
Library.Tween(Library,ModePopup, ModePopupInfo, {
GroupTransparency = 0;
Position          = UDim2.new(0, 0, 0, ModePopupBaseY);
}):Play();
end;
local function AddModeOpt(Name, Idx)
local Btn = Library.CreateInstance(Library,"TextButton", {
Parent                 = ModePopupInside;
Size                   = UDim2.new(1, 0, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = Name;
TextColor3             = (Name == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
LayoutOrder            = Idx;
ZIndex                 = 62;
});
Library.CreateInstance(Library,"UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
FontIt(Btn);
ModeOptionBtns[Name] = Btn;
Btn.MouseButton1Click:Connect(function()
Mode = Name;
ModeVal.Text = Mode;
RefreshModeOpts();
CloseModePopup();
end);
end;
AddModeOpt("Solid",   1);
AddModeOpt("Rainbow", 2);
AddModeOpt("Fading",  3);
ModeBox.MouseButton1Click:Connect(function()
if ModePopupOpen then CloseModePopup() else OpenModePopup() end;
end);

AnimLbl("Speed", 42);
local SpeedVal = Library.CreateInstance(Library,"TextLabel", {
Parent                 = AnimationsPanel;
AnchorPoint            = Vector2.new(1, 0);
Position               = UDim2.new(1, 0, 0, 42);
Size                   = UDim2.new(0, 40, 0, 12);
BackgroundTransparency = 1;
Text                   = "50%";
TextColor3             = Color3.fromHex("8C8F99");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Right;
}); FontIt(SpeedVal);
local SpTrack = Library.CreateInstance(Library,"TextButton", {
Parent           = AnimationsPanel;
Position         = UDim2.new(0, 0, 0, 58);
Size             = UDim2.new(1, 0, 0, 10);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
local SpGray = Library.CreateInstance(Library,"Frame", {
Parent = SpTrack; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
});
local SpInside = Library.CreateInstance(Library,"Frame", {
Parent = SpGray; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("131313"); BorderSizePixel = 0;
});
local SpFill = Library.CreateInstance(Library,"Frame", {
Parent           = SpInside;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(0.5, -2, 1, -2);
BackgroundColor3 = Library.Accent;
BorderSizePixel  = 0;
});
Library.RegisterAccent(Library,SpFill);

local SpDragging = false;
local SpVisualT = 0.5;
local SpTargetT = 0.5;
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if math.abs(SpTargetT - SpVisualT) < 0.001 then return end;
local Alpha = 1 - math.exp(-Dt * 14);
SpVisualT = SpVisualT + (SpTargetT - SpVisualT) * Alpha;
SpFill.Size = UDim2.new(SpVisualT, -2, 1, -2);
end);
local function SpUpdate(Px)
local Ax, Aw = SpInside.AbsolutePosition.X, SpInside.AbsoluteSize.X;
if Aw <= 0 then return end;
local T = math.clamp((Px - Ax) / Aw, 0, 1);
Speed = math.floor(T * 100 + 0.5);
SpTargetT = T;
SpeedVal.Text = Speed .. "%";
end;
Library.Connection(Library,SpTrack.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
SpDragging = true; SpUpdate(Input.Position.X);
end;
end);
Library.Connection(Library,SpTrack.InputEnded, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
SpDragging = false;
end;
end);
Library.Connection(Library,Services.UserInputService.InputChanged, function(Input)
if not SpDragging then return end;
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
SpUpdate(Input.Position.X);
end;
end);

local SatValArea = Library.CreateInstance(Library,"Frame", {
Name             = "SatVal";
Parent           = ColorPage;
Position         = UDim2.new(0, 0, 0, 24);
Size             = UDim2.new(1, -30, 1, -66);
BackgroundColor3 = Color3.fromRGB(255, 0, 0);
BorderSizePixel  = 0;
ZIndex           = 55;
});
Library.CreateInstance(Library,"UIStroke", {
Parent          = SatValArea;
Color           = Color3.fromHex("000105");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local SatLayer = Library.CreateInstance(Library,"TextButton", {
Name             = "Sat";
Parent           = SatValArea;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
ZIndex           = 56;
});
Library.CreateInstance(Library,"UIGradient", {
Parent       = SatLayer;
Rotation     = 270;
Transparency = NewNumberSequence({
NewNumberSequenceKeypoint(0, 0);
NewNumberSequenceKeypoint(1, 1);
});
Color = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromRGB(0, 0, 0));
NewColorSequenceKeypoint(1, Color3.fromRGB(0, 0, 0));
});
});
local ValLayer = Library.CreateInstance(Library,"TextButton", {
Name             = "Val";
Parent           = SatValArea;
Size             = UDim2.new(1, 0, 1, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
ZIndex           = 57;
});
Library.CreateInstance(Library,"UIGradient", {
Parent       = ValLayer;
Transparency = NewNumberSequence({
NewNumberSequenceKeypoint(0, 0);
NewNumberSequenceKeypoint(1, 1);
});
});
local SatValMarker = Library.CreateInstance(Library,"Frame", {
Name             = "Marker";
Parent           = SatValArea;
Size             = UDim2.new(0, 2, 0, 2);
BorderSizePixel  = 1;
BorderColor3     = Color3.fromRGB(0, 0, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
ZIndex           = 58;
});

local HueArea = Library.CreateInstance(Library,"TextButton", {
Name             = "Hue";
Parent           = ColorPage;
AnchorPoint      = Vector2.new(1, 0);
Position         = UDim2.new(1, -14, 0, 24);
Size             = UDim2.new(0, 12, 1, -66);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
ZIndex           = 55;
});
Library.CreateInstance(Library,"UIStroke", {
Parent          = HueArea;
Color           = Color3.fromHex("000105");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = HueArea;
Rotation = 270;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0,    Color3.fromRGB(255, 0, 0));
NewColorSequenceKeypoint(0.17, Color3.fromRGB(255, 255, 0));
NewColorSequenceKeypoint(0.33, Color3.fromRGB(0, 255, 0));
NewColorSequenceKeypoint(0.5,  Color3.fromRGB(0, 255, 255));
NewColorSequenceKeypoint(0.67, Color3.fromRGB(0, 0, 255));
NewColorSequenceKeypoint(0.83, Color3.fromRGB(255, 0, 255));
NewColorSequenceKeypoint(1,    Color3.fromRGB(255, 0, 0));
});
});
local HueMarker = Library.CreateInstance(Library,"Frame", {
Name             = "Marker";
Parent           = HueArea;
Size             = UDim2.new(1, 0, 0, 2);
BorderSizePixel  = 1;
BorderColor3     = Color3.fromRGB(0, 0, 0);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
ZIndex           = 56;
});

local AlphaArea = Library.CreateInstance(Library,"TextButton", {
Name             = "Alpha";
Parent           = ColorPage;
AnchorPoint      = Vector2.new(1, 0);
Position         = UDim2.new(1, 0, 0, 24);
Size             = UDim2.new(0, 12, 1, -66);
BackgroundColor3 = Color;
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
ZIndex           = 55;
});
Library.CreateInstance(Library,"UIStroke", {
Parent          = AlphaArea;
Color           = Color3.fromHex("000105");
Thickness       = 1;
ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
});
local AlphaCheckers = Library.CreateInstance(Library,"ImageLabel", {
Name                   = "Checkers";
Parent                 = AlphaArea;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Image                  = "rbxassetid://18274452449";
ScaleType              = Enum.ScaleType.Tile;
TileSize               = UDim2.new(0, 6, 0, 6);
ZIndex                 = 56;
});
Library.CreateInstance(Library,"UIGradient", {
Parent       = AlphaCheckers;
Rotation     = 270;
Transparency = NewNumberSequence({
NewNumberSequenceKeypoint(0, 0);
NewNumberSequenceKeypoint(1, 1);
});
});
local AlphaMarker = Library.CreateInstance(Library,"Frame", {
Name             = "Marker";
Parent           = AlphaArea;
Size             = UDim2.new(1, 0, 0, 2);
BackgroundColor3 = Color3.fromRGB(255, 255, 255);
BorderSizePixel  = 1;
BorderColor3     = Color3.fromRGB(0, 0, 0);
ZIndex           = 57;
});

local function MakeInput(YOffFromBottom)
local Box = Library.CreateInstance(Library,"Frame", {
Parent           = ColorPage;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, -YOffFromBottom);
Size             = UDim2.new(1, 0, 0, 18);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
ZIndex           = 55;
});
local Gray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local Inside = Library.CreateInstance(Library,"Frame", {
Parent           = Gray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = Inside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});
local Input = Library.CreateInstance(Library,"TextBox", {
Parent                 = Inside;
Size                   = UDim2.new(1, -6, 1, 0);
Position               = UDim2.new(0, 3, 0, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ClearTextOnFocus       = false;
Text                   = "";
PlaceholderColor3      = Color3.fromHex("5E626B");
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
ClipsDescendants       = true;
});
if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;
return Input;
end;

local HexInput = MakeInput(0);
HexInput.PlaceholderText = "Hex";
local RgbInput = MakeInput(20);
RgbInput.PlaceholderText = "R, G, B";

local function RgbString(C)
return string.format("%d, %d, %d", math.round(C.R * 255), math.round(C.G * 255), math.round(C.B * 255));
end;

local function ApplyState()
local C = Color3.fromHSV(H, S, V);
Color                              = C;
SwatchFill.BackgroundColor3        = C;
SwatchFill.BackgroundTransparency  = 1 - A;
AlphaArea.BackgroundColor3         = C;
SatValArea.BackgroundColor3        = Color3.fromHSV(H, 1, 1);

local SOff = (S < 1) and 0 or -3;
local VOff = ((1 - V) < 1) and 0 or -3;
SatValMarker.Position = UDim2.new(S, SOff, 1 - V, VOff);

local HOff = ((1 - H) < 1) and 0 or -2;
HueMarker.Position = UDim2.new(0, 0, 1 - H, HOff);

local AOff = ((1 - A) < 1) and 0 or -2;
AlphaMarker.Position = UDim2.new(0, 0, 1 - A, AOff);

if not RgbInput:IsFocused() then RgbInput.Text = RgbString(C) end;
if not HexInput:IsFocused() then HexInput.Text = C:ToHex() end;

Library.Flags[Flag] = C;
Callback(C, A);
end;
ApplyState();

local FadeColorA = Color3.fromRGB(255, 0, 0);
local FadeColorB = Color3.fromRGB(0, 0, 255);
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
if Mode == "Rainbow" then
H = (H + Dt * (Speed / 100)) % 1;
ApplyState();
elseif Mode == "Fading" then
local T = (math.sin(tick() * (Speed / 25)) + 1) * 0.5;
local C = FadeColorA:Lerp(FadeColorB, T);
H, S, V = Color3.toHSV(C);
ApplyState();
end;
end);

RgbInput.FocusLost:Connect(function()
local r, g, b = string.match(RgbInput.Text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)");
r, g, b = tonumber(r), tonumber(g), tonumber(b);
if r and g and b and r <= 255 and g <= 255 and b <= 255 then
H, S, V = Color3.toHSV(Color3.fromRGB(r, g, b));
end;
ApplyState();
end);
HexInput.FocusLost:Connect(function()
local Text = string.gsub(HexInput.Text, "^#", "");
if #Text == 6 then
local ok, C = pcall(Color3.fromHex, Text);
if ok and C then H, S, V = Color3.toHSV(C) end;
end;
ApplyState();
end);

local DraggingSat, DraggingHue, DraggingAlpha = false, false, false;
local Open = false;
local PickerIn   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local PickerOut  = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
local SlideOff   = 10;
local function AnchorXY()
local AbsP = Swatch.AbsolutePosition;
return AbsP.X - PickerHolder.AbsoluteSize.X + Swatch.AbsoluteSize.X, AbsP.Y + Swatch.AbsoluteSize.Y + 65;
end;
local function SetVisible(B)
if B == Open then return end;
Open = B;
local X, Y = AnchorXY();
if Open then
PickerHolder.Visible           = true;
PickerHolder.Position          = UDim2.fromOffset(X, Y - SlideOff);
PickerHolder.GroupTransparency = 1;
PickerOuterStroke.Transparency = 1;
PickerInnerStroke.Transparency = 1;
Library.Tween(Library,PickerHolder, PickerIn, {
Position          = UDim2.fromOffset(X, Y);
GroupTransparency = 0;
}):Play();
Library.Tween(Library,PickerOuterStroke, PickerIn, { Transparency = 0 }):Play();
Library.Tween(Library,PickerInnerStroke, PickerIn, { Transparency = 0 }):Play();
else
Library.Tween(Library,PickerHolder, PickerOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
Library.Tween(Library,PickerOuterStroke, PickerOut, { Transparency = 1 }):Play();
Library.Tween(Library,PickerInnerStroke, PickerOut, { Transparency = 1 }):Play();
task.delay(PickerOut.Time, function()
if not Open then PickerHolder.Visible = false end;
end);
end;
end;

local function HookDown(Inst, Setter)
Library.Connection(Library,Inst.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Setter(true);
end;
end);
end;

Library.Connection(Library,Swatch.MouseButton1Click, function() SetVisible(not Open) end);
HookDown(SatLayer,  function(B) DraggingSat   = B end);
HookDown(ValLayer,  function(B) DraggingSat   = B end);
HookDown(HueArea,   function(B) DraggingHue   = B end);
HookDown(AlphaArea, function(B) DraggingAlpha = B end);

Library.Connection(Library,Services.UserInputService.InputEnded, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 then
DraggingSat   = false;
DraggingHue   = false;
DraggingAlpha = false;
end;
end);

Library.Connection(Library,Services.UserInputService.InputChanged, function(Input)
if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end;
if not (DraggingSat or DraggingHue or DraggingAlpha) then return end;
local M = Services.UserInputService:GetMouseLocation();
local Mx, My = M.X, M.Y - GuiInset;
if DraggingSat then
local Ap = SatValArea.AbsolutePosition;
local Sz = SatValArea.AbsoluteSize;
S = Sz.X > 0 and math.clamp((Mx - Ap.X) / Sz.X, 0, 1) or 0;
V = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
elseif DraggingHue then
local Ap = HueArea.AbsolutePosition;
local Sz = HueArea.AbsoluteSize;
H = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
elseif DraggingAlpha then
local Ap = AlphaArea.AbsolutePosition;
local Sz = AlphaArea.AbsoluteSize;
A = Sz.Y > 0 and 1 - math.clamp((My - Ap.Y) / Sz.Y, 0, 1) or 0;
end;
ApplyState();
end);

Library.Connection(Library,Services.UserInputService.InputBegan, function(Input)
if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
if not Open then return end;
local M = Services.UserInputService:GetMouseLocation();
local Mx, My = M.X, M.Y - GuiInset;
local function Inside(F)
local Ap, Sz = F.AbsolutePosition, F.AbsoluteSize;
return Mx >= Ap.X and Mx <= Ap.X + Sz.X and My >= Ap.Y and My <= Ap.Y + Sz.Y;
end;
if not Inside(PickerHolder) and not Inside(Swatch) then
SetVisible(false);
end;
end);

if Opts.Tooltip then Library.Tooltip(Library,Row, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Row.Visible = S end);
end;

local CpObj = { Container = Row, Swatch = Swatch, Picker = PickerHolder };
function CpObj:Get() return Color, A end;
function CpObj:Set(NewColor, NewAlpha)
if typeof(NewColor) == "Color3" then H, S, V = Color3.toHSV(NewColor) end;
if NewAlpha then A = math.clamp(NewAlpha, 0, 1) end;
ApplyState();
end;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Colorpicker", Obj = CpObj };
end
return CpObj;
end;

function SecRef:Dropdown(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Dropdown");
local Options  = typeof(Opts.Options) == "table" and Opts.Options or {};
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
local Multi    = Opts.Multi == true;

local Value;
if Multi then
Value = {};
if typeof(Opts.Default) == "table" then
for _, V in Opts.Default do Value[tostring(V)] = true end;
elseif Opts.Default ~= nil then
Value[tostring(Opts.Default)] = true;
end;
else
Value = tostring(Opts.Default or Options[1] or "");
end;
Library.Flags[Flag] = Value;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Dropdown_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 36);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Box = Library.CreateInstance(Library,"TextButton", {
Name             = "Box";
Parent           = Container;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, 0);
Size             = UDim2.new(1, 0, 0, 21);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
AutoButtonColor  = false;
Text             = "";
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Parent           = BoxGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BoxInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});

local ValLbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Value";
Parent                 = BoxInside;
Position               = UDim2.new(0, 4, 0, 0);
Size                   = UDim2.new(1, -14, 1, 0);
BackgroundTransparency = 1;
Text                   = "";
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
TextTruncate           = Enum.TextTruncate.AtEnd;
ClipsDescendants       = true;
});
local Arrow = Library.CreateInstance(Library,"Frame", {
Name                   = "Arrow";
Parent                 = BoxInside;
AnchorPoint            = Vector2.new(1, 0.5);
Position               = UDim2.new(1, -4, 0.5, 0);
Size                   = UDim2.fromOffset(7, 7);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
Library.CreateInstance(Library,"Frame", {
Name             = "Horiz";
Parent           = Arrow;
AnchorPoint      = Vector2.new(0.5, 0.5);
Position         = UDim2.new(0.5, 0, 0.5, 0);
Size             = UDim2.fromOffset(7, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local ArrowV = Library.CreateInstance(Library,"Frame", {
Name             = "Vert";
Parent           = Arrow;
AnchorPoint      = Vector2.new(0.5, 0.5);
Position         = UDim2.new(0.5, 0, 0.5, 0);
Size             = UDim2.fromOffset(1, 7);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local function SetArrow(Plus) ArrowV.Visible = Plus end;
if ProggyCleanFont then
ValLbl.FontFace = ProggyCleanFont;
end;

local Popup = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "DropdownPopup";
Parent            = Gui;
Size              = UDim2.new(0, 100, 0, 142);
BackgroundColor3  = Color3.fromHex("000000");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 50;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = Popup;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});
local PopupGray = Library.CreateInstance(Library,"Frame", {
Parent           = Popup;
Position         = UDim2.new(0, 0, 0, 0);
Size             = UDim2.new(1, 0, 0, 142);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
ZIndex           = 50;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = PopupGray;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});
local PopupInside = Library.CreateInstance(Library,"Frame", {
Parent                 = PopupGray;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 140);
BackgroundColor3       = Color3.fromHex("131313");
BorderSizePixel        = 0;
ZIndex                 = 50;
});
Library.CreateInstance(Library,"ScrollingFrame", {
Parent        = PopupInside;
Size          = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel  = 0;
ScrollBarThickness = 4;
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
});
local ScrollContent = PopupInside:FindFirstChildOfClass("ScrollingFrame")
Library.CreateInstance(Library,"UIListLayout", {
Parent        = ScrollContent;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 0);
});

local Open = false;
local OptionButtons = {};
local ClosePopup;

local function IsSelected(Opt)
Opt = tostring(Opt);
if Multi then return Value[Opt] == true end;
return Opt == Value;
end;

local function DisplayText()
if not Multi then return tostring(Value) end;
local Sel = {};
for _, Opt in Options do
if Value[tostring(Opt)] then table.insert(Sel, tostring(Opt)) end;
end;
return (#Sel > 0) and table.concat(Sel, ", ") or "None";
end;

local OptColorInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local function RefreshColors()
for _, B in OptionButtons do
local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
Library.Tween(Library,B, OptColorInfo, { TextColor3 = Target }):Play();
end;
end;

local function SetVal(V, Fire)
V = tostring(V);
if Multi then
Value[V] = (not Value[V]) or nil;
else
if V == Value then return end;
Value = V;
end;
Library.Flags[Flag] = Value;
ValLbl.Text = DisplayText();
RefreshColors();
if Fire ~= false then Callback(Value) end;
end;

local function BuildOptions()
for _, C in ScrollContent:GetChildren() do
if C:IsA("TextButton") then C:Destroy() end;
end;
table.clear(OptionButtons);
for I, Opt in Options do
local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Option_" .. tostring(Opt);
Parent                 = ScrollContent;
Size                   = UDim2.new(1, 0, 0, 14);
BackgroundColor3       = Color3.fromHex("131313");
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = tostring(Opt);
TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
LayoutOrder            = I;
ZIndex                 = 51;
});
Library.CreateInstance(Library,"UIPadding", {
Parent      = Btn;
PaddingLeft = UDim.new(0, 5);
});
if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
Btn.MouseButton1Click:Connect(function()
SetVal(Btn.Text);
if not Multi and ClosePopup then ClosePopup() end;
end);
table.insert(OptionButtons, Btn);
end;
if ScrollContent then
ScrollContent.CanvasSize = UDim2.new(0, 0, 0, #Options * 14)
end
end;
BuildOptions();
ValLbl.Text = DisplayText();
Library.OnAccent(Library,RefreshColors);

local PopupIn  = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local PopupOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
local SlideOff = 10;
local PopupGap = 60;

local function AnchorXY()
local AbsPos  = Box.AbsolutePosition;
local AbsSize = Box.AbsoluteSize;
Popup.Size = UDim2.new(0, AbsSize.X, 0, 142);
return AbsPos.X, AbsPos.Y + AbsSize.Y + PopupGap;
end;

ClosePopup = function()
if not Open then return end;
Open = false;
local X, Y = AnchorXY();
Library.Tween(Library,Popup, PopupOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
task.delay(PopupOut.Time, function()
if not Open then Popup.Visible = false end;
end);
SetArrow(true);
end;

Box.MouseButton1Click:Connect(function()
Open = not Open;
local X, Y = AnchorXY();
if Open then
Popup.Visible           = true;
Popup.Position          = UDim2.fromOffset(X, Y - SlideOff);
Popup.GroupTransparency = 1;
Library.Tween(Library,Popup, PopupIn, {
Position          = UDim2.fromOffset(X, Y);
GroupTransparency = 0;
}):Play();
SetArrow(false);
else
Library.Tween(Library,Popup, PopupOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
task.delay(PopupOut.Time, function()
if not Open then Popup.Visible = false end;
end);
SetArrow(true);
end;
end);

Library.Connection(Library,Services.UserInputService.InputBegan, function(Input)
if not Open then return end;
if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end;
local Mx, My = Input.Position.X, Input.Position.Y;
local function InAbs(Inst)
local P, S = Inst.AbsolutePosition, Inst.AbsoluteSize;
return Mx >= P.X and Mx <= P.X + S.X and My >= P.Y and My <= P.Y + S.Y;
end;
if InAbs(Box) or InAbs(Popup) then return end;
Open = false;
local X, Y = AnchorXY();
Library.Tween(Library,Popup, PopupOut, {
Position          = UDim2.fromOffset(X, Y - SlideOff);
GroupTransparency = 1;
}):Play();
task.delay(PopupOut.Time, function()
if not Open then Popup.Visible = false end;
end);
SetArrow(true);
end);

if Opts.Tooltip then Library.Tooltip(Library,Box, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Container.Visible = S end);
end;

local Obj = { Container = Container, Box = Box, Popup = Popup };
function Obj:Get() return Value end;
function Obj:Set(V)
if Multi then
Value = {};
if typeof(V) == "table" then
for _, Item in V do Value[tostring(Item)] = true end;
elseif V ~= nil then
Value[tostring(V)] = true;
end;
Library.Flags[Flag] = Value;
ValLbl.Text = DisplayText();
RefreshColors();
Callback(Value);
else
SetVal(V);
end;
end;
function Obj:SetOptions(Opts2)
Options = typeof(Opts2) == "table" and Opts2 or {};
BuildOptions();
ValLbl.Text = DisplayText();
end;
return Obj;
end;

function SecRef:Textbox(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name        = tostring(Opts.Name or Opts.Title or Opts.Text or "Textbox");
local Default     = tostring(Opts.Default or "");
local Placeholder = tostring(Opts.Placeholder or "...");
local Numeric     = Opts.Numeric == true;
local Callback    = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag        = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
Library.Flags[Flag] = Default;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "Textbox_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 36);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Container;
Position               = UDim2.new(0, 0, 0, 0);
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Box = Library.CreateInstance(Library,"Frame", {
Name             = "Box";
Parent           = Container;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, 0);
Size             = UDim2.new(1, 0, 0, 21);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Parent           = BoxGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BoxInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});

local Input = Library.CreateInstance(Library,"TextBox", {
Name                   = "Input";
Parent                 = BoxInside;
Position               = UDim2.new(0, 4, 0, 0);
Size                   = UDim2.new(1, -8, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ClearTextOnFocus       = false;
Text                   = Default;
PlaceholderText        = Placeholder;
PlaceholderColor3      = Color3.fromHex("5E626B");
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
ClipsDescendants       = true;
});
if ProggyCleanFont then Input.FontFace = ProggyCleanFont end;

local function Commit(V, Fire)
V = tostring(V);
if Numeric then
local Num = tonumber(V);
V = Num and tostring(Num) or "";
end;
Input.Text = V;
Library.Flags[Flag] = V;
if Fire ~= false then Callback(V) end;
end;

Input.FocusLost:Connect(function(Enter)
Commit(Input.Text);
end);

if Opts.Tooltip then Library.Tooltip(Library,Box, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Container.Visible = S end);
end;

local Obj = { Container = Container, Box = Box, Input = Input };
function Obj:Get() return Input.Text end;
function Obj:Set(V) Commit(V, false) end;
if Flag ~= "" then
Library.UIElements[Flag] = { Type = "Textbox", Obj = Obj };
end
return Obj;
end;

function SecRef:Keybind(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "Keybind");
local Mode     = string.lower(tostring(Opts.Mode or "Toggle"));
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));
local Key      = Opts.Default;
local State    = false;
Library.Flags[Flag] = State;

local function KeyDisplay(K)
if K == nil then return "None" end;
if typeof(K) == "EnumItem" then
return Library.KeyNames[K] or K.Name;
end;
return tostring(K);
end;

local Row = Library.CreateInstance(Library,"TextButton", {
Name                   = "Keybind_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, 16);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = "";
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Label";
Parent                 = Row;
AnchorPoint            = Vector2.new(0, 0.5);
Position               = UDim2.new(0, 0, 0.5, 0);
Size                   = UDim2.new(1, -62, 1, 0);
BackgroundTransparency = 1;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Box = Library.CreateInstance(Library,"Frame", {
Name             = "KeyBox";
Parent           = Row;
AnchorPoint      = Vector2.new(1, 0.5);
Position         = UDim2.new(1, 0, 0.5, 0);
Size             = UDim2.fromOffset(56, 16);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Parent           = Box;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Parent           = BoxGray;
Position         = UDim2.new(0, 1, 0, 1);
Size             = UDim2.new(1, -2, 1, -2);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent   = BoxInside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});

local Display = Library.CreateInstance(Library,"TextLabel", {
Name                   = "Display";
Parent                 = BoxInside;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
Text                   = KeyDisplay(Key);
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Center;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Display.FontFace = ProggyCleanFont end;

local Listening = false;
local ListenConn;

local function Refresh()
if Listening then
Display.Text       = "...";
Display.TextColor3 = Library.Accent;
else
Display.Text       = KeyDisplay(Key);
Display.TextColor3 = Color3.fromHex("FFFFFF");
end;
end;

local function CancelListen()
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Listening = false;
Refresh();
end;

local function StartListen()
if Listening then CancelListen(); return end;
Listening = true;
Refresh();
task.defer(function()
if not Listening then return end;
ListenConn = Services.UserInputService.InputBegan:Connect(function(Input)
local T = Input.UserInputType;
if T == Enum.UserInputType.Keyboard then
local K = Input.KeyCode;
if K == Enum.KeyCode.Escape then
CancelListen();
else
Key = K;
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Refresh();
Library.NotifyKeybind(Library);
KeybindCallback(Key, BindMode);
end;
elseif T == Enum.UserInputType.MouseButton1
or T == Enum.UserInputType.MouseButton2
or T == Enum.UserInputType.MouseButton3 then
Key = T;
Listening = false;
if ListenConn then ListenConn:Disconnect(); ListenConn = nil end;
Refresh();
Library.NotifyKeybind(Library);
KeybindCallback(Key, BindMode);
end;
end);
end);
end;

Row.MouseButton1Click:Connect(StartListen);

local ModeOpts = { "Toggle", "Hold", "Always" };

local Popup = Library.CreateInstance(Library,"CanvasGroup", {
Name              = "KeybindPopup_" .. Name;
Parent            = Gui;
Size              = UDim2.new(0, 80, 0, 0);
AutomaticSize     = Enum.AutomaticSize.Y;
BackgroundColor3  = Color3.fromHex("000000");
BorderSizePixel   = 0;
Visible           = false;
GroupTransparency = 1;
ZIndex            = 50;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = Popup;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});
local PopupGray = Library.CreateInstance(Library,"Frame", {
Parent           = Popup;
Size             = UDim2.new(1, 0, 0, 0);
AutomaticSize    = Enum.AutomaticSize.Y;
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
ZIndex           = 50;
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = PopupGray;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});
local PopupInside = Library.CreateInstance(Library,"Frame", {
Parent           = PopupGray;
Size             = UDim2.new(1, 0, 0, 0);
AutomaticSize    = Enum.AutomaticSize.Y;
BackgroundColor3 = Color3.fromHex("131313");
BorderSizePixel  = 0;
ZIndex           = 50;
});
Library.CreateInstance(Library,"UIListLayout", {
Parent        = PopupInside;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 0);
});
Library.CreateInstance(Library,"UIPadding", {
Parent        = PopupInside;
PaddingTop    = UDim.new(0, 2);
PaddingBottom = UDim.new(0, 2);
});

local PopupOpen = false;
local PopupToken = 0;
local PopupInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
local PopupSlide = 8;
local ModeBtns = {};

local function RefreshModeBtns()
for M, B in ModeBtns do
B.TextColor3 = (M == Mode) and Library.Accent or Color3.fromHex("FFFFFF");
end;
end;

local function ClosePopup()
if not PopupOpen then return end;
PopupOpen = false;
PopupToken = PopupToken + 1;
local Mine = PopupToken;
local Ap = Box.AbsolutePosition;
local Sz = Box.AbsoluteSize;
Library.Tween(Library,Popup, PopupInfo, {
GroupTransparency = 1;
Position          = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62 - PopupSlide);
}):Play();
task.delay(PopupInfo.Time, function()
if PopupToken == Mine then Popup.Visible = false end;
end);
end;

local function OpenPopup()
if PopupOpen then ClosePopup(); return end;
PopupOpen = true;
PopupToken = PopupToken + 1;
RefreshModeBtns();
local Ap = Box.AbsolutePosition;
local Sz = Box.AbsoluteSize;
Popup.GroupTransparency = 1;
Popup.Position = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62 - PopupSlide);
Popup.Visible = true;
Library.Tween(Library,Popup, PopupInfo, {
GroupTransparency = 0;
Position          = UDim2.fromOffset(Ap.X + Sz.X - 80, Ap.Y + Sz.Y + 62);
}):Play();
end;

for I, M in ModeOpts do
local Btn = Library.CreateInstance(Library,"TextButton", {
Parent                 = PopupInside;
Size                   = UDim2.new(1, 0, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = M;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
LayoutOrder            = I;
});
Library.CreateInstance(Library,"UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 6) });
if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
ModeBtns[M:lower()] = Btn;
Btn.MouseButton1Click:Connect(function()
Mode = M:lower();
if Mode == "always" then
State = true;
Library.Flags[Flag] = State;
Callback(true);
end;
RefreshModeBtns();
Library.NotifyKeybind(Library);
ClosePopup();
end);
end;
RefreshModeBtns();

Row.MouseButton2Click:Connect(OpenPopup);

Library.Connection(Library,Services.UserInputService.InputBegan, function(Input)
if not PopupOpen then return end;
if Input.UserInputType ~= Enum.UserInputType.MouseButton1
and Input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end;
local M = Services.UserInputService:GetMouseLocation();
local Ap = Popup.AbsolutePosition;
local Sz = Popup.AbsoluteSize;
if M.X < Ap.X or M.Y < Ap.Y or M.X > Ap.X + Sz.X or M.Y > Ap.Y + Sz.Y then
local Bp = Box.AbsolutePosition;
local Bs = Box.AbsoluteSize;
if M.X < Bp.X or M.Y < Bp.Y or M.X > Bp.X + Bs.X or M.Y > Bp.Y + Bs.Y then
ClosePopup();
end;
end;
end);

local function KeyMatches(Input)
if Key == nil or typeof(Key) ~= "EnumItem" then return false end;
if Key.EnumType == Enum.KeyCode then
return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Key;
elseif Key.EnumType == Enum.UserInputType then
return Input.UserInputType == Key;
end;
return false;
end;

Library.Connection(Library,Services.UserInputService.InputBegan, function(Input, GameProc)
if GameProc then return end;
if Listening then return end;
if Services.UserInputService:GetFocusedTextBox() then return end;
if not KeyMatches(Input) then return end;
if Mode == "always" then
Callback();
elseif Mode == "hold" then
State = true;
Library.Flags[Flag] = State;
Callback(true);
else
State = not State;
Library.Flags[Flag] = State;
Callback(State);
end;
end);

Library.Connection(Library,Services.UserInputService.InputEnded, function(Input)
if Mode ~= "hold" then return end;
if not KeyMatches(Input) then return end;
if State then
State = false;
Library.Flags[Flag] = State;
Callback(false);
end;
end);

if Opts.Tooltip then Library.Tooltip(Library,Row, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Row.Visible = S end);
end;

Library.RegisterKeybind(Library, {
Name     = Name;
GetMode  = function() return Mode end;
GetKey   = function() return Key end;
GetState = function() return State end;
});

local Obj = { Container = Row, Box = Box, Display = Display };
function Obj:Get() return State end;
function Obj:GetKey() return Key end;
function Obj:SetKey(K)
if Listening then CancelListen() end;
Key = K;
Refresh();
end;
return Obj;
end;

function SecRef:List(Opts)
Opts = typeof(Opts) == "table" and Opts or {};
local Name     = tostring(Opts.Name or Opts.Title or Opts.Text or "List");
local Options  = typeof(Opts.Options) == "table" and Opts.Options or {};
local Multi    = Opts.Multi == true;
local Height   = tonumber(Opts.Height) or 100;
local Callback = typeof(Opts.Callback) == "function" and Opts.Callback or function() end;
local Flag     = tostring(Opts.Flag or Opts.Pointer or ("_" .. Name));

local Value;
if Multi then
Value = {};
if typeof(Opts.Default) == "table" then
for _, V in Opts.Default do Value[tostring(V)] = true end;
end;
else
Value = tostring(Opts.Default or Options[1] or "");
end;
Library.Flags[Flag] = Value;

local Container = Library.CreateInstance(Library,"Frame", {
Name                   = "List_" .. Name;
Parent                 = self.Body;
Size                   = UDim2.new(1, 0, 0, Height + 16);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});

local Lbl = Library.CreateInstance(Library,"TextLabel", {
Parent                 = Container;
Size                   = UDim2.new(1, 0, 0, 12);
BackgroundTransparency = 1;
Text                   = Name;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

local Box = Library.CreateInstance(Library,"Frame", {
Name             = "Box";
Parent           = Container;
AnchorPoint      = Vector2.new(0, 1);
Position         = UDim2.new(0, 0, 1, 0);
Size             = UDim2.new(1, 0, 0, Height);
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
local BoxGray = Library.CreateInstance(Library,"Frame", {
Parent = Box; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("393939"); BorderSizePixel = 0;
});
local BoxInside = Library.CreateInstance(Library,"Frame", {
Parent = BoxGray; Position = UDim2.new(0, 1, 0, 1);
Size = UDim2.new(1, -2, 1, -2); BackgroundColor3 = Color3.fromHex("FFFFFF"); BorderSizePixel = 0;
});
Library.CreateInstance(Library,"UIGradient", {
Parent = BoxInside; Rotation = 90;
Color = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1B1B1B"));
NewColorSequenceKeypoint(1, Color3.fromHex("121212"));
});
});

local Scroller = Library.CreateInstance(Library,"ScrollingFrame", {
Parent                 = BoxInside;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
CanvasSize             = UDim2.new(0, 0, 0, 0);
AutomaticCanvasSize    = Enum.AutomaticSize.Y;
ScrollBarThickness     = 2;
ScrollBarImageColor3   = Library.Accent;
ScrollingDirection     = Enum.ScrollingDirection.Y;
ClipsDescendants       = true;
});
Library.RegisterAccent(Library,Scroller, "ScrollBarImageColor3");
Library.CreateInstance(Library,"UIListLayout", {
Parent        = Scroller;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
});
Library.CreateInstance(Library,"UIPadding", {
Parent     = Scroller;
PaddingTop = UDim.new(0, 2);
});

local OptionButtons = {};
local function IsSelected(Opt)
Opt = tostring(Opt);
if Multi then return Value[Opt] == true end;
return Opt == Value;
end;
local OptColorInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local function RefreshColors()
for _, B in OptionButtons do
local Target = IsSelected(B.Text) and Library.Accent or Color3.fromHex("FFFFFF");
Library.Tween(Library,B, OptColorInfo, { TextColor3 = Target }):Play();
end;
end;
local function SetVal(V, Fire)
V = tostring(V);
if Multi then
Value[V] = (not Value[V]) or nil;
else
if V == Value then return end;
Value = V;
end;
Library.Flags[Flag] = Value;
RefreshColors();
if Fire ~= false then Callback(Value) end;
end;
local function BuildOptions()
for _, C in Scroller:GetChildren() do
if C:IsA("TextButton") then C:Destroy() end;
end;
table.clear(OptionButtons);
for I, Opt in Options do
local Btn = Library.CreateInstance(Library,"TextButton", {
Name                   = "Opt_" .. tostring(Opt);
Parent                 = Scroller;
Size                   = UDim2.new(1, 0, 0, 14);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
AutoButtonColor        = false;
Text                   = tostring(Opt);
TextColor3             = IsSelected(Opt) and Library.Accent or Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
LayoutOrder            = I;
});
Library.CreateInstance(Library,"UIPadding", { Parent = Btn; PaddingLeft = UDim.new(0, 5) });
if ProggyCleanFont then Btn.FontFace = ProggyCleanFont end;
Btn.MouseButton1Click:Connect(function() SetVal(Btn.Text) end);
table.insert(OptionButtons, Btn);
end;
end;
BuildOptions();
Library.OnAccent(Library,RefreshColors);

if Opts.Tooltip then Library.Tooltip(Library,Box, Opts.Tooltip) end;
if Opts.Dependency and typeof(Opts.Dependency.OnChange) == "function" then
Opts.Dependency:OnChange(function(S) Container.Visible = S end);
end;

local Obj = { Container = Container, Box = Box, Scroller = Scroller };
function Obj:Get() return Value end;
function Obj:Set(V) SetVal(V) end;
function Obj:SetOptions(Opts2)
Options = typeof(Opts2) == "table" and Opts2 or {};
BuildOptions();
end;
return Obj;
end;

return SecRef;
end;

local WinRef = self;
Btn.MouseButton1Click:Connect(function()
if WinRef._Tabs then
    for _, T in WinRef._Tabs do
    if T ~= TabRef and T.Active then T:SetActive(false) end;
    end;
end;
TabRef:SetActive(true);
end);

if self._Tabs then
    table.insert(self._Tabs, TabRef);
end

local N = self._Tabs and #self._Tabs or 1;
if self._Tabs then
    for I, T in self._Tabs do
    T.Button.Size = UDim2.new(1 / N, 0, 1, 0);
    T.IsLeft  = (I == 1);
    T.IsRight = (I == N);
    T:SetActive(T.Active);
    end;
end;

if N == 1 then
TabRef:SetActive(true);
end;

local SepInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local function FadePiece(P, T)
Library.Tween(Library,P, SepInfo, { BackgroundTransparency = T }):Play();
end;
local function RefreshSeparators()
if not self._Tabs then return end
for I, T in self._Tabs do
local Prev = self._Tabs[I - 1];
local Next = self._Tabs[I + 1];
if T.Active then
FadePiece(T.Separator,   1);
FadePiece(T.TopBlack,    1);
FadePiece(T.TopGray,     1);
FadePiece(T.BottomBlack, 1);
FadePiece(T.BottomGray,  1);
FadePiece(T.LeftBlack,   1);
FadePiece(T.LeftGray,    1);
FadePiece(T.RightBlack,  1);
FadePiece(T.RightGray,   1);
FadePiece(T.TopGradient, 0);
else
FadePiece(T.TopGradient, 1);
local LeftShown  = (Prev ~= nil) and Prev.Active;
local RightShown = (Next ~= nil) and Next.Active;
FadePiece(T.TopBlack,    0);
FadePiece(T.TopGray,     0);
FadePiece(T.BottomBlack, 0);
FadePiece(T.BottomGray,  0);
FadePiece(T.LeftBlack,   LeftShown  and 0 or 1);
FadePiece(T.LeftGray,    LeftShown  and 0 or 1);
FadePiece(T.RightBlack,  RightShown and 0 or 1);
FadePiece(T.RightGray,   RightShown and 0 or 1);
FadePiece(T.Separator,   (Next ~= nil and not Next.Active) and 0 or 1);
local Li = LeftShown and 1 or 0;
local Ri = RightShown and 1 or 0;
T.TopGray.Position    = UDim2.new(0, Li, 0, 1);
T.TopGray.Size        = UDim2.new(1, -Li - Ri, 0, 1);
T.BottomGray.Position = UDim2.new(0, Li, 1, -1);
T.BottomGray.Size     = UDim2.new(1, -Li - Ri, 0, 1);
end;
end;
end;
RefreshSeparators();

local OrigSetActive = TabRef.SetActive;
function TabRef:SetActive(State)
OrigSetActive(self, State);
RefreshSeparators();
end;

function TabRef:ApplySettings()
local ConfigDir    = Library.Directory .. "/Configs";
local ThemeDir     = Library.Directory .. "/Themes";


local function ListConfigs()
local Out = {};
if isfolder and isfolder(ConfigDir) then
for _, F in listfiles(ConfigDir) do
if string.find(F, "%.json$") then
local Nm = string.gsub(F, ".*[/\\]", ""):gsub("%.json$", "");
if not string.match(string.lower(Nm), "^autoload") then
table.insert(Out, Nm);
end;
end;
end;
end;
if #Out == 0 then table.insert(Out, "default") end;
return Out;
end;

local function ListThemes()
local Out = {};
if isfolder and isfolder(ThemeDir) then
for _, F in listfiles(ThemeDir) do
if string.find(F, "%.json$") then
local Nm = string.gsub(F, ".*[/\\]", ""):gsub("%.json$", "");
table.insert(Out, Nm);
end;
end;
end;
if #Out == 0 then table.insert(Out, "default") end;
return Out;
end;

local SecCfg = self:Section({ Name = "Configuration", Side = "Left" });
local ConfigList = SecCfg:List({
Name    = "Configs";
Options = ListConfigs();
Default = "default";
Height  = 90;
});
SecCfg:Textbox({ Name = "Config Name", Flag = "ConfigName", Placeholder = "name..." });
SecCfg:Button({
Name = "Save";
Callback = function()
local Nm = Library.Flags.ConfigName;
if not Nm or Nm == "" then Library.Notify(Library,"Enter a config name first", 3); return end;
local Save = {};
local ExcludedFlags = {
"MenuEaseStyle", "MenuEaseDir", "TweeningSpeed", "DraggingSpeed", "MenuPrefix", "MenuSuffix",
"Watermark", "WatermarkOpts", "WatermarkRate", "KeybindList"
};
for K, V in Library.Flags do
local IsExcluded = false;
for _, Excluded in ipairs(ExcludedFlags) do
if K == Excluded then
IsExcluded = true;
break;
end;
end;
if not IsExcluded then
if typeof(V) == "Color3" then Save[K] = { _t = "Color3", v = V:ToHex() };
elseif typeof(V) == "table" then Save[K] = V;
else Save[K] = V end;
end;
end;
writefile(ConfigDir .. "/" .. Nm .. ".json", Services.HttpService:JSONEncode(Save));
ConfigList:SetOptions(ListConfigs());
Library.Notify(Library,"Saved config: " .. Nm, 3);
end;
}):Button({
Name = "Load";
Callback = function()
local Nm = ConfigList:Get();
local Path = ConfigDir .. "/" .. Nm .. ".json";
if not (isfile and isfile(Path)) then Library.Notify(Library,"Config not found", 3); return end;
local Ok, Data = pcall(Services.HttpService.JSONDecode, Services.HttpService, readfile(Path));
if not Ok then Library.Notify(Library,"Failed to decode config", 3); return end;
for K, V in Data do
if typeof(V) == "table" and V._t == "Color3" then
Library.Flags[K] = Color3.fromHex(V.v);
else
Library.Flags[K] = V;
end;
end;
Library.Notify(Library,"Loaded: " .. Nm, 3);
end;
    });
    local ConfigDeleteRow = SecCfg:Row({ Height = 21 });
    ConfigDeleteRow:Button({
    Name = "Delete"; Confirm = true;
    Callback = function()
    local Nm = ConfigList:Get();
    local Path = ConfigDir .. "/" .. Nm .. ".json";
    if isfile and isfile(Path) then delfile(Path) end;
    ConfigList:SetOptions(ListConfigs());
    Library.Notify(Library,"Deleted: " .. Nm, 3);
    end;
    });
    ConfigDeleteRow:Button({
    Name = "Refresh";
    Callback = function()
    ConfigList:SetOptions(ListConfigs());
    Library.Notify(Library,"Refreshed configs", 2);
    end;
    });
    local ConfigAutoLoadRow = SecCfg:Row({ Height = 21 });
    ConfigAutoLoadRow:Button({
    Name = "Set Auto Load";
    Callback = function()
    writefile(Library.Directory .. "/AutoloadConfig.txt", ConfigList:Get());
    Library.Notify(Library,"Auto-load config: " .. ConfigList:Get(), 3);
    end;
    });
    ConfigAutoLoadRow:Button({
    Name = "Remove Auto Load"; Confirm = true;
    Callback = function()
    if isfile and isfile(Library.Directory .. "/AutoloadConfig.txt") then writefile(Library.Directory .. "/AutoloadConfig.txt", "") end;
    Library.Notify(Library,"Auto-load config cleared", 3);
    end;
    });

local SecMenu = self:Section({ Name = "Menu", Side = "Left" });
local Row1 = SecMenu:Row({ Height = 21 });
Row1:Dropdown({
Name    = "Easing Style"; Flag = "MenuEaseStyle";
Options = { "Linear", "Cubic", "Quad", "Quart", "Quint", "Sine", "Exponential", "Circular", "Back", "Elastic", "Bounce" };
Default = "Quint";
Callback = function(V) Library.EasingStyle = Enum.EasingStyle[V] end;
});
Row1:Dropdown({
Name = "Easing Direction"; Flag = "MenuEaseDir";
Options = { "In", "Out", "InOut" };
Default = "Out";
Callback = function(V) Library.EasingDirection = Enum.EasingDirection[V] end;
});
Library.EasingStyle     = Enum.EasingStyle.Quint;
Library.EasingDirection = Enum.EasingDirection.Out;

local Row2 = SecMenu:Row({ Height = 21 });
Row2:Slider({
Name = "Tweening Speed"; Flag = "TweeningSpeed";
Min = 0.05, Max = 2, Step = 0.05, Decimals = 2, Default = 1;
Callback = function(V) Library.AnimationSpeed = V end;
});
Row2:Slider({ Name = "Dragging Speed", Flag = "DraggingSpeed", Min = 0, Max = 2, Step = 0.05, Decimals = 2, Default = 0.05 });

local Row3 = SecMenu:Row({ Height = 21 });
Row3:Textbox({ Name = "Prefix", Flag = "MenuPrefix", Placeholder = "menu prefix" });
Row3:Textbox({ Name = "Suffix", Flag = "MenuSuffix", Placeholder = "menu suffix" });

SecMenu:Keybind({
Name     = "Menu Keybind";
Default  = Enum.KeyCode.Insert;
Mode     = "Always";
Callback = function() Window:Toggle() end;
});

local SecHud = self:Section({ Name = "HUD", Side = "Right" });
local WatermarkToggle = SecHud:Toggle({
Name     = "Watermark", Default = true;
Callback = function(S) if Library._Watermark then Library._Watermark.Gui.Enabled = S end end;
});
SecHud:Dropdown({
Name    = "Watermark Options";
Multi   = true;
Flag    = "WatermarkOpts";
Options = { "Title", "Fps", "Ping", "Game Name", "User ID", "LocalPlayer Name", "Date" };
Default = { "Title", "Fps", "Ping" };
Dependency = WatermarkToggle;
});
SecHud:Slider({ Name = "Refresh Rate", Flag = "WatermarkRate", Min = 0, Max = 2, Step = 0.05, Decimals = 2, Default = 0.1; Dependency = WatermarkToggle; });
local KeybindListToggle = SecHud:Toggle({
Name     = "Keybind List", Default = true;
Callback = function(S) if Library._KeybindList then Library._KeybindList.Gui.Enabled = S end end;
});
SecHud:Slider({ Name = "Keybind Transparency", Flag = "KeybindTransparency", Min = 0, Max = 100, Step = 1, Default = 50; Dependency = KeybindListToggle; Callback = function(V) if Library._KeybindList and Library._KeybindList.Frame then local transparency = V / 100; Library._KeybindList.Frame.BackgroundTransparency = transparency; for _, child in ipairs(Library._KeybindList.Frame:GetChildren()) do if child:IsA("Frame") then child.BackgroundTransparency = transparency elseif child:IsA("UIStroke") then child.Transparency = transparency end end end end; });

do
local LP = Services.LocalPlayer;
local Fps, FpsAcc, FpsCnt = 60, 0, 0;
Library.Connection(Library,Services.RunService.RenderStepped, function(Dt)
FpsCnt = FpsCnt + 1; FpsAcc = FpsAcc + Dt;
if FpsAcc >= 0.5 then
Fps = math.round(FpsCnt / FpsAcc);
FpsCnt, FpsAcc = 0, 0;
end;
end);
local GameName = "Roblox"

local function fetchGameName() 
    local Ok, Info = pcall(Services.MarketplaceService.GetProductInfo, Services.MarketplaceService, Services.game.PlaceId)
    if Ok and Info and Info.Name then GameName = Info.Name end
end

task.spawn(fetchGameName)
local Acc = 0;
Library.Connection(Library,Services.RunService.Heartbeat, function(Dt)
local W = Library._Watermark;
if not (W and W.Gui and W.Gui.Enabled) then return end;
local Rate = Library.Flags.WatermarkRate or 0.1;
Acc = Acc + Dt;
if Acc < Rate then return end;
Acc = 0;

local K = Library._KeybindList;
if K and K.Frame then
    local KeybindTransparency = Library.Flags.KeybindTransparency or 50;
    K.Frame.BackgroundTransparency = KeybindTransparency / 100;
end

local Opts = Library.Flags.WatermarkOpts or {};
local Parts = {};
if Opts.Title              then table.insert(Parts, "Vision") end;
if Opts.Fps                then table.insert(Parts, Fps .. " fps") end;
if Opts.Ping and LP        then table.insert(Parts, math.round(LP:GetNetworkPing() * 1000) .. " ms") end;
if Opts["Game Name"]       then table.insert(Parts, GameName) end;
if Opts["User ID"] and LP  then table.insert(Parts, tostring(LP.UserId)) end;
if Opts["LocalPlayer Name"] and LP then table.insert(Parts, LP.Name) end;
if Opts.Date               then table.insert(Parts, os.date("%H:%M:%S")) end;
if #Parts > 0 then
local Body   = table.concat(Parts, " | ");
local Prefix = Library.Flags.MenuPrefix or "";
local Suffix = Library.Flags.MenuSuffix or "";
if Prefix ~= "" then Body = Prefix .. " " .. Body end;
if Suffix ~= "" then Body = Body   .. " " .. Suffix end;
W:SetText(Body);
end;
end);
end;

local SecTheme = self:Section({ Name = "Theming", Side = "Right" });
SecTheme:Colorpicker({
Name     = "Accent"; Flag = "Accent";
Default  = Library.Accent;
Alpha    = 1;
Callback = function(C) Library.SetAccent(Library,C); Library.Flags.Accent = C; end;
});
SecTheme:Textbox({ Name = "Theme Name", Flag = "ThemeName", Placeholder = "theme name..." });
local ThemeList = SecTheme:List({
Name    = "Themes";
Options = ListThemes();
Default = "default";
Height  = 80;
});
local ThemeSaveDeleteRow = SecTheme:Row({ Height = 21 });
ThemeSaveDeleteRow:Button({
Name = "Save";
Callback = function()
local Nm = Library.Flags.ThemeName;
if not Nm or Nm == "" then Library.Notify(Library,"Enter a theme name", 3); return end;
local Save = { 
Accent = Library.Flags.Accent:ToHex(),
MenuSettings = {
MenuEaseStyle = Library.Flags.MenuEaseStyle,
MenuEaseDir = Library.Flags.MenuEaseDir,
TweeningSpeed = Library.Flags.TweeningSpeed,
DraggingSpeed = Library.Flags.DraggingSpeed,
MenuPrefix = Library.Flags.MenuPrefix,
MenuSuffix = Library.Flags.MenuSuffix
},
HUDSettings = {
Watermark = Library.Flags.Watermark,
WatermarkOpts = Library.Flags.WatermarkOpts,
WatermarkRate = Library.Flags.WatermarkRate,
KeybindList = Library.Flags.KeybindList,
KeybindTransparency = Library.Flags.KeybindTransparency
},
NotificationSettings = {
QueueSystem = Library.Flags.QueueSystem,
MaxHeight = Library.Flags.NotifyMaxHeight,
Transparency = Library.Flags.NotifyTransparency,
BarPosition = Library.Flags.NotifyBarSide,
Alignment = Library.Flags.NotifyAlignment,
PositionX = Library.Flags.NotifyPosX,
PositionY = Library.Flags.NotifyPosY,
SortOrder = Library.Flags.NotifySortOrder
}
};
writefile(ThemeDir .. "/" .. Nm .. ".json", Services.HttpService:JSONEncode(Save));
ThemeList:SetOptions(ListThemes());
Library.Notify(Library,"Saved theme: " .. Nm, 3);
end;
});

ThemeSaveDeleteRow:Button({
Name = "Delete"; Confirm = true;
Callback = function()
local Nm = ThemeList:Get();
local Path = ThemeDir .. "/" .. Nm .. ".json";
if isfile and isfile(Path) then delfile(Path) end;
ThemeList:SetOptions(ListThemes());
Library.Notify(Library,"Deleted theme: " .. Nm, 3);
end;
});

local ThemeLoadRefreshRow = SecTheme:Row({ Height = 21 });
ThemeLoadRefreshRow:Button({
Name = "Load";
Callback = function()
local Nm = ThemeList:Get();
local Path = ThemeDir .. "/" .. Nm .. ".json";
if not (isfile and isfile(Path)) then Library.Notify(Library,"Theme not found", 3); return end;
local Ok, Data = pcall(Services.HttpService.JSONDecode, Services.HttpService, readfile(Path));
if Ok and Data.Accent then
local LoadedAccent = Color3.fromHex(Data.Accent)
Library.SetAccent(Library,LoadedAccent);
Library.Flags.Accent = LoadedAccent;

if Library.UIElements["Accent"] and Library.UIElements["Accent"].Obj then
Library.UIElements["Accent"].Obj:Set(LoadedAccent)
end

if Data.MenuSettings then
if Data.MenuSettings.MenuEaseStyle then
Library.Flags.MenuEaseStyle = Data.MenuSettings.MenuEaseStyle
Library.EasingStyle = Enum.EasingStyle[Data.MenuSettings.MenuEaseStyle]
end
if Data.MenuSettings.MenuEaseDir then
Library.Flags.MenuEaseDir = Data.MenuSettings.MenuEaseDir
Library.EasingDirection = Enum.EasingDirection[Data.MenuSettings.MenuEaseDir]
end
if Data.MenuSettings.TweeningSpeed then
Library.Flags.TweeningSpeed = Data.MenuSettings.TweeningSpeed
Library.AnimationSpeed = Data.MenuSettings.TweeningSpeed
end
if Data.MenuSettings.DraggingSpeed then
Library.Flags.DraggingSpeed = Data.MenuSettings.DraggingSpeed
end
if Data.MenuSettings.MenuPrefix then
Library.Flags.MenuPrefix = Data.MenuSettings.MenuPrefix
end
if Data.MenuSettings.MenuSuffix then
Library.Flags.MenuSuffix = Data.MenuSettings.MenuSuffix
end
end

if Data.HUDSettings then
if Data.HUDSettings.Watermark ~= nil then
Library.Flags.Watermark = Data.HUDSettings.Watermark
if Library._Watermark then Library._Watermark.Gui.Enabled = Data.HUDSettings.Watermark end
end
if Data.HUDSettings.WatermarkOpts then
Library.Flags.WatermarkOpts = Data.HUDSettings.WatermarkOpts
end
if Data.HUDSettings.WatermarkRate then
Library.Flags.WatermarkRate = Data.HUDSettings.WatermarkRate
end

if Data.HUDSettings.KeybindList ~= nil then
Library.Flags.KeybindList = Data.HUDSettings.KeybindList
if Library._KeybindList then Library._KeybindList.Gui.Enabled = Data.HUDSettings.KeybindList end
end
if Data.HUDSettings.KeybindTransparency then
Library.Flags.KeybindTransparency = Data.HUDSettings.KeybindTransparency
if Library._KeybindList and Library._KeybindList.Frame then
    Library._KeybindList.Frame.BackgroundTransparency = Data.HUDSettings.KeybindTransparency / 100
end
end
end

if Data.NotificationSettings then
if Data.NotificationSettings.QueueSystem ~= nil then
Library.Flags.QueueSystem = Data.NotificationSettings.QueueSystem
end
if Data.NotificationSettings.MaxHeight then
Library.Flags.NotifyMaxHeight = Data.NotificationSettings.MaxHeight
end
if Data.NotificationSettings.Transparency then
Library.Flags.NotifyTransparency = Data.NotificationSettings.Transparency
end
if Data.NotificationSettings.BarPosition then
Library.Flags.NotifyBarSide = Data.NotificationSettings.BarPosition
end
if Data.NotificationSettings.Alignment then
Library.Flags.NotifyAlignment = Data.NotificationSettings.Alignment
end
if Data.NotificationSettings.PositionX then
Library.Flags.NotifyPosX = Data.NotificationSettings.PositionX
end
if Data.NotificationSettings.PositionY then
Library.Flags.NotifyPosY = Data.NotificationSettings.PositionY
end
if Data.NotificationSettings.SortOrder then
Library.Flags.NotifySortOrder = Data.NotificationSettings.SortOrder
end
end

for Flag, Element in Library.UIElements do
if Element.Obj and Element.Obj.Set then
local Value = Library.Flags[Flag]
if Element.Type == "Toggle" then
Element.Obj:Set(Value)
elseif Element.Type == "Slider" then
Element.Obj:Set(Value)
elseif Element.Type == "Colorpicker" then
if typeof(Value) == "Color3" then
Element.Obj:Set(Value)
end
elseif Element.Type == "Dropdown" then
Element.Obj:Set(Value)
elseif Element.Type == "Textbox" then
Element.Obj:Set(Value)
elseif Element.Type == "List" then
Element.Obj:Set(Value)
end
end
end

if Library.UIElements["QueueSystem"] and Library.UIElements["QueueSystem"].Obj then
Library.UIElements["QueueSystem"].Obj:Set(Library.Flags.QueueSystem)
end
if Library.UIElements["NotifyMaxHeight"] and Library.UIElements["NotifyMaxHeight"].Obj then
Library.UIElements["NotifyMaxHeight"].Obj:Set(Library.Flags.NotifyMaxHeight)
end
if Library.UIElements["NotifyTransparency"] and Library.UIElements["NotifyTransparency"].Obj then
Library.UIElements["NotifyTransparency"].Obj:Set(Library.Flags.NotifyTransparency)
end
if Library.UIElements["NotifyBarSide"] and Library.UIElements["NotifyBarSide"].Obj then
Library.UIElements["NotifyBarSide"].Obj:Set(Library.Flags.NotifyBarSide)
end
if Library.UIElements["NotifyAlignment"] and Library.UIElements["NotifyAlignment"].Obj then
Library.UIElements["NotifyAlignment"].Obj:Set(Library.Flags.NotifyAlignment)
end
if Library.UIElements["NotifyPosX"] and Library.UIElements["NotifyPosX"].Obj then
Library.UIElements["NotifyPosX"].Obj:Set(Library.Flags.NotifyPosX)
end
if Library.UIElements["NotifyPosY"] and Library.UIElements["NotifyPosY"].Obj then
Library.UIElements["NotifyPosY"].Obj:Set(Library.Flags.NotifyPosY)
end
if Library.UIElements["NotifySortOrder"] and Library.UIElements["NotifySortOrder"].Obj then
Library.UIElements["NotifySortOrder"].Obj:Set(Library.Flags.NotifySortOrder)
end

if Library.UIElements["KeybindTransparency"] and Library.UIElements["KeybindTransparency"].Obj then
    Library.UIElements["KeybindTransparency"].Obj:Set(Library.Flags.KeybindTransparency)
end

Library.Notify(Library,"Loaded theme: " .. Nm, 3);
end;
end;
});
ThemeLoadRefreshRow:Button({
Name = "Refresh";
Callback = function()
ThemeList:SetOptions(ListThemes());
Library.Notify(Library,"Refreshed themes", 2);
end;
});
local ThemeAutoLoadRow = SecTheme:Row({ Height = 21 });
ThemeAutoLoadRow:Button({
Name = "Set Auto Load";
Callback = function()
writefile(Library.Directory .. "/AutoloadTheme.txt", ThemeList:Get());
Library.Notify(Library,"Auto-load theme: " .. ThemeList:Get(), 3);
end;
});
ThemeAutoLoadRow:Button({
Name = "Remove Auto Load"; Confirm = true;
Callback = function()
if isfile and isfile(Library.Directory .. "/AutoloadTheme.txt") then writefile(Library.Directory .. "/AutoloadTheme.txt", "") end;
Library.Notify(Library,"Auto-load theme cleared", 3);
end;
});

local SecNotify = self:Section({ Name = "Notifications", Side = "Left" });
local QueueToggle = SecNotify:Toggle({
Name     = "Queue System", Flag = "QueueSystem", Default = false;
Callback = function(S) 
Library._NotifyMaxHeight = S and 300 or math.huge
end;
});
SecNotify:Slider({
Name = "Max Height"; Flag = "NotifyMaxHeight";
Min = 100, Max = 500, Step = 10, Default = 300;
Callback = function(V) 
Library._NotifyMaxHeight = V
end;
Dependency = QueueToggle;
});
SecNotify:Slider({
Name = "Transparency"; Flag = "NotifyTransparency";
Min = 0, Max = 100, Step = 1, Default = 50;
Callback = function(V) 
Library._NotifyTransparency = V / 100
end;
});
SecNotify:Button({
Name = "Test Notification";
Callback = function()
Library.Notify(Library,'Hello there', 4);
end;
});

return self;
end;

return TabRef;
end;
self.CurrentlyOpen = Window;

Window.Visible = true;
Window._FadeToken = 0;
Window._FadeOriginals = nil;
local FadeProps = {
Frame          = { "BackgroundTransparency" };
TextLabel      = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
TextButton     = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
TextBox        = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" };
ImageLabel     = { "BackgroundTransparency", "ImageTransparency" };
ImageButton    = { "BackgroundTransparency", "ImageTransparency" };
ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" };
CanvasGroup    = { "BackgroundTransparency", "GroupTransparency" };
UIStroke       = { "Transparency" };
};
local function CaptureOriginals()
local Map = {};
for _, Inst in Outer:GetDescendants() do
local Props = FadeProps[Inst.ClassName];
if Props then
local PMap = {};
for _, P in Props do
local Ok, V = pcall(function() return Inst[P] end);
if Ok then PMap[P] = V end;
end;
Map[Inst] = PMap;
end;
end;
local OuterProps = FadeProps[Outer.ClassName];
if OuterProps then
local PMap = {};
for _, P in OuterProps do
local Ok, V = pcall(function() return Outer[P] end);
if Ok then PMap[P] = V end;
end;
Map[Outer] = PMap;
end;
return Map;
end;
function Window:SetVisible(State)
if self.Visible == State then return end;
self.Visible = State and true or false;
self._FadeToken = self._FadeToken + 1;
local Mine = self._FadeToken;
if not self._FadeOriginals then
self._FadeOriginals = CaptureOriginals();
end;
local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
if self.Visible then
Gui.Enabled = true;
if self.MobileToggle then
    self.MobileToggle.Text = "✕";
end
for Inst, PMap in self._FadeOriginals do
if Inst.Parent then
local Goal = {};
for P, V in PMap do Goal[P] = V end;
Library.Tween(Library,Inst, Info, Goal):Play();
end;
end;
else
if self.MobileToggle then
    self.MobileToggle.Text = "☰";
end
for Inst, PMap in self._FadeOriginals do
if Inst.Parent then
local Goal = {};
for P in PMap do Goal[P] = 1 end;
Library.Tween(Library,Inst, Info, Goal):Play();
end;
end;
task.delay(Info.Time, function()
if self._FadeToken == Mine and not self.Visible then
Gui.Enabled = false;
end;
end);
end;
end;
function Window:Toggle()
self:SetVisible(not self.Visible);
end;

function Window:Destroy()
if self.MobileToggle then
    self.MobileToggle:Destroy();
end
Gui:Destroy();
if Library.CurrentlyOpen == self then Library.CurrentlyOpen = nil end;
end;

return Window;
end

function Library.KeybindList(self, Opts) 
Opts = typeof(Opts) == "table" and Opts or {};
local Title = tostring(Opts.Title or Opts.Text or "Keybinds");
local Width = tonumber(Opts.Width) or 170;

local Gui = self.CreateInstance(self,"ScreenGui", {
Name           = "KeybindList";
Parent         = (gethui and gethui()) or Services.CoreGui;
IgnoreGuiInset = true;
ResetOnSpawn   = false;
ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
});

local Frame = self.CreateInstance(self,"Frame", {
Name             = "Keybinds";
Parent           = Gui;
AnchorPoint      = Vector2.new(1, 0);
Position         = UDim2.new(1, -10, 0, 210);
Size             = UDim2.new(0, Width, 0, 0);
AutomaticSize    = Enum.AutomaticSize.Y;
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIGradient", {
Parent   = Frame;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
NewColorSequenceKeypoint(1, Color3.fromHex("141414"));
});
});

local function Edge(Anchor, Pos, Sz, Color)
self.CreateInstance(self,"Frame", {
Parent           = Frame;
AnchorPoint      = Anchor;
Position         = Pos;
Size             = Sz;
BackgroundColor3 = Color3.fromHex(Color);
BorderSizePixel  = 0;
ZIndex           = 5;
});
end;
Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(1, 0, 0, 1),  "000000"); 
local TopLine = self.CreateInstance(self,"Frame", {
Name             = "TopLine";
Parent           = Frame;
Position         = UDim2.new(0, 0, 0, 1);
Size             = UDim2.new(1, 0, 0, 1);
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
ZIndex           = 5;
});
local TopGrad = self.CreateInstance(self,"UIGradient", { Parent = TopLine; Rotation = 0 });
Library.RegisterAccentGradient(Library,TopGrad);
Edge(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0),  UDim2.new(1, 0, 0, 1),  "000000");
Edge(Vector2.new(0, 1), UDim2.new(0, 1, 1, -1), UDim2.new(1, -2, 0, 1), "393939");
Edge(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000");
Edge(Vector2.new(0, 0), UDim2.new(0, 1, 0, 2),  UDim2.new(0, 1, 1, -3), "393939");
Edge(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0),  UDim2.new(0, 1, 1, 0),  "000000");
Edge(Vector2.new(1, 0), UDim2.new(1, -1, 0, 2), UDim2.new(0, 1, 1, -3), "393939");

local Inner = self.CreateInstance(self,"Frame", {
Name                   = "Inner";
Parent                 = Frame;
Position               = UDim2.new(0, 8, 0, 6);
Size                   = UDim2.new(1, -16, 0, 0);
AutomaticSize          = Enum.AutomaticSize.Y;
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
self.CreateInstance(self,"UIListLayout", {
Parent        = Inner;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 2);
});
self.CreateInstance(self,"UIPadding", {
Parent        = Inner;
PaddingBottom = UDim.new(0, 8);
});

local TitleLbl = self.CreateInstance(self,"TextLabel", {
Name                   = "Title";
Parent                 = Inner;
Position               = UDim2.new(0, -1, 0, 0);
Size                   = UDim2.new(1, 0, 0, 13);
BackgroundTransparency = 1;
Text                   = Title;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
LayoutOrder            = 1;
});
if ProggyCleanFont then TitleLbl.FontFace = ProggyCleanFont end;

local Entries = self.CreateInstance(self,"Frame", {
Name                   = "Entries";
Parent                 = Inner;
Size                   = UDim2.new(1, 0, 0, 0);
AutomaticSize          = Enum.AutomaticSize.Y;
BackgroundTransparency = 1;
BorderSizePixel        = 0;
LayoutOrder            = 2;
});
self.CreateInstance(self,"UIListLayout", {
Parent        = Entries;
FillDirection = Enum.FillDirection.Vertical;
SortOrder     = Enum.SortOrder.LayoutOrder;
Padding       = UDim.new(0, 2);
});
self.CreateInstance(self,"UIPadding", {
Parent     = Entries;
PaddingTop = UDim.new(0, 5);
});

self:Draggable(Frame);

local function KeyName(Key)
if Key == nil then return "None" end;
if typeof(Key) == "EnumItem" then return Library.KeyNames[Key] or Key.Name end;
return tostring(Key);
end;

local Rows = {};
local function Rebuild()
for _, R in Rows do R:Destroy() end;
table.clear(Rows);
for I, Entry in Library.Keybinds do
local Key = Entry.GetKey and Entry.GetKey() or nil;
if Key ~= nil then
local Row = Library.CreateInstance(Library,"Frame", {
Name                   = "Entry";
Parent                 = Entries;
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Size                   = UDim2.new(1, 0, 0, 13);
LayoutOrder            = I;
});
local DisplayName = tostring(Entry.Name or "?");
local NameLbl = Library.CreateInstance(Library,"TextLabel", {
Parent                 = Row;
AnchorPoint            = Vector2.new(0, 0.5);
Position               = UDim2.new(0, 0, 0.5, 0);
Size                   = UDim2.new(1, -50, 1, 0);
BackgroundTransparency = 1;
Text                   = DisplayName;
RichText               = true;
TextColor3             = Color3.fromHex("BFC4CC");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
local KeyLbl = Library.CreateInstance(Library,"TextLabel", {
Parent                 = Row;
AnchorPoint            = Vector2.new(1, 0.5);
Position               = UDim2.new(1, 0, 0.5, 0);
Size                   = UDim2.new(0, 46, 1, 0);
BackgroundTransparency = 1;
Text                   = KeyName(Key);
TextColor3             = Library.Accent;
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Right;
TextYAlignment         = Enum.TextYAlignment.Center;
});
Library.RegisterAccent(Library,KeyLbl, "TextColor3");
if ProggyCleanFont then
NameLbl.FontFace = ProggyCleanFont;
KeyLbl.FontFace  = ProggyCleanFont;
end;
table.insert(Rows, Row);
end;
end;
end;
Library.OnKeybindChange(Library,Rebuild);

local Obj = { Gui = Gui, Frame = Frame, TitleLabel = TitleLbl };
function Obj:Refresh() Rebuild() end;
function Obj:SetTitle(NewTitle) TitleLbl.Text = string.upper(tostring(NewTitle)) end;
function Obj:Destroy() Gui:Destroy() end;
Library._KeybindList = Obj;
return Obj;
end

function Library.Watermark(self, Opts) 
Opts = typeof(Opts) == "table" and Opts or {};
local Text = tostring(Opts.Text or Opts.Title or "Networph");

local Gui = self.CreateInstance(self,"ScreenGui", {
Name = "Watermark";
Parent = (gethui and gethui()) or Services.CoreGui;
IgnoreGuiInset = true;
ResetOnSpawn = false;
ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
});

local Frame = self.CreateInstance(self,"Frame", {
Name             = "Watermark";
Parent           = Gui;
AnchorPoint      = Vector2.new(0, 0);
Position         = UDim2.fromOffset(10, 110);
Size             = UDim2.new(0, 0, 0, 24);
AutomaticSize    = Enum.AutomaticSize.X;
BackgroundColor3 = Color3.fromHex("000000");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIPadding", {
Parent        = Frame;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});

local Gray = self.CreateInstance(self,"Frame", {
Name             = "Gray";
Parent           = Frame;
Size             = UDim2.new(0, 0, 1, 0);
AutomaticSize    = Enum.AutomaticSize.X;
BackgroundColor3 = Color3.fromHex("393939");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIPadding", {
Parent        = Gray;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});

local GradRing = self.CreateInstance(self,"Frame", {
Name             = "GradientRing";
Parent           = Gray;
Size             = UDim2.new(0, 0, 1, 0);
AutomaticSize    = Enum.AutomaticSize.X;
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
local RingGradient = self.CreateInstance(self,"UIGradient", {
Parent   = GradRing;
Rotation = 0;
});
Library.RegisterAccentGradient(Library,RingGradient);
self.CreateInstance(self,"UIPadding", {
Parent        = GradRing;
PaddingLeft   = UDim.new(0, 1);
PaddingRight  = UDim.new(0, 1);
PaddingTop    = UDim.new(0, 1);
PaddingBottom = UDim.new(0, 1);
});

local Inside = self.CreateInstance(self,"Frame", {
Name             = "Inside";
Parent           = GradRing;
Size             = UDim2.new(0, 0, 1, 0);
AutomaticSize    = Enum.AutomaticSize.X;
BackgroundColor3 = Color3.fromHex("FFFFFF");
BorderSizePixel  = 0;
});
self.CreateInstance(self,"UIGradient", {
Parent   = Inside;
Rotation = 90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("1F1F1F"));
NewColorSequenceKeypoint(1, Color3.fromHex("181818"));
});
});
self.CreateInstance(self,"UIPadding", {
Parent       = Inside;
PaddingLeft  = UDim.new(0, 10);
PaddingRight = UDim.new(0, 10);
});

local Lbl = self.CreateInstance(self,"TextLabel", {
Name                   = "Label";
Parent                 = Inside;
AnchorPoint            = Vector2.new(0, 0.5);
Position               = UDim2.new(0, 0, 0.5, 0);
Size                   = UDim2.new(0, 0, 1, 0);
AutomaticSize          = Enum.AutomaticSize.X;
BackgroundTransparency = 1;
Text                   = Text;
TextColor3             = Color3.fromHex("FFFFFF");
TextSize               = 12;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
});
if ProggyCleanFont then Lbl.FontFace = ProggyCleanFont end;

self:Draggable(Frame);

local Obj = { Gui = Gui, Frame = Frame, Label = Lbl };
function Obj:SetText(NewText) Lbl.Text = tostring(NewText) end;
function Obj:Destroy() Gui:Destroy() end;
Library._Watermark = Obj;
return Obj;
end

function Library.Notify(self, Text, Time) 
Text = tostring(Text or "");
Time = tonumber(Time) or 3;

if not self._NotifyStack then
local Gui = self.CreateInstance(self,"ScreenGui", {
Name           = "Notifications";
Parent         = (gethui and gethui()) or Services.CoreGui;
IgnoreGuiInset = true;
ResetOnSpawn   = false;
ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
});
local Stack = self.CreateInstance(self,"Frame", {
Name                   = "Stack";
Parent                 = Gui;
AnchorPoint            = Vector2.new(0.5, 0);
Position               = UDim2.new(0.5, 0, 0.6, 0);
Size                   = UDim2.new(0, 400, 1, -210);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
});
self.CreateInstance(self,"UIListLayout", {
Parent              = Stack;
FillDirection       = Enum.FillDirection.Vertical;
SortOrder           = Enum.SortOrder.LayoutOrder;
VerticalAlignment   = Enum.VerticalAlignment.Top;
HorizontalAlignment = Enum.HorizontalAlignment.Center;
Padding             = UDim.new(0, 6);
});
self.CreateInstance(self,"UISizeConstraint", {
Parent           = Stack;
MaxSize          = Vector2.new(400, 300);
MinSize          = Vector2.new(0, 0);
});
self._NotifyGui   = Gui;
self._NotifyStack = Stack;
self._NotifyOrder = 0;
self._NotifyQueue = {};
self._NotifyMaxHeight = 300;
end;

self._NotifyOrder = self._NotifyOrder + 1;

local function GetStackHeight()
local totalHeight = 0
for _, child in ipairs(self._NotifyStack:GetChildren()) do
if child:IsA("GuiObject") then
totalHeight = totalHeight + child.AbsoluteSize.Y + 6 
end
end
return totalHeight
end

local currentHeight = GetStackHeight()
if currentHeight >= self._NotifyMaxHeight then
table.insert(self._NotifyQueue, {Text = Text, Time = Time})
return
end

local H = 22;
local TextService = Services.TextService;
local TextBounds = TextService:GetTextSize(Text, 13, Enum.Font.Code, Vector2.new(1000, 100));
local xw = TextBounds.X + 16;

local Camera = Services.Camera;
if Camera then
local ViewportSize = Camera.ViewportSize;
local MaxWidth = math.min(xw, ViewportSize.X - 40);
xw = MaxWidth;
end

local Outer = self.CreateInstance(self,"Frame", {
Name                   = "Notification";
Parent                 = self._NotifyStack;
Size                   = UDim2.fromOffset(0, H);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
ClipsDescendants       = true;
LayoutOrder            = self._NotifyOrder;
ZIndex                 = 100;
});

local Inner = self.CreateInstance(self,"Frame", {
Name                   = "Inner";
Parent                 = Outer;
Size                   = UDim2.new(1, 0, 1, 0);
BackgroundColor3       = Color3.fromHex("262626");
BackgroundTransparency = Library._NotifyTransparency or 0.3;
BorderSizePixel        = 0;
ZIndex                 = 101;
});

self.CreateInstance(self,"UISizeConstraint", {
Parent           = Outer;
MaxSize          = Vector2.new(400, 100);
MinSize          = Vector2.new(0, 0);
});

self.CreateInstance(self,"UIStroke", {
Parent    = Inner;
Color     = Color3.fromHex("393939");
Thickness = 1;
});

local GradientFrame = self.CreateInstance(self,"Frame", {
Name                   = "GradientFrame";
Parent                 = Inner;
Position               = UDim2.new(0, 1, 0, 1);
Size                   = UDim2.new(1, -2, 1, -2);
BackgroundColor3       = Color3.fromHex("262626");
BackgroundTransparency = Library._NotifyTransparency or 0.3;
BorderSizePixel        = 0;
ZIndex                 = 102;
});

self.CreateInstance(self,"UIGradient", {
Parent   = GradientFrame;
Rotation = -90;
Color    = NewColorSequence({
NewColorSequenceKeypoint(0, Color3.fromHex("191919"));
NewColorSequenceKeypoint(1, Color3.fromHex("262626"));
});
});

local Title = self.CreateInstance(self,"TextLabel", {
Name                   = "Title";
Parent                 = GradientFrame;
Position               = UDim2.new(0, 8, 0, 0);
Size                   = UDim2.new(1, -8, 1, 0);
BackgroundTransparency = 1;
BorderSizePixel        = 0;
Text                   = Text;
TextColor3             = Color3.fromHex("A0A0A0");
TextSize               = 13;
TextXAlignment         = Enum.TextXAlignment.Left;
TextYAlignment         = Enum.TextYAlignment.Center;
RichText               = true;
ZIndex                 = 103;
});
if ProggyCleanFont then Title.FontFace = ProggyCleanFont end;

local Accent = self.CreateInstance(self,"Frame", {
Name                   = "Accent";
Parent                 = Outer;
Position               = UDim2.new(0, -1, 1, -2);
Size                   = UDim2.new(1, 2, 0, 1);
BackgroundColor3       = Library.Accent;
BorderSizePixel        = 0;
ZIndex                 = 104;
});
Library.RegisterAccent(Library,Accent);

pcall(function() Outer:TweenSize(UDim2.fromOffset(xw, H), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.35, true) end);

task.spawn(function()
task.wait(Time or 5);
pcall(function() Outer:TweenSize(UDim2.fromOffset(0, H), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.35, true) end);
task.wait(0.2);
if Outer and Outer.Parent then Outer:Destroy() end;

task.wait(0.1)
if #self._NotifyQueue > 0 then
local queued = table.remove(self._NotifyQueue, 1)
if queued then
self:Notify(queued.Text, queued.Time)
end
end
end);

return Outer;
end

function Library.Unload(self) 
self.Log(self, "Unload requested");
for _, Conn in self.Connections do
if Conn ~= nil then
Conn:Disconnect();
end;
end;
self.Connections = {};

local Win = self.CurrentlyOpen;
if typeof(Win) == "table" and typeof(Win.Gui) == "Instance" and Win.Gui.Parent then
Win.Gui:Destroy();
end;
self.CurrentlyOpen = nil;

self.Flags = {};
self.Toggles = {};
self.Options = {};
self.Log(self, "Unload complete");
end

return Library

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local G = getgenv()

G.Job = G.Job or ""
G.SpamJoin = G.SpamJoin or false
G.UsernamesNoSpam = G.UsernamesNoSpam or { "username1", "username2" }

pcall(function()
	if plr.PlayerGui:FindFirstChild("MoonChecker") then plr.PlayerGui.MoonChecker:Destroy() end
end)
pcall(function()
	if game.CoreGui:FindFirstChild("JobIdGui") then game.CoreGui.JobIdGui:Destroy() end
end)

function TPServer(j)
	if string.find(tostring(j), "TeleportService") then
		local ok, err = pcall(function() loadstring(j)() end)
		return ok and "Success | Teleporting..." or err
	else
		pcall(function()
			ReplicatedStorage:WaitForChild("__ServerBrowser"):InvokeServer("teleport", tostring(j))
		end)
		return "Trying to teleport..."
	end
end

local function IsNoSpamUser()
	for _, n in ipairs(G.UsernamesNoSpam) do
		if tostring(n):lower() == plr.Name:lower() then return true end
	end
	return false
end

local function GetServerTime()
	local t = tostring(Lighting.ClockTime):split(".")
	return t[1] or "0", math.floor(((tonumber(t[2]) or 0) / 100) * 60)
end

local function MoonTextureId()
	local s = Lighting:FindFirstChildOfClass("Sky")
	return (s and s.MoonTextureId) or ""
end

local function CheckMoon()
	local id = MoonTextureId()
	if id == "http://www.roblox.com/asset/?id=9709149431" then return "Full Moon"
	elseif id == "http://www.roblox.com/asset/?id=9709149052" then return "Next Night"
	else return "Bad Moon" end
end

local function mmbs(a, b)
	local d = a - b
	return d > 1 and math.floor(d).." min" or math.floor(d*60).." sec"
end

local function GetMoonStatus()
	local c = Lighting.ClockTime
	local moon = CheckMoon()
	if moon == "Full Moon" then
		if c <= 5 then return "ends in "..mmbs(5,c)
		elseif c < 12 then return "Fake Moon"
		elseif c < 18 then return "Full In "..mmbs(18,c)
		else return "Ends In "..mmbs(30,c) end
	elseif moon == "Next Night" then
		if c < 12 then return "Full In "..mmbs(18,c)
		else return "full in "..mmbs(42,c) end
	end
	return "No Moon"
end

local function Tween(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		props
	):Play()
end

local C = {
	black  = Color3.fromRGB(0,   0,   0),
	dark   = Color3.fromRGB(12,  12,  12),
	card   = Color3.fromRGB(20,  20,  20),
	raised = Color3.fromRGB(28,  28,  28),
	line   = Color3.fromRGB(38,  38,  38),
	muted  = Color3.fromRGB(85,  85,  85),
	silver = Color3.fromRGB(155, 155, 155),
	white  = Color3.fromRGB(232, 232, 232),
	green  = Color3.fromRGB(30,  100, 50),
	red    = Color3.fromRGB(100, 28,  28),
}

local function New(cls, p, parent)
	local o = Instance.new(cls)
	for k,v in pairs(p) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function Corner(r, p)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r); c.Parent = p
end

local function Stroke(col, p)
	local s = Instance.new("UIStroke"); s.Thickness = 1; s.Color = col or C.line; s.Parent = p
end

local function Div(y, parent)
	New("Frame", {
		Size = UDim2.new(1,-20,0,1), Position = UDim2.new(0,10,0,y),
		BackgroundColor3 = C.line, BorderSizePixel = 0, ZIndex = 10,
	}, parent)
end

local function MakeDraggable(handle, target)
	local drag, ds, sp = false, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true; ds = i.Position; sp = target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - ds
			target.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
		end
	end)
end

local mainGui = New("ScreenGui", {
	Name = "JobIdGui", ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, game.CoreGui)

local iconBtn = New("TextButton", {
	Size = UDim2.new(0, 36, 0, 36),
	Position = UDim2.new(1, -50, 0, 14),
	BackgroundColor3 = C.dark,
	Text = "≡",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = C.silver,
	AutoButtonColor = false,
	ZIndex = 12,
}, mainGui)
Corner(10, iconBtn)
Stroke(C.line, iconBtn)

iconBtn.MouseEnter:Connect(function() Tween(iconBtn,{TextColor3=C.white},0.15) end)
iconBtn.MouseLeave:Connect(function() Tween(iconBtn,{TextColor3=C.silver},0.15) end)

local PANEL_W = 260
local PANEL_H = 330

local panel = New("Frame", {
	Size = UDim2.new(0, PANEL_W, 0, PANEL_H),
	Position = UDim2.new(1, -(PANEL_W+14), 0, 58),
	BackgroundColor3 = C.dark,
	ClipsDescendants = true,
	ZIndex = 9,
	Visible = false,
}, mainGui)
Corner(12, panel)
Stroke(C.line, panel)
MakeDraggable(panel, panel)

New("Frame", {
	Size = UDim2.new(0,28,0,2), Position = UDim2.new(0,14,0,0),
	BackgroundColor3 = C.white, BorderSizePixel=0, ZIndex=11,
}, panel)

New("TextLabel", {
	Size=UDim2.new(1,-14,0,28), Position=UDim2.new(0,14,0,6),
	BackgroundTransparency=1, Text="Moon Tracker",
	Font=Enum.Font.GothamBold, TextSize=9,
	TextColor3=C.muted, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
}, panel)

Div(34, panel)

local moonRows = {
	{key="time",    lbl="Time"},
	{key="moon",    lbl="Moon"},
	{key="status",  lbl="Status"},
	{key="players", lbl="Players"},
}
local moonVals = {}
for i, row in ipairs(moonRows) do
	local y = 38 + (i-1)*30
	New("TextLabel", {
		Size=UDim2.new(0,60,0,24), Position=UDim2.new(0,14,0,y),
		BackgroundTransparency=1, Text=row.lbl,
		Font=Enum.Font.GothamBold, TextSize=9,
		TextColor3=C.muted, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
	}, panel)
	moonVals[row.key] = New("TextLabel", {
		Size=UDim2.new(1,-80,0,24), Position=UDim2.new(0,76,0,y),
		BackgroundTransparency=1, Text="—",
		Font=Enum.Font.GothamBold, TextSize=11,
		TextColor3=C.white, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=10,
	}, panel)
	New("UIPadding",{PaddingRight=UDim.new(0,14)}, moonVals[row.key])
end

local MOON_END = 38 + #moonRows*30 + 6

Div(MOON_END, panel)

local SH = MOON_END + 4

New("TextLabel", {
	Size=UDim2.new(1,-14,0,26), Position=UDim2.new(0,14,0,SH),
	BackgroundTransparency=1, Text="Server Hop",
	Font=Enum.Font.GothamBold, TextSize=9,
	TextColor3=C.muted, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
}, panel)

New("TextLabel", {
	Size=UDim2.new(0,46,0,24), Position=UDim2.new(0,14,0,SH+26),
	BackgroundTransparency=1, Text="Job Id",
	Font=Enum.Font.GothamBold, TextSize=9,
	TextColor3=C.muted, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
}, panel)
New("TextLabel", {
	Size=UDim2.new(1,-140,0,24), Position=UDim2.new(0,62,0,SH+26),
	BackgroundTransparency=1,
	Text=string.sub(tostring(game.JobId),1,14).."…",
	Font=Enum.Font.Gotham, TextSize=10,
	TextColor3=C.silver, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
}, panel)

local copyBtn = New("TextButton", {
	Size=UDim2.new(0,54,0,20), Position=UDim2.new(1,-66,0,SH+29),
	BackgroundColor3=C.raised, Text="Copy",
	Font=Enum.Font.GothamBold, TextSize=9,
	TextColor3=C.white, AutoButtonColor=false, ZIndex=11,
}, panel)
Corner(6,copyBtn); Stroke(C.line,copyBtn)
copyBtn.MouseButton1Click:Connect(function()
	pcall(function() setclipboard(tostring(game.JobId)) end)
	copyBtn.Text="✓"; task.wait(1.5); copyBtn.Text="Copy"
end)

local inputBox = New("TextBox", {
	Size=UDim2.new(1,-20,0,32), Position=UDim2.new(0,10,0,SH+56),
	BackgroundColor3=C.raised,
	PlaceholderText="  Job ID / Teleport String",
	PlaceholderColor3=C.muted,
	Text=G.Job,
	Font=Enum.Font.Gotham, TextSize=11,
	TextColor3=C.white, ClearTextOnFocus=false, ZIndex=10,
}, panel)
Corner(8,inputBox); Stroke(C.line,inputBox)
New("UIPadding",{PaddingLeft=UDim.new(0,10)}, inputBox)
inputBox.FocusLost:Connect(function() G.Job = inputBox.Text end)

local spamCurrentColor = IsNoSpamUser() and C.raised or C.red

local function MkBtn(lbl, xScale, xOff, bg)
	local b = New("TextButton", {
		Size=UDim2.new(0.47,0,0,28), Position=UDim2.new(xScale,xOff,0,SH+96),
		BackgroundColor3=bg, Text=lbl,
		Font=Enum.Font.GothamBold, TextSize=10,
		TextColor3=C.white, AutoButtonColor=false, ZIndex=10,
	}, panel)
	Corner(8,b); Stroke(C.line,b)
	return b
end

local joinBtn = MkBtn("Join", 0, 10, C.raised)
local spamBtn = MkBtn(IsNoSpamUser() and "SPAM · LOCK" or "SPAM · OFF", 0.5, 5, spamCurrentColor)

joinBtn.MouseEnter:Connect(function() Tween(joinBtn,{BackgroundColor3=C.raised:Lerp(C.white,0.1)},0.15) end)
joinBtn.MouseLeave:Connect(function() Tween(joinBtn,{BackgroundColor3=C.raised},0.15) end)

spamBtn.MouseEnter:Connect(function()
	Tween(spamBtn,{BackgroundColor3=spamCurrentColor:Lerp(C.white,0.15)},0.15)
end)
spamBtn.MouseLeave:Connect(function()
	Tween(spamBtn,{BackgroundColor3=spamCurrentColor},0.15)
end)

local statusLbl = New("TextLabel", {
	Size=UDim2.new(1,-20,0,18), Position=UDim2.new(0,14,0,SH+130),
	BackgroundTransparency=1, Text="",
	Font=Enum.Font.Gotham, TextSize=9,
	TextColor3=C.muted, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10,
}, panel)

local function SetStatus(msg, col)
	statusLbl.Text="▸  "..msg; statusLbl.TextColor3=col or C.muted
	task.delay(3,function() if statusLbl.Text:find(msg,1,true) then statusLbl.Text="" end end)
end

joinBtn.MouseButton1Click:Connect(function()
	G.Job=inputBox.Text
	if G.Job~="" then SetStatus(TPServer(G.Job),C.silver)
	else SetStatus("enter a job id first",C.muted) end
end)

spamBtn.MouseButton1Click:Connect(function()
	if IsNoSpamUser() then return end
	G.Job=inputBox.Text; G.SpamJoin=not G.SpamJoin
	if G.SpamJoin then
		spamBtn.Text="SPAM · ON"
		spamCurrentColor = C.green
	else
		spamBtn.Text="SPAM · OFF"
		spamCurrentColor = C.red
	end
	Tween(spamBtn,{BackgroundColor3=spamCurrentColor},0.2)
end)

task.spawn(function()
	while task.wait(2) do
		if not IsNoSpamUser() and G.SpamJoin and G.Job~="" then
			pcall(function() TPServer(G.Job) end)
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		local h, s = GetServerTime()
		local moon   = CheckMoon()
		local status = GetMoonStatus()
		local dotCol = moon=="Full Moon" and C.white or moon=="Next Night" and C.silver or C.muted

		moonVals.time.Text    = h..":"..string.format("%02d",s)
		moonVals.moon.Text    = moon
		moonVals.status.Text  = status
		moonVals.players.Text = tostring(#Players:GetPlayers())
		moonVals.moon.TextColor3   = dotCol
		moonVals.status.TextColor3 = dotCol
	end
end)

local panelOpen = false

local function OpenPanel()
	panelOpen = true
	panel.Visible = true
	panel.Size = UDim2.new(0,PANEL_W,0,0)
	Tween(panel,{Size=UDim2.new(0,PANEL_W,0,PANEL_H)},0.3)
end

local function ClosePanel()
	panelOpen = false
	Tween(panel,{Size=UDim2.new(0,PANEL_W,0,0)},0.22)
	task.delay(0.23,function() panel.Visible=false end)
end

local function Toggle()
	if panelOpen then ClosePanel() else OpenPanel() end
end

iconBtn.MouseButton1Click:Connect(Toggle)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightAlt then Toggle() end
end)

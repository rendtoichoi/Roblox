local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer

_G.Job = ""
_G.SpamJoin = true

pcall(function()
	if plr.PlayerGui:FindFirstChild("MoonChecker") then
		plr.PlayerGui.MoonChecker:Destroy()
	end
end)

pcall(function()
	if game.CoreGui:FindFirstChild("JobIdGui") then
		game.CoreGui.JobIdGui:Destroy()
	end
end)

local MoonGui = Instance.new("ScreenGui")
MoonGui.Name = "MoonChecker"
MoonGui.ResetOnSpawn = false
MoonGui.Parent = plr:WaitForChild("PlayerGui")

local MainText = Instance.new("TextLabel")
MainText.Parent = MoonGui
MainText.Size = UDim2.new(0, 400, 0, 100)
MainText.AnchorPoint = Vector2.new(0.5, 0)
MainText.Position = UDim2.new(0.5, 0, 0, -10)

MainText.BackgroundTransparency = 1
MainText.TextColor3 = Color3.fromRGB(255,255,255)
MainText.TextStrokeTransparency = 0
MainText.TextScaled = true
MainText.Font = Enum.Font.SourceSansBold
MainText.Text = "Loading..."
MainText.TextXAlignment = Enum.TextXAlignment.Center
MainText.TextYAlignment = Enum.TextYAlignment.Center

local function GetGameTime()
	local c2 = Lighting.ClockTime
	if c2 >= 18 or c2 < 5 then
		return "Night"
	else
		return "Day"
	end
end

local function GetHour()
	return math.floor(Lighting.ClockTime)
end

local function GetServerTime()
	local RealTime = tostring(Lighting.ClockTime)
	local RealTimeTable = RealTime:split(".")

	local Minute = RealTimeTable[1] or "0"
	local decimalPart = tonumber(RealTimeTable[2]) or 0
	local Second = tonumber(decimalPart / 100) * 60

	return Minute, math.floor(Second)
end

local function MoonTextureId()
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky and sky.MoonTextureId then
		return sky.MoonTextureId
	end
	return ""
end

local function CheckMoon()
	local moon5 = "http://www.roblox.com/asset/?id=9709149431"
	local moon4 = "http://www.roblox.com/asset/?id=9709149052"

	local moonreal = MoonTextureId()
	local result = "Bad Moon"

	if moonreal == moon5 then
		result = "Full Moon"
	elseif moonreal == moon4 then
		result = "Next Night"
	end

	return result
end

local function mmbs(inp, c2)
	local ps = inp - c2
	if ps > 1 then
		return math.floor(ps) .. " Minutes"
	else
		return math.floor(ps * 60) .. " Seconds"
	end
end

local function GetMoonStatus()
	local c2 = Lighting.ClockTime
	local moon = CheckMoon()

	if moon == "Full Moon" and c2 <= 5 then
		return tostring(GetHour()).." (End in "..mmbs(5,c2)..")"

	elseif moon == "Full Moon" and (c2 > 5 and c2 < 12) then
		return tostring(GetHour()).." (Fake Moon)"

	elseif moon == "Full Moon" and (c2 > 12 and c2 < 18) then
		return tostring(GetHour()).." (Full in "..mmbs(18,c2)..")"

	elseif moon == "Full Moon" and (c2 > 18 and c2 <= 24) then
		return tostring(GetHour()).." (End in "..mmbs(30,c2)..")"
	end

	if moon == "Next Night" and c2 < 12 then
		return tostring(GetHour()).." (Full in "..mmbs(18,c2)..")"

	elseif moon == "Next Night" and c2 > 12 then
		return tostring(GetHour()).." (Full in "..mmbs(18+24,c2)..")"
	end

	return tostring(GetHour())
end

task.spawn(function()
	while task.wait(1) do
		local h, s = GetServerTime()
		local moon = CheckMoon()
		local status = GetMoonStatus()

		MainText.Text =
			"Time: "..h..":"..string.format("%02d", s)
			.."\nMoon: "..moon
			.."\nStatus: "..status

		if moon == "Full Moon" then
			MainText.TextColor3 = Color3.fromRGB(0,255,127)
		elseif moon == "Next Night" then
			MainText.TextColor3 = Color3.fromRGB(255,170,0)
		else
			MainText.TextColor3 = Color3.fromRGB(255,80,80)
		end
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "JobIdGui"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,150)
frame.Position = UDim2.new(1,-270,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui
Instance.new("UICorner",frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,25)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "Server JobId"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0,25,0,25)
mini.Position = UDim2.new(1,-25,0,0)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(60,60,60)
mini.TextColor3 = Color3.new(1,1,1)
mini.Parent = frame

local content = Instance.new("Frame")
content.Size = UDim2.new(1,0,1,-25)
content.Position = UDim2.new(0,0,0,25)
content.BackgroundTransparency = 1
content.Parent = frame

local jobLabel = Instance.new("TextLabel")
jobLabel.Size = UDim2.new(1,-10,0,25)
jobLabel.Position = UDim2.new(0,5,0,5)
jobLabel.BackgroundTransparency = 1
jobLabel.TextColor3 = Color3.new(1,1,1)
jobLabel.TextScaled = true
jobLabel.Text = "Job ID: "..game.JobId
jobLabel.Parent = content

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1,-10,0,25)
copyBtn.Position = UDim2.new(0,5,0,35)
copyBtn.Text = "Copy Job ID"
copyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Parent = content
Instance.new("UICorner",copyBtn)

copyBtn.MouseButton1Click:Connect(function()
	pcall(function()
		setclipboard(tostring(game.JobId))
	end)
end)

local box = Instance.new("TextBox")
box.Size = UDim2.new(1,-10,0,25)
box.Position = UDim2.new(0,5,0,65)
box.PlaceholderText = "Enter Job ID"
box.Text = ""
box.BackgroundColor3 = Color3.fromRGB(50,50,50)
box.TextColor3 = Color3.new(1,1,1)
box.Parent = content
Instance.new("UICorner",box)

box.FocusLost:Connect(function()
	_G.Job = box.Text
end)

local joinBtn = Instance.new("TextButton")
joinBtn.Size = UDim2.new(0.48,-5,0,25)
joinBtn.Position = UDim2.new(0,5,0,100)
joinBtn.Text = "Join Server"
joinBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
joinBtn.TextColor3 = Color3.new(1,1,1)
joinBtn.Parent = content
Instance.new("UICorner",joinBtn)

joinBtn.MouseButton1Click:Connect(function()
	_G.Job = box.Text

	if _G.Job ~= "" then
		pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, _G.Job, plr)
		end)
	end
end)

local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(0.48,-5,0,25)
spamBtn.Position = UDim2.new(0.52,0,0,100)
spamBtn.Text = "Spam : OFF"
spamBtn.BackgroundColor3 = Color3.fromRGB(90,50,50)
spamBtn.TextColor3 = Color3.new(1,1,1)
spamBtn.Parent = content
Instance.new("UICorner",spamBtn)

spamBtn.MouseButton1Click:Connect(function()
	_G.Job = box.Text
	_G.SpamJoin = not _G.SpamJoin

	if _G.SpamJoin then
		spamBtn.Text = "Spam : ON"
		spamBtn.BackgroundColor3 = Color3.fromRGB(50,120,50)
	else
		spamBtn.Text = "Spam : OFF"
		spamBtn.BackgroundColor3 = Color3.fromRGB(90,50,50)
	end
end)

task.spawn(function()
	while task.wait(2) do
		if _G.SpamJoin then
			_G.Job = box.Text

			if _G.Job ~= "" then
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, _G.Job, plr)
				end)
			end
		end
	end
end)

local minimized = false

mini.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		content.Visible = false
		frame.Size = UDim2.new(0,260,0,25)
		mini.Text = "+"
	else
		content.Visible = true
		frame.Size = UDim2.new(0,260,0,150)
		mini.Text = "-"
	end
end)

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

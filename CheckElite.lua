local Players = game:GetService("Players")
local localplayer = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

if localplayer.PlayerGui:FindFirstChild("EliteHUD") then
    localplayer.PlayerGui.EliteHUD:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EliteHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = localplayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 50)
frame.Position = UDim2.new(0.5, -100, 0, -30)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 18
label.Font = Enum.Font.GothamBold
label.Text = "Elite: Loading..."
label.Parent = frame

task.spawn(function()
    while task.wait(2) do
        local ok, total = pcall(function()
            return rs.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
        end)
        if ok and total then
            label.Text = "Elite: " .. tostring(total) .. " / 30"
            if total >= 30 then
                label.TextColor3 = Color3.fromRGB(0, 255, 100)
            else
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end)

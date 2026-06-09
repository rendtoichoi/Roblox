local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer

repeat task.wait() until plr
repeat task.wait() until ReplicatedStorage:FindFirstChild("Remotes")
repeat task.wait() until ReplicatedStorage.Remotes:FindFirstChild("CommF_")

local CommF = ReplicatedStorage.Remotes.CommF_

local SWORD_CONFIG = {
    SwordName = "Tushita",
    RequiredMastery = 350,
    CheckDelay = 5
}

local function CheckSwordMastery()
    local inventory = CommF:InvokeServer("getInventory")

    if not inventory then
        warn("Không lấy được inventory")
        return false
    end

    for _, item in pairs(inventory) do
        if item.Type == "Sword" then
            local name = tostring(item.Name)
            local mastery = tonumber(item.Mastery) or 0

            print("Sword:", name, "| Mastery:", mastery)

            if name == SWORD_CONFIG.SwordName and mastery >= SWORD_CONFIG.RequiredMastery then
                getgenv().CustomChange = true
                print("Đã đạt yêu cầu:", name, "Mastery", mastery)
                return true
            end
        end
    end

    return false
end

while task.wait(SWORD_CONFIG.CheckDelay) do
    if CheckSwordMastery() then
        print("Sword đủ mastery -> stop loop")
        break
    end
end

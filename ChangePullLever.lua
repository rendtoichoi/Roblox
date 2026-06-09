local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommF = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("CommF_")

local CHECK_EVERY = 1

getgenv().CFG = getgenv().CFG or {}

getgenv().CFG.PullLever = {
    Enabled = true,
    Need = "yes", 
}

local function CheckPullLever()
    local ok, result = pcall(function()
        return CommF:InvokeServer("CheckTempleDoor")
    end)

    if ok and result then
        return "yes"
    end

    return "no"
end

local function checkPullLever()
    local cfg = getgenv().CFG.PullLever

    if not cfg or cfg.Enabled ~= true then
        print("[PULL LEVER] Disabled")
        return false
    end

    local have = CheckPullLever()
    local need = tostring(cfg.Need or "yes")
    local success = have == need

    print(
        string.format(
            "[CHECK PULL LEVER] Have: %s | Need: %s | %s",
            have,
            need,
            success and "YES" or "NO"
        )
    )

    return success
end

while task.wait(CHECK_EVERY) do
    if checkPullLever() then
        getgenv().CustomChange = true
        print("[SUCCESS] Pull Lever đủ điều kiện! CustomChange = true.")
        break
    end
end

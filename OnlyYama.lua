local LocalPlayer = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF_ = ReplicatedStorage.Remotes.CommF_
local Enemies = workspace.Enemies

local config = {
    team = "Pirates"
}

local function joinTeam()
    if LocalPlayer.Team ~= nil then
        return
    end
    repeat
        task.wait()
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if string.find(v.Name, "Main") then
                local TeamButton = v.ChooseTeam.Container[config.team].Frame.TextButton
                TeamButton.Size = UDim2.new(0, 10000, 0, 10000)
                TeamButton.Position = UDim2.new(-4, 0, -5, 0)
                TeamButton.BackgroundTransparency = 1
                task.wait(0.5)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                task.wait(0.05)
            end
        end
    until LocalPlayer.Team ~= nil and game:IsLoaded()
    task.wait(3)
end

task.spawn(joinTeam)

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

local isTweening = false
local tween = nil
local pathPart = nil
local connection = nil
local lastCheckInv = 0
local inventoryScan = {}
local BoneMonsters = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}

local AttackLoaded = false
local RegisterAttack, RegisterHit
local remoteAttack, idremote, seed
local lastAttack = 0
local AttackDistance = 100
local AttackDelay = 0.03

local function GetEncryptedRemote()
    if remoteAttack and idremote then
        return true
    end
    for _, folder in ipairs({
        ReplicatedStorage:FindFirstChild("Util"),
        ReplicatedStorage:FindFirstChild("Common"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Assets"),
        ReplicatedStorage:FindFirstChild("FX")
    }) do
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("RemoteEvent") and obj:GetAttribute("Id") then
                    remoteAttack = obj
                    idremote = obj:GetAttribute("Id")
                    return true
                end
            end
        end
    end
    return false
end

local function RefreshSeed(Net)
    if seed then
        return seed
    end
    pcall(function()
        seed = Net:WaitForChild("seed"):InvokeServer()
    end)
    return seed
end

local function LoadAttack()
    if AttackLoaded then
        return
    end
    AttackLoaded = true
    local Modules = ReplicatedStorage:WaitForChild("Modules")
    local Net = Modules:WaitForChild("Net")
    RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    RegisterHit = Net:WaitForChild("RE/RegisterHit")
    RefreshSeed(Net)
    GetEncryptedRemote()
    task.spawn(function()
        for _, folder in ipairs({
            ReplicatedStorage:FindFirstChild("Util"),
            ReplicatedStorage:FindFirstChild("Common"),
            ReplicatedStorage:FindFirstChild("Remotes"),
            ReplicatedStorage:FindFirstChild("Assets"),
            ReplicatedStorage:FindFirstChild("FX")
        }) do
            if folder then
                folder.ChildAdded:Connect(function(obj)
                    if obj:IsA("RemoteEvent") and obj:GetAttribute("Id") then
                        remoteAttack = obj
                        idremote = obj:GetAttribute("Id")
                    end
                end)
            end
        end
    end)
end

local function EncryptedRegisterHit(hitData)
    local Modules = ReplicatedStorage:FindFirstChild("Modules")
    local Net = Modules and Modules:FindFirstChild("Net")
    if not Net then
        return false
    end
    if not RefreshSeed(Net) then
        return false
    end
    if not GetEncryptedRemote() then
        return false
    end
    pcall(function()
        local encodedName = string.gsub("RE/RegisterHit", ".", function(c)
            return string.char(
                bit32.bxor(
                    string.byte(c),
                    math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1
                )
            )
        end)
        remoteAttack:FireServer(
            encodedName,
            bit32.bxor(idremote + 909090, seed * 2),
            unpack(hitData)
        )
    end)
    return true
end

local function IsTargetName(enemyName, name)
    if not name or name == "" then
        return true
    end
    if typeof(name) == "table" then
        return table.find(name, enemyName) ~= nil
    end
    return enemyName == tostring(name)
end

function FastAttack(name)
    LoadAttack()
    if not RegisterAttack or not RegisterHit then
        return
    end
    if not Character or not Humanoid or Humanoid.Health <= 0 then
        return
    end
    if not Character:FindFirstChildWhichIsA("Tool") then
        return
    end
    if tick() - lastAttack < AttackDelay then
        return
    end
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local targets = {}
    for _, enemy in ipairs(Enemies:GetChildren()) do
        local hum = enemy:FindFirstChild("Humanoid")
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        local head = enemy:FindFirstChild("Head")
        if hum
            and hrp
            and hum.Health > 0
            and IsTargetName(enemy.Name, name)
            and (hrp.Position - root.Position).Magnitude <= AttackDistance
        then
            targets[#targets + 1] = {
                enemy,
                head or hrp
            }
        end
    end
    if #targets <= 0 then
        return
    end
    local hitData = {
        [1] = targets[1][2],
        [2] = {}
    }
    for _, data in ipairs(targets) do
        hitData[2][#hitData[2] + 1] = {
            data[1],
            data[2]
        }
    end
    pcall(function()
        RegisterAttack:FireServer()
    end)
    pcall(function()
        RegisterHit:FireServer(unpack(hitData))
    end)
    EncryptedRegisterHit(hitData)
    lastAttack = tick()
end

local statusGui = Instance.new("ScreenGui")
statusGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 300, 0, 50)
statusLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
statusLabel.BackgroundTransparency = 0.5
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Parent = statusGui

local function setStatus(msg)
    statusLabel.Text = msg
    print(msg)
end

task.spawn(function()
    while task.wait() do
        pcall(function()
            if LocalPlayer.Character then
                for _, no in pairs(LocalPlayer.Character:GetDescendants()) do
                    if no:IsA("BasePart") then
                        no.CanCollide = false
                    end
                end
                if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = LocalPlayer.Character.HumanoidRootPart
                    Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                    Noclip.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end
end)

function getCFrame(v)
    if not v then return nil end
    if typeof(v) == "CFrame" then return v end
    if typeof(v) == "Vector3" then return CFrame.new(v) end
    if typeof(v) ~= "Instance" then return nil end
    if v:IsA("BasePart") then return v.CFrame end
    if v:IsA("Model") then
        if v.GetPivot then return v:GetPivot() end
        local root = v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")
        if root then return root.CFrame end
    end
    if v:IsA("CFrameValue") then return v.Value end
    if v:IsA("Vector3Value") then return CFrame.new(v.Value) end
    return nil
end

function Tween(targetCFrame, targetObject)
    if tween then
        tween:Cancel()
        tween = nil
    end
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if pathPart then
        pathPart:Destroy()
        pathPart = nil
    end
    isTweening = false
    if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
    if targetCFrame == false then return end
    targetCFrame = getCFrame(targetCFrame)
    if not targetCFrame then return end
    local root = Character:FindFirstChild("HumanoidRootPart")
    targetObject = targetObject or root
    if targetObject == root then
        Character.Humanoid.Sit = false
    end
    if root and targetCFrame and math.abs(root.Position.Y - targetCFrame.Position.Y) > 30 then
        root.CFrame = CFrame.new(root.Position.X, targetCFrame.Position.Y, root.Position.Z)
        targetCFrame = targetCFrame * CFrame.new(0, 0, 0)
    end
    isTweening = true
    if targetObject == root and (root.Position - targetCFrame.Position).Magnitude <= 200 then
        root.CFrame = targetCFrame
        isTweening = false
        return
    end
    local startCFrame = targetObject.CFrame
    local distance = (targetCFrame.Position - startCFrame.Position).Magnitude
    pathPart = Instance.new("Part")
    pathPart.Name = "TweenGhost"
    pathPart.Transparency = 1
    pathPart.Anchored = true
    pathPart.CanCollide = false
    pathPart.CFrame = startCFrame
    pathPart.Size = Vector3.new(5, 5, 5)
    pathPart.Parent = workspace
    local speed = 325
    tween = TweenService:Create(pathPart, TweenInfo.new(distance / speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    connection = RunService.Heartbeat:Connect(function()
        if targetObject and targetObject.Parent and pathPart then
            if targetObject:IsA("BasePart") then
                targetObject.Velocity = Vector3.new(0, 0, 0)
                targetObject.RotVelocity = Vector3.new(0, 0, 0)
            end
            targetObject.CFrame = pathPart.CFrame
            if targetObject == root then
                Character.Humanoid.Sit = false
            end
        else
            Tween(false)
        end
    end)
    tween.Completed:Connect(function()
        Tween(false)
    end)
    tween:Play()
end

local ActiveBringName = nil
local ActiveBringCount = 5

local function TweenObject(Object, Pos, Speed)
    Speed = Speed or 300
    if not Object or not Pos then
        return
    end
    local Distance = (Pos.Position - Object.Position).Magnitude
    if Distance <= 3 then
        Object.CFrame = Pos
        return
    end
    local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    TweenService:Create(Object, info, {CFrame = Pos}):Play()
end

local function GetMobPosition(name)
    local pos = Vector3.new(0, 0, 0)
    local count = 0
    for _, v in pairs(Enemies:GetChildren()) do
        if v.Name == name and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                pos = pos + v.HumanoidRootPart.Position
                count = count + 1
            end
        end
    end
    if count == 0 then
        return nil
    end
    return pos / count
end

local function DoBringMob(name, count)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return
    end
    local hrpChar = char.HumanoidRootPart
    local enemies = Enemies:GetChildren()
    if #enemies == 0 then
        return
    end
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
    local totalpos = {}
    for _, v in pairs(enemies) do
        if IsTargetName(v.Name, name) and not totalpos[v.Name] then
            totalpos[v.Name] = GetMobPosition(v.Name)
        end
    end
    local moved = 0
    for _, v in pairs(enemies) do
        if count and moved >= count then
            break
        end
        local hum = v:FindFirstChild("Humanoid")
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and IsTargetName(v.Name, name) then
            local distChar = (hrp.Position - hrpChar.Position).Magnitude
            if distChar <= 1500 then
                local mobPos = totalpos[v.Name]
                if mobPos then
                    local target = CFrame.new(mobPos)
                    local dist = (hrp.Position - target.Position).Magnitude
                    if dist > 3 and dist <= 1500 then
                        TweenObject(hrp, target, 300)
                    end
                    hrp.CanCollide = false
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    if hum:FindFirstChild("Animator") then
                        hum.Animator:Destroy()
                    end
                    moved = moved + 1
                end
            end
        end
    end
end

function BringMonster(name, count)
    ActiveBringName = name
    ActiveBringCount = count or 5
    DoBringMob(ActiveBringName, ActiveBringCount)
end

RunService.Heartbeat:Connect(function()
    if ActiveBringName then
        pcall(function()
            DoBringMob(ActiveBringName, ActiveBringCount)
        end)
    end
end)

function EquipWeapon(toolTip)
    if not Character then return end
    local tool = Character:FindFirstChildWhichIsA("Tool")
    if tool and tool.ToolTip == toolTip then return end
    for _, x in next, LocalPlayer.Backpack:GetChildren() do
        if x:IsA("Tool") and x.ToolTip == toolTip then
            Humanoid:EquipTool(x)
            return
        end
    end
end

function EnsureWeapon(toolTip)
    if not Character then return end
    local tool = Character:FindFirstChildWhichIsA("Tool")
    if not tool or (tool.ToolTip ~= toolTip) then
        EquipWeapon(toolTip)
    end
end

function UpdateInventory()
    if tick() - lastCheckInv > 1 then
        inventoryScan = CommF_:InvokeServer("getInventory")
        lastCheckInv = tick()
    end
end

function CheckInventory(...)
    UpdateInventory()
    for _, v in pairs(inventoryScan) do
        for _, n in next, {...} do
            if v.Name == n then return true end
        end
    end
    return false
end

function GetConnectionEnemies(name)
    local list = {}
    for _, v in next, Enemies:GetChildren() do
        if v.Name == name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            table.insert(list, v)
        end
    end
    return #list > 0 and list or nil
end

getgenv().DontHopSameServer = getgenv().DontHopSameServer ~= false
getgenv().CacheSeconds = getgenv().CacheSeconds or 60
getgenv().HopMaxPlayers = getgenv().HopMaxPlayers or 5

local LastServersDataPulled = nil
local CachedServers = nil

local function IfTableHaveIndex(j)
    if type(j) ~= "table" then return false end
    for _ in pairs(j) do return true end
    return false
end

local function GetServerBrowser()
    return ReplicatedStorage:FindFirstChild("__ServerBrowser")
end

local function GetAllServers()
    if LastServersDataPulled and CachedServers then
        if os.time() - LastServersDataPulled < (getgenv().CacheSeconds or 60) then
            return CachedServers
        end
    end
    local ServerBrowser = GetServerBrowser()
    if not ServerBrowser then
        warn("[ServerHop] Không tìm thấy __ServerBrowser")
        return {}
    end
    local AllServers = {}
    local totalPages = 0
    for page = 1, 150 do
        local ok, data = pcall(function()
            return ServerBrowser:InvokeServer(page)
        end)
        if ok and type(data) == "table" and IfTableHaveIndex(data) then
            totalPages = totalPages + 1
            for jobId, info in pairs(data) do
                AllServers[jobId] = info
            end
        elseif totalPages > 0 and page > totalPages + 8 then
            break
        end
        task.wait(0.07)
    end
    LastServersDataPulled = os.time()
    CachedServers = AllServers
    return AllServers
end

function ServerHop(reason, maxPlayers)
    reason = reason or "NoEliteBoss"
    maxPlayers = tonumber(maxPlayers) or tonumber(getgenv().HopMaxPlayers) or 5
    local success, err = pcall(function()
        local ServerBrowser = GetServerBrowser()
        if not ServerBrowser then
            error("Không tìm thấy __ServerBrowser")
        end
        local Servers = GetAllServers()
        if not Servers or next(Servers) == nil then
            error("Không lấy được dữ liệu server")
        end
        local ArrayServers = {}
        for jobId, v in pairs(Servers) do
            if type(v) == "table" then
                table.insert(ArrayServers, {
                    JobId = jobId,
                    Players = tonumber(v.Count) or tonumber(v.playing) or 0,
                    Region = v.Region or "Unknown"
                })
            end
        end
        if #ArrayServers == 0 then
            error("No servers found")
        end
        local chosen = nil
        for _ = 1, 120 do
            local pick = ArrayServers[math.random(1, #ArrayServers)]
            if pick then
                local notSame = (not getgenv().DontHopSameServer) or pick.JobId ~= game.JobId
                if notSame and pick.Players < maxPlayers then
                    chosen = pick
                    break
                end
            end
        end
        if not chosen then
            table.sort(ArrayServers, function(a, b)
                return (a.Players or 999) < (b.Players or 999)
            end)
            for _, pick in ipairs(ArrayServers) do
                local notSame = (not getgenv().DontHopSameServer) or pick.JobId ~= game.JobId
                if notSame and pick.Players < maxPlayers then
                    chosen = pick
                    break
                end
            end
        end
        if not chosen then
            error("Không tìm thấy server phù hợp dưới " .. tostring(maxPlayers) .. " players")
        end
        if typeof(setStatus) == "function" then
            setStatus(("Server hopping (%s) -> %s | Players: %s"):format(
                tostring(reason),
                tostring(chosen.JobId):sub(1, 8) .. "..",
                tostring(chosen.Players)
            ))
        else
            warn("[ServerHop] Teleporting -> " .. tostring(chosen.JobId))
        end
        ServerBrowser:InvokeServer("teleport", chosen.JobId)
    end)
    if not success then
        warn("[ServerHop] Error:", err)
        if typeof(setStatus) == "function" then
            setStatus("ServerHop error: " .. tostring(err))
        end
        return false, tostring(err)
    end
    return true, "Teleporting..."
end

function HasYama()
    return CheckInventory("Yama") or CheckInventory("Yama", "True Triple Katana")
end

function GetMastery()
    local toolName = "Yama"
    local tool = Character:FindFirstChild(toolName) or Character:FindFirstChildOfClass("Tool")
    if tool and tool.Name == toolName then
        local level = tool:FindFirstChild("Level")
        if level then return level.Value end
    end
    return 0
end

function LoadYama()
    CommF_:InvokeServer("LoadItem", "Yama")
    task.wait(0.5)
end

function FarmBoneMastery()
    setStatus("Moving to bone spawn...")
    Tween(CFrame.new(-9506.234375, 172.130615234375, 6117.0771484375))
    repeat task.wait(0.5) until (HumanoidRootPart.Position - Vector3.new(-9506.234375, 172.130615234375, 6117.0771484375)).Magnitude <= 30

    setStatus("Farming Bone Mastery...")
    while GetMastery() < 350 do
        if not Character or Humanoid.Health <= 0 then break end
        local target = nil
        for _, v in next, Enemies:GetChildren() do
            if table.find(BoneMonsters, v.Name) then
                local h = v:FindFirstChild("Humanoid")
                if h and h.Health > 0 then
                    target = v
                    break
                end
            end
        end
        if target then
            EnsureWeapon("Sword")
            BringMonster(target.Name, 5)
            local lastTween = 0
            while target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 and target.Parent do
                if GetMastery() >= 350 then break end
                EnsureWeapon("Sword")
                if not Character:FindFirstChild("HasBuso") then CommF_:InvokeServer("Buso") end
                if tick() - lastTween > 0.5 and (target.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude > 15 then
                    Tween(target.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                    lastTween = tick()
                end
                FastAttack(target.Name)
                task.wait(0.2)
            end
        else
            Tween(CFrame.new(-9506.234375, 172.130615234375, 6117.0771484375))
            task.wait(1)
        end
    end
    setStatus("Bone Mastery complete!")
end

local function GetEliteProgress()
    local ok, result = pcall(function()
        return CommF_:InvokeServer("EliteHunter", "Progress")
    end)
    if ok then
        return tonumber(result) or 0
    end
    return 0
end

function FarmEliteHunter()
    setStatus("Farming Elite Hunter progress...")
    while GetEliteProgress() < 30 and not HasYama() do
        if not Character or Humanoid.Health <= 0 then
            task.wait(1)
        else
            local playerGui = LocalPlayer.PlayerGui
            local questGui = playerGui.Main.Quest
            local questText = questGui.Container.QuestTitle.Title.Text
            if questGui.Visible then
                if string.find(questText, "Diablo") or string.find(questText, "Urban") or string.find(questText, "Deandre") then
                    local bossName = nil
                    for _, name in ipairs({"Diablo", "Urban", "Deandre"}) do
                        if string.find(questText, name) then
                            bossName = name
                            break
                        end
                    end
                    if bossName then
                        local boss = Enemies:FindFirstChild(bossName)
                        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                            EnsureWeapon("Melee")
                            local lastTween = 0
                            while boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss.Parent do
                                if GetEliteProgress() >= 30 or HasYama() then break end
                                EnsureWeapon("Melee")
                                if not Character:FindFirstChild("HasBuso") then CommF_:InvokeServer("Buso") end
                                if tick() - lastTween > 0.3 and (boss.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude > 15 then
                                    Tween(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                                    lastTween = tick()
                                end
                                FastAttack(bossName)
                                task.wait(0.1)
                            end
                        else
                            local replicatedBoss = ReplicatedStorage:FindFirstChild(bossName)
                            if replicatedBoss and replicatedBoss:FindFirstChild("HumanoidRootPart") then
                                Tween(replicatedBoss.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                                task.wait(0.5)
                            else
                                task.wait(1)
                            end
                        end
                    end
                else
                    task.wait(1)
                end
            else
                local result = CommF_:InvokeServer("EliteHunter")
                if result == "I don't have anything for you right now. Come back later." then
                    setStatus("server hopping...")
                    ServerHop("EliteHunter", getgenv().HopMaxPlayers or 5)
                    task.wait(5)
                else
                    task.wait(0.5)
                end
            end
        end
        task.wait(0.5)
    end
    setStatus("Elite reached 30")
end

function GetYama()
    if HasYama() then return end
    setStatus("Getting Yama...")
    while not HasYama() do
        if not Character or Humanoid.Health <= 0 then
            task.wait(1)
        else
            local map = workspace:FindFirstChild("Map")
            local waterfall = map and map:FindFirstChild("Waterfall")
            local sealedKatana = waterfall and waterfall:FindFirstChild("SealedKatana")
            local hitbox = sealedKatana and sealedKatana:FindFirstChild("Hitbox")
            if not map or not waterfall or not sealedKatana or not hitbox then
                Tween(CFrame.new(5251.93213, 17.9657593, 453.653931, 0.0348494053, 0, 0.999392569, 0, 1, 0, -0.999392569, 0, 0.0348494053))
                task.wait(0.5)
            else
                local dist = (hitbox.Position - HumanoidRootPart.Position).Magnitude
                if dist > 20 then
                    Tween(hitbox.CFrame)
                    task.wait(0.5)
                else
                    local ghosts = GetConnectionEnemies("Ghost")
                    if ghosts and #ghosts > 0 then
                        setStatus("killing ghosts")
                        EnsureWeapon("Melee")
                        for _, ghost in ipairs(ghosts) do
                            if ghost and ghost:FindFirstChild("Humanoid") and ghost.Humanoid.Health > 0 then
                                local lastTween = 0
                                while ghost and ghost:FindFirstChild("Humanoid") and ghost.Humanoid.Health > 0 and ghost.Parent do
                                    if HasYama() then break end
                                    EnsureWeapon("Melee")
                                    if not Character:FindFirstChild("HasBuso") then CommF_:InvokeServer("Buso") end
                                    if tick() - lastTween > 0.5 and (ghost.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude > 15 then
                                        Tween(ghost.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                                        lastTween = tick()
                                    end
                                    FastAttack("Ghost")
                                    task.wait(0.2)
                                end
                            end
                        end
                    else
                        local clickDetector = hitbox:FindFirstChild("ClickDetector")
                        if clickDetector then
                            fireclickdetector(clickDetector)
                        end
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait()
    end
    setStatus("got yama")
end

local function Main()
    while true do
        if not Character or Humanoid.Health <= 0 then
            setStatus("Waiting for character...")
            task.wait(1)
        elseif GetMastery() >= 350 and HasYama() then
            setStatus("All tasks complete. Idle...")
            task.wait(5)
        elseif not HasYama() then
            local progress = GetEliteProgress()
            if progress < 30 then
                FarmEliteHunter()
            elseif progress >= 30 then
                GetYama()
            end
        else
            if GetMastery() < 350 then
                LoadYama()
                task.wait(0.5)
                EnsureWeapon("Sword")
                FarmBoneMastery()
            end
        end
        task.wait(2)
    end
end

Main()

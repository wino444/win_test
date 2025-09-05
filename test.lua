-- Phantom Chat Hub Client (Roblox Lua) 🌌
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── CONFIG ────────────────────────────── ⚙️
local USE_DEFAULT_URL = true
local DEFAULT_URL     = "wss://a971468b3890.ngrok-free.app"

local wsApi = WebSocket or WebSocketClient or (syn and syn.websocket)
if not wsApi then
    warn("❌ Executor นี้ไม่รองรับ WebSocket! 🚫")
    return
end

-- ─── VARIABLES ────────────────────────── 📦
local connection, connected = nil, false
local connectCooldown = false
local isAuthenticated = false
local sendCooldown = false
local chatGui = nil
local chatOutputFrame = nil
local chatList = nil
local toggleButtonGui = nil -- สำหรับปุ่มเปิด/ปิด

-- ─── ฟังก์ชัน log ────────────────────── 📜
local function log(txt)
    print(txt) -- debug
end

-- ─── สร้าง UI แชท ────────────────────── 🖼️
local function createChatUI()
    chatGui = Instance.new("ScreenGui", PlayerGui)
    chatGui.Name = "PhantomChatHub"
    chatGui.Enabled = false

    local chatFrame = Instance.new("Frame", chatGui)
    chatFrame.Size            = UDim2.new(0.6, 0, 0.7, 0) -- ขยายขนาด UI ✨
    chatFrame.Position        = UDim2.new(0.2, 0, 0.15, 0)
    chatFrame.BackgroundColor3= Color3.fromRGB(20, 20, 20)
    chatFrame.BorderSizePixel = 1
    chatFrame.Active          = true
    chatFrame.Draggable       = true

    local title = Instance.new("TextLabel", chatFrame)
    title.Text              = "🌌 Phantom Chat Hub"
    title.Size              = UDim2.new(1, 0, 0.1, 0)
    title.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
    title.TextColor3        = Color3.fromRGB(0, 255, 0)
    title.Font              = Enum.Font.SourceSansBold
    title.TextSize          = 24 -- ขยายตัวอักษรเล็กน้อย

    -- Scrollable frame สำหรับ chat
    chatOutputFrame = Instance.new("ScrollingFrame", chatFrame)
    chatOutputFrame.Size             = UDim2.new(1, -20, 0.65, -10)
    chatOutputFrame.Position         = UDim2.new(0, 10, 0.12, 5)
    chatOutputFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    chatOutputFrame.BorderSizePixel  = 0
    chatOutputFrame.CanvasSize       = UDim2.new(0, 0, 0, 0)
    chatOutputFrame.ScrollBarThickness = 8
    chatOutputFrame.BackgroundTransparency = 0.1

    chatList = Instance.new("UIListLayout", chatOutputFrame)
    chatList.SortOrder = Enum.SortOrder.LayoutOrder
    chatList.Padding   = UDim.new(0, 6)

    local chatInput = Instance.new("TextBox", chatFrame)
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

    -- สร้างปุ่มเปิด/ปิด UI
    toggleButtonGui = Instance.new("ScreenGui", PlayerGui)
    toggleButtonGui.Name = "ToggleChatButton"

    local toggleButton = Instance.new("TextButton", toggleButtonGui)
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(1, -60, 0, 10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    toggleButton.Text = "💬"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 20
    toggleButton.BorderSizePixel = 0

    local corner = Instance.new("UICorner", toggleButton)
    corner.CornerRadius = UDim.new(0, 10) -- ปุ่มกลมๆ สไตล์โมเดิร์น

    toggleButton.MouseButton1Click:Connect(function()
        chatGui.Enabled = not chatGui.Enabled
        toggleButton.Text = chatGui.Enabled and "❌" or "💬"
    end)

    return chatGui
end

-- ─── ฟังก์ชันเพิ่มข้อความ chat ─────────── 💬
local function addChatMessage(text)
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size             = UDim2.new(1, -10, 0, 24)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3       = Color3.fromRGB(0, 255, 0)
    msgLabel.Font             = Enum.Font.Code
    msgLabel.TextSize         = 16
    msgLabel.TextScaled       = true -- ปรับขนาดข้อความอัตโนมัติ
    msgLabel.TextXAlignment   = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment   = Enum.TextYAlignment.Top
    msgLabel.Text             = text
    msgLabel.Parent           = chatOutputFrame

    -- อัปเดต CanvasSize และเลื่อนลงล่าง
    chatOutputFrame.CanvasSize = UDim2.new(0, 0, 0, chatList.AbsoluteContentSize.Y + 10)
    chatOutputFrame.CanvasPosition = Vector2.new(0, math.max(0, chatOutputFrame.CanvasSize.Y.Offset))
end

-- ─── ฟังก์ชัน handle message ─────────── 📩
local function handleMessage(msg)
    if not isAuthenticated then
        if msg:find("✅ คุณเชื่อมต่อเซิร์ฟเวอร์สำเร็จ!") then
            isAuthenticated = true
            if chatGui then chatGui.Enabled = true end
            log("✅ เชื่อมต่อและตั้งชื่อสำเร็จ!")
            local auth = {name=LocalPlayer.Name, userId=LocalPlayer.UserId}
            connection:Send(HttpService:JSONEncode(auth))
        end
        return
    end

    local success, data = pcall(HttpService.JSONDecode, HttpService, msg)
    if success and type(data) == "table" then
        if data.chat then
            addChatMessage("🗨️ " .. data.chat)
        elseif data.error then
            log("❌ " .. data.error)
        elseif data.command and data.target == LocalPlayer.Name then
            if data.command == "kick" then
                log("🦵 คุณถูก kick! ตัดการเชื่อมต่อ...")
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
        log("📄 " .. msg)
    end
end

-- ─── ฟังก์ชัน UI ใส่ URL ─────────── 🌐
local function showURLGui()
    local urlGui = Instance.new("ScreenGui", PlayerGui)
    urlGui.Name = "PhantomURLInput"

    local frame = Instance.new("Frame", urlGui)
    frame.Size            = UDim2.new(0.4, 0, 0.3, 0)
    frame.Position        = UDim2.new(0.3, 0, 0.35, 0)
    frame.BackgroundColor3= Color3.fromRGB(15, 15, 15)
    frame.Active          = true
    frame.Draggable       = true

    local label = Instance.new("TextLabel", frame)
    label.Size  = UDim2.new(1, 0, 0.2, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
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
        if not url:match("^wss://") then
            urlBox.Text = ""
            urlBox.PlaceholderText = "❌ URL ต้องขึ้นต้นด้วย wss://"
            return
        end
        urlGui:Destroy()
        connectToHub(url)
    end)
end

-- ─── ฟังก์ชัน connect ─────────── 🔌
createChatUI()  -- สร้าง UI ล่วงหน้า

function connectToHub(url)
    if connectCooldown then return end
    connectCooldown = true
    task.delay(2, function() connectCooldown = false end)

    log("🌐 กำลังเชื่อมต่อ: " .. url)
    local success, sock = pcall(wsApi.connect, url)
    if not success or not sock then
        log("❌ เชื่อมต่อไม่สำเร็จ!")
        return
    end

    connection, connected = sock, true

    if connection.OnMessage then
        connection.OnMessage:Connect(handleMessage)
    else
        task.spawn(function()
            while connected do
                local success, msg = pcall(function() return connection:Recv() end)
                if success and msg then handleMessage(msg) end
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
            log("⚠️ เกิดข้อผิดพลาด: " .. tostring(err))
            connected = false
        end)
    end
end

-- ─── เริ่มต้น ─────────── 🚀
if USE_DEFAULT_URL then
    connectToHub(DEFAULT_URL)
else
    showURLGui()
end

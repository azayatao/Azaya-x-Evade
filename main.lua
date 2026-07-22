-- https://lua.expert/
--// AZAYA GUI X - XENO COMPATIBLE (ULTRA SIMPLE)
--// No UICorner, No UIStroke, No Complex UDim

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--// Anti Duplicate
pcall(function()
    if CoreGui:FindFirstChild("AzayaGUI") then 
        CoreGui.AzayaGUI:Destroy() 
    end
end)

--// CONFIG
local config = {
    FlySpeed = 120,
    HoverHeight = 250,
    FarmDistance = 10
}

--// STATES
local Fly_Enabled = false
local Noclip_Enabled = false
local AutoFarm_Enabled = false
local AutoRevive_Enabled = false
local ESP_Player_Enabled = false
local ESP_Entity_Enabled = false
local AutoRespawn_Enabled = false
local BotDetector_Enabled = true

local Fly_Attachment = nil
local Fly_Velocity = nil
local ESP_List = {}

--// BOT DETECTOR
local BotDetector = {
    Logs = {},
    ClosestBot = nil,
    ClosestDistance = math.huge,
    LastHealth = 0,
}

--// FUNCTIONS
local function GetCharacter()
    if not Player or not Player.Character then return nil, nil, nil end
    local char = Player.Character
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return char, hum, root
end

local function FindBots()
    local bots = {}
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return bots end
    
    for _, obj in pairs(playersFolder:GetChildren()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.MaxHealth == 100000 then
                local root = obj:FindFirstChild("HumanoidRootPart")
                if root then
                    table.insert(bots, {Name = obj.Name, Model = obj, Root = root, Hum = hum})
                end
            end
        end
    end
    return bots
end

local function RecordBotHit(botName, distance, botPos, playerPos)
    if distance > 50 then return end
    table.insert(BotDetector.Logs, {
        Time = os.date("%H:%M:%S"),
        Bot = botName,
        Dist = math.floor(distance * 100) / 100,
        BotX = math.floor(botPos.X * 100) / 100,
        BotY = math.floor(botPos.Y * 100) / 100,
        BotZ = math.floor(botPos.Z * 100) / 100,
        PlayerX = math.floor(playerPos.X * 100) / 100,
        PlayerY = math.floor(playerPos.Y * 100) / 100,
        PlayerZ = math.floor(playerPos.Z * 100) / 100,
    })
end

local function ExportCSV()
    local csv = "Time,Bot,Distance,BotX,BotY,BotZ,PlayerX,PlayerY,PlayerZ\n"
    for _, entry in pairs(BotDetector.Logs) do
        csv = csv .. entry.Time .. "," .. entry.Bot .. "," .. entry.Dist .. "," .. entry.BotX .. "," .. entry.BotY .. "," .. entry.BotZ .. "," .. entry.PlayerX .. "," .. entry.PlayerY .. "," .. entry.PlayerZ .. "\n"
    end
    return csv
end

local function AutoCopy(content, filename)
    if setclipboard then
        setclipboard(content)
    end
    if not isfolder("AzayaGUI") then makefolder("AzayaGUI") end
    writefile("AzayaGUI/" .. filename, content)
end

--// FLY SYSTEM
local function EnableFly()
    local _, _, root = GetCharacter()
    if not root then return end
    
    Fly_Attachment = Instance.new("Attachment")
    Fly_Attachment.Parent = root
    
    Fly_Velocity = Instance.new("LinearVelocity")
    Fly_Velocity.Name = "FlyVelocity"
    Fly_Velocity.Attachment0 = Fly_Attachment
    Fly_Velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    Fly_Velocity.ForceLimitsEnabled = false
    Fly_Velocity.VectorVelocity = Vector3.zero
    Fly_Velocity.Parent = root
    
    Fly_Enabled = true
    print("[Azaya] Fly enabled")
end

local function DisableFly()
    if Fly_Velocity then Fly_Velocity:Destroy() Fly_Velocity = nil end
    if Fly_Attachment then Fly_Attachment:Destroy() Fly_Attachment = nil end
    Fly_Enabled = false
    print("[Azaya] Fly disabled")
end

--// NOCLIP
RunService.Stepped:Connect(function()
    if not Noclip_Enabled then return end
    local char = Player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

--// FLY LOOP
RunService.RenderStepped:Connect(function()
    if not Fly_Enabled then return end
    if not Fly_Velocity or not Fly_Velocity.Parent then
        EnableFly()
        return
    end
    
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
    
    if dir.Magnitude > 0 then dir = dir.Unit * config.FlySpeed end
    Fly_Velocity.VectorVelocity = dir
end)

--// AUTO FARM WIN
task.spawn(function()
    while true do
        task.wait(0.2)
        if not AutoFarm_Enabled then continue end
        
        local _, _, root = GetCharacter()
        if not root then continue end
        
        if not Fly_Enabled then EnableFly() end
        
        local target = Vector3.new(root.Position.X, config.HoverHeight, root.Position.Z)
        local diff = target - root.Position
        
        if diff.Magnitude > config.FarmDistance then
            if Fly_Velocity then Fly_Velocity.VectorVelocity = diff.Unit * config.FlySpeed end
        else
            if Fly_Velocity then Fly_Velocity.VectorVelocity = Vector3.zero end
        end
    end
end)

--// AUTO REVIVE
task.spawn(function()
    while true do
        task.wait(1)
        if not AutoRevive_Enabled then continue end
        
        local _, _, root = GetCharacter()
        if not root then continue end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                local proot = player.Character:FindFirstChild("HumanoidRootPart")
                if hum and proot and hum.Health <= 0 then
                    root.CFrame = proot.CFrame
                end
            end
        end
    end
end)

--// ESP
local function CreateESP(obj, color)
    if not obj or obj:FindFirstChild("ESPHighlight") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESPHighlight"
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.5
    hl.Parent = obj
    table.insert(ESP_List, hl)
end

local function ClearESP()
    for _, hl in pairs(ESP_List) do
        if hl then hl:Destroy() end
    end
    ESP_List = {}
end

task.spawn(function()
    while true do
        task.wait(1)
        if not ESP_Player_Enabled and not ESP_Entity_Enabled then
            ClearESP()
            continue
        end
        
        if ESP_Player_Enabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    CreateESP(p.Character, Color3.fromRGB(0, 255, 0))
                end
            end
        end
        
        if ESP_Entity_Enabled then
            for _, m in pairs(Workspace:GetChildren()) do
                if m:IsA("Model") and m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) then
                    CreateESP(m, Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end
end)

--// BOT DETECTOR LOOP
task.spawn(function()
    while true do
        task.wait(0.1)
        if not BotDetector_Enabled then continue end
        
        local _, _, root = GetCharacter()
        if not root then continue end
        
        local bots = FindBots()
        BotDetector.ClosestDistance = math.huge
        BotDetector.ClosestBot = nil
        
        for _, bot in pairs(bots) do
            local dist = (bot.Root.Position - root.Position).Magnitude
            if dist < BotDetector.ClosestDistance then
                BotDetector.ClosestDistance = dist
                BotDetector.ClosestBot = bot.Name
            end
        end
    end
end)

--// PROXIMITY RECORDING
task.spawn(function()
    local lastRecord = 0
    while true do
        task.wait(0.2)
        if not BotDetector_Enabled then continue end
        if BotDetector.ClosestDistance >= 5 then continue end
        if (tick() - lastRecord) < 1.5 then continue end
        if not BotDetector.ClosestBot then continue end
        
        local _, _, root = GetCharacter()
        if not root then continue end
        
        local bots = FindBots()
        for _, bot in pairs(bots) do
            if bot.Name == BotDetector.ClosestBot then
                RecordBotHit(bot.Name, BotDetector.ClosestDistance, bot.Root.Position, root.Position)
                lastRecord = tick()
                break
            end
        end
    end
end)

--// SIMPLE GUI - NO COMPLEX UICOMPONENTS
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AzayaGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(80, 120, 200)
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Azaya GUI X v6"
titleLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleLabel

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = scrollFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingLeft = UDim.new(0, 5)
listPad.PaddingRight = UDim.new(0, 5)
listPad.PaddingTop = UDim.new(0, 5)
listPad.PaddingBottom = UDim.new(0, 5)
listPad.Parent = scrollFrame

--// CREATE BUTTONS
local function AddButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    end)
    
    return btn
end

local function AddToggle(name, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 25)
    container.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 9
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, -3, 1, 0)
    toggle.Position = UDim2.new(0.7, 3, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    toggle.BorderSizePixel = 0
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(200, 80, 80)
    toggle.TextSize = 8
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = container
    
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            toggle.Text = "ON"
        else
            toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            toggle.Text = "OFF"
        end
        callback(state)
    end)
    
    return container
end

--// ADD ITEMS
AddToggle("Fly", function(state) if state then EnableFly() else DisableFly() end end)
AddToggle("Noclip", function(state) Noclip_Enabled = state end)
AddToggle("Auto Farm", function(state) AutoFarm_Enabled = state end)
AddToggle("Auto Revive", function(state) AutoRevive_Enabled = state end)
AddToggle("ESP Player", function(state) ESP_Player_Enabled = state end)
AddToggle("ESP Entity", function(state) ESP_Entity_Enabled = state end)
AddToggle("Auto Respawn", function(state) AutoRespawn_Enabled = state end)
AddToggle("Bot Detector", function(state) BotDetector_Enabled = state end)
AddButton("Export CSV", function()
    local csv = ExportCSV()
    AutoCopy(csv, "bot_log_" .. os.date("%H%M%S") .. ".csv")
    print("[Azaya] CSV exported!")
end)
AddButton("Clear Logs", function()
    BotDetector.Logs = {}
    print("[Azaya] Logs cleared!")
end)

--// DRAGGABLE
local dragging = false
local dragStart = nil
local startPos = nil

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = mainFrame.Position
    end
end)

titleLabel.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local delta = mousePos - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// HOTKEYS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        mainFrame.Visible = not mainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F9 then
        local csv = ExportCSV()
        AutoCopy(csv, "bot_log_export.csv")
        print("[Azaya] Export!")
    end
end)

print("[Azaya] GUI Loaded! F1=Toggle, F9=Export")

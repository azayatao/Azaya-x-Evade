-- https://lua.expert/
--// Azaya GUI X - v4 | Evade Edition
--// Xeno & Delta Compatible
--// Fix: crash removed, round detector pakai timer 3 menit

--// Services
local v1 = game:GetService("Players")
local v2 = game:GetService("RunService")
local v3 = game:GetService("UserInputService")
local v4 = game:GetService("ReplicatedStorage")
local v5 = game:GetService("Workspace")
local v6 = game:GetService("VirtualUser")
local v8 = game:GetService("CoreGui")

--// Player
local v9 = v1.LocalPlayer

--// Anti Duplicate
pcall(function()
    if v8:FindFirstChild("AzayaGUI") then v8.AzayaGUI:Destroy() end
    if v8:FindFirstChild("AzayaWPGui") then v8.AzayaWPGui:Destroy() end
end)

--// Remotes
local v10, v11, v12, v13 = nil, nil, nil, nil
pcall(function()
    local vTemp = v4:WaitForChild("Events")
    v10 = vTemp:WaitForChild("Data"):WaitForChild("RequestMap")
    v11 = vTemp:WaitForChild("Character"):WaitForChild("VerifyRange")
    v12 = vTemp:WaitForChild("Character"):WaitForChild("GetStarterInfo")
    v13 = vTemp:WaitForChild("Data"):WaitForChild("Get")
end)

local v_deployRemote = nil
pcall(function()
    v_deployRemote = v4:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("DeployableUsed")
end)

--// Config
local v14 = { FlySpeed = 120, HoverHeight = 250, FarmDistance = 10 }

--// Feature States
local v15 = false
local v16 = false
local v17 = false
local v18 = false
local v19 = false
local v20 = false
local v21 = false
local v22 = false
local v23 = false

--// Fly Objects
local v24, v25 = nil, nil

--// ESP Cache
local v26 = {}

--// ============================================================
--// WAYPOINT SYSTEM
--// ============================================================

local v_wpFolder = "AzayaGUI"
local v_wpFile   = "AzayaGUI/waypoints.txt"
local v_wpData   = {}
local v_wpOrder  = {}

pcall(function()
    if not isfolder(v_wpFolder) then makefolder(v_wpFolder) end
end)

local function v_wpSave()
    pcall(function()
        local v_out = ""
        for _, v_n in ipairs(v_wpOrder) do
            if v_wpData[v_n] then
                local p = v_wpData[v_n]
                v_out = v_out .. v_n .. "|" .. math.floor(p.X*100)/100 .. "|" .. math.floor(p.Y*100)/100 .. "|" .. math.floor(p.Z*100)/100 .. "\n"
            end
        end
        writefile(v_wpFile, v_out)
    end)
end

local function v_wpLoad()
    pcall(function()
        if not isfile(v_wpFile) then return end
        local v_raw = readfile(v_wpFile)
        for v_line in v_raw:gmatch("[^\n]+") do
            local n, x, y, z = v_line:match("^(.+)|(-?[%d%.]+)|(-?[%d%.]+)|(-?[%d%.]+)$")
            if n and x and y and z then
                if not v_wpData[n] then
                    v_wpData[n] = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
                    table.insert(v_wpOrder, n)
                end
            end
        end
    end)
end

local function v_wpAdd(p1, p2)
    if not v_wpData[p1] then
        table.insert(v_wpOrder, p1)
    end
    v_wpData[p1] = p2
    v_wpSave()
end

local function v_wpDelete(p1)
    v_wpData[p1] = nil
    for i, n in ipairs(v_wpOrder) do
        if n == p1 then table.remove(v_wpOrder, i) break end
    end
    v_wpSave()
end

v_wpLoad()

--// ============================================================
--// CHARACTER HELPER
--// ============================================================

local function v27()
    local c, h, r = nil, nil, nil
    pcall(function()
        c = v9.Character
        if c then
            h = c:FindFirstChild("Humanoid")
            r = c:FindFirstChild("HumanoidRootPart")
        end
    end)
    return c, h, r
end

--// ============================================================
--// NOTIFY
--// ============================================================

local function v31(p1, p2)
    pcall(function()
        print("[Azaya X]:", p1)
        if Rayfield then
            Rayfield:Notify({ Title = "Azaya X", Content = p1, Duration = p2 or 3, Image = 4483345998 })
        end
    end)
end

--// ============================================================
--// FLY SYSTEM
--// ============================================================

local function v32()
    pcall(function()
        if v24 then v24:Destroy() v24 = nil end
        if v25 then v25:Destroy() v25 = nil end
    end)
end

local function v33(p1)
    v15 = p1
    pcall(function()
        local _, _, r = v27()
        if not r then return end
        if v15 then
            v32()
            v25 = Instance.new("Attachment") v25.Parent = r
            v24 = Instance.new("LinearVelocity")
            v24.Name = "AzayaFlyVelocity"
            v24.Attachment0 = v25
            v24.RelativeTo = Enum.ActuatorRelativeTo.World
            v24.ForceLimitsEnabled = false
            v24.VectorVelocity = Vector3.zero
            v24.Parent = r
            v31("✈️ Fly aktif")
        else
            v32()
            v31("Fly dimatikan")
        end
    end)
end

v2.RenderStepped:Connect(function()
    pcall(function()
        if not v15 or v17 then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local _, _, r = v27()
        if not r then return end
        if not v24 or not v24.Parent then if v15 then v33(true) end end
        local dir = Vector3.zero
        if v3:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if v3:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if v3:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if v3:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if v3:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if v3:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit * v14.FlySpeed end
        if v24 then v24.VectorVelocity = dir end
    end)
end)

v9.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(function() if v15 then v33(true) end end)
end)

--// ============================================================
--// NOCLIP
--// ============================================================

v2.Stepped:Connect(function()
    pcall(function()
        if not v16 then return end
        local c = v9.Character
        if not c then return end
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)

--// ============================================================
--// AUTO FARM WIN
--// ============================================================

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not v17 then return end
            local _, _, r = v27()
            if not r then return end
            if not v15 then v33(true) end
            local target = Vector3.new(r.Position.X, v14.HoverHeight, r.Position.Z)
            local diff = target - r.Position
            if diff.Magnitude > v14.FarmDistance then
                if v24 then v24.VectorVelocity = diff.Unit * v14.FlySpeed end
            else
                if v24 then v24.VectorVelocity = Vector3.zero end
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
end)

--// ============================================================
--// AUTO FARM REVIVE
--// ============================================================

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not v18 then return end
            local _, _, r = v27()
            if not r then return end
            for _, p in pairs(v1:GetPlayers()) do
                if p ~= v9 and p.Character then
                    local h = p.Character:FindFirstChild("Humanoid")
                    local pr = p.Character:FindFirstChild("HumanoidRootPart")
                    if h and pr and h.Health <= 0 then
                        r.CFrame = pr.CFrame
                        if v11 then v11:InvokeServer() end
                    end
                end
            end
        end)
    end
end)

--// ============================================================
--// AUTO MAP VOTE
--// ============================================================

task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if not v19 or not v10 then return end
            local res = v10:InvokeServer()
            if typeof(res) == "table" then v10:InvokeServer(res[1]) end
        end)
    end
end)

--// ============================================================
--// AUTO WHISTLE
--// ============================================================

task.spawn(function()
    while task.wait(3) do
        pcall(function()
            if not v20 then return end
            local w = v4:FindFirstChild("Whistle", true)
            if w then w:InvokeServer() end
        end)
    end
end)

--// ============================================================
--// AUTO RESPAWN
--// ============================================================

v9.CharacterAdded:Connect(function(p1)
    pcall(function()
        local h = p1:WaitForChild("Humanoid")
        h.Died:Connect(function()
            if v21 then task.wait(2) v9:LoadCharacter() end
        end)
    end)
end)

--// ============================================================
--// ESP
--// ============================================================

local function v_espCreate(p1, p2)
    pcall(function()
        if not p1 or p1:FindFirstChild("AzayaESP") then return end
        local hl = Instance.new("Highlight")
        hl.Name = "AzayaESP"
        hl.FillColor = p2
        hl.OutlineColor = p2
        hl.FillTransparency = 0.5
        hl.Parent = p1
        table.insert(v26, hl)
    end)
end

local function v61()
    pcall(function()
        for _, h in pairs(v26) do if h then h:Destroy() end end
        v26 = {}
    end)
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not v22 and not v23 then v61() return end
            if v22 then
                for _, p in pairs(v1:GetPlayers()) do
                    if p ~= v9 and p.Character then
                        v_espCreate(p.Character, Color3.fromRGB(0, 255, 0))
                    end
                end
            end
            if v23 then
                for _, m in pairs(v5:GetChildren()) do
                    if m:IsA("Model") and m:FindFirstChild("Humanoid") and not v1:GetPlayerFromCharacter(m) then
                        v_espCreate(m, Color3.fromRGB(255, 0, 0))
                    end
                end
            end
        end)
    end
end)

--// ============================================================
--// TELEPORT OUT
--// ============================================================

local function v68()
    pcall(function()
        local _, _, r = v27()
        if not r then return end
        r.CFrame = CFrame.new(0, -500, 0)
        v31("🚀 Teleported out of map")
    end)
end

--// ============================================================
--// ANTI AFK
--// ============================================================

v9.Idled:Connect(function()
    pcall(function()
        v6:CaptureController()
        v6:ClickButton2(Vector2.new())
    end)
end)

--// ============================================================
--// AUTO PUT TELEPORTER
--// ============================================================

local function v_placeTeleporter(p1)
    pcall(function()
        local v_pos = v_wpData[p1]
        if not v_pos then v31("❌ Waypoint tidak ditemukan!") return end
        local _, _, r = v27()
        if not r then v31("❌ Character tidak ditemukan!") return end
        v31("🔄 Menaruh Teleporter di " .. p1 .. "...")
        r.CFrame = CFrame.new(v_pos)
        task.wait(0.3)
        local cam = workspace.CurrentCamera
        if cam then
            local camPos = r.Position + Vector3.new(0, 2, 0)
            cam.CFrame = CFrame.new(camPos, camPos + Vector3.new(0, -1, 1))
        end
        task.wait(0.2)
        if v_deployRemote then v_deployRemote:FireServer("Teleporter", true) end
        task.wait(0.3)
        mouse1click()
        task.wait(0.2)
        v31("✅ Teleporter ditempatkan di " .. p1)
    end)
end

--// ============================================================
--// ROUND DETECTOR — TIMER BASED (3 menit per round)
--// Cara kerja:
--//   - CharacterAdded = sinyal round baru dimulai
--//   - Setelah 180 detik → fire RoundEnd otomatis
--//   - Jika karakter spawn lagi sebelum 180 detik → reset timer
--// ============================================================

local v_onRoundStart = Instance.new("BindableEvent")
local v_onRoundEnd   = Instance.new("BindableEvent")
local v_roundTimer   = nil   -- thread timer aktif
local v_roundActive  = false
local v_roundDuration = 180  -- detik, bisa diubah via slider

local function v_startRoundTimer()
    -- Batalkan timer lama jika ada
    if v_roundTimer then
        task.cancel(v_roundTimer)
        v_roundTimer = nil
    end
    v_roundActive = true
    v_onRoundStart:Fire()

    v_roundTimer = task.delay(v_roundDuration, function()
        pcall(function()
            v_roundActive = false
            v_roundTimer = nil
            v_onRoundEnd:Fire()
        end)
    end)
end

-- Trigger: setiap karakter spawn = round baru
v9.CharacterAdded:Connect(function()
    task.wait(1.5) -- tunggu sebentar biar karakter fully loaded
    pcall(function()
        v_startRoundTimer()
    end)
end)

--// ============================================================
--// AUTO ROUND CONFIG
--// ============================================================

local v_autoRound = {
    Enabled      = false,
    AutoTP       = false,
    AutoFly      = false,
    AutoFarm     = false,
    AutoRevive   = false,
    TargetWP     = "",
    DelaySeconds = 2,
}

-- Round Start: jalankan semua aksi yang diaktifkan
v_onRoundStart.Event:Connect(function()
    pcall(function()
        if not v_autoRound.Enabled then return end
        task.wait(v_autoRound.DelaySeconds)

        if v_autoRound.AutoFly then
            v33(true)
            v31("🔄 Round Start → Fly ON")
        end

        if v_autoRound.AutoFarm then
            v17 = true
            v31("🔄 Round Start → Auto Farm ON")
        end

        if v_autoRound.AutoRevive then
            v18 = true
            v31("🔄 Round Start → Auto Revive ON")
        end

        if v_autoRound.AutoTP and v_autoRound.TargetWP ~= "" then
            local _, _, r = v27()
            if r then
                local pos = v_wpData[v_autoRound.TargetWP]
                if pos then
                    r.CFrame = CFrame.new(pos)
                    v31("🔄 Round Start → TP ke: " .. v_autoRound.TargetWP)
                else
                    v31("⚠️ Waypoint '" .. v_autoRound.TargetWP .. "' tidak ditemukan!")
                end
            end
        end
    end)
end)

-- Round End: matikan fitur farming
v_onRoundEnd.Event:Connect(function()
    pcall(function()
        if not v_autoRound.Enabled then return end
        if v_autoRound.AutoFarm then
            v17 = false
            v31("🔄 Round End → Auto Farm OFF")
        end
        if v_autoRound.AutoRevive then
            v18 = false
            v31("🔄 Round End → Auto Revive OFF")
        end
        v31("⏱️ Round selesai (timer habis)", 3)
    end)
end)

--// ============================================================
--// RAYFIELD SETUP
--// ============================================================

local v90 = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local v91 = v90:CreateWindow({
    Name = "⚡ Azaya GUI X  •  Evade",
    LoadingTitle = "Azaya Interface Suite",
    LoadingSubtitle = "by Azaya  •  v4",
    ConfigurationSaving = { Enabled = true, FolderName = "AzayaGUI", FileName = "EvadeConfig" },
    Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = false
})

--// ============================================================
--// TAB: PLAYER
--// ============================================================

local v92 = v91:CreateTab("🏠 Player", nil)

v92:CreateSection("✈️ Movement")

v92:CreateToggle({ Name = "Fly", CurrentValue = false, Flag = "ToggleFly",
    Callback = function(p1) v33(p1) end })

v92:CreateSlider({ Name = "Fly Speed", Range = {1,300}, Increment = 1,
    Suffix = " studs/s", CurrentValue = 120, Flag = "SliderFlySpeed",
    Callback = function(p1) v14.FlySpeed = p1 end })

v92:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "ToggleNoclip",
    Callback = function(p1) v16 = p1 end })

v92:CreateSection("🧍 Character")

v92:CreateToggle({ Name = "Auto Respawn", CurrentValue = false, Flag = "ToggleRespawn",
    Callback = function(p1) v21 = p1 end })

v92:CreateButton({ Name = "Teleport Out of Map", Callback = function() v68() end })

--// ============================================================
--// TAB: AUTO FARM
--// ============================================================

local v95 = v91:CreateTab("🌾 Auto Farm", nil)

v95:CreateSection("🏆 Win Farming")

v95:CreateToggle({ Name = "Auto Farm Win  (Hover Sky)", CurrentValue = false, Flag = "ToggleFarmWin",
    Callback = function(p1)
        v17 = p1
        if p1 then v31("🌾 Auto Farm aktif — terbang ke langit...") else v31("Auto Farm dimatikan") end
    end })

v95:CreateSlider({ Name = "Hover Height", Range = {50,1000}, Increment = 10,
    Suffix = " studs", CurrentValue = 250, Flag = "SliderHoverHeight",
    Callback = function(p1) v14.HoverHeight = p1 end })

v95:CreateSection("🤝 Team Support")

v95:CreateToggle({ Name = "Auto Revive", CurrentValue = false, Flag = "ToggleRevive",
    Callback = function(p1) v18 = p1 end })

v95:CreateSection("🗺️ Utility")

v95:CreateToggle({ Name = "Auto Map Vote", CurrentValue = false, Flag = "ToggleVote",
    Callback = function(p1) v19 = p1 end })

v95:CreateToggle({ Name = "Auto Whistle", CurrentValue = false, Flag = "ToggleWhistle",
    Callback = function(p1) v20 = p1 end })

--// ============================================================
--// TAB: VISUALS
--// ============================================================

local v97 = v91:CreateTab("👁️ Visuals", nil)

v97:CreateSection("ESP")

v97:CreateToggle({ Name = "ESP Player  (Hijau)", CurrentValue = false, Flag = "ToggleESPPlayer",
    Callback = function(p1) v22 = p1 end })

v97:CreateToggle({ Name = "ESP Entity  (Merah)", CurrentValue = false, Flag = "ToggleESPEntity",
    Callback = function(p1) v23 = p1 end })

v97:CreateButton({ Name = "Clear ESP", Callback = function()
    v61() v22 = false v23 = false v31("ESP dihapus")
end })

--// ============================================================
--// TAB: AUTO ROUND
--// ============================================================

local v_tabRound = v91:CreateTab("🔄 Auto Round", nil)

v_tabRound:CreateSection("⚙️ Master Switch")

v_tabRound:CreateToggle({
    Name = "Enable Auto Round",
    CurrentValue = false,
    Flag = "ToggleAutoRound",
    Callback = function(p1)
        v_autoRound.Enabled = p1
        if p1 then
            v31("🔄 Auto Round aktif!\nMenunggu spawn berikutnya...", 4)
        else
            v31("Auto Round dimatikan")
        end
    end
})

v_tabRound:CreateSection("🚀 Aksi saat Round Start")

v_tabRound:CreateToggle({
    Name = "Auto Fly",
    CurrentValue = false,
    Flag = "ToggleRoundFly",
    Callback = function(p1) v_autoRound.AutoFly = p1 end
})

v_tabRound:CreateToggle({
    Name = "Auto Farm Win",
    CurrentValue = false,
    Flag = "ToggleRoundFarm",
    Callback = function(p1) v_autoRound.AutoFarm = p1 end
})

v_tabRound:CreateToggle({
    Name = "Auto Revive",
    CurrentValue = false,
    Flag = "ToggleRoundRevive",
    Callback = function(p1) v_autoRound.AutoRevive = p1 end
})

v_tabRound:CreateToggle({
    Name = "Auto TP ke Waypoint",
    CurrentValue = false,
    Flag = "ToggleRoundTP",
    Callback = function(p1) v_autoRound.AutoTP = p1 end
})

v_tabRound:CreateSection("📍 Target Waypoint")

v_tabRound:CreateLabel("Isi nama waypoint yang sudah disimpan di tab Waypoints.")

v_tabRound:CreateInput({
    Name = "Nama Waypoint Tujuan",
    PlaceholderText = "Contoh: Spawn, Rooftop...",
    RemoveTextAfterFocusLost = false,
    Flag = "InputRoundWP",
    Callback = function(p1) v_autoRound.TargetWP = p1 end
})

v_tabRound:CreateSection("⏱️ Timer Setting")

v_tabRound:CreateLabel("Evade = 3 menit per round. Ubah jika berbeda.")

v_tabRound:CreateSlider({
    Name = "Durasi Round",
    Range = {60, 300},
    Increment = 5,
    Suffix = " detik",
    CurrentValue = 180,
    Flag = "SliderRoundDuration",
    Callback = function(p1) v_roundDuration = p1 end
})

v_tabRound:CreateSlider({
    Name = "Delay setelah Spawn",
    Range = {0, 10},
    Increment = 0.5,
    Suffix = " detik",
    CurrentValue = 2,
    Flag = "SliderRoundDelay",
    Callback = function(p1) v_autoRound.DelaySeconds = p1 end
})

v_tabRound:CreateSection("🧪 Test Manual")

v_tabRound:CreateButton({
    Name = "🔥 Simulasi Round Start",
    Callback = function()
        v_startRoundTimer()
        v31("🔥 Round Start disimulasikan!", 3)
    end
})

v_tabRound:CreateButton({
    Name = "🔥 Simulasi Round End",
    Callback = function()
        if v_roundTimer then task.cancel(v_roundTimer) v_roundTimer = nil end
        v_roundActive = false
        v_onRoundEnd:Fire()
        v31("🔥 Round End disimulasikan!", 3)
    end
})

--// ============================================================
--// CUSTOM WAYPOINT LIST GUI
--// ============================================================

local v_wpGui = Instance.new("ScreenGui")
v_wpGui.Name = "AzayaWPGui"
v_wpGui.ResetOnSpawn = false
v_wpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
v_wpGui.Parent = v8

local v_wpFrame = Instance.new("Frame")
v_wpFrame.Name = "WPFrame"
v_wpFrame.Size = UDim2.new(0, 260, 0, 280)
v_wpFrame.Position = UDim2.new(0.5, -130, 0.5, 20)
v_wpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
v_wpFrame.BorderSizePixel = 0
v_wpFrame.Visible = false
v_wpFrame.Parent = v_wpGui

local v_wpCorner = Instance.new("UICorner")
v_wpCorner.CornerRadius = UDim.new(0, 8)
v_wpCorner.Parent = v_wpFrame

local v_wpStroke = Instance.new("UIStroke")
v_wpStroke.Color = Color3.fromRGB(70, 70, 90)
v_wpStroke.Thickness = 1
v_wpStroke.Parent = v_wpFrame

local v_wpHeader = Instance.new("Frame")
v_wpHeader.Size = UDim2.new(1, 0, 0, 32)
v_wpHeader.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
v_wpHeader.BorderSizePixel = 0
v_wpHeader.Parent = v_wpFrame

local v_wpHCorner = Instance.new("UICorner")
v_wpHCorner.CornerRadius = UDim.new(0, 8)
v_wpHCorner.Parent = v_wpHeader

local v_wpTitle = Instance.new("TextLabel")
v_wpTitle.Size = UDim2.new(1, -10, 1, 0)
v_wpTitle.Position = UDim2.new(0, 10, 0, 0)
v_wpTitle.BackgroundTransparency = 1
v_wpTitle.Text = "📍 Waypoint List"
v_wpTitle.TextColor3 = Color3.fromRGB(220, 220, 240)
v_wpTitle.TextSize = 13
v_wpTitle.Font = Enum.Font.GothamBold
v_wpTitle.TextXAlignment = Enum.TextXAlignment.Left
v_wpTitle.Parent = v_wpHeader

local v_wpModeLabel = Instance.new("TextLabel")
v_wpModeLabel.Size = UDim2.new(1, -10, 1, 0)
v_wpModeLabel.Position = UDim2.new(0, 0, 0, 0)
v_wpModeLabel.BackgroundTransparency = 1
v_wpModeLabel.Text = "Mode: TP"
v_wpModeLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
v_wpModeLabel.TextSize = 11
v_wpModeLabel.Font = Enum.Font.Gotham
v_wpModeLabel.TextXAlignment = Enum.TextXAlignment.Right
v_wpModeLabel.Size = UDim2.new(1, -10, 1, 0)
v_wpModeLabel.Parent = v_wpHeader

local v_wpScroll = Instance.new("ScrollingFrame")
v_wpScroll.Size = UDim2.new(1, -10, 1, -42)
v_wpScroll.Position = UDim2.new(0, 5, 0, 37)
v_wpScroll.BackgroundTransparency = 1
v_wpScroll.BorderSizePixel = 0
v_wpScroll.ScrollBarThickness = 3
v_wpScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
v_wpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
v_wpScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
v_wpScroll.Parent = v_wpFrame

local v_wpList = Instance.new("UIListLayout")
v_wpList.SortOrder = Enum.SortOrder.LayoutOrder
v_wpList.Padding = UDim.new(0, 4)
v_wpList.Parent = v_wpScroll

local v_wpPad = Instance.new("UIPadding")
v_wpPad.PaddingTop = UDim.new(0, 4)
v_wpPad.Parent = v_wpScroll

local v_wpMode = "tp"
local v_wpRows = {}

local function v_wpMakeRow(p1)
    if v_wpRows[p1] then return end

    local v_row = Instance.new("Frame")
    v_row.Name = "WP_" .. p1
    v_row.Size = UDim2.new(1, 0, 0, 36)
    v_row.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    v_row.BorderSizePixel = 0
    v_row.Parent = v_wpScroll

    local v_rowCorner = Instance.new("UICorner")
    v_rowCorner.CornerRadius = UDim.new(0, 6)
    v_rowCorner.Parent = v_row

    local v_nameLabel = Instance.new("TextLabel")
    v_nameLabel.Size = UDim2.new(1, -80, 1, 0)
    v_nameLabel.Position = UDim2.new(0, 10, 0, 0)
    v_nameLabel.BackgroundTransparency = 1
    v_nameLabel.Text = "📍 " .. p1
    v_nameLabel.TextColor3 = Color3.fromRGB(210, 210, 230)
    v_nameLabel.TextSize = 12
    v_nameLabel.Font = Enum.Font.Gotham
    v_nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    v_nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    v_nameLabel.Parent = v_row

    local v_actBtn = Instance.new("TextButton")
    v_actBtn.Size = UDim2.new(0, 46, 0, 24)
    v_actBtn.Position = UDim2.new(1, -78, 0.5, -12)
    v_actBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    v_actBtn.BorderSizePixel = 0
    v_actBtn.Text = "TP"
    v_actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    v_actBtn.TextSize = 11
    v_actBtn.Font = Enum.Font.GothamBold
    v_actBtn.Parent = v_row

    local v_actCorner = Instance.new("UICorner")
    v_actCorner.CornerRadius = UDim.new(0, 5)
    v_actCorner.Parent = v_actBtn

    local v_delBtn = Instance.new("TextButton")
    v_delBtn.Size = UDim2.new(0, 24, 0, 24)
    v_delBtn.Position = UDim2.new(1, -28, 0.5, -12)
    v_delBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    v_delBtn.BorderSizePixel = 0
    v_delBtn.Text = "✕"
    v_delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    v_delBtn.TextSize = 11
    v_delBtn.Font = Enum.Font.GothamBold
    v_delBtn.Parent = v_row

    local v_delCorner = Instance.new("UICorner")
    v_delCorner.CornerRadius = UDim.new(0, 5)
    v_delCorner.Parent = v_delBtn

    v_actBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if v_wpMode == "tp" then
                local _, _, r = v27()
                if not r then return end
                local pos = v_wpData[p1]
                if not pos then return end
                r.CFrame = CFrame.new(pos)
                v31("📍 TP ke " .. p1)
            else
                v_placeTeleporter(p1)
            end
        end)
    end)

    v_delBtn.MouseButton1Click:Connect(function()
        pcall(function()
            v_wpDelete(p1)
            v_row:Destroy()
            v_wpRows[p1] = nil
            v31("🗑️ '" .. p1 .. "' dihapus")
        end)
    end)

    v_wpRows[p1] = v_row
end

local function v_wpRefreshMode()
    for name, row in pairs(v_wpRows) do
        for _, child in pairs(row:GetChildren()) do
            if child:IsA("TextButton") and child.Text ~= "✕" then
                if v_wpMode == "tp" then
                    child.Text = "TP"
                    child.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                else
                    child.Text = "⚡"
                    child.BackgroundColor3 = Color3.fromRGB(140, 80, 200)
                end
            end
        end
    end
    if v_wpMode == "tp" then
        v_wpModeLabel.Text = "Mode: TP"
        v_wpModeLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
    else
        v_wpModeLabel.Text = "Mode: Place Teleporter"
        v_wpModeLabel.TextColor3 = Color3.fromRGB(180, 130, 255)
    end
end

--// Draggable
local v_dragging = false
local v_dragStart = nil
local v_startPos = nil

v_wpHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        v_dragging = true
        v_dragStart = input.Position
        v_startPos = v_wpFrame.Position
    end
end)

v_wpHeader.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        v_dragging = false
    end
end)

v3.InputChanged:Connect(function(input)
    if v_dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - v_dragStart
        v_wpFrame.Position = UDim2.new(
            v_startPos.X.Scale,
            v_startPos.X.Offset + delta.X,
            v_startPos.Y.Scale,
            v_startPos.Y.Offset + delta.Y
        )
    end
end)

--// ============================================================
--// TAB: WAYPOINTS
--// ============================================================

local v99 = v91:CreateTab("📍 Waypoints", nil)

v99:CreateSection("💾 Simpan Posisi")
v99:CreateLabel("Waypoint tersimpan permanen — dibaca otomatis tiap run.")

local v_wpNameInput = ""

v99:CreateInput({
    Name = "Nama Waypoint",
    PlaceholderText = "Contoh: Spawn, Rooftop...",
    RemoveTextAfterFocusLost = false,
    Flag = "InputWaypointName",
    Callback = function(p1) v_wpNameInput = p1 end,
})

v99:CreateButton({ Name = "💾  Save Current Position", Callback = function()
    pcall(function()
        if v_wpNameInput == "" then v31("⚠️ Isi nama waypoint dulu!") return end
        local _, _, r = v27()
        if not r then v31("❌ Character tidak ditemukan!") return end
        local pos = r.Position
        local isNew = (v_wpData[v_wpNameInput] == nil)
        v_wpAdd(v_wpNameInput, pos)
        if isNew then v_wpMakeRow(v_wpNameInput) end
        v31("✅ '" .. v_wpNameInput .. "' disimpan!\nX:" .. math.floor(pos.X) .. " Y:" .. math.floor(pos.Y) .. " Z:" .. math.floor(pos.Z), 4)
        v_wpNameInput = ""
    end)
end })

v99:CreateSection("📋 List Waypoint")
v99:CreateLabel("Buka panel list dengan tombol di bawah.")

v99:CreateButton({ Name = "📋  Tampilkan / Sembunyikan List", Callback = function()
    v_wpMode = "tp"
    v_wpRefreshMode()
    v_wpTitle.Text = "📍 Waypoint List  —  TP Mode"
    v_wpFrame.Visible = not v_wpFrame.Visible
end })

v99:CreateSection("🗑️ Clear All")
v99:CreateButton({ Name = "🧹  Clear All Waypoints", Callback = function()
    pcall(function()
        for name, row in pairs(v_wpRows) do
            row:Destroy()
        end
        v_wpRows = {}
        v_wpData = {}
        v_wpOrder = {}
        v_wpSave()
        v31("🧹 Semua waypoint dihapus.", 4)
    end)
end })

--// ============================================================
--// TAB: TELEPORTER
--// ============================================================

local v_tabTP = v91:CreateTab("🛸 Teleporter", nil)

v_tabTP:CreateSection("⚙️ Cara Pakai")
v_tabTP:CreateLabel("Pastikan kamu punya item Teleporter di loadout.")
v_tabTP:CreateLabel("Klik tombol ⚡ di list → karakter TP → Teleporter di-place otomatis.")

v_tabTP:CreateButton({ Name = "🛸  Tampilkan / Sembunyikan List", Callback = function()
    v_wpMode = "place"
    v_wpRefreshMode()
    v_wpTitle.Text = "🛸 Teleporter List  —  Place Mode"
    v_wpFrame.Visible = not v_wpFrame.Visible
end })

--// ============================================================
--// LOAD ROWS DARI FILE
--// ============================================================

for _, name in ipairs(v_wpOrder) do
    v_wpMakeRow(name)
end

--// ============================================================
--// NOTIFY LOADED
--// ============================================================

v31("⚡ Azaya GUI X v4 loaded!\n" .. #v_wpOrder .. " waypoint dimuat.", 4)

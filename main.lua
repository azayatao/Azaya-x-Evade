-- https://lua.expert/
--// Azaya GUI X - v3 | Evade Edition
--// Xeno & Delta Compatible
--// Features: Fly, Noclip, ESP, Auto Farm, Permanent Waypoints, Auto Put Teleporter

--// Services
local v1 = game:GetService("Players")
local v2 = game:GetService("RunService")
local v3 = game:GetService("UserInputService")
local v4 = game:GetService("ReplicatedStorage")
local v5 = game:GetService("Workspace")
local v6 = game:GetService("VirtualUser")
local v7 = game:GetService("TeleportService")
local v8 = game:GetService("CoreGui")

--// Player
local v9 = v1.LocalPlayer

--// Anti Duplicate
pcall(function()
    if v8:FindFirstChild("AzayaGUI") then
        v8.AzayaGUI:Destroy()
    end
end)

--// Remotes
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil

pcall(function()
    local vTemp = v4:WaitForChild("Events")
    v10 = vTemp:WaitForChild("Data"):WaitForChild("RequestMap")
    v11 = vTemp:WaitForChild("Character"):WaitForChild("VerifyRange")
    v12 = vTemp:WaitForChild("Character"):WaitForChild("GetStarterInfo")
    v13 = vTemp:WaitForChild("Data"):WaitForChild("Get")
end)

--// DeployableUsed Remote
local v_deployRemote = nil
pcall(function()
    v_deployRemote = v4:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("DeployableUsed")
end)

--// Config
local v14 = {
    FlySpeed = 120,
    HoverHeight = 250,
    FarmDistance = 10
}

--// Feature States
local v15 = false -- Fly
local v16 = false -- Noclip
local v17 = false -- Auto Farm Win
local v18 = false -- Auto Farm Revive
local v19 = false -- Auto Map Vote
local v20 = false -- Auto Whistle
local v21 = false -- Auto Respawn
local v22 = false -- ESP Player
local v23 = false -- ESP Entity

--// Fly Objects
local v24 = nil
local v25 = nil

--// ESP Cache
local v26 = {}

--// ============================================================
--// WAYPOINT SYSTEM (Permanent)
--// ============================================================

local v_wpFolder = "AzayaGUI"
local v_wpFile   = "AzayaGUI/waypoints.txt"
local v_wpData   = {} -- { name = Vector3 }
local v_wpOrder  = {} -- urutan simpan

--// Pastikan folder ada
pcall(function()
    if not isfolder(v_wpFolder) then
        makefolder(v_wpFolder)
    end
end)

--// Parse file ke table
local function v_wpLoad()
    pcall(function()
        if not isfile(v_wpFile) then return end
        local v_raw = readfile(v_wpFile)
        for v_line in v_raw:gmatch("[^\n]+") do
            local v_n, v_x, v_y, v_z = v_line:match("^(.+)|(-?[%d%.]+)|(-?[%d%.]+)|(-?[%d%.]+)$")
            if v_n and v_x and v_y and v_z then
                v_wpData[v_n] = Vector3.new(tonumber(v_x), tonumber(v_y), tonumber(v_z))
                table.insert(v_wpOrder, v_n)
            end
        end
    end)
end

--// Tulis ulang file dari table
local function v_wpSave()
    pcall(function()
        local v_out = ""
        for _, v_n in ipairs(v_wpOrder) do
            if v_wpData[v_n] then
                local v_pos = v_wpData[v_n]
                v_out = v_out .. v_n .. "|" .. math.floor(v_pos.X*100)/100 .. "|" .. math.floor(v_pos.Y*100)/100 .. "|" .. math.floor(v_pos.Z*100)/100 .. "\n"
            end
        end
        writefile(v_wpFile, v_out)
    end)
end

--// Tambah waypoint baru
local function v_wpAdd(p1, p2)
    if v_wpData[p1] then
        -- update existing
        v_wpData[p1] = p2
    else
        v_wpData[p1] = p2
        table.insert(v_wpOrder, p1)
    end
    v_wpSave()
end

--// Hapus waypoint
local function v_wpDelete(p1)
    v_wpData[p1] = nil
    for v_i, v_n in ipairs(v_wpOrder) do
        if v_n == p1 then
            table.remove(v_wpOrder, v_i)
            break
        end
    end
    v_wpSave()
end

--// Load saat startup
v_wpLoad()

--// ============================================================
--// CHARACTER HELPER
--// ============================================================

local function v27()
    local v28 = nil
    local v29 = nil
    local v30 = nil
    pcall(function()
        if v9 then
            v28 = v9.Character
            if v28 then
                v29 = v28:FindFirstChild("Humanoid")
                v30 = v28:FindFirstChild("HumanoidRootPart")
            end
        end
    end)
    return v28, v29, v30
end

--// ============================================================
--// NOTIFY
--// ============================================================

local function v31(p1, p2)
    pcall(function()
        print("[Azaya X]:", p1)
        if Rayfield then
            Rayfield:Notify({
                Title = "Azaya X",
                Content = p1,
                Duration = p2 or 3,
                Image = 4483345998
            })
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
        local _, _, v36 = v27()
        if not v36 then return end
        if v15 then
            v32()
            v25 = Instance.new("Attachment")
            v25.Parent = v36
            v24 = Instance.new("LinearVelocity")
            v24.Name = "AzayaFlyVelocity"
            v24.Attachment0 = v25
            v24.RelativeTo = Enum.ActuatorRelativeTo.World
            v24.ForceLimitsEnabled = false
            v24.VectorVelocity = Vector3.zero
            v24.Parent = v36
            v31("✈️ Fly aktif")
        else
            v32()
            v31("Fly dimatikan")
        end
    end)
end

v2.RenderStepped:Connect(function()
    pcall(function()
        if not v15 then return end
        if v17 then return end
        local v37 = workspace.CurrentCamera
        if not v37 then return end
        local _, _, v40 = v27()
        if not v40 then return end
        if not v24 or not v24.Parent then
            if v15 then v33(true) end
        end
        local v41 = Vector3.zero
        if v3:IsKeyDown(Enum.KeyCode.W) then v41 += v37.CFrame.LookVector end
        if v3:IsKeyDown(Enum.KeyCode.S) then v41 -= v37.CFrame.LookVector end
        if v3:IsKeyDown(Enum.KeyCode.A) then v41 -= v37.CFrame.RightVector end
        if v3:IsKeyDown(Enum.KeyCode.D) then v41 += v37.CFrame.RightVector end
        if v3:IsKeyDown(Enum.KeyCode.Space) then v41 += Vector3.new(0,1,0) end
        if v3:IsKeyDown(Enum.KeyCode.LeftControl) then v41 -= Vector3.new(0,1,0) end
        if v41.Magnitude > 0 then v41 = v41.Unit * v14.FlySpeed end
        if v24 then v24.VectorVelocity = v41 end
    end)
end)

v9.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(function()
        if v15 then v33(true) end
    end)
end)

--// ============================================================
--// NOCLIP
--// ============================================================

v2.Stepped:Connect(function()
    pcall(function()
        if not v16 then return end
        local v42 = v9.Character
        if not v42 then return end
        for _, v44 in pairs(v42:GetDescendants()) do
            if v44:IsA("BasePart") then
                v44.CanCollide = false
            end
        end
    end)
end)

--// ============================================================
--// AUTO FARM WIN (HOVER)
--// ============================================================

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not v17 then return end
            local _, _, v47 = v27()
            if not v47 then return end
            if not v15 then v33(true) end
            local v48 = Vector3.new(v47.Position.X, v14.HoverHeight, v47.Position.Z)
            local v49 = (v48 - v47.Position)
            if v49.Magnitude > v14.FarmDistance then
                if v24 then v24.VectorVelocity = v49.Unit * v14.FlySpeed end
            else
                if v24 then v24.VectorVelocity = Vector3.zero end
                v47.AssemblyAngularVelocity = Vector3.zero
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
            local _, _, v52 = v27()
            if not v52 then return end
            for _, v54 in pairs(v1:GetPlayers()) do
                if v54 ~= v9 and v54.Character then
                    local v55 = v54.Character:FindFirstChild("Humanoid")
                    local v56 = v54.Character:FindFirstChild("HumanoidRootPart")
                    if v55 and v56 and v55.Health <= 0 then
                        v52.CFrame = v56.CFrame
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
            if not v19 then return end
            if v10 then
                local v57 = v10:InvokeServer()
                if typeof(v57) == "table" then
                    v10:InvokeServer(v57[1])
                end
            end
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
            local v58 = v4:FindFirstChild("Whistle", true)
            if v58 then v58:InvokeServer() end
        end)
    end
end)

--// ============================================================
--// AUTO RESPAWN
--// ============================================================

v9.CharacterAdded:Connect(function(p1)
    pcall(function()
        local v59 = p1:WaitForChild("Humanoid")
        v59.Died:Connect(function()
            if v21 then
                task.wait(2)
                v9:LoadCharacter()
            end
        end)
    end)
end)

--// ============================================================
--// ESP
--// ============================================================

local function v_espCreate(p1, p2)
    pcall(function()
        if not p1 then return end
        if p1:FindFirstChild("AzayaESP") then return end
        local v60 = Instance.new("Highlight")
        v60.Name = "AzayaESP"
        v60.FillColor = p2
        v60.OutlineColor = p2
        v60.FillTransparency = 0.5
        v60.Parent = p1
        table.insert(v26, v60)
    end)
end

local function v61()
    pcall(function()
        for _, v63 in pairs(v26) do
            if v63 then v63:Destroy() end
        end
        v26 = {}
    end)
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not v22 and not v23 then v61() return end
            if v22 then
                for _, v65 in pairs(v1:GetPlayers()) do
                    if v65 ~= v9 and v65.Character then
                        v_espCreate(v65.Character, Color3.fromRGB(0, 255, 0))
                    end
                end
            end
            if v23 then
                for _, v67 in pairs(v5:GetChildren()) do
                    if v67:IsA("Model") and v67:FindFirstChild("Humanoid") then
                        if not v1:GetPlayerFromCharacter(v67) then
                            v_espCreate(v67, Color3.fromRGB(255, 0, 0))
                        end
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
        local _, _, v71 = v27()
        if not v71 then return end
        v71.CFrame = CFrame.new(0, -500, 0)
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
    -- p1 = nama waypoint
    pcall(function()
        local v_pos = v_wpData[p1]
        if not v_pos then
            v31("❌ Waypoint tidak ditemukan!")
            return
        end

        local _, _, v_hrp = v27()
        if not v_hrp then
            v31("❌ Character tidak ditemukan!")
            return
        end

        v31("🔄 Placing teleporter di " .. p1 .. "...")

        -- 1. TP ke posisi waypoint
        v_hrp.CFrame = CFrame.new(v_pos)
        task.wait(0.3)

        -- 2. Tilt kamera ke bawah agar placement valid (tidak merah)
        local v_cam = workspace.CurrentCamera
        if v_cam then
            local v_camPos = v_hrp.Position + Vector3.new(0, 2, 0)
            local v_lookDown = CFrame.new(v_camPos, v_camPos + Vector3.new(0, -1, 1))
            v_cam.CFrame = v_lookDown
        end
        task.wait(0.2)

        -- 3. Fire DeployableUsed untuk equip/preview Teleporter
        if v_deployRemote then
            v_deployRemote:FireServer("Teleporter", true)
        end
        task.wait(0.3)

        -- 4. Simulate mouse click untuk confirm placement
        mouse1click()

        task.wait(0.2)
        v31("✅ Teleporter placed di " .. p1)
    end)
end

--// ============================================================
--// RAYFIELD GUI
--// ============================================================

local v90 = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local v91 = v90:CreateWindow({
    Name = "⚡ Azaya GUI X  •  Evade",
    LoadingTitle = "Azaya Interface Suite",
    LoadingSubtitle = "by Azaya • v3",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AzayaGUI",
        FileName = "EvadeConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

--// ============================================================
--// TAB: PLAYER
--// ============================================================

local v92 = v91:CreateTab("🏠 Player", nil)

v92:CreateSection("✈️ Movement")

v92:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "ToggleFly",
    Callback = function(p1)
        v33(p1)
    end,
})

v92:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 300},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 120,
    Flag = "SliderFlySpeed",
    Callback = function(p1)
        v14.FlySpeed = p1
    end,
})

v92:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "ToggleNoclip",
    Callback = function(p1)
        v16 = p1
    end,
})

v92:CreateSection("🧍 Character")

v92:CreateToggle({
    Name = "Auto Respawn",
    CurrentValue = false,
    Flag = "ToggleRespawn",
    Callback = function(p1)
        v21 = p1
    end,
})

v92:CreateButton({
    Name = "Teleport Out of Map",
    Callback = function()
        v68()
    end,
})

--// ============================================================
--// TAB: AUTO FARM
--// ============================================================

local v95 = v91:CreateTab("🌾 Auto Farm", nil)

v95:CreateSection("🏆 Win Farming")

v95:CreateToggle({
    Name = "Auto Farm Win  (Hover Sky)",
    CurrentValue = false,
    Flag = "ToggleFarmWin",
    Callback = function(p1)
        v17 = p1
        if p1 then
            v31("🌾 Auto Farm aktif — terbang ke langit...")
        else
            v31("Auto Farm dimatikan")
        end
    end,
})

v95:CreateSlider({
    Name = "Hover Height",
    Range = {50, 1000},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 250,
    Flag = "SliderHoverHeight",
    Callback = function(p1)
        v14.HoverHeight = p1
    end,
})

v95:CreateSection("🤝 Team Support")

v95:CreateToggle({
    Name = "Auto Revive",
    CurrentValue = false,
    Flag = "ToggleRevive",
    Callback = function(p1)
        v18 = p1
    end,
})

v95:CreateSection("🗺️ Utility")

v95:CreateToggle({
    Name = "Auto Map Vote",
    CurrentValue = false,
    Flag = "ToggleVote",
    Callback = function(p1)
        v19 = p1
    end,
})

v95:CreateToggle({
    Name = "Auto Whistle",
    CurrentValue = false,
    Flag = "ToggleWhistle",
    Callback = function(p1)
        v20 = p1
    end,
})

--// ============================================================
--// TAB: VISUALS
--// ============================================================

local v97 = v91:CreateTab("👁️ Visuals", nil)

v97:CreateSection("ESP")

v97:CreateToggle({
    Name = "ESP Player  (Hijau)",
    CurrentValue = false,
    Flag = "ToggleESPPlayer",
    Callback = function(p1)
        v22 = p1
    end,
})

v97:CreateToggle({
    Name = "ESP Entity  (Merah)",
    CurrentValue = false,
    Flag = "ToggleESPEntity",
    Callback = function(p1)
        v23 = p1
    end,
})

v97:CreateButton({
    Name = "Clear ESP",
    Callback = function()
        v61()
        v22 = false
        v23 = false
        v31("ESP dihapus")
    end,
})

--// ============================================================
--// TAB: WAYPOINTS
--// ============================================================

local v99 = v91:CreateTab("📍 Waypoints", nil)

v99:CreateSection("💾 Simpan Posisi")

--// Label info
v99:CreateLabel("Waypoint tersimpan permanen di file lokal.")

local v_wpNameInput = ""

v99:CreateInput({
    Name = "Nama Waypoint",
    PlaceholderText = "Contoh: Spawn, Rooftop...",
    RemoveTextAfterFocusLost = false,
    Flag = "InputWaypointName",
    Callback = function(p1)
        v_wpNameInput = p1
    end,
})

--// Tab teleporter (forward declare, diisi setelah tab dibuat)
local v_tabTP = nil

--// Fungsi buat button waypoint + button teleporter (dipanggil saat load & saat save baru)
local function v_makeWpButtons(p1)
    -- Button di tab Waypoints
    v99:CreateButton({
        Name = "🔵 TP: " .. p1,
        Callback = function()
            pcall(function()
                local _, _, v_hrp = v27()
                if not v_hrp then return end
                local v_pos = v_wpData[p1]
                if not v_pos then return end
                v_hrp.CFrame = CFrame.new(v_pos)
                v31("📍 Teleported ke " .. p1)
            end)
        end,
    })
    -- Button di tab Auto Put Teleporter (jika sudah ada)
    if v_tabTP then
        v_tabTP:CreateButton({
            Name = "🛸 Place di: " .. p1,
            Callback = function()
                v_placeTeleporter(p1)
            end,
        })
    end
end

v99:CreateButton({
    Name = "💾  Save Current Position",
    Callback = function()
        pcall(function()
            if v_wpNameInput == "" then
                v31("⚠️ Isi nama waypoint dulu!")
                return
            end
            local _, _, v_hrp = v27()
            if not v_hrp then
                v31("❌ Character tidak ditemukan!")
                return
            end
            local v_pos = v_hrp.Position
            local v_isNew = (v_wpData[v_wpNameInput] == nil)
            v_wpAdd(v_wpNameInput, v_pos)
            if v_isNew then
                v_makeWpButtons(v_wpNameInput)
            end
            v31("✅ '" .. v_wpNameInput .. "' disimpan!\nX:" .. math.floor(v_pos.X) .. " Y:" .. math.floor(v_pos.Y) .. " Z:" .. math.floor(v_pos.Z), 4)
            v_wpNameInput = ""
        end)
    end,
})

v99:CreateSection("🗑️ Kelola Waypoint")

v99:CreateButton({
    Name = "❌  Hapus Waypoint (by nama)",
    Callback = function()
        pcall(function()
            if v_wpNameInput == "" then
                v31("⚠️ Isi nama waypoint yang ingin dihapus di input!")
                return
            end
            if not v_wpData[v_wpNameInput] then
                v31("❌ Waypoint '" .. v_wpNameInput .. "' tidak ditemukan!")
                return
            end
            v_wpDelete(v_wpNameInput)
            v31("🗑️ '" .. v_wpNameInput .. "' dihapus.\nReload script untuk refresh tombol.", 4)
            v_wpNameInput = ""
        end)
    end,
})

v99:CreateButton({
    Name = "🧹  Clear All Waypoints",
    Callback = function()
        pcall(function()
            v_wpData = {}
            v_wpOrder = {}
            v_wpSave()
            v31("🧹 Semua waypoint dihapus.\nReload script untuk refresh tombol.", 4)
        end)
    end,
})

--// ============================================================
--// TAB: AUTO PUT TELEPORTER
--// ============================================================

v_tabTP = v91:CreateTab("🛸 Teleporter", nil)

v_tabTP:CreateSection("⚙️ Cara Pakai")
v_tabTP:CreateLabel("Klik tombol di bawah → karakter TP ke waypoint → Teleporter otomatis di-place.")
v_tabTP:CreateLabel("Pastikan kamu punya item Teleporter di loadout.")

v_tabTP:CreateSection("📍 Pilih Waypoint")

--// Load waypoint yang sudah ada saat startup (untuk kedua tab)
for _, v_n in ipairs(v_wpOrder) do
    v_makeWpButtons(v_n)
end

--// ============================================================
--// NOTIFY LOADED
--// ============================================================

local v_wpCount = #v_wpOrder
v31("⚡ Azaya GUI X v3 loaded!\n" .. v_wpCount .. " waypoint dimuat.", 4)

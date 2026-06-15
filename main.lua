-- https://lua.expert/
--// Azaya GUI X - Rayfield Edition (Hover + Dynamic Waypoints)
--// Optimized for Xeno & Evade

--// Services (v1 - v8)
local v1 = game:GetService("Players")
local v2 = game:GetService("RunService")
local v3 = game:GetService("UserInputService")
local v4 = game:GetService("ReplicatedStorage")
local v5 = game:GetService("Workspace")
local v6 = game:GetService("VirtualUser")
local v7 = game:GetService("TeleportService")
local v8 = game:GetService("CoreGui")

--// Player (v9)
local v9 = v1.LocalPlayer

--// Anti Duplicate GUI
pcall(function()
    if v8:FindFirstChild("AzayaGUI") then
        v8.AzayaGUI:Destroy()
    end
end)

--// Remotes (v10 - v13)
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

--// Config (v14)
local v14 = {
    FlySpeed = 120,
    HoverHeight = 250,
    FarmDistance = 10
}

--// Feature States (v15 - v23)
local v15 = false -- Fly
local v16 = false -- Noclip
local v17 = false -- Auto Farm Win
local v18 = false -- Auto Farm Revive
local v19 = false -- Auto Map Vote
local v20 = false -- Auto Whistle
local v21 = false -- Auto Respawn
local v22 = false -- ESP Player
local v23 = false -- ESP Entity

--// Fly Objects (v24 - v25)
local v24 = nil
local v25 = nil

--// ESP Cache (v26)
local v26 = {}

--// Waypoint Storage (v27_wp)
local v27_wp = {}
local v27_name = ""

--// Character Helper
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

--// Notify
local function v31(p1)
    pcall(function()
        print("[Azaya X]:", p1)
        if Rayfield then
            Rayfield:Notify({
                Title = "Azaya X",
                Content = p1,
                Duration = 3,
                Image = 4483345998
            })
        end
    end)
end

--// Remove Fly
local function v32()
    pcall(function()
        if v24 then v24:Destroy() v24 = nil end
        if v25 then v25:Destroy() v25 = nil end
    end)
end

--// Toggle Fly
local function v33(p1)
    v15 = p1
    pcall(function()
        local v34, v35, v36 = v27()
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
            v31("Fly Enabled")
        else
            v32()
            v31("Fly Disabled")
        end
    end)
end

--// Fly Loop
v2.RenderStepped:Connect(function()
    pcall(function()
        if not v15 then return end
        if v17 then return end
        local v37 = workspace.CurrentCamera
        if not v37 then return end
        local v38, v39, v40 = v27()
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

--// Recreate Fly After Respawn
v9.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(function()
        if v15 then v33(true) end
    end)
end)

--// Noclip Loop
v2.Stepped:Connect(function()
    pcall(function()
        if not v16 then return end
        local v42 = v9.Character
        if not v42 then return end
        for v43, v44 in pairs(v42:GetDescendants()) do
            if v44:IsA("BasePart") then
                v44.CanCollide = false
            end
        end
    end)
end)

--// Auto Farm Win Loop
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not v17 then return end
            local v45, v46, v47 = v27()
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

--// Auto Farm Revive Loop
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not v18 then return end
            local v50, v51, v52 = v27()
            if not v52 then return end
            for v53, v54 in pairs(v1:GetPlayers()) do
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

--// Auto Map Vote Loop
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

--// Auto Whistle Loop
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            if not v20 then return end
            local v58 = v4:FindFirstChild("Whistle", true)
            if v58 then v58:InvokeServer() end
        end)
    end
end)

--// Auto Respawn Handler
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

--// ESP Create
local function v59(p1, p2)
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

--// Clear ESP
local function v61()
    pcall(function()
        for v62, v63 in pairs(v26) do
            if v63 then v63:Destroy() end
        end
        v26 = {}
    end)
end

--// ESP Loop
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not v22 and not v23 then
                v61()
                return
            end
            if v22 then
                for v64, v65 in pairs(v1:GetPlayers()) do
                    if v65 ~= v9 and v65.Character then
                        v59(v65.Character, Color3.fromRGB(0, 255, 0))
                    end
                end
            end
            if v23 then
                for v66, v67 in pairs(v5:GetChildren()) do
                    if v67:IsA("Model") and v67:FindFirstChild("Humanoid") then
                        if not v1:GetPlayerFromCharacter(v67) then
                            v59(v67, Color3.fromRGB(255, 0, 0))
                        end
                    end
                end
            end
        end)
    end
end)

--// Teleport Out
local function v68()
    pcall(function()
        local v69, v70, v71 = v27()
        if not v71 then return end
        v71.CFrame = CFrame.new(0, -500, 0)
        v31("Teleported Out of Map")
    end)
end

--// Anti AFK
v9.Idled:Connect(function()
    pcall(function()
        v6:CaptureController()
        v6:ClickButton2(Vector2.new())
    end)
end)

--// ==========================================================
--// RAYFIELD GUI SETUP
--// ==========================================================

local v90 = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local v91 = v90:CreateWindow({
    Name = "Azaya GUI X | Hover Mode",
    LoadingTitle = "Azaya Interface",
    LoadingSubtitle = "Optimized for Evade",
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

--// Tab: Player (v92)
local v92 = v91:CreateTab("Player", nil)

v92:CreateSection("Movement")

v92:CreateToggle({
    Name = "Fly (Manual)",
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
    Suffix = "Speed",
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

v92:CreateSlider({
    Name = "Hover Height (Farm Height)",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "Studs",
    CurrentValue = 250,
    Flag = "SliderHoverHeight",
    Callback = function(p1)
        v14.HoverHeight = p1
    end,
})

v92:CreateSection("Character")

v92:CreateToggle({
    Name = "Auto Respawn",
    CurrentValue = false,
    Flag = "ToggleRespawn",
    Callback = function(p1)
        v21 = p1
    end,
})

v92:CreateButton({
    Name = "Teleport Out Map",
    Callback = function()
        v68()
    end,
})

--// Tab: Auto Farm (v95)
local v95 = v91:CreateTab("Auto Farm", nil)

v95:CreateSection("Automation")

v95:CreateToggle({
    Name = "Auto Farm Win (Hover Sky)",
    CurrentValue = false,
    Flag = "ToggleFarmWin",
    Callback = function(p1)
        v17 = p1
        if p1 then v31("Auto Farm: Flying to Sky...") else v31("Auto Farm: Stopped") end
    end,
})

v95:CreateToggle({
    Name = "Auto Farm Revive",
    CurrentValue = false,
    Flag = "ToggleRevive",
    Callback = function(p1)
        v18 = p1
    end,
})

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

--// Tab: Visuals (v97)
local v97 = v91:CreateTab("Visuals", nil)

v97:CreateSection("ESP Settings")

v97:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Flag = "ToggleESPPlayer",
    Callback = function(p1)
        v22 = p1
    end,
})

v97:CreateToggle({
    Name = "ESP Entity",
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
        v31("ESP Cleared")
    end,
})

--// Tab: Waypoints (v99)
local v99 = v91:CreateTab("Waypoints", nil)

v99:CreateSection("Custom Waypoints")

v99:CreateInput({
    Name = "Waypoint Name",
    PlaceholderText = "Ketik nama waypoint...",
    RemoveTextAfterFocusLost = false,
    Flag = "InputWaypointName",
    Callback = function(p1)
        v27_name = p1
    end,
})

--// Fungsi buat button waypoint baru
local function v_addwp(p1)
    v99:CreateButton({
        Name = "TP: " .. p1,
        Callback = function()
            pcall(function()
                local v_ch, v_hm, v_hrp = v27()
                if not v_hrp then return end
                v_hrp.CFrame = CFrame.new(v27_wp[p1])
                v31("Teleported to " .. p1)
            end)
        end,
    })
end

v99:CreateButton({
    Name = "Save Current Position",
    Callback = function()
        pcall(function()
            if v27_name == "" then
                v31("Isi nama waypoint dulu!")
                return
            end
            local v_ch, v_hm, v_hrp = v27()
            if not v_hrp then
                v31("Character tidak ditemukan!")
                return
            end
            local v_pos = v_hrp.Position
            v27_wp[v27_name] = v_pos
            v_addwp(v27_name)
            v31("Waypoint '" .. v27_name .. "' disimpan!")
            v27_name = ""
        end)
    end,
})

v99:CreateButton({
    Name = "Clear All Waypoints",
    Callback = function()
        v27_wp = {}
        v31("Data waypoint dihapus. Re-run script untuk reset tombol.")
    end,
})

--// Notify Loaded
v31("Script Loaded - Hover Mode Ready")

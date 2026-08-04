-- [[ ★ KlNZ HUB by klun.z - TSB V8.1 (Fixed TSB Hotbar UIStroke Error + No Clip) ★ ]] --

-- [[ 1. DỌN DẸP THREAD & VÒNG LẶP CŨ NẾU RE-EXECUTE ]] --
if getgenv().KlNZ_Connections then
    for _, conn in pairs(getgenv().KlNZ_Connections) do
        pcall(function() conn:Disconnect() end)
    end
end
getgenv().KlNZ_Connections = {}
getgenv().KlNZ_Running = false
task.wait(0.1)
getgenv().KlNZ_Running = true

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local p = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ HÀM TÌM CONTAINER LƯU UI AN TOÀN ]] --
local function getSafeParent()
    local parent = nil
    pcall(function() if gethui then parent = gethui() end end)
    if parent then return parent end
    
    pcall(function()
        local core = game:GetService("CoreGui")
        local test = Instance.new("Folder", core)
        test:Destroy()
        parent = core
    end)
    if parent then return parent end
    
    return p:FindFirstChildOfClass("PlayerGui") or p:WaitForChild("PlayerGui", 5)
end

local parentContainer = getSafeParent()
local playerGui = p:FindFirstChildOfClass("PlayerGui") or p:WaitForChild("PlayerGui", 5)

-- [[ AUTO FIX LỖI UISTROKE CỦA TSB HOTBAR (CHỐNG CRASH LINE 2684) ]] --
local hotbarFixThread = task.spawn(function()
    while getgenv().KlNZ_Running do
        pcall(function()
            if playerGui then
                local btnNames = {"-Zero", "-One", "-Two", "-Three", "-Four", "-Five"}
                for _, btnName in pairs(btnNames) do
                    for _, obj in pairs(playerGui:GetDescendants()) do
                        if obj.Name == btnName and (obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("GuiObject")) then
                            if not obj:FindFirstChildOfClass("UIStroke") then
                                local dummyStroke = Instance.new("UIStroke")
                                dummyStroke.Name = "UIStroke"
                                dummyStroke.Thickness = 1
                                dummyStroke.Transparency = 1 -- Ẩn đi để không xấu UI gốc
                                dummyStroke.Parent = obj
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- [[ DỌN DẸP TRIỆT ĐỂ UI CŨ ]] --
local function clearAllOld(name)
    pcall(function()
        if parentContainer then
            for _, v in pairs(parentContainer:GetChildren()) do
                if v.Name == name then v:Destroy() end
            end
        end
        if playerGui then
            for _, v in pairs(playerGui:GetChildren()) do
                if v.Name == name then v:Destroy() end
            end
        end
    end)
end

local oldUINames = {
    "KlNZ_Hub_klunz", "KlNZ_Hub", "klunz_Redz_TSB", "klunz_FPS_Gui", 
    "TSB_Pure_Farm", "klunz_Status_Global", "klunz_Melee_Mini", 
    "klunz_Master_V6", "klunz_Aimbot_Killer"
}
for _, uiName in pairs(oldUINames) do clearAllOld(uiName) end

-- TÔNG MÀU CHỦ ĐẠO: TÍM NEON
local ACCENT_COLOR = Color3.fromRGB(170, 90, 255)
local ACCENT_HEX = "#AA5AFF"

-- [[ BIẾN TRẠNG THÁI & CẤU HÌNH ]] --
local activeFarm = false
local activeEscape1 = false 
local activeESP = true
local systemLock1 = false 
local activeCombat2 = false 
local activeMelee = false 
local activeNoclip = false -- Biến trạng thái No Clip
local currentTarget = nil
local _HITBOX_SIZE = 25 
local _S = math.sqrt(10000) 
local CONFIG1 = { EscapeHP = 25, SafeHP = 90, TargetHP = 30 }
local CONFIG2 = { SelectedTarget = nil }

-- [[ 2. FPS COUNTER ]] --
local fpsGui = Instance.new("ScreenGui", parentContainer); fpsGui.Name = "klunz_FPS_Gui"; fpsGui.ResetOnSpawn = false; fpsGui.DisplayOrder = 9999
local fps = Instance.new("TextLabel", fpsGui)
fps.Size, fps.Position = UDim2.new(0, 80, 0, 24), UDim2.new(0, 10, 0, 10)
fps.BackgroundColor3, fps.BackgroundTransparency = Color3.fromRGB(15, 15, 18), 0.2
fps.Font, fps.TextScaled, fps.Text = Enum.Font.GothamBold, true, "FPS: 0"
fps.TextColor3 = ACCENT_COLOR
Instance.new("UICorner", fps).CornerRadius = UDim.new(0, 6)
local strokeFPS = Instance.new("UIStroke", fps); strokeFPS.Color = ACCENT_COLOR; strokeFPS.Thickness = 1
local frames, last = 0, tick()

-- [[ 3. MAIN GUI LAYOUT ]] --
local mainGui = Instance.new("ScreenGui", parentContainer)
mainGui.Name = "KlNZ_Hub_klunz"
mainGui.ResetOnSpawn = false
mainGui.DisplayOrder = 10000

-- Nút nổi Mở/Tắt Menu
local openBtn = Instance.new("ImageButton", mainGui)
openBtn.Size, openBtn.Position = UDim2.new(0, 55, 0, 55), UDim2.new(0.02, 0, 0.15, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
openBtn.Image = "rbxassetid://90209832041834"
openBtn.ScaleType = Enum.ScaleType.Crop
openBtn.Active, openBtn.Draggable = true, true
openBtn.ZIndex = 100
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", openBtn); openStroke.Color = ACCENT_COLOR; openStroke.Thickness = 2

-- Tải ảnh Potato Queen bất đồng bộ
task.spawn(function()
    pcall(function()
        local objects = game:GetObjects("rbxassetid://90209832041834")
        if objects and objects[1] and objects[1]:IsA("Decal") then
            openBtn.Image = objects[1].Texture
        end
    end)
end)

-- Khung Menu Chính
local mainFrame = Instance.new("Frame", mainGui)
mainFrame.Size, mainFrame.Position = UDim2.new(0, 360, 0, 250), UDim2.new(0.5, -180, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mainFrame.Active, mainFrame.Draggable = true, true
mainFrame.Visible = true
mainFrame.ZIndex = 1
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Color = ACCENT_COLOR; mainStroke.Thickness = 1.5

-- Top Bar
local topBar = Instance.new("Frame", mainFrame)
topBar.Size, topBar.BackgroundColor3 = UDim2.new(1, 0, 0, 35), Color3.fromRGB(22, 22, 28)
topBar.ZIndex = 2
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", topBar)
title.Size, title.Position = UDim2.new(0, 250, 1, 0), UDim2.new(0, 10, 0, 0)
title.Text, title.TextColor3, title.Font, title.TextSize = "KlNZ HUB by klun.z | TSB V8.1", ACCENT_COLOR, Enum.Font.GothamBold, 11
title.BackgroundTransparency, title.TextXAlignment = 1, Enum.TextXAlignment.Left
title.ZIndex = 3

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size, closeBtn.Position = UDim2.new(0, 25, 0, 25), UDim2.new(1, -30, 0, 5)
closeBtn.Text, closeBtn.TextColor3, closeBtn.BackgroundColor3 = "X", Color3.fromRGB(255, 255, 255), Color3.fromRGB(35, 35, 42)
closeBtn.Font, closeBtn.TextSize = Enum.Font.GothamBold, 11
closeBtn.ZIndex = 3
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- Thanh Tab Trái
local sideBar = Instance.new("Frame", mainFrame)
sideBar.Size, sideBar.Position = UDim2.new(0, 100, 1, -35), UDim2.new(0, 0, 0, 35)
sideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sideBar.ZIndex = 2
Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 8)
local sideLayout = Instance.new("UIListLayout", sideBar); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Khung Nội Dung Chứa Trang
local container = Instance.new("Frame", mainFrame)
container.Size, container.Position = UDim2.new(1, -105, 1, -40), UDim2.new(0, 103, 0, 38)
container.BackgroundTransparency = 1
container.ZIndex = 2

local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame", container)
    page.Size, page.Position = UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT_COLOR
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ClipsDescendants = true
    page.Visible = false
    page.ZIndex = 3
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 10)
    
    pages[name] = page
    return page
end

local combatPage = createPage("Combat")
local farmPage = createPage("Farm/Misc")
local targetPage = createPage("Target")
combatPage.Visible = true

local function createTabBtn(name, pageName)
    local tBtn = Instance.new("TextButton", sideBar)
    tBtn.Size = UDim2.new(0.9, 0, 0, 30)
    tBtn.Text, tBtn.TextColor3, tBtn.Font, tBtn.TextSize = name, Color3.fromRGB(180, 180, 180), Enum.Font.GothamBold, 10
    tBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    tBtn.ZIndex = 3
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
    
    tBtn.MouseButton1Click:Connect(function()
        for _, pG in pairs(pages) do pG.Visible = false end
        for _, b in pairs(sideBar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(180, 180, 180) end end
        if pages[pageName] then pages[pageName].Visible = true end
        tBtn.TextColor3 = ACCENT_COLOR
    end)
    return tBtn
end

local tab1 = createTabBtn("⚔️ COMBAT", "Combat"); tab1.TextColor3 = ACCENT_COLOR
createTabBtn("🌾 MISC", "Farm/Misc")
createTabBtn("🎯 TARGET", "Target")

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- [[ THƯ VIỆN CONTROLS UI ]] --
local function AddSection(parent, text)
    local sec = Instance.new("TextLabel", parent)
    sec.Size = UDim2.new(0.95, 0, 0, 20)
    sec.Text, sec.TextColor3, sec.Font, sec.TextSize = text, ACCENT_COLOR, Enum.Font.GothamBold, 10
    sec.BackgroundTransparency, sec.TextXAlignment = 1, Enum.TextXAlignment.Left
    sec.ZIndex = 4
end

local function AddToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    frame.ZIndex = 4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size, txt.Position = UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 8, 0, 0)
    txt.Text, txt.TextColor3, txt.Font, txt.TextSize = text, Color3.fromRGB(220, 220, 220), Enum.Font.Gotham, 10
    txt.BackgroundTransparency, txt.TextXAlignment = 1, Enum.TextXAlignment.Left
    txt.ZIndex = 5
    
    local switch = Instance.new("TextButton", frame)
    switch.Size, switch.Position = UDim2.new(0, 36, 0, 18), UDim2.new(1, -42, 0.5, -9)
    switch.Text = ""
    switch.BackgroundColor3 = default and ACCENT_COLOR or Color3.fromRGB(45, 45, 55)
    switch.ZIndex = 5
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", switch)
    circle.Size, circle.Position = UDim2.new(0, 14, 0, 14), default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.ZIndex = 6
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and ACCENT_COLOR or Color3.fromRGB(45, 45, 55)
        circle:TweenPosition(state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.15, true)
        callback(state)
    end)
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.Text, btn.TextColor3, btn.Font, btn.TextSize = text, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 10
    btn.BackgroundColor3 = ACCENT_COLOR
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

local function AddInput(parent, placeholder, defaultVal, callback)
    local inp = Instance.new("TextBox", parent)
    inp.Size = UDim2.new(0.95, 0, 0, 30)
    inp.PlaceholderText = placeholder
    inp.Text = placeholder .. ": " .. defaultVal
    inp.BackgroundColor3, inp.TextColor3 = Color3.fromRGB(22, 22, 28), Color3.fromRGB(220, 220, 220)
    inp.Font, inp.TextSize = Enum.Font.Gotham, 10
    inp.ZIndex = 4
    Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 6)
    
    inp.FocusLost:Connect(function()
        local val = tonumber(inp.Text:match("%d+")) or tonumber(inp.Text)
        if val then callback(val); inp.Text = placeholder .. ": " .. val else inp.Text = placeholder .. ": " .. defaultVal end
    end)
end

-- [[ TAB 1: COMBAT ]] --
AddSection(combatPage, "— COMBAT MODES —")
AddToggle(combatPage, "🔥 MELEE RAGE", activeMelee, function(s)
    activeMelee = s
    if activeMelee then activeCombat2 = false end
end)

AddToggle(combatPage, "🎯 AIM & KILL TARGET", activeCombat2, function(s)
    activeCombat2 = s
    if activeCombat2 then activeMelee = false end
end)

AddSection(combatPage, "— CONFIGS —")
AddInput(combatPage, "SET TARGET HP", 30, function(v) CONFIG1.TargetHP = v end)

-- [[ TAB 2: FARM & MISC ]] --
AddSection(farmPage, "— AUTOMATION & UTILS —")
-- Dòng 1: Auto Farm Dummy
AddToggle(farmPage, "🤖 AUTO FARM DUMMY", activeFarm, function(s)
    activeFarm = s
    if activeFarm then activeEscape1 = false end
end)

-- Dòng 2: Auto Escape
AddToggle(farmPage, "🛡️ AUTO ESCAPE (BAY TRỜI)", activeEscape1, function(s)
    activeEscape1 = s
    if not s then systemLock1 = false end
end)

-- Dòng 3: No Clip (ĐÃ THÊM VÀO ĐÚNG VỊ TRÍ)
AddToggle(farmPage, "👻 NO CLIP", activeNoclip, function(s)
    activeNoclip = s
end)

AddInput(farmPage, "SET ESCAPE HP", 25, function(v) CONFIG1.EscapeHP = v end)

AddSection(farmPage, "— SYSTEM & FIX LAG —")
AddButton(farmPage, "⚡ 10% GRAPHICS + XOÁ CÂY", function()
    task.spawn(function()
        local L = game:GetService("Lighting")
        L.GlobalShadows = false; L.Brightness = 0; L.FogEnd = 9e9
        for _, v in pairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end end
        for _, v in pairs(workspace:GetDescendants()) do
            local n = string.lower(v.Name)
            if string.find(n, "tree") or string.find(n, "leaves") or string.find(n, "leaf") or string.find(n, "bush") then v:Destroy()
            elseif v:IsA("BasePart") and not v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then v:Destroy() end
        end
    end)
end)

AddButton(farmPage, "⭐ SUPER HOP SERVER", function()
    local Http = game:GetService("HttpService"); local TP = game:GetService("TeleportService")
    local success, res = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") end)
    if success then
        local data = Http:JSONDecode(res)
        for _, s in pairs(data.data) do if s.id ~= game.JobId and s.playing <= (s.maxPlayers - 2) then TP:TeleportToPlaceInstance(game.PlaceId, s.id, p) return end end
    end
end)

-- [[ TAB 3: TARGET SELECTOR ]] --
AddSection(targetPage, "— PLAYER SELECTOR —")
local scrollTarget = Instance.new("Frame", targetPage)
scrollTarget.Size = UDim2.new(0.95, 0, 0, 140)
scrollTarget.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
scrollTarget.ZIndex = 4
Instance.new("UICorner", scrollTarget).CornerRadius = UDim.new(0, 6)

local scList = Instance.new("ScrollingFrame", scrollTarget)
scList.Size, scList.Position = UDim2.new(0.95, 0, 0.9, 0), UDim2.new(0.025, 0, 0.05, 0)
scList.BackgroundTransparency, scList.ScrollBarThickness = 1, 2
scList.AutomaticCanvasSize = Enum.AutomaticSize.Y
scList.CanvasSize = UDim2.new(0, 0, 0, 0)
scList.ZIndex = 5
local scLayout = Instance.new("UIListLayout", scList); scLayout.Padding = UDim.new(0, 3)

local function updateTargetList()
    local existingButtons = {}
    for _, v in pairs(scList:GetChildren()) do
        if v:IsA("TextButton") then existingButtons[v.Name] = v end
    end
    
    local currentPlayers = {}
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= p then
            currentPlayers[pl.Name] = true
            local b = existingButtons[pl.Name]
            
            local hpStr = " [<font color=\"#888888\">N/A</font>]"
            if pl.Character and pl.Character:FindFirstChild("Humanoid") then
                local eH = pl.Character.Humanoid
                if eH.MaxHealth > 0 then
                    local hpP = math.floor((eH.Health / eH.MaxHealth) * 100)
                    local hexColor = "#00FF7F"
                    if hpP < 30 then hexColor = ACCENT_HEX elseif hpP < 70 then hexColor = "#FFD700" end
                    hpStr = string.format(" [<font color=\"%s\">%d%%</font>]", hexColor, hpP)
                end
            end
            
            if not b then
                b = Instance.new("TextButton", scList)
                b.Name = pl.Name
                b.Size = UDim2.new(1, -5, 0, 22)
                b.RichText = true
                b.Font, b.TextSize, b.TextXAlignment = Enum.Font.Gotham, 9, Enum.TextXAlignment.Left
                b.ZIndex = 6
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                b.MouseButton1Click:Connect(function() 
                    CONFIG2.SelectedTarget = (CONFIG2.SelectedTarget == pl) and nil or pl
                    updateTargetList()
                end)
            end
            
            b.Text = "  " .. pl.Name .. hpStr
            b.BackgroundColor3 = (CONFIG2.SelectedTarget == pl) and ACCENT_COLOR or Color3.fromRGB(30, 30, 38)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    for name, btn in pairs(existingButtons) do
        if not currentPlayers[name] then btn:Destroy() end
    end
end

updateTargetList()
AddButton(targetPage, "🔄 REFRESH PLAYER LIST", updateTargetList)

task.spawn(function()
    while getgenv().KlNZ_Running and task.wait(0.2) do
        if targetPage and targetPage.Visible and mainFrame and mainFrame.Visible then
            updateTargetList()
        end
    end
end)

-- [[ DUMMY LOGIC ]] --
local function getWeakestDummy()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Weakest Dummy" and v:FindFirstChild("HumanoidRootPart") then return v.HumanoidRootPart end
    end
    return nil
end

-- [[ HEARTBEAT MAIN LOOP ]] --
local hbConnection = RunService.Heartbeat:Connect(function(dt)
    if not getgenv().KlNZ_Running then return end

    frames += 1; fps.TextColor3 = Color3.fromHSV((tick() * 0.2) % 1, 1, 1)
    if tick() - last >= 1 then fps.Text = "FPS: "..frames; frames = 0; last = tick() end

    -- Xử lý No Clip liên tục qua Heartbeat
    if activeNoclip then
        local char = p.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end

    if activeFarm then
        local dummy = getWeakestDummy()
        if dummy then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, dummy.Position)
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") then char:PivotTo(dummy.CFrame * CFrame.new(0, 0, 2.0)) end
        end
    end

    local char = p.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not (root and hum) then return end
    
    -- ESP Low HP & Hitbox
        for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character then
            if v.Character:FindFirstChild("Head") then
                local head = v.Character.Head; local eHum = v.Character:FindFirstChild("Humanoid"); local bill = head:FindFirstChild("klunz_ESP")
                if activeESP and eHum then
                    local hpP = (eHum.Health / eHum.MaxHealth) * 100
                    if hpP <= 30 and hpP > 0 then
                        if not bill then
                            bill = Instance.new("BillboardGui", head); bill.Name, bill.Size, bill.AlwaysOnTop, bill.ExtentsOffset = "klunz_ESP", UDim2.new(0, 80, 0, 40), true, Vector3.new(0, 3, 0)
                            local t = Instance.new("TextLabel", bill); t.Size, t.BackgroundTransparency, t.TextColor3, t.Font, t.TextSize, t.TextStrokeTransparency = UDim2.new(1, 0, 1, 0), 1, ACCENT_COLOR, Enum.Font.GothamBold, 10, 0
                        end
                        bill.TextLabel.Text = v.Name .. "\n[" .. math.floor(hpP) .. "%]"
                    elseif bill then bill:Destroy() end
                elseif bill then bill:Destroy() end
            end
            if v.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = v.Character.HumanoidRootPart
                if activeCombat2 or activeMelee then
                    targetRoot.Size = Vector3.new(_HITBOX_SIZE, _HITBOX_SIZE, _HITBOX_SIZE); targetRoot.Transparency = 0.8; targetRoot.BrickColor = BrickColor.new("Royal purple"); targetRoot.Material = Enum.Material.ForceField; targetRoot.CanCollide = false
                else targetRoot.Size, targetRoot.Transparency = Vector3.new(2, 2, 1), 1 end
            end
        end
    end
    
    -- AUTO ESCAPE LOGIC
    local isFighting = activeCombat2 or activeMelee
    local myHP = (hum.Health / hum.MaxHealth) * 100
    
    if activeEscape1 and not isFighting and myHP <= CONFIG1.EscapeHP then 
        systemLock1 = true
    else
        systemLock1 = false
    end
    
    if systemLock1 then 
        root.CFrame = CFrame.new(root.Position.X, 1200, root.Position.Z)
        root.AssemblyLinearVelocity = Vector3.zero 
        return 
    end
    
    -- COMBAT TARGET LOCK LOGIC
    local target = nil
    if activeCombat2 and CONFIG2.SelectedTarget and CONFIG2.SelectedTarget.Character then
        local tHum = CONFIG2.SelectedTarget.Character:FindFirstChild("Humanoid")
        if tHum and tHum.Health > 0 then target = CONFIG2.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") end
    elseif activeMelee then
        local low = 101
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= p and v.Character and v.Character:FindFirstChild("Humanoid") then
                local eh = v.Character.Humanoid; local ep = (eh.Health/eh.MaxHealth)*100
                if ep > 0 and ep <= CONFIG1.TargetHP and ep < low then low = ep; target = v.Character:FindFirstChild("HumanoidRootPart") end
            end
        end
    end
    
    if target then
        currentTarget = target 
        local tVel = target.AssemblyLinearVelocity
        
        if tVel.Y > 5 or target.Position.Y > root.Position.Y + 2 then
            hum.Jump = true
        end
        
        local pingComp = 0.12 
        local predictedPos = target.Position + (tVel * pingComp)
        local tCF = target.CFrame
        
        local offset = 1.2
        local finalPos = predictedPos + (tCF.LookVector * -offset)
        
        root.CFrame = CFrame.new(finalPos, predictedPos)
        root.AssemblyLinearVelocity = tVel 
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    else 
        currentTarget = nil
        if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * (_S * dt)) end
    end
end)
table.insert(getgenv().KlNZ_Connections, hbConnection)

-- [[ TSB HITREG REMOTE LOGIC ]] --
task.spawn(function()
    while getgenv().KlNZ_Running do
        if (activeCombat2 or activeMelee) and not systemLock1 then
            local char = p.Character
            local ev = char and char:FindFirstChild("Communicate")
            if ev and currentTarget then
                ev:FireServer({[1] = 1})
                task.wait(0.015) 
                ev:FireServer({[1] = 2})
                task.wait(0.015)
                ev:FireServer({[1] = 3})
            end
        end
        task.wait(0.05)
    end
end)

-- Anti AFK
local idleConn = p.Idled:Connect(function() 
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0)) 
    end)
end)
table.insert(getgenv().KlNZ_Connections, idleConn)
			

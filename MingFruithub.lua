-- ==========================================
-- MING FRUIT HUB (CYBERPUNK UI + TOGGLE MENU)
-- ==========================================

-- Xóa UI cũ nếu chạy lại
if game.CoreGui:FindFirstChild("MingFruitHubUI") then
    game.CoreGui.MingFruitHubUI:Destroy()
end

-- MODULE ANTI-BAN V9 (Che giấu log & bảo vệ client)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and tostring(self):lower():match("ban") or tostring(self):lower():match("kick") then
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Disable()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

getgenv().MingConfig = {
    PullMob = false,
    AutoClick = false,
    Range = 50,
    SpeedMode = "Thường"
}

-- 1. TẠO GIAO DIỆN (UI) XỊN XÒ - DARK NEON STYLE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MingFruitHubUI"
ScreenGui.Parent = game.CoreGui

-- Main Container (Khung chính)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Viền Neon phát sáng nhẹ cho khung
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 229, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Tiêu đề Hub
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 45)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ MING FRUIT HUB ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- 2. NÚT ẨN/HIỆN MENU (TOGGLE UI BUTTON) TRÊN THANH TIÊU ĐỀ
local isMenuHidden = false
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleMenuBtn.Position = UDim2.new(1, -35, 0, 8)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
ToggleMenuBtn.Text = "-"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleMenuBtn.TextSize = 16
ToggleMenuBtn.Font = Enum.Font.GothamBold
ToggleMenuBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleMenuBtn

-- Container chứa các tính năng bên trong (để ẩn đi khi thu gọn)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 48)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3
Container.CanvasSize = UDim2.new(0, 0, 0, 310)
Container.Parent = MainFrame

ToggleMenuBtn.MouseButton1Click:Connect(function()
    isMenuHidden = not isMenuHidden
    if isMenuHidden then
        Container.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 270, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        ToggleMenuBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 270, 0, 360), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        task.wait(0.1)
        Container.Visible = true
        ToggleMenuBtn.Text = "-"
    end
end)

-- Nhãn trạng thái Anti-Ban v9
local AntiBanLabel = Instance.new("TextLabel")
AntiBanLabel.Size = UDim2.new(0.9, 0, 0, 20)
AntiBanLabel.Position = UDim2.new(0.05, 0, 0, 5)
AntiBanLabel.BackgroundTransparency = 1
AntiBanLabel.Text = "🛡️ Anti-Ban v9: Bảo vệ hoạt động"
AntiBanLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
AntiBanLabel.TextSize = 11
AntiBanLabel.Font = Enum.Font.GothamItalic
AntiBanLabel.Parent = Container

-- Hàm tạo nút bấm trạng thái (Bật/Tắt) kiểu Cyberpunk hiện đại
local function createToggleButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    btn.Text = name .. " : [ TẮT ]"
    btn.TextColor3 = Color3.fromRGB(255, 90, 90)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 80)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 60, 45)
            stroke.Color = Color3.fromRGB(0, 255, 150)
            btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            btn.Text = name .. " : [ BẬT ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
            stroke.Color = Color3.fromRGB(50, 50, 80)
            btn.TextColor3 = Color3.fromRGB(255, 90, 90)
            btn.Text = name .. " : [ TẮT ]"
        end
        callback(state)
    end)
    return btn
end

-- 3. NÚT GOM QUÁI
createToggleButton("Gom Quái (Noclip+Fly)", 32, function(state)
    getgenv().MingConfig.PullMob = state
end)

-- 4. THANH ĐIỀU CHỈNH PHẠM VI (0 - 300)
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
RangeLabel.Position = UDim2.new(0.05, 0, 0, 78)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Phạm vi gom: 50m"
RangeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
RangeLabel.TextSize = 12
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.Parent = Container

local MinusRange = Instance.new("TextButton")
MinusRange.Size = UDim2.new(0, 50, 0, 28)
MinusRange.Position = UDim2.new(0.05, 0, 0, 102)
MinusRange.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
MinusRange.Text = "- 25"
MinusRange.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusRange.TextSize = 12
MinusRange.Font = Enum.Font.GothamBold
MinusRange.Parent = Container
local rc1 = Instance.new("UICorner") rc1.CornerRadius = UDim.new(0, 6) rc1.Parent = MinusRange

MinusRange.MouseButton1Click:Connect(function()
    if getgenv().MingConfig.Range >= 25 then
        getgenv().MingConfig.Range = getgenv().MingConfig.Range - 25
        RangeLabel.Text = "Phạm vi gom: " .. getgenv().MingConfig.Range .. "m"
    end
end)

local PlusRange = Instance.new("TextButton")
PlusRange.Size = UDim2.new(0, 50, 0, 28)
PlusRange.Position = UDim2.new(0.74, 0, 0, 102)
PlusRange.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
PlusRange.Text = "+ 25"
PlusRange.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusRange.TextSize = 12
PlusRange.Font = Enum.Font.GothamBold
PlusRange.Parent = Container
local rc2 = Instance.new("UICorner") rc2.CornerRadius = UDim.new(0, 6) rc2.Parent = PlusRange

PlusRange.MouseButton1Click:Connect(function()
    if getgenv().MingConfig.Range <= 275 then
        getgenv().MingConfig.Range = getgenv().MingConfig.Range + 25
        RangeLabel.Text = "Phạm vi gom: " .. getgenv().MingConfig.Range .. "m"
    end
end)

-- 5. NÚT TỰ ĐỘNG ĐÁNH
createToggleButton("Tự Động Đánh", 140, function(state)
    getgenv().MingConfig.AutoClick = state
end)

-- 6. CHỌN TỐC ĐỘ ĐÁNH
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 188)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Tốc độ: Thường"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 229, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Parent = Container

local speeds = {"Thường", "Nhanh", "Siêu Nhanh"}
local currentSpeedIdx = 1

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBtn.Position = UDim2.new(0.05, 0, 0, 212)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
SpeedBtn.Text = "Tốc Độ: Thường"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 12
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.Parent = Container

local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0, 8) sc.Parent = SpeedBtn
local ss = Instance.new("UIStroke") ss.Color = Color3.fromRGB(0, 229, 255) ss.Thickness = 1 ss.Parent = SpeedBtn

SpeedBtn.MouseButton1Click:Connect(function()
    currentSpeedIdx = currentSpeedIdx + 1
    if currentSpeedIdx > #speeds then currentSpeedIdx = 1 end
    getgenv().MingConfig.SpeedMode = speeds[currentSpeedIdx]
    SpeedLabel.Text = "Tốc độ: " .. getgenv().MingConfig.SpeedMode
    SpeedBtn.Text = "Tốc Độ: " .. getgenv().MingConfig.SpeedMode
end)


-- 7. HỆ THỐNG XỬ LÝ CHÍNH (GOM QUÁI, FLY, NOCLIP & AUTO FARM)
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if getgenv().MingConfig.PullMob then
                if humanoid then
                    humanoid.PlatformStand = true
                end
                
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                        
                        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= getgenv().MingConfig.Range then
                                enemyRoot.CFrame = myRoot.CFrame * CFrame.new(0, 6, 0)
                                enemyHumanoid.PlatformStand = true
                                enemyHumanoid.WalkSpeed = 0
                            end
                        end
                    end
                end
            else
                if humanoid and humanoid.PlatformStand then
                    humanoid.PlatformStand = false
                end
            end
            
            if getgenv().MingConfig.AutoClick then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    VirtualUser:Button1Down(Vector2.new(500, 500))
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(500, 500))
                    
                    local mode = getgenv().MingConfig.SpeedMode
                    if mode == "Thường" then
                        task.wait(0.2)
                    elseif mode == "Nhanh" then
                        task.wait(0.08)
                    elseif mode == "Siêu Nhanh" then
                        task.wait(0.01)
                    end
                end
            end
        end)
    end
end)

print("Đã tải thành công: Ming Fruit Hub (Cyberpunk Edition)!")

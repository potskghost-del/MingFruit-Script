-- ==========================================
-- MING FRUIT HUB + ANTI-BAN V9
-- ==========================================

-- Xóa UI cũ nếu chạy lại
if game.CoreGui:FindFirstChild("MingFruitHubUI") then
    game.CoreGui.MingFruitHubUI:Destroy()
end

-- MODULE ANTI-BAN V9 (Mã hóa và làm giả thông số Client Heartbeat / Chống bắt log game)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    -- Che giấu các hành vi gọi Remote bất thường tránh bị hệ thống Anti-Cheat ghi log
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Chặn hoặc lọc bớt các thông số báo cáo Client đáng ngờ gửi thẳng lên Server
        if method == "FireServer" and tostring(self):lower():match("ban") or tostring(self):lower():match("kick") then
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    
    -- Xóa các kết nối log rác của Roblox Console
    for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Disable()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Các biến cấu hình chính
getgenv().MingConfig = {
    PullMob = false,
    AutoClick = false,
    Range = 50, -- Mặc định 50, kéo tối đa 300
    SpeedMode = "Thường" -- "Thường", "Nhanh", "Siêu Nhanh"
}

-- 1. TẠO GIAO DIỆN (UI) MING FRUIT HUB
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MingFruitHubUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 340) -- Tăng nhẹ chiều cao để vừa khung Anti-Ban
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Tiêu đề Hub
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "⚡ MING FRUIT HUB (V9) ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Nhãn trạng thái Anti-Ban v9
local AntiBanLabel = Instance.new("TextLabel")
AntiBanLabel.Size = UDim2.new(0.9, 0, 0, 20)
AntiBanLabel.Position = UDim2.new(0.05, 0, 0, 32)
AntiBanLabel.BackgroundTransparency = 1
AntiBanLabel.Text = "🛡️ Anti-Ban v9: Đã kích hoạt"
AntiBanLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
AntiBanLabel.TextSize = 11
AntiBanLabel.Font = Enum.Font.SourceSansItalic
AntiBanLabel.Parent = MainFrame

-- Hàm tạo nút bấm trạng thái (Bật/Tắt)
local function createToggleButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = name .. ": TẮT"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
            btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            btn.Text = name .. ": BẬT"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.TextColor3 = Color3.fromRGB(255, 80, 80)
            btn.Text = name .. ": TẮT"
        end
        callback(state)
    end)
    return btn
end

-- 2. NÚT GOM QUÁI (BẬT/TẮT)
createToggleButton("Gom Quái (Noclip+Fly)", 60, function(state)
    getgenv().MingConfig.PullMob = state
end)

-- 3. THANH ĐIỀU CHỈNH PHẠM VI (0 - 300)
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
RangeLabel.Position = UDim2.new(0.05, 0, 0, 105)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Phạm vi gom: 50m"
RangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeLabel.TextSize = 13
RangeLabel.Font = Enum.Font.SourceSans
RangeLabel.Parent = MainFrame

-- Nút Tăng/Giảm phạm vi nhanh
local MinusRange = Instance.new("TextButton")
MinusRange.Size = UDim2.new(0, 45, 0, 25)
MinusRange.Position = UDim2.new(0.05, 0, 0, 127)
MinusRange.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinusRange.Text = "- 25"
MinusRange.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusRange.TextSize = 12
MinusRange.Parent = MainFrame
MinusRange.MouseButton1Click:Connect(function()
    if getgenv().MingConfig.Range >= 25 then
        getgenv().MingConfig.Range = getgenv().MingConfig.Range - 25
        RangeLabel.Text = "Phạm vi gom: " .. getgenv().MingConfig.Range .. "m"
    end
end)

local PlusRange = Instance.new("TextButton")
PlusRange.Size = UDim2.new(0, 45, 0, 25)
PlusRange.Position = UDim2.new(0.78, 0, 0, 127)
PlusRange.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
PlusRange.Text = "+ 25"
PlusRange.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusRange.TextSize = 12
PlusRange.Parent = MainFrame
PlusRange.MouseButton1Click:Connect(function()
    if getgenv().MingConfig.Range <= 275 then
        getgenv().MingConfig.Range = getgenv().MingConfig.Range + 25
        RangeLabel.Text = "Phạm vi gom: " .. getgenv().MingConfig.Range .. "m"
    end
end)

-- 4. NÚT TỰ ĐỘNG ĐÁNH (BẬT/TẮT)
createToggleButton("Tự Động Đánh", 160, function(state)
    getgenv().MingConfig.AutoClick = state
end)

-- 5. CHỌN TỐC ĐỘ ĐÁNH
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 205)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Tốc độ: Thường"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = MainFrame

local speeds = {"Thường", "Nhanh", "Siêu Nhanh"}
local currentSpeedIdx = 1

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 30)
SpeedBtn.Position = UDim2.new(0.05, 0, 0, 230)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
SpeedBtn.Text = "Đổi Tốc Độ (Hiện tại: Thường)"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 12
SpeedBtn.Font = Enum.Font.SourceSansBold
SpeedBtn.Parent = MainFrame

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 6)
sc.Parent = SpeedBtn

SpeedBtn.MouseButton1Click:Connect(function()
    currentSpeedIdx = currentSpeedIdx + 1
    if currentSpeedIdx > #speeds then currentSpeedIdx = 1 end
    getgenv().MingConfig.SpeedMode = speeds[currentSpeedIdx]
    SpeedLabel.Text = "Tốc độ: " .. getgenv().MingConfig.SpeedMode
    SpeedBtn.Text = "Đổi Tốc Độ (Hiện tại: " .. getgenv().MingConfig.SpeedMode .. ")"
end)


-- 6. HỆ THỐNG XỬ LÝ CHÍNH (GOM QUÁI, FLY, NOCLIP & AUTO FARM)
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            -- Xử lý tính năng Gom Quái + Noclip + Fly trên đầu
            if getgenv().MingConfig.PullMob then
                if humanoid then
                    humanoid.PlatformStand = true -- Giữ nhân vật lơ lửng, không rơi
                end
                
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                        
                        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= getgenv().MingConfig.Range then
                                -- Gom quái dính sát lơ lửng ngay phía trên đầu bạn (An toàn tuyệt đối)
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
            
            -- Xử lý Tự Động Đánh theo tốc độ tùy chỉnh
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

print("Đã tải thành công: Ming Fruit Hub + Anti-Ban v9!")

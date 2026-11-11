-- ==========================================
-- MING FRUIT HUB (ADVANCED EDITION)
-- ==========================================

-- Xóa UI cũ nếu chạy lại script
if game.CoreGui:FindFirstChild("MingFruitHubUI") then
    game.CoreGui.MingFruitHubUI:Destroy()
end

-- 1. MODULE ANTI-BAN ẨN (NÂNG CẤP NGẦM - KHÔNG HIỂN THỊ RA NGOÀI)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and (tostring(self):lower():match("ban") or tostring(self):lower():match("kick") or tostring(self):lower():match("detect")) then
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    
    -- Vô hiệu hóa bắt lỗi hệ thống và log rác client
    for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Disable()
    end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Gọi module Net chuẩn của game nếu có
local Net = nil
pcall(function()
    Net = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"))
end)

-- Cấu hình lưu trữ trạng thái Hub
getgenv().MingConfig = {
    AutoAttack = false,
    PullMob = false,
    Range = 100,         -- Phạm vi hút quái (0 - 500m)
    SpeedMode = "Thường"   -- Tốc độ đánh
}

-- 2. TẠO GIAO DIỆN CHÍNH & LOGO MF
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MingFruitHubUI"
ScreenGui.Parent = game.CoreGui

-- Logo hình MF nhỏ (Có thể kéo thả di chuyển)
local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0, 45, 0, 45)
LogoBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
LogoBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LogoBtn.Text = "MF"
LogoBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
LogoBtn.TextSize = 16
LogoBtn.Font = Enum.Font.GothamBold
LogoBtn.Active = true
LogoBtn.Draggable = true
LogoBtn.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0) -- Bo tròn thành hình tròn
LogoCorner.Parent = LogoBtn

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(0, 229, 255)
LogoStroke.Thickness = 1.5
LogoStroke.Parent = LogoBtn

-- Khung Menu Chính (Cyberpunk Dark Neon Style)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 380)
MainFrame.Position = UDim2.new(0.12, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- Mặc định ẩn, bấm Logo MF để mở
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 229, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Xử lý sự kiện bấm Logo mở/đóng menu
LogoBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Tiêu đề Menu
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

-- Nút đóng Menu nhanh (Dấu X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- 3. HỆ THỐNG TAB CHUYỂN ĐỔI (TAB 1: AUTO FARM & TAB 2: CHƯA PHÁT TRIỂN)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 32)
TabBar.Position = UDim2.new(0, 12, 0, 50)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tab1Btn = Instance.new("TextButton")
Tab1Btn.Size = UDim2.new(0.48, 0, 1, 0)
Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
Tab1Btn.Text = "Auto Farm ⚔️"
Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 255)
Tab1Btn.TextSize = 12
Tab1Btn.Font = Enum.Font.GothamBold
Tab1Btn.Parent = TabBar
local t1c = Instance.new("UICorner") t1c.CornerRadius = UDim.new(0, 6) t1c.Parent = Tab1Btn

local Tab2Btn = Instance.new("TextButton")
Tab2Btn.Size = UDim2.new(0.48, 0, 1, 0)
Tab2Btn.Position = UDim2.new(0.52, 0, 0, 0)
Tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Tab2Btn.Text = "Mục 2 (Dev)"
Tab2Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
Tab2Btn.TextSize = 12
Tab2Btn.Font = Enum.Font.GothamBold
Tab2Btn.Parent = TabBar
local t2c = Instance.new("UICorner") t2c.CornerRadius = UDim.new(0, 6) t2c.Parent = Tab2Btn

-- Container nội dung Tab 1
local Tab1Content = Instance.new("ScrollingFrame")
Tab1Content.Size = UDim2.new(1, -24, 1, -95)
Tab1Content.Position = UDim2.new(0, 12, 0, 88)
Tab1Content.BackgroundTransparency = 1
Tab1Content.BorderSizePixel = 0
Tab1Content.ScrollBarThickness = 3
Tab1Content.CanvasSize = UDim2.new(0, 0, 0, 280)
Tab1Content.Parent = MainFrame

-- Container nội dung Tab 2 (Chưa phát triển)
local Tab2Content = Instance.new("Frame")
Tab2Content.Size = UDim2.new(1, -24, 1, -95)
Tab2Content.Position = UDim2.new(0, 12, 0, 88)
Tab2Content.BackgroundTransparency = 1
Tab2Content.Visible = false
Tab2Content.Parent = MainFrame

local DevNotice = Instance.new("TextLabel")
DevNotice.Size = UDim2.new(1, 0, 1, 0)
DevNotice.BackgroundTransparency = 1
DevNotice.Text = "🚀 Tính năng đang được phát triển...\nHãy chờ đón ở các bản cập nhật sau!"
DevNotice.TextColor3 = Color3.fromRGB(180, 180, 180)
DevNotice.TextSize = 13
DevNotice.Font = Enum.Font.GothamItalic
DevNotice.TextWrapped = true
DevNotice.Parent = Tab2Content

-- Chuyển Tab logic
Tab1Btn.MouseButton1Click:Connect(function()
    Tab1Content.Visible = true
    Tab2Content.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
    Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Tab2Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

Tab2Btn.MouseButton1Click:Connect(function()
    Tab1Content.Visible = false
    Tab2Content.Visible = true
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 80, 80)
    Tab2Btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Tab1Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)


-- 4. XÂY DỰNG CÁC TÍNH NĂNG TRONG TAB 1 (AUTO FARM ⚔️)

-- Hàm tạo nút Bật/Tắt chuẩn
local function createToggle(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    btn.Text = name .. " : [ TẮT ]"
    btn.TextColor3 = Color3.fromRGB(255, 90, 90)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Tab1Content
    
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = btn
    local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(50, 50, 80) s.Thickness = 1 s.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 60, 45)
            s.Color = Color3.fromRGB(0, 255, 150)
            btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            btn.Text = name .. " : [ BẬT ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
            s.Color = Color3.fromRGB(50, 50, 80)
            btn.TextColor3 = Color3.fromRGB(255, 90, 90)
            btn.Text = name .. " : [ TẮT ]"
        end
        callback(state)
    end)
    return btn
end

-- A. Nút Tự Động Đánh (On/Off)
createToggle("Tự Động Đánh", 0, function(state)
    getgenv().MingConfig.AutoAttack = state
end)

-- B. Chọn Tốc Độ Đánh
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 44)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Tốc độ đánh: Thường"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 229, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Parent = Tab1Content

local speeds = {"Thường", "Nhanh", "Siêu Nhanh"}
local curSpeedIdx = 1

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, 0, 0, 32)
SpeedBtn.Position = UDim2.new(0, 0, 0, 68)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
SpeedBtn.Text = "Đổi Tốc Độ (Thường)"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextSize = 12
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.Parent = Tab1Content
local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0, 8) sc.Parent = SpeedBtn

SpeedBtn.MouseButton1Click:Connect(function()
    curSpeedIdx = curSpeedIdx + 1
    if curSpeedIdx > #speeds then curSpeedIdx = 1 end
    getgenv().MingConfig.SpeedMode = speeds[curSpeedIdx]
    SpeedLabel.Text = "Tốc độ đánh: " .. getgenv().MingConfig.SpeedMode
    SpeedBtn.Text = "Đổi Tốc Độ (" .. getgenv().MingConfig.SpeedMode .. ")"
end)

-- C. Nút Gom Quái (On/Off)
createToggle("Gom Quái (Trước Mặt)", 112, function(state)
    getgenv().MingConfig.PullMob = state
end)

-- D. Thanh chỉnh phạm vi gom quái (0 - 500m)
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(1, 0, 0, 20)
RangeLabel.Position = UDim2.new(0, 0, 0, 156)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Phạm vi hút quái: 100m"
RangeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
RangeLabel.TextSize = 12
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.Parent = Tab1Content

-- Nút giảm phạm vi nhanh (-50)
local MinusRange = Instance.new("TextButton")
MinusRange.Size = UDim2.new(0.47, 0, 0, 28)
MinusRange.Position = UDim2.new(0, 0, 0, 180)
MinusRange.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
MinusRange.Text = "- 50m"
MinusRange.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusRange.TextSize = 12
MinusRange.Font = Enum.Font.GothamBold
MinusRange.Parent = Tab1Content
local rc1 = Instance.new("UICorner") rc1.CornerRadius = UDim.new(0, 6) rc1.Parent = MinusRange

MinusRange.MouseButton1Click:Connect(function()
    if getgenv().MingConfig.Range >= 50 then
        getgenv().MingConfig.Range = getgenv().MingConfig.Range - 50
        RangeLabel.Text = "Phạm vi hút quái: " .. getgenv().MingConfig.Range .. "m"
    end
end)

-- Nút tăng phạm vi nhanh (+50) tối đa 500m
local PlusRange = Instance.new("TextButton")
PlusRange.Size = UDim2.new(0.47, 0, 0, 28)
PlusRange.Position = UDim2.new(0.53, 0, 0, 180)
PlusRange.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
PlusRange.Text = "+ 50m"
PlusRange.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusRange.TextSize = 12
PlusRange.Font = Enum.Font.GothamBold
PlusRange.Parent = Tab1Content
local rc2 = Instance.new("UICorner") rc2.CornerRadius = UDim.new(0, 6) rc2.Parent = PlusRange

PlusRange.MouseButton1Click:Connect(function()
    if getgenv().MingConfig.Range <= 450 then
        getgenv().MingConfig.Range = getgenv().MingConfig.Range + 50
        RangeLabel.Text = "Phạm vi hút quái: " .. getgenv().MingConfig.Range .. "m"
    end
end)


-- 5. HỆ THỐNG XỬ LÝ LẬP TRÌNH CHÍNH (GOM QUÁI TỐC ĐỘ 30 + TỰ ĐỘNG ĐÁNH MODULE)
task.spawn(function()
    while true do
        task.wait(0.02)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = char.HumanoidRootPart
            
            -- Xử lý Gom Quái bay về trước mặt với tốc độ kiểm soát
            if getgenv().MingConfig.PullMob then
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                        
                        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= getgenv().MingConfig.Range then
                                -- Vị trí mục tiêu ngay trước mặt (cách 3 studs)
                                local targetCFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                                
                                -- Cho quái bay mượt mà đến trước mặt thay vì giật cục
                                enemyRoot.CFrame = enemyRoot.CFrame:Lerp(targetCFrame, 0.3)
                                
                                -- Đóng băng hành vi quái để đứng yên cho dễ đánh
                                enemyHumanoid.PlatformStand = true
                                enemyHumanoid.WalkSpeed = 0
                            end
                        end
                    end
                end
            end
            
            -- Xử lý Tự Động Đánh dùng module Net & Tool tích hợp
            if getgenv().MingConfig.AutoAttack then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    local vim = game:GetService("VirtualUser")
                    vim:Button1Down(Vector2.new(500, 500))
                    vim:Button1Up(Vector2.new(500, 500))
                    
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

print("Đã tải thành công: Ming Fruit Hub (Advanced Edition)!")

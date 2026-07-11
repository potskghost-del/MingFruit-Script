-- LocalScript - Bảng Điều Chỉnh Tốc Độ Chạy (Hỗ trợ Kéo Thả)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Xóa GUI cũ nếu đã tồn tại trước đó để tránh trùng lặp
if PlayerGui:FindFirstChild("Zidwi_Speed_Hub") then
	PlayerGui.Zidwi_Speed_Hub:Destroy()
end

----------------------------------------------------------------
-- 1. KHỞI TẠO GIAO DIỆN (GUI) TỐI GIẢN
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Zidwi_Speed_Hub"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Khung nền chính (Có màu nền mờ để dễ nhìn thấy vùng kéo thả)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 180, 0, 70)
mainFrame.Position = UDim2.new(0, 50, 0, 120) -- Vị trí mặc định ban đầu
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.4 -- Mờ nhẹ để không che tầm nhìn game
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

-- Bo góc cho khung nền nhìn đẹp hơn
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Chữ hiển thị tốc độ hiện tại (Chữ trắng, viền đen)
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 5)
speedLabel.BackgroundTransparency = 1
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.TextStrokeTransparency = 0
speedLabel.Text = "Tốc độ: 16 (Mặc định)"
speedLabel.Parent = mainFrame

-- Nút bấm GIẢM tốc độ
local btnDecrease = Instance.new("TextButton")
btnDecrease.Name = "BtnDecrease"
btnDecrease.Size = UDim2.new(0, 40, 0, 25)
btnDecrease.Position = UDim2.new(0, 15, 0, 35)
btnDecrease.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnDecrease.Text = "-"
btnDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDecrease.TextSize = 18
btnDecrease.Font = Enum.Font.SourceSansBold
btnDecrease.Parent = mainFrame

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 5)
btnCorner1.Parent = btnDecrease

-- Nút bấm TĂNG tốc độ
local btnIncrease = Instance.new("TextButton")
btnIncrease.Name = "BtnIncrease"
btnIncrease.Size = UDim2.new(0, 40, 0, 25)
btnIncrease.Position = UDim2.new(1, -55, 0, 35)
btnIncrease.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
btnIncrease.Text = "+"
btnIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIncrease.TextSize = 18
btnIncrease.Font = Enum.Font.SourceSansBold
btnIncrease.Parent = mainFrame

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 5)
btnCorner2.Parent = btnIncrease

----------------------------------------------------------------
-- 2. ĐỘNG CƠ XỬ LÝ TỐC ĐỘ (WALKSPEED)
----------------------------------------------------------------
local currentSpeed = 16 -- Tốc độ gốc của Roblox

local function updateSpeed(value)
	currentSpeed = math.clamp(currentSpeed + value, 16, 250) -- Giới hạn từ 16 đến 250 để tránh lỗi game
	speedLabel.Text = "Tốc độ: " .. currentSpeed
	
	-- Áp dụng tốc độ vào nhân vật
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = currentSpeed
	end
end

-- Tự động giữ tốc độ khi nhân vật hồi sinh (Reset/Spawn lại)
LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = currentSpeed
	end
end)

-- Sự kiện click nút bấm
btnDecrease.MouseButton1Click:Connect(function()
	updateSpeed(-10) -- Mỗi lần bấm giảm 10 tốc độ
end)

btnIncrease.MouseButton1Click:Connect(function()
	updateSpeed(10) -- Mỗi lần bấm tăng 10 tốc độ
end)

----------------------------------------------------------------
-- 3. HỆ THỐNG KÉO THẢ (DRAG & DROP) CHO CẢ PC VÀ MOBILE
----------------------------------------------------------------
local dragging = false
local dragInput
local dragStart
local startPos

local function updateGuiPos(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale, 
		startPos.X.Offset + delta.X, 
		startPos.Y.Scale, 
		startPos.Y.Offset + delta.Y
	)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateGuiPos(input)
	end
end)

print("✅ ZIDWI SPEED: Đã kích hoạt menu đổi tốc độ chạy! Giữ chuột trái hoặc ngón tay vào phần bảng đen để dịch chuyển tùy ý.")

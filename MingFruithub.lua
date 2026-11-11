local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
-- ==========================================
-- 1. ADVANCED SILENT ANTI-BAN SYSTEM
-- ==========================================
local AntiBanSystem = {}
do
-- Hook metatable protections to avoid detection by server-side sanity checks
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
local method = getnamecallmethod()
local args = {...}
-- Prevent suspicious remote spamming or known blacklisted signatures
if method == "FireServer" or method == "InvokeServer" then
local remoteName = tostring(self)
if remoteName:lower():find("ban") or remoteName:lower():find("kick") or remoteName:lower():find("exploit") then
return
end
end
return oldNamecall(self, ...)
end)
-- Stealth heartbeat corruption to bypass tick-rate anomaly detection
RunService.Heartbeat:Connect(function()
if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local hrp = LocalPlayer.Character.HumanoidRootPart
-- Inject micro-jitter to simulate biological input variance
if math.random(1, 100) == 50 then
hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(math.random(-0.01, 0.01), 0, math.random(-0.01, 0.01))
end
end
end)
end
-- ==========================================
-- 2. FAST ATTACK MODULE INTEGRATION
-- ==========================================
local FastAttackModule = {}
do
local NetModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"))
function FastAttackModule.ExecuteAttack(attackSpeed)
pcall(function()
local combatRemote = NetModule:RemoteEvent("RegisterAttack")
if combatRemote then
combatRemote:FireServer(attackSpeed or 0.05)
end
end)
end
end
-- ==========================================
-- 3. MOB AGGREGATOR (GOM QUÁI) SYSTEM
-- ==========================================
local MobAggregator = {}
do
function MobAggregator.PullEnemies(radius, targetCFrame)
pcall(function()
local enemiesFolder = workspace:FindFirstChild("Enemies")
if not enemiesFolder then return end
for _, enemy in pairs(enemiesFolder:GetChildren()) do
local hrp = enemy:FindFirstChild("HumanoidRootPart")
local humanoid = enemy:FindFirstChildOfClass("Humanoid")
if hrp and humanoid and humanoid.Health > 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local playerHRP = LocalPlayer.Character.HumanoidRootPart
local distance = (hrp.Position - playerHRP.Position).Magnitude
if distance <= radius then
-- Disable physics collision/gravity temporarily for smooth pulling
for _, part in pairs(enemy:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
-- Calculate position right in front of the player within melee range (~4 studs ahead)
local desiredPosition = playerHRP.CFrame * CFrame.new(0, 0, -4)
-- Smooth translation at speed 30
local tweenInfo = TweenInfo.new((hrp.Position - desiredPosition.Position).Magnitude / 30, Enum.EasingStyle.Linear)
local tween = TweenService:Create(hrp, tweenInfo, {CFrame = desiredPosition})
tween:Play()
end
end
end
end)
end
end
-- ==========================================
-- 4. UI ARCHITECTURE (DRAGGABLE MF LOGO & MENU)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MingFruitHub_Core"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Draggable MF Logo
local LogoButton = Instance.new("TextButton")
LogoButton.Name = "MF_Logo"
LogoButton.Size = UDim2.new(0, 50, 0, 50)
LogoButton.Position = UDim2.new(0, 100, 0, 100)
LogoButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LogoButton.BorderColor3 = Color3.fromRGB(255, 165, 0)
LogoButton.BorderSizePixel = 2
LogoButton.Text = "MF"
LogoButton.TextColor3 = Color3.fromRGB(255, 165, 0)
LogoButton.TextSize = 18
LogoButton.Font = Enum.Font.GothamBold
LogoButton.Parent = ScreenGui
local UICornerLogo = Instance.new("UICorner")
UICornerLogo.CornerRadius = UDim.new(1, 0)
UICornerLogo.Parent = LogoButton
-- Make Logo Draggable (Mobile & PC)
local dragging, dragInput, dragStart, startPos
LogoButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = LogoButton.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
LogoButton.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
LogoButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
-- Main Menu Frame
local MainMenu = Instance.new("Frame")
MainMenu.Name = "Main_Menu"
MainMenu.Size = UDim2.new(0, 420, 0, 320)
MainMenu.Position = UDim2.new(0.5, -210, 0.5, -160)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.BorderColor3 = Color3.fromRGB(255, 165, 0)
MainMenu.BorderSizePixel = 1
MainMenu.Visible = false
MainMenu.Parent = ScreenGui
local UICornerMenu = Instance.new("UICorner")
UICornerMenu.CornerRadius = UDim.new(0, 8)
UICornerMenu.Parent = MainMenu
-- Title Bar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.Text = " MING FRUIT HUB | ARCHITECTURE V1.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainMenu
local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 8)
UICornerTitle.Parent = TitleLabel
-- Toggle Menu Visibility on Logo Click
LogoButton.MouseButton1Click:Connect(function()
MainMenu.Visible = not MainMenu.Visible
end)
-- ==========================================
-- 5. AUTOFARM TAB & CONTROLS INTERFACE
-- ==========================================
-- Autofarm Section Container
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -60)
ContentContainer.Position = UDim2.new(0, 10, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
ContentContainer.ScrollBarThickness = 4
ContentContainer.Parent = MainMenu
-- State Variables for Controls
local autoAttackEnabled = false
local attackSpeedValue = 0.05
local pullEnemiesEnabled = false
local pullRadiusValue = 50
-- UI Helper: Toggle Button Creator
local function createToggle(name, posY, callback)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 250, 0, 35)
label.Position = UDim2.new(0, 10, 0, posY)
label.BackgroundTransparency = 1
label.Text = name
label.TextColor3 = Color3.fromRGB(240, 240, 240)
label.TextSize = 13
label.Font = Enum.Font.Gotham
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = ContentContainer
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 100, 0, 30)
btn.Position = UDim2.new(1, -110, 0, posY + 2)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.Text = "OFF"
btn.TextColor3 = Color3.fromRGB(200, 50, 50)
btn.TextSize = 13
btn.Font = Enum.Font.GothamBold
btn.Parent = ContentContainer
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = btn
local state = false
btn.MouseButton1Click:Connect(function()
state = not state
if state then
btn.Text = "ON"
btn.TextColor3 = Color3.fromRGB(50, 200, 50)
btn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
else
btn.Text = "OFF"
btn.TextColor3 = Color3.fromRGB(200, 50, 50)
btn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
end
callback(state)
end)
end
-- UI Helper: Slider/Input Creator for numeric values
local function createInputBox(name, posY, defaultVal, callback)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 230, 0, 35)
label.Position = UDim2.new(0, 10, 0, posY)
label.BackgroundTransparency = 1
label.Text = name
label.TextColor3 = Color3.fromRGB(240, 240, 240)
label.TextSize = 13
label.Font = Enum.Font.Gotham
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = ContentContainer
local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 100, 0, 30)
box.Position = UDim2.new(1, -110, 0, posY + 2)
box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
box.TextColor3 = Color3.fromRGB(255, 165, 0)
box.Text = tostring(defaultVal)
box.TextSize = 13
box.Font = Enum.Font.GothamBold
box.Parent = ContentContainer
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = box
box.FocusLost:Connect(function()
local val = tonumber(box.Text)
if val then
callback(val)
else
box.Text = tostring(defaultVal)
end
end)
end
-- ==========================================
-- 6. BUILD CONFIGURATION UI ELEMENTS
-- ==========================================
createToggle("Tự Động Đánh (Fast Attack)", 10, function(state)
autoAttackEnabled = state
end)
createInputBox("Tốc Độ Đánh (s)", 55, attackSpeedValue, function(val)
attackSpeedValue = val
end)
createToggle("Gom Quái (Mob Puller)", 100, function(state)
pullEnemiesEnabled = state
end)
createInputBox("Phạm Vi Hút (0-500m)", 145, pullRadiusValue, function(val)
if val >= 0 and val <= 500 then
pullRadiusValue = val
end
end)
-- ==========================================
-- 7. CORE RUNTIME EXECUTION LOOPS
-- ==========================================
TaskSpawnLoop = task.spawn(function()
while true do
task.wait(attackSpeedValue)
if autoAttackEnabled then
FastAttackModule.ExecuteAttack(attackSpeedValue)
end
end
end)
TaskPullLoop = task.spawn(function()
while true do
task.wait(0.1)
if pullEnemiesEnabled then
MobAggregator.PullEnemies(pullRadiusValue)
end
end
end)

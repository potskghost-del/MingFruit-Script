-- MINGFRUIT FPS BOOSTER V6
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- 1. Giảm chất lượng Địa hình (Terrain) và tắt hiệu ứng môi trường
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
end

-- 2. Tắt toàn bộ hiệu ứng ánh sáng nặng (Bóng đổ, làm mờ, tia sáng)
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
        effect.Enabled = false
    end
end

-- 3. Xóa Texture (Vân bề mặt) của vật thể để giảm tải cho RAM và GPU
local function fixLagObject(obj)
    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Color = Color3.fromRGB(150, 150, 150) -- Đưa về màu xám tối giản để load nhanh hơn
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy() -- Xóa ảnh dán trên tường, sàn nhà
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = false -- Tắt hiệu ứng hạt bay bay, đuôi chiêu thức
    end
end

-- Quét toàn bộ map hiện tại
for _, child in pairs(workspace:GetDescendants()) do
    fixLagObject(child)
end

-- Tự động quét và tắt hiệu ứng của vật thể mới sinh ra (Quái, Chiêu thức mới bật)
workspace.DescendantAdded:Connect(function(child)
    fixLagObject(child)
end)

-- 4. Giới hạn FPS ẩn và giải phóng bộ nhớ
setfpscap(120) -- Mở khóa giới hạn FPS nếu Executor hỗ trợ

-- Hiển thị thông báo nhỏ trên góc
local sg = Instance.new("ScreenGui", game.CoreGui)
local txt = Instance.new("TextLabel", sg)
txt.Size = UDim2.new(0, 200, 0, 30); txt.Position = UDim2.new(0.4, 0, 0.05, 0)
txt.Text = "FPS BOOSTER: ACTIVATED (-mingfruit-)"
txt.TextColor3 = Color3.fromRGB(0, 255, 0); txt.BackgroundColor3 = Color3.fromRGB(0,0,0)
task.wait(3); txt:Destroy()

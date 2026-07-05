-- [[ SCRIPT TỐI ƯU FPS & GIẢM LAG   ]] --

local Lighting = game:GetService("Lighting")
local Terrain = game:GetService("Workspace"):FindFirstChildOfClass("Terrain")

-- 1. Cấu hình hiệu ứng ánh sáng & Màu sắc siêu nhạt
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 1.2 -- Giữ độ sáng vừa phải để không bị tối

-- Xóa các hiệu ứng làm nặng máy
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") then
        effect:Destroy()
    end
end

-- Tạo hiệu ứng chỉnh màu: Giảm độ bão hòa (Color Saturation) để màu siêu nhạt nhưng KHÔNG bị xám hẳn
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Saturation = -0.6 -- Giảm 60% màu (vẫn giữ lại 40% màu sắc nguyên bản)
ColorCorrection.Contrast = 0.05
ColorCorrection.Parent = Lighting

-- 2. Tối ưu Terrain (Địa hình đất/cỏ)
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
end

-- 3. Hàm biến mọi chất liệu (Texture/Material) thành màu nhạt và mượt
local function OptimizeObject(obj)
    -- Giảm chất liệu về SmoothPlastic để card màn hình không phải xử lý
    if obj:IsA("BasePart") and not obj:IsA("MeshPart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
    elseif obj:IsA("MeshPart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        -- Nếu muốn mượt hơn nữa có thể bật dòng dưới (nhưng có thể mất hình dạng gốc của mesh)
        -- obj.RenderFidelity = Enum.RenderFidelity.Performance
    end

    -- Xóa bỏ các hình dán (Decals/Textures) gây lag trên bề mặt block
    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    end

    -- Tắt hiệu ứng hạt (Khói, lửa, lấp lánh)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end

-- Chạy tối ưu cho toàn bộ map hiện tại
for _, obj in pairs(game:GetDescendants()) do
    pcall(OptimizeObject, obj)
end

-- Tự động tối ưu cho các vật thể mới được sinh ra sau đó
game.DescendantAdded:Connect(function(obj)
    pcall(OptimizeObject, obj)
end)

-- 4. Giảm chất liệu đồ họa của toàn bộ Game theo thiết lập hệ thống
sethiddenproperty(game:GetService("RenderSettings"), "EagerBulkExecution", true)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

print("--- Đã tối ưu FPS thành công! Màu sắc đã được làm nhạt đi ---")

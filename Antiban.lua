-- MINGFRUIT ANTI-BAN V6
local CoreGui = game:GetService("CoreGui")

-- Tạo giao diện thông báo
local screenGui = Instance.new("ScreenGui", CoreGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.4, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "ĐÃ KÍCH HOẠT ANTIBAN"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.BackgroundTransparency = 1

local sub = Instance.new("TextLabel", frame)
sub.Size = UDim2.new(1, 0, 0, 40)
sub.Position = UDim2.new(0, 0, 0.3, 0)
sub.Text = "-mingfruit-"
sub.TextColor3 = Color3.fromRGB(255, 255, 255)
sub.BackgroundTransparency = 1

local okBtn = Instance.new("TextButton", frame)
okBtn.Size = UDim2.new(0, 80, 0, 30)
okBtn.Position = UDim2.new(0.5, -40, 0.7, 0)
okBtn.Text = "OK"
okBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)

-- Logic ẩn giao diện
okBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Chức năng Anti-Ban thực tế (Chặn các hàm báo cáo)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and tostring(self) == "ReportAbuse" then
        return nil
    end
    return oldNamecall(self, ...)
end)

print("MingFruit Anti-Ban V6 đã hoạt động ngầm!")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- UIの重複防止
if CoreGui:FindFirstChild("SakuraStepSystem") then CoreGui.SakuraStepSystem:Destroy() end

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "SakuraStepSystem"

-- 🌸 メインメニュー
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 160)
main.Position = UDim2.new(0.5, -110, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 105, 180)
stroke.Thickness = 2

-- 🌸 タイトル
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🌸 SAKURA STEP 🌸"
title.TextColor3 = Color3.fromRGB(255, 182, 193)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1

-- 🌸 [1枚ずつ出すボタン]
local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0, 180, 0, 50)
btn.Position = UDim2.new(0.5, -90, 0.35, 0)
btn.Text = "パレットを1枚連結"
btn.Font = Enum.Font.GothamSemibold
btn.TextSize = 14
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
btn.BorderSizePixel = 0
Instance.new("UICorner", btn)

-- 🌸 [リセットボタン]
local resetBtn = Instance.new("TextButton", main)
resetBtn.Size = UDim2.new(0, 180, 0, 30)
resetBtn.Position = UDim2.new(0.5, -90, 0.75, 0)
resetBtn.Text = "全て消去"
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 12
resetBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
resetBtn.BackgroundTransparency = 1

--- ⚙️ ゲーム内部システムへの直接アクセス (1枚ずつ) ---
btn.MouseButton1Click:Connect(function()
    local event = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ToyEvent")
    
    if event then
        -- サーバーへ「パレットを1つ出す」信号を直接送る
        event:FireServer("Pallet")
    else
        warn("ToyEventが見つかりません。ゲームが対応していない可能性があります。")
    end
end)

-- 消去機能
resetBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v.Name:find("Pallet") and v:IsA("Part") then
                v:Destroy()
            end
        end
    end
end)

-- 🌸 滑らかなアニメーション注入 (Motor6D制御)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Motor6D") and (v.Part1 and v.Part1.Name:find("Pallet")) then
            -- 連結の深さを取得して「しなり」を作る
            local depth = 0
            local current = v.Part0
            while current and current:IsA("Part") and current.Name:find("Pallet") do
                depth = depth + 1
                current = current:FindFirstChildWhichIsA("Motor6D") and current:FindFirstChildWhichIsA("Motor6D").Part0
            end
            
            local t = tick() * 4
            local angle = math.sin(t - (depth * 0.4)) * math.rad(35)
            local side = (v.C0.X < 0) and -1 or 1
            v.C1 = CFrame.Angles(0, angle * side, 0)
        end
    end
end)
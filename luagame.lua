local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- UIの重複を削除
if CoreGui:FindFirstChild("FTAP_SakuraSmooth") then CoreGui.FTAP_SakuraSmooth:Destroy() end

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "FTAP_SakuraSmooth"

-- 🌸 メインフレーム (FTAPLauncher風のシンプルかつ綺麗なUI)
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 150)
main.Position = UDim2.new(0.5, -100, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- 外枠の光
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 105, 180)
stroke.Thickness = 2

-- タイトル
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "FTAP SMOOTH"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

-- 🌸 パレットを1枚出すボタン (FTAPLauncherの通信方式)
local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0, 160, 0, 45)
btn.Position = UDim2.new(0.5, -80, 0.4, 0)
btn.Text = "SPAWN PALLET"
btn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
Instance.new("UICorner", btn)

-- [[ ⚙️ FTAPLauncherと全く同じ内部操作ロジック ⚙️ ]]
btn.MouseButton1Click:Connect(function()
    -- ゲームの心臓部へ直接信号を送る (パスを完全一致させています)
    local toyEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ToyEvent")
    
    if toyEvent then
        -- 内部システムに直接「パレット」を要求
        toyEvent:FireServer("Pallet")
    else
        -- パスが違う場合、総当たりでToyEventを探す
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v.Name == "ToyEvent" and v:IsA("RemoteEvent") then
                v:FireServer("Pallet")
                break
            end
        end
    end
end)

-- 全削除ボタン
local clr = Instance.new("TextButton", main)
clr.Size = UDim2.new(0, 160, 0, 30)
clr.Position = UDim2.new(0.5, -80, 0.75, 0)
clr.Text = "CLEAR ALL"
clr.BackgroundTransparency = 1
clr.TextColor3 = Color3.new(0.6, 0.6, 0.6)
clr.Font = Enum.Font.Gotham
clr.MouseButton1Click:Connect(function()
    if player.Character then
        for _, v in ipairs(player.Character:GetDescendants()) do
            if v.Name:find("Pallet") and v:IsA("Part") then v:Destroy() end
        end
    end
end)

-- [[ 🌸 滑らかな「しなり」アニメーション 🌸 ]]
-- ゲーム本来の機能で出したパレットを自動検知して、後付けで動きを注入します
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    for _, v in ipairs(char:GetDescendants()) do
        -- ゲームが生成したパレットのMotor6Dを見つけ出す
        if v:IsA("Motor6D") and (v.Part1 and v.Part1.Name:find("Pallet")) then
            -- 連結の深さを測って、先端ほど遅れて動く「しなり」を作る
            local depth = 0
            local current = v.Part0
            while current and current:IsA("Part") and current.Name:find("Pallet") do
                depth = depth + 1
                current = current:FindFirstChildWhichIsA("Motor6D") and current:FindFirstChildWhichIsA("Motor6D").Part0
            end
            
            local t = tick() * 4 -- 羽ばたきの速さ
            local wave = math.sin(t - (depth * 0.4)) -- サイン波で滑らかに
            local angle = math.rad(35) * wave
            
            -- 左右の向きを自動判定して適用
            local side = (v.C0.X < 0) and -1 or 1
            v.C1 = CFrame.Angles(0, angle * side, 0)
        end
    end
end)

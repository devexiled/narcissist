local Toggled = nil
local holdingTool = nil
local HitPart = nil
local CamPart = nil

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ws = game:GetService("Workspace")
local plrs = game:GetService("Players")
local ts = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")

local Vector2new = Vector2.new
local CurrentCamera = ws.CurrentCamera
local lplr = plrs.LocalPlayer
local Mouse = lplr:GetMouse()
local bodyparts = {"Head","LeftFoot","LeftHand","LeftLowerArm","LeftLowerLeg","LeftUpperArm","LeftUpperLeg","LowerTorso","RightFoot","RightHand","RightLowerArm","RightLowerLeg","RightUpperArm","RightUpperLeg","UpperTorso"}
local cambodyparts = {"Head","LowerTorso","UpperTorso"}
local vels = table.create(game.Players.MaxPlayers)

local speedglitched = false
local enabled = false
local Plr = nil
local inSilRad = false
local inCamRad = false
local piss = nil
local disableMacro = false
local showVisuals = getgenv().Settings.ShowFOV
local closeCheck = false
local viewing = false
local aimviewtarget = nil
local nocliping = false

local Player = game.Players.LocalPlayer
local PlayerCameras = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras()
local Controller = PlayerCameras.activeCameraController

local cnew = CFrame.new
local mathrand = math.random
local Vector3new = Vector3.new

local line=Instance.new("Beam")
line.Segments = 1
line.Width0 = 0.2
line.Width1 = 0.2
line.Color = ColorSequence.new(getgenv().Settings.AimViewer.Color)
line.FaceCamera = true
local line1 = Instance.new("Attachment")
local line2 = Instance.new("Attachment")
line.Attachment0 = line1
line.Attachment1 = line2
line.Parent = workspace.Terrain
line1.Parent = workspace.Terrain
line2.Parent =workspace.Terrain


local camlockfov = Drawing.new("Circle")
camlockfov.Visible = getgenv().Settings.ShowFOV
camlockfov.Thickness = getgenv().Settings.Camlock.Thickness
camlockfov.NumSides = getgenv().Settings.Camlock.NumSides
camlockfov.Radius = getgenv().Settings.Camlock.Radius * 3
camlockfov.Color = getgenv().Settings.Camlock.Color
camlockfov.Filled = getgenv().Settings.Camlock.Filled
camlockfov.Transparency = getgenv().Settings.Camlock.Transparency

local silentfov = Drawing.new("Circle")
silentfov.Visible = getgenv().Settings.ShowFOV
silentfov.Thickness = getgenv().Settings.Silent.Thickness
silentfov.NumSides = getgenv().Settings.Silent.NumSides
silentfov.Radius = getgenv().Settings.Silent.Radius * 3
silentfov.Color = getgenv().Settings.Silent.Color
silentfov.Filled = getgenv().Settings.Silent.Filled
silentfov.Transparency = getgenv().Settings.Silent.Transparency

function visible(target)
     local obscuringParts = CurrentCamera:GetPartsObscuringTarget({CurrentCamera.CFrame.Position, target.Character.UpperTorso.Position}, {lplr.Character, target.Character.UpperTorso.Parent})
     if #obscuringParts > 0 then
         for i,v in pairs(obscuringParts) do
             if not v:IsDescendantOf(lplr.Character) then
                 return false
             end
         end
     end
     return true
end

function getgun()
    for _,v in pairs(aimviewtarget.Character:GetChildren()) do
        if v and (v:FindFirstChild('Default') or v:FindFirstChild('Handle') )then
            return v
        end
    end
end

function greet()
    Instance.new("Animation", game:GetService("ReplicatedStorage"):findFirstChild("ClientAnimations")).Name = 'Greet'
    game:GetService("ReplicatedStorage"):findFirstChild("ClientAnimations"):findFirstChild("Greet").AnimationId = 'rbxassetid://3189777795'
    lplr.Character:findFirstChildOfClass'Humanoid':LoadAnimation(game:GetService("ReplicatedStorage"):findFirstChild("ClientAnimations"):findFirstChild("Greet")):Play()
    wait(1.6)
    lplr.Character:findFirstChildOfClass'Humanoid':LoadAnimation(game:GetService("ReplicatedStorage"):findFirstChild("ClientAnimations"):findFirstChild("Greet")):Stop()
    wait()
    for i, v in next, lplr.Backpack:GetChildren() do
        if v:IsA("Tool") and v.Name ~= "Combat" or v.Name ~= "[Boombox]" then
            lplr.Character:findFirstChildOfClass'Humanoid':EquipTool(v)
        end
    end
end

function getnamecall()
    if game.PlaceId == 2788229376 then
        return "UpdateMousePos"
    elseif game.PlaceId == 5602055394 or game.PlaceId == 7951883376 then
        return "MousePos"
    elseif game.PlaceId == 9825515356 then
        return "GetMousePos"
    end
end

if game.PlaceId == 9825515356 then
    disableMacro = true
end

print(disableMacro)

local namecalltype = getnamecall()

function MainEventLocate()
    for i,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v.Name == "MainEvent" then
            return v
        end
    end
end

local mainevent = MainEventLocate()

function inSilentRadius()
    if Plr and HitPart then
        local pos = nil
        if aimchecks(Plr) then
            pos = CurrentCamera:WorldToViewportPoint(Plr.Character[HitPart].Position + Plr.Character[HitPart].Velocity * getgenv().Settings.Prediction)
        else
            pos = CurrentCamera:WorldToViewportPoint(Plr.Character[HitPart].Position + ((vels[Plr]) * getgenv().Settings.Prediction))
        end
        local mag = (Vector2new(Mouse.X, Mouse.Y + 36) - Vector2new(pos.X, pos.Y)).Magnitude
        if mag < getgenv().Settings.Silent.Radius * 3 then
            inSilRad = true
        else
            inSilRad = false
        end
    end
end

function inCamlockRadius()
    if Plr then
        local pos = nil
        if aimchecks(Plr) then
            pos = CurrentCamera:WorldToViewportPoint(Plr.Character[CamPart].Position + Plr.Character[CamPart].Velocity * getgenv().Settings.Prediction)
        else
            pos = CurrentCamera:WorldToViewportPoint(Plr.Character[CamPart].Position + ((vels[Plr]) * getgenv().Settings.Prediction))
        end
        local mag = (Vector2new(Mouse.X, Mouse.Y + 36) - Vector2new(pos.X, pos.Y)).Magnitude
        if mag < getgenv().Settings.Camlock.Radius * 3 then
            inCamRad = true
        else
            inCamRad = false
        end
    end
end

function aimchecks(cum)
    if (cum.Character.HumanoidRootPart.Velocity.Y < -5 and cum.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall) or cum.Character.HumanoidRootPart.Velocity.Y < -50 then
        return true
    elseif cum and (cum.Character.HumanoidRootPart.Velocity.X > 35 or cum.Character.HumanoidRootPart.Velocity.X < -35) then
        return true
    elseif cum and cum.Character.HumanoidRootPart.Velocity.Y > 60 then
        return true
    elseif cum and (cum.Character.HumanoidRootPart.Velocity.Z > 35 or cum.Character.HumanoidRootPart.Velocity.Z < -35) then
        return true
    else
        return false
    end
end

local function firstPersonMacro()
    while Toggled do
        keypress(0x04)
        rs.RenderStepped:wait()
        keypress(0x04)
        rs.RenderStepped:wait()
        mousescroll(1000)
        rs.RenderStepped:wait()
        mousescroll(-1000)
        rs.RenderStepped:wait()
    end
end

function thirdPersonMacro()
    if getrenv()._G.HoldGunBool then
        while Toggled do
            keypress(0x59)
            rs.RenderStepped:wait()
            keypress(0x55)
            rs.RenderStepped:wait()
            keyrelease(0x59)
            rs.RenderStepped:wait()
            keyrelease(0x55)
            rs.RenderStepped:wait()
        end
    else
        while Toggled do 
            keypress(0x49)
            rs.RenderStepped:wait()
            keypress(0x4F)
            rs.RenderStepped:wait()
            keyrelease(0x49)
            rs.RenderStepped:wait()
            keyrelease(0x4F)
            rs.RenderStepped:wait()
        end
    end
end

function noclip()
    while nocliping do
        vim:SendKeyEvent(true, Enum.KeyCode[getgenv().Settings.Noclip.Gun2], false, game)
        wait(0.017)
        vim:SendKeyEvent(true, Enum.KeyCode[getgenv().Settings.Noclip.Gun1], false, game) 
        wait(0.017)
    end
end

function silentFunction()
    if Plr then
        print(inSilRad)
        if HitPart and inSilRad then
            if not aimchecks(Plr) then
                mainevent:FireServer(namecalltype, Plr.Character[HitPart].Position + (Plr.Character[HitPart].Velocity * getgenv().Settings.Prediction))
            else
                mainevent:FireServer(namecalltype, Plr.Character[HitPart].Position + ((vels[Plr]) * getgenv().Settings.Prediction))
            end
        end
    end
end

function calcvel(v, delta)
    if Plr and CamPart then
        if originalpos == nil then
            originalpos = Plr.Character.HumanoidRootPart.Position
            return Vector3.new(0, 0, 0)
        end
        local velocity = (Plr.Character.HumanoidRootPart.Position - originalpos) / delta
        originalpos = Plr.Character.HumanoidRootPart.Position
        vels[Plr] = velocity / Vector3.new(1,4,1)
    end
end

function GetNearestPart()
    local Closest = {Part = nil, Dist = math.huge}
    if Plr then
        for _,v in pairs(Plr.Character:GetChildren()) do
            if table.find(bodyparts, v.Name) then
                local pos = CurrentCamera:WorldToViewportPoint(v.Position)
                local Magn = (Vector2new(Mouse.X, Mouse.Y + 36) - Vector2new(pos.X, pos.Y)).Magnitude
                if Magn < Closest.Dist then
                    Closest.Dist = Magn
                    Closest.Part = v
                end
            end
        end
        HitPart = Closest.Part.Name
    end
end

function GetCamNearestPart()
    local Closest = {Part = nil, Dist = math.huge}
    if Plr then
        for _,v in pairs(Plr.Character:GetChildren()) do
            if table.find(cambodyparts, v.Name) then
                local pos = CurrentCamera:WorldToViewportPoint(v.Position)
                local Magn = (Vector2new(Mouse.X, Mouse.Y + 36) - Vector2new(pos.X, pos.Y)).Magnitude
                if Magn < Closest.Dist then
                    Closest.Dist = Magn
                    Closest.Part = v
                end
            end
        end
        CamPart = Closest.Part.Name
    end
end


function FindClosestUser()
    local closestPlayer
    local shortestDistance = math.huge

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health ~= 0 and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = CurrentCamera:WorldToViewportPoint(p.Character.PrimaryPart.Position)
            local magnitude = (Vector2new(pos.X, pos.Y) - Vector2new(Mouse.X, Mouse.Y)).magnitude
            if magnitude < shortestDistance then
                closestPlayer = p
                shortestDistance = magnitude
            end
        end
    end
    return closestPlayer
end

rs.RenderStepped:Connect(function(delta)
    for _,v in pairs(game.Players:GetPlayers()) do
        calcvel(v, delta)
    end
    silentfov.Position = Vector2new(Mouse.X, Mouse.Y + 36)
    camlockfov.Position = Vector2new(Mouse.X, Mouse.Y + 36)
    if enabled and getgenv().Settings.Camlock.Enabled then
        GetCamNearestPart()
        inCamlockRadius()
        print(inCamRad)
        if Plr and inCamRad and visible(Plr) then
            local oldPred = getgenv().Settings.Prediction
            local dist = (lplr.Character.UpperTorso.Position - Plr.Character.UpperTorso.Position).Magnitude
            if Plr.Character and dist > 45 then
                local oldvelo = Plr.Character[HitPart].Velocity
                Plr.Character[HitPart].Velocity = Vector3.new(oldvelo.X, 0, oldvelo.Z)
                getgenv().Settings.Prediction = oldPred/2
            else
                getgenv().Settings.Prediction = oldPred
            end
            if Plr.Character.BodyEffects["K.O"].Value == true or lplr.Character.BodyEffects["K.O"].Value == true then
                enabled = false
                Plr = nil
            else
                local main = nil
                local peepee = mathrand(-(getgenv().Settings.Camlock.ShakeValue), getgenv().Settings.Camlock.ShakeValue)
                local rahhh = Vector3new(peepee, peepee, peepee)
                if getgenv().Settings.Camlock.Smoothness then
                    if not aimchecks(Plr) then
                        main = cnew(CurrentCamera.CFrame.p, (Plr.Character[CamPart].Position + Plr.Character[CamPart].Velocity * getgenv().Settings.Prediction) + rahhh)
                    else
                        main = cnew(CurrentCamera.CFrame.p, (Plr.Character[CamPart].Position + (vels[Plr]) * getgenv().Settings.Prediction) + rahhh)
                    end
                                
                    CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(main, getgenv().Settings.Camlock.SmoothnessAmount, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                else
                    if not aimchecks(Plr) then
                        CurrentCamera.CFrame = cnew(CurrentCamera.CFrame.p, (Plr.Character[CamPart].Position + Plr.Character[CamPart].Velocity * getgenv().Settings.Prediction) + rahhh)
                    else
                        CurrentCamera.CFrame = cnew(CurrentCamera.CFrame.p, (Plr.Character[CamPart].Position + (vels[Plr]) * getgenv().Settings.Prediction) + rahhh)
                    end
                end
            end
        end
    end
    if viewing and aimviewtarget then
        local character = lplr.Character
            if not character then
            line.Enabled = false
            return
        end

        if getgenv().Settings.AimViewer.Enabled and getgun() and aimviewtarget.Character:FindFirstChild("BodyEffects") and aimviewtarget.Character:FindFirstChild("Head")  then
            line.Enabled = true
            line1.Position =  aimviewtarget.Character:FindFirstChild("Head").Position
            line2.Position = aimviewtarget.Character.BodyEffects.MousePos.Value ---edit this if some random ass game got some weird ass other name :palingface
        else
            line.Enabled = false
        end
    end
end)



--[[
rs.RenderStepped:Connect(function()
    if getgenv().Settings.Spoofers.Memory then
        for __, v in pairs(game.CoreGui.RobloxGui.PerformanceStats:GetChildren()) do
            if v.Name == "PS_Button" and v.StatsMiniTextPanelClass.TitleLabel.Text == "Mem" then
                Memory = v.StatsMiniTextPanelClass.ValueLabel
            end
        end
        
        Memory:GetPropertyChangedSignal("Text"):Connect(function()
            local Random = math.random(getgenv().Settings.Spoofers.Min,getgenv().Settings.Spoofers.Max)
            Random = Random * 1.23 
            Memory.Text = "".. Random .." MB"
        end)
    end
end)]]

uis.InputBegan:Connect(function(key, typing)
    if not typing then
        if key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.Macro:upper()] and getgenv().Settings.Macro.Enabled then
            if Toggled then
                Toggled = false
            else
                Toggled = true
                if getgenv().Settings.Macro.AutoGreet == true and speedglitched == false and not disableMacro then
                    greet()
                    speedglitched = true
                else
                    speedglitched = true
                end
                if speedglitched then
                    if getgenv().Settings.Macro.Perspective == "First" then
                        firstPersonMacro()
                    elseif getgenv().Settings.Macro.Perspective == "Third" then
                        thirdPersonMacro()
                    end
                end
            end
        elseif key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.LockBind:upper()] then
            enabled = true
            Plr = FindClosestUser()
        elseif key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.UnlockBind:upper()] then
            enabled = false
            Plr = nil
        elseif key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.HideVisuals:upper()] then
            if showVisuals then
                showVisuals = false
                silentfov.Visible = false
                camlockfov.Visible = false
            else
                showVisuals = true
                silentfov.Visible = true
                camlockfov.Visible = true
            end
        elseif key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.AimView:upper()] then
            if viewing then
                viewing = false
                aimviewtarget = nil
                line.Enabled = false
            else
                viewing = true
                aimviewtarget = FindClosestUser()
            end
        elseif key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.Noclip:upper()] and getgenv().Settings.Noclip.Enabled then
            if nocliping then
                nocliping = false
            else
                nocliping = true
                noclip()
            end
        end
        if getrenv()._G.HoldGunBool then
            if key.KeyCode == Enum.KeyCode.Y then
                Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance - 5)
            end
            if key.KeyCode == Enum.KeyCode.U then
                Controller:SetCameraToSubjectDistance(Controller.currentSubjectDistance + 5)
            end
        end
    end
end)

uis.InputEnded:Connect(function(key, typing)
    if not typing then
        if key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.Macro:upper()] then
            if getgenv().Settings.Macro.Mode == "Hold" and Toggled then
                Toggled = false
            end
        elseif key.KeyCode == Enum.KeyCode[getgenv().Settings.Binds.Noclip:upper()] and getgenv().Settings.Noclip.Enabled then
            if noclipping then
                noclipping = false
                print("un noclipping")
            end
        end
    end
end)

lplr.Character.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") then
        --[[
        if child.Name == "[Double-Barrel SG]" then
            fov.Radius = getgenv().FovSettings.DoubleBarrelFOV*3
        elseif child.Name == "[TacticalShotgun]" then
            fov.Radius = getgenv().FovSettings.TacticalShotgunFOV*3
        elseif child.Name == "[Shotgun]" then
            fov.Radius = getgenv().FovSettings.ShotgunFOV*3
        elseif child.name == "[SMG]" or child.Name == "[P90]" or child.Name == "[Vector]" then
            fov.Radius = getgenv().FovSettings.SMGFOV*3
        elseif child.Name == "[Revolver]" then
            fov.Radius = getgenv().FovSettings.RevFOV*3
        elseif child.Name == "[Silencer]" then
            fov.Radius = getgenv().FovSettings.SilencerFOV*3
        else
            fov.Radius = getgenv().FovSettings.OthersFOV*3
        end]]
        if speedglitched then
            speedglitched = false
        end
        tool.Activated:connect(function()
            GetNearestPart()
            inSilentRadius()
            silentFunction()
        end)
    end
end)

lplr.Character.ChildRemoved:Connect(function(tool)
    if tool:IsA("Tool") then
        if speedglitched then
            speedglitched = false
        end
    end
end)

lplr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            if speedglitched then
                speedglitched = false
            end
            tool.Activated:connect(function()
                GetNearestPart()
                inSilentRadius()
                silentFunction()
            end)
        end
    end)

    char.ChildRemoved:Connect(function(tool)
        if tool:IsA("Tool") then
            if speedglitched then
                speedglitched = false
            end
        end
    end)
end)

coroutine.resume(coroutine.create(function()
    while true do
        if getgenv().Settings.AutoPrediction then
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            if ping <= 40 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping30_40
            elseif ping <= 50 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping40_50
            elseif ping <= 60 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping50_60
            elseif ping <= 70 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping60_70
            elseif ping <= 80 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping70_80
            elseif ping <= 90 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping80_90
            elseif ping <= 100 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping90_100
            elseif ping <= 110 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping100_110
            elseif ping <= 120 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping110_120
            elseif ping <= 130 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping120_130
            elseif ping <= 140 then
                getgenv().Settings.Prediction = getgenv().AutoPrediction.Ping130_140
            end
            task.wait(0.3)
        end
    end
end))
--[[
    NIGHTMARE LIBRARY - Load Steal Edition
    Modified with Auto Steal System
]]

local Nightmare = {}
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==================== ANTI-DETECTION PARENT ====================
local function getSafeCoreGuiParent()
    if gethui then
        local success, result = pcall(function()
            return gethui()
        end)
        if success and result then
            return result
        end
    end

    if syn and syn.protect_gui then
        local protectedGui = Instance.new("ScreenGui")
        protectedGui.Name = "Nightmare_Protected"
        protectedGui.ResetOnSpawn = false
        protectedGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        syn.protect_gui(protectedGui)
        protectedGui.Parent = CoreGui
        return protectedGui
    end

    return CoreGui
end

-- ==================== CONFIG SAVE SYSTEM ====================
local ConfigSystem = {}
ConfigSystem.ConfigFile = "Nightmare_Config.json"
ConfigSystem.DefaultConfig = {}

function ConfigSystem:Load()
    if isfile and isfile(self.ConfigFile) then
        local success, result = pcall(function()
            local fileContent = readfile(self.ConfigFile)
            local decoded = HttpService:JSONDecode(fileContent)
            return decoded
        end)
        
        if success and result then
            return result
        else
            warn("⚠️ Failed to load config, using defaults")
            return self.DefaultConfig
        end
    else
        return self.DefaultConfig
    end
end

function ConfigSystem:Save(config)
    local success, error = pcall(function()
        local encoded = HttpService:JSONEncode(config)
        writefile(self.ConfigFile, encoded)
    end)
    
    if success then
        return true
    else
        warn("❌ Failed to save config:", error)
        return false
    end
end

function ConfigSystem:UpdateSetting(config, key, value)
    config[key] = value
    self:Save(config)
end

-- ==================== NOTIFICATION SYSTEM ====================
local NotificationGui = nil
local DEFAULT_NOTIFICATION_SOUND_ID = 3398620867

local function createNotificationGui()
    if NotificationGui then return end
    
    local safeParent = getSafeCoreGuiParent()
    
    NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "NightmareNotificationGui"
    NotificationGui.ResetOnSpawn = false
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.Parent = safeParent
end

-- ==================== LOAD STEAL SYSTEM VARIABLES ====================
local LoadStealActive = false
local LoadStealConnection = nil
local velocityConnection = nil
local isCloning = false

-- ==================== MODULES ====================
local AnimalsModule, TraitsModule, MutationsModule
pcall(function()
    AnimalsModule = require(ReplicatedStorage.Datas.Animals)
    TraitsModule = require(ReplicatedStorage.Datas.Traits)
    MutationsModule = require(ReplicatedStorage.Datas.Mutations)
end)

-- ==================== DETECTION LOGIC ====================

local function getTraitMultiplier(model)
    if not TraitsModule then return 0 end
    local traitJson = model:GetAttribute("Traits")
    if not traitJson or traitJson == "" then return 0 end
    local traits = {}
    local ok, decoded = pcall(function() return HttpService:JSONDecode(traitJson) end)
    if ok and typeof(decoded) == "table" then traits = decoded
    else for t in string.gmatch(traitJson, "[^,]+") do table.insert(traits, t) end end
    local mult = 0
    for _, entry in pairs(traits) do
        local name = typeof(entry) == "table" and entry.Name or tostring(entry)
        name = name:gsub("^_Trait%.", "")
        local trait = TraitsModule[name]
        if trait and trait.MultiplierModifier then mult += tonumber(trait.MultiplierModifier) or 0 end
    end
    return mult
end

local function getFinalGeneration(model)
    if not AnimalsModule then return 0 end
    local animalData = AnimalsModule[model.Name]
    if not animalData then return 0 end
    local baseGen = tonumber(animalData.Generation) or tonumber(animalData.Price or 0)
    local traitMult = getTraitMultiplier(model)
    local mutationMult = 0
    if MutationsModule then
        local mutation = model:GetAttribute("Mutation")
        if mutation and MutationsModule[mutation] then mutationMult = tonumber(MutationsModule[mutation].Modifier or 0) end
    end
    return math.max(1, math.round(baseGen * (1 + traitMult + mutationMult)))
end

local function isPlayerPlot(plot)
    local plotSign = plot:FindFirstChild("PlotSign")
    if plotSign then
        local yourBase = plotSign:FindFirstChild("YourBase")
        if yourBase and yourBase.Enabled then return true end
    end
    return false
end

local function findTheAbsoluteBestPet()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local highest = {value = 0}
    for _, plot in pairs(plots:GetChildren()) do
        if not isPlayerPlot(plot) then
            for _, obj in pairs(plot:GetDescendants()) do
                if obj:IsA("Model") and AnimalsModule and AnimalsModule[obj.Name] then
                    pcall(function()
                        local gen = getFinalGeneration(obj)
                        if gen > 0 and gen > highest.value then
                            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                            if root then
                                highest = {
                                    plot = plot,
                                    model = obj,
                                    value = gen,
                                    position = root.Position,
                                    rootPart = root
                                }
                            end
                        end
                    end)
                end
            end
        end
    end
    return highest.value > 0 and highest or nil
end

-- ==================== TELEPORT LOGIC ====================

local function equipFlyingCarpet()
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    humanoid:UnequipTools()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local carpet = backpack:FindFirstChild("Flying Carpet") or 
                  backpack:FindFirstChild("FlyingCarpet") or
                  backpack:FindFirstChild("flying carpet") or
                  backpack:FindFirstChild("flyingcarpet")
    
    if carpet then
        carpet.Parent = character
        humanoid:EquipTool(carpet)
        return true
    end
    return false
end

local function stopVelocity()
    if velocityConnection then velocityConnection:Disconnect(); velocityConnection = nil end
end

local function getSideBounds(sideFolder)
    if not sideFolder then return nil end
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    local found = false
    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                found = true
                local p = child.Position
                minX, minY, minZ = math.min(minX, p.X), math.min(minY, p.Y), math.min(minZ, p.Z)
                maxX, maxY, maxZ = math.max(maxX, p.X), math.max(maxY, p.Y), math.max(maxZ, p.Z)
            else scan(child) end
        end
    end
    scan(sideFolder)
    if not found then return nil end
    local center = Vector3.new((minX + maxX) * 0.5, (minY + maxY) * 0.5, (minZ + maxZ) * 0.5)
    local halfSize = Vector3.new((maxX - minX) * 0.5, (maxY - minY) * 0.5, (maxZ - minZ) * 0.5)
    return {center = center, halfSize = halfSize}
end

local function getSafeOutsideDecorPos(plot, targetPos, fromPos)
    local decorations = plot:FindFirstChild("Decorations")
    if not decorations then return targetPos end
    local side3Folder = decorations:FindFirstChild("Side 3")
    if not side3Folder then return targetPos end
    local info = getSideBounds(side3Folder)
    if not info then return targetPos end
    
    local center, halfSize = info.center, info.halfSize
    local MARGIN = 3.2
    local localTarget = targetPos - center
    if math.abs(localTarget.X) <= halfSize.X + MARGIN and math.abs(localTarget.Z) <= halfSize.Z + MARGIN then
        local src = fromPos and (fromPos - center) or localTarget
        local dirUnit = Vector3.new(src.X, 0, src.Z).Unit
        local tx = (dirUnit.X ~= 0) and (((dirUnit.X > 0 and halfSize.X or -halfSize.X)) / dirUnit.X) or math.huge
        local tz = (dirUnit.Z ~= 0) and (((dirUnit.Z > 0 and halfSize.Z or -halfSize.Z)) / dirUnit.Z) or math.huge
        local worldPos = center + dirUnit * (math.min(tx, tz) + MARGIN)
        return Vector3.new(worldPos.X, targetPos.Y, worldPos.Z)
    end
    return targetPos
end

local function faceTarget(targetPos)
    local character = LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local currentPos = hrp.Position
    local direction = (targetPos - currentPos) * Vector3.new(1, 0, 1)
    
    if direction.Magnitude > 0 then
        local lookCFrame = CFrame.new(currentPos, currentPos + direction)
        hrp.CFrame = CFrame.new(hrp.Position) * (lookCFrame - lookCFrame.Position)
        return true
    end
    return false
end

-- ==================== INSTANT CLONER ====================

local function instantCloner()
    if isCloning then return false end
    isCloning = true
    
    local success = pcall(function()
        local character = LocalPlayer.Character
        if not character then error("Character not found") end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then error("Humanoid not found") end
        
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                humanoid:UnequipTools()
                task.wait(0.1)
                break
            end
        end
        
        local backpack = LocalPlayer.Backpack
        local cloner = backpack:FindFirstChild("Quantum Cloner")
        if not cloner then error("Quantum Cloner not found!") end
        
        humanoid:EquipTool(cloner)
        task.wait(0.1)
        
        local useRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/UseItem")
        useRemote:FireServer()
        task.wait(0.1)
        
        local clonerRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/QuantumCloner/OnTeleport")
        clonerRemote:FireServer()
    end)
    
    task.wait(1)
    isCloning = false
    return success
end

-- ==================== FLY SYSTEM ====================

local flyConnection = nil
local H_SPEED = 70
local V_SPEED = 38
local BASE_GRAVITY = 0.72
local HEAD_OFFSET = 2.7
local CEILING_ZONE = 0.45
local ARRIVAL_DISTANCE = 5
local MODE = "IDLE"
local stateCooldown = 0

local function getForces(root)
    local att = root:FindFirstChild("FLY_Att") or Instance.new("Attachment", root)
    att.Name = "FLY_Att"

    local lv = root:FindFirstChild("FLY_LV") or Instance.new("LinearVelocity", root)
    lv.Name = "FLY_LV"
    lv.Attachment0 = att
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.MaxForce = math.huge

    local vf = root:FindFirstChild("FLY_VF") or Instance.new("VectorForce", root)
    vf.Name = "FLY_VF"
    vf.Attachment0 = att
    vf.RelativeTo = Enum.ActuatorRelativeTo.World
    vf.ApplyAtCenterOfMass = true

    return lv, vf
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function ceilingDistance(root)
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local hit = Workspace:Raycast(
        root.Position + Vector3.new(0, HEAD_OFFSET, 0),
        Vector3.new(0, 1.5, 0),
        rayParams
    )
    if hit then
        return hit.Position.Y - (root.Position.Y + HEAD_OFFSET)
    end
end

local function cleanupFlyForces()
    if flyConnection then 
        flyConnection:Disconnect() 
        flyConnection = nil 
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, name in ipairs({"FLY_LV", "FLY_VF", "FLY_Att"}) do
        local obj = hrp:FindFirstChild(name)
        if obj then obj:Destroy() end
    end
    
    MODE = "IDLE"
    stateCooldown = 0
end

local function flyToTarget(targetPos)
    local character = LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    local hasArrived = false
    
    flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not hrp or not hrp.Parent then 
            cleanupFlyForces()
            return 
        end
        
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        
        local lv, vf = getForces(hrp)
        
        if stateCooldown > 0 then
            stateCooldown -= dt
        end
        
        local distance = (targetPos - hrp.Position).Magnitude
        if distance <= ARRIVAL_DISTANCE then
            hasArrived = true
            lv.VectorVelocity = Vector3.zero
            cleanupFlyForces()
            return
        end
        
        local ceilingDelta = ceilingDistance(hrp)
        
        if ceilingDelta and ceilingDelta <= CEILING_ZONE then
            MODE = "STICK"
        else
            if MODE == "STICK" then
                MODE = "FLY"
            end
        end
        
        local mass = hrp.AssemblyMass
        vf.Force = Vector3.new(0, Workspace.Gravity * mass * BASE_GRAVITY, 0)
        
        if MODE == "STICK" then
            lv.VectorVelocity = Vector3.zero
            return
        end
        
        local delta = targetPos - hrp.Position
        local h = Vector3.new(delta.X, 0, delta.Z)
        local hDist = h.Magnitude
        local hDir = hDist > 0 and h.Unit or Vector3.zero
        
        local curve = math.clamp(hDist / 10, 0.2, 1)
        local v = math.clamp(delta.Y, -1, 1) * V_SPEED * curve
        
        lv.VectorVelocity = Vector3.new(
            hDir.X * H_SPEED,
            v,
            hDir.Z * H_SPEED
        )
    end)
    
    local timeout = 0
    while not hasArrived and timeout < 30 do
        task.wait(0.1)
        timeout += 0.1
    end
    
    cleanupFlyForces()
    return hasArrived
end

-- ==================== AUTO TP TO BEST ====================

local function autoTPToBest()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return nil end
    
    local bestPet = findTheAbsoluteBestPet()
    if not bestPet then return nil end
    
    local currentPos = hrp.Position
    local targetPos = bestPet.position
    local directionToPet = (targetPos - currentPos).Unit
    local approachPos = targetPos - (directionToPet * 7)
    
    if targetPos.Y > 10 then approachPos = Vector3.new(approachPos.X, 20, approachPos.Z)
    else approachPos = Vector3.new(approachPos.X, targetPos.Y + 2, approachPos.Z) end
    
    if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.05)
    end
    
    local targetUpwardSpeed = 120
    local currentUpwardSpeed = 0
    local smoothness = 0.25
    local elapsed = 0
    local maxDuration = 0.3
    
    velocityConnection = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed >= maxDuration then stopVelocity(); return end
        currentUpwardSpeed = currentUpwardSpeed + (targetUpwardSpeed - currentUpwardSpeed) * smoothness
        hrp.Velocity = Vector3.new(hrp.Velocity.X, currentUpwardSpeed, hrp.Velocity.Z)
    end)
    
    task.wait(0.3)
    stopVelocity()
    
    if equipFlyingCarpet() then
        task.wait(0.1)
        local finalPos = getSafeOutsideDecorPos(bestPet.plot, approachPos, currentPos)
        if finalPos.Y > 10 then finalPos = Vector3.new(finalPos.X, 20, finalPos.Z)
        else finalPos = Vector3.new(finalPos.X, finalPos.Y, finalPos.Z) end
        
        hrp.CFrame = CFrame.new(finalPos)
    end
    
    return bestPet
end

-- ==================== MAIN AUTO STEAL ====================

local function autoSteal()
    if not LoadStealActive then return end
    
    local bestPet = autoTPToBest()
    if not bestPet then return end
    
    task.wait(0.5)
    faceTarget(bestPet.position)
    task.wait(0.3)
    instantCloner()
    task.wait(0.5)
    flyToTarget(bestPet.position)
end

-- ==================== LOAD STEAL LOOP ====================

local function startLoadSteal()
    if LoadStealConnection then return end
    LoadStealActive = true
    
    LoadStealConnection = task.spawn(function()
        while LoadStealActive do
            pcall(autoSteal)
            task.wait(2)
        end
    end)
end

local function stopLoadSteal()
    LoadStealActive = false
    if LoadStealConnection then
        task.cancel(LoadStealConnection)
        LoadStealConnection = nil
    end
    cleanupFlyForces()
    stopVelocity()
end

-- ==================== UI CREATION ====================
function Nightmare:Create()
    self.Config = ConfigSystem:Load()
    local safeParent = getSafeCoreGuiParent()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NightmareGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = safeParent

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Image = "rbxassetid://18514852024"
    ToggleButton.Size = UDim2.new(0, 45, 0, 45)
    ToggleButton.Position = UDim2.new(0, 15, 0.5, -22.5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Active = true
    ToggleButton.Draggable = true
    ToggleButton.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = ToggleButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 2
    stroke.Parent = ToggleButton

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 240, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -120, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = MainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 50, 50)
    mainStroke.Thickness = 2
    mainStroke.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "NIGHTMARE"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    TitleLabel.Font = Enum.Font.Arcade
    TitleLabel.TextSize = 20
    TitleLabel.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -110)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.Parent = MainFrame

    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 10)
    scrollCorner.Parent = ScrollFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.FillDirection = Enum.FillDirection.Vertical
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Parent = ScrollFrame

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Helper Functions
    local function createToggleButton(parent, name, text, position, size)
        local toggle = Instance.new("TextButton")
        toggle.Name = name
        toggle.Size = size
        toggle.Position = position
        toggle.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        toggle.BorderSizePixel = 0
        toggle.Text = text
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 11
        toggle.Font = Enum.Font.Arcade
        toggle.Parent = parent

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggle

        local toggleStroke = Instance.new("UIStroke")
        toggleStroke.Color = Color3.fromRGB(255, 50, 50)
        toggleStroke.Thickness = 1
        toggleStroke.Parent = toggle

        return toggle
    end

    local function setToggleState(toggle, state)
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(0, 139, 0)
            toggle.TextColor3 = Color3.fromRGB(200, 255, 200)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
            toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    -- Utility Frame
    local UtilityFrame = Instance.new("Frame")
    UtilityFrame.Size = UDim2.new(0, 200, 0, 250)
    UtilityFrame.Position = UDim2.new(0, 250, 0.5, -125)
    UtilityFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    UtilityFrame.BorderSizePixel = 0
    UtilityFrame.Visible = false
    UtilityFrame.Parent = MainFrame

    local utilityCorner = Instance.new("UICorner")
    utilityCorner.CornerRadius = UDim.new(0, 15)
    utilityCorner.Parent = UtilityFrame

    local utilityStroke = Instance.new("UIStroke")
    utilityStroke.Color = Color3.fromRGB(255, 50, 50)
    utilityStroke.Thickness = 2
    utilityStroke.Parent = UtilityFrame

    local UtilityTitle = Instance.new("TextLabel")
    UtilityTitle.Size = UDim2.new(1, 0, 0, 35)
    UtilityTitle.BackgroundTransparency = 1
    UtilityTitle.Text = "UTILITY"
    UtilityTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
    UtilityTitle.Font = Enum.Font.Arcade
    UtilityTitle.TextSize = 16
    UtilityTitle.Parent = UtilityFrame

    local UtilityScrollFrame = Instance.new("ScrollingFrame")
    UtilityScrollFrame.Size = UDim2.new(1, -20, 1, -50)
    UtilityScrollFrame.Position = UDim2.new(0, 10, 0, 40)
    UtilityScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    UtilityScrollFrame.BorderSizePixel = 0
    UtilityScrollFrame.ScrollBarThickness = 4
    UtilityScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    UtilityScrollFrame.Parent = UtilityFrame

    local UtilityListLayout = Instance.new("UIListLayout")
    UtilityListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UtilityListLayout.Padding = UDim.new(0, 8)
    UtilityListLayout.FillDirection = Enum.FillDirection.Vertical
    UtilityListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UtilityListLayout.Parent = UtilityScrollFrame

    UtilityListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UtilityScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UtilityListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Utility Button
    local utilityButton = Instance.new("TextButton")
    utilityButton.Size = UDim2.new(0, 100, 0, 32)
    utilityButton.Position = UDim2.new(0, 15, 1, -55)
    utilityButton.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    utilityButton.BorderSizePixel = 0
    utilityButton.Text = "Utility"
    utilityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    utilityButton.TextSize = 13
    utilityButton.Font = Enum.Font.Arcade
    utilityButton.Parent = MainFrame

    local utilityCornerBtn = Instance.new("UICorner")
    utilityCornerBtn.CornerRadius = UDim.new(0, 8)
    utilityCornerBtn.Parent = utilityButton

    local utilityStrokeBtn = Instance.new("UIStroke")
    utilityStrokeBtn.Color = Color3.fromRGB(255, 50, 50)
    utilityStrokeBtn.Thickness = 1
    utilityStrokeBtn.Parent = utilityButton

    utilityButton.MouseButton1Click:Connect(function()
        UtilityFrame.Visible = not UtilityFrame.Visible
    end)

    -- Discord Button
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0, 100, 0, 32)
    discordButton.Position = UDim2.new(0, 125, 1, -55)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.BorderSizePixel = 0
    discordButton.Text = "  Discord"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 13
    discordButton.Font = Enum.Font.Arcade
    discordButton.Parent = MainFrame

    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 8)
    discordCorner.Parent = discordButton

    local discordIcon = Instance.new("ImageLabel")
    discordIcon.Size = UDim2.new(0, 16, 0, 16)
    discordIcon.Position = UDim2.new(0, 9, 0.5, -8)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Image = "rbxassetid://131585302403438"
    discordIcon.Parent = discordButton

    discordButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/WB2p6Zvh")
        discordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
        task.wait(0.2)
        discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)

    ToggleButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- CREATE UTILITY TOGGLES
    local function createIntegratedUtilityToggle(toggleName, configKey, callback)
        local utilityToggle = createToggleButton(
            UtilityScrollFrame, 
            "UtilityToggle_" .. toggleName, 
            toggleName, 
            UDim2.new(0, 10, 0, 0), 
            UDim2.new(0, 160, 0, 32)
        )
        
        local isToggled = self.Config[configKey] or false
        setToggleState(utilityToggle, isToggled)
        if callback then callback(isToggled) end
        
        utilityToggle.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            setToggleState(utilityToggle, isToggled)
            ConfigSystem:UpdateSetting(self.Config, configKey, isToggled)
            if callback then callback(isToggled) end
        end)
    end

    -- Load Steal Toggle
    createIntegratedUtilityToggle("Load Steal", "Nightmare_Utility_LoadSteal", function(state)
        if state then
            startLoadSteal()
        else
            stopLoadSteal()
        end
    end)

    createNotificationGui()
    print("✅ Nightmare Created Successfully!")
end

-- ==================== NOTIFY FUNCTION ====================
function Nightmare:Notify(text, soundId)
    if not NotificationGui then createNotificationGui() end

    local soundToPlay = soundId or DEFAULT_NOTIFICATION_SOUND_ID
    
    if soundToPlay then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundToPlay
        sound.Volume = 0.4
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 0)
    notifFrame.Position = UDim2.new(0.5, 0, 0, -100)
    notifFrame.AnchorPoint = Vector2.new(0.5, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notifFrame.BackgroundTransparency = 0.1
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = NotificationGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notifFrame
    
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(255, 50, 50)
    outline.Thickness = 1.0
    outline.Parent = notifFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    textLabel.Font = Enum.Font.Arcade
    textLabel.TextSize = 18
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = notifFrame
    
    local tweenInfoIn = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local goalIn = { Size = UDim2.new(0, 300, 0, 60), Position = UDim2.new(0.5, 0, 0, 20) }
    local tweenIn = TweenService:Create(notifFrame, tweenInfoIn, goalIn)
    tweenIn:Play()
    
    task.spawn(function()
        task.wait(3)
        local tweenInfoOut = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local goalOut = { Size = UDim2.new(0, 300, 0, 0), Position = UDim2.new(0.5, 0, 0, -100) }
        local tweenOut = TweenService:Create(notifFrame, tweenInfoOut, goalOut)
        tweenOut:Play()
        tweenOut.Completed:Connect(function() notifFrame:Destroy() end)
    end)
end

-- ==================== ADD TOGGLE ROW ====================
function Nightmare:AddToggleRow(text1, callback1, text2, callback2)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 35)
    rowFrame.BackgroundTransparency = 1
    rowFrame.Parent = ScrollFrame

    local function createSingleToggle(text, callback, position)
        local configKey = "Nightmare_" .. text
        
        local toggle = createToggleButton(
            rowFrame, 
            "Toggle_" .. text, 
            text, 
            position, 
            UDim2.new(0, 100, 0, 32)
        )

        local isToggled = self.Config[configKey] or false
        setToggleState(toggle, isToggled)
        if callback then callback(isToggled) end

        toggle.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            setToggleState(toggle, isToggled)
            ConfigSystem:UpdateSetting(self.Config, configKey, isToggled)
            if callback then callback(isToggled) end
        end)
    end

    createSingleToggle(text1, callback1, UDim2.new(0, 5, 0, 0))
    if text2 and callback2 then
        createSingleToggle(text2, callback2, UDim2.new(0, 115, 0, 0))
    end
end

return Nightmare

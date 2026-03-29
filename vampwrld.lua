-- // --- LOADING LIBRARIES --- //
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- // --- MASTER VARIABLES (LOCKED) --- //
local Resolution = 1 

-- // --- Services --- //
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // --- Color Setup (LOCKED) --- //
local ColorCorr = Lighting:FindFirstChild("VampCC") or Instance.new("ColorCorrectionEffect", Lighting)
ColorCorr.Name = "VampCC"

-- // --- Window --- //
local Window = Library:CreateWindow({ 
    Title = 'Vamp.wrld ☾', 
    Center = true, 
    AutoShow = true 
})

local Tabs = { 
    World = Window:AddTab('World', 'lucide-globe'), 
    Settings = Window:AddTab('Settings', 'lucide-settings') 
}

-- // --- World Tab: Stretched Res & Colors (LOCKED) --- //
local ResSection = Tabs.World:AddLeftGroupbox('Stretched Res')
local ResSlider = ResSection:AddSlider('ResSlider', { Text = 'Resolution', Default = 1, Min = 0.1, Max = 2, Rounding = 2 })
ResSlider:OnChanged(function(v) Resolution = v end)

local ColorSection = Tabs.World:AddRightGroupbox('Screen Modifiers')
ColorSection:AddToggle('EnableCC', { Text = 'Enable Visuals', Default = false }):OnChanged(function(v) 
    ColorCorr.Enabled = v 
end)

ColorSection:AddSlider('Sat', { Text = 'Saturation', Default = 0, Min = -1, Max = 4, Rounding = 1 }):OnChanged(function(v) 
    ColorCorr.Saturation = v 
end)

ColorSection:AddSlider('Brit', { Text = 'Brightness', Default = 0, Min = -1, Max = 1, Rounding = 2 }):OnChanged(function(v) 
    ColorCorr.Brightness = v 
end)

ColorSection:AddSlider('Cont', { Text = 'Contrast', Default = 0, Min = -1, Max = 4, Rounding = 1 }):OnChanged(function(v) 
    ColorCorr.Contrast = v 
end)

-- // --- Settings Tab: Steal Identity --- //
local IdentitySection = Tabs.Settings:AddLeftGroupbox('Steal Identity')
IdentitySection:AddInput('IdentityID', { Text = 'Target User ID', Default = '', Placeholder = 'Paste ID...' })

local function ApplyIdentity(id)
    task.spawn(function()
        local Character = LocalPlayer.Character
        if not Character then return end
        
        -- Lock ID for game respawns
        LocalPlayer.CharacterAppearanceId = id
        
        -- Fetch and Force Inject
        local success, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(id) end)
        if success and desc then
            -- Manual Visual Strip
            for _, v in pairs(Character:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then 
                    v:Destroy() 
                end
            end
            task.wait(0.1)
            local Hum = Character:FindFirstChildOfClass("Humanoid")
            if Hum then Hum:ApplyDescription(desc) end
            Library:Notify("Identity Stolen (ID: " .. id .. ")")
        end
    end)
end

IdentitySection:AddButton('Steal Identity', function() 
    ApplyIdentity(tonumber(Options.IdentityID.Value)) 
end)

IdentitySection:AddButton('Refresh Character', function() 
    LocalPlayer:LoadCharacter() 
end)

IdentitySection:AddButton('Reset to Self', function() 
    ApplyIdentity(LocalPlayer.UserId) 
end)

-- // --- CONFIG SYSTEM (FULL WORKING) --- //
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'ResSlider' }) 

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- // --- THE MASTER LOOP --- //
RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    if Camera then
        -- Only applies Stretched Res (Optimized)
        Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, Resolution, 0, 0, 0, 1)
    end
end)

-- // --- AUTO-EXECUTE & TELEPORT HANDLER --- //
local teleportFunc = queue_on_teleport or (syn and syn.queue_on_teleport)
if teleportFunc then
    -- Replace the URL with your raw script link if you host it online
    teleportFunc([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Duszty/vampwrld/refs/heads/main/vampwrld.lua"))()]])
end

-- // --- FINALIZE --- //
SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)
Library:Notify("Vamp.wrld ☾ Loaded Successfully")

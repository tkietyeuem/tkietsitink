local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local ENDPOINT = "https://dashboard-i1e6.onrender.com/api/update"
local API_KEY = getgenv().Key or "fallback-token"

local AllowedPets = {
    ["Frog"] = true,
    ["Bunny"] = true,
    ["Owl"] = true,
    ["Bee"] = true,
    ["Deer"] = true,
    ["Robin"] = true,
    ["Monkey"] = true,
    ["Golden Dragonfly"] = true,
    ["Unicorn"] = true,
    ["Raccoon"] = true,
    ["Black Dragon"] = true,
    ["Ice Serpent"] = true
}

local function getPets()
    local equipped = {}
    local unequipped = {}

    local petequip = LocalPlayer:FindFirstChild("Petequip") or LocalPlayer:FindFirstChild("petequip") or LocalPlayer:FindFirstChild("PetEquip")
    if petequip then
        for _, pet in ipairs(petequip:GetChildren()) do
            if AllowedPets[pet.Name] then
                table.insert(equipped, pet.Name)
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if AllowedPets[item.Name] then
                table.insert(unequipped, item.Name)
            end
        end
    end

    table.sort(equipped)
    table.sort(unequipped)
    return equipped, unequipped
end

local function forceTransmit()
    local sheckles = 0
    
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        if child.Name:lower() == "leaderstats" then
            local sVal = child:FindFirstChild("Sheckles") or child:FindFirstChild("sheckles") or child:FindFirstChild("Money")
            if sVal and sVal:IsA("ValueBase") then
                sheckles = sVal.Value
                break
            end
        end
    end

    local eq, uneq = getPets()
    local payload = {
        apiKey = API_KEY,
        username = LocalPlayer.Name,
        sheckles = sheckles,
        equippedPets = eq,
        unequippedPets = uneq
    }

    local success, result = pcall(function()
        return HttpService:PostAsync(
            ENDPOINT,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson,
            false
        )
    end)

    if not success then
        warn("RENDER NET ERROR: " .. tostring(result))
    else
        print("RENDER NET SUCCESS: Data transmitted successfully!")
    end
end

task.spawn(function()
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        if child.Name:lower() == "leaderstats" then
            for _, val in ipairs(child:GetChildren()) do
                if val.Name:lower() == "sheckles" or val.Name:lower() == "money" then
                    val.Changed:Connect(forceTransmit)
                end
            end
        end
    end

    local petequip = LocalPlayer:FindFirstChild("Petequip") or LocalPlayer:FindFirstChild("petequip") or LocalPlayer:FindFirstChild("PetEquip")
    if petequip then
        petequip.ChildAdded:Connect(forceTransmit)
        petequip.ChildRemoved:Connect(forceTransmit)
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild("backpack")
    if backpack then
        backpack.ChildAdded:Connect(forceTransmit)
        backpack.ChildRemoved:Connect(forceTransmit)
    end

    forceTransmit()
end)

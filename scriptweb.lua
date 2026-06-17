local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local ENDPOINT = "https://dashboard-plvx.onrender.com/api/update"
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

local lastSheckles = -1
local lastPetsString = ""

local function getPets()
    local equipped = {}
    local unequipped = {}

    if LocalPlayer:FindFirstChild("Petequip") then
        for _, pet in ipairs(LocalPlayer.Petequip:GetChildren()) do
            if AllowedPets[pet.Name] then
                table.insert(equipped, pet.Name)
            end
        end
    end

    if LocalPlayer:FindFirstChild("Backpack") then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if AllowedPets[item.Name] then
                table.insert(unequipped, item.Name)
            end
        end
    end

    table.sort(equipped)
    table.sort(unequipped)

    return equipped, unequipped
end

local function transmitPayload(sheckles, eq, uneq)
    local payload = {
        apiKey = API_KEY,
        username = LocalPlayer.Name,
        sheckles = sheckles,
        equippedPets = eq,
        unequippedPets = uneq
    }

    pcall(function()
        HttpService:PostAsync(
            ENDPOINT,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson,
            false
        )
    end)
end

task.spawn(function()
    while task.wait(1) do
        local sheckles = 0
        if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Sheckles") then
            sheckles = LocalPlayer.leaderstats.Sheckles.Value
        end

        local eq, uneq = getPets()
        local currentPetsString = HttpService:JSONEncode({eq, uneq})

        if sheckles ~= lastSheckles or currentPetsString ~= lastPetsString then
            lastSheckles = sheckles
            lastPetsString = currentPetsString
            transmitPayload(sheckles, eq, uneq)
        end
    end
end)

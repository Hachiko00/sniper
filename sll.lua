local PetsToSell = {
    {petName = "Pastel Griffin", GemAmnt = 17000, PetAmount = 100},
    {petName = "Pastel Goat", GemAmnt = 28000, PetAmount = 100},
    {petName = "Vibrant Cobra", GemAmnt = 15000, PetAmount = 10},
}

local PetType = 2 -- 0 Reg, 1 Gold, 2 Rainbow
local Listings = 1 -- Amount of listings you want to have at once

local Enabled = true
local lplr = game:GetService("Players").LocalPlayer
local Http = game:GetService("HttpService")
local SaveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save)
local SaveFile = SaveModule.Get(lplr)
local PetInventory = SaveFile.Inventory.Pet
local BoothFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Booths")
local BoothListings
local Mouse = lplr:GetMouse()

for _,v in pairs(BoothFolder:GetChildren()) do
    if string.find(v.Info.BoothBottom.Frame.Top.Text,lplr.Name) then
        BoothListings = v.Pets.BoothTop.PetScroll
    end
end

local function List()
    for _, petInfo in ipairs(PetsToSell) do
        local petName = petInfo.petName
        local gemAmnt = petInfo.GemAmnt
        local petAmount = petInfo.PetAmount

        for ID, value in pairs(PetInventory) do
            if value.id == petName and value.pt == PetType and not value.sh and value._am >= petAmount then 
                game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Booths_CreateListing"):InvokeServer(ID, gemAmnt, petAmount)
            end
        end
    end
end

BoothListings.ChildRemoved:Connect(function()
    if #BoothListings:GetChildren() <= Listings + 1 and Enabled then
        wait(4)
        for i = 1, Listings - (#BoothListings:GetChildren() - 2) do
            List()
            task.wait(3)
        end
    end
end)

Mouse.KeyDown:Connect(function(Key)
    if Key == "p" then
        Enabled = not Enabled
    end
end)

while true do
    if Enabled then
        for i = 1, Listings do
            List()
            task.wait(3)
        end
    end
    wait(5) -- Add a delay between each loop iteration to avoid excessive server requests
end 

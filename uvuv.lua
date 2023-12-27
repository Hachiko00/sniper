local NiggasToAvoid = {
    "imjustyou_3"
	"imjustyou_4"
	"imjustyou_5"
	"imjustyou_6"
}

local thingsTosnipe = {
    ["Fortune"] = getgenv().Settings.Books.FortunePrice,
    ["Chest Mimic"] = getgenv().Settings.Books.ChestMimicPrice,
    ["Lucky Block"] = getgenv().Settings.Books.LuckyBlockPrice,
    ["Shiny Hunter"] = getgenv().Settings.Books.ShinyHunterPrice,
    ["Huge Hunter"] = getgenv().Settings.Books.HugeHunterPrice,
    ["Titanic Christmas Present"] = getgenv().Settings.Present.TitanicPresentPrice,
    ["X-Large Christmas Present"] = getgenv().Settings.Present.XLargeChristmasPrice
}

local keywords = {
    ["Royalty"] = getgenv().Settings.Charm.RoyaltyPrice,
    ["Exclusive"] = getgenv().Settings.Pets.EggPrice,
    ["Spinny"]= getgenv().Settings.Other.SpinnyPrice,
    ["Upper"] = getgenv().Settings.Other.UpperKey,
	["Lower"] = getgenv().Settings.Other.LowerKey,
    ["Orange"] = getgenv().Settings.Fruits.Orange,
    ["Banana"] = getgenv().Settings.Fruits.Banana,
    ["Apple"] = getgenv().Settings.Fruits.Apple,
    ["Rainbow"] = getgenv().Settings.Fruits.RainbowFruit,
    ["Pineapple"] = getgenv().Settings.Fruits.Pineapple
}

repeat wait() until game:IsLoaded()

if not game.PlaceId == 8737899170 or not game.PlaceId == 15502339080 or not game.PlaceId == 15588442388 then wait(9e9) end

print('executed')

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local function Hopped(webhook, user)
    local message = {
        ['content'] = "Server Hopped!",
        ['embeds'] = {
            {
                ['title'] = "You just hopped!",
                ["color"] = tonumber(0x32CD32),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "||"..user.. "||" .. " Hopped ",
                    }
                },
            },
        }
    }
    local http = game:GetService("HttpService")
    local jsonMessage = http:JSONEncode(message)
    http:PostAsync(webhook, jsonMessage)
end

local function serverHop(id)
    repeat
        local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s"
        local req = request({ Url = string.format(sfUrl, id, "Desc", 100) })
        local body = HttpService:JSONDecode(req.Body)
        if id == 15502339080 then
            if body.nextPageCursor ~= nil then
                req = request({ Url = string.format( sfUrl .. "&cursor=" .. body.nextPageCursor, id, "Desc", 100), })
            end
        end
        task.wait(0.1)
        local servers = {}
        if body and body.data then
            for i, v in next, body.data do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing >= math.random(30,35) and v.playing <= math.random(40,45) and v.id ~= game.JobId then
                    table.insert(servers, 1, v.id)
					Hopped(getgenv().Settings.ServerHopped, user)
                end
            end
        end

        local randomCount = #servers
        if not randomCount then
            randomCount = 2
        end

        TeleportService:TeleportToPlaceInstance(id, servers[math.random(1, randomCount)], Players.LocalPlayer)
    until game.placeId ~= 8737899170
end

wait(20)
if game.placeId ~= getgenv().Settings.place then
    pcall(serverHop, getgenv().Settings.place)
	Hopped(getgenv().Settings.ServerHopped, Hopped)
    wait(30)
end

local p = tostring(game:GetService("Players").LocalPlayer)
local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")
local Library = require(game.ReplicatedStorage:WaitForChild('Library'))

if p == "prinzemark1026" then
    game:Shutdown()
elseif p == "Aubreeunicorn1" then
    game:Shutdown()
elseif p == "katsumi" then
    game:Shutdown()
elseif p == "patrickzxc_123" then
    game:Shutdown()
end

for i, v in pairs(game:GetService("Players"):GetChildren()) do
    print(v.Name)

    for _, username in ipairs(NiggasToAvoid) do
        if v.Name == username and p ~= username then
            pcall(serverHop, getgenv().Settings.place)
			Hopped(getgenv().Settings.ServerHopped, user)
            wait(60)
        end
    end
end

wait(10)

local function formatNumber(number)
    return tostring(number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function buyItem(playerid, uid)
    local success, errorMessage = pcall(function ()
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    end)
    return success
end

local function sendUpdate(webhook, user, item, gems)
    local message = {
        ['content'] = "@everyone",
        ['embeds'] = {
            {
                ['title'] = "Sniped!",
                ["color"] = tonumber(0x32CD32),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "**"..user.." sniped: "..item.."**",
                        ['value'] = "cost: "..formatNumber(gems).."",
                    }
                },
            },
        }
    }
    local http = game:GetService("HttpService")
    local jsonMessage = http:JSONEncode(message)
    http:PostAsync(webhook, jsonMessage)
end

local function checklisting(uid, gems, item, playerid)
    gems = tonumber(gems)
    local type = {}
    pcall(function()
      type = Library.Directory.Pets[item]
    end)
    
    if type.huge and gems <= getgenv().Settings.Pets.HugePrice then
        buyItem(playerid, uid)
        if buyItem then
            sendUpdate(getgenv().Settings.webhook, p, item, gems)
        else
            print('failed to snipe')
        end
        print('Successfully Sniped ', item)
    elseif type.titanic and gems <= getgenv().Settings.Pets.TitanicPetPrice then
        buyItem(playerid, uid)
        if buyItem then
            sendUpdate(getgenv().Settings.webhook, p, item, gems)
        else
            print('failed to snipe')
        end
        print('Successfully Sniped ', item)
    elseif type.exclusiveLevel and not string.find(item, 'Coin') and not string.find(item, 'Banana') and gems <= getgenv().Settings.Pets.ExclusivePetPrice then
        buyItem(playerid, uid)
        if buyItem then
            sendUpdate(getgenv().Settings.webhook, p, item, gems)
        else
            print('failed to snipe')
        end
        print('Successfully Sniped ', item)
    end
    elseif gems <= 1 then
		buyItem(playerid, uid)
    end
    for i, v in pairs(keywords) do
        if string.find(item, i) and gems <= v then
            buyItem(playerid, uid)
            print('Successfully Sniped ', item)
        end
    end
    for i, v in pairs(thingsTosnipe) do
        if item == i and gems <= v then
            buyItem(playerid, uid)
            if buyItem then
                sendUpdate(getgenv().Settings.webhook, p, item, gems)
            else
                print('failed to snipe')
            end
            print('Successfully Sniped ', item)
        end
    end
end

local function create_platform(x, y, z)
    local p = Instance.new("Part")
    p.Anchored = true
    p.Name = "plat"
    p.Position = Vector3.new(x, y, z)
    p.Size = Vector3.new(10, 1, 10)
    p.Parent = game.Workspace
end

local function teleport(x, y, z)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Wait for the character to be available
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(x, y, z))
    end
end

create_platform(-922, 190, -2338)
local aa = game.Workspace:FindFirstChild("plat")
repeat
    wait()
until aa ~= nil
teleport(-922, 195, -2338)

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    if message ~= nil then
        if type(message) == "table" then
			local playerID = message['PlayerID']
            local listing = message["Listings"]
            for key, value in pairs(listing) do
                if type(value) == "table" then
                    local uid = key
                    local gems = value["DiamondCost"]
                    local itemdata = value["ItemData"]
                    if itemdata then
                        local data = itemdata["data"]
                        if data then
                            local item = data["id"]
                            checklisting(uid, gems, item, playerID)
                        end
                    end
                end
            end
        end
    end
end)


local niggaJump = coroutine.create(function ()
    while 1 do
        wait(5)
        game.Players.LocalPlayer.Character.Humanoid.Jump = true
    end
end)
coroutine.resume(niggaJump)

local VirtualUser=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)

game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

game:GetService('RunService'):Set3dRenderingEnabled(false)

local isServerDead = coroutine.create(function ()
    local isDead = false
    while not isDead do
        wait(10)
        local Players = game:GetService("Players"):GetPlayers()
        local count = #Players

        if count <= getgenv().Settings.num_of_players_to_tp then
            isDead = true
            pcall(serverHop, getgenv().Settings.place)
			Hopped(getgenv().Settings.ServerHopped, user)
            wait(60)
        end
    end
end)
coroutine.resume(isServerDead)

wait(1800)
pcall(serverHop, getgenv().Settings.place)
Hopped(getgenv().Settings.ServerHopped, user)

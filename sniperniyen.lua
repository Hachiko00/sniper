repeat wait() until game:IsLoaded()

game:GetService("RunService"):Set3dRenderingEnabled(false)
local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")
local message1 = {}
local Players = game:GetService('Players')
local PlayerInServer = #Players:GetPlayers()
local ostime = os.time()


if not getgenv().a then
    getgenv().a = true
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    
end

local function processListingInfo(uid, gems, item, version, shiny, amount, boughtFrom)
    print(uid, gems, item, version, shiny, amount, boughtFrom)
    print("BOUGHT FROM:", boughtFrom)
    print("UID:", uid)
    print("GEMS:", gems)
    print("ITEM:", item)

    local nicknames = {
        imjustyou_3 = 'alt1',
        imjustyou_4 = 'alt2',
        imjustyou_5 = 'alt3',
    }

    local accountName = game.Players.LocalPlayer.Name

    local nickname = nicknames[accountName] or game.Players.LocalPlayer.Name

    local snipeMessage = nickname .. " just sniped a "
    if version then
        if version == 2 then
            version = "Rainbow"
        elseif version == 1 then
            version = "Golden"
        end
    else
        version = "Normal"
    end

    snipeMessage = snipeMessage .. version

    if shiny then
        snipeMessage = snipeMessage .. " Shiny"
    end

    snipeMessage = snipeMessage .. " " .. (item)

    print(snipeMessage)

    if amount then
        print("AMOUNT:", amount)
    else
        amount = 1
        print("AMOUNT:", amount)
    end

    message1 = {
        ['content'] = "Sniper",
        ['embeds'] = {
            {
                ['title'] = snipeMessage,
                ["color"] = tonumber(0x33dd99),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "PRICE:",
                        ['value'] = tostring(gems) .. " GEMS",
                    },
                    {
                        ['name'] = "BOUGHT FROM:",
                        ['value'] = tostring(boughtFrom),
                    },
                    {
                        ['name'] = "AMOUNT:",
                        ['value'] = tostring(amount),
                    },
                    {
                        ['name'] = "PETID:",
                        ['value'] = tostring(uid),
                    },
                },
            },
        }
    }

    local http = game:GetService("HttpService")
    local jsonMessage = http:JSONEncode(message1)
    http:PostAsync(getgenv().webhook, jsonMessage)
end

local function checklisting(uid, gems, item, version, shiny, amount, username, playerid)
    local Library = require(game.ReplicatedStorage:WaitForChild('Library'))
    gems = tonumber(gems)
    local type = {}
    pcall(function()
        type = Library.Directory.Pets[item]
end)

    if type.exclusiveLevel and gems <= 10000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        processListingInfo(uid, gems, item, version, shiny, amount, username)
    elseif item == "Titanic Christmas Gift" and gems <= 10000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        processListingInfo(uid, gems, item, version, shiny, amount, username)
    elseif type.huge and gems <= 1000000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        processListingInfo(uid, gems, item, version, shiny, amount, username)     
    elseif type.titanic and gems <= 10000000 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        processListingInfo(uid, gems, item, version, shiny, amount, username)      
    elseif gems == 1 then
        game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    end
end

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    local playerID = message['PlayerID']
    if type(message) == "table" then
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
                        local version = data["pt"]
                        local shiny = data["sh"]
                        local amount = data["_am"]
                        checklisting(uid, gems, item, version, shiny, amount, username , playerID)
                    end
                end
            end
        end
    end
end)
print('executed')

local function jumpToServer() 
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true" 
    local req = request({ Url = string.format(sfUrl, 15502339080, "Desc", 100) }) 
    local body = game:GetService("HttpService"):JSONDecode(req.Body) 
    local deep = math.random(1, 3)
    if deep > 1 then 
        for i = 1, deep, 1 do 
            req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 15502339080, "Desc", 100) }) 
            body = game:GetService("HttpService"):JSONDecode(req.Body) 
            task.wait(0.1)
        end 
    end 
    local servers = {} 
    if body and body.data then 
        for i, v in next, body.data do 
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
    local randomCount = #servers
    if not randomCount then
        randomCount = 2
    end
    game:GetService("TeleportService"):TeleportToPlaceInstance(15502339080, servers[math.random(1, randomCount)], game:GetService("Players").LocalPlayer) 

    local serverId = servers[math.random(1, randomCount)]

    game:GetService("TeleportService"):TeleportToPlaceInstance(15502339080, serverId, game:GetService("Players").LocalPlayer)

    local playersInServer = #game:GetService("Players"):GetPlayers()

    -- Notify Discord about the successful server hop
    local webhookUrl = 'https://discord.com/api/webhooks/1095531015893684294/neUmv3_nRNa4XxZUCzpxQx85LpHzq_dJpMTMM8kHoV5zq-s1A-f1Vg3x_iCqkLBJgjUj'
    local message = {
        ['content'] = "Server hop successful!",
        ['embeds'] = {
            {
                ['title'] = "Server Hopped",
                ["color"] = tonumber(0x33dd99),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "Server ID:",
                        ['value'] = tostring(serverId),
                    },
                    {
                        ['name'] = "Players in Server:",
                        ['value'] = tostring(playersInServer),
                    },
                    -- You can add more fields as needed
                },
            },
        }
    }

    local http = game:GetService("HttpService")
    local jsonMessage = http:JSONEncode(message)
    http:PostAsync(webhookUrl, jsonMessage)
end

local webhookUrl = 'https://discord.com/api/webhooks/1095531015893684294/neUmv3_nRNa4XxZUCzpxQx85LpHzq_dJpMTMM8kHoV5zq-s1A-f1Vg3x_iCqkLBJgjUj'

local function countPlayersAndNotify()
    local playerCount = #game:GetService("Players"):GetPlayers()

    local message = {
        ['content'] = "Player count update",
        ['embeds'] = {
            {
                ['title'] = "Current Players in Server",
                ["color"] = tonumber(0x33dd99),
                ["timestamp"] = DateTime.now():ToIsoDate(),
                ['fields'] = {
                    {
                        ['name'] = "Player Count:",
                        ['value'] = tostring(playerCount),
                    },
                },
            },
        }
    }

    local http = game:GetService("HttpService")
    local jsonMessage = http:JSONEncode(message)
    http:PostAsync(webhookUrl, jsonMessage)
end

while wait(0.1) do
    PlayerInServer = #Players:GetPlayers()
    if PlayerInServer < 40 or os.time() >= ostime + 300 then
        jumpToServer()
    end
    for count = 0, #getgenv().alts, 1 do
        if game.Players:FindFirstChild(alts[count]) and alts[count] ~= game:GetService("Players").LocalPlayer then
            jumpToServer()
        end
    end

    -- Check player count every 5 minutes
    if os.time() % 300 == 0 then
        countPlayersAndNotify()
    end
end

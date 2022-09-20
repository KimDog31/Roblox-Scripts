local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not Lib.Loaded do
    game:GetService("RunService").Heartbeat:Wait()
end
local Players = game:GetService("Players")
local console = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lve/SynapseXConsole/main/maine.lua"))()

local function Bank(id)
    local self = {}
    function self:withdraw(pets, gems)
        Lib.Network.Invoke("bank withdraw", id, pets, gems)
    end
    function self:deposit(pets, gems)
        Lib.Network.Invoke("bank deposit", id, pets, gems)
    end
    function self:get()
        return Lib.Network.Invoke("get bank", id)
    end
    return self
end

local nextTeleport = queue_on_teleport or syn.queue_on_teleport



console.new()
console.clear()

console.windowname("4lve#0001 Perdiotic Save Fail")


console.log("Getting Banks")
local bankNames = {}
local bankData = {}
for i,v in pairs((Lib.Network.Invoke("get my banks"))) do
    local name
    pcall(function ()
        name = Players:GetNameFromUserIdAsync(v.Owner)
    end)
    if name then
        bankData[name] = v.BUID
        table.insert(bankNames, name)
    end
end

console.newline()

console.log("Banks And Bank Owners Acquired")
console.newline()

for i,v in pairs(bankNames) do
    console.newline()
    console.log('['..i..'] '..v)
end

console.newline()

function askForInput()
    console.newline()
    input = console.input('Select Bank To Deposit Gems Into: ')
    if bankData[bankNames[tonumber(input)]] then
        return bankData[bankNames[tonumber(input)]], bankNames[tonumber(input)]
    else
        console.newline()
        console.log('Invalid Input Please Enter A Number Between 1-'..#bankNames)
        return askForInput()
    end
end


local BankUID, BankOwner = askForInput()
console.newline()
console.log('Selected Bank ['..BankUID..'] With The Owner ['..BankOwner..']')
console.newline()
console.newline()

console.log('Trying To Get Periodic Save Fail')

for i = 1, 100 do
    spawn(function()
        for i = 1, 100000 do
            pcall(function()
                Bank(BankUID):withdraw({}, 2)
                Bank(BankUID):deposit({}, 2)
                print("Deposited And Withdrawed Gems")
                task.wait()
            end)
        end
    end)
    task.wait()
end
console.newline()

old = hookfunction(Lib.Message.New, function(m, ...)
    if(m == "\226\154\160\239\184\143 Periodic save failed! You will be kicked in 5 seconds to prevent data loss. Sorry!") then
        console.log('Game Got Perdiotic Save Fail')
    end
    return old(m, ...)
 end)

console.newline()

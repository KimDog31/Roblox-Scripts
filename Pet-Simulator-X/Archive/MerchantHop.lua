
if not getgenv().totalServers then
	getgenv().totalServers = 0
    getgenv().totalServersMerchant = 0
    getgenv().itemsBought = 0
end

spawn(function()
	local PlaceID = game.PlaceId
	local AllIDs = {}
	local foundAnything = ""
	local actualHour = os.date("!*t").hour
	local Deleted = false
	function TPReturner()
		local Site;
		if foundAnything == "" then
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
		else
			Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
		end
		local ID = ""
		if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
			foundAnything = Site.nextPageCursor
		end
		local num = 0;
		for i,v in pairs(Site.data) do
			local Possible = true
			ID = tostring(v.id)
			if tonumber(v.maxPlayers) > tonumber(v.playing) then
				for _,Existing in pairs(AllIDs) do
					if num ~= 0 then
						if ID == tostring(Existing) then
							Possible = false
						end
					else
						if tonumber(actualHour) ~= tonumber(Existing) then
							local delFile = pcall(function()
								delfile("NotSameServers.json")
								AllIDs = {}
								table.insert(AllIDs, actualHour)
							end)
						end
					end
					num = num + 1
				end
				if Possible == true then
					table.insert(AllIDs, ID)
					wait()
					pcall(function()
						writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
						wait()
						game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
					end)
					wait(4)
				end
			end
		end
	end
	function Teleport()
		while wait() do
			pcall(function()
				TPReturner()
				if foundAnything ~= "" then
					TPReturner()
				end
			end)
		end
	end
end)


if not game:IsLoaded() then
    game.Loaded:Wait()
end
local console = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lve/SynapseXConsole/main/maine.lua"))()
console.clear()
console.log('New Server Joined. Waiting For Script To Load')
local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not Lib.Loaded do
	game:GetService("RunService").Heartbeat:Wait()
end

nextTeleport = queue_on_teleport or syn.queue_on_teleport

function useTeleport()
    console.newline()
    console.newline()
    console.log('Teleporting To New Server')
    nextTeleport([[
		getgenv().mode = ]]..mode..[[
        getgenv().totalServers = ]]..totalServers..[[
        getgenv().totalServersMerchant = ]]..totalServersMerchant..[[
        getgenv().itemsBought = ]]..itemsBought..[[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/4lve/Roblox/main/MerchantHop.lua"))()
    ]])
    Teleport()
end


console.new()
console.windowname('Merchant Hop Created By 4lve#0001')
console.clear()

console.log("Server Info:")
console.newline()
console.formatcolors(" - Current Job ID: &a"..game.JobId)
console.newline()
console.formatcolors(" - Total Servers Joined: &a"..totalServers)
console.newline()
console.formatcolors(" - Total Servers With Merchant: &a"..totalServersMerchant)
console.newline()
console.formatcolors(" - Total Pets Bought: &a"..itemsBought)
console.newline()
console.newline()
console.log("Activity:")
console.newline()

if (Lib.Network.Invoke("get merchant items")["Level 3"]) then
    console.formatcolors(" - &aMerchant Found")
	if (getgenv().mode == 1) then
		notOutOfStock = true
		while notOutOfStock do
			notOutOfStock = Lib.Network.Invoke("buy merchant item", 3)
			if notOutOfStock then
				console.newline()
				console.formatcolors(" - &aMerchant Pet Bought")
				getgenv().itemsBought = getgenv().itemsBought + 1
			end
		end
	else

		for i,v in pairs(Lib.Network.Invoke("get merchant items")) do
			if ((v.petId == "288") and v.petExtra.r) then
				notOutOfStock = Lib.Network.Invoke("buy merchant item", tonumber(i:split(" ")[2]))
				if notOutOfStock then
					console.newline()
					console.formatcolors(" - &aBought Rainbow Santa Paws")
					getgenv().itemsBought = getgenv().itemsBought + 1
				end
			end
		end

	end
    getgenv().totalServers = getgenv().totalServers + 1
    getgenv().totalServersMerchant = getgenv().totalServersMerchant + 1
    useTeleport()
else
    console.formatcolors(" - &4Merchant Not Found")
    getgenv().totalServers = getgenv().totalServers + 1
    useTeleport()
end

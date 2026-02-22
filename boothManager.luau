local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local MessagingService = game:GetService("MessagingService")

local RemoteEvents = ReplicatedStorage["Remote Events"]

local passes = require(ServerScriptService.Passes)
local passTable = {}
local boothOwner
local boothClaimed = false
local passesLoaded = false
local passSurfaceGui
local surfaceGuiTable = {}

local BoothClaim = RemoteEvents["ClaimStand"]
local ChangeText = RemoteEvents["ChangeText"]
local unclaimEvent = RemoteEvents["Unclaim"]
local refreshEvent = RemoteEvents["Refresh"]
local donation = RemoteEvents["Donation"]

local booth = script.Parent
local prox = booth.Proximity.ProximityPrompt
local ownerText = booth.SignClaim.SignClaimUi.Claimed
local raisedText = booth.SignDescription.SurfaceGui.Frame.MoneyRaised
local passUi = ReplicatedStorage.ReplicatedUi.DonationPass

local connection

local function addPassGuis(player, passes)
	for i, passes in pairs(passes) do
		local pass = passUi:Clone()
		pass.Parent = surfaceGuiTable[player.UserId].ScrollingFrame
		pass.TextLabel.Text = passes[2]
		pass.Visible = true
		pass:SetAttribute("passName", passes[1])
		pass:SetAttribute("passPrice", passes[2])
		pass:SetAttribute("passId", passes[3])
		pass:SetAttribute("passImage", passes[4])
		task.wait()
	end	
end

local function removepassGuis(player)
	for i, pass in pairs(surfaceGuiTable[player.UserId].ScrollingFrame:GetChildren()) do
		if pass.Name == "DonationPass" then
			pass:Destroy()
		end
	end
end

local function unclaimBooth()
	passTable = {}
	boothOwner = nil
	boothClaimed = false
	passesLoaded = false
	ownerText.Text = "UNCLAIMED"
	booth.SignText["Sign Text"].TextDisplay.Text = "Crazy Donations"
	prox.Enabled = true
	raisedText.Text = "0" .. "$ Raised"
	for i , plr in pairs(Players:GetPlayers()) do
		removepassGuis(plr)
	end
	connection:Disconnect()
end

ChangeText.OnServerEvent:Connect(function(player, info)
	if info[2] == booth then
		booth.SignText["Sign Text"].TextDisplay.Text = info[1]
	end
end)

Players.PlayerAdded:Connect(function(player)

	passSurfaceGui = ReplicatedStorage.ReplicatedUi.SignButtons:Clone()
	passSurfaceGui.Parent = player.PlayerGui
	passSurfaceGui.Adornee = booth.SignButtons
	surfaceGuiTable[player.UserId] = passSurfaceGui

	if boothClaimed then
		wait(3)
		addPassGuis(player, passTable[boothOwner.UserId])
	end
end)

prox.Triggered:Connect(function(player)

	local userId = player.UserId

	local ownedBooth = player:WaitForChild("OwnedBooth")

	if not boothClaimed and ownedBooth.Value == nil then
		boothClaimed = true

		ownedBooth.Value = booth

		boothOwner = player
		ownerText.Text = "Claimed by: " .. boothOwner.Name
		prox.Enabled = false

		local Raised =player:WaitForChild("leaderstats").Raised

		raisedText.Text = Raised.Value .. "$ Raised"

		connection = Raised:GetPropertyChangedSignal("Value"):Connect(function()
			raisedText.Text = Raised.Value .. "$ Raised"
		end)

		print(connection)

		local retry = 10
		local attempt = 0

		while true do
			local passAmount
			attempt = attempt + 1
			print("fetching passes")
			passTable[userId], passAmount = passes.fetchpasses(player)
			if not (passTable[userId] or passAmount == 0) and attempt < 10 then
				task.wait(5)
			else 
				break
			end
		end

		passesLoaded = true

		print(passTable[userId])

		repeat task.wait() until passesLoaded
		for i, plr in pairs(Players:GetPlayers()) do
			addPassGuis(plr, passTable[userId])
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if player == boothOwner then
		unclaimBooth()
	end
end)

unclaimEvent.OnServerEvent:Connect(function(player)
	if player == boothOwner then
		unclaimBooth()
		player.OwnedBooth.Value = nil
	end
end)

refreshEvent.OnServerEvent:Connect(function(player)
	if player == boothOwner then
		local userId = boothOwner.UserId

		removepassGuis(boothOwner)

		passesLoaded = false

		local retry = 10
		local attempt = 0

		while true do
			local passAmount
			attempt = attempt + 1
			print("fetching passes")
			passTable[userId], passAmount = passes.fetchpasses(player)
			if not (passTable[userId] or passAmount == 0) and attempt < 10 then
				task.wait(5)
			else 
				break
			end
		end
		passesLoaded = true

		print(passTable[userId])

		repeat task.wait() until passesLoaded
		for i, plr in pairs(Players:GetPlayers()) do
			addPassGuis(plr, passTable[userId])
		end
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if purchased and boothOwner then
		local userId = boothOwner.UserId
		if passTable[userId] then
			print("pass purchased")
			for i , passes in pairs(passTable[userId]) do
				print(passes[3], passId)
				if passes[3] == passId then
					print(passes[2])
					boothOwner:WaitForChild("leaderstats").Raised.Value += passes[2]
					player:WaitForChild("leaderstats").Donated.Value += passes[2]
					player:WaitForChild("Snowflakes").Value += math.ceil(passes[2] / 2)
					MessagingService:PublishAsync("Donation", {donatedName = player.UserId, raisedName = boothOwner.UserId, donationAmount = passes[2]})
					break
				end
			end
		end
	end
end)

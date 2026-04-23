--Completed 03/21/2026
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local DataSaveService = require(ReplicatedStorage.Services.DataSaveService)

local MainDataStore = DataStoreService:GetDataStore("MainDataStore")
local DonatedOrderedDataStore = DataStoreService:GetOrderedDataStore("DonatedOrderedDataStore")
local RaisedOrderedDataStore = DataStoreService:GetOrderedDataStore("RaisedOrderedDataStore")

local statsTable = {}

Players.PlayerAdded:Connect(function(plr)
	local data = DataSaveService.loadData(plr, MainDataStore)

	local donated = 0
	local raised = 0
	local donationbux = 0

	if data then	
		donated = data.Donated or 0
		raised = data.Raised or 0
		donationbux = data.Donationbux or 0
	end

	local donatedLeaderstats = DataSaveService.addLeaderstats(plr, "Donated")
	local raisedLeaderstats = DataSaveService.addLeaderstats(plr, "Raised")
	local donationbuxstats = DataSaveService.addVariable(plr, "Donationbux")

	donatedLeaderstats.Value = donated
	raisedLeaderstats.Value = raised
	donationbuxstats.Value = donationbux

	statsTable[plr] = {
		donated = donatedLeaderstats,
		raised = raisedLeaderstats,
		donationbux = donationbuxstats
	}
end)

local function savePlayer(plr)
	if not statsTable[plr] then return end

	local donatedAmount = statsTable[plr].donated.Value
	local raisedAmount = statsTable[plr].raised.Value
	local donationbuxAmount = statsTable[plr].donationbux.Value

	DataSaveService.saveData(plr, MainDataStore, {
		Donated = donatedAmount,
		Raised = raisedAmount,
		Donationbux = donationbuxAmount
	})

	DataSaveService.saveData(plr, DonatedOrderedDataStore, donatedAmount)
	DataSaveService.saveData(plr, RaisedOrderedDataStore, raisedAmount)
end

Players.PlayerRemoving:Connect(function(plr)
	savePlayer(plr)
	statsTable[plr] = nil
end)

game:BindToClose(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		savePlayer(plr)
	end
	task.wait(5)
end)

local module = {
	stats = statsTable,
}

return module

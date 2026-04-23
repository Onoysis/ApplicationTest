-- Completed / Last Update 3/22/2026
local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

local RemoteFolder = ReplicatedStorage:WaitForChild("RemoteFunctions") 
local getTagsRemote = RemoteFolder:WaitForChild("GetTags")

local groupId = game.CreatorId
local tagMainTemplate = ReplicatedStorage.ReplicatedInstances.ReplicatedUis.TagsGui
local playerTags = {}

getTagsRemote.OnServerInvoke = function()
	return playerTags
end

module.updatePlayerTag = function(player)
	local DataSaveService = require(ReplicatedStorage.Services.DataSaveService)
	local DonatedOrderedDataStore = DataStoreService:GetOrderedDataStore("DonatedOrderedDataStore")
	local RaisedOrderedDataStore = DataStoreService:GetOrderedDataStore("RaisedOrderedDataStore")

	local userId = player.UserId
	local character = player.Character or player.CharacterAdded:Wait()

	character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	local tagMain = tagMainTemplate:Clone()
	tagMain.Main.Username.Text = player.DisplayName
	tagMain.Parent = character.Head

	local tagsOwned = {
		visibility = {
			specialRank = false,
			vip = false,
			topRaised = false,
			robuxDonated = false,
			member = false,
		},
		values = {
			specialRank = "",
			topRaised = 0,
			robuxDonated = 0,
		},
	}

	local rank = player:GetRankInGroup(groupId)
	if rank > 1 then
		tagsOwned.values.specialRank = player:GetRoleInGroup(groupId)
		tagsOwned.visibility.specialRank = true
	end

	if rank >= 1 then	
		tagsOwned.visibility.member = true		
	end

	local donatedRank = DataSaveService.getPlayerRankInDatastore(DonatedOrderedDataStore, player, 50)
	if donatedRank then
		tagsOwned.values.robuxDonated = donatedRank
		tagsOwned.visibility.robuxDonated = true
	end

	local raisedRank = DataSaveService.getPlayerRankInDatastore(RaisedOrderedDataStore, player, 50)
	if raisedRank then
		tagsOwned.values.topRaised = raisedRank
		tagsOwned.visibility.topRaised = true
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, 1759948216)
	end)

	if success and result then
		tagsOwned.visibility.vip = true
	end

	local tagsFrame = tagMain.Main.Tags
	tagsFrame.DonatedRank.Visible = tagsOwned.visibility.robuxDonated
	tagsFrame.RaisedRank.Visible = tagsOwned.visibility.topRaised
	tagsFrame.VIPRank.Visible = tagsOwned.visibility.vip
	tagsFrame.MemberRank.Visible = tagsOwned.visibility.member
	tagsFrame.SpecialRank.Visible = tagsOwned.visibility.specialRank

	tagsFrame.DonatedRank.RankText.Text = "#" .. tagsOwned.values.robuxDonated
	tagsFrame.RaisedRank.RankText.Text = "#" .. tagsOwned.values.topRaised
	tagsFrame.SpecialRank.RankText.Text = tagsOwned.values.specialRank

	playerTags[tostring(player.UserId)] = tagsOwned
end

module.tagTable = playerTags

return module

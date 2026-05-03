local module = {}
local Get = shared.Get
local ModelHandler = Get("ModelHandler")

local WeldHandler = Get("WeldHandler")
local DataHandler = Get("DataHandler")
local FunctionLib = Get("FunctionLib")

local TitelHandler = Get("TitleHandler")

function module.Create(Brainrot,level,modifier)
	local Tool = Instance.new("Tool")
	Tool.CanBeDropped = false
	local LevelText = ""
	local ModifierText = ""
	
	if level then
		LevelText = `[lv. {level}] `
	end
	
	if modifier then
		--ModifierText = `[{modifier}] `
	end
	
	Tool.Name = `{ModifierText}{LevelText}{Brainrot}`
	
	local Model : Model = ModelHandler.GetModel(Brainrot,modifier)
	WeldHandler:FullModel(Model)
	
	Tool:SetAttribute("__Brainrot",true)
	for i,v in Model:GetChildren() do
		if v:IsA("BasePart") then
			v.Anchored = false
			v.CanCollide = false
			v.Massless = true
			v.CastShadow = false
		end
		if Model.PrimaryPart == v then
			v.Name = "Handle"
		else
			v.Name = "_Model"
		end
		v.Parent = Tool
	end
	Tool.Grip = CFrame.new(0,-2,.5)
	--[[
	local Higlight = Instance.new("Highlight",Tool)
	Higlight.FillTransparency = 1
	Higlight.OutlineColor = Color3.fromRGB(255,255,255)
	Higlight.OutlineTransparency = 0
	Higlight.DepthMode = Enum.HighlightDepthMode.Occluded
	
	
	]]
	
	
	

	
	TitelHandler.Create(Tool.Handle,{
		Title = Brainrot,
		
		Passive = 299,
		Modifiers = {modifier},
		Upgrade = level
	})
	return Tool
end

function module.Add(plr,Data,Equip)
	local PlayerData = DataHandler.GetPlayerData(plr)
	
	local Id = game.HttpService:GenerateGUID(false)
	
	PlayerData.Inventory[Id] = Data
	if Equip then
		plr:SetAttribute("_SetInv",Id)
	end
end

function module.Update(plr : Player)
	if not plr.Character then
		return
	end
	local PlayerData = DataHandler.GetPlayerData(plr)
	
	local Tools = {}
	
	for i,v in (plr.Backpack) and plr.Backpack:GetChildren() or {} do
		if v:GetAttribute("__Brainrot") then
			table.insert(Tools,v)
		end
	end
	
	for i,v in plr.Character:GetChildren() do
		if v:IsA("Tool") and v:GetAttribute("__Brainrot") then
			table.insert(Tools,v)
		end
	end
	
	local Found = {}
	
	for Id,Tool in Tools do
		if PlayerData.Inventory[Tool:GetAttribute("_Unique")] then
			Found[Tool:GetAttribute("_Unique")] = true
		else
			Tool:Destroy()
		end
	end
	
	for i,v in PlayerData.Inventory do
		if Found[i] == true then
			continue
		end
		Found[i] = true
		local Modifier = v.Modifiers or {}
		Modifier = Modifier[1] or nil
		
		local Tool = module.Create(v.Id,v.Upgrade,Modifier)
		Tool:SetAttribute("_Unique",i)
		Tool.Parent = plr.Backpack
		
		if plr:GetAttribute("_SetInv") == i then
			plr.Character:WaitForChild("Humanoid"):UnequipTools()
			Tool.Parent = plr.Character or plr.Backpack
			plr:SetAttribute("_SetInv",nil)
		end
	end
end

function module.NotFull(plr)
	local PlayerData = DataHandler.GetPlayerData(plr)
	local Total = 0
	for i,v in PlayerData.Inventory do
		Total += 1
	end

	local MaxCarry = 199 --

	if Total >= MaxCarry then
		FunctionLib.Alert(plr,"Your inventory is full!",Color3.fromRGB(255, 0, 0),"Error")
		return true
	else
		return true
	end
end
function module.Init()
	task.delay(2,function()
		--local Tool = module.Create("Strawberry Elephant",24,"Gold")
		--Tool.Parent = game.Players.Artennix.Backpack
	end)
end
return module

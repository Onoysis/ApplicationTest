local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local SoundService = game:GetService("SoundService")
local lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local DonationSound = SoundService:WaitForChild("DonationSound")

local donationEvent = ReplicatedStorage["Remote Events"]:WaitForChild("Donation")
local uiFolder = ReplicatedStorage:WaitForChild("ReplicatedUi")

local normalDonation = uiFolder:WaitForChild("NormalDonation")
local donation100 = uiFolder:WaitForChild("100Donation")
local donation1K = uiFolder:WaitForChild("1KDonation")
local donation10K = uiFolder:WaitForChild("10KDonation")

local effectPlaying

local function formatNumber(n)
	return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function playDonationEffect(template, lifetime, animTimes, raisedName, donatedName, amount)
	
	local donationPart = workspace["Map(WORKSPACE)"].DonationPart

	local mainPart = template:Clone()
	mainPart.Parent = workspace

	mainPart.CFrame = donationPart.CFrame + Vector3.new(0, 10, 0)

	local gui = mainPart:WaitForChild("BillboardGuiAnimation")
	local frame = gui:WaitForChild("Frame")
	local scale = frame:WaitForChild("UIScale")
	local textLabels = frame:WaitForChild("TextLabels")
	local donatedText = textLabels:WaitForChild("TopText")
	local raisedText = textLabels:WaitForChild("BottomText")
	local amountText = textLabels:WaitForChild("MiddleText")
	local light = mainPart:FindFirstChild("PointLight")
	local lightPopTween
	local lightShrinkTween
	
	donatedText.Text = donatedName ..  " Donated"
	raisedText.Text = "To " .. raisedName
	amountText.Text =  formatNumber(amount)

	scale.Scale = 0
	frame.Position += UDim2.fromOffset(0, 25)

	local popTween = TweenService:Create(
		scale,
		TweenInfo.new(animTimes, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = 1}
	)

	local floatTween = TweenService:Create(
		frame,
		TweenInfo.new(lifetime, Enum.EasingStyle.Linear),
		{Position = frame.Position - UDim2.fromOffset(0, 60 + lifetime*2)}
	)

	local shrinkTween = TweenService:Create(
		scale,
		TweenInfo.new(animTimes, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Scale = 0}
	)
	
	if light then
		lightPopTween = TweenService:Create(
			light,
			TweenInfo.new(animTimes, Enum.EasingStyle.Linear),
			{Brightness = 30, Range = 50}
		)
		
		lightShrinkTween = TweenService:Create(
			light,
			TweenInfo.new(animTimes, Enum.EasingStyle.Linear),
			{Brightness = 0, Range = 0}
		)
	end

	popTween:Play()
	if lightPopTween then lightPopTween:Play() end
	floatTween:Play()

	task.delay(lifetime, function()
		shrinkTween:Play()
		if lightShrinkTween then lightShrinkTween:Play() end
	end)

	shrinkTween.Completed:Connect(function()
		mainPart:Destroy()
	end)
end

donationEvent.OnClientEvent:Connect(function(data)
	local amount = data.donationAmount
	local donated = data.donatedName
	local raised = data.raisedName
	
	print(amount, donated, raised)
	
	if typeof(donated) == "number" then
		if donated < 0 then
			donated = 4051161141
		end
		donated = Players:GetNameFromUserIdAsync(donated)
	end
	
	if typeof(raised) == "number" then
		if raised < 0 then
			raised = 7372818375
		end
		raised = Players:GetNameFromUserIdAsync(raised)
	end

	Channel:DisplaySystemMessage(
		"<font color='#00FF00'>" ..
			donated .. " donated " .. amount .. " robux to " .. raised .. "!" ..
			"</font>"
	)
	
	if raised == Player.Name then
		local donationInfo = Player.PlayerGui.DonationInfo.Main
		donationInfo.Visible = true
		donationInfo["1Order"].Donated.Text = donated .. " Donated"
		donationInfo.Robux.Text = amount .. " To You"
		task.delay(5, function()
			donationInfo.Visible = false
		end)
	end
	
	if Player:WaitForChild("DonationEffects").Value then
		if amount < 100 then
			repeat task.wait() until not effectPlaying
			local Sound = DonationSound:Clone()
			Sound.Parent = SoundService
			Sound.PlaybackSpeed = 2
			Sound.Volume = 0.2
			Sound.Playing = true
			playDonationEffect(normalDonation, 5, 0.5, raised, donated, amount)
			task.wait(5)
			Sound:Destroy()
			
		elseif amount < 1000 then
			repeat task.wait() until not effectPlaying
			effectPlaying = true
			local Sound = DonationSound:Clone()
			Sound.Parent = SoundService
			Sound.PlaybackSpeed = 1.5
			Sound.Volume = 0.5
			Sound.Playing = true
			lighting.Brightness = 1
			playDonationEffect(donation100, 10, 0.5, raised, donated, amount)
			task.wait(11)
			lighting.Brightness = 3
			Sound:Destroy()
			effectPlaying = false

		elseif amount < 10000 then
			repeat task.wait() until not effectPlaying
			effectPlaying = true
			local Sound = DonationSound:Clone()
			Sound.Parent = SoundService
			Sound.PlaybackSpeed = 1.2
			Sound.Volume = 0.7
			Sound.Playing = true
			lighting.ClockTime = 22
			lighting.Brightness = 2
			playDonationEffect(donation1K, 30, 1, raised, donated, amount)
			task.wait(32)
			lighting.ClockTime = 14.5
			lighting.Brightness = 3
			DonationSound.Playing = false
			Sound:Destroy()
			effectPlaying = false
		else
			repeat task.wait() until not effectPlaying
			effectPlaying = true
			local Sound = DonationSound:Clone()
			Sound.Parent = SoundService
			Sound.PlaybackSpeed = 0.7
			Sound.Volume = 1
			Sound.Playing = true
			lighting.ClockTime = 22
			lighting.Brightness = 0
			lighting.ColorCorrection.Brightness = -0.5
			playDonationEffect(donation10K, 60, 2, raised, donated, amount)
			task.wait(64)
			lighting.ClockTime = 14.5
			lighting.Brightness = 3
			lighting.ColorCorrection.Brightness = 0
			Sound:Destroy()
			effectPlaying = false
		end
	end
end)

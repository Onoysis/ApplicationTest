<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="Content-Style-Type" content="text/css">
  <title></title>
  <meta name="Generator" content="Cocoa HTML Writer">
  <meta name="CocoaVersion" content="2685.3">
  <style type="text/css">
    p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; -webkit-text-stroke: #000000}
    p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; -webkit-text-stroke: #000000; min-height: 14.0px}
    span.s1 {font-kerning: none}
    span.Apple-tab-span {white-space:pre}
  </style>
</head>
<body>
<p class="p1"><span class="s1">local ReplicatedStorage = game:GetService("ReplicatedStorage")</span></p>
<p class="p1"><span class="s1">local RunService = game:GetService("RunService")</span></p>
<p class="p1"><span class="s1">local HttpService = game:GetService("HttpService")</span></p>
<p class="p1"><span class="s1">local Players = game:GetService("Players")</span></p>
<p class="p1"><span class="s1">local ServerScriptService = game:GetService("ServerScriptService")</span></p>
<p class="p1"><span class="s1">local MarketplaceService = game:GetService("MarketplaceService")</span></p>
<p class="p1"><span class="s1">local MessagingService = game:GetService("MessagingService")</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local RemoteEvents = ReplicatedStorage["Remote Events"]</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local passes = require(ServerScriptService.Passes)</span></p>
<p class="p1"><span class="s1">local passTable = {}</span></p>
<p class="p1"><span class="s1">local boothOwner</span></p>
<p class="p1"><span class="s1">local boothClaimed = false</span></p>
<p class="p1"><span class="s1">local passesLoaded = false</span></p>
<p class="p1"><span class="s1">local passSurfaceGui</span></p>
<p class="p1"><span class="s1">local surfaceGuiTable = {}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local BoothClaim = RemoteEvents["ClaimStand"]</span></p>
<p class="p1"><span class="s1">local ChangeText = RemoteEvents["ChangeText"]</span></p>
<p class="p1"><span class="s1">local unclaimEvent = RemoteEvents["Unclaim"]</span></p>
<p class="p1"><span class="s1">local refreshEvent = RemoteEvents["Refresh"]</span></p>
<p class="p1"><span class="s1">local donation = RemoteEvents["Donation"]</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local booth = script.Parent</span></p>
<p class="p1"><span class="s1">local prox = booth.Proximity.ProximityPrompt</span></p>
<p class="p1"><span class="s1">local ownerText = booth.SignClaim.SignClaimUi.Claimed</span></p>
<p class="p1"><span class="s1">local raisedText = booth.SignDescription.SurfaceGui.Frame.MoneyRaised</span></p>
<p class="p1"><span class="s1">local passUi = ReplicatedStorage.ReplicatedUi.DonationPass</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local connection</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local function addPassGuis(player, passes)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>for i, passes in pairs(passes) do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local pass = passUi:Clone()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass.Parent = surfaceGuiTable[player.UserId].ScrollingFrame</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass.TextLabel.Text = passes[2]</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass.Visible = true</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass:SetAttribute("passName", passes[1])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass:SetAttribute("passPrice", passes[2])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass:SetAttribute("passId", passes[3])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass:SetAttribute("passImage", passes[4])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>task.wait()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end<span class="Apple-tab-span">	</span></span></p>
<p class="p1"><span class="s1">end</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local function removepassGuis(player)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>for i, pass in pairs(surfaceGuiTable[player.UserId].ScrollingFrame:GetChildren()) do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>if pass.Name == "DonationPass" then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>pass:Destroy()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">local function unclaimBooth()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>passTable = {}</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>boothOwner = nil</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>boothClaimed = false</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>passesLoaded = false</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>ownerText.Text = "UNCLAIMED"</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>booth.SignText["Sign Text"].TextDisplay.Text = "Crazy Donations"</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>prox.Enabled = true</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>raisedText.Text = "0" .. "$ Raised"</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>for i , plr in pairs(Players:GetPlayers()) do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>removepassGuis(plr)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>connection:Disconnect()</span></p>
<p class="p1"><span class="s1">end</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">ChangeText.OnServerEvent:Connect(function(player, info)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if info[2] == booth then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>booth.SignText["Sign Text"].TextDisplay.Text = info[1]</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">Players.PlayerAdded:Connect(function(player)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>passSurfaceGui = ReplicatedStorage.ReplicatedUi.SignButtons:Clone()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>passSurfaceGui.Parent = player.PlayerGui</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>passSurfaceGui.Adornee = booth.SignButtons</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>surfaceGuiTable[player.UserId] = passSurfaceGui</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if boothClaimed then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>wait(3)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>addPassGuis(player, passTable[boothOwner.UserId])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">prox.Triggered:Connect(function(player)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>local userId = player.UserId</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>local ownedBooth = player:WaitForChild("OwnedBooth")</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if not boothClaimed and ownedBooth.Value == nil then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>boothClaimed = true</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>ownedBooth.Value = booth</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>boothOwner = player</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>ownerText.Text = "Claimed by: " .. boothOwner.Name</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>prox.Enabled = false</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local Raised =player:WaitForChild("leaderstats").Raised</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>raisedText.Text = Raised.Value .. "$ Raised"</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>connection = Raised:GetPropertyChangedSignal("Value"):Connect(function()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>raisedText.Text = Raised.Value .. "$ Raised"</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print(connection)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local retry = 10</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local attempt = 0</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>while true do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local passAmount</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>attempt = attempt + 1</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print("fetching passes")</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>passTable[userId], passAmount = passes.fetchpasses(player)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>if not (passTable[userId] or passAmount == 0) and attempt &lt; 10 then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>task.wait(5)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>else<span class="Apple-converted-space"> </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>break</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>passesLoaded = true</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print(passTable[userId])</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>repeat task.wait() until passesLoaded</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>for i, plr in pairs(Players:GetPlayers()) do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>addPassGuis(plr, passTable[userId])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">Players.PlayerRemoving:Connect(function(player)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if player == boothOwner then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>unclaimBooth()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">unclaimEvent.OnServerEvent:Connect(function(player)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if player == boothOwner then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>unclaimBooth()</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>player.OwnedBooth.Value = nil</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">refreshEvent.OnServerEvent:Connect(function(player)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if player == boothOwner then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local userId = boothOwner.UserId</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>removepassGuis(boothOwner)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>passesLoaded = false</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local retry = 10</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local attempt = 0</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>while true do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local passAmount</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>attempt = attempt + 1</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print("fetching passes")</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>passTable[userId], passAmount = passes.fetchpasses(player)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>if not (passTable[userId] or passAmount == 0) and attempt &lt; 10 then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>task.wait(5)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>else<span class="Apple-converted-space"> </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>break</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>passesLoaded = true</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print(passTable[userId])</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>repeat task.wait() until passesLoaded</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>for i, plr in pairs(Players:GetPlayers()) do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>addPassGuis(plr, passTable[userId])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>if purchased and boothOwner then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>local userId = boothOwner.UserId</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>if passTable[userId] then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print("pass purchased")</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>for i , passes in pairs(passTable[userId]) do</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print(passes[3], passId)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>if passes[3] == passId then</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>print(passes[2])</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>boothOwner:WaitForChild("leaderstats").Raised.Value += passes[2]</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>player:WaitForChild("leaderstats").Donated.Value += passes[2]</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>player:WaitForChild("Snowflakes").Value += math.ceil(passes[2] / 2)</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>MessagingService:PublishAsync("Donation", {donatedName = player.UserId, raisedName = boothOwner.UserId, donationAmount = passes[2]})</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>break</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1"><span class="Apple-tab-span">	</span>end</span></p>
<p class="p1"><span class="s1">end)</span></p>
</body>
</html>

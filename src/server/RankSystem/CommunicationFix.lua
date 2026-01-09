-- ServerScriptService > Misc > CommunicationFix

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ownerUserId = 9053456438 -- Your user ID

-- Use existing Events structure
local Events = ReplicatedStorage:WaitForChild("Events")
local UpdateDoorEvent = Events:WaitForChild("UpdateDoor")
local GetPlayerRankEvent = Events:WaitForChild("GetPlayerRank")
local RankChangedEvent = Events:WaitForChild("RankChanged")

-- Function to determine player access using global functions
local function getPlayerAccess(player)
	local access = {
		rank = "Guest",
		hasVIP = false,
		hasDJ = false,
		hasAll = false
	}

	-- Try to get access from global functions
	if _G.GetPlayerDoorAccess then
		local doorAccess = _G.GetPlayerDoorAccess(player)
		if doorAccess then
			access = {
				rank = doorAccess.rank or "Guest",
				hasVIP = doorAccess.hasVIP or false,
				hasDJ = doorAccess.hasDJ or false,
				hasAll = doorAccess.hasAll or false
			}
		end
	elseif _G.GetPlayerRank then
		local rank = _G.GetPlayerRank(player)
		access.rank = rank or "Guest"

		-- Set access based on rank
		if rank == "Owner" then
            access.hasVIP, access.hasDJ, access.hasAll = true, true, true
        elseif rank == "Staff" then
            access.hasVIP, access.hasDJ, access.hasAll = true, true, true
        elseif rank == "Sultan" then
            access.hasVIP, access.hasDJ, access.hasAll = true, true, true
        elseif rank == "TopSpender" then
            access.hasVIP, access.hasDJ, access.hasAll = true, true, true
		elseif rank == "DJ" then
			access.hasVIP, access.hasDJ, access.hasAll = true, true, true
		elseif rank == "Influencer" then
			access.hasVIP, access.hasDJ, access.hasAll = true, true, true  -- FIXED: Influencer has all access
		elseif rank == "VVIP" then
			access.hasDJ = false
		elseif rank == "VIP" then
			access.hasVIP = true
		elseif rank == "Gueststar" then
			access.hasVIP, access.hasDJ, access.hasAll = true, true, true  -- Gueststar has DJ access
		end
	else
		-- Fallback: check if player is owner
		if player.UserId == ownerUserId then
			access = {
				rank = "Owner",
				hasVIP = true,
				hasDJ = true,
				hasAll = true
			}
		end
	end

	return access
end

-- Function to send update to player
local function sendForceUpdate(player)
	if not player or not player.Parent then
		return false
	end

	local access = getPlayerAccess(player)

	-- Send via UpdateDoor event
	local success = pcall(function()
		UpdateDoorEvent:FireClient(player, access)
	end)

	if success then
		
	else
		warn("? UPDATE failed for " .. player.Name)
	end

	return success
end

-- Handle GetPlayerRank requests
GetPlayerRankEvent.OnServerEvent:Connect(function(player)
	
	local access = getPlayerAccess(player)
	-- Fire back rank data
	GetPlayerRankEvent:FireClient(player, access.rank)
	-- Also send door update
	sendForceUpdate(player)
end)

-- Auto-send updates when players join
Players.PlayerAdded:Connect(function(player)


	-- Send immediate update after delay
	task.spawn(function()
		task.wait(3) -- Wait for other systems to initialize
		
		sendForceUpdate(player)
	end)

	player.CharacterAdded:Connect(function()

		-- Send updates with multiple attempts
		task.spawn(function()
			for i = 1, 5 do -- Try 5 times
				task.wait(i * 1) -- 1s, 2s, 3s, 4s, 5s

			

				if sendForceUpdate(player) then
					
					if i >= 2 then break end -- Stop after 2 successful attempts
				end
			end
		end)
	end)
end)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
	
	task.spawn(function()
		task.wait(2)
		for i = 1, 3 do
			task.wait(1)
			if sendForceUpdate(player) then
				
				break
			end
		end
	end)
end

-- Periodic updates (every 30 seconds)
task.spawn(function()
	while true do
		task.wait(30)
		

		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				task.spawn(function()
					sendForceUpdate(player)
				end)
				task.wait(0.2) -- Small delay between players
			end
		end
	end
end)

-- Enhanced admin commands
local function onPlayerChatted(player, message)
	if player.UserId == ownerUserId then
		local cmd = message:lower()

		if cmd == "/forceupdate" or cmd == "/sendupdate" then
			
			sendForceUpdate(player)

		elseif cmd == "/updateall" then
			
			for _, p in pairs(Players:GetPlayers()) do
				if p.Character then
					sendForceUpdate(p)
					task.wait(0.1)
				end
			end

		elseif cmd == "/testcomm" then
			

			-- Test access calculation
			local access = getPlayerAccess(player)
			

			-- Test UpdateDoor event
			local testSuccess = pcall(function()
				UpdateDoorEvent:FireClient(player, {
					rank = "TEST",
					hasVIP = true,
					hasDJ = true,
					hasAll = true
				})
			end)
			

		elseif cmd == "/spamupdate" then
			
			for i = 1, 5 do
				sendForceUpdate(player)
				task.wait(0.5)
			end
		end
	end
end

-- Connect chat events
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		onPlayerChatted(player, message)
	end)
end)

for _, player in pairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(message)
		onPlayerChatted(player, message)
	end)
end

-- Connect to rank changes from main system
task.spawn(function()
	-- Wait for main system to be available
	local attempts = 0
	while not _G.GetPlayerRank and attempts < 50 do
		task.wait(1)
		attempts = attempts + 1
	end

	if _G.GetPlayerRank then
		

		-- Monitor for rank changes and update doors accordingly
		task.spawn(function()
			while true do
				task.wait(60) -- Check every minute
				for _, player in pairs(Players:GetPlayers()) do
					if player.Character then
						task.spawn(function()
							sendForceUpdate(player)
						end)
					end
				end
			end
		end)
	else
		warn("?? Main PlayerRanks system not found after 50 seconds")
	end
end)
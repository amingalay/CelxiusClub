-- ServerScriptService > Misc > RankChangeHandler

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for Events
local Events = ReplicatedStorage:WaitForChild("Events")
local RankChangedEvent = Events:WaitForChild("RankChanged")


-- Function to force update player team immediately
local function forceUpdatePlayerTeam(player, newRank)
	if not player or not player.Parent then
		return false
	end

	

	-- Find target team
	local targetTeam = Teams:FindFirstChild(newRank)
	if not targetTeam then
		warn("? Team not found: " .. newRank)
		return false
	end

	-- Force assign to team
	player.Team = targetTeam
	

	-- Also update nametag if global function exists
	if _G.UpdatePlayerNametag then
		task.spawn(function()
			task.wait(0.5)
			_G.UpdatePlayerNametag(player)
		end)
	end

	return true
end

-- Listen for rank changes from main system
local function connectToRankChanges()
	-- Method 1: Listen to RankChanged event
	RankChangedEvent.OnServerEvent:Connect(function(player, newRank)
		
		task.spawn(function()
			task.wait(0.2) -- Small delay
			forceUpdatePlayerTeam(player, newRank)
		end)
	end)
end

-- Function to monitor /setrank commands and auto-update teams
local function monitorSetRankCommands()
	-- Hook into player chat to detect /setrank usage
	local function onPlayerChatted(player, message)
		-- Only monitor owner's commands
		if player.UserId ~= 9053456438 then return end

		if message:sub(1, 1) == "/" then
			local args = message:split(" ")
			local command = args[1]:lower()

			if command == "/setrank" and #args >= 3 then
				local targetName = args[2]
				local rankName = args[3]


				-- Find target player
				local targetPlayer = nil
				for _, p in pairs(Players:GetPlayers()) do
					if p.Name:lower():find(targetName:lower()) or p.DisplayName:lower():find(targetName:lower()) then
						targetPlayer = p
						break
					end
				end

				if targetPlayer then
					-- Validate rank exists
                    local validRanks = {"Owner", "Staff", "Sultan", "TopSpender", "DJ", "Influencer", "VVIP", "VIP", "Gueststar", "Guest"}
					local actualRank = nil

					for _, rank in pairs(validRanks) do
						if rank:lower() == rankName:lower() then
							actualRank = rank
							break
						end
					end

					if actualRank then
					

						-- Force update team after a delay (let main system process first)
						task.spawn(function()
							task.wait(2) -- Wait for main system
							forceUpdatePlayerTeam(targetPlayer, actualRank)
						end)
					end
				end
			end
		end
	end

	-- Connect to all players
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
end

-- Admin commands for testing
local function handleAdminCommands(player, message)
	if player.UserId ~= 8899222872 then return end

	local cmd = message:lower()

	if cmd == "/forceteamupdate" then
		
		for _, p in pairs(Players:GetPlayers()) do
			if _G.GetPlayerRank then
				local rank = _G.GetPlayerRank(p)
				if rank then
					forceUpdatePlayerTeam(p, rank)
					task.wait(0.1)
				end
			end
		end

	elseif cmd:sub(1, 12) == "/forceteam " then
		local args = cmd:split(" ")
		if #args >= 3 then
			local targetName = args[2]
			local rankName = args[3]

			local targetPlayer = nil
			for _, p in pairs(Players:GetPlayers()) do
				if p.Name:lower():find(targetName:lower()) then
					targetPlayer = p
					break
				end
			end

			if targetPlayer then
				forceUpdatePlayerTeam(targetPlayer, rankName)
			end
		end
	end
end

-- Connect admin commands
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		handleAdminCommands(player, message)
	end)
end)

for _, player in pairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(message)
		handleAdminCommands(player, message)
	end)
end

-- Initialize
task.spawn(function()
	-- Wait for other systems
	task.wait(2)

	connectToRankChanges()
	monitorSetRankCommands()
end)

-- Global function for manual team updates
_G.ForceUpdatePlayerTeam = forceUpdatePlayerTeam
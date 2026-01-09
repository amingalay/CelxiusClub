-- ServerScriptService > Misc > TeamManager
-- UNIFIED TEAM MANAGEMENT SYSTEM - Replaces team creation in other scripts

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- Wait for Events
local Events = ReplicatedStorage:WaitForChild("Events")
local RankChangedEvent = Events:WaitForChild("RankChanged")

-- Team configurations with colors matching NameTag colors
local TEAM_CONFIGS = {
	["Owner"] = {
        color = Color3.fromRGB(77, 255, 0), 
		order = 1,
        nametagColor = Color3.fromRGB(77, 255, 0)
	},
	["Staff"] = {
        color = Color3.fromRGB(85, 255, 255), 
		order = 2,
        nametagColor = Color3.fromRGB(85, 255, 255)
	},
    ["Sultan"] = {
        color = Color3.fromRGB(0, 0, 255), 
        order = 3,
        nametagColor = Color3.fromRGB(0, 0, 255)
    },
	["TopSpender"] = {
        color = Color3.fromRGB(255, 215, 0), 
		order = 4,
        nametagColor = Color3.fromRGB(255, 215, 0)
    },
    ["DJ"] = {
        color = Color3.fromRGB(0, 132, 255), 
        order = 5,
        nametagColor = Color3.fromRGB(0, 132, 255)
    },
	["Influencer"] = {
        color = Color3.fromRGB(255, 142, 3), 
		order = 6,
		nametagColor = Color3.fromRGB(255, 0, 0)
	},
	["VVIP"] = {
        color = Color3.fromRGB(226, 1, 207), 
		order = 7,
        nametagColor = Color3.fromRGB(226, 1, 207)
	},
	["VIP"] = {
        color = Color3.fromRGB(255, 255, 0), 
		order = 8,
        nametagColor = Color3.fromRGB(255, 170, 0)
	},
	["Gueststar"] = {
        color = Color3.fromRGB(138, 43, 226), 
		order = 9,
		nametagColor = Color3.fromRGB(138, 43, 226)
	},
	["Guest"] = {
		color = Color3.fromRGB(169, 169, 169), 
		order = 10,
		nametagColor = Color3.fromRGB(169, 169, 169)
	}
}

-- Team creation queue to prevent conflicts
local teamCreationQueue = {}
local isCreatingTeams = false

local function log(message)
end

-- Function to safely create a single team
local function createSingleTeam(teamName, config)
	-- Remove existing team first
	local existingTeam = Teams:FindFirstChild(teamName)
	if existingTeam then
		existingTeam:Destroy()
		task.wait(0.1)
	end

	-- Create new team
	local newTeam = Instance.new("Team")
	newTeam.Name = teamName
	newTeam.TeamColor = BrickColor.new(config.color)
	newTeam.AutoAssignable = (teamName == "Guest")
	newTeam.Parent = Teams

	log("? Created team: " .. teamName .. " (Order: " .. config.order .. ")")
	return newTeam
end

-- Function to create all teams in proper order
local function createAllTeams()
	if isCreatingTeams then
		log("? Team creation already in progress, skipping...")
		return
	end

	isCreatingTeams = true
	log("?? Creating all teams in proper order...")

	-- Clear all existing teams first
	for _, team in pairs(Teams:GetChildren()) do
		if team:IsA("Team") then
			log("??? Removing existing team: " .. team.Name)
			team:Destroy()
		end
	end

	task.wait(0.5) -- Wait for cleanup

	-- Create teams in order
	local orderedTeams = {}
	for teamName, config in pairs(TEAM_CONFIGS) do
		table.insert(orderedTeams, {name = teamName, config = config})
	end

	-- Sort by order
	table.sort(orderedTeams, function(a, b)
		return a.config.order < b.config.order
	end)

	-- Create each team
	for _, teamData in pairs(orderedTeams) do
		createSingleTeam(teamData.name, teamData.config)
		task.wait(0.1) -- Small delay between creations
	end

	isCreatingTeams = false
	log("? All teams created successfully!")

	-- Verify all teams exist
	local missingTeams = {}
	for teamName, _ in pairs(TEAM_CONFIGS) do
		if not Teams:FindFirstChild(teamName) then
			table.insert(missingTeams, teamName)
		end
	end

	if #missingTeams > 0 then
		warn("? Missing teams after creation: " .. table.concat(missingTeams, ", "))
		-- Try once more for missing teams
		for _, teamName in pairs(missingTeams) do
			local config = TEAM_CONFIGS[teamName]
			createSingleTeam(teamName, config)
		end
	end

	-- List final teams
	log("?? Final team list:")
	for _, team in pairs(Teams:GetChildren()) do
		if team:IsA("Team") then
			log("  - " .. team.Name .. " (" .. tostring(team.TeamColor.Color) .. ")")
		end
	end
end

-- Function to assign player to correct team
local function assignPlayerToTeam(player, rank)
	if not player or not player.Parent then
		return false
	end

	rank = rank or "Guest"
	local targetTeam = Teams:FindFirstChild(rank)

	if not targetTeam then
		warn("? Team not found: " .. rank .. ", creating...")
		local config = TEAM_CONFIGS[rank]
		if config then
			targetTeam = createSingleTeam(rank, config)
		else
			-- Fallback to Guest
			targetTeam = Teams:FindFirstChild("Guest")
		end
	end

	if targetTeam then
		player.Team = targetTeam
		log("? Assigned " .. player.Name .. " to " .. rank .. " team")
		return true
	else
		warn("? Failed to assign " .. player.Name .. " to team: " .. rank)
		return false
	end
end

-- Function to get player rank (integrates with PlayerRanks system)
local function getPlayerRank(player)
	if _G.GetPlayerRank then
		return _G.GetPlayerRank(player)
	end
	return "Guest" -- Fallback
end

-- Function to update all player teams
local function updateAllPlayerTeams()
	log("?? Updating all player teams...")
	for _, player in pairs(Players:GetPlayers()) do
		local rank = getPlayerRank(player)
		assignPlayerToTeam(player, rank)
		task.wait(0.1)
	end
	log("? All player teams updated")
end

-- Monitor for missing teams
local function startTeamMonitoring()
	task.spawn(function()
		while true do
			task.wait(15) -- Check every 15 seconds

			-- Check for missing teams
			local missingTeams = {}
			for teamName, config in pairs(TEAM_CONFIGS) do
				local team = Teams:FindFirstChild(teamName)
				if not team then
					table.insert(missingTeams, teamName)
				end
			end

			-- Create missing teams
			if #missingTeams > 0 then
				log("?? Missing teams detected: " .. table.concat(missingTeams, ", "))
				for _, teamName in pairs(missingTeams) do
					local config = TEAM_CONFIGS[teamName]
					createSingleTeam(teamName, config)
					task.wait(0.1)
				end
			end
		end
	end)

	log("? Team monitoring started (checks every 15 seconds)")
end

-- Listen for rank changes from PlayerRanks system
local function connectToRankChanges()
	-- Method 1: Listen to RankChanged event
	RankChangedEvent.OnServerEvent:Connect(function(player, newRank)
		log("?? Rank change detected for " .. player.Name .. " to: " .. newRank)
		task.spawn(function()
			task.wait(0.5) -- Small delay
			assignPlayerToTeam(player, newRank)
		end)
	end)

	-- Method 2: Listen to FireAllClients version
	RankChangedEvent.OnServerEvent:Connect(function(userId, newRank)
		if type(userId) == "number" then
			local player = Players:GetPlayerByUserId(userId)
			if player then
				log("?? Rank change detected (broadcast) for " .. player.Name .. " to: " .. newRank)
				task.spawn(function()
					task.wait(0.5)
					assignPlayerToTeam(player, newRank)
				end)
			end
		end
	end)

	log("? Connected to rank change events")
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
	log("?? Player joined: " .. player.Name)

	-- Wait for character spawn
	player.CharacterAdded:Connect(function()
		task.spawn(function()
			task.wait(3) -- Wait for other systems to process
			local rank = getPlayerRank(player)
			assignPlayerToTeam(player, rank)
		end)
	end)

	-- Handle if already spawned
	if player.Character then
		task.spawn(function()
			task.wait(3)
			local rank = getPlayerRank(player)
			assignPlayerToTeam(player, rank)
		end)
	end
end)

-- Admin commands
local function handleAdminCommands(player, message)
	if player.UserId ~= 8899222872 then return end

	local cmd = message:lower()

	if cmd == "/createteams" or cmd == "/fixteams" then
		log("?? Manual team creation by " .. player.Name)
		createAllTeams()
		task.wait(2)
		updateAllPlayerTeams()

	elseif cmd == "/updateteams" then
		log("?? Manual team update by " .. player.Name)
		updateAllPlayerTeams()

	elseif cmd == "/listteams" then
		log("?? Current teams:")
		for teamName, config in pairs(TEAM_CONFIGS) do
			local team = Teams:FindFirstChild(teamName)
			local status = team and "? EXISTS" or "? MISSING"
			log("  " .. teamName .. ": " .. status .. " (Order: " .. config.order .. ")")
		end

	elseif cmd:sub(1, 10) == "/setteam " then
		local args = cmd:split(" ")
		if #args >= 3 then
			local targetName = args[2]
			local teamName = args[3]

			local targetPlayer = nil
			for _, p in pairs(Players:GetPlayers()) do
				if p.Name:lower():find(targetName:lower()) then
					targetPlayer = p
					break
				end
			end

			if targetPlayer then
				assignPlayerToTeam(targetPlayer, teamName)
			else
				log("? Player not found: " .. targetName)
			end
		end

	elseif cmd == "/teamstatus" then
		log("?? TEAM STATUS REPORT:")
		log("Total teams in folder: " .. #Teams:GetChildren())
		for _, team in pairs(Teams:GetChildren()) do
			if team:IsA("Team") then
				local playerCount = #team:GetPlayers()
				log("  " .. team.Name .. ": " .. playerCount .. " players")
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

-- Global functions for other scripts
_G.AssignPlayerToTeam = assignPlayerToTeam
_G.CreateAllTeams = createAllTeams
_G.GetTeamConfig = function(teamName)
	return TEAM_CONFIGS[teamName]
end

-- Initialize system
local function initializeTeamManager()
	task.spawn(function()
		-- Wait for other systems to load
		task.wait(2)

		log("?? Starting team creation...")
		createAllTeams()

		-- Wait for PlayerRanks system
		local attempts = 0
		while not _G.GetPlayerRank and attempts < 30 do
			task.wait(1)
			attempts = attempts + 1
		end

		if _G.GetPlayerRank then
			log("? PlayerRanks system found, connecting to rank changes...")
			connectToRankChanges()

			task.wait(2)
			updateAllPlayerTeams()
		else
			log("?? PlayerRanks system not found after 30 seconds")
		end

		startTeamMonitoring()
	end)
end

-- Start the system
initializeTeamManager()
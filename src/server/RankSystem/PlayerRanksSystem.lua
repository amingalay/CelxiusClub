-- ServerScriptService > Misc > PlayerRanksSystem

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

-- PlayerRanks DataStore
local playerRanksDataStore = DataStoreService:GetDataStore("PlayerRanks")

-- Wait for Global Config
local function waitForGlobalConfig()
    local maxWait = 10
    local waitTime = 0

    while not _G.GamepassCode and waitTime < maxWait do
        task.wait(0.1)
        waitTime = waitTime + 0.1
    end

    if not _G.GamepassCode then
        warn("?? Global gamepass config not found! Using fallback values.")
		return {VIP = 1459564491, VVIP = 1431661148, DJ = 1431637360}
    end

    return _G.GamepassCode
end

-- Configuration
local GamepassConfig = waitForGlobalConfig()
local VIP_Gamepass_ID = GamepassConfig.VIP -- 1397990052
local VVIP_Gamepass_ID = GamepassConfig.VVIP or GamepassConfig.DJ -- 1397078410
local DJ_Gamepass_ID = GamepassConfig.DJ   -- 1397078410

-- Owner and Admin Configuration
local ownerUserId = 9053456438
local adminList = {
	8876419479,8899222872,9053456438,
}

local RankConfig = {
    Owner = {
        priority = 100,
        color = {77, 255, 0}, -- Dark red
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = true
    },
    Staff = {
        priority = 130,
        color = {85, 255, 255}, -- Dark red
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = true
    },
    Sultan = {
        priority = 120,
        color = {0, 0, 255}, -- Gold
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = true  -- FIXED: TopSpender has all access
    },
    TopSpender = {
        priority = 90,
        color = {255, 215, 0}, -- Gold
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = true  -- FIXED: TopSpender has all access
    },
    DJ = {
        priority = 110,
        color = {0, 132, 255}, -- Purple
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = false
    },
    Influencer = {
        priority = 80,
        color = {255, 142, 3}, -- Lime green
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = true  -- FIXED: Influencer has all access
    },
    Gueststar = {
        priority = 50,
        color = {138, 43, 226}, -- Purple
        hasVIPAccess = true,
        hasDJAccess = true,
        hasAllAccess = false
    },
    VVIP = {
        priority = 70,
        color = {226, 1, 207}, -- Purple
        hasVIPAccess = true,  -- FIXED: VVIP should have VIP access too
        hasDJAccess = true,
        hasAllAccess = false
    },
    VIP = {
        priority = 60,
		color = {255, 170, 0}, -- Gold
        hasVIPAccess = true,
        hasDJAccess = false,
        hasAllAccess = false
    },
    Guest = {
        priority = 10,
        color = {169, 169, 169}, -- Gray
        hasVIPAccess = false,
        hasDJAccess = false,
        hasAllAccess = false
    }
}

-- ===== Tools Access (ADD-ONLY) =====
local TOOL_TEMPLATES = {
	MoneyGun 		= ServerStorage:FindFirstChild("MoneyGun"),
	Azule			= ServerStorage:FindFirstChild("Azule"),
	Smoke			= ServerStorage:FindFirstChild("Smoke"),
	ConfettiGun		= ServerStorage:FindFirstChild("ConfettiGun"),
	BubbleParty		= ServerStorage:FindFirstChild("BubbleParty"),
	Martell			= ServerStorage:FindFirstChild("Martell"),
	Glowstick		= ServerStorage:FindFirstChild("Glowstick"),
}

for name, inst in pairs(TOOL_TEMPLATES) do
	if not inst or not inst:IsA("Tool") then
		warn(("[TOOLS] %s tidak ditemukan di ServerStorage atau bukan Tool."):format(name))
	end
end

local VIP_ONLY = { "ConfettiGun", "Glowstick", "Azule"}
local ALL_TOOLS = { "MoneyGun", "ConfettiGun", "BubbleParty", "Azule", "Smoke","Martell","Glowstick" }

local function getAllowedToolsForRank(rank: string): {string}
	local config = RankConfig[rank] or RankConfig.Guest
	local vipPriority = (RankConfig.VIP and RankConfig.VIP.priority) or 60
	if rank == "VIP" then
		return VIP_ONLY
	end
	if config.priority > vipPriority then
		return ALL_TOOLS
	end
	return {}
end

local function ensureToolIn(container: Instance, toolName: string)
	if not container then return end
	if container:FindFirstChild(toolName) then return end
	local tpl = TOOL_TEMPLATES[toolName]
	if not (tpl and tpl:IsA("Tool")) then return end
	local clone = tpl:Clone()
	clone.Parent = container
end

local function addAllowedToolsFor(player: Player, rank: string)
	local allowed = getAllowedToolsForRank(rank)
	if #allowed == 0 then return end
	local backpack = player:FindFirstChildOfClass("Backpack")
	local starterGear = player:FindFirstChild("StarterGear")
	for _, toolName in ipairs(allowed) do
		if backpack then ensureToolIn(backpack, toolName) end
		if starterGear then ensureToolIn(starterGear, toolName) end
	end
end


local function removeDisallowed(player: Player, rank: string)
	local allowedSet = {}
	for _, n in ipairs(getAllowedToolsForRank(rank)) do
		allowedSet[n] = true
	end
	local function sweep(container)
		if not container then return end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") and TOOL_TEMPLATES[child.Name] and not allowedSet[child.Name] then
				child:Destroy()
			end
		end
	end
	sweep(player:FindFirstChildOfClass("Backpack"))
	sweep(player:FindFirstChild("StarterGear"))
end

-- ===== END Tools Access =====


-- Player tracking
local PlayerDoorStates = {}
local PlayerRequestCooldowns = {}
local COOLDOWN_TIME = 2

-- Purchase tracking to prevent spam
local PurchaseCooldowns = {}
local PURCHASE_COOLDOWN = 5

-- Door References
local Door = workspace:WaitForChild("WALL")
local AllScreenVIPs = {}
local AllScreenDJs = {}

-- Remote Events (use existing structure)
local Events = ReplicatedStorage:WaitForChild("Events")
local GetConfigEvent = Events:WaitForChild("GetConfig")
local CheckGamepassEvent = Events:WaitForChild("CheckGamepass") 
local GetPlayerRankEvent = Events:WaitForChild("GetPlayerRank")
local PurchaseGamepassEvent = Events:WaitForChild("PurchaseGamepass") -- Note: typo in original
local RankChangedEvent = Events:WaitForChild("RankChanged")
local UpdateDoorEvent = Events:WaitForChild("UpdateDoor")

-- Utility Functions
local function log(message)
    --print("[RANKS] " .. message)
end

local function isPlayerAdmin(player)
    return player.UserId == ownerUserId or table.find(adminList, player.UserId)
end

-- PlayerRanks Functions
local function getPlayerRank(player)
    local success, rankData = pcall(function()
        return playerRanksDataStore:GetAsync(player.UserId)
    end)

    if success and rankData then
        if type(rankData) == "string" then
            return rankData
        elseif type(rankData) == "table" and rankData.rank then
            return rankData.rank
        end
    end

    -- Default rank assignment
    if player.UserId == ownerUserId then
        return "Owner"
    elseif table.find(adminList, player.UserId) then
        return "Owner"
    else
        return "Guest"
    end
end

local function setPlayerRank(player, rank)
    if not RankConfig[rank] then
        warn("Invalid rank: " .. tostring(rank))
        return false
    end

    local success = pcall(function()
        playerRanksDataStore:SetAsync(player.UserId, rank)
    end)

    if success then
        log("? Set rank for " .. player.Name .. " to: " .. rank)
        -- Fire rank changed event
        RankChangedEvent:FireClient(player, rank)
        return true
    else
        warn("? Failed to set rank for " .. player.Name)
        return false
    end
end

-- Gamepass Functions
local function serverCheckGamepass(player, gamepassId)
    if not player or not player.Parent then
        return false
    end

    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
    end)

    return success and owns or false
end

local function getPlayerDoorAccess(player)
    local rank = getPlayerRank(player)
    local rankData = RankConfig[rank] or RankConfig.Guest

    -- Check gamepass ownership
    local hasVIPGamepass = serverCheckGamepass(player, VIP_Gamepass_ID)
    local hasVVIPGamepass = serverCheckGamepass(player, VVIP_Gamepass_ID)
    local hasDJGamepass = serverCheckGamepass(player, DJ_Gamepass_ID)

    -- Combine rank access with gamepass access
    local hasVIPAccess = rankData.hasVIPAccess or hasVIPGamepass or hasVVIPGamepass
    local hasDJAccess = rankData.hasDJAccess or hasDJGamepass or hasVVIPGamepass
    local hasAllAccess = rankData.hasAllAccess

    return {
        hasVIP = hasVIPAccess,
        hasDJ = hasDJAccess,
        hasAll = hasAllAccess,
        rank = rank,
        rankColor = rankData.color,
        priority = rankData.priority
    }
end

-- Auto-assign ranks based on gamepass ownership
local function autoAssignRankFromGamepass(player)
    local currentRank = getPlayerRank(player)
    local currentRankData = RankConfig[currentRank] or RankConfig.Guest

    -- Don't downgrade high-priority ranks
    if currentRankData.priority >= 80 then
        return
    end

    local hasVIPGamepass = serverCheckGamepass(player, VIP_Gamepass_ID)
    local hasVVIPGamepass = serverCheckGamepass(player, VVIP_Gamepass_ID)
    local hasDJGamepass = serverCheckGamepass(player, DJ_Gamepass_ID)

    if (hasVVIPGamepass or hasDJGamepass) and currentRankData.priority < 70 then
        setPlayerRank(player, "VVIP")
        log("?? Auto-assigned VVIP rank to " .. player.Name .. " (VVIP/DJ gamepass owner)")
    elseif hasVIPGamepass and currentRankData.priority < 60 then
        setPlayerRank(player, "VIP")
        log("?? Auto-assigned VIP rank to " .. player.Name .. " (VIP gamepass owner)")
    end
end

-- Door Control Functions
local function findAllScreens()
    log("Finding all screens in WALL...")

    AllScreenVIPs = {}
    AllScreenDJs = {}

    for _, child in pairs(Door:GetChildren()) do
        if child.Name == "ScreenVIP" and child:IsA("UnionOperation") then
            table.insert(AllScreenVIPs, child)
        elseif child.Name == "ScreenDJ" and child:IsA("UnionOperation") then
            table.insert(AllScreenDJs, child)
        end
    end

    log("Total screens found - VIP: " .. #AllScreenVIPs .. ", DJ: " .. #AllScreenDJs)
end

local function isPlayerRequestOnCooldown(player)
    local userId = player.UserId
    local currentTime = tick()

    if PlayerRequestCooldowns[userId] then
        local timeSinceLastRequest = currentTime - PlayerRequestCooldowns[userId]
        if timeSinceLastRequest < COOLDOWN_TIME then
            return true
        end
    end

    PlayerRequestCooldowns[userId] = currentTime
    return false
end

local function updateIndividualPlayerDoorAccess(player, bypassCooldown)
    if not player or not player.Parent or not player.Character then
        return
    end

    if not bypassCooldown and isPlayerRequestOnCooldown(player) then
        return
    end

    local doorAccess = getPlayerDoorAccess(player)

    -- Store player's door state
    PlayerDoorStates[player.UserId] = {
        hasVIP = doorAccess.hasVIP,
        hasDJ = doorAccess.hasDJ,
        hasAll = doorAccess.hasAll,
        rank = doorAccess.rank,
        lastUpdate = tick()
    }

    log("?? Updated access for " .. player.Name .. " (" .. doorAccess.rank .. ") - VIP: " .. tostring(doorAccess.hasVIP) .. ", DJ: " .. tostring(doorAccess.hasDJ) .. ", All: " .. tostring(doorAccess.hasAll))

    -- Send update to specific player
    UpdateDoorEvent:FireClient(player, {
        hasVIP = doorAccess.hasVIP,
        hasDJ = doorAccess.hasDJ,
        hasAll = doorAccess.hasAll,
        rank = doorAccess.rank,
        vipScreens = #AllScreenVIPs,
        djScreens = #AllScreenDJs
	})
	addAllowedToolsFor(player, doorAccess.rank)
end

-- Purchase cooldown check
local function isPurchaseOnCooldown(player)
    local userId = player.UserId
    local currentTime = tick()

    if PurchaseCooldowns[userId] then
        local timeSinceLastPurchase = currentTime - PurchaseCooldowns[userId]
        if timeSinceLastPurchase < PURCHASE_COOLDOWN then
            return true
        end
    end

    PurchaseCooldowns[userId] = currentTime
    return false
end

-- Event Handlers
GetConfigEvent.OnServerInvoke = function(player)
    return {
        VIP = VIP_Gamepass_ID,
        VVIP = VVIP_Gamepass_ID
    }
end

-- Handle GetPlayerRank as RemoteEvent
GetPlayerRankEvent.OnServerEvent:Connect(function(player)
    local rank = getPlayerRank(player)
    local rankData = RankConfig[rank] or RankConfig.Guest
    -- Fire back the rank data
    GetPlayerRankEvent:FireClient(player, {
        rank = rank,
        color = rankData.color,
        priority = rankData.priority
    })
end)

CheckGamepassEvent.OnServerEvent:Connect(function(player, gamepassId)
    if not gamepassId or (gamepassId ~= VIP_Gamepass_ID and gamepassId ~= VVIP_Gamepass_ID and gamepassId ~= DJ_Gamepass_ID) then
        warn("[SERVER] Invalid gamepass ID from client: " .. tostring(gamepassId))
        CheckGamepassEvent:FireClient(player, false)
        return
    end
    local result = serverCheckGamepass(player, gamepassId)
    CheckGamepassEvent:FireClient(player, result)
end)

PurchaseGamepassEvent.OnServerEvent:Connect(function(player, gamepassId, gamepassType)
    log("Purchase request from " .. player.Name .. " for " .. (gamepassType or "unknown") .. " (ID: " .. tostring(gamepassId) .. ")")

    -- Check purchase cooldown
    if isPurchaseOnCooldown(player) then
        log("? Purchase request from " .. player.Name .. " is on cooldown")
        return
    end

    -- Validate gamepass ID
    if gamepassId ~= VIP_Gamepass_ID and gamepassId ~= VVIP_Gamepass_ID and gamepassId ~= DJ_Gamepass_ID then
        warn("? Invalid gamepass ID: " .. tostring(gamepassId))
        return
    end

    -- Check if already owns
    if serverCheckGamepass(player, gamepassId) then
        log("? Player " .. player.Name .. " already owns gamepass " .. gamepassId .. ", updating access...")
        updateIndividualPlayerDoorAccess(player, true)

        -- Send message to player
        spawn(function()
            if player.Character and player.Character:FindFirstChild("Head") then
                local message = "? You already own this gamepass! Your access has been refreshed."
                game:GetService("Chat"):Chat(player.Character.Head, message)
            end
        end)
        return
    end

    -- Prompt purchase
    local success, error = pcall(function()
        MarketplaceService:PromptGamePassPurchase(player, gamepassId)
    end)

    if success then
        log("? Purchase prompt shown to " .. player.Name .. " for gamepass " .. gamepassId)
    else
        warn("? Failed to show purchase prompt to " .. player.Name .. ": " .. tostring(error))
    end
end)

-- Gamepass Purchase Handler
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
    log("Purchase finished - Player: " .. player.Name .. ", GamePass: " .. gamepassId .. ", Purchased: " .. tostring(wasPurchased))

    if wasPurchased then
        -- Auto-assign rank based on gamepass
        autoAssignRankFromGamepass(player)

        -- Update door access immediately
        task.spawn(function()
            task.wait(1)
            updateIndividualPlayerDoorAccess(player, true)
		end)
		
		-- Beri tools sesuai rank saat ini (masuk juga ke StarterGear)
		local rankNow = getPlayerRank(player)
		addAllowedToolsFor(player, rankNow)

		-- Force respawn supaya loadout & nametag langsung bersih sesuai akses baru
		task.spawn(function()
			task.wait(0.75)
			if player and player.Parent then
				player:LoadCharacter()
			end
		end)

        local gamepassName = "Unknown"
        if gamepassId == VIP_Gamepass_ID then
            gamepassName = "VIP"
        elseif gamepassId == VVIP_Gamepass_ID then
            gamepassName = "VVIP"
        elseif gamepassId == DJ_Gamepass_ID then
            gamepassName = "DJ"
        end

        log("?? " .. player.Name .. " successfully purchased " .. gamepassName .. " gamepass!")

        -- Send success message
        task.spawn(function()
            task.wait(0.5)
            if player and player.Parent and player.Character and player.Character:FindFirstChild("Head") then
                local chatService = game:GetService("Chat")
                local message = "?? Thank you for your purchase! Your " .. gamepassName .. " access has been activated!"
                chatService:Chat(player.Character.Head, message)
            end
        end)

        -- Force update teams and nametags
        spawn(function()
            wait(2)
            local newRank = getPlayerRank(player)

            -- Update team
            local Teams = game:GetService("Teams")
            local targetTeam = Teams:FindFirstChild(newRank)
            if targetTeam then
                player.Team = targetTeam
                log("? Updated " .. player.Name .. " team to: " .. newRank)
            end

            -- Update nametag
            if _G.UpdatePlayerNametag then
                _G.UpdatePlayerNametag(player)
            end
        end)
    else
        log("? " .. player.Name .. " cancelled or failed to purchase gamepass " .. gamepassId)
    end
end)

-- Admin Commands
local function onPlayerChatted(player, message)
    if not isPlayerAdmin(player) then return end

    if message:sub(1, 1) == "/" then
        local args = message:split(" ")
        local command = args[1]:lower()

        if command == "/setrank" then
            local targetName = args[2]
            local rankName = args[3]

            if not targetName or not rankName then
                log("? Usage: /setrank [player] [rank]")
                return
			end

            local targetPlayer = Players:FindFirstChild(targetName)
            if not targetPlayer then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.DisplayName:lower():find(targetName:lower()) then
                        targetPlayer = p
                        break
                    end
                end
            end

            if not targetPlayer then
                log("? Player not found: " .. targetName)
                return
            end

            -- Find matching rank (case insensitive)
            local actualRank = nil
            for rank, _ in pairs(RankConfig) do
                if rank:lower() == rankName:lower() then
                    actualRank = rank
                    break
                end
            end

            if not actualRank then
                log("? Invalid rank: " .. rankName)
                log("Available ranks: Owner, TopSpender, Influencer, DJ, VVIP, VIP, Guest")
                return
            end

			if setPlayerRank(targetPlayer, actualRank) then
				log("? Set " .. targetPlayer.Name .. "'s rank to: " .. actualRank)

				-- Umumkan ke klien (buat nametag UI dsb)
				RankChangedEvent:FireAllClients(targetPlayer.UserId, actualRank)

				-- Recompute akses
				task.spawn(function()
					task.wait(1)
					updateIndividualPlayerDoorAccess(targetPlayer, true)
				end)

				-- Update tim
				task.spawn(function()
					task.wait(0.5)
					local Teams = game:GetService("Teams")
					local targetTeam = Teams:FindFirstChild(actualRank)
					if targetTeam then
						targetPlayer.Team = targetTeam
						log("? Updated " .. targetPlayer.Name .. " team to: " .. actualRank)
					else
						warn("? Team not found: " .. actualRank)
					end
				end)

				-- Update nametag
				task.spawn(function()
					task.wait(1.5)
					if _G.UpdatePlayerNametag then
						_G.UpdatePlayerNametag(targetPlayer)
						log("? Updated " .. targetPlayer.Name .. " nametag")
					else
						local character = targetPlayer.Character
						if character and character:FindFirstChild("Head") then
							local head = character.Head
							local existingNametag = head:FindFirstChild("NameTag")
							if existingNametag then
								existingNametag:Destroy()
								task.wait(0.2)
								log("?? Removed old nametag for " .. targetPlayer.Name)
							end
						end
					end
				end)

				-- ? Sinkron tools: (pilih salah satu baris removeDisallowed, kalau mau ketat)
				task.spawn(function()
					task.wait(0.25)
					local rankNow = getPlayerRank(targetPlayer)
					-- HAPUS baris di bawah jika kamu TIDAK mau mode ketat
					-- removeDisallowed(targetPlayer, rankNow)
					addAllowedToolsFor(targetPlayer, rankNow)
				end)

				-- ? Force respawn agar loadout & nama langsung sesuai rank baru
				task.delay(0.75, function()
					if targetPlayer and targetPlayer.Parent then
						targetPlayer:LoadCharacter()
					end
				end)
			end

        elseif command == "/checkrank" then
            local targetName = args[2]

            if not targetName then
                log("? Usage: /checkrank [player]")
                return
            end

            local targetPlayer = Players:FindFirstChild(targetName)
            if not targetPlayer then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.DisplayName:lower():find(targetName:lower()) then
                        targetPlayer = p
                        break
                    end
                end
            end

            if not targetPlayer then
                log("? Player not found: " .. targetName)
                return
            end

            local rank = getPlayerRank(targetPlayer)
            local doorAccess = getPlayerDoorAccess(targetPlayer)

            log("?? " .. targetPlayer.Name .. "'s info:")
            log("  Rank: " .. rank)
            log("  VIP Access: " .. tostring(doorAccess.hasVIP))
            log("  DJ Access: " .. tostring(doorAccess.hasDJ))
            log("  All Access: " .. tostring(doorAccess.hasAll))
            log("  Priority: " .. doorAccess.priority)
            log("  VIP Gamepass: " .. tostring(serverCheckGamepass(targetPlayer, VIP_Gamepass_ID)))
            log("  VVIP Gamepass: " .. tostring(serverCheckGamepass(targetPlayer, VVIP_Gamepass_ID)))
            log("  DJ Gamepass: " .. tostring(serverCheckGamepass(targetPlayer, DJ_Gamepass_ID)))

        elseif command == "/syncranks" then
            log("?? Syncing all player ranks and door access...")
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                task.spawn(function()
                    autoAssignRankFromGamepass(targetPlayer)
                    task.wait(0.5)
                    updateIndividualPlayerDoorAccess(targetPlayer, true)
                end)
            end
            log("? Rank sync completed")

        elseif command == "/listranks" then
            log("?? Available Ranks:")
            local sortedRanks = {}
            for rank, data in pairs(RankConfig) do
                table.insert(sortedRanks, {rank = rank, priority = data.priority})
            end
            table.sort(sortedRanks, function(a, b) return a.priority > b.priority end)

            for _, rankData in pairs(sortedRanks) do
                local config = RankConfig[rankData.rank]
                log("  " .. rankData.rank .. " (Priority: " .. config.priority .. ") - VIP: " .. tostring(config.hasVIPAccess) .. ", DJ: " .. tostring(config.hasDJAccess) .. ", All: " .. tostring(config.hasAllAccess))
            end

        elseif command == "/testpurchase" then
            local targetName = args[2]
            local gamepassType = args[3] and args[3]:upper() or "VIP"

            if not targetName then
                log("? Usage: /testpurchase [player] [VIP/VVIP]")
                return
            end

            local targetPlayer = Players:FindFirstChild(targetName)
            if not targetPlayer then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.DisplayName:lower():find(targetName:lower()) then
                        targetPlayer = p
                        break
                    end
                end
            end

            if not targetPlayer then
                log("? Player not found: " .. targetName)
                return
            end

            local gamepassId = (gamepassType == "VVIP") and VVIP_Gamepass_ID or VIP_Gamepass_ID

            log("?? Testing purchase prompt for " .. targetPlayer.Name .. " (" .. gamepassType .. ")")

            local success, error = pcall(function()
                MarketplaceService:PromptGamePassPurchase(targetPlayer, gamepassId)
            end)

            if success then
                log("? Test purchase prompt shown successfully")
            else
                log("? Test purchase prompt failed: " .. tostring(error))
            end
        end
    end
end

-- Player Events
Players.PlayerAdded:Connect(function(player)
    log("Player joined: " .. player.Name)

    -- Initialize player door state
    PlayerDoorStates[player.UserId] = {
        hasVIP = false,
        hasDJ = false,
        hasAll = false,
        rank = "Guest",
        lastUpdate = 0
    }

    -- Initialize cooldowns
    PlayerRequestCooldowns[player.UserId] = 0
    PurchaseCooldowns[player.UserId] = 0

    -- Setup chat commands
    player.Chatted:Connect(function(message)
        onPlayerChatted(player, message)
    end)

    -- Check rank and door access when character spawns
	player.CharacterAdded:Connect(function()
		wait(3)
		autoAssignRankFromGamepass(player)
		updateIndividualPlayerDoorAccess(player, false)

		-- Tambah tools sesuai rank saat respawn
		local r = _G.GetPlayerRank and _G.GetPlayerRank(player) or "Guest"
		addAllowedToolsFor(player, r)
	end)

    if player.Character then
        spawn(function()
            wait(2)
            autoAssignRankFromGamepass(player)
            updateIndividualPlayerDoorAccess(player, false)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    PlayerRequestCooldowns[player.UserId] = nil
    PlayerDoorStates[player.UserId] = nil
    PurchaseCooldowns[player.UserId] = nil
    log("Player left: " .. player.Name)
end)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
    if player then
        PlayerDoorStates[player.UserId] = {
            hasVIP = false,
            hasDJ = false,
            hasAll = false,
            rank = "Guest",
            lastUpdate = 0
        }

        PlayerRequestCooldowns[player.UserId] = 0
        PurchaseCooldowns[player.UserId] = 0

        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)

        spawn(function()
            wait(2)
            autoAssignRankFromGamepass(player)
            updateIndividualPlayerDoorAccess(player, false)
        end)
    end
end

-- Periodic Access Check
spawn(function()
    while true do
        wait(30)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and PlayerDoorStates[player.UserId] then
                spawn(function()
                    updateIndividualPlayerDoorAccess(player, false)
                end)
            end
        end
    end
end)

-- Initialize System
local function initializePlayerRanksSystem()
    log("=== PLAYERRANKS SYSTEM WITH GAMEPASS INTEGRATION ===")
    log("Owner ID: " .. ownerUserId)
    log("VIP Gamepass ID: " .. VIP_Gamepass_ID)
    log("VVIP Gamepass ID: " .. VVIP_Gamepass_ID)
    log("DJ Gamepass ID: " .. DJ_Gamepass_ID)

    findAllScreens()

    log("=== SYSTEM READY ===")
    log("? PlayerRanks DataStore integration")
    log("? Individual door access control")
    log("? Automatic gamepass rank assignment")
    log("? Purchase cooldown system")
    log("? Admin commands: /setrank, /checkrank, /listranks, /syncranks, /testpurchase")
    log("? Available ranks: Owner, TopSpender, Influencer, DJ, VVIP, VIP, Guest")
    log("? Screen mapping - VIP: ScreenVIP, DJ: ScreenDJ")
end

-- Global functions for integration
_G.GetPlayerRank = getPlayerRank
_G.SetPlayerRank = setPlayerRank
_G.GetPlayerDoorAccess = getPlayerDoorAccess
_G.UpdatePlayerDoorAccess = updateIndividualPlayerDoorAccess
_G.CheckGamepassOwnership = serverCheckGamepass
_G.AutoAssignRankFromGamepass = autoAssignRankFromGamepass

-- Start the system
initializePlayerRanksSystem()
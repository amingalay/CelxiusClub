-- ServerScriptService > Misc > NameTagScript (Enhanced with Multi-Logo System and Gradient Animation)

local rep = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local nametag = rep.NameTag

-- DataStores
local nametagStore = DataStoreService:GetDataStore("CustomNametags")
local logoStore = DataStoreService:GetDataStore("PlayerLogos") -- NEW: Separate DataStore for logos

-- Owner Configuration
local OWNER_USER_IDS = {
	9053456438,
	8899222872,
	8876419479,
}

-- Events from existing structure
local Events = rep:WaitForChild("Events")
local RankChangedEvent = Events:WaitForChild("RankChanged")

-- Konfigurasi Ranks (sesuai dengan Unified PlayerRanks System)
local RANK_CONFIGS = {
	["Owner"] = { text = "Owner", color = Color3.fromRGB(255, 0, 255), teamName = "Owner" },
	["Staff"] = { text = "Staff", color = Color3.fromRGB(85, 255, 255), teamName = "Staff" },
	["Sultan"] = { text = "Sultan", color = Color3.fromRGB(0, 0, 255), teamName = "Sultan" },
	["TopSpender"] = { text = "TopSpender", color = Color3.fromRGB(85, 0, 127), teamName = "TopSpender" },
	["DJ"] = { text = "DJ", color = Color3.fromRGB(0, 132, 255), teamName = "DJ" },
	["Influencer"] = { text = "Influencer", color = Color3.fromRGB(255, 142, 3), teamName = "Influencer" },
	["Gueststar"] = { text = "Gueststar", color = Color3.fromRGB(138, 43, 226), teamName = "Gueststar" },
	["VVIP"] = { text = "VVIP", color = Color3.fromRGB(255, 0, 0), teamName = "VVIP" },
	["VIP"] = { text = "VIP", color = Color3.fromRGB(255, 170, 0), teamName = "VIP" },
	["Guest"] = { text = "Guest", color = Color3.fromRGB(169, 169, 169), teamName = "Guest" },
}

-- Special Users Configuration (TAMBAHAN UNTUK FebeBbyy)
local SPECIAL_USERS = {
	["TCopaa"] = {
		text = "Owner",
		color = Color3.fromRGB(255, 85, 255), -- Warna merah untuk FebeBbyy
		teamName = "Owner", -- atau team yang diinginkan
	},
	--["Miinn0777"] = {
	--	text = "?FOUNDER CELIXUS?",
	--	color = Color3.fromRGB(85, 170, 255), -- Warna hijau untuk Tedsuno
	--	teamName = "Owner" -- atau team yang diinginkan
	--},
	["K4yysie"] = {
		text = "QUEEN",
		color = Color3.fromRGB(255, 0, 127), -- Warna biru untuk syndcate_77
		teamName = "Sultan", -- atau team yang diinginkan
	},
	["jeonghan167"] = {
		text = "Admin",
		color = Color3.fromRGB(255, 170, 255), -- Warna biru untuk syndcate_77
		teamName = "Staff", -- atau team yang diinginkan
	},
	["Farlenz"] = {
		text = "BARTENDER",
		color = Color3.fromRGB(85, 170, 255), -- Warna biru untuk syndcate_77
		teamName = "Sultan", -- atau team yang diinginkan
	},
	["choccomatchha"] = {
		text = "KORBAN HTS",
		color = Color3.fromRGB(0, 85, 255), -- Warna biru untuk syndcate_77
		teamName = "Sultan", -- atau team yang diinginkan
	},
	["1niYukii"] = {
		text = "PRINCESS",
		color = Color3.fromRGB(255, 85, 255), -- Warna biru untuk syndcate_77
		teamName = "TopSpender", -- atau team yang diinginkan
	},
	["babycans88"] = {
		text = "LC VALOR",
		color = Color3.fromRGB(255, 85, 255), -- Warna biru untuk syndcate_77
		teamName = "TopSpender", -- atau team yang diinginkan
	},
}

-- UPDATED: Multi-Logo Configuration System
local LOGO_CONFIGS = {
	["dtgg"] = {
		elementName = "DTGG", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["cxc"] = {
		elementName = "CXC", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["ssl"] = {
		elementName = "SSL", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["vl"] = {
		elementName = "VL", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["1tr"] = {
		elementName = "1TR", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["mid"] = {
		elementName = "MID", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["sf"] = {
		elementName = "SF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["puff"] = {
		elementName = "PUFF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["if"] = {
		elementName = "IF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["inc"] = {
		elementName = "INC", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["sst"] = {
		elementName = "SST", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["td"] = {
		elementName = "TD", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["69"] = {
		elementName = "69", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["bh"] = {
		elementName = "BH", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["jse"] = {
		elementName = "JSE", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["kf"] = {
		elementName = "KF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["rbp"] = {
		elementName = "RBP", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["str"] = {
		elementName = "STR", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["sick"] = {
		elementName = "SICK", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["n1"] = {
		elementName = "N1", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["otg"] = {
		elementName = "OTG", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["ogk"] = {
		elementName = "OGK", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["trl"] = {
		elementName = "TRL", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["svg"] = {
		elementName = "SVG", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["mmr"] = {
		elementName = "MMR", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["d9"] = {
		elementName = "D9", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["shdf"] = {
		elementName = "SHDF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["agn"] = {
		elementName = "AGN", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["44luv"] = {
		elementName = "44LUV", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["dw"] = {
		elementName = "DW", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["sac"] = {
		elementName = "SAC", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["sov"] = {
		elementName = "SOV", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["flo"] = {
		elementName = "FLO", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["vsc"] = {
		elementName = "VSC", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["end"] = {
		elementName = "END", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["pink"] = {
		elementName = "PINK", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["ctf"] = {
		elementName = "CTF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["snf"] = {
		elementName = "SNF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["zh"] = {
		elementName = "ZH", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["fof"] = {
		elementName = "FOF", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["tsg"] = {
		elementName = "TSG", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["vn"] = {
		elementName = "VN", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["thrash"] = {
		elementName = "THRASH", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["db"] = {
		elementName = "DB", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["4k"] = {
		elementName = "4K", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["805"] = {
		elementName = "805", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["nw"] = {
		elementName = "NW", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["or"] = {
		elementName = "OR", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},
	["lyric"] = {
		elementName = "LYRIC", -- Nama element di ReplicatedStorage > NameTag
		enabled = true,
	},

	-- Template untuk logo baru:
	-- ["logoname"] = {
	--     elementName = "ElementName",
	--     enabled = true
	-- }
}

-- Urutan teams (FIXED - tambahkan kembali Gueststar)
local TEAM_ORDER = { "Owner", "Staff", "Sultan", "TopSpender", "DJ", "Gueststar", "Influencer", "VVIP", "VIP", "Guest" }

-- Table untuk menyimpan custom nametag dan logo
local customNametags = {}
local playerLogos = {} -- NEW: Table for storing player logos

-- NEW: Table untuk menyimpan gradient animations
local gradientAnimations = {} -- Table to store gradient animation tweens

-- List pemain dengan permission khusus
local ADMINS = {
	"TCopaa", -- Ganti dengan username admin
}

-- NEW: Gradient Animation Configuration
local GRADIENT_CONFIG = {
	tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	startPos = Vector2.new(1, 0),
	endPos = Vector2.new(-1, 0),
	startRotation = 180,
}

-- Utility function
local function log(message)
	-- print("[NAMETAG] " .. message) -- Enable logging untuk debug
end

-- NEW: Gradient Animation Functions
local function startGradientAnimation(gradientElement)
	if not gradientElement or not gradientElement:IsA("UIGradient") then
		return
	end

	-- Stop any existing animation for this gradient
	if gradientAnimations[gradientElement] then
		gradientAnimations[gradientElement]:Cancel()
		gradientAnimations[gradientElement] = nil
	end

	-- Setup initial values
	gradientElement.Offset = GRADIENT_CONFIG.startPos
	local currentRotation = GRADIENT_CONFIG.startRotation

	-- Create the tween
	local offsetTween =
		TweenService:Create(gradientElement, GRADIENT_CONFIG.tweenInfo, { Offset = GRADIENT_CONFIG.endPos })

	-- Store the tween reference
	gradientAnimations[gradientElement] = offsetTween

	-- Function to handle animation loop
	local function animateGradient()
		if not gradientElement.Parent then
			-- Cleanup if element no longer exists
			if gradientAnimations[gradientElement] then
				gradientAnimations[gradientElement] = nil
			end
			return
		end

		offsetTween:Play()
		offsetTween.Completed:Wait()

		-- Reset position and flip rotation for continuous animation
		gradientElement.Offset = GRADIENT_CONFIG.startPos
		currentRotation = currentRotation == 180 and 0 or 180
		gradientElement.Rotation = currentRotation

		-- Continue animation
		task.spawn(animateGradient)
	end

	-- Start the animation
	task.spawn(animateGradient)
	log("?? Started gradient animation")
end

local function stopGradientAnimation(gradientElement)
	if gradientAnimations[gradientElement] then
		gradientAnimations[gradientElement]:Cancel()
		gradientAnimations[gradientElement] = nil
		log("?? Stopped gradient animation")
	end
end

-- NEW: Logo DataStore Functions
local function loadPlayerLogo(player)
	local success, result = pcall(function()
		return logoStore:GetAsync(tostring(player.UserId))
	end)

	if success and result then
		-- Validate logo exists in config
		if LOGO_CONFIGS[result] and LOGO_CONFIGS[result].enabled then
			playerLogos[player.UserId] = result
			log("? Loadedd logo for " .. player.Name .. ": " .. result)
		else
			log("?? Invalid logo removed for " .. player.Name .. ": " .. tostring(result))
			-- Remove invalid logo from datastore
			pcall(function()
				logoStore:RemoveAsync(tostring(player.UserId))
			end)
		end
	end
end

local function savePlayerLogo(player, logoType)
	if not logoType then
		-- Remove logo
		local success = pcall(function()
			logoStore:RemoveAsync(tostring(player.UserId))
		end)
		if success then
			playerLogos[player.UserId] = nil
			log("? Removed logo for " .. player.Name)
		end
		return success
	end

	-- Validate logo type
	if logoType and (not LOGO_CONFIGS[logoType] or not LOGO_CONFIGS[logoType].enabled) then
		warn("? Invalid logo type: " .. tostring(logoType))
		return false
	end

	local success = pcall(function()
		logoStore:SetAsync(tostring(player.UserId), logoType)
	end)

	if success then
		playerLogos[player.UserId] = logoType
		log("? Saved logo for " .. player.Name .. ": " .. logoType)
	else
		warn("? Failed to save logo for " .. player.Name)
	end

	return success
end

-- INTEGRATION WITH UNIFIED PLAYERRANKS SYSTEM
local function getPlayerRankFromUnifiedSystem(player)
	-- Menggunakan global function dari Unified PlayerRanks System
	if _G.GetPlayerRank then
		return _G.GetPlayerRank(player)
	else
		-- Fallback jika belum loaded
		warn("?? Unified PlayerRanks System not loaded yet, using fallback")
		return "Guest"
	end
end

-- Fungsi untuk check if player is owner
local function isOwner(player)
	for _, ownerId in pairs(OWNER_USER_IDS) do
		if player.UserId == ownerId then
			return true
		end
	end
	return false
end

-- Fungsi untuk load custom nametag dari DataStore
local function loadCustomNametag(player)
	local success, result = pcall(function()
		return nametagStore:GetAsync(tostring(player.UserId))
	end)

	if success and result then
		customNametags[player.UserId] = result
		log("? Loaded custom nametag for " .. player.Name .. ": " .. result)
	end
end

-- Fungsi untuk save custom nametag ke DataStore
local function saveCustomNametag(player, nametagText)
	local success, error = pcall(function()
		nametagStore:SetAsync(tostring(player.UserId), nametagText)
	end)

	if success then
		customNametags[player.UserId] = nametagText
		log("? Saved custom nametag for " .. player.Name .. ": " .. nametagText)
	else
		warn("? Failed to save custom nametag for " .. player.Name .. ": " .. tostring(error))
	end
end

-- Fungsi untuk mendapatkan konfigurasi rank (DIMODIFIKASI UNTUK SPECIAL USERS)
local function getRankConfig(player)
	-- Check for special users first
	if SPECIAL_USERS[player.Name] then
		return SPECIAL_USERS[player.Name]
	end

	local playerRank = getPlayerRankFromUnifiedSystem(player)

	-- Pastikan rank valid
	if playerRank and RANK_CONFIGS[playerRank] then
		return RANK_CONFIGS[playerRank]
	end

	-- Default ke Guest jika tidak valid
	return RANK_CONFIGS["Guest"]
end

-- Fungsi untuk mengatur team pemain
local function setPlayerTeam(player, teamName)
	local team = Teams:FindFirstChild(teamName)
	if team then
		player.Team = team
		log("? Set " .. player.Name .. " to team: " .. teamName)
	else
		warn("? Team not found: " .. teamName)
	end
end

-- Fungsi untuk cek apakah pemain adalah Admin
local function isAdmin(player)
	if isOwner(player) then
		return true
	end

	for _, adminName in ipairs(ADMINS) do
		if string.lower(player.Name) == string.lower(adminName) then
			return true
		end
	end
	return false
end

-- UPDATED: Enhanced nametag update function with multi-logo support and gradient animation
local function updatePlayerNametag(player)
	if not player or not player.Parent then
		return
	end

	if not player.Character or not player.Character:FindFirstChild("Head") then
		return
	end

	local head = player.Character.Head
	local humanoid = player.Character:FindFirstChild("Humanoid")

	-- FORCE DISABLE DEFAULT ROBLOX NAMETAG
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	-- DEBOUNCE: Prevent rapid-fire updates
	if player:GetAttribute("UpdatingNametag") then
		return
	end
	player:SetAttribute("UpdatingNametag", true)

	-- CLEANUP: Head AND HumanoidRootPart
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	local targets = { head, rootPart }

	for _, target in pairs(targets) do
		if target then
			for _, child in pairs(target:GetChildren()) do
				if child:IsA("BillboardGui") then
					child:Destroy()
				end
			end
		end
	end

	if not nametag then
		warn("? NameTag template not found in ReplicatedStorage!")
		player:SetAttribute("UpdatingNametag", nil)
		return
	end

	-- Dapatkan konfigurasi rank dari Unified System atau Special Users
	local config = getRankConfig(player)

	-- Cek custom nametag
	local nametagText = config.text
	if customNametags[player.UserId] then
		nametagText = customNametags[player.UserId]
	end

	local success, newtext = pcall(function()
		return nametag:Clone()
	end)

	if not success or not newtext then
		warn("? Failed to clone nametag template")
		player:SetAttribute("UpdatingNametag", nil)
		return
	end

	-- Setup nametag elements
	local uppertext = newtext:FindFirstChild("UpperText") -- Display Name (Middle)
	local lowertext = newtext:FindFirstChild("LowerText") -- Custom Name (Top)

	-- Create RankLabel (Bottom) if it doesn't exist
	local rankLabel = newtext:FindFirstChild("RankLabel")
	if not rankLabel then
		rankLabel = Instance.new("TextLabel")
		rankLabel.Name = "RankLabel"
		rankLabel.BackgroundTransparency = 1
		rankLabel.Parent = newtext
	end

	-- Clean up undefined/extra text labels (Strict Instance Check)
	-- This removes "Dummy", duplicates, or any other unauthorized label
	for _, child in pairs(newtext:GetDescendants()) do
		if child:IsA("TextLabel") then
			-- Destroy if it's not one of our active labels
			if child ~= uppertext and child ~= lowertext and child ~= rankLabel then
				child:Destroy()
				log("??? Removed nested artifact: " .. child.Name)
			end
		end
	end

	if not uppertext or not lowertext then
		newtext:Destroy()
		player:SetAttribute("UpdatingNametag", nil)
		warn("? NameTag template missing UpperText or LowerText")
		return
	end

	-- Apply nametag structure: 3 Layers
	newtext.Name = "OfficialNametag"
	newtext.Parent = head
	newtext.Adornee = head

	-- Clear debounce
	player:SetAttribute("UpdatingNametag", nil)

	-- Log layout debugging
	log("?? Updating layout for " .. player.Name .. " | Rank: " .. tostring(config.text))

	-- ACTIVE DEFENSE: Monitor Head for unwanted BillboardGuis
	-- This will kill any ghost tags that try to spawn after we run
	local existingConnection = player:GetAttribute("NametagDefenseConnection")
	if not existingConnection then -- Only connect once
		local connection = head.ChildAdded:Connect(function(child)
			task.wait() -- Small wait to let it property set
			if child:IsA("BillboardGui") and child.Name ~= "OfficialNametag" then
				log("??? Defense System: Destroyed unauthorized BillboardGui: " .. child.Name)
				child:Destroy()
			end
		end)
		player:SetAttribute("NametagDefenseConnection", true) -- Mark as connected (ideally we should store the connection to disconnect later, but for now this prevents double-connect logic logic if we stored it in valid way)
		-- Note: In a real robust system we'd manage the connection object properly.
	end

	-- Force check other body parts just in case
	local bodyParts = player.Character:GetChildren()
	for _, part in pairs(bodyParts) do
		if part:IsA("BasePart") and part.Name ~= "Head" and part.Name ~= "HumanoidRootPart" then
			for _, child in pairs(part:GetChildren()) do
				if child:IsA("BillboardGui") then
					log("?? Found BillboardGui on " .. part.Name .. ", destroying...")
					child:Destroy()
				end
			end
		end
	end

	-- FORCE RESET PROPERTIES (To fix alignment and "Staff" drifting)
	local labels = { uppertext, lowertext, rankLabel }
	for _, label in pairs(labels) do
		label.Size = UDim2.new(1, 0, 0.33, 0)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextXAlignment = Enum.TextXAlignment.Center -- Force Center
		label.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	-- POSITIONING (Strict)
	lowertext.Position = UDim2.new(0.5, 0, 0.165, 0) -- Top (Centered Anchor)
	uppertext.Position = UDim2.new(0.5, 0, 0.5, 0) -- Middle (Centered Anchor)
	rankLabel.Position = UDim2.new(0.5, 0, 0.835, 0) -- Bottom (Centered Anchor)

	-- SIZING (Adjusted to fit 3 lines)
	lowertext.Size = UDim2.new(1, 0, 0.33, 0)
	uppertext.Size = UDim2.new(1, 0, 0.33, 0)
	rankLabel.Size = UDim2.new(1, 0, 0.33, 0)

	-- ALIGNMENT (Force Center)
	lowertext.TextXAlignment = Enum.TextXAlignment.Center
	uppertext.TextXAlignment = Enum.TextXAlignment.Center
	rankLabel.TextXAlignment = Enum.TextXAlignment.Center

	-- CONTENT & COLOR

	-- 1. Custom Name (Top)
	if customNametags[player.UserId] then
		lowertext.Text = customNametags[player.UserId]
		lowertext.Visible = true
		lowertext.TextColor3 = Color3.new(1, 1, 1) -- Default white for custom name? Or keep rank color?
		-- Usually custom names act as titles, maybe keep them white or gold.
		-- Let's use a nice default or maybe the rank color?
		-- Plan said: "FOUNDER" (Warna Custom). Let's use rank color for consistency or maybe white?
		-- implementation_plan said: "Warna Custom".
		-- Let's stick to White for now to differentiate from Rank, or specific colors if defined.
		-- Actually previous code used config.color for lowertext.
		lowertext.TextColor3 = config.color -- Use rank color for custom title as well for now
	else
		lowertext.Text = ""
		lowertext.Visible = false -- Hide if no custom name
	end

	-- 2. Display Name (Middle)
	uppertext.Text = player.DisplayName
	uppertext.TextColor3 = Color3.new(1, 1, 1) -- White for Name

	-- 3. Rank Name (Bottom)
	rankLabel.Text = config.text
	rankLabel.TextColor3 = config.color

	-- Special overrides from Special Users
	if SPECIAL_USERS[player.Name] then
		rankLabel.TextColor3 = config.color
		lowertext.TextColor3 = config.color
	end

	-- NEW: Start gradient animations for any UIGradient elements in the nametag
	for _, descendant in pairs(newtext:GetDescendants()) do
		if descendant:IsA("UIGradient") then
			startGradientAnimation(descendant)
		end
	end

	-- UPDATED: Multi-Logo System - Hide all logos first, then show player's logo
	local playerLogo = playerLogos[player.UserId]

	-- Step 1: Hide all logos
	for logoType, logoConfig in pairs(LOGO_CONFIGS) do
		if logoConfig.enabled then
			local logoElement = newtext:FindFirstChild(logoConfig.elementName)
			if logoElement then
				logoElement.Visible = false
				log("?? Hidden " .. logoConfig.elementName .. " logo")
			else
				warn("?? Logo element " .. logoConfig.elementName .. " not found in template")
			end
		end
	end

	-- Step 2: Show the player's specific logo if they have one
	if playerLogo and LOGO_CONFIGS[playerLogo] and LOGO_CONFIGS[playerLogo].enabled then
		local logoConfig = LOGO_CONFIGS[playerLogo]
		local logoElement = newtext:FindFirstChild(logoConfig.elementName)

		if logoElement then
			logoElement.Visible = true
			log("? Showed " .. logoConfig.elementName .. " logo for " .. player.Name)
		else
			warn("? " .. logoConfig.elementName .. " ImageLabel not found in nametag template")
		end
	else
		log("?? No logo or invalid logo for " .. player.Name)
	end

	-- Log with information
	if SPECIAL_USERS[player.Name] then
		log("? Updated SPECIAL nametag for " .. player.Name .. " (" .. config.text .. ") with special color")
	else
		log("? Updated nametag for " .. player.Name .. " (" .. config.text .. ")")
	end

	if playerLogo then
		log("?? Logo active: " .. playerLogo .. " for " .. player.Name)
	end
end

-- NEW: Logo command handler
local function handleLogoCommand(player, message)
	if not isAdmin(player) then
		return
	end

	local parts = string.split(message, " ")
	if #parts < 3 then
		log("? Usage: !setlogo username logoType")
		log("Available logos: " .. table.concat(getAvailableLogos(), ", "))
		return
	end

	local targetUsername = parts[2]
	local logoType = string.lower(parts[3])

	-- Special case for "none" or "remove"
	if logoType == "none" or logoType == "remove" then
		logoType = nil
	end

	-- Validate logo type
	if logoType and (not LOGO_CONFIGS[logoType] or not LOGO_CONFIGS[logoType].enabled) then
		log("? Invalid logo type: " .. logoType)
		log("Available logos: " .. table.concat(getAvailableLogos(), ", "))
		return
	end

	-- Find target player
	local targetPlayer = nil
	for _, p in pairs(Players:GetPlayers()) do
		if
			string.lower(p.Name) == string.lower(targetUsername)
			or string.lower(p.DisplayName) == string.lower(targetUsername)
		then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then
		log("? Player not found: " .. targetUsername)
		return
	end

	-- Set logo
	if savePlayerLogo(targetPlayer, logoType) then
		updatePlayerNametag(targetPlayer)
		if logoType then
			log("? Set logo for " .. targetPlayer.Name .. ": " .. logoType)
		else
			log("? Removed logo for " .. targetPlayer.Name)
		end
	else
		log("? Failed to set logo for " .. targetPlayer.Name)
	end
end

-- NEW: Function to get available logos
function getAvailableLogos()
	local logos = {}
	for logoType, config in pairs(LOGO_CONFIGS) do
		if config.enabled then
			table.insert(logos, logoType)
		end
	end
	return logos
end

-- NEW: List logos command
local function handleListLogosCommand(player, message)
	if not isAdmin(player) then
		return
	end

	log("?? Available Logos:")
	for logoType, config in pairs(LOGO_CONFIGS) do
		local status = config.enabled and "? ENABLED" or "? DISABLED"
		log("  " .. logoType .. " (Element: " .. config.elementName .. "): " .. status)
	end
end

-- NEW: Check player logo command
local function handleCheckLogoCommand(player, message)
	if not isAdmin(player) then
		return
	end

	local parts = string.split(message, " ")
	if #parts < 2 then
		log("? Usage: !checklogo username")
		return
	end

	local targetUsername = parts[2]
	local targetPlayer = nil

	for _, p in pairs(Players:GetPlayers()) do
		if
			string.lower(p.Name) == string.lower(targetUsername)
			or string.lower(p.DisplayName) == string.lower(targetUsername)
		then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then
		log("? Player not found: " .. targetUsername)
		return
	end

	local playerLogo = playerLogos[targetPlayer.UserId]
	local rank = getPlayerRankFromUnifiedSystem(targetPlayer)
	local config = getRankConfig(targetPlayer)

	log("?? " .. targetPlayer.Name .. "'s info:")
	log("  Current Rank: " .. rank)
	log("  Team: " .. (targetPlayer.Team and targetPlayer.Team.Name or "None"))
	log("  Custom Nametag: " .. (customNametags[targetPlayer.UserId] or "None"))
	log("  Logo: " .. (playerLogo or "None"))
	if playerLogo then
		local logoConfig = LOGO_CONFIGS[playerLogo]
		if logoConfig then
			log("  Logo Element: " .. logoConfig.elementName)
			log("  Logo Status: ? VALID")
		else
			log("  Logo Status: ? INVALID")
		end
	end
	log("  Rank Color: " .. tostring(config.color))

	-- Check if special user
	if SPECIAL_USERS[targetPlayer.Name] then
		log("  ? SPECIAL USER with custom color!")
	end
end

-- Command handlers
local function handleNametagCommand(player, message)
	if not isAdmin(player) then
		return
	end

	local parts = string.split(message, " ")
	if #parts < 3 then
		log("? Usage: !nametag username text")
		return
	end

	local targetUsername = parts[2]
	local newNametagText = table.concat(parts, " ", 3)

	-- Find target player
	local targetPlayer = nil
	for _, p in pairs(Players:GetPlayers()) do
		if
			string.lower(p.Name) == string.lower(targetUsername)
			or string.lower(p.DisplayName) == string.lower(targetUsername)
		then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then
		log("? Player not found: " .. targetUsername)
		return
	end

	-- Set custom nametag
	saveCustomNametag(targetPlayer, newNametagText)
	updatePlayerNametag(targetPlayer)

	log("? Set custom nametag for " .. targetPlayer.Name .. ": " .. newNametagText)
end

-- Connect to Unified PlayerRanks System
local function connectToUnifiedSystem()
	-- Listen for rank changes via RankChanged event
	RankChangedEvent.OnServerEvent:Connect(function(player, newRank)
		log("?? Rank changed for " .. player.Name .. " to: " .. newRank)

		-- Only update nametag here
		task.spawn(function()
			task.wait(0.5)
			updatePlayerNametag(player)
		end)
	end)

	log("? Connected to Unified PlayerRanks System")
end

-- Global function for manual nametag updates
_G.UpdatePlayerNametag = updatePlayerNametag

-- Player events
Players.PlayerAdded:Connect(function(player)
	log("Player joined: " .. player.Name)

	-- Check if special user
	if SPECIAL_USERS[player.Name] then
		log("? Special user detected: " .. player.Name .. " (Special color)")
	end

	-- Load custom nametag and logo
	loadCustomNametag(player)
	loadPlayerLogo(player)

	-- Handle chat commands
	player.Chatted:Connect(function(message)
		local lowerMessage = string.lower(message)
		if string.sub(lowerMessage, 1, 9) == "!nametag " then
			handleNametagCommand(player, message)
		elseif string.sub(lowerMessage, 1, 9) == "!setlogo " then
			handleLogoCommand(player, message)
		elseif string.sub(lowerMessage, 1, 11) == "!listlogos" then
			handleListLogosCommand(player, message)
		elseif string.sub(lowerMessage, 1, 11) == "!checklogo " then
			handleCheckLogoCommand(player, message)
		end
	end)

	-- Handle character spawn
	player.CharacterAdded:Connect(function(char)
		local head = char:WaitForChild("Head")
		local humanoid = char:WaitForChild("Humanoid")

		-- Disable default nametag
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		-- Update nametag with delay
		task.spawn(function()
			task.wait(1)
			updatePlayerNametag(player)
		end)
	end)

	-- Handle existing character
	if player.Character and player.Character:FindFirstChild("Head") then
		task.spawn(function()
			task.wait(1)
			updatePlayerNametag(player)
		end)
	end
end)

-- Player leaving cleanup
Players.PlayerRemoving:Connect(function(player)
	-- Clean up custom data
	if customNametags[player.UserId] then
		customNametags[player.UserId] = nil
	end
	if playerLogos[player.UserId] then
		playerLogos[player.UserId] = nil
	end

	-- Clean up gradient animations
	if player.Character and player.Character:FindFirstChild("Head") then
		local nametag = player.Character.Head:FindFirstChild("NameTag")
		if nametag then
			for _, descendant in pairs(nametag:GetDescendants()) do
				if descendant:IsA("UIGradient") then
					stopGradientAnimation(descendant)
				end
			end
		end
	end

	log("Player left: " .. player.Name)
end)

-- Initialize system
local function initializeNametagSystem()
	log("=== NAMETAG SYSTEM WITH MULTI-LOGO SUPPORT AND GRADIENT ANIMATION INITIALIZING ===")

	-- Load all player logos on startup
	for _, player in pairs(Players:GetPlayers()) do
		loadPlayerLogo(player)
		loadCustomNametag(player)
	end

	-- Connect to Unified System
	task.spawn(function()
		for i = 1, 5 do
			task.wait(i)
			if _G.GetPlayerRank then
				connectToUnifiedSystem()
				break
			else
				log("? Waiting for Unified PlayerRanks System... attempt " .. i)
			end
		end
	end)

	-- Handle existing players
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Head") then
			task.spawn(function()
				task.wait(1)
				updatePlayerNametag(player)
			end)
		end
	end

	log("=== NAMETAG SYSTEM WITH MULTI-LOGO SUPPORT AND GRADIENT ANIMATION READY ===")
	log("? Available logos: " .. table.concat(getAvailableLogos(), ", "))
	log("?? Gradient animations enabled for all nametag elements")

	-- Log logo element mappings
	log("?? Logo Element Mappings:")
	for logoType, config in pairs(LOGO_CONFIGS) do
		if config.enabled then
			log("  " .. logoType .. " ? " .. config.elementName)
		end
	end
end

-- Global functions for logo management
_G.CustomNametags = customNametags
_G.PlayerLogos = playerLogos
_G.SetPlayerLogo = savePlayerLogo
_G.GetPlayerLogo = function(player)
	return playerLogos[player.UserId]
end

-- Function untuk trigger logo update dari external systems
_G.TriggerLogoUpdate = function(player, logoType)
	if savePlayerLogo(player, logoType) then
		task.spawn(function()
			task.wait(0.1)
			updatePlayerNametag(player)
		end)
		return true
	end
	return false
end

-- Enhanced global function yang bisa reload data
_G.UpdatePlayerNametag = function(player)
	loadCustomNametag(player)
	loadPlayerLogo(player)
	task.wait(0.1)
	updatePlayerNametag(player)
end

-- NEW: Global functions for gradient animation control
_G.StartNametagGradientAnimation = startGradientAnimation
_G.StopNametagGradientAnimation = stopGradientAnimation

-- Remote Events
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:FindFirstChild("Events")

if Events then
	-- Event untuk logo update
	local logoUpdateEvent = Events:FindFirstChild("LogoUpdate")
	if not logoUpdateEvent then
		logoUpdateEvent = Instance.new("RemoteEvent")
		logoUpdateEvent.Name = "LogoUpdate"
		logoUpdateEvent.Parent = Events
	end

	-- Handle logo update dari command
	logoUpdateEvent.OnServerEvent:Connect(function(sender, targetPlayer, logoType)
		if targetPlayer then
			if savePlayerLogo(targetPlayer, logoType) then
				task.spawn(function()
					task.wait(0.1)
					updatePlayerNametag(targetPlayer)
				end)
			end
		end
	end)
end
-- == Admin Remote Bindings ==
local EventsFolder = rep:FindFirstChild("Events")
if not EventsFolder then
	EventsFolder = Instance.new("Folder")
	EventsFolder.Name = "Events"
	EventsFolder.Parent = rep
end

local SetNametagEvent = EventsFolder:FindFirstChild("SetNametag")
if not SetNametagEvent then
	SetNametagEvent = Instance.new("RemoteEvent")
	SetNametagEvent.Name = "SetNametag"
	SetNametagEvent.Parent = EventsFolder
end

local IsAdminFn = rep:FindFirstChild("IsAdmin")
if not IsAdminFn then
	IsAdminFn = Instance.new("RemoteFunction")
	IsAdminFn.Name = "IsAdmin"
	IsAdminFn.Parent = rep
end

IsAdminFn.OnServerInvoke = function(player)
	return isAdmin(player)
end

SetNametagEvent.OnServerEvent:Connect(function(sender, targetIdentifier, newNametagText)
	if not isAdmin(sender) then
		warn("[SetNametag] Non-admin attempted to call SetNametag: " .. sender.Name)
		return
	end

	local targetPlayer = nil
	if type(targetIdentifier) == "number" then
		targetPlayer = Players:GetPlayerByUserId(targetIdentifier)
	elseif type(targetIdentifier) == "string" then
		local key = string.lower(targetIdentifier)
		for _, p in pairs(Players:GetPlayers()) do
			if string.lower(p.Name) == key or string.lower(p.DisplayName) == key then
				targetPlayer = p
				break
			end
		end
	end

	if not targetPlayer then
		warn("[SetNametag] Target player not found: " .. tostring(targetIdentifier))
		return
	end

	if newNametagText == nil or newNametagText == "" then
		saveCustomNametag(targetPlayer, nil)
		updatePlayerNametag(targetPlayer)
		log("[SetNametag] Removed custom nametag for " .. targetPlayer.Name .. " by " .. sender.Name)
	else
		saveCustomNametag(targetPlayer, newNametagText)
		updatePlayerNametag(targetPlayer)
		log("[SetNametag] Set '" .. tostring(newNametagText) .. "' for " .. targetPlayer.Name .. " by " .. sender.Name)
	end
end)
-- Start the system
initializeNametagSystem()

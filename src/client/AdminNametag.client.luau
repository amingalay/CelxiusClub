-- src/client/AdminNametag.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local function tryCreateAdminUI()
	local isAdminFn = ReplicatedStorage:WaitForChild("IsAdmin", 5)
	local ok, isAdmin = pcall(function()
		return isAdminFn:InvokeServer()
	end)
	if not ok or not isAdmin then
		return
	end

	-- Basic GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminNametagGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.Size = UDim2.new(0, 320, 0, 200)
	frame.Position = UDim2.new(0, 10, 0.2, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Parent = frame
	title.Size = UDim2.new(1, 0, 0, 28)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Admin — Custom Nametag"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16

	local targetBox = Instance.new("TextBox")
	targetBox.Parent = frame
	targetBox.Size = UDim2.new(1, -20, 0, 28)
	targetBox.Position = UDim2.new(0, 10, 0, 36)
	targetBox.PlaceholderText = "Target username or displayname"
	targetBox.ClearTextOnFocus = false

	local titleBox = Instance.new("TextBox")
	titleBox.Parent = frame
	titleBox.Size = UDim2.new(1, -20, 0, 28)
	titleBox.Position = UDim2.new(0, 10, 0, 72)
	titleBox.PlaceholderText = "Custom title (leave blank to remove)"
	titleBox.ClearTextOnFocus = false

	local setBtn = Instance.new("TextButton")
	setBtn.Parent = frame
	setBtn.Size = UDim2.new(0.5, -15, 0, 32)
	setBtn.Position = UDim2.new(0, 10, 0, 110)
	setBtn.Text = "Set Title"
	setBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	setBtn.TextColor3 = Color3.new(1, 1, 1)

	local removeBtn = Instance.new("TextButton")
	removeBtn.Parent = frame
	removeBtn.Size = UDim2.new(0.5, -15, 0, 32)
	removeBtn.Position = UDim2.new(0.5, 5, 0, 110)
	removeBtn.Text = "Remove"
	removeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	removeBtn.TextColor3 = Color3.new(1, 1, 1)

	local feedback = Instance.new("TextLabel")
	feedback.Parent = frame
	feedback.Size = UDim2.new(1, -20, 0, 40)
	feedback.Position = UDim2.new(0, 10, 0, 150)
	feedback.BackgroundTransparency = 1
	feedback.TextColor3 = Color3.fromRGB(220, 220, 220)
	feedback.TextWrapped = true
	feedback.Text = ""

	local Events = ReplicatedStorage:WaitForChild("Events")
	local SetNametagEvent = Events:WaitForChild("SetNametag")

	local function resolveIdentifier(input)
		if tonumber(input) then
			return tonumber(input)
		end
		local key = string.lower(input)
		for _, p in pairs(Players:GetPlayers()) do
			if string.lower(p.Name) == key or string.lower(p.DisplayName) == key then
				return p.UserId
			end
		end
		return input
	end

	setBtn.MouseButton1Click:Connect(function()
		local target = targetBox.Text
		local text = titleBox.Text
		if target == "" then
			feedback.Text = "Masukkan username/displayname target."
			return
		end
		local id = resolveIdentifier(target)
		SetNametagEvent:FireServer(id, text)
		feedback.Text = "Mengirim permintaan set title..."
	end)

	removeBtn.MouseButton1Click:Connect(function()
		local target = targetBox.Text
		if target == "" then
			feedback.Text = "Masukkan username/displayname target."
			return
		end
		local id = resolveIdentifier(target)
		SetNametagEvent:FireServer(id, nil)
		feedback.Text = "Mengirim permintaan remove..."
	end)
end

-- Init when PlayerGui available
if player and player:FindFirstChild("PlayerGui") then
	tryCreateAdminUI()
else
	player.ChildAdded:Connect(function(child)
		if child.Name == "PlayerGui" then
			tryCreateAdminUI()
		end
	end)
end

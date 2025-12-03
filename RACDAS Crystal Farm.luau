local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId

getgenv().crystalOn = false
getgenv().crystals = {}

local function addCrystal(v)
	if v:IsA("BasePart") and v.Name:lower():find("crystal") then
		table.insert(getgenv().crystals, v)
	end
end

local function removeCrystal(v)
	for i, part in ipairs(getgenv().crystals) do
		if part == v then
			table.remove(getgenv().crystals, i)
			break
		end
	end
end

for _, v in ipairs(workspace:GetDescendants()) do
	addCrystal(v)
end

workspace.DescendantAdded:Connect(addCrystal)
workspace.DescendantRemoving:Connect(removeCrystal)

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 70)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame)

local dragging, dragStart, startPos = false, nil, nil
local UIS = game:GetService("UserInputService")
frame.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = frame.Position
	end
end)
frame.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

local function newButton(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 150, 0, 40)
	b.Position = UDim2.new(0, 15, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.Text = text .. ": OFF"
	b.Parent = frame
	Instance.new("UICorner", b)
	return b
end

local crystalBtn = newButton("Crystals", 15)
crystalBtn.MouseButton1Click:Connect(function()
	getgenv().crystalOn = not getgenv().crystalOn
	crystalBtn.Text = "Crystals: " .. (getgenv().crystalOn and "ON" or "OFF")
end)

local function tpTo(part)
	if not part then return end
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1, 0))
end

-- main loop
task.spawn(function()
	while true do
		if getgenv().crystalOn then
			if #getgenv().crystals == 0 then
				if syn then
					syn.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/user/script.lua'))()")
				end
				TeleportService:Teleport(PLACE_ID, LocalPlayer)
				break
			end
			for _, v in ipairs(getgenv().crystals) do
				if not getgenv().crystalOn then break end
				if v and v.Parent then
					tpTo(v)
					task.wait(0.05)
				end
			end
		end
		task.wait()
	end
end)

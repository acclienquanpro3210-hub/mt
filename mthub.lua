--===================================
-- MtScript HUB | Delta Executor
-- KEY | FPS | AIMLOCK | ESP | FIXLAG
--===================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local MANUAL_KEY = "mtruongscriptroblox"
local unlocked = false

local FPS_ON, FIX_ON, ESP_ON, AIM_ON = false, false, false, false
local AIM_FOV = 120

-- ===== GUI =====
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "MtScriptHub"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,460,0,300)
main.Position = UDim2.new(0.5,-230,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active, main.Draggable = true, true

-- ===== TITLE =====
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-20,0,30)
title.Position = UDim2.new(0,10,0,10)
title.BackgroundTransparency = 1
title.Text = "MtScript"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 26
title.TextColor3 = Color3.fromRGB(0,170,255)

-- ===== TABS =====
local tabs = {"KEY","FPS","AIMLOCK","ESP","FIXLAG"}
local pages, tabBtns = {}, {}

local function createTab(name, index)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(0,85,0,28)
	b.Position = UDim2.new(0,10+(index*90),0,50)
	b.Text = name
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)

	local p = Instance.new("Frame", main)
	p.Size = UDim2.new(1,-20,1,-100)
	p.Position = UDim2.new(0,10,0,90)
	p.BackgroundTransparency = 1
	p.Visible = false

	b.MouseButton1Click:Connect(function()
		for _,pg in pairs(pages) do pg.Visible = false end
		p.Visible = true
	end)

	tabBtns[name] = b
	pages[name] = p
end

for i,t in ipairs(tabs) do
	createTab(t,i-1)
end
pages.KEY.Visible = true

-- ===== KEY PAGE =====
local keyBox = Instance.new("TextBox", pages.KEY)
keyBox.Size = UDim2.new(0,220,0,40)
keyBox.PlaceholderText = "Enter Key"
keyBox.ClearTextOnFocus = false
keyBox.Text = ""

local keyBtn = Instance.new("TextButton", pages.KEY)
keyBtn.Size = UDim2.new(0,140,0,40)
keyBtn.Position = UDim2.new(0,230,0,0)
keyBtn.Text = "UNLOCK"

keyBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == MANUAL_KEY then
		unlocked = true
		keyBtn.Text = "UNLOCKED"
	else
		keyBtn.Text = "WRONG KEY"
	end
end)

-- ===== TOGGLE BUTTON HELPER =====
local function toggleBtn(parent, y, text, callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,220,0,40)
	b.Position = UDim2.new(0,0,0,y)
	b.Text = text..": OFF"
	b.MouseButton1Click:Connect(function()
		if not unlocked then b.Text = "LOCKED"; return end
		local on = callback()
		b.Text = text..": "..(on and "ON" or "OFF")
	end)
end

-- ===== FPS =====
toggleBtn(pages.FPS,0,"FPS BOOST",function()
	FPS_ON = not FPS_ON
	if FPS_ON then
		Lighting.GlobalShadows = false
		Lighting.Brightness = 1
	end
	return FPS_ON
end)

-- ===== FIX LAG =====
toggleBtn(pages.FIXLAG,0,"FIX LAG",function()
	FIX_ON = not FIX_ON
	if FIX_ON then
		for _,v in ipairs(Lighting:GetChildren()) do
			if v:IsA("BloomEffect") or v:IsA("BlurEffect")
			or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
				v:Destroy()
			end
		end
		for _,v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail")
			or v:IsA("Smoke") or v:IsA("Fire") then
				v.Enabled = false
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("BasePart") then
				v.Material = Enum.Material.Plastic
			end
		end
	end
	return FIX_ON
end)

-- ===== ESP =====
local ESP = {}
local function addESP(p)
	if p == LP then return end
	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Color = Color3.fromRGB(255,80,80)
	ESP[p] = box
end

for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(function(p)
	if ESP[p] then ESP[p]:Remove(); ESP[p] = nil end
end)

toggleBtn(pages.ESP,0,"ESP",function()
	ESP_ON = not ESP_ON
	return ESP_ON
end)

RunService.RenderStepped:Connect(function()
	if not ESP_ON then
		for _,b in pairs(ESP) do b.Visible = false end
		return
	end
	for p,b in pairs(ESP) do
		local c = p.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos,on = Camera:WorldToViewportPoint(hrp.Position)
			b.Visible = on
			if on then
				b.Size = Vector2.new(40,60)
				b.Position = Vector2.new(pos.X-20,pos.Y-30)
			end
		else
			b.Visible = false
		end
	end
end)

-- ===== AIMLOCK =====
local function getTarget()
	local best, dist = nil, AIM_FOV
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
			local v,on = Camera:WorldToViewportPoint(p.Character.Head.Position)
			if on then
				local d = (Vector2.new(v.X,v.Y) -
					Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
				if d < dist then
					dist = d
					best = p.Character.Head
				end
			end
		end
	end
	return best
end

toggleBtn(pages.AIMLOCK,0,"AIMLOCK",function()
	AIM_ON = not AIM_ON
	return AIM_ON
end)

RunService.RenderStepped:Connect(function()
	if AIM_ON then
		local t = getTarget()
		if t then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
		end
	end
end)
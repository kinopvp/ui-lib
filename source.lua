local UILibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
UILibrary.config = {
	toggleKey = Enum.KeyCode.Insert,
	animationSpeed = 0.25,
	theme = {
		accent = Color3.fromRGB(138, 43, 226),
		background = Color3.fromRGB(25, 25, 35),
		secondary = Color3.fromRGB(35, 35, 50),
		tertiary = Color3.fromRGB(45, 45, 65),
		text = Color3.fromRGB(240, 240, 245),
		textDim = Color3.fromRGB(160, 160, 175),
		border = Color3.fromRGB(60, 60, 80)
	}
}

UILibrary.state = {
	isOpen = false,
	isDragging = false,
	isResizing = false,
	currentTab = nil
}

getgenv().UILibInstance = getgenv().UILibInstance or math.random(1000000, 9999999)

-- Utility Functions
local function createTween(instance, properties, duration)
	local tweenInfo = TweenInfo.new(duration or UILibrary.config.animationSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	return TweenService:Create(instance, tweenInfo, properties)
end

local function applyCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
	return corner
end

local function applyStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

local function applyGradient(instance, colors)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colors)
	gradient.Rotation = 90
	gradient.Parent = instance
	return gradient
end

-- Set Toggle Key
function UILibrary:setToggleKey(keyCode)
	self.config.toggleKey = keyCode
end

-- Set Theme
function UILibrary:setTheme(themeName)
	local themes = {
		purple = {
			accent = Color3.fromRGB(138, 43, 226),
			background = Color3.fromRGB(25, 25, 35),
			secondary = Color3.fromRGB(35, 35, 50),
			tertiary = Color3.fromRGB(45, 45, 65),
			text = Color3.fromRGB(240, 240, 245),
			textDim = Color3.fromRGB(160, 160, 175),
			border = Color3.fromRGB(60, 60, 80)
		},
		ocean = {
			accent = Color3.fromRGB(0, 168, 255),
			background = Color3.fromRGB(15, 25, 35),
			secondary = Color3.fromRGB(25, 35, 50),
			tertiary = Color3.fromRGB(35, 50, 70),
			text = Color3.fromRGB(240, 245, 250),
			textDim = Color3.fromRGB(150, 170, 190),
			border = Color3.fromRGB(50, 70, 90)
		},
		ember = {
			accent = Color3.fromRGB(255, 82, 82),
			background = Color3.fromRGB(30, 20, 20),
			secondary = Color3.fromRGB(45, 30, 30),
			tertiary = Color3.fromRGB(60, 40, 40),
			text = Color3.fromRGB(255, 240, 240),
			textDim = Color3.fromRGB(180, 160, 160),
			border = Color3.fromRGB(80, 60, 60)
		}
	}
	
	if themes[themeName] then
		self.config.theme = themes[themeName]
	end
end

-- Create Main UI
function UILibrary:createWindow(title)
	if game.CoreGui:FindFirstChild("ModernUILib_" .. getgenv().UILibInstance) then
		game.CoreGui:FindFirstChild("ModernUILib_" .. getgenv().UILibInstance):Destroy()
	end
	
	local theme = self.config.theme
	
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ModernUILib_" .. getgenv().UILibInstance
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = game.CoreGui
	
	-- Background Blur
	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "BlurFrame"
	blurFrame.Size = UDim2.fromScale(1, 1)
	blurFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	blurFrame.BackgroundTransparency = 0.5
	blurFrame.BorderSizePixel = 0
	blurFrame.Parent = screenGui
	
	-- Main Window
	local mainWindow = Instance.new("Frame")
	mainWindow.Name = "MainWindow"
	mainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
	mainWindow.Position = UDim2.fromScale(0.5, 0.5)
	mainWindow.Size = UDim2.fromOffset(700, 450)
	mainWindow.BackgroundColor3 = theme.background
	mainWindow.BorderSizePixel = 0
	mainWindow.ClipsDescendants = false
	mainWindow.Parent = screenGui
	
	applyCorner(mainWindow, 12)
	applyStroke(mainWindow, theme.border, 1)
	
	-- Drop Shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.fromScale(0.5, 0.5)
	shadow.Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(40, 40)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554236805"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	shadow.ZIndex = 0
	shadow.Parent = mainWindow
	
	-- Top Bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3 = theme.secondary
	topBar.BorderSizePixel = 0
	topBar.Parent = mainWindow
	
	applyCorner(topBar, 12)
	
	-- Fix bottom corners of top bar
	local topBarCover = Instance.new("Frame")
	topBarCover.AnchorPoint = Vector2.new(0, 1)
	topBarCover.Position = UDim2.fromScale(0, 1)
	topBarCover.Size = UDim2.new(1, 0, 0, 12)
	topBarCover.BackgroundColor3 = theme.secondary
	topBarCover.BorderSizePixel = 0
	topBarCover.Parent = topBar
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Position = UDim2.fromOffset(20, 0)
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "Modern UI"
	titleLabel.TextColor3 = theme.text
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = topBar
	
	-- Accent Bar
	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Position = UDim2.fromOffset(0, 0)
	accentBar.Size = UDim2.new(1, 0, 0, 3)
	accentBar.BackgroundColor3 = theme.accent
	accentBar.BorderSizePixel = 0
	accentBar.Parent = topBar
	
	applyGradient(accentBar, {theme.accent, theme.accent:Lerp(Color3.new(1, 1, 1), 0.3)})
	
	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -15, 0.5, 0)
	closeBtn.Size = UDim2.fromOffset(30, 30)
	closeBtn.BackgroundColor3 = theme.tertiary
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "×"
	closeBtn.TextColor3 = theme.text
	closeBtn.TextSize = 24
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = topBar
	
	applyCorner(closeBtn, 6)
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
		self.state.isOpen = false
	end)
	
	closeBtn.MouseEnter:Connect(function()
		createTween(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
	end)
	
	closeBtn.MouseLeave:Connect(function()
		createTween(closeBtn, {BackgroundColor3 = theme.tertiary}):Play()
	end)
	
	-- Navigation Panel
	local navPanel = Instance.new("Frame")
	navPanel.Name = "NavPanel"
	navPanel.Position = UDim2.fromOffset(0, 50)
	navPanel.Size = UDim2.new(0, 160, 1, -50)
	navPanel.BackgroundColor3 = theme.secondary
	navPanel.BorderSizePixel = 0
	navPanel.Parent = mainWindow
	
	local navList = Instance.new("UIListLayout")
	navList.Padding = UDim.new(0, 8)
	navList.SortOrder = Enum.SortOrder.LayoutOrder
	navList.Parent = navPanel
	
	local navPadding = Instance.new("UIPadding")
	navPadding.PaddingTop = UDim.new(0, 15)
	navPadding.PaddingLeft = UDim.new(0, 10)
	navPadding.PaddingRight = UDim.new(0, 10)
	navPadding.Parent = navPanel
	
	-- Content Container
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Position = UDim2.fromOffset(160, 50)
	contentContainer.Size = UDim2.new(1, -160, 1, -50)
	contentContainer.BackgroundTransparency = 1
	contentContainer.BorderSizePixel = 0
	contentContainer.ClipsDescendants = true
	contentContainer.Parent = mainWindow
	
	-- Drag Functionality
	self:enableDrag(topBar, mainWindow)
	
	-- Resize Handle
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.AnchorPoint = Vector2.new(1, 1)
	resizeHandle.Position = UDim2.fromScale(1, 1)
	resizeHandle.Size = UDim2.fromOffset(15, 15)
	resizeHandle.BackgroundColor3 = theme.accent
	resizeHandle.BorderSizePixel = 0
	resizeHandle.Parent = mainWindow
	
	applyCorner(resizeHandle, 3)
	
	self:enableResize(resizeHandle, mainWindow)
	
	-- Toggle Connection
	pcall(function()
		if getgenv().UILibToggleConnection then
			getgenv().UILibToggleConnection:Disconnect()
		end
	end)
	
	getgenv().UILibToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.config.toggleKey then
			screenGui.Enabled = not screenGui.Enabled
			self.state.isOpen = screenGui.Enabled
		end
	end)
	
	-- Store references
	self.screenGui = screenGui
	self.mainWindow = mainWindow
	self.navPanel = navPanel
	self.contentContainer = contentContainer
	self.tabs = {}
	
	return self
end

-- Create Tab
function UILibrary:createTab(name, icon)
	local theme = self.config.theme
	
	-- Tab Button
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = name
	tabBtn.Size = UDim2.new(1, 0, 0, 40)
	tabBtn.BackgroundColor3 = theme.tertiary
	tabBtn.BackgroundTransparency = 1
	tabBtn.BorderSizePixel = 0
	tabBtn.Text = ""
	tabBtn.AutoButtonColor = false
	tabBtn.Parent = self.navPanel
	
	applyCorner(tabBtn, 8)
	
	-- Icon (if provided)
	if icon then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "Icon"
		iconLabel.Position = UDim2.fromOffset(10, 10)
		iconLabel.Size = UDim2.fromOffset(20, 20)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Image = icon
		iconLabel.ImageColor3 = theme.textDim
		iconLabel.Parent = tabBtn
	end
	
	-- Tab Label
	local tabLabel = Instance.new("TextLabel")
	tabLabel.Name = "Label"
	tabLabel.Position = UDim2.fromOffset(icon and 38 or 10, 0)
	tabLabel.Size = UDim2.new(1, icon and -38 or -10, 1, 0)
	tabLabel.BackgroundTransparency = 1
	tabLabel.Text = name
	tabLabel.TextColor3 = theme.textDim
	tabLabel.TextSize = 14
	tabLabel.Font = Enum.Font.GothamMedium
	tabLabel.TextXAlignment = Enum.TextXAlignment.Left
	tabLabel.Parent = tabBtn
	
	-- Tab Content Frame
	local tabContent = Instance.new("ScrollingFrame")
	tabContent.Name = name .. "Content"
	tabContent.Size = UDim2.fromScale(1, 1)
	tabContent.BackgroundTransparency = 1
	tabContent.BorderSizePixel = 0
	tabContent.ScrollBarThickness = 4
	tabContent.ScrollBarImageColor3 = theme.accent
	tabContent.CanvasSize = UDim2.fromScale(0, 0)
	tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabContent.Visible = false
	tabContent.Parent = self.contentContainer
	
	local contentList = Instance.new("UIListLayout")
	contentList.Padding = UDim.new(0, 10)
	contentList.SortOrder = Enum.SortOrder.LayoutOrder
	contentList.Parent = tabContent
	
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 15)
	contentPadding.PaddingLeft = UDim.new(0, 15)
	contentPadding.PaddingRight = UDim.new(0, 15)
	contentPadding.PaddingBottom = UDim.new(0, 15)
	contentPadding.Parent = tabContent
	
	-- Tab Click Handler
	tabBtn.MouseButton1Click:Connect(function()
		-- Hide all tabs
		for _, tab in pairs(self.tabs) do
			tab.content.Visible = false
			tab.button.BackgroundTransparency = 1
			createTween(tab.label, {TextColor3 = theme.textDim}):Play()
		end
		
		-- Show this tab
		tabContent.Visible = true
		createTween(tabBtn, {BackgroundTransparency = 0}):Play()
		createTween(tabLabel, {TextColor3 = theme.text}):Play()
		self.state.currentTab = name
	end)
	
	-- Hover effects
	tabBtn.MouseEnter:Connect(function()
		if self.state.currentTab ~= name then
			createTween(tabBtn, {BackgroundTransparency = 0.5}):Play()
		end
	end)
	
	tabBtn.MouseLeave:Connect(function()
		if self.state.currentTab ~= name then
			createTween(tabBtn, {BackgroundTransparency = 1}):Play()
		end
	end)
	
	-- Store tab data
	self.tabs[name] = {
		button = tabBtn,
		label = tabLabel,
		content = tabContent
	}
	
	-- Auto-select first tab
	if not self.state.currentTab then
		tabBtn.MouseButton1Click:Fire()
	end
	
	-- Return tab API
	local TabAPI = {}
	TabAPI.content = tabContent
	
	function TabAPI:addButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 35)
		btn.BackgroundColor3 = theme.tertiary
		btn.BorderSizePixel = 0
		btn.Text = text
		btn.TextColor3 = theme.text
		btn.TextSize = 14
		btn.Font = Enum.Font.Gotham
		btn.AutoButtonColor = false
		btn.Parent = tabContent
		
		applyCorner(btn, 6)
		applyStroke(btn, theme.border, 1)
		
		btn.MouseButton1Click:Connect(function()
			createTween(btn, {BackgroundColor3 = theme.accent}):Play()
			wait(0.1)
			createTween(btn, {BackgroundColor3 = theme.tertiary}):Play()
			if callback then callback() end
		end)
		
		btn.MouseEnter:Connect(function()
			createTween(btn, {BackgroundColor3 = theme.tertiary:Lerp(theme.accent, 0.3)}):Play()
		end)
		
		btn.MouseLeave:Connect(function()
			createTween(btn, {BackgroundColor3 = theme.tertiary}):Play()
		end)
		
		return btn
	end
	
	function TabAPI:addToggle(text, default, callback)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(1, 0, 0, 35)
		toggleFrame.BackgroundColor3 = theme.tertiary
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = tabContent
		
		applyCorner(toggleFrame, 6)
		applyStroke(toggleFrame, theme.border, 1)
		
		local toggleLabel = Instance.new("TextLabel")
		toggleLabel.Position = UDim2.fromOffset(12, 0)
		toggleLabel.Size = UDim2.new(1, -60, 1, 0)
		toggleLabel.BackgroundTransparency = 1
		toggleLabel.Text = text
		toggleLabel.TextColor3 = theme.text
		toggleLabel.TextSize = 14
		toggleLabel.Font = Enum.Font.Gotham
		toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
		toggleLabel.Parent = toggleFrame
		
		local toggleBtn = Instance.new("TextButton")
		toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
		toggleBtn.Position = UDim2.new(1, -10, 0.5, 0)
		toggleBtn.Size = UDim2.fromOffset(40, 20)
		toggleBtn.BackgroundColor3 = default and theme.accent or theme.background
		toggleBtn.BorderSizePixel = 0
		toggleBtn.Text = ""
		toggleBtn.AutoButtonColor = false
		toggleBtn.Parent = toggleFrame
		
		applyCorner(toggleBtn, 10)
		
		local toggleCircle = Instance.new("Frame")
		toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
		toggleCircle.Position = UDim2.new(0, default and 22 or 2, 0.5, 0)
		toggleCircle.Size = UDim2.fromOffset(16, 16)
		toggleCircle.BackgroundColor3 = theme.text
		toggleCircle.BorderSizePixel = 0
		toggleCircle.Parent = toggleBtn
		
		applyCorner(toggleCircle, 8)
		
		local isToggled = default or false
		
		toggleBtn.MouseButton1Click:Connect(function()
			isToggled = not isToggled
			
			createTween(toggleBtn, {BackgroundColor3 = isToggled and theme.accent or theme.background}):Play()
			createTween(toggleCircle, {Position = UDim2.new(0, isToggled and 22 or 2, 0.5, 0)}):Play()
			
			if callback then callback(isToggled) end
		end)
		
		return toggleFrame
	end
	
	function TabAPI:addSlider(text, min, max, default, callback)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(1, 0, 0, 50)
		sliderFrame.BackgroundColor3 = theme.tertiary
		sliderFrame.BorderSizePixel = 0
		sliderFrame.Parent = tabContent
		
		applyCorner(sliderFrame, 6)
		applyStroke(sliderFrame, theme.border, 1)
		
		local sliderLabel = Instance.new("TextLabel")
		sliderLabel.Position = UDim2.fromOffset(12, 5)
		sliderLabel.Size = UDim2.new(1, -24, 0, 20)
		sliderLabel.BackgroundTransparency = 1
		sliderLabel.Text = text
		sliderLabel.TextColor3 = theme.text
		sliderLabel.TextSize = 14
		sliderLabel.Font = Enum.Font.Gotham
		sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
		sliderLabel.Parent = sliderFrame
		
		local valueLabel = Instance.new("TextLabel")
		valueLabel.AnchorPoint = Vector2.new(1, 0)
		valueLabel.Position = UDim2.new(1, -12, 0, 5)
		valueLabel.Size = UDim2.fromOffset(50, 20)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = tostring(default or min)
		valueLabel.TextColor3 = theme.accent
		valueLabel.TextSize = 14
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.Parent = sliderFrame
		
		local sliderTrack = Instance.new("Frame")
		sliderTrack.Position = UDim2.fromOffset(12, 32)
		sliderTrack.Size = UDim2.new(1, -24, 0, 6)
		sliderTrack.BackgroundColor3 = theme.background
		sliderTrack.BorderSizePixel = 0
		sliderTrack.Parent = sliderFrame
		
		applyCorner(sliderTrack, 3)
		
		local sliderFill = Instance.new("Frame")
		sliderFill.Size = UDim2.new(0, 0, 1, 0)
		sliderFill.BackgroundColor3 = theme.accent
		sliderFill.BorderSizePixel = 0
		sliderFill.Parent = sliderTrack
		
		applyCorner(sliderFill, 3)
		
		local sliderHandle = Instance.new("Frame")
		sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
		sliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
		sliderHandle.Size = UDim2.fromOffset(14, 14)
		sliderHandle.BackgroundColor3 = theme.text
		sliderHandle.BorderSizePixel = 0
		sliderHandle.Parent = sliderTrack
		
		applyCorner(sliderHandle, 7)
		
		local dragging = false
		local currentValue = default or min
		
		local function updateSlider(input)
			local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
			currentValue = math.floor(min + (max - min) * pos)
			
			sliderFill.Size = UDim2.fromScale(pos, 1)
			sliderHandle.Position = UDim2.fromScale(pos, 0.5)
			valueLabel.Text = tostring(currentValue)
			
			if callback then callback(currentValue) end
		end
		
		sliderTrack.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				updateSlider(input)
			end
		end)
		
		sliderTrack.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSlider(input)
			end
		end)
		
		-- Initialize
		local initPos = (currentValue - min) / (max - min)
		sliderFill.Size = UDim2.fromScale(initPos, 1)
		sliderHandle.Position = UDim2.fromScale(initPos, 0.5)
		
		return sliderFrame
	end
	
	function TabAPI:addLabel(text)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 25)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = theme.textDim
		label.TextSize = 13
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = tabContent
		
		return label
	end
	
	return TabAPI
end

-- Enable Dragging
function UILibrary:enableDrag(dragFrame, targetFrame)
	local dragging = false
	local dragStart, startPos
	
	dragFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position
			
			self.state.isDragging = true
		end
	end)
	
	dragFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			self.state.isDragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Enable Resizing
function UILibrary:enableResize(resizeHandle, targetFrame)
	local resizing = false
	local resizeStart, startSize
	
	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = targetFrame.Size
			
			self.state.isResizing = true
		end
	end)
	
	resizeHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
			self.state.isResizing = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeStart
			local newWidth = math.max(startSize.X.Offset + delta.X, 500)
			local newHeight = math.max(startSize.Y.Offset + delta.Y, 350)
			
			targetFrame.Size = UDim2.fromOffset(newWidth, newHeight)
		end
	end)
end

return UILibrary

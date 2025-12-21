--[[
    MobileUI Library v1.0
    A professional mobile-first UI library for Roblox
    Optimized for touch input, small screens, and one-hand usage
    
    Author: Mobile UI Specialist
    Features: Touch-optimized controls, smooth animations, theme support
]]

local MobileUI = {}
MobileUI.__index = MobileUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Constants
local MOBILE_BUTTON_HEIGHT = 52
local MOBILE_SPACING = 12
local CORNER_RADIUS = 12
local ANIMATION_TIME = 0.3

-- Theme Definitions
local Themes = {
    purple = {
        background = Color3.fromRGB(25, 20, 35),
        secondary = Color3.fromRGB(40, 35, 55),
        accent = Color3.fromRGB(138, 80, 255),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(180, 180, 200),
        border = Color3.fromRGB(60, 50, 80)
    },
    dark = {
        background = Color3.fromRGB(20, 20, 25),
        secondary = Color3.fromRGB(30, 30, 38),
        accent = Color3.fromRGB(70, 130, 255),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(160, 160, 170),
        border = Color3.fromRGB(45, 45, 55)
    },
    ocean = {
        background = Color3.fromRGB(15, 30, 45),
        secondary = Color3.fromRGB(25, 45, 65),
        accent = Color3.fromRGB(50, 180, 220),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(150, 200, 220),
        border = Color3.fromRGB(40, 70, 95)
    }
}

-- Utility Functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function addCorner(parent, radius)
    return createInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or CORNER_RADIUS),
        Parent = parent
    })
end

local function tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(
        duration or ANIMATION_TIME,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Main Library Constructor
function MobileUI.new()
    local self = setmetatable({}, MobileUI)
    
    -- Check if device is mobile
    if not UserInputService.TouchEnabled then
        warn("MobileUI: This library is optimized for mobile devices only!")
    end
    
    self.currentTheme = Themes.purple
    self.windows = {}
    self.isVisible = true
    
    -- Create main ScreenGui
    self.screenGui = createInstance("ScreenGui", {
        Name = "MobileUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Create toggle button (floating button to show/hide UI)
    self:createToggleButton()
    
    return self
end

-- Theme Management
function MobileUI:setTheme(themeName)
    if Themes[themeName] then
        self.currentTheme = Themes[themeName]
        -- Update all existing windows
        for _, window in ipairs(self.windows) do
            window:updateTheme(self.currentTheme)
        end
    else
        warn("Theme '" .. themeName .. "' not found!")
    end
end

-- Toggle Button (Floating button to open/close UI)
function MobileUI:createToggleButton()
    local toggleBtn = createInstance("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0, 15, 0, 100),
        BackgroundColor3 = self.currentTheme.accent,
        Text = "UI",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = self.screenGui
    })
    addCorner(toggleBtn, 30)
    
    -- Add shadow effect
    createInstance("UIStroke", {
        Color = Color3.new(0, 0, 0),
        Transparency = 0.5,
        Thickness = 2,
        Parent = toggleBtn
    })
    
    -- Touch drag functionality
    local dragging = false
    local dragStart, startPos
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = toggleBtn.Position
        end
    end)
    
    toggleBtn.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            toggleBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    toggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Toggle visibility
    toggleBtn.Activated:Connect(function()
        self.isVisible = not self.isVisible
        for _, window in ipairs(self.windows) do
            window.frame.Visible = self.isVisible
        end
        tween(toggleBtn, {Rotation = self.isVisible and 0 or 180})
    end)
end

-- Window Constructor
function MobileUI:createWindow(title)
    local window = {}
    window.tabs = {}
    window.currentTab = nil
    window.theme = self.currentTheme
    
    -- Main window frame
    window.frame = createInstance("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 380, 0, 550),
        Position = UDim2.new(0.5, -190, 0.5, -275),
        BackgroundColor3 = self.currentTheme.background,
        BorderSizePixel = 0,
        Parent = self.screenGui
    })
    addCorner(window.frame)
    
    -- Border stroke
    createInstance("UIStroke", {
        Color = self.currentTheme.border,
        Thickness = 2,
        Parent = window.frame
    })
    
    -- Title bar
    local titleBar = createInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = self.currentTheme.secondary,
        BorderSizePixel = 0,
        Parent = window.frame
    })
    addCorner(titleBar)
    
    local titleLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.currentTheme.text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Close button
    local closeBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -47, 0, 7.5),
        BackgroundColor3 = Color3.fromRGB(255, 60, 60),
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 28,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    addCorner(closeBtn, 8)
    
    closeBtn.Activated:Connect(function()
        tween(window.frame, {Size = UDim2.new(0, 0, 0, 0)})
        task.wait(ANIMATION_TIME)
        window.frame.Visible = false
    end)
    
    -- Tab container
    window.tabContainer = createInstance("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 65),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 60),
        BorderSizePixel = 0,
        Parent = window.frame
    })
    
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        Parent = window.tabContainer
    })
    
    -- Content container
    window.contentContainer = createInstance("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -20, 1, -145),
        Position = UDim2.new(0, 10, 0, 135),
        BackgroundTransparency = 1,
        Parent = window.frame
    })
    
    -- Touch drag for window
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.frame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            window.frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Window methods
    function window:updateTheme(theme)
        window.theme = theme
        window.frame.BackgroundColor3 = theme.background
        titleBar.BackgroundColor3 = theme.secondary
        titleLabel.TextColor3 = theme.text
        
        for _, tab in ipairs(window.tabs) do
            tab:updateTheme(theme)
        end
    end
    
    function window:createTab(name, icon)
        local tab = {}
        tab.elements = {}
        
        -- Tab button
        tab.button = createInstance("TextButton", {
            Size = UDim2.new(0, 100, 0, 50),
            BackgroundColor3 = window.theme.secondary,
            Text = (icon and icon .. " " or "") .. name,
            TextColor3 = window.theme.textDim,
            TextSize = 16,
            Font = Enum.Font.GothamMedium,
            Parent = window.tabContainer
        })
        addCorner(tab.button, 8)
        
        -- Tab content frame
        tab.content = createInstance("ScrollingFrame", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = window.theme.accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = window.contentContainer
        })
        
        local layout = createInstance("UIListLayout", {
            Padding = UDim.new(0, MOBILE_SPACING),
            Parent = tab.content
        })
        
        -- Auto-resize canvas
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + MOBILE_SPACING)
        end)
        
        -- Update canvas size for horizontal tabs
        local tabLayout = window.tabContainer:FindFirstChildOfClass("UIListLayout")
        tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            window.tabContainer.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X, 0, 60)
        end)
        
        -- Tab switching
        tab.button.Activated:Connect(function()
            for _, otherTab in ipairs(window.tabs) do
                otherTab.content.Visible = false
                otherTab.button.BackgroundColor3 = window.theme.secondary
                otherTab.button.TextColor3 = window.theme.textDim
            end
            
            tab.content.Visible = true
            tab.button.BackgroundColor3 = window.theme.accent
            tab.button.TextColor3 = window.theme.text
            window.currentTab = tab
        end)
        
        -- Tab element creation methods
        function tab:addButton(text, callback)
            local btn = createInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, MOBILE_BUTTON_HEIGHT),
                BackgroundColor3 = window.theme.accent,
                Text = text,
                TextColor3 = window.theme.text,
                TextSize = 18,
                Font = Enum.Font.GothamMedium,
                Parent = tab.content
            })
            addCorner(btn, 10)
            
            -- Touch feedback
            btn.Activated:Connect(function()
                tween(btn, {BackgroundColor3 = Color3.fromRGB(
                    window.theme.accent.R * 255 * 0.8,
                    window.theme.accent.G * 255 * 0.8,
                    window.theme.accent.B * 255 * 0.8
                )}, 0.1)
                task.wait(0.1)
                tween(btn, {BackgroundColor3 = window.theme.accent}, 0.1)
                
                if callback then
                    callback()
                end
            end)
            
            table.insert(tab.elements, btn)
            return btn
        end
        
        function tab:addToggle(text, default, callback)
            local toggleFrame = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, MOBILE_BUTTON_HEIGHT),
                BackgroundColor3 = window.theme.secondary,
                Parent = tab.content
            })
            addCorner(toggleFrame, 10)
            
            local label = createInstance("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = window.theme.text,
                TextSize = 16,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            local toggleBtn = createInstance("TextButton", {
                Size = UDim2.new(0, 60, 0, 32),
                Position = UDim2.new(1, -70, 0.5, -16),
                BackgroundColor3 = default and window.theme.accent or window.theme.border,
                Text = "",
                Parent = toggleFrame
            })
            addCorner(toggleBtn, 16)
            
            local indicator = createInstance("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = default and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = toggleBtn
            })
            addCorner(indicator, 12)
            
            local state = default
            
            toggleBtn.Activated:Connect(function()
                state = not state
                
                tween(toggleBtn, {
                    BackgroundColor3 = state and window.theme.accent or window.theme.border
                })
                tween(indicator, {
                    Position = state and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12)
                })
                
                if callback then
                    callback(state)
                end
            end)
            
            table.insert(tab.elements, toggleFrame)
            return toggleFrame
        end
        
        function tab:addSlider(text, min, max, default, callback)
            local sliderFrame = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 75),
                BackgroundColor3 = window.theme.secondary,
                Parent = tab.content
            })
            addCorner(sliderFrame, 10)
            
            local label = createInstance("TextLabel", {
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 8),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = window.theme.text,
                TextSize = 16,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame
            })
            
            local valueLabel = createInstance("TextLabel", {
                Size = UDim2.new(0, 60, 0, 25),
                Position = UDim2.new(1, -70, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = window.theme.accent,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame
            })
            
            local sliderBg = createInstance("Frame", {
                Size = UDim2.new(1, -20, 0, 32),
                Position = UDim2.new(0, 10, 1, -40),
                BackgroundColor3 = window.theme.border,
                Parent = sliderFrame
            })
            addCorner(sliderBg, 16)
            
            local sliderFill = createInstance("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = window.theme.accent,
                BorderSizePixel = 0,
                Parent = sliderBg
            })
            addCorner(sliderFill, 16)
            
            local sliderKnob = createInstance("Frame", {
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new((default - min) / (max - min), -14, 0.5, -14),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = sliderBg
            })
            addCorner(sliderKnob, 14)
            
            local dragging = false
            local currentValue = default
            
            local function updateSlider(input)
                local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(min + (max - min) * relativeX)
                
                valueLabel.Text = tostring(currentValue)
                tween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.1)
                tween(sliderKnob, {Position = UDim2.new(relativeX, -14, 0.5, -14)}, 0.1)
                
                if callback then
                    callback(currentValue)
                end
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            sliderBg.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(input)
                end
            end)
            
            sliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            table.insert(tab.elements, sliderFrame)
            return sliderFrame
        end
        
        function tab:addDropdown(text, options, callback)
            local dropdownFrame = createInstance("Frame", {
                Size = UDim2.new(1, 0, 0, MOBILE_BUTTON_HEIGHT),
                BackgroundColor3 = window.theme.secondary,
                Parent = tab.content
            })
            addCorner(dropdownFrame, 10)
            
            local label = createInstance("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = text .. ": " .. (options[1] or "None"),
                TextColor3 = window.theme.text,
                TextSize = 16,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })
            
            local arrow = createInstance("TextLabel", {
                Size = UDim2.new(0, 40, 1, 0),
                Position = UDim2.new(1, -50, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = window.theme.accent,
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                Parent = dropdownFrame
            })
            
            local dropdownBtn = createInstance("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = dropdownFrame
            })
            
            local menuOpen = false
            local menu
            
            dropdownBtn.Activated:Connect(function()
                if menuOpen then
                    if menu then
                        tween(menu, {Size = UDim2.new(0.9, 0, 0, 0)})
                        task.wait(ANIMATION_TIME)
                        menu:Destroy()
                        menu = nil
                    end
                    menuOpen = false
                    tween(arrow, {Rotation = 0})
                else
                    -- Create fullscreen mobile-style dropdown
                    menu = createInstance("Frame", {
                        Size = UDim2.new(0.9, 0, 0, 0),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = window.theme.background,
                        BorderSizePixel = 0,
                        ZIndex = 10,
                        Parent = self.screenGui
                    })
                    addCorner(menu)
                    
                    createInstance("UIStroke", {
                        Color = window.theme.accent,
                        Thickness = 3,
                        Parent = menu
                    })
                    
                    local menuScroll = createInstance("ScrollingFrame", {
                        Size = UDim2.new(1, -20, 1, -20),
                        Position = UDim2.new(0, 10, 0, 10),
                        BackgroundTransparency = 1,
                        ScrollBarThickness = 6,
                        ScrollBarImageColor3 = window.theme.accent,
                        BorderSizePixel = 0,
                        Parent = menu
                    })
                    
                    local menuLayout = createInstance("UIListLayout", {
                        Padding = UDim.new(0, 8),
                        Parent = menuScroll
                    })
                    
                    for _, option in ipairs(options) do
                        local optionBtn = createInstance("TextButton", {
                            Size = UDim2.new(1, 0, 0, MOBILE_BUTTON_HEIGHT),
                            BackgroundColor3 = window.theme.secondary,
                            Text = option,
                            TextColor3 = window.theme.text,
                            TextSize = 18,
                            Font = Enum.Font.Gotham,
                            Parent = menuScroll
                        })
                        addCorner(optionBtn, 10)
                        
                        optionBtn.Activated:Connect(function()
                            label.Text = text .. ": " .. option
                            
                            tween(menu, {Size = UDim2.new(0.9, 0, 0, 0)})
                            task.wait(ANIMATION_TIME)
                            menu:Destroy()
                            menu = nil
                            menuOpen = false
                            tween(arrow, {Rotation = 0})
                            
                            if callback then
                                callback(option)
                            end
                        end)
                    end
                    
                    menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        menuScroll.CanvasSize = UDim2.new(0, 0, 0, menuLayout.AbsoluteContentSize.Y + 20)
                    end)
                    
                    tween(menu, {Size = UDim2.new(0.9, 0, 0, math.min(400, #options * (MOBILE_BUTTON_HEIGHT + 8) + 20))})
                    menuOpen = true
                    tween(arrow, {Rotation = 180})
                end
            end)
            
            table.insert(tab.elements, dropdownFrame)
            return dropdownFrame
        end
        
        function tab:addLabel(text)
            local label = createInstance("TextLabel", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = window.theme.secondary,
                Text = text,
                TextColor3 = window.theme.text,
                TextSize = 16,
                Font = Enum.Font.Gotham,
                TextWrapped = true,
                Parent = tab.content
            })
            addCorner(label, 10)
            
            table.insert(tab.elements, label)
            return label
        end
        
        function tab:updateTheme(theme)
            tab.button.BackgroundColor3 = theme.secondary
            tab.button.TextColor3 = theme.textDim
            tab.content.ScrollBarImageColor3 = theme.accent
            
            for _, element in ipairs(tab.elements) do
                if element:IsA("TextButton") then
                    element.BackgroundColor3 = theme.accent
                    element.TextColor3 = theme.text
                elseif element:IsA("Frame") then
                    element.BackgroundColor3 = theme.secondary
                end
            end
        end
        
        table.insert(window.tabs, tab)
        
        -- Auto-select first tab
        if #window.tabs == 1 then
            tab.button.BackgroundColor3 = window.theme.accent
            tab.button.TextColor3 = window.theme.text
            tab.content.Visible = true
            window.currentTab = tab
        end
        
        return tab
    end
    
    table.insert(self.windows, window)
    return window
end

return MobileUI

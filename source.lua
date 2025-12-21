local MobileUI = {}
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local themes = {
    purple = {bg = Color3.fromRGB(25,20,35), sec = Color3.fromRGB(40,35,55), acc = Color3.fromRGB(138,80,255), txt = Color3.new(1,1,1), dim = Color3.fromRGB(180,180,200)},
    dark = {bg = Color3.fromRGB(20,20,25), sec = Color3.fromRGB(30,30,38), acc = Color3.fromRGB(70,130,255), txt = Color3.new(1,1,1), dim = Color3.fromRGB(160,160,170)},
    ocean = {bg = Color3.fromRGB(15,30,45), sec = Color3.fromRGB(25,45,65), acc = Color3.fromRGB(50,180,220), txt = Color3.new(1,1,1), dim = Color3.fromRGB(150,200,220)}
}

local function tween(obj, props, t)
    TS:Create(obj, TweenInfo.new(t or 0.3, Enum.EasingStyle.Quad), props):Play()
end

local function corner(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 12)
end

function MobileUI.new()
    local lib = {theme = themes.purple, windows = {}}
    
    lib.gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    lib.gui.Name = "MobileUI"
    lib.gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton", lib.gui)
    btn.Size = UDim2.new(0,60,0,60)
    btn.Position = UDim2.new(0,15,0,100)
    btn.BackgroundColor3 = lib.theme.acc
    btn.Text = "UI"
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    corner(btn, 30)
    
    local drag, ds, sp
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            ds = i.Position
            sp = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    
    lib.visible = true
    btn.Activated:Connect(function()
        lib.visible = not lib.visible
        for _, w in ipairs(lib.windows) do
            w.frame.Visible = lib.visible
        end
    end)
    
    function lib:setTheme(name)
        if themes[name] then
            self.theme = themes[name]
            for _, w in ipairs(self.windows) do
                w:refresh()
            end
        end
    end
    
    function lib:createWindow(title)
        local win = {tabs = {}, lib = self}
        
        win.frame = Instance.new("Frame", self.gui)
        win.frame.Size = UDim2.new(0,360,0,520)
        win.frame.Position = UDim2.new(0.5,-180,0.5,-260)
        win.frame.BackgroundColor3 = self.theme.bg
        win.frame.BorderSizePixel = 0
        corner(win.frame)
        
        local top = Instance.new("Frame", win.frame)
        top.Size = UDim2.new(1,0,0,50)
        top.BackgroundColor3 = self.theme.sec
        top.BorderSizePixel = 0
        corner(top)
        
        local lbl = Instance.new("TextLabel", top)
        lbl.Size = UDim2.new(1,-60,1,0)
        lbl.Position = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextColor3 = self.theme.txt
        lbl.TextSize = 18
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local close = Instance.new("TextButton", top)
        close.Size = UDim2.new(0,35,0,35)
        close.Position = UDim2.new(1,-42,0,7)
        close.BackgroundColor3 = Color3.fromRGB(255,60,60)
        close.Text = "×"
        close.TextColor3 = Color3.new(1,1,1)
        close.TextSize = 24
        close.Font = Enum.Font.GothamBold
        corner(close, 8)
        close.Activated:Connect(function()
            win.frame.Visible = false
        end)
        
        local drag, ds, sp
        top.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                ds = i.Position
                sp = win.frame.Position
            end
        end)
        top.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.Touch then
                local d = i.Position - ds
                win.frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end)
        top.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
        
        win.tabbar = Instance.new("ScrollingFrame", win.frame)
        win.tabbar.Size = UDim2.new(1,-20,0,55)
        win.tabbar.Position = UDim2.new(0,10,0,60)
        win.tabbar.BackgroundTransparency = 1
        win.tabbar.ScrollBarThickness = 0
        win.tabbar.ScrollingDirection = Enum.ScrollingDirection.X
        win.tabbar.BorderSizePixel = 0
        Instance.new("UIListLayout", win.tabbar).FillDirection = Enum.FillDirection.Horizontal
        Instance.new("UIListLayout", win.tabbar).Padding = UDim.new(0,6)
        
        win.container = Instance.new("Frame", win.frame)
        win.container.Size = UDim2.new(1,-20,1,-125)
        win.container.Position = UDim2.new(0,10,0,120)
        win.container.BackgroundTransparency = 1
        
        function win:refresh()
            win.frame.BackgroundColor3 = self.lib.theme.bg
            top.BackgroundColor3 = self.lib.theme.sec
            lbl.TextColor3 = self.lib.theme.txt
            for _, t in ipairs(win.tabs) do
                t:refresh()
            end
        end
        
        function win:createTab(name, icon)
            local tab = {elements = {}, win = win}
            
            tab.btn = Instance.new("TextButton", win.tabbar)
            tab.btn.Size = UDim2.new(0,90,0,45)
            tab.btn.BackgroundColor3 = self.lib.theme.sec
            tab.btn.Text = (icon or "")..name
            tab.btn.TextColor3 = self.lib.theme.dim
            tab.btn.TextSize = 15
            tab.btn.Font = Enum.Font.GothamMedium
            corner(tab.btn, 8)
            
            tab.scroll = Instance.new("ScrollingFrame", win.container)
            tab.scroll.Size = UDim2.new(1,0,1,0)
            tab.scroll.BackgroundTransparency = 1
            tab.scroll.ScrollBarThickness = 4
            tab.scroll.ScrollBarImageColor3 = self.lib.theme.acc
            tab.scroll.BorderSizePixel = 0
            tab.scroll.Visible = false
            
            local layout = Instance.new("UIListLayout", tab.scroll)
            layout.Padding = UDim.new(0,10)
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tab.scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
            end)
            
            tab.btn.Activated:Connect(function()
                for _, t in ipairs(win.tabs) do
                    t.scroll.Visible = false
                    t.btn.BackgroundColor3 = win.lib.theme.sec
                    t.btn.TextColor3 = win.lib.theme.dim
                end
                tab.scroll.Visible = true
                tab.btn.BackgroundColor3 = win.lib.theme.acc
                tab.btn.TextColor3 = win.lib.theme.txt
            end)
            
            function tab:addButton(txt, callback)
                local b = Instance.new("TextButton", tab.scroll)
                b.Size = UDim2.new(1,0,0,48)
                b.BackgroundColor3 = win.lib.theme.acc
                b.Text = txt
                b.TextColor3 = win.lib.theme.txt
                b.TextSize = 16
                b.Font = Enum.Font.GothamMedium
                corner(b, 10)
                b.Activated:Connect(function()
                    tween(b, {BackgroundColor3 = Color3.fromRGB(win.lib.theme.acc.R*255*0.7, win.lib.theme.acc.G*255*0.7, win.lib.theme.acc.B*255*0.7)}, 0.1)
                    task.wait(0.1)
                    tween(b, {BackgroundColor3 = win.lib.theme.acc}, 0.1)
                    if callback then callback() end
                end)
                table.insert(tab.elements, b)
            end
            
            function tab:addToggle(txt, def, callback)
                local f = Instance.new("Frame", tab.scroll)
                f.Size = UDim2.new(1,0,0,48)
                f.BackgroundColor3 = win.lib.theme.sec
                corner(f, 10)
                
                local l = Instance.new("TextLabel", f)
                l.Size = UDim2.new(1,-70,1,0)
                l.Position = UDim2.new(0,12,0,0)
                l.BackgroundTransparency = 1
                l.Text = txt
                l.TextColor3 = win.lib.theme.txt
                l.TextSize = 15
                l.Font = Enum.Font.Gotham
                l.TextXAlignment = Enum.TextXAlignment.Left
                
                local tb = Instance.new("TextButton", f)
                tb.Size = UDim2.new(0,55,0,28)
                tb.Position = UDim2.new(1,-62,0.5,-14)
                tb.BackgroundColor3 = def and win.lib.theme.acc or Color3.fromRGB(60,60,70)
                tb.Text = ""
                corner(tb, 14)
                
                local ind = Instance.new("Frame", tb)
                ind.Size = UDim2.new(0,22,0,22)
                ind.Position = def and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)
                ind.BackgroundColor3 = Color3.new(1,1,1)
                corner(ind, 11)
                
                local state = def
                tb.Activated:Connect(function()
                    state = not state
                    tween(tb, {BackgroundColor3 = state and win.lib.theme.acc or Color3.fromRGB(60,60,70)})
                    tween(ind, {Position = state and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)})
                    if callback then callback(state) end
                end)
                table.insert(tab.elements, f)
            end
            
            function tab:addSlider(txt, min, max, def, callback)
                local f = Instance.new("Frame", tab.scroll)
                f.Size = UDim2.new(1,0,0,70)
                f.BackgroundColor3 = win.lib.theme.sec
                corner(f, 10)
                
                local l = Instance.new("TextLabel", f)
                l.Size = UDim2.new(1,-60,0,22)
                l.Position = UDim2.new(0,10,0,6)
                l.BackgroundTransparency = 1
                l.Text = txt
                l.TextColor3 = win.lib.theme.txt
                l.TextSize = 15
                l.Font = Enum.Font.Gotham
                l.TextXAlignment = Enum.TextXAlignment.Left
                
                local v = Instance.new("TextLabel", f)
                v.Size = UDim2.new(0,50,0,22)
                v.Position = UDim2.new(1,-60,0,6)
                v.BackgroundTransparency = 1
                v.Text = tostring(def)
                v.TextColor3 = win.lib.theme.acc
                v.TextSize = 15
                v.Font = Enum.Font.GothamBold
                v.TextXAlignment = Enum.TextXAlignment.Right
                
                local bg = Instance.new("Frame", f)
                bg.Size = UDim2.new(1,-20,0,28)
                bg.Position = UDim2.new(0,10,1,-34)
                bg.BackgroundColor3 = Color3.fromRGB(40,40,50)
                corner(bg, 14)
                
                local fill = Instance.new("Frame", bg)
                fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
                fill.BackgroundColor3 = win.lib.theme.acc
                fill.BorderSizePixel = 0
                corner(fill, 14)
                
                local knob = Instance.new("Frame", bg)
                knob.Size = UDim2.new(0,24,0,24)
                knob.Position = UDim2.new((def-min)/(max-min),-12,0.5,-12)
                knob.BackgroundColor3 = Color3.new(1,1,1)
                corner(knob, 12)
                
                local drag = false
                local val = def
                
                local function update(i)
                    local rx = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * rx)
                    v.Text = tostring(val)
                    tween(fill, {Size = UDim2.new(rx,0,1,0)}, 0.1)
                    tween(knob, {Position = UDim2.new(rx,-12,0.5,-12)}, 0.1)
                    if callback then callback(val) end
                end
                
                bg.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.Touch then
                        drag = true
                        update(i)
                    end
                end)
                bg.InputChanged:Connect(function(i)
                    if drag and i.UserInputType == Enum.UserInputType.Touch then update(i) end
                end)
                bg.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.Touch then drag = false end
                end)
                table.insert(tab.elements, f)
            end
            
            function tab:addDropdown(txt, opts, callback)
                local f = Instance.new("Frame", tab.scroll)
                f.Size = UDim2.new(1,0,0,48)
                f.BackgroundColor3 = win.lib.theme.sec
                corner(f, 10)
                
                local l = Instance.new("TextLabel", f)
                l.Size = UDim2.new(1,-50,1,0)
                l.Position = UDim2.new(0,12,0,0)
                l.BackgroundTransparency = 1
                l.Text = txt..": "..(opts[1] or "None")
                l.TextColor3 = win.lib.theme.txt
                l.TextSize = 15
                l.Font = Enum.Font.Gotham
                l.TextXAlignment = Enum.TextXAlignment.Left
                
                local arr = Instance.new("TextLabel", f)
                arr.Size = UDim2.new(0,30,1,0)
                arr.Position = UDim2.new(1,-40,0,0)
                arr.BackgroundTransparency = 1
                arr.Text = "▼"
                arr.TextColor3 = win.lib.theme.acc
                arr.TextSize = 16
                
                local db = Instance.new("TextButton", f)
                db.Size = UDim2.new(1,0,1,0)
                db.BackgroundTransparency = 1
                db.Text = ""
                
                local open = false
                local menu
                
                db.Activated:Connect(function()
                    if open then
                        if menu then
                            tween(menu, {Size = UDim2.new(0.85,0,0,0)})
                            task.wait(0.3)
                            menu:Destroy()
                            menu = nil
                        end
                        open = false
                        tween(arr, {Rotation = 0})
                    else
                        menu = Instance.new("Frame", win.lib.gui)
                        menu.Size = UDim2.new(0.85,0,0,0)
                        menu.Position = UDim2.new(0.5,0,0.5,0)
                        menu.AnchorPoint = Vector2.new(0.5,0.5)
                        menu.BackgroundColor3 = win.lib.theme.bg
                        menu.BorderSizePixel = 0
                        menu.ZIndex = 10
                        corner(menu)
                        
                        local ms = Instance.new("ScrollingFrame", menu)
                        ms.Size = UDim2.new(1,-16,1,-16)
                        ms.Position = UDim2.new(0,8,0,8)
                        ms.BackgroundTransparency = 1
                        ms.ScrollBarThickness = 5
                        ms.ScrollBarImageColor3 = win.lib.theme.acc
                        ms.BorderSizePixel = 0
                        
                        local ml = Instance.new("UIListLayout", ms)
                        ml.Padding = UDim.new(0,6)
                        
                        for _, opt in ipairs(opts) do
                            local ob = Instance.new("TextButton", ms)
                            ob.Size = UDim2.new(1,0,0,48)
                            ob.BackgroundColor3 = win.lib.theme.sec
                            ob.Text = opt
                            ob.TextColor3 = win.lib.theme.txt
                            ob.TextSize = 16
                            ob.Font = Enum.Font.Gotham
                            corner(ob, 10)
                            
                            ob.Activated:Connect(function()
                                l.Text = txt..": "..opt
                                tween(menu, {Size = UDim2.new(0.85,0,0,0)})
                                task.wait(0.3)
                                menu:Destroy()
                                menu = nil
                                open = false
                                tween(arr, {Rotation = 0})
                                if callback then callback(opt) end
                            end)
                        end
                        
                        ml:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            ms.CanvasSize = UDim2.new(0,0,0,ml.AbsoluteContentSize.Y+16)
                        end)
                        
                        tween(menu, {Size = UDim2.new(0.85,0,0,math.min(380, #opts*54+16))})
                        open = true
                        tween(arr, {Rotation = 180})
                    end
                end)
                table.insert(tab.elements, f)
            end
            
            function tab:addLabel(txt)
                local l = Instance.new("TextLabel", tab.scroll)
                l.Size = UDim2.new(1,0,0,38)
                l.BackgroundColor3 = win.lib.theme.sec
                l.Text = txt
                l.TextColor3 = win.lib.theme.txt
                l.TextSize = 15
                l.Font = Enum.Font.Gotham
                l.TextWrapped = true
                corner(l, 10)
                table.insert(tab.elements, l)
            end
            
            function tab:refresh()
                tab.btn.BackgroundColor3 = win.lib.theme.sec
                tab.btn.TextColor3 = win.lib.theme.dim
                tab.scroll.ScrollBarImageColor3 = win.lib.theme.acc
            end
            
            table.insert(win.tabs, tab)
            if #win.tabs == 1 then
                tab.btn.BackgroundColor3 = win.lib.theme.acc
                tab.btn.TextColor3 = win.lib.theme.txt
                tab.scroll.Visible = true
            end
            
            return tab
        end
        
        table.insert(self.windows, win)
        return win
    end
    
    return lib
end

return MobileUI

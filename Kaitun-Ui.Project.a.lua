repeat task.wait() until game:IsLoaded()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local KaitunUI = {}
KaitunUI.__index = KaitunUI

function KaitunUI.new(config)
    local self = setmetatable({}, KaitunUI)
    
    config = config or {}
    self.title = config.title or "Kaitun UI"
    self.buttonImage = config.buttonImage or "rbxassetid://78590114316385"
    self.buttonSize = config.buttonSize or 50
    self.panelWidth = config.panelWidth or 700
    self.panelHeight = config.panelHeight or 500
    self.accentColor = config.accentColor or Color3.fromRGB(138, 43, 226)
    
    self.isOpen = false
    self.texts = {}
    
    self:CreateUI()
    
    return self
end

function KaitunUI:CreateUI()
    -- เช็คและลบ UI เก่าถ้ามีอยู่แล้ว
    local existingUI = game.CoreGui:FindFirstChild("KaitunUI")
    if existingUI then
        existingUI:Destroy()
    end
    
    -- Main ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "KaitunUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.IgnoreGuiInset = true
    self.gui.Parent = game.CoreGui
    
    -- Kamui Effect Container (จะตามตำแหน่ง panel)
    self.kamuiContainer = Instance.new("Frame", self.gui)
    self.kamuiContainer.Name = "KamuiEffect"
    self.kamuiContainer.Size = UDim2.fromOffset(800, 800)
    self.kamuiContainer.Position = UDim2.fromScale(0.5, 0.5)
    self.kamuiContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    self.kamuiContainer.BackgroundTransparency = 1
    self.kamuiContainer.BorderSizePixel = 0
    self.kamuiContainer.Visible = false
    
    -- Kamui Spiral (หลายวงซ้อนกัน)
    self.spirals = {}
    for i = 1, 5 do
        local spiral = Instance.new("ImageLabel", self.kamuiContainer)
        spiral.Name = "Spiral" .. i
        spiral.Size = UDim2.fromOffset(800 - (i * 100), 800 - (i * 100))
        spiral.Position = UDim2.fromScale(0.5, 0.5)
        spiral.AnchorPoint = Vector2.new(0.5, 0.5)
        spiral.BackgroundTransparency = 1
        spiral.Image = "rbxassetid://6031094678" -- spiral image
        spiral.ImageColor3 = self.accentColor
        spiral.ImageTransparency = 0.3 + (i * 0.1)
        table.insert(self.spirals, spiral)
    end
    
    -- Black hole center
    self.blackHole = Instance.new("Frame", self.kamuiContainer)
    self.blackHole.Name = "BlackHole"
    self.blackHole.Size = UDim2.fromOffset(0, 0)
    self.blackHole.Position = UDim2.fromScale(0.5, 0.5)
    self.blackHole.AnchorPoint = Vector2.new(0.5, 0.5)
    self.blackHole.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", self.blackHole).CornerRadius = UDim.new(1, 0)
    
    -- Circle Button (ด้านบนสุดของจอ)
    self.openButton = Instance.new("ImageButton", self.gui)
    self.openButton.Name = "OpenButton"
    self.openButton.Size = UDim2.fromOffset(self.buttonSize, self.buttonSize)
    self.openButton.Position = UDim2.new(0.5, 0, 0, 10 + self.buttonSize/2)
    self.openButton.AnchorPoint = Vector2.new(0.5, 0.5)
    self.openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.openButton.Image = self.buttonImage
    self.openButton.ImageColor3 = Color3.new(1, 1, 1)
    self.openButton.AutoButtonColor = false
    Instance.new("UICorner", self.openButton).CornerRadius = UDim.new(1, 0)
    
    local buttonStroke = Instance.new("UIStroke", self.openButton)
    buttonStroke.Color = self.accentColor
    buttonStroke.Thickness = 2
    
    -- Button glow effect
    local buttonGlow = Instance.new("ImageLabel", self.openButton)
    buttonGlow.Name = "Glow"
    buttonGlow.Size = UDim2.new(1, 20, 1, 20)
    buttonGlow.Position = UDim2.fromScale(0.5, 0.5)
    buttonGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    buttonGlow.BackgroundTransparency = 1
    buttonGlow.Image = "rbxassetid://5028857084"
    buttonGlow.ImageColor3 = self.accentColor
    buttonGlow.ImageTransparency = 0.7
    buttonGlow.ZIndex = 0
    
    -- Draggable button
    local dragging = false
    local dragStart, startPos
    
    self.openButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.openButton.Position
        end
    end)
    
    self.openButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.openButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Button click
    self.openButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Button hover
    self.openButton.MouseEnter:Connect(function()
        TweenService:Create(self.openButton, TweenInfo.new(0.2), {
            Size = UDim2.fromOffset(self.buttonSize + 5, self.buttonSize + 5)
        }):Play()
        TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
            ImageTransparency = 0.4
        }):Play()
    end)
    
    self.openButton.MouseLeave:Connect(function()
        TweenService:Create(self.openButton, TweenInfo.new(0.2), {
            Size = UDim2.fromOffset(self.buttonSize, self.buttonSize)
        }):Play()
        TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
            ImageTransparency = 0.7
        }):Play()
    end)
    
    -- Main Panel
    self.panel = Instance.new("Frame", self.gui)
    self.panel.Name = "MainPanel"
    self.panel.Size = UDim2.fromOffset(self.panelWidth, self.panelHeight)
    self.panel.Position = UDim2.fromScale(0.5, 0.5)
    self.panel.AnchorPoint = Vector2.new(0.5, 0.5)
    self.panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    self.panel.BackgroundTransparency = 1
    self.panel.Visible = false
    self.panel.ClipsDescendants = true
    Instance.new("UICorner", self.panel).CornerRadius = UDim.new(0, 16)
    
    local panelStroke = Instance.new("UIStroke", self.panel)
    panelStroke.Color = self.accentColor
    panelStroke.Thickness = 2
    panelStroke.Transparency = 1
    self.panelStroke = panelStroke
    
    -- Title bar
    local titleBar = Instance.new("Frame", self.panel)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BackgroundTransparency = 1
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)
    self.titleBar = titleBar
    
    -- Draggable panel via title bar
    local draggingPanel = false
    local panelDragStart, panelStartPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingPanel = true
            panelDragStart = input.Position
            panelStartPos = self.panel.Position
            TweenService:Create(self.panelStroke, TweenInfo.new(0.15), {
                Thickness = 3,
                Color = Color3.fromRGB(self.accentColor.R * 255 + 30, self.accentColor.G * 255 + 30, self.accentColor.B * 255 + 30)
            }):Play()
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingPanel = false
            TweenService:Create(self.panelStroke, TweenInfo.new(0.15), {
                Thickness = 2,
                Color = self.accentColor
            }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingPanel and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - panelDragStart
            self.panel.Position = UDim2.new(
                panelStartPos.X.Scale,
                panelStartPos.X.Offset + delta.X,
                panelStartPos.Y.Scale,
                panelStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.fromOffset(15, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    self.titleLabel = titleLabel
    
    -- Close button
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.TextTransparency = 1
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    self.closeBtn = closeBtn
    
    -- Close button spin animation
    local closeBtnAngle = 0
    self.closeBtnSpinConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
        closeBtnAngle = closeBtnAngle + dt * 90
        closeBtn.Rotation = closeBtnAngle
    end)
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(255, 100, 100)
        }):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(150, 150, 150)
        }):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Scrolling Frame
    self.scrollFrame = Instance.new("ScrollingFrame", self.panel)
    self.scrollFrame.Name = "Content"
    self.scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    self.scrollFrame.Position = UDim2.fromOffset(10, 45)
    self.scrollFrame.BackgroundTransparency = 1
    self.scrollFrame.ScrollBarThickness = 4
    self.scrollFrame.ScrollBarImageColor3 = self.accentColor
    self.scrollFrame.ScrollBarImageTransparency = 0.5
    self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.scrollFrame.ScrollingEnabled = true
    
    local contentLayout = Instance.new("UIListLayout", self.scrollFrame)
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local contentPadding = Instance.new("UIPadding", self.scrollFrame)
    contentPadding.PaddingTop = UDim.new(0, 5)
end

function KaitunUI:ExpandOpen()
    -- ซ่อนปุ่ม
    self.openButton.Visible = false
    
    -- ตั้งค่า panel เริ่มต้นที่ตำแหน่งปุ่ม
    self.panel.Visible = true
    self.panel.Size = UDim2.fromOffset(self.buttonSize, self.buttonSize)
    self.panel.Position = self.openButton.Position
    self.panel.BackgroundTransparency = 0
    self.panelStroke.Transparency = 0
    self.titleBar.BackgroundTransparency = 1
    self.titleLabel.TextTransparency = 1
    self.closeBtn.TextTransparency = 1
    self.scrollFrame.ScrollBarImageTransparency = 1
    
    -- ขยายจากปุ่มเป็น panel
    TweenService:Create(self.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(self.panelWidth, self.panelHeight),
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()
    
    task.delay(0.3, function()
        TweenService:Create(self.titleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(self.titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        TweenService:Create(self.closeBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        TweenService:Create(self.scrollFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            ScrollBarImageTransparency = 0.5
        }):Play()
    end)
    
    task.delay(0.4, function()
        -- Staggered text fade in
        for idx, textData in ipairs(self.texts) do
            task.delay(idx * 0.08, function()
                if textData.frame and textData.frame.Parent then
                    textData.frame.Position = UDim2.new(0, -20, 0, 0)
                    TweenService:Create(textData.frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0,
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                    
                    if textData.label then
                        TweenService:Create(textData.label, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                            TextTransparency = 0
                        }):Play()
                    elseif textData.loadingLabel then
                        TweenService:Create(textData.loadingLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                            TextTransparency = 0
                        }):Play()
                        TweenService:Create(textData.percentLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                            TextTransparency = 0
                        }):Play()
                    end
                end
            end)
        end
    end)
end

function KaitunUI:CollapseClose()
    -- Staggered text fade out (reverse order)
    for idx = #self.texts, 1, -1 do
        local textData = self.texts[idx]
        local delay = (#self.texts - idx) * 0.03
        task.delay(delay, function()
            if textData.frame and textData.frame.Parent then
                TweenService:Create(textData.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1
                }):Play()
                
                if textData.label then
                    TweenService:Create(textData.label, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play()
                elseif textData.loadingLabel then
                    TweenService:Create(textData.loadingLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play()
                    TweenService:Create(textData.percentLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play()
                end
            end
        end)
    end
    
    task.delay(0.1, function()
        TweenService:Create(self.titleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(self.closeBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(self.titleBar, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(self.scrollFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            ScrollBarImageTransparency = 1
        }):Play()
    end)
    
    task.delay(0.2, function()
        -- หดกลับเป็นปุ่ม
        TweenService:Create(self.panel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(self.buttonSize, self.buttonSize),
            Position = self.openButton.Position
        }):Play()
    end)
    
    task.delay(0.6, function()
        self.panel.Visible = false
        self.openButton.Visible = true
        
        -- Reset text positions
        for _, textData in ipairs(self.texts) do
            if textData.frame then
                textData.frame.Position = UDim2.new(0, 0, 0, 0)
            end
        end
    end)
end

function KaitunUI:KamuiOpen()
    -- ตั้งตำแหน่ง kamui effect ตาม panel
    self.kamuiContainer.Position = self.panel.Position
    
    self.kamuiContainer.Visible = true
    self.panel.Visible = true
    self.panel.BackgroundTransparency = 1
    self.panel.Size = UDim2.fromOffset(0, 0)
    self.panelStroke.Transparency = 1
    self.titleBar.BackgroundTransparency = 1
    self.titleLabel.TextTransparency = 1
    self.closeBtn.TextTransparency = 1
    
    -- Smooth spiral animation
    for i, spiral in ipairs(self.spirals) do
        spiral.Rotation = 0
        spiral.Size = UDim2.fromOffset(0, 0)
        spiral.ImageTransparency = 0
        local direction = (i % 2 == 0) and 1 or -1
        local targetSize = 800 - (i * 100)
        
        -- Staggered spiral expansion
        task.delay(i * 0.05, function()
            TweenService:Create(spiral, TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Rotation = 720 * direction,
                Size = UDim2.fromOffset(targetSize, targetSize),
                ImageTransparency = 1
            }):Play()
        end)
    end
    
    -- Black hole smooth expand
    self.blackHole.Size = UDim2.fromOffset(0, 0)
    self.blackHole.BackgroundTransparency = 0
    TweenService:Create(self.blackHole, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(math.max(self.panelWidth, self.panelHeight) * 2.5, math.max(self.panelWidth, self.panelHeight) * 2.5),
        BackgroundTransparency = 0.3
    }):Play()
    
    task.delay(0.4, function()
        -- Panel scale up smoothly
        TweenService:Create(self.panel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(self.panelWidth, self.panelHeight),
            BackgroundTransparency = 0.02
        }):Play()
        
        TweenService:Create(self.panelStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Transparency = 0
        }):Play()
    end)
    
    task.delay(0.6, function()
        TweenService:Create(self.titleBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(self.titleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        TweenService:Create(self.closeBtn, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        
        -- Staggered text fade in
        for idx, textData in ipairs(self.texts) do
            task.delay(idx * 0.08, function()
                if textData.frame and textData.frame.Parent then
                    textData.frame.Position = UDim2.new(0, -20, 0, 0)
                    TweenService:Create(textData.frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0,
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                    
                    -- เช็คว่าเป็น text หรือ loader
                    if textData.label then
                        TweenService:Create(textData.label, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                            TextTransparency = 0
                        }):Play()
                    elseif textData.loadingLabel then
                        TweenService:Create(textData.loadingLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                            TextTransparency = 0
                        }):Play()
                        TweenService:Create(textData.percentLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                            TextTransparency = 0
                        }):Play()
                    end
                end
            end)
        end
    end)
    
    task.delay(1.0, function()
        -- Fade out black hole
        TweenService:Create(self.blackHole, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    task.delay(1.3, function()
        self.kamuiContainer.Visible = false
    end)
end

function KaitunUI:KamuiClose()
    -- ตั้งตำแหน่ง kamui effect ตาม panel ปัจจุบัน
    self.kamuiContainer.Position = self.panel.Position
    
    self.kamuiContainer.Visible = true
    
    -- Staggered text fade out (reverse order)
    for idx = #self.texts, 1, -1 do
        local textData = self.texts[idx]
        local delay = (#self.texts - idx) * 0.05
        task.delay(delay, function()
            if textData.frame and textData.frame.Parent then
                TweenService:Create(textData.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 20, 0, 0)
                }):Play()
                
                -- เช็คว่าเป็น text หรือ loader
                if textData.label then
                    TweenService:Create(textData.label, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play()
                elseif textData.loadingLabel then
                    TweenService:Create(textData.loadingLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play()
                    TweenService:Create(textData.percentLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play()
                end
            end
        end)
    end
    
    task.delay(0.15, function()
        TweenService:Create(self.titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(self.closeBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(self.titleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    task.delay(0.25, function()
        -- Black hole appear
        self.blackHole.BackgroundTransparency = 1
        self.blackHole.Size = UDim2.fromOffset(math.max(self.panelWidth, self.panelHeight) * 2.5, math.max(self.panelWidth, self.panelHeight) * 2.5)
        TweenService:Create(self.blackHole, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0
        }):Play()
        
        -- Panel shrink
        TweenService:Create(self.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(self.panelStroke, TweenInfo.new(0.4), {
            Transparency = 1
        }):Play()
    end)
    
    task.delay(0.5, function()
        -- Reverse spiral (sucking in effect)
        for i, spiral in ipairs(self.spirals) do
            spiral.ImageTransparency = 1
            spiral.Size = UDim2.fromOffset(800 - (i * 100), 800 - (i * 100))
            local direction = (i % 2 == 0) and -1 or 1
            
            task.delay((#self.spirals - i) * 0.05, function()
                TweenService:Create(spiral, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
                    Rotation = spiral.Rotation + (720 * direction),
                    Size = UDim2.fromOffset(0, 0),
                    ImageTransparency = 0
                }):Play()
            end)
        end
        
        -- Black hole shrink
        TweenService:Create(self.blackHole, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
    end)
    
    task.delay(1.3, function()
        self.panel.Visible = false
        self.kamuiContainer.Visible = false
        -- Reset text positions
        for _, textData in ipairs(self.texts) do
            textData.frame.Position = UDim2.new(0, 0, 0, 0)
        end
    end)
end

function KaitunUI:Open()
    if self.isOpen then return end
    self.isOpen = true
    self:ExpandOpen()  -- ใช้ animation ขยายจากปุ่ม
end

function KaitunUI:Close()
    if not self.isOpen then return end
    self.isOpen = false
    self:CollapseClose()  -- ใช้ animation หดกลับเป็นปุ่ม
end

function KaitunUI:Toggle()
    if self.isOpen then
        self:Close()
    else
        self:Open()
    end
end

function KaitunUI:AddText(text, config)
    config = config or {}
    local textColor = config.color or Color3.new(1, 1, 1)
    local fontSize = config.fontSize or 14
    local font = config.font or Enum.Font.Gotham
    local bgColor = config.backgroundColor or Color3.fromRGB(30, 30, 35)
    local animate = config.animate ~= false -- default true
    
    local textFrame = Instance.new("Frame", self.scrollFrame)
    textFrame.Size = UDim2.new(1, -10, 0, 36)
    textFrame.BackgroundColor3 = bgColor
    textFrame.BorderSizePixel = 0
    Instance.new("UICorner", textFrame).CornerRadius = UDim.new(0, 8)
    
    local textLabel = Instance.new("TextLabel", textFrame)
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.fromOffset(10, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.Font = font
    textLabel.TextSize = fontSize
    textLabel.TextColor3 = textColor
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextWrapped = true
    
    -- Animation เข้ามาสวยๆ
    if animate and self.isOpen then
        textFrame.BackgroundTransparency = 1
        textFrame.Position = UDim2.new(0, 0, 0, 30)
        textLabel.TextTransparency = 1
        
        task.delay(0.05, function()
            TweenService:Create(textFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                TextTransparency = 0
            }):Play()
        end)
    else
        textFrame.BackgroundTransparency = self.isOpen and 0 or 1
        textLabel.TextTransparency = self.isOpen and 0 or 1
    end
    
    local textData = {
        frame = textFrame,
        label = textLabel,
        text = text
    }
    
    -- SetText method with smooth animation (chainable)
    function textData:SetText(newText)
        self.text = newText
        -- Fade out
        TweenService:Create(self.label, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        
        task.delay(0.15, function()
            self.label.Text = newText
            -- Fade in
            TweenService:Create(self.label, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                TextTransparency = 0
            }):Play()
        end)
        return self
    end
    
    -- SetColor method (chainable)
    function textData:SetColor(color)
        self.label.TextColor3 = color
        return self
    end
    
    -- SetBackgroundColor method (chainable)
    function textData:SetBackgroundColor(color)
        self.frame.BackgroundColor3 = color
        return self
    end
    
    -- Rainbow color effect (chainable)
    function textData:Rainbow(speed)
        speed = speed or 1
        if self.rainbowConnection then
            self.rainbowConnection:Disconnect()
        end
        local hue = 0
        self.rainbowConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
            hue = (hue + dt * speed * 100) % 360
            self.label.TextColor3 = Color3.fromHSV(hue / 360, 1, 1)
        end)
        return self
    end
    
    -- Stop rainbow effect (chainable)
    function textData:StopRainbow()
        if self.rainbowConnection then
            self.rainbowConnection:Disconnect()
            self.rainbowConnection = nil
        end
        return self
    end
    
    -- Pulse between red and green (for status check)
    function textData:StatusPulse(speed)
        speed = speed or 1
        if self.pulseConnection then
            self.pulseConnection:Disconnect()
        end
        local t = 0
        self.pulseConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
            t = t + dt * speed
            local lerp = (math.sin(t * math.pi) + 1) / 2
            self.label.TextColor3 = Color3.fromRGB(
                255 * (1 - lerp),
                255 * lerp,
                0
            )
        end)
        return self
    end
    
    -- Stop pulse effect (chainable)
    function textData:StopPulse()
        if self.pulseConnection then
            self.pulseConnection:Disconnect()
            self.pulseConnection = nil
        end
        return self
    end
    
    -- Set status color (red = false, green = true)
    function textData:SetStatus(isGood)
        self:StopPulse()
        if isGood then
            self.label.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            self.label.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        return self
    end
    
    table.insert(self.texts, textData)
    
    return textData
end

function KaitunUI:RemoveText(textData)
    for i, data in ipairs(self.texts) do
        if data == textData then
            data.frame:Destroy()
            table.remove(self.texts, i)
            break
        end
    end
end

function KaitunUI:ClearTexts()
    for _, textData in ipairs(self.texts) do
        textData.frame:Destroy()
    end
    self.texts = {}
end

function KaitunUI:SetTitle(title)
    self.title = title
    self.titleLabel.Text = title
end

function KaitunUI:SetAccentColor(color)
    self.accentColor = color
    self.panelStroke.Color = color
    self.scrollFrame.ScrollBarImageColor3 = color
    for _, spiral in ipairs(self.spirals) do
        spiral.ImageColor3 = color
    end
end

-- Loader with progress bar and spinning circle (centered)
function KaitunUI:AddLoader(config)
    config = config or {}
    local text = config.text or "Loading..."
    local barColor = config.barColor or self.accentColor
    local bgColor = config.backgroundColor or Color3.fromRGB(30, 30, 35)
    
    -- Loader อยู่ตรงกลาง panel (ไม่ใช่ใน scrollFrame)
    local loaderFrame = Instance.new("Frame", self.panel)
    loaderFrame.Size = UDim2.new(0.8, 0, 0, 140)
    loaderFrame.Position = UDim2.fromScale(0.5, 0.5)
    loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    loaderFrame.BackgroundColor3 = bgColor
    loaderFrame.BackgroundTransparency = 0
    loaderFrame.BorderSizePixel = 0
    loaderFrame.ZIndex = 10
    Instance.new("UICorner", loaderFrame).CornerRadius = UDim.new(0, 12)
    
    -- Spinning circle container (centered above text)
    local spinnerContainer = Instance.new("Frame", loaderFrame)
    spinnerContainer.Size = UDim2.fromOffset(40, 40)
    spinnerContainer.Position = UDim2.new(0.5, 0, 0, 15)
    spinnerContainer.AnchorPoint = Vector2.new(0.5, 0)
    spinnerContainer.BackgroundTransparency = 1
    spinnerContainer.BorderSizePixel = 0
    spinnerContainer.ZIndex = 10
    
    -- Spinner logo (วงกลมหมุน)
    local spinner = Instance.new("ImageLabel", spinnerContainer)
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundTransparency = 1
    spinner.Image = "rbxassetid://78590114316385"
    spinner.ImageTransparency = 0
    spinner.ZIndex = 10
    
    -- Spinner animation
    local spinConnection
    local spinAngle = 0
    spinConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
        spinAngle = spinAngle + dt * 180
        spinner.Rotation = spinAngle
    end)
    
    -- Loading text (centered)
    local loadingLabel = Instance.new("TextLabel", loaderFrame)
    loadingLabel.Size = UDim2.new(1, -20, 0, 20)
    loadingLabel.Position = UDim2.new(0.5, 0, 0, 60)
    loadingLabel.AnchorPoint = Vector2.new(0.5, 0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = text
    loadingLabel.ZIndex = 10
    loadingLabel.Font = Enum.Font.GothamBold
    loadingLabel.TextSize = 14
    loadingLabel.TextColor3 = Color3.new(1, 1, 1)
    loadingLabel.TextXAlignment = Enum.TextXAlignment.Center
    loadingLabel.TextTransparency = 0
    
    -- Progress bar background (below text)
    local barBg = Instance.new("Frame", loaderFrame)
    barBg.Size = UDim2.new(0.9, 0, 0, 8)
    barBg.Position = UDim2.new(0.5, 0, 0, 90)
    barBg.AnchorPoint = Vector2.new(0.5, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 10
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
    
    -- Progress bar fill
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = barColor
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 10
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)
    
    -- Glow effect on bar
    local barGlow = Instance.new("ImageLabel", barFill)
    barGlow.Size = UDim2.new(1, 10, 1, 10)
    barGlow.Position = UDim2.fromScale(0.5, 0.5)
    barGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    barGlow.BackgroundTransparency = 1
    barGlow.Image = "rbxassetid://5028857084"
    barGlow.ImageColor3 = barColor
    barGlow.ZIndex = 10
    
    -- Percentage text (below progress bar)
    local percentLabel = Instance.new("TextLabel", loaderFrame)
    percentLabel.Size = UDim2.new(1, 0, 0, 20)
    percentLabel.Position = UDim2.new(0.5, 0, 0, 105)
    percentLabel.AnchorPoint = Vector2.new(0.5, 0)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.TextSize = 16
    percentLabel.TextColor3 = barColor
    percentLabel.TextXAlignment = Enum.TextXAlignment.Center
    percentLabel.TextTransparency = 0
    percentLabel.ZIndex = 10
    barGlow.ImageTransparency = 0.6
    barGlow.ScaleType = Enum.ScaleType.Slice
    barGlow.SliceCenter = Rect.new(24, 24, 276, 276)
    
    local loaderData = {
        frame = loaderFrame,
        spinner = spinner,
        spinnerContainer = spinnerContainer,
        loadingLabel = loadingLabel,
        percentLabel = percentLabel,
        barBg = barBg,
        barFill = barFill,
        barGlow = barGlow,
        spinConnection = spinConnection,
        progress = 0
    }
    
    -- SetProgress method (0-100)
    function loaderData:SetProgress(percent)
        percent = math.clamp(percent, 0, 100)
        self.progress = percent
        
        TweenService:Create(self.barFill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(percent / 100, 0, 1, 0)
        }):Play()
        
        -- Animate percentage text
        local currentPercent = tonumber(self.percentLabel.Text:match("%d+")) or 0
        local steps = math.abs(percent - currentPercent)
        if steps > 0 then
            for i = 1, steps do
                task.delay(i * 0.01, function()
                    local newVal = currentPercent + (percent > currentPercent and i or -i)
                    self.percentLabel.Text = math.floor(newVal) .. "%"
                end)
            end
        end
    end
    
    -- SetText method
    function loaderData:SetText(newText)
        TweenService:Create(self.loadingLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        
        task.delay(0.15, function()
            self.loadingLabel.Text = newText
            TweenService:Create(self.loadingLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                TextTransparency = 0
            }):Play()
        end)
    end
    
    -- SetColor method
    function loaderData:SetColor(color)
        self.spinner.ImageColor3 = color
        self.barFill.BackgroundColor3 = color
        self.barGlow.ImageColor3 = color
        self.percentLabel.TextColor3 = color
    end
    
    -- Complete method (shows checkmark then fade out)
    function loaderData:Complete(callback)
        self.spinConnection:Disconnect()
        
        TweenService:Create(self.spinner, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            ImageTransparency = 1
        }):Play()
        
        task.delay(0.3, function()
            self.spinner.Image = "rbxassetid://6031094667" -- checkmark
            self.spinner.ImageColor3 = Color3.fromRGB(100, 255, 100)
            self.spinner.Rotation = 0
            TweenService:Create(self.spinner, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                ImageTransparency = 0
            }):Play()
        end)
        
        self:SetProgress(100)
        self:SetText("Complete!")
        
        -- รอแสดง checkmark แล้ว fade out loader
        task.delay(1, function()
            -- Fade out loader
            TweenService:Create(self.frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(self.loadingLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                TextTransparency = 1
            }):Play()
            TweenService:Create(self.percentLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                TextTransparency = 1
            }):Play()
            TweenService:Create(self.spinner, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                ImageTransparency = 1
            }):Play()
            TweenService:Create(self.barBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(self.barFill, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(0.5, function()
                self:Destroy()
                if callback then
                    callback()
                end
            end)
        end)
    end
    
    -- Destroy method
    function loaderData:Destroy()
        if self.spinConnection then
            self.spinConnection:Disconnect()
        end
        self.frame:Destroy()
    end
    
    table.insert(self.texts, loaderData)
    
    return loaderData
end

function KaitunUI:Destroy()
    self.gui:Destroy()
end

return KaitunUI


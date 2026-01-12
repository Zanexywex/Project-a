if game.CoreGui:FindFirstChild("awidhiahsdibawgduyiagwiydgaiysdgiaywdgiaysgdiagwdiaysdguiaywdguaywgduaysdguaywdgauywdga") then
    game.CoreGui:FindFirstChild("awidhiahsdibawgduyiagwiydgaiysdgiaywdgiaysgdiagwdiaysdguiaywdguaywgduaysdguaywdgauywdga"):Destroy()
end

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.Parent = game.CoreGui

local loadBlur = Instance.new("BlurEffect")
loadBlur.Size = 0
loadBlur.Parent = Lighting

TweenService:Create(loadBlur, TweenInfo.new(0.5), {Size = 24}):Play()

local overlay = Instance.new("Frame", loadingGui)
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.3
overlay.BorderSizePixel = 0

local loadBox = Instance.new("Frame", loadingGui)
loadBox.Size = UDim2.fromOffset(0, 0)
loadBox.Position = UDim2.fromScale(0.5, 0.5)
loadBox.AnchorPoint = Vector2.new(0.5, 0.5)
loadBox.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", loadBox).CornerRadius = UDim.new(0, 20)

local loadBoxStroke = Instance.new("UIStroke", loadBox)
loadBoxStroke.Color = Color3.fromRGB(0, 170, 255)
loadBoxStroke.Thickness = 2
loadBoxStroke.Transparency = 0.5

TweenService:Create(loadBox, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.fromOffset(200, 180)
}):Play()

task.wait(0.3)

local spinnerContainer = Instance.new("Frame", loadBox)
spinnerContainer.Size = UDim2.fromOffset(60, 60)
spinnerContainer.Position = UDim2.new(0.5, 0, 0.35, 0)
spinnerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
spinnerContainer.BackgroundTransparency = 1

local spinner = Instance.new("Frame", spinnerContainer)
spinner.Size = UDim2.fromScale(1, 1)
spinner.BackgroundTransparency = 1

local spinnerRing = Instance.new("UIStroke", spinner)
spinnerRing.Color = Color3.fromRGB(0, 170, 255)
spinnerRing.Thickness = 4
spinnerRing.Transparency = 0

Instance.new("UICorner", spinner).CornerRadius = UDim.new(1, 0)

local spinnerArc = Instance.new("Frame", spinnerContainer)
spinnerArc.Size = UDim2.fromScale(1, 1)
spinnerArc.BackgroundTransparency = 1

local arcStroke = Instance.new("UIStroke", spinnerArc)
arcStroke.Color = Color3.fromRGB(60, 60, 60)
arcStroke.Thickness = 4
arcStroke.Transparency = 0.5

Instance.new("UICorner", spinnerArc).CornerRadius = UDim.new(1, 0)

local spinnerGlow = Instance.new("Frame", spinnerContainer)
spinnerGlow.Size = UDim2.fromScale(1.2, 1.2)
spinnerGlow.Position = UDim2.fromScale(0.5, 0.5)
spinnerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
spinnerGlow.BackgroundTransparency = 1

local glowStroke = Instance.new("UIStroke", spinnerGlow)
glowStroke.Color = Color3.fromRGB(0, 170, 255)
glowStroke.Thickness = 6
glowStroke.Transparency = 0.7

Instance.new("UICorner", spinnerGlow).CornerRadius = UDim.new(1, 0)

local loadText = Instance.new("TextLabel", loadBox)
loadText.Size = UDim2.new(1, 0, 0, 20)
loadText.Position = UDim2.new(0, 0, 0.7, 0)
loadText.BackgroundTransparency = 1
loadText.Text = "Loading"
loadText.Font = Enum.Font.GothamBold
loadText.TextSize = 16
loadText.TextColor3 = Color3.new(1, 1, 1)

local progressBg = Instance.new("Frame", loadBox)
progressBg.Size = UDim2.new(0.7, 0, 0, 4)
progressBg.Position = UDim2.new(0.15, 0, 0.85, 0)
progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame", progressBg)
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

local progressGlow = Instance.new("Frame", progressFill)
progressGlow.Size = UDim2.new(1, 0, 3, 0)
progressGlow.Position = UDim2.fromScale(0, -1)
progressGlow.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
progressGlow.BackgroundTransparency = 0.7
Instance.new("UICorner", progressGlow).CornerRadius = UDim.new(1, 0)

local spinSpeed = 1.5
local spinning = true

task.spawn(function()
	while spinning do
		spinnerContainer.Rotation = spinnerContainer.Rotation + 6
		spinnerGlow.Rotation = spinnerGlow.Rotation - 3
		task.wait(0.016)
	end
end)

task.spawn(function()
	local dots = {"Loading", "Loading.", "Loading..", "Loading..."}
	local i = 1
	while spinning do
		loadText.Text = dots[i]
		i = i % 4 + 1
		task.wait(0.3)
	end
end)

local loadSteps = {"Initializing...", "Loading UI...", "Setting up...", "Almost ready...", "Done!"}
for i, step in ipairs(loadSteps) do
	TweenService:Create(progressFill, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
		Size = UDim2.fromScale(i / #loadSteps, 1)
	}):Play()
	task.wait(0.35)
end

spinning = false
loadText.Text = "Ready!"

task.wait(0.3)

TweenService:Create(spinnerRing, TweenInfo.new(0.2), {Transparency = 1}):Play()
TweenService:Create(arcStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
TweenService:Create(glowStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()

local checkmark = Instance.new("TextLabel", loadBox)
checkmark.Size = UDim2.fromOffset(50, 50)
checkmark.Position = UDim2.new(0.5, 0, 0.35, 0)
checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
checkmark.BackgroundTransparency = 1
checkmark.Text = "✅"
checkmark.Font = Enum.Font.GothamBold
checkmark.TextSize = 0
checkmark.TextColor3 = Color3.fromRGB(0, 200, 100)

TweenService:Create(checkmark, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
	TextSize = 40
}):Play()

task.wait(0.5)

TweenService:Create(loadBox, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
	Size = UDim2.fromOffset(0, 0)
}):Play()

TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadBlur, TweenInfo.new(0.4), {Size = 0}):Play()

task.wait(0.4)
loadingGui:Destroy()
loadBlur:Destroy()

local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local gui = Instance.new("ScreenGui")
gui.Name = "awidhiahsdibawgduyiagwiydgaiysdgiaywdgiaysgdiagwdiaysdguiaywdguaywgduaysdguaywdgauywdga"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local openBtn = Instance.new("ImageButton", gui)
openBtn.Size = UDim2.fromOffset(56,56)
openBtn.Position = UDim2.fromScale(0.5, 0.03)
openBtn.AnchorPoint = Vector2.new(0.5,0)
openBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
openBtn.AutoButtonColor = false
openBtn.Image = "rbxassetid://70961657488991"
openBtn.ImageColor3 = Color3.new(1,1,1)
openBtn.ScaleType = Enum.ScaleType.Fit
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)

local stroke = Instance.new("UIStroke", openBtn)
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 2
stroke.Transparency = 0.2

local rotating = false


_G.UI = _G.UI or {}
local UI = _G.UI
UI.Panels = {}
UI.PanelCount = 0

UI.TabButtons = {}
UI.CurrentTab = 1
UI.TabBar = nil
UI.TabIndicator = nil
UI.OpenPanels = {}
UI.IsOpen = false
UI.Popups = {}
UI.Keybinds = {}
UI.KeybindPanel = nil

function UI:CloseAllPopups()
	for _, data in ipairs(self.Popups) do
		if data.popup and data.popup.Parent then
			data.popup:Destroy()
		end
		if data.onClose then
			data.onClose()
		end
	end
	self.Popups = {}
end

function UI:AnimateAndClosePopups()
	for _, data in ipairs(self.Popups) do
		if data.popup and data.popup.Parent then
			local tween = TweenService:Create(data.popup, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.new(data.popup.Position.X.Scale, data.popup.Position.X.Offset, 0, -400)
			})
			tween:Play()
			tween.Completed:Once(function()
				if data.popup and data.popup.Parent then
					data.popup:Destroy()
				end
				if data.onClose then
					data.onClose()
				end
			end)
		end
	end
	self.Popups = {}
end

function UI:RegisterPopup(popup, onClose)
	table.insert(self.Popups, {popup = popup, onClose = onClose})
end

_G.UIPanelStates = _G.UIPanelStates or {}

function UI:SavePanelState(index)
	local panel = self.Panels[index]
	if not panel then return end
	
	_G.UIPanelStates[index] = {
		isOpen = self.OpenPanels[index] or false,
		position = {
			xScale = panel.Position.X.Scale,
			xOffset = panel.Position.X.Offset,
			yScale = panel.Position.Y.Scale,
			yOffset = panel.Position.Y.Offset
		}
	}
end

function UI:LoadPanelState(index)
	local state = _G.UIPanelStates[index]
	if not state then return nil end
	return state
end

function UI:SaveAllPanelStates()
	for i = 1, #self.Panels do
		self:SavePanelState(i)
	end
end

function UI:CreateTabBar()
	if self.TabBar then return end
	
	local tabBar = Instance.new("Frame", gui)
	tabBar.Size = UDim2.fromOffset(400, 42)
	tabBar.Position = UDim2.new(0.5, 0, 0, -50)
	tabBar.AnchorPoint = Vector2.new(0.5, 0)
	tabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	tabBar.Visible = false
	Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 14)
	
	local tabStroke = Instance.new("UIStroke", tabBar)
	tabStroke.Color = Color3.fromRGB(45, 45, 45)
	tabStroke.Thickness = 1
	
	local dragBar = Instance.new("Frame", tabBar)
	dragBar.Size = UDim2.new(1, 0, 0, 12)
	dragBar.Position = UDim2.fromOffset(0, 0)
	dragBar.BackgroundTransparency = 1
	dragBar.ZIndex = 10
	
	local dragIcon = Instance.new("Frame", dragBar)
	dragIcon.Size = UDim2.fromOffset(40, 4)
	dragIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	dragIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	dragIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	dragIcon.ZIndex = 11
	Instance.new("UICorner", dragIcon).CornerRadius = UDim.new(1, 0)
	
	local draggingTab = false
	local dragStartTab, startPosTab
	
	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingTab = true
			dragStartTab = input.Position
			startPosTab = tabBar.Position
			TweenService:Create(tabStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(0, 170, 255),
				Thickness = 2
			}):Play()
			TweenService:Create(dragIcon, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			}):Play()
		end
	end)
	
	dragBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingTab = false
			TweenService:Create(tabStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(45, 45, 45),
				Thickness = 1
			}):Play()
			TweenService:Create(dragIcon, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			}):Play()
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if draggingTab and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStartTab
			tabBar.Position = UDim2.new(
				startPosTab.X.Scale,
				startPosTab.X.Offset + delta.X,
				startPosTab.Y.Scale,
				startPosTab.Y.Offset + delta.Y
			)
		end
	end)
	
	local tabContainer = Instance.new("Frame", tabBar)
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(1, -16, 1, -8)
	tabContainer.Position = UDim2.fromOffset(8, 4)
	tabContainer.BackgroundTransparency = 1
	
	local tabLayout = Instance.new("UIListLayout", tabContainer)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	
	local indicator = Instance.new("Frame", tabBar)
	indicator.Name = "Indicator"
	indicator.Size = UDim2.fromOffset(80, 32)
	indicator.Position = UDim2.fromOffset(8, 5)
	indicator.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	indicator.ZIndex = 0
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 10)
	
	local indicatorGradient = Instance.new("UIGradient", indicator)
	indicatorGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 200))
	})
	indicatorGradient.Rotation = 90
	
	self.TabBar = tabBar
	self.TabIndicator = indicator
	self.TabContainer = tabContainer
end

function UI:AddTab(name, panelIndex)
	if not self.TabBar then self:CreateTabBar() end
	
	local tabBtn = Instance.new("TextButton", self.TabContainer)
	tabBtn.Size = UDim2.fromOffset(80, 32)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 13
	tabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
	tabBtn.ZIndex = 2
	tabBtn.AutoButtonColor = false
	
	table.insert(self.TabButtons, {Button = tabBtn, Index = panelIndex, Name = name})
	self.OpenPanels[panelIndex] = false
	
	local totalWidth = #self.TabButtons * 86 + 16
	self.TabBar.Size = UDim2.fromOffset(math.max(totalWidth, 200), 42)
	
	tabBtn.MouseButton1Click:Connect(function()
		self:TogglePanel(panelIndex)
	end)

	tabBtn.MouseEnter:Connect(function()
		if not self.OpenPanels[panelIndex] then
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {
				TextColor3 = Color3.fromRGB(200, 200, 200)
			}):Play()
		end
	end)
	
	tabBtn.MouseLeave:Connect(function()
		if not self.OpenPanels[panelIndex] then
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {
				TextColor3 = Color3.fromRGB(140, 140, 140)
			}):Play()
		end
	end)
end

function UI:TogglePanel(index)
	local panel = self.Panels[index]
	if not panel then return end
	if not self.IsOpen then return end
	
	local isOpen = self.OpenPanels[index]
	self.OpenPanels[index] = not isOpen

	local tabBtn = self.TabButtons[index] and self.TabButtons[index].Button
	if tabBtn then
		TweenService:Create(tabBtn, TweenInfo.new(0.25), {
			TextColor3 = (not isOpen) and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 140)
		}):Play()
	end
	
	if not isOpen then
		local savedState = self:LoadPanelState(index)
		local targetPos
		
		if savedState and savedState.position then
			targetPos = UDim2.new(
				savedState.position.xScale,
				savedState.position.xOffset,
				savedState.position.yScale,
				savedState.position.yOffset
			)
		else
			local openCount = 0
			for i, open in pairs(self.OpenPanels) do
				if open and i < index then
					openCount += 1
				end
			end
			targetPos = UDim2.new(0.5, openCount * 30, 0.35, openCount * 20)
		end
		
		panel.Visible = true
		panel.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, 0, -400)
		TweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = targetPos
		}):Play()
	else
		self:SavePanelState(index)

		local tween = TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0, -400)
		})
		tween:Play()
		tween.Completed:Once(function()
			panel.Visible = false
		end)
	end
end

function UI:ClosePanel(index)
	local panel = self.Panels[index]
	if not panel or not self.OpenPanels[index] then return end
	
	self:AnimateAndClosePopups()
	
	self.OpenPanels[index] = false
	self:SavePanelState(index)

	local tabBtn = self.TabButtons[index] and self.TabButtons[index].Button
	if tabBtn then
		TweenService:Create(tabBtn, TweenInfo.new(0.25), {
			TextColor3 = Color3.fromRGB(140, 140, 140)
		}):Play()
	end
	
	local tween = TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0, -400)
	})
	tween:Play()
	tween.Completed:Once(function()
		panel.Visible = false
	end)
end

-- Register Keybind
function UI:RegisterKeybind(name, key, isToggle, getState)
	table.insert(self.Keybinds, {
		name = name,
		key = key,
		isToggle = isToggle,
		getState = getState,
		active = false
	})
	self:UpdateKeybindPanel()
end

-- Update Keybind State
function UI:UpdateKeybindState(name, active)
	for _, kb in ipairs(self.Keybinds) do
		if kb.name == name then
			kb.active = active
			break
		end
	end
	self:UpdateKeybindPanel()
end

-- Update Keybind Key
function UI:UpdateKeybindKey(name, newKey)
	for _, kb in ipairs(self.Keybinds) do
		if kb.name == name then
			kb.key = newKey
			break
		end
	end
	self:UpdateKeybindPanel()
end

-- Create Keybind Panel
function UI:CreateKeybindPanel()
	if self.KeybindPanel then return end
	
	local panel = Instance.new("Frame", gui)
	panel.Name = "KeybindPanel"
	panel.Size = UDim2.fromOffset(220, 300)
	panel.Position = UDim2.new(0, 15, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	panel.Visible = false
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
	
	local panelStroke = Instance.new("UIStroke", panel)
	panelStroke.Color = Color3.fromRGB(0, 170, 255)
	panelStroke.Thickness = 1
	panelStroke.Transparency = 0.5
	
	-- Title
	local title = Instance.new("TextLabel", panel)
	title.Size = UDim2.new(1, 0, 0, 36)
	title.BackgroundTransparency = 1
	title.Text = "⌨️ Keybinds"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextColor3 = Color3.new(1, 1, 1)
	
	-- Scroll container
	local scroll = Instance.new("ScrollingFrame", panel)
	scroll.Size = UDim2.new(1, -16, 1, -44)
	scroll.Position = UDim2.fromOffset(8, 36)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	
	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)
	
	self.KeybindPanel = panel
	self.KeybindScroll = scroll
end

-- Update Keybind Panel
function UI:UpdateKeybindPanel()
	if not self.KeybindPanel then self:CreateKeybindPanel() end
	
	local scroll = self.KeybindScroll
	-- Clear old items
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Create new items
	for _, kb in ipairs(self.Keybinds) do
		local item = Instance.new("Frame", scroll)
		item.Size = UDim2.new(1, -8, 0, 32)
		item.BackgroundColor3 = kb.active and Color3.fromRGB(0, 60, 80) or Color3.fromRGB(30, 30, 30)
		Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
		
		-- Active indicator
		local indicator = Instance.new("Frame", item)
		indicator.Size = UDim2.fromOffset(4, 20)
		indicator.Position = UDim2.new(0, 6, 0.5, 0)
		indicator.AnchorPoint = Vector2.new(0, 0.5)
		indicator.BackgroundColor3 = kb.active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(80, 80, 80)
		Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
		
		-- Name
		local nameLabel = Instance.new("TextLabel", item)
		nameLabel.Size = UDim2.new(0.6, -20, 1, 0)
		nameLabel.Position = UDim2.fromOffset(16, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = kb.name
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextSize = 12
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		
		-- Key badge
		local keyBadge = Instance.new("Frame", item)
		keyBadge.Size = UDim2.fromOffset(40, 22)
		keyBadge.Position = UDim2.new(1, -8, 0.5, 0)
		keyBadge.AnchorPoint = Vector2.new(1, 0.5)
		keyBadge.BackgroundColor3 = kb.active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
		Instance.new("UICorner", keyBadge).CornerRadius = UDim.new(0, 6)
		
		local keyText = Instance.new("TextLabel", keyBadge)
		keyText.Size = UDim2.fromScale(1, 1)
		keyText.BackgroundTransparency = 1
		keyText.Text = kb.key and kb.key.Name or "None"
		keyText.Font = Enum.Font.GothamBold
		keyText.TextSize = 10
		keyText.TextColor3 = Color3.new(1, 1, 1)
		
		-- Status text
		if kb.isToggle then
			local statusText = Instance.new("TextLabel", item)
			statusText.Size = UDim2.fromOffset(30, 14)
			statusText.Position = UDim2.new(1, -52, 0.5, 0)
			statusText.AnchorPoint = Vector2.new(1, 0.5)
			statusText.BackgroundTransparency = 1
			statusText.Text = kb.active and "ON" or "OFF"
			statusText.Font = Enum.Font.GothamBold
			statusText.TextSize = 9
			statusText.TextColor3 = kb.active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
		end
	end
end

-- Toggle Keybind Panel visibility
function UI:ToggleKeybindPanel()
	if not self.KeybindPanel then self:CreateKeybindPanel() end
	
	local panel = self.KeybindPanel
	if panel.Visible then
		self.KeybindFrame:Close()
	else
		self.KeybindFrame:Show()
	end
end

-- Keybind Frame API
UI.KeybindFrame = {}

function UI.KeybindFrame:Show()
	if not UI.KeybindPanel then UI:CreateKeybindPanel() end
	
	local panel = UI.KeybindPanel
	panel.Visible = true
	panel.Position = UDim2.new(0, -230, 0.5, 0)
	TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 15, 0.5, 0)
	}):Play()
end

function UI.KeybindFrame:Close()
	if not UI.KeybindPanel then return end
	
	local panel = UI.KeybindPanel
	TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(0, -230, 0.5, 0)
	}):Play()
	task.delay(0.3, function()
		panel.Visible = false
	end)
end

function UI.KeybindFrame:Toggle()
	if not UI.KeybindPanel then UI:CreateKeybindPanel() end
	
	if UI.KeybindPanel.Visible then
		UI.KeybindFrame:Close()
	else
		UI.KeybindFrame:Show()
	end
end

function UI:CreatePanel(name)
	UI.PanelCount += 1
	local index = UI.PanelCount

	local panel = Instance.new("Frame", gui)
	panel.Size = UDim2.fromOffset(520, 340)
	panel.Position = UDim2.new(0.5, 0, 0, -400)
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
	panel.ClipsDescendants = true
	panel.Visible = false
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)
	
	local panelStroke = Instance.new("UIStroke", panel)
	panelStroke.Color = Color3.fromRGB(40, 40, 40)
	panelStroke.Thickness = 1

	local title = Instance.new("TextLabel", panel)
	title.Name = "TitleBar"
	title.Size = UDim2.new(1,0,0,36)
	title.BackgroundTransparency = 1
	title.Text = name
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.new(1,1,1)
	
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
			
			TweenService:Create(panelStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(0, 170, 255),
				Thickness = 2
			}):Play()
		end
	end)
	
	title.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			
			self:SavePanelState(index)
			
			TweenService:Create(panelStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(40, 40, 40),
				Thickness = 1
			}):Play()
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
			panel.Position = newPos
		end
	end)
	
	local dragIcon = Instance.new("TextLabel", title)
	dragIcon.Size = UDim2.fromOffset(40, 6)
	dragIcon.Position = UDim2.new(0.5, 0, 0, 6)
	dragIcon.AnchorPoint = Vector2.new(0.5, 0)
	dragIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	dragIcon.BackgroundTransparency = 0.5
	dragIcon.Text = ""
	Instance.new("UICorner", dragIcon).CornerRadius = UDim.new(1, 0)
	
	local closeBtn = Instance.new("TextButton", panel)
	closeBtn.Size = UDim2.fromOffset(28, 28)
	closeBtn.Position = UDim2.new(1, -8, 0, 4)
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
	closeBtn.AutoButtonColor = false
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
	
	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(200, 60, 60),
			TextColor3 = Color3.new(1, 1, 1),
			Rotation = 90
		}):Play()
	end)
	
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			TextColor3 = Color3.fromRGB(150, 150, 150),
			Rotation = 0
		}):Play()
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		self:ClosePanel(index)
	end)
	
	self:AddTab(name, index)

	local body = Instance.new("Frame", panel)
	body.Position = UDim2.fromOffset(20,36)
	body.Size = UDim2.new(1,-40,1,-36)
	body.BackgroundTransparency = 1

	local function makeScroll(x)
		local s = Instance.new("ScrollingFrame", body)
		s.Size = UDim2.fromScale(0.45,1)
		s.Position = UDim2.fromScale(x,0)
		s.CanvasSize = UDim2.new(0,0,0,0)
		s.ScrollBarThickness = 6
		s.BackgroundTransparency = 1
		s.ScrollBarImageColor3 = Color3.fromRGB(50,50,50)

		local layout = Instance.new("UIListLayout", s)
		layout.Padding = UDim.new(0,8)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			s.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
		end)

		return s
	end


	local leftCol = makeScroll(0)
	leftCol.Size = UDim2.fromScale(0.45, 1)
	local rightCol = makeScroll(0.55)
	rightCol.Size = UDim2.fromScale(0.45, 1)
	
	-- centerCol in middle, position Y updates based on leftCol content
	local centerCol = Instance.new("Frame", body)
	centerCol.Size = UDim2.new(0.5, 0, 0, 50)
	centerCol.Position = UDim2.new(0.25, 0, 0, 0)
	centerCol.BackgroundTransparency = 1
	
	local centerLayout = Instance.new("UIListLayout", centerCol)
	centerLayout.Padding = UDim.new(0,8)
	centerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	-- Update centerCol size based on content
	centerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		centerCol.Size = UDim2.new(0.5, 0, 0, centerLayout.AbsoluteContentSize.Y + 10)
	end)
	
	-- Update centerCol position below leftCol content
	local function updateCenterPosition()
		local leftContentHeight = 0
		local leftLayout = leftCol:FindFirstChildOfClass("UIListLayout")
		if leftLayout then
			leftContentHeight = leftLayout.AbsoluteContentSize.Y
		end
		centerCol.Position = UDim2.new(0.25, 0, 0, leftContentHeight + 15)
	end
	
	-- Connect to leftCol CanvasSize to update when content changes
	leftCol:GetPropertyChangedSignal("CanvasSize"):Connect(updateCenterPosition)
	task.defer(updateCenterPosition)
	
	local PanelAPI = {}
	
	-- Create border glow effect
	local function createBorderGlow(element)
		local stroke = element:FindFirstChildOfClass("UIStroke")
		if not stroke then
			stroke = Instance.new("UIStroke", element)
			stroke.Color = Color3.fromRGB(0, 170, 255)
			stroke.Thickness = 0
			stroke.Transparency = 1
		end
		
		-- Animate border glow
		TweenService:Create(stroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Thickness = 2.5,
			Transparency = 0,
			Color = Color3.fromRGB(0, 200, 255)
		}):Play()
		
		-- Create gradient
		local gradient = stroke:FindFirstChildOfClass("UIGradient")
		if not gradient then
			gradient = Instance.new("UIGradient", stroke)
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 180)),
				ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0, 220, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 220, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 180))
			})
		end
		
		-- Animate gradient rotation
		local startRotation = gradient.Rotation
		task.spawn(function()
			for i = 0, 360, 8 do
				gradient.Rotation = startRotation + i
				task.wait(0.008)
			end
			gradient.Rotation = startRotation
			
			-- Fade out
			TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Thickness = 0,
				Transparency = 1
			}):Play()
		end)
	end

	function PanelAPI.CreateSwitch(parent, text, default, callback)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 36)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,-70,1,0)
		lbl.Position = UDim2.fromOffset(10,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local bg = Instance.new("Frame", h)
		bg.Size = UDim2.fromOffset(34,18)
		bg.Position = UDim2.new(1,-6,0.5,0)
		bg.AnchorPoint = Vector2.new(1,0.5)
		bg.BackgroundColor3 = default and Color3.fromRGB(0,170,255) or Color3.fromRGB(80,80,80)
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

		local knob = Instance.new("Frame", bg)
		knob.Size = UDim2.fromOffset(14,14)
		knob.Position = default and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2)
		knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

		local state = default
		
		local function toggleState()
			state = not state
			-- Border glow
			createBorderGlow(h)
			
			TweenService:Create(knob, TweenInfo.new(0.2), {
				Position = state and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2)
			}):Play()
			TweenService:Create(bg, TweenInfo.new(0.2), {
				BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(80,80,80)
			}):Play()
			if callback then callback(state) end
		end
		
		local btn = Instance.new("TextButton", h)
		btn.Size = UDim2.fromScale(1,1)
		btn.BackgroundTransparency = 1
		btn.Text = ""

		btn.MouseButton1Click:Connect(toggleState)
		
		local settingBtn = Instance.new("ImageButton", h)
		settingBtn.Size = UDim2.fromOffset(20, 20)
		settingBtn.Position = UDim2.new(1, -46, 0.5, 0)
		settingBtn.AnchorPoint = Vector2.new(1, 0.5)
		settingBtn.BackgroundTransparency = 1
		settingBtn.Image = "rbxassetid://3926307971"
		settingBtn.ImageRectOffset = Vector2.new(324, 124)
		settingBtn.ImageRectSize = Vector2.new(36, 36)
		settingBtn.ImageColor3 = Color3.fromRGB(100, 100, 100)
		settingBtn.Visible = false
		
		settingBtn.MouseEnter:Connect(function()
			TweenService:Create(settingBtn, TweenInfo.new(0.15), {
				ImageColor3 = Color3.fromRGB(0, 170, 255),
				Rotation = 45
			}):Play()
		end)
		
		settingBtn.MouseLeave:Connect(function()
			TweenService:Create(settingBtn, TweenInfo.new(0.15), {
				ImageColor3 = Color3.fromRGB(100, 100, 100),
				Rotation = 0
			}):Play()
		end)
		
		local switchAPI = {}
		local settingItems = {}
		local settingPopup = nil
		local popupOpen = false
		
		local function createSettingPopup()
			if settingPopup then settingPopup:Destroy() end
			
			settingPopup = Instance.new("Frame", gui)
			settingPopup.Size = UDim2.fromOffset(200, 0)
			local absPos = h.AbsolutePosition
			settingPopup.Position = UDim2.fromOffset(absPos.X + 230, absPos.Y)
			settingPopup.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			settingPopup.ClipsDescendants = true
			settingPopup.ZIndex = 200
			Instance.new("UICorner", settingPopup).CornerRadius = UDim.new(0, 12)
			UI:RegisterPopup(settingPopup, function()
				settingPopup = nil
				popupOpen = false
			end)
			
			local popupStroke = Instance.new("UIStroke", settingPopup)
			popupStroke.Color = Color3.fromRGB(0, 170, 255)
			popupStroke.Thickness = 2

			local titleBar = Instance.new("Frame", settingPopup)
			titleBar.Size = UDim2.new(1, 0, 0, 28)
			titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			titleBar.ZIndex = 201
			Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
			
			local cornerFix = Instance.new("Frame", titleBar)
			cornerFix.Size = UDim2.new(1, 0, 0, 10)
			cornerFix.Position = UDim2.new(0, 0, 1, -10)
			cornerFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			cornerFix.BorderSizePixel = 0
			cornerFix.ZIndex = 201
			
			local titleText = Instance.new("TextLabel", titleBar)
			titleText.Size = UDim2.new(1, -30, 1, 0)
			titleText.Position = UDim2.fromOffset(10, 0)
			titleText.BackgroundTransparency = 1
			titleText.Text = "Settings"
			titleText.Font = Enum.Font.GothamBold
			titleText.TextSize = 12
			titleText.TextColor3 = Color3.new(1, 1, 1)
			titleText.TextXAlignment = Enum.TextXAlignment.Left
			titleText.ZIndex = 202
			
			local closeBtn = Instance.new("TextButton", titleBar)
			closeBtn.Size = UDim2.fromOffset(20, 20)
			closeBtn.Position = UDim2.new(1, -6, 0.5, 0)
			closeBtn.AnchorPoint = Vector2.new(1, 0.5)
			closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			closeBtn.Text = "X"
			closeBtn.Font = Enum.Font.GothamBold
			closeBtn.TextSize = 10
			closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
			closeBtn.AutoButtonColor = false
			closeBtn.ZIndex = 202
			Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
			
			closeBtn.MouseEnter:Connect(function()
				TweenService:Create(closeBtn, TweenInfo.new(0.1), {
					BackgroundColor3 = Color3.fromRGB(200, 60, 60),
					TextColor3 = Color3.new(1, 1, 1)
				}):Play()
			end)
			
			closeBtn.MouseLeave:Connect(function()
				TweenService:Create(closeBtn, TweenInfo.new(0.1), {
					BackgroundColor3 = Color3.fromRGB(50, 50, 50),
					TextColor3 = Color3.fromRGB(150, 150, 150)
				}):Play()
			end)
			
			closeBtn.MouseButton1Click:Connect(function()
				local tween = TweenService:Create(settingPopup, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
					Size = UDim2.fromOffset(200, 0)
				})
				tween:Play()
				tween.Completed:Once(function()
					settingPopup:Destroy()
					settingPopup = nil
					popupOpen = false
				end)
			end)
			
			local dragging = false
			local dragStart, startPos
			
			titleBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = settingPopup.Position
				end
			end)
			
			titleBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local delta = input.Position - dragStart
					settingPopup.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
				end
			end)
			
			local content = Instance.new("ScrollingFrame", settingPopup)
			content.Size = UDim2.new(1, -12, 1, -34)
			content.Position = UDim2.fromOffset(6, 30)
			content.BackgroundTransparency = 1
			content.ScrollBarThickness = 4
			content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
			content.ZIndex = 201
			content.CanvasSize = UDim2.new(0, 0, 0, 0)
			
			local contentLayout = Instance.new("UIListLayout", content)
			contentLayout.Padding = UDim.new(0, 6)
			contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			
			contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 6)
			end)
			
			for _, item in ipairs(settingItems) do
				item.build(content)
			end
			
			local totalHeight = math.min(#settingItems * 38 + 40, 220)
			TweenService:Create(settingPopup, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Size = UDim2.fromOffset(200, totalHeight)
			}):Play()
		end
		
		settingBtn.MouseButton1Click:Connect(function()
			if popupOpen then
				if settingPopup then
					local tween = TweenService:Create(settingPopup, TweenInfo.new(0.15), {Size = UDim2.fromOffset(200, 0)})
					tween:Play()
					tween.Completed:Once(function() settingPopup:Destroy(); settingPopup = nil end)
				end
				popupOpen = false
			else
				popupOpen = true
				createSettingPopup()
			end
		end)
		
		function switchAPI:AddKeybind(name, key, cb)
			settingBtn.Visible = true
			local currentKey = key
			local conn = nil
			local keybindName = text .. " - " .. name
			
			-- Register keybind with UI
			UI:RegisterKeybind(keybindName, key, true, function() return state end)
			
			table.insert(settingItems, {
				build = function(parent)
					local row = Instance.new("Frame", parent)
					row.Size = UDim2.new(1, -8, 0, 28)
					row.BackgroundTransparency = 1
					row.ZIndex = 202
					
					local lbl = Instance.new("TextLabel", row)
					lbl.Size = UDim2.new(0.55, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.Text = name
					lbl.Font = Enum.Font.Gotham
					lbl.TextSize = 11
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.TextXAlignment = Enum.TextXAlignment.Left
					lbl.ZIndex = 202
					
					local keyBtn = Instance.new("TextButton", row)
					keyBtn.Size = UDim2.fromOffset(55, 22)
					keyBtn.Position = UDim2.new(1, 0, 0.5, 0)
					keyBtn.AnchorPoint = Vector2.new(1, 0.5)
					keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					keyBtn.Text = currentKey and currentKey.Name or "None"
					keyBtn.Font = Enum.Font.GothamBold
					keyBtn.TextSize = 10
					keyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
					keyBtn.AutoButtonColor = false
					keyBtn.ZIndex = 202
					Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)
					
					local listening = false
					keyBtn.MouseButton1Click:Connect(function()
						if listening then return end
						listening = true
						keyBtn.Text = "..."
						keyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
						keyBtn.TextColor3 = Color3.new(1, 1, 1)
						
						local ic = UserInputService.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.Keyboard then
								currentKey = input.KeyCode
								keyBtn.Text = input.KeyCode.Name
								keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
								keyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
								listening = false
								UI:UpdateKeybindKey(keybindName, currentKey)
								if conn then conn:Disconnect() end
								conn = UserInputService.InputBegan:Connect(function(inp)
									if inp.KeyCode == currentKey then 
										toggleState()
										UI:UpdateKeybindState(keybindName, state)
										if cb then cb(state) end 
									end
								end)
							end
						end)
						task.delay(5, function() if listening then ic:Disconnect(); listening = false; keyBtn.Text = currentKey and currentKey.Name or "None"; keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); keyBtn.TextColor3 = Color3.fromRGB(0, 170, 255) end end)
					end)
				end
			})
			
			if key then
				conn = UserInputService.InputBegan:Connect(function(inp)
					if inp.KeyCode == currentKey then 
						toggleState()
						UI:UpdateKeybindState(keybindName, state)
						if cb then cb(state) end 
					end
				end)
			end
			return switchAPI
		end
		
		function switchAPI:AddSlider(name, min, max, default, cb)
			settingBtn.Visible = true
			local value = math.clamp(default or min, min, max)
			
			table.insert(settingItems, {
				build = function(parent)
					local row = Instance.new("Frame", parent)
					row.Size = UDim2.new(1, -8, 0, 38)
					row.BackgroundTransparency = 1
					row.ZIndex = 202
					
					local lbl = Instance.new("TextLabel", row)
					lbl.Size = UDim2.new(0.6, 0, 0, 14)
					lbl.Text = name
					lbl.Font = Enum.Font.Gotham
					lbl.TextSize = 10
					lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
					lbl.BackgroundTransparency = 1
					lbl.TextXAlignment = Enum.TextXAlignment.Left
					lbl.ZIndex = 202
					
					local valLbl = Instance.new("TextLabel", row)
					valLbl.Size = UDim2.fromOffset(40, 14)
					valLbl.Position = UDim2.new(1, 0, 0, 0)
					valLbl.AnchorPoint = Vector2.new(1, 0)
					valLbl.Text = tostring(value)
					valLbl.Font = Enum.Font.GothamBold
					valLbl.TextSize = 10
					valLbl.TextColor3 = Color3.fromRGB(0, 170, 255)
					valLbl.BackgroundTransparency = 1
					valLbl.TextXAlignment = Enum.TextXAlignment.Right
					valLbl.ZIndex = 202
					
					local bar = Instance.new("Frame", row)
					bar.Size = UDim2.new(1, 0, 0, 6)
					bar.Position = UDim2.fromOffset(0, 20)
					bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					bar.ZIndex = 202
					Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
					
					local fill = Instance.new("Frame", bar)
					fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
					fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
					fill.ZIndex = 203
					Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
					
					local dragging = false
					bar.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
						end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							local a = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
							value = math.floor(min + (max - min) * a + 0.5)
							fill.Size = UDim2.fromScale(a, 1)
							valLbl.Text = tostring(value)
							if cb then cb(value) end
						end
					end)
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
					end)
				end
			})
			return switchAPI
		end
		
		function switchAPI:AddDropdown(name, list, default, cb)
			settingBtn.Visible = true
			local val = default
			
			table.insert(settingItems, {
				build = function(parent)
					local row = Instance.new("Frame", parent)
					row.Size = UDim2.new(1, -8, 0, 28)
					row.BackgroundTransparency = 1
					row.ZIndex = 202
					
					local lbl = Instance.new("TextLabel", row)
					lbl.Size = UDim2.new(0.4, 0, 1, 0)
					lbl.Text = name
					lbl.Font = Enum.Font.Gotham
					lbl.TextSize = 10
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.BackgroundTransparency = 1
					lbl.TextXAlignment = Enum.TextXAlignment.Left
					lbl.ZIndex = 202
					
					local btn = Instance.new("TextButton", row)
					btn.Size = UDim2.new(0.58, 0, 0, 22)
					btn.Position = UDim2.new(1, 0, 0.5, 0)
					btn.AnchorPoint = Vector2.new(1, 0.5)
					btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					btn.Text = val or "Select"
					btn.Font = Enum.Font.Gotham
					btn.TextSize = 10
					btn.TextColor3 = Color3.new(1, 1, 1)
					btn.ZIndex = 202
					Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
					
					local dropFrame = nil
					btn.MouseButton1Click:Connect(function()
						if dropFrame then dropFrame:Destroy(); dropFrame = nil; return end
						dropFrame = Instance.new("Frame", gui)
						dropFrame.Size = UDim2.fromOffset(100, math.min(#list * 22 + 6, 100))
						dropFrame.Position = UDim2.fromOffset(btn.AbsolutePosition.X, btn.AbsolutePosition.Y + 24)
						dropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
						dropFrame.ZIndex = 250
						Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 6)
						
						local scroll = Instance.new("ScrollingFrame", dropFrame)
						scroll.Size = UDim2.new(1, -4, 1, -4)
						scroll.Position = UDim2.fromOffset(2, 2)
						scroll.BackgroundTransparency = 1
						scroll.ScrollBarThickness = 3
						scroll.ZIndex = 251
						Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)
						
						for _, v in ipairs(list) do
							local opt = Instance.new("TextButton", scroll)
							opt.Size = UDim2.new(1, -2, 0, 18)
							opt.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
							opt.Text = v
							opt.Font = Enum.Font.Gotham
							opt.TextSize = 10
							opt.TextColor3 = Color3.new(1, 1, 1)
							opt.ZIndex = 252
							Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)
							opt.MouseButton1Click:Connect(function()
								val = v; btn.Text = v; dropFrame:Destroy(); dropFrame = nil
								if cb then cb(v) end
							end)
						end
					end)
				end
			})
			return switchAPI
		end
		
		function switchAPI:AddColorPicker(name, r, g, b, cb)
			settingBtn.Visible = true
			local color = Color3.fromRGB(r or 255, g or 255, b or 255)
			local currentR, currentG, currentB = r or 255, g or 255, b or 255
			
			table.insert(settingItems, {
				build = function(parent)
					local row = Instance.new("Frame", parent)
					row.Size = UDim2.new(1, -8, 0, 28)
					row.BackgroundTransparency = 1
					row.ZIndex = 202
					
					local lbl = Instance.new("TextLabel", row)
					lbl.Size = UDim2.new(0.6, 0, 1, 0)
					lbl.Text = name
					lbl.Font = Enum.Font.Gotham
					lbl.TextSize = 10
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.BackgroundTransparency = 1
					lbl.TextXAlignment = Enum.TextXAlignment.Left
					lbl.ZIndex = 202
					
					local colorBtn = Instance.new("TextButton", row)
					colorBtn.Size = UDim2.fromOffset(28, 20)
					colorBtn.Position = UDim2.new(1, 0, 0.5, 0)
					colorBtn.AnchorPoint = Vector2.new(1, 0.5)
					colorBtn.BackgroundColor3 = color
					colorBtn.Text = ""
					colorBtn.ZIndex = 202
					Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 5)
					
					colorBtn.MouseButton1Click:Connect(function()
						local picker = Instance.new("Frame", gui)
						picker.Size = UDim2.fromOffset(160, 140)
						picker.Position = UDim2.fromOffset(colorBtn.AbsolutePosition.X - 130, colorBtn.AbsolutePosition.Y)
						picker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
						picker.ZIndex = 260
						Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)
						Instance.new("UIStroke", picker).Color = Color3.fromRGB(0, 170, 255)
						
						local h, s, v = Color3.toHSV(color)
						
						local hueBar = Instance.new("Frame", picker)
						hueBar.Size = UDim2.new(1, -16, 0, 12)
						hueBar.Position = UDim2.fromOffset(8, 8)
						hueBar.ZIndex = 261
						Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)
						local hg = Instance.new("UIGradient", hueBar)
						hg.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
							ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
							ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
							ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
							ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
							ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
							ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
						})
						
						local preview = Instance.new("Frame", picker)
						preview.Size = UDim2.fromOffset(35, 35)
						preview.Position = UDim2.fromOffset(8, 28)
						preview.BackgroundColor3 = color
						preview.ZIndex = 261
						Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)
						
						-- RGB Inputs
						local function createMiniInput(labelText, val, yPos)
							local container = Instance.new("Frame", picker)
							container.Size = UDim2.fromOffset(95, 18)
							container.Position = UDim2.fromOffset(50, yPos)
							container.BackgroundTransparency = 1
							container.ZIndex = 261
							
							local lb = Instance.new("TextLabel", container)
							lb.Size = UDim2.fromOffset(14, 18)
							lb.BackgroundTransparency = 1
							lb.Text = labelText
							lb.Font = Enum.Font.GothamBold
							lb.TextSize = 10
							lb.TextColor3 = labelText == "R" and Color3.fromRGB(255,100,100) or (labelText == "G" and Color3.fromRGB(100,255,100) or Color3.fromRGB(100,150,255))
							lb.ZIndex = 261
							
							local inp = Instance.new("TextBox", container)
							inp.Size = UDim2.fromOffset(40, 18)
							inp.Position = UDim2.fromOffset(18, 0)
							inp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
							inp.Text = tostring(val)
							inp.Font = Enum.Font.GothamBold
							inp.TextSize = 10
							inp.TextColor3 = Color3.new(1, 1, 1)
							inp.ClearTextOnFocus = false
							inp.ZIndex = 261
							Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 4)
							
							return inp
						end
						
						local rInp = createMiniInput("R", currentR, 28)
						local gInp = createMiniInput("G", currentG, 48)
						local bInp = createMiniInput("B", currentB, 68)
						
						local function updateFromInputs()
							currentR = math.clamp(tonumber(rInp.Text) or 0, 0, 255)
							currentG = math.clamp(tonumber(gInp.Text) or 0, 0, 255)
							currentB = math.clamp(tonumber(bInp.Text) or 0, 0, 255)
							color = Color3.fromRGB(currentR, currentG, currentB)
							h, s, v = Color3.toHSV(color)
							preview.BackgroundColor3 = color
							colorBtn.BackgroundColor3 = color
						end
						
						rInp.FocusLost:Connect(updateFromInputs)
						gInp.FocusLost:Connect(updateFromInputs)
						bInp.FocusLost:Connect(updateFromInputs)
						
						local okBtn = Instance.new("TextButton", picker)
						okBtn.Size = UDim2.fromOffset(60, 22)
						okBtn.Position = UDim2.fromOffset(92, 110)
						okBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
						okBtn.Text = "OK"
						okBtn.Font = Enum.Font.GothamBold
						okBtn.TextSize = 10
						okBtn.TextColor3 = Color3.new(1, 1, 1)
						okBtn.ZIndex = 261
						Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0, 5)
						
						hueBar.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								h = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
								color = Color3.fromHSV(h, s, v)
								currentR = math.floor(color.R * 255)
								currentG = math.floor(color.G * 255)
								currentB = math.floor(color.B * 255)
								preview.BackgroundColor3 = color
								colorBtn.BackgroundColor3 = color
								rInp.Text = tostring(currentR)
								gInp.Text = tostring(currentG)
								bInp.Text = tostring(currentB)
							end
						end)
						
						okBtn.MouseButton1Click:Connect(function()
							picker:Destroy()
							if cb then cb(color) end
						end)
					end)
				end
			})
			return switchAPI
		end
		
		return switchAPI
	end

	function PanelAPI.CreateTextbox(parent, placeholder, default, callback)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 40)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local label = Instance.new("TextLabel", h)
		label.Text = placeholder
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(160,160,160)
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(12,14)
		label.Size = UDim2.new(1,-24,0,14)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local box = Instance.new("TextBox", h)
		box.BackgroundTransparency = 1
		box.Text = default or ""
		box.Font = Enum.Font.Gotham
		box.TextSize = 14
		box.TextColor3 = Color3.new(1,1,1)
		box.ClearTextOnFocus = false
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Position = UDim2.fromOffset(8,10)
		box.Size = UDim2.new(1,-16,1,-12)

		local floated = false

		local function floatUp()
			if floated then return end
			floated = true
			TweenService:Create(label, TweenInfo.new(0.18), {
				Position = UDim2.fromOffset(10, 2),
				TextSize = 11,
				TextColor3 = Color3.fromRGB(0,170,255)
			}):Play()
		end

		local function floatDown()
			if box.Text ~= "" then return end
			floated = false
			TweenService:Create(label, TweenInfo.new(0.18), {
				Position = UDim2.fromOffset(12,14),
				TextSize = 12,
				TextColor3 = Color3.fromRGB(160,160,160)
			}):Play()
		end

		if box.Text ~= "" then floatUp() end

		box.Focused:Connect(floatUp)
		box.FocusLost:Connect(function()
			floatDown()
			if callback then callback(box.Text) end
		end)
	end

	function PanelAPI.CreateButton(parent, text, callback)
		local b = Instance.new("TextButton", parent)
		b.Size = UDim2.fromOffset(200,38)
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 15
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = Color3.fromRGB(0,170,255)
		b.AutoButtonColor = false
		b.ClipsDescendants = true
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
		
		-- Glow effect
		local glow = Instance.new("ImageLabel", b)
		glow.Name = "Glow"
		glow.Size = UDim2.new(1, 30, 1, 30)
		glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.BackgroundTransparency = 1
		glow.Image = "rbxassetid://5028857084"
		glow.ImageColor3 = Color3.fromRGB(0, 170, 255)
		glow.ImageTransparency = 1
		glow.ZIndex = 0
		
		-- Hover effect
		b.MouseEnter:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(0, 200, 255)
			}):Play()
			TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				ImageTransparency = 0.7
			}):Play()
		end)
		
		b.MouseLeave:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			}):Play()
			TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				ImageTransparency = 1
			}):Play()
		end)
		
		-- Smooth press effect
		b.MouseButton1Down:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(0, 140, 220)
			}):Play()
		end)
		
		b.MouseButton1Up:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(0, 200, 255)
			}):Play()
		end)
		
		-- Ripple + Border glow effect on click
		b.MouseButton1Click:Connect(function()
			-- Border glow
			createBorderGlow(b)
			
			-- Create ripple circle
			local ripple = Instance.new("Frame", b)
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ripple.BackgroundTransparency = 0.5
			ripple.BorderSizePixel = 0
			ripple.Size = UDim2.fromOffset(10, 10)
			ripple.ZIndex = 10
			Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
			
			-- Get mouse position on button
			local mouse = game:GetService("Players").LocalPlayer:GetMouse()
			local relativeX = mouse.X - b.AbsolutePosition.X
			local relativeY = mouse.Y - b.AbsolutePosition.Y
			ripple.Position = UDim2.fromOffset(relativeX, relativeY)
			
			-- Ripple size to cover entire button
			local maxSize = math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 2.5
			
			-- Animate ripple expand
			local expandTween = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(maxSize, maxSize),
				BackgroundTransparency = 1
			})
			expandTween:Play()
			
			-- Remove ripple after animation
			expandTween.Completed:Connect(function()
				ripple:Destroy()
			end)
			
			if callback then callback() end
		end)
	end

	function PanelAPI.CreateCopyButton(parent, text, callback)
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 36)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)
		
		local copyIcon = Instance.new("ImageLabel", h)
		copyIcon.Size = UDim2.fromOffset(18, 18)
		copyIcon.Position = UDim2.fromOffset(10, 9)
		copyIcon.BackgroundTransparency = 1
		copyIcon.Image = "rbxassetid://7072718362"
		copyIcon.ImageColor3 = Color3.fromRGB(0, 170, 255)
		
		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1, -70, 1, 0)
		lbl.Position = UDim2.fromOffset(34, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.new(1, 1, 1)
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		
		local copyBtn = Instance.new("TextButton", h)
		copyBtn.Size = UDim2.fromOffset(50, 24)
		copyBtn.Position = UDim2.new(1, -8, 0.5, 0)
		copyBtn.AnchorPoint = Vector2.new(1, 0.5)
		copyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		copyBtn.Text = "Copy"
		copyBtn.Font = Enum.Font.GothamBold
		copyBtn.TextSize = 11
		copyBtn.TextColor3 = Color3.new(1, 1, 1)
		copyBtn.AutoButtonColor = false
		Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
		
		copyBtn.MouseEnter:Connect(function()
			TweenService:Create(copyBtn, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(0, 200, 255)
			}):Play()
		end)
		
		copyBtn.MouseLeave:Connect(function()
			TweenService:Create(copyBtn, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			}):Play()
		end)
		
		copyBtn.MouseButton1Click:Connect(function()
			if callback then callback() end
			
			copyBtn.Text = "✓"
			TweenService:Create(copyBtn, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(0, 200, 100)
			}):Play()
			TweenService:Create(copyIcon, TweenInfo.new(0.1), {
				ImageColor3 = Color3.fromRGB(0, 200, 100)
			}):Play()
			
			task.delay(1, function()
				copyBtn.Text = "Copy"
				TweenService:Create(copyBtn, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(0, 170, 255)
				}):Play()
				TweenService:Create(copyIcon, TweenInfo.new(0.15), {
					ImageColor3 = Color3.fromRGB(0, 170, 255)
				}):Play()
			end)
		end)
	end

	function PanelAPI.CreateDropdown(parent, title, list, default, callback)
		local currentList = {}
		for _, v in ipairs(list) do
			table.insert(currentList, v)
		end
		
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 40)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		h.ClipsDescendants = true
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local label = Instance.new("TextLabel", h)
		label.Text = title
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(160,160,160)
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(12,4)
		label.Size = UDim2.new(1,-24,0,14)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local selected = Instance.new("TextLabel", h)
		selected.Text = default or ""
		selected.Font = Enum.Font.Gotham
		selected.TextSize = 14
		selected.TextColor3 = Color3.new(1,1,1)
		selected.BackgroundTransparency = 1
		selected.Position = UDim2.fromOffset(12,18)
		selected.Size = UDim2.new(1,-40,0,18)
		selected.TextXAlignment = Enum.TextXAlignment.Left

		local arrow = Instance.new("TextLabel", h)
		arrow.Text = "▼"
		arrow.Font = Enum.Font.GothamBold
		arrow.TextSize = 14
		arrow.TextColor3 = Color3.fromRGB(200,200,200)
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.fromOffset(20,20)
		arrow.Position = UDim2.new(1,-26,0.5,-6)

		local btn = Instance.new("TextButton", h)
		btn.Size = UDim2.fromScale(1,1)
		btn.BackgroundTransparency = 1
		btn.Text = ""

		local listFrame = Instance.new("ScrollingFrame", h)
		listFrame.Position = UDim2.fromOffset(0,40)
		listFrame.Size = UDim2.fromOffset(220,0)
		listFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
		listFrame.ClipsDescendants = true
		listFrame.ScrollBarThickness = 6
		listFrame.ScrollBarImageColor3 = Color3.fromRGB(50,50,50)
		Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,10)

		local pad = Instance.new("UIPadding", listFrame)
		pad.PaddingLeft = UDim.new(0,10)
		pad.PaddingRight = UDim.new(0,10)
		pad.PaddingTop = UDim.new(0,6)
		pad.PaddingBottom = UDim.new(0,6)

		local layout = Instance.new("UIListLayout", listFrame)
		layout.Padding = UDim.new(0,6)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
		end)

		local opened = false
		local function toggle(state)
			opened = state
			-- Border glow on open
			if state then
				createBorderGlow(h)
			end
			
			TweenService:Create(h, TweenInfo.new(0.25), {
				Size = opened and UDim2.fromOffset(220, 40 + math.min(#currentList*30,150)) or UDim2.fromOffset(220,40)
			}):Play()
			TweenService:Create(listFrame, TweenInfo.new(0.25), {
				Size = opened and UDim2.fromOffset(220, math.min(#currentList*30,150)) or UDim2.fromOffset(220,0)
			}):Play()
			TweenService:Create(arrow, TweenInfo.new(0.25), {
				Rotation = opened and 180 or 0
			}):Play()
		end
		
		local function createOption(v)
			local opt = Instance.new("TextButton", listFrame)
			opt.Size = UDim2.fromOffset(200,24)
			opt.Text = v
			opt.Font = Enum.Font.Gotham
			opt.TextSize = 13
			opt.TextColor3 = Color3.new(1,1,1)
			opt.BackgroundColor3 = Color3.fromRGB(35,35,35)
			opt.TextXAlignment = Enum.TextXAlignment.Center
			Instance.new("UICorner", opt).CornerRadius = UDim.new(0,6)

			opt.MouseButton1Click:Connect(function()
				selected.Text = v
				toggle(false)
				if callback then callback(v) end
			end)
			
			return opt
		end
		
		local function rebuildList()
			local children = listFrame:GetChildren()
			for i = #children, 1, -1 do
				local child = children[i]
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			for _, v in ipairs(currentList) do
				createOption(v)
			end
		end

		rebuildList()

		btn.MouseButton1Click:Connect(function()
			toggle(not opened)
		end)
		
		local dropdownAPI = {}
		
		function dropdownAPI:Refresh()
			currentList = {}
			local children = listFrame:GetChildren()
			for i = #children, 1, -1 do
				local child = children[i]
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
		end
		
		function dropdownAPI:Add(item)
			table.insert(currentList, item)
			createOption(item)
		end
		
		return dropdownAPI
	end

	-- Multi-select Dropdown
	function PanelAPI.CreateMultiDropdown(parent, title, list, defaults, callback)
		local currentList = {}
		for _, v in ipairs(list) do
			table.insert(currentList, v)
		end
		
		-- Selected items (table)
		local selectedItems = {}
		if type(defaults) == "table" then
			for _, v in ipairs(defaults) do
				selectedItems[v] = true
			end
		elseif type(defaults) == "string" then
			selectedItems[defaults] = true
		end
		
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 40)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		h.ClipsDescendants = true
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local label = Instance.new("TextLabel", h)
		label.Text = title .. " (Multi)"
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(160,160,160)
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(12,4)
		label.Size = UDim2.new(1,-24,0,14)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local selected = Instance.new("TextLabel", h)
		selected.Font = Enum.Font.Gotham
		selected.TextSize = 13
		selected.TextColor3 = Color3.new(1,1,1)
		selected.BackgroundTransparency = 1
		selected.Position = UDim2.fromOffset(12,18)
		selected.Size = UDim2.new(1,-40,0,18)
		selected.TextXAlignment = Enum.TextXAlignment.Left
		selected.TextTruncate = Enum.TextTruncate.AtEnd

		local function updateSelectedText()
			local items = {}
			for item, isSelected in pairs(selectedItems) do
				if isSelected then
					table.insert(items, item)
				end
			end
			if #items == 0 then
				selected.Text = "None"
			else
				selected.Text = table.concat(items, ", ")
			end
		end
		updateSelectedText()

		local arrow = Instance.new("TextLabel", h)
		arrow.Text = "▼"
		arrow.Font = Enum.Font.GothamBold
		arrow.TextSize = 14
		arrow.TextColor3 = Color3.fromRGB(200,200,200)
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.fromOffset(20,20)
		arrow.Position = UDim2.new(1,-26,0.5,-6)

		local btn = Instance.new("TextButton", h)
		btn.Size = UDim2.fromScale(1,1)
		btn.BackgroundTransparency = 1
		btn.Text = ""

		local listFrame = Instance.new("ScrollingFrame", h)
		listFrame.Position = UDim2.fromOffset(0,40)
		listFrame.Size = UDim2.fromOffset(220,0)
		listFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
		listFrame.ClipsDescendants = true
		listFrame.ScrollBarThickness = 6
		listFrame.ScrollBarImageColor3 = Color3.fromRGB(50,50,50)
		Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,10)

		local pad = Instance.new("UIPadding", listFrame)
		pad.PaddingLeft = UDim.new(0,10)
		pad.PaddingRight = UDim.new(0,10)
		pad.PaddingTop = UDim.new(0,6)
		pad.PaddingBottom = UDim.new(0,6)

		local layout = Instance.new("UIListLayout", listFrame)
		layout.Padding = UDim.new(0,6)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
		end)

		local opened = false
		local optionButtons = {}
		
		local function toggle(state)
			opened = state
			if state then
				createBorderGlow(h)
			end
			
			TweenService:Create(h, TweenInfo.new(0.25), {
				Size = opened and UDim2.fromOffset(220, 40 + math.min(#currentList*30,150)) or UDim2.fromOffset(220,40)
			}):Play()
			TweenService:Create(listFrame, TweenInfo.new(0.25), {
				Size = opened and UDim2.fromOffset(220, math.min(#currentList*30,150)) or UDim2.fromOffset(220,0)
			}):Play()
			TweenService:Create(arrow, TweenInfo.new(0.25), {
				Rotation = opened and 180 or 0
			}):Play()
		end
		
		local function getSelectedTable()
			local result = {}
			for item, isSelected in pairs(selectedItems) do
				if isSelected then
					table.insert(result, item)
				end
			end
			return table.concat(result, ", ")
		end
		
		local function updateOptionVisual(opt, v)
			local isSelected = selectedItems[v]
			TweenService:Create(opt, TweenInfo.new(0.15), {
				BackgroundColor3 = isSelected and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(35,35,35)
			}):Play()
			
			local check = opt:FindFirstChild("Check")
			if check then
				check.Text = isSelected and "✓" or ""
			end
		end
		
		local function createOption(v)
			local opt = Instance.new("TextButton", listFrame)
			opt.Size = UDim2.fromOffset(200,24)
			opt.Text = ""
			opt.BackgroundColor3 = selectedItems[v] and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(35,35,35)
			Instance.new("UICorner", opt).CornerRadius = UDim.new(0,6)
			
			-- Checkbox
			local check = Instance.new("TextLabel", opt)
			check.Name = "Check"
			check.Size = UDim2.fromOffset(20, 24)
			check.Position = UDim2.fromOffset(4, 0)
			check.BackgroundTransparency = 1
			check.Text = selectedItems[v] and "✓" or ""
			check.Font = Enum.Font.GothamBold
			check.TextSize = 14
			check.TextColor3 = Color3.fromRGB(0, 200, 100)
			
			-- Label
			local optLabel = Instance.new("TextLabel", opt)
			optLabel.Size = UDim2.new(1, -28, 1, 0)
			optLabel.Position = UDim2.fromOffset(24, 0)
			optLabel.BackgroundTransparency = 1
			optLabel.Text = v
			optLabel.Font = Enum.Font.Gotham
			optLabel.TextSize = 13
			optLabel.TextColor3 = Color3.new(1,1,1)
			optLabel.TextXAlignment = Enum.TextXAlignment.Left

			opt.MouseButton1Click:Connect(function()
				selectedItems[v] = not selectedItems[v]
				updateOptionVisual(opt, v)
				updateSelectedText()
				if callback then callback(getSelectedTable()) end
			end)
			
			optionButtons[v] = opt
			return opt
		end
		
		local function rebuildList()
			for _, child in ipairs(listFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			optionButtons = {}
			for _, v in ipairs(currentList) do
				createOption(v)
			end
		end

		rebuildList()

		btn.MouseButton1Click:Connect(function()
			toggle(not opened)
		end)
		
		local dropdownAPI = {}
		
		function dropdownAPI:Refresh()
			currentList = {}
			selectedItems = {}
			rebuildList()
			updateSelectedText()
		end
		
		function dropdownAPI:Add(item)
			table.insert(currentList, item)
			createOption(item)
		end
		
		function dropdownAPI:Select(item)
			selectedItems[item] = true
			if optionButtons[item] then
				updateOptionVisual(optionButtons[item], item)
			end
			updateSelectedText()
			if callback then callback(getSelectedTable()) end
		end
		
		function dropdownAPI:Deselect(item)
			selectedItems[item] = false
			if optionButtons[item] then
				updateOptionVisual(optionButtons[item], item)
			end
			updateSelectedText()
			if callback then callback(getSelectedTable()) end
		end
		
		function dropdownAPI:GetSelected()
			return getSelectedTable()
		end
		
		return dropdownAPI
	end

	function PanelAPI.CreateSlider(parent, title, min, max, default, callback)
		min = min or 0
		max = max or 100
		default = math.clamp(default or min, min, max)

		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 54)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local label = Instance.new("TextLabel", h)
		label.Text = title
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(160,160,160)
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(10,4)
		label.Size = UDim2.new(1,-60,0,14)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local box = Instance.new("TextBox", h)
		box.Size = UDim2.fromOffset(46,18)
		box.Position = UDim2.fromOffset(164,4)
		box.Text = tostring(default)
		box.Font = Enum.Font.GothamBold
		box.TextSize = 12
		box.TextColor3 = Color3.new(1,1,1)
		box.BackgroundColor3 = Color3.fromRGB(20,20,20)
		box.ClearTextOnFocus = false
		box.TextXAlignment = Enum.TextXAlignment.Center
		Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

		local barBg = Instance.new("Frame", h)
		barBg.Size = UDim2.new(1,-20,0,6)
		barBg.Position = UDim2.fromOffset(10,32)
		barBg.BackgroundColor3 = Color3.fromRGB(45,45,45)
		Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

		local fill = Instance.new("Frame", barBg)
		fill.Size = UDim2.fromScale((default-min)/(max-min),1)
		fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

		local knob = Instance.new("Frame", barBg)
		knob.Size = UDim2.fromOffset(14,14)
		knob.AnchorPoint = Vector2.new(0.5,0.5)
		knob.Position = UDim2.new(fill.Size.X.Scale,0,0.5,0)
		knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

		local dragging = false
		local value = default

		local function setValue(v)
			value = math.clamp(math.floor(v + 0.5), min, max)
			local alpha = (value-min)/(max-min)

			fill.Size = UDim2.fromScale(alpha,1)
			knob.Position = UDim2.new(alpha,0,0.5,0)
			box.Text = tostring(value)

			if callback then
				callback(value)
			end
		end

		local function updateFromX(x)
			local alpha = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
			setValue(min + (max-min)*alpha)
		end

		barBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateFromX(input.Position.X)
			end
		end)

		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromX(input.Position.X)
			end
		end)

		game:GetService("UserInputService").InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		box.FocusLost:Connect(function()
			local num = tonumber(box.Text)
			if num then
				setValue(num)
			else
				box.Text = tostring(value)
			end
		end)

		setValue(default)
	end

	function PanelAPI.CreateKeybind(parent, title, defaultKey, callback)
		local currentKey = defaultKey
		local listening = false
		
		-- Register keybind with UI
		UI:RegisterKeybind(title, defaultKey, false, nil)
		
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 36)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,-80,1,0)
		lbl.Position = UDim2.fromOffset(10,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local keyBtn = Instance.new("TextButton", h)
		keyBtn.Size = UDim2.fromOffset(60, 24)
		keyBtn.Position = UDim2.new(1, -10, 0.5, 0)
		keyBtn.AnchorPoint = Vector2.new(1, 0.5)
		keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		keyBtn.Text = defaultKey and defaultKey.Name or "None"
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.TextSize = 12
		keyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
		keyBtn.AutoButtonColor = false
		Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
		
		local keyStroke = Instance.new("UIStroke", keyBtn)
		keyStroke.Color = Color3.fromRGB(60, 60, 60)
		keyStroke.Thickness = 1

		keyBtn.MouseEnter:Connect(function()
			if not listening then
				TweenService:Create(keyBtn, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(55, 55, 55)
				}):Play()
				TweenService:Create(keyStroke, TweenInfo.new(0.15), {
					Color = Color3.fromRGB(0, 170, 255)
				}):Play()
			end
		end)

		keyBtn.MouseLeave:Connect(function()
			if not listening then
				TweenService:Create(keyBtn, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				}):Play()
				TweenService:Create(keyStroke, TweenInfo.new(0.15), {
					Color = Color3.fromRGB(60, 60, 60)
				}):Play()
			end
		end)

		local inputConnection
		
		keyBtn.MouseButton1Click:Connect(function()
			if listening then return end
			listening = true
			
			keyBtn.Text = "..."
			TweenService:Create(keyBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			}):Play()
			TweenService:Create(keyStroke, TweenInfo.new(0.2), {
				Color = Color3.fromRGB(0, 200, 255)
			}):Play()
			keyBtn.TextColor3 = Color3.new(1, 1, 1)
			
			inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if input.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = input.KeyCode
					keyBtn.Text = input.KeyCode.Name
					
					-- Update keybind key
					UI:UpdateKeybindKey(title, currentKey)
					
					TweenService:Create(keyBtn, TweenInfo.new(0.2), {
						BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					}):Play()
					TweenService:Create(keyStroke, TweenInfo.new(0.2), {
						Color = Color3.fromRGB(60, 60, 60)
					}):Play()
					keyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
					
					listening = false
					inputConnection:Disconnect()
					
					if callback then
						callback(currentKey)
					end
				end
			end)
		end)
		
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not listening and input.UserInputType == Enum.UserInputType.Keyboard then
				if currentKey and input.KeyCode == currentKey then
					TweenService:Create(keyBtn, TweenInfo.new(0.1), {
						BackgroundColor3 = Color3.fromRGB(0, 170, 255)
					}):Play()
					keyBtn.TextColor3 = Color3.new(1, 1, 1)
					
					task.delay(0.15, function()
						TweenService:Create(keyBtn, TweenInfo.new(0.1), {
							BackgroundColor3 = Color3.fromRGB(45, 45, 45)
						}):Play()
						keyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
					end)
				end
			end
		end)
	end

	function PanelAPI.CreateColorPicker(parent, title, r, g, b, callback)
		local currentColor = Color3.fromRGB(r or 255, g or 255, b or 255)
		local currentR, currentG, currentB = r or 255, g or 255, b or 255
		local pickerOpen = false
		local pickerFrame = nil
		
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 36)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,-50,1,0)
		lbl.Position = UDim2.fromOffset(10,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local colorPreview = Instance.new("TextButton", h)
		colorPreview.Size = UDim2.fromOffset(32, 24)
		colorPreview.Position = UDim2.new(1, -10, 0.5, 0)
		colorPreview.AnchorPoint = Vector2.new(1, 0.5)
		colorPreview.BackgroundColor3 = currentColor
		colorPreview.Text = ""
		colorPreview.AutoButtonColor = false
		Instance.new("UICorner", colorPreview).CornerRadius = UDim.new(0, 6)
		
		local previewStroke = Instance.new("UIStroke", colorPreview)
		previewStroke.Color = Color3.fromRGB(60, 60, 60)
		previewStroke.Thickness = 1

		local function createPicker()
			if pickerFrame then return end
			
			pickerFrame = Instance.new("Frame", gui)
			pickerFrame.Size = UDim2.fromOffset(220, 240)
			pickerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			pickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			pickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			pickerFrame.ZIndex = 100
			Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 12)
			UI:RegisterPopup(pickerFrame, function()
				pickerFrame = nil
				pickerOpen = false
			end)
			
			local pickerStroke = Instance.new("UIStroke", pickerFrame)
			pickerStroke.Color = Color3.fromRGB(0, 170, 255)
			pickerStroke.Thickness = 2
			
			local titleBar = Instance.new("Frame", pickerFrame)
			titleBar.Size = UDim2.new(1, 0, 0, 30)
			titleBar.BackgroundTransparency = 1
			titleBar.ZIndex = 101
			
			local pickerTitle = Instance.new("TextLabel", titleBar)
			pickerTitle.Size = UDim2.new(1, 0, 1, 0)
			pickerTitle.BackgroundTransparency = 1
			pickerTitle.Text = title
			pickerTitle.Font = Enum.Font.GothamBold
			pickerTitle.TextSize = 14
			pickerTitle.TextColor3 = Color3.new(1, 1, 1)
			pickerTitle.ZIndex = 101
			
			local dragIcon = Instance.new("Frame", titleBar)
			dragIcon.Size = UDim2.fromOffset(40, 4)
			dragIcon.Position = UDim2.new(0.5, 0, 0, 4)
			dragIcon.AnchorPoint = Vector2.new(0.5, 0)
			dragIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			dragIcon.ZIndex = 102
			Instance.new("UICorner", dragIcon).CornerRadius = UDim.new(1, 0)
			
			local draggingPicker = false
			local dragStartPicker, startPosPicker
			
			titleBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingPicker = true
					dragStartPicker = input.Position
					startPosPicker = pickerFrame.Position
					TweenService:Create(pickerStroke, TweenInfo.new(0.15), {
						Color = Color3.fromRGB(0, 200, 255),
						Thickness = 3
					}):Play()
				end
			end)
			
			titleBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingPicker = false
					TweenService:Create(pickerStroke, TweenInfo.new(0.15), {
						Color = Color3.fromRGB(0, 170, 255),
						Thickness = 2
					}):Play()
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if draggingPicker and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local delta = input.Position - dragStartPicker
					pickerFrame.Position = UDim2.new(
						startPosPicker.X.Scale,
						startPosPicker.X.Offset + delta.X,
						startPosPicker.Y.Scale,
						startPosPicker.Y.Offset + delta.Y
					)
				end
			end)
			
			local colorBox = Instance.new("ImageLabel", pickerFrame)
			colorBox.Size = UDim2.fromOffset(190, 80)
			colorBox.Position = UDim2.fromOffset(15, 35)
			colorBox.BackgroundColor3 = Color3.fromHSV(1, 1, 1)
			colorBox.Image = "rbxassetid://4155801252"
			colorBox.ZIndex = 101
			Instance.new("UICorner", colorBox).CornerRadius = UDim.new(0, 6)
			
			local colorBoxGradient = Instance.new("UIGradient", colorBox)
			colorBoxGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
			})
			
			local colorCursor = Instance.new("Frame", colorBox)
			colorCursor.Size = UDim2.fromOffset(10, 10)
			colorCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			colorCursor.Position = UDim2.fromScale(1, 0)
			colorCursor.BackgroundColor3 = Color3.new(1, 1, 1)
			colorCursor.ZIndex = 102
			Instance.new("UICorner", colorCursor).CornerRadius = UDim.new(1, 0)
			Instance.new("UIStroke", colorCursor).Thickness = 2
			
			local hueBar = Instance.new("Frame", pickerFrame)
			hueBar.Size = UDim2.fromOffset(190, 12)
			hueBar.Position = UDim2.fromOffset(15, 120)
			hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
			hueBar.ZIndex = 101
			Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)
			
			local hueGradient = Instance.new("UIGradient", hueBar)
			hueGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
				ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
				ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
				ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
				ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
			})
			
			local hueCursor = Instance.new("Frame", hueBar)
			hueCursor.Size = UDim2.fromOffset(6, 16)
			hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			hueCursor.Position = UDim2.new(0, 0, 0.5, 0)
			hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
			hueCursor.ZIndex = 102
			Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(0, 3)
			Instance.new("UIStroke", hueCursor).Thickness = 1
			
			-- RGB Input Section
			local rgbContainer = Instance.new("Frame", pickerFrame)
			rgbContainer.Size = UDim2.fromOffset(190, 50)
			rgbContainer.Position = UDim2.fromOffset(15, 138)
			rgbContainer.BackgroundTransparency = 1
			rgbContainer.ZIndex = 101
			
			local function createRGBInput(labelText, defaultVal, xPos)
				local container = Instance.new("Frame", rgbContainer)
				container.Size = UDim2.fromOffset(58, 50)
				container.Position = UDim2.fromOffset(xPos, 0)
				container.BackgroundTransparency = 1
				container.ZIndex = 101
				
				local label = Instance.new("TextLabel", container)
				label.Size = UDim2.new(1, 0, 0, 14)
				label.BackgroundTransparency = 1
				label.Text = labelText
				label.Font = Enum.Font.GothamBold
				label.TextSize = 11
				label.TextColor3 = labelText == "R" and Color3.fromRGB(255, 100, 100) or (labelText == "G" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(100, 150, 255))
				label.ZIndex = 101
				
				local inputBox = Instance.new("TextBox", container)
				inputBox.Size = UDim2.new(1, 0, 0, 28)
				inputBox.Position = UDim2.fromOffset(0, 18)
				inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				inputBox.Text = tostring(defaultVal)
				inputBox.Font = Enum.Font.GothamBold
				inputBox.TextSize = 12
				inputBox.TextColor3 = Color3.new(1, 1, 1)
				inputBox.PlaceholderText = "0-255"
				inputBox.ClearTextOnFocus = false
				inputBox.ZIndex = 101
				Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
				
				return inputBox
			end
			
			local rInput = createRGBInput("R", currentR, 0)
			local gInput = createRGBInput("G", currentG, 66)
			local bInput = createRGBInput("B", currentB, 132)
			
			local previewBox = Instance.new("Frame", pickerFrame)
			previewBox.Size = UDim2.fromOffset(60, 28)
			previewBox.Position = UDim2.fromOffset(15, 198)
			previewBox.BackgroundColor3 = currentColor
			previewBox.ZIndex = 101
			Instance.new("UICorner", previewBox).CornerRadius = UDim.new(0, 6)
			
			local confirmBtn = Instance.new("TextButton", pickerFrame)
			confirmBtn.Size = UDim2.fromOffset(60, 28)
			confirmBtn.Position = UDim2.fromOffset(145, 198)
			confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			confirmBtn.Text = "OK"
			confirmBtn.Font = Enum.Font.GothamBold
			confirmBtn.TextSize = 13
			confirmBtn.TextColor3 = Color3.new(1, 1, 1)
			confirmBtn.ZIndex = 101
			Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)
			
			local cancelBtn = Instance.new("TextButton", pickerFrame)
			cancelBtn.Size = UDim2.fromOffset(55, 28)
			cancelBtn.Position = UDim2.fromOffset(83, 198)
			cancelBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			cancelBtn.Text = "Cancel"
			cancelBtn.Font = Enum.Font.GothamBold
			cancelBtn.TextSize = 11
			cancelBtn.TextColor3 = Color3.new(1, 1, 1)
			cancelBtn.ZIndex = 101
			Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)
			
			local hue, sat, val = 0, 1, 1
			local h1, s1, v1 = Color3.toHSV(currentColor)
			hue, sat, val = h1, s1, v1
			
			local function updateColor()
				currentColor = Color3.fromHSV(hue, sat, val)
				currentR = math.floor(currentColor.R * 255)
				currentG = math.floor(currentColor.G * 255)
				currentB = math.floor(currentColor.B * 255)
				previewBox.BackgroundColor3 = currentColor
				colorBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
				colorBoxGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
				})
				rInput.Text = tostring(currentR)
				gInput.Text = tostring(currentG)
				bInput.Text = tostring(currentB)
			end
			
			local function updateFromRGB()
				local newR = math.clamp(tonumber(rInput.Text) or 0, 0, 255)
				local newG = math.clamp(tonumber(gInput.Text) or 0, 0, 255)
				local newB = math.clamp(tonumber(bInput.Text) or 0, 0, 255)
				currentR, currentG, currentB = newR, newG, newB
				currentColor = Color3.fromRGB(newR, newG, newB)
				hue, sat, val = Color3.toHSV(currentColor)
				previewBox.BackgroundColor3 = currentColor
				colorBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
				colorBoxGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
				})
				hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
				colorCursor.Position = UDim2.fromScale(sat, 1 - val)
			end
			
			rInput.FocusLost:Connect(updateFromRGB)
			gInput.FocusLost:Connect(updateFromRGB)
			bInput.FocusLost:Connect(updateFromRGB)
			
			hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
			colorCursor.Position = UDim2.fromScale(sat, 1 - val)
			updateColor()
			
			local draggingHue = false
			hueBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingHue = true
					hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
					hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
					updateColor()
				end
			end)
			
			local draggingColor = false
			colorBox.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingColor = true
					sat = math.clamp((input.Position.X - colorBox.AbsolutePosition.X) / colorBox.AbsoluteSize.X, 0, 1)
					val = 1 - math.clamp((input.Position.Y - colorBox.AbsolutePosition.Y) / colorBox.AbsoluteSize.Y, 0, 1)
					colorCursor.Position = UDim2.fromScale(sat, 1 - val)
					updateColor()
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					if draggingHue then
						hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
						hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
						updateColor()
					elseif draggingColor then
						sat = math.clamp((input.Position.X - colorBox.AbsolutePosition.X) / colorBox.AbsoluteSize.X, 0, 1)
						val = 1 - math.clamp((input.Position.Y - colorBox.AbsolutePosition.Y) / colorBox.AbsoluteSize.Y, 0, 1)
						colorCursor.Position = UDim2.fromScale(sat, 1 - val)
						updateColor()
					end
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingHue = false
					draggingColor = false
				end
			end)
			
			confirmBtn.MouseButton1Click:Connect(function()
				colorPreview.BackgroundColor3 = currentColor
				pickerFrame:Destroy()
				pickerFrame = nil
				pickerOpen = false
				if callback then
					callback(currentColor)
				end
			end)
			
			cancelBtn.MouseButton1Click:Connect(function()
				pickerFrame:Destroy()
				pickerFrame = nil
				pickerOpen = false
			end)
			
			pickerFrame.Size = UDim2.fromOffset(220, 0)
			TweenService:Create(pickerFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Size = UDim2.fromOffset(220, 240)
			}):Play()
		end
		
		colorPreview.MouseEnter:Connect(function()
			TweenService:Create(previewStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(0, 170, 255)
			}):Play()
		end)
		
		colorPreview.MouseLeave:Connect(function()
			TweenService:Create(previewStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(60, 60, 60)
			}):Play()
		end)
		
		colorPreview.MouseButton1Click:Connect(function()
			if pickerOpen then return end
			pickerOpen = true
			createPicker()
		end)
	end

	function PanelAPI.CreatePhoto(parent, title, callback)
		local Players = game:GetService("Players")
		local selectedPlayer = nil
		local viewerOpen = false
		local viewerFrame = nil
		local listFrame = nil
		
		local h = Instance.new("Frame", parent)
		h.Size = UDim2.fromOffset(220, 40)
		h.BackgroundColor3 = Color3.fromRGB(30,30,30)
		Instance.new("UICorner", h).CornerRadius = UDim.new(0,10)

		local lbl = Instance.new("TextLabel", h)
		lbl.Size = UDim2.new(1,-24,0,14)
		lbl.Position = UDim2.fromOffset(12,4)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 12
		lbl.TextColor3 = Color3.fromRGB(160,160,160)
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local selectedLabel = Instance.new("TextLabel", h)
		selectedLabel.Size = UDim2.new(1,-40,0,18)
		selectedLabel.Position = UDim2.fromOffset(12,18)
		selectedLabel.BackgroundTransparency = 1
		selectedLabel.Text = "Select Player..."
		selectedLabel.Font = Enum.Font.Gotham
		selectedLabel.TextSize = 14
		selectedLabel.TextColor3 = Color3.new(1,1,1)
		selectedLabel.TextXAlignment = Enum.TextXAlignment.Left

		local arrow = Instance.new("TextLabel", h)
		arrow.Text = "▶"
		arrow.Font = Enum.Font.GothamBold
		arrow.TextSize = 12
		arrow.TextColor3 = Color3.fromRGB(200,200,200)
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.fromOffset(20,20)
		arrow.Position = UDim2.new(1,-26,0.5,-6)

		local btn = Instance.new("TextButton", h)
		btn.Size = UDim2.fromScale(1,1)
		btn.BackgroundTransparency = 1
		btn.Text = ""

		local opened = false
		
		local function createViewer(player)
			if viewerFrame then viewerFrame:Destroy() end
			
			viewerFrame = Instance.new("Frame", gui)
			viewerFrame.Size = UDim2.fromOffset(280, 380)
			viewerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			viewerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			viewerFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			viewerFrame.ZIndex = 100
			Instance.new("UICorner", viewerFrame).CornerRadius = UDim.new(0, 14)
			UI:RegisterPopup(viewerFrame, function()
				viewerFrame = nil
				viewerOpen = false
			end)
			
			local viewerStroke = Instance.new("UIStroke", viewerFrame)
			viewerStroke.Color = Color3.fromRGB(0, 170, 255)
			viewerStroke.Thickness = 2
			
			local titleBar = Instance.new("Frame", viewerFrame)
			titleBar.Size = UDim2.new(1, 0, 0, 36)
			titleBar.BackgroundTransparency = 1
			titleBar.ZIndex = 101
			
			local draggingViewer = false
			local dragStartViewer = nil
			local startPosViewer = nil
			
			titleBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingViewer = true
					dragStartViewer = input.Position
					startPosViewer = viewerFrame.Position
					
					TweenService:Create(viewerStroke, TweenInfo.new(0.15), {
						Color = Color3.fromRGB(0, 200, 255),
						Thickness = 3
					}):Play()
				end
			end)
			
			titleBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingViewer = false
					
					TweenService:Create(viewerStroke, TweenInfo.new(0.15), {
						Color = Color3.fromRGB(0, 170, 255),
						Thickness = 2
					}):Play()
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if draggingViewer and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local delta = input.Position - dragStartViewer
					local newPos = UDim2.new(
						startPosViewer.X.Scale,
						startPosViewer.X.Offset + delta.X,
						startPosViewer.Y.Scale,
						startPosViewer.Y.Offset + delta.Y
					)
					viewerFrame.Position = newPos
				end
			end)
			
			local dragIconViewer = Instance.new("Frame", titleBar)
			dragIconViewer.Size = UDim2.fromOffset(40, 6)
			dragIconViewer.Position = UDim2.new(0.5, 0, 0, 6)
			dragIconViewer.AnchorPoint = Vector2.new(0.5, 0)
			dragIconViewer.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			dragIconViewer.BackgroundTransparency = 0.5
			dragIconViewer.ZIndex = 102
			Instance.new("UICorner", dragIconViewer).CornerRadius = UDim.new(1, 0)
			
			local titleText = Instance.new("TextLabel", titleBar)
			titleText.Size = UDim2.new(1, -40, 1, 0)
			titleText.Position = UDim2.fromOffset(12, 0)
			titleText.BackgroundTransparency = 1
			titleText.Text = player.Name
			titleText.Font = Enum.Font.GothamBold
			titleText.TextSize = 16
			titleText.TextColor3 = Color3.new(1, 1, 1)
			titleText.TextXAlignment = Enum.TextXAlignment.Left
			titleText.ZIndex = 101
			
			local closeBtn = Instance.new("TextButton", viewerFrame)
			closeBtn.Size = UDim2.fromOffset(28, 28)
			closeBtn.Position = UDim2.new(1, -8, 0, 4)
			closeBtn.AnchorPoint = Vector2.new(1, 0)
			closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			closeBtn.Text = "X"
			closeBtn.Font = Enum.Font.GothamBold
			closeBtn.TextSize = 14
			closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
			closeBtn.AutoButtonColor = false
			closeBtn.ZIndex = 102
			Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
			
			closeBtn.MouseEnter:Connect(function()
				TweenService:Create(closeBtn, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(200, 60, 60),
					TextColor3 = Color3.new(1, 1, 1),
					Rotation = 90
				}):Play()
			end)
			
			closeBtn.MouseLeave:Connect(function()
				TweenService:Create(closeBtn, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					TextColor3 = Color3.fromRGB(150, 150, 150),
					Rotation = 0
				}):Play()
			end)
			
			closeBtn.MouseButton1Click:Connect(function()
				local tween = TweenService:Create(viewerFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
					Size = UDim2.fromOffset(280, 0)
				})
				tween:Play()
				tween.Completed:Once(function()
					viewerFrame:Destroy()
					viewerFrame = nil
					viewerOpen = false
				end)
			end)
			
			local avatarFrame = Instance.new("Frame", viewerFrame)
			avatarFrame.Size = UDim2.fromOffset(120, 200)
			avatarFrame.Position = UDim2.fromOffset(20, 45)
			avatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			avatarFrame.ZIndex = 101
			Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(0, 10)
			
			local avatarImage = Instance.new("ImageLabel", avatarFrame)
			avatarImage.Size = UDim2.fromScale(1, 1)
			avatarImage.BackgroundTransparency = 1
			avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
			avatarImage.ZIndex = 102
			
			local success, content = pcall(function()
				return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
			end)
			if success then
				avatarImage.Image = content
			end
			
			local infoPanel = Instance.new("Frame", viewerFrame)
			infoPanel.Size = UDim2.fromOffset(120, 200)
			infoPanel.Position = UDim2.fromOffset(150, 45)
			infoPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			infoPanel.ZIndex = 101
			Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 10)
			
			local infoLayout = Instance.new("UIListLayout", infoPanel)
			infoLayout.Padding = UDim.new(0, 4)
			infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			
			local infoPad = Instance.new("UIPadding", infoPanel)
			infoPad.PaddingTop = UDim.new(0, 8)
			infoPad.PaddingLeft = UDim.new(0, 8)
			infoPad.PaddingRight = UDim.new(0, 8)
			
			local function createInfoLabel(text, value)
				local infoFrame = Instance.new("Frame", infoPanel)
				infoFrame.Size = UDim2.new(1, 0, 0, 22)
				infoFrame.BackgroundTransparency = 1
				infoFrame.ZIndex = 102
				
				local infoTitle = Instance.new("TextLabel", infoFrame)
				infoTitle.Size = UDim2.new(1, 0, 0, 10)
				infoTitle.BackgroundTransparency = 1
				infoTitle.Text = text
				infoTitle.Font = Enum.Font.Gotham
				infoTitle.TextSize = 10
				infoTitle.TextColor3 = Color3.fromRGB(140, 140, 140)
				infoTitle.TextXAlignment = Enum.TextXAlignment.Left
				infoTitle.ZIndex = 102
				
				local infoValue = Instance.new("TextLabel", infoFrame)
				infoValue.Size = UDim2.new(1, 0, 0, 12)
				infoValue.Position = UDim2.fromOffset(0, 10)
				infoValue.BackgroundTransparency = 1
				infoValue.Text = tostring(value)
				infoValue.Font = Enum.Font.GothamBold
				infoValue.TextSize = 11
				infoValue.TextColor3 = Color3.new(1, 1, 1)
				infoValue.TextXAlignment = Enum.TextXAlignment.Left
				infoValue.ZIndex = 102
				
				return infoValue
			end
			
			createInfoLabel("Display Name", player.DisplayName)
			createInfoLabel("User ID", player.UserId)
			
			local teamLabel = createInfoLabel("Team", player.Team and player.Team.Name or "None")

			local hitboxPanel = Instance.new("Frame", viewerFrame)
			hitboxPanel.Size = UDim2.new(1, -40, 0, 110)
			hitboxPanel.Position = UDim2.fromOffset(20, 255)
			hitboxPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			hitboxPanel.ClipsDescendants = true
			hitboxPanel.ZIndex = 101
			Instance.new("UICorner", hitboxPanel).CornerRadius = UDim.new(0, 10)
			
			local hitboxTitle = Instance.new("TextLabel", hitboxPanel)
			hitboxTitle.Size = UDim2.new(1, 0, 0, 24)
			hitboxTitle.BackgroundTransparency = 1
			hitboxTitle.Text = "  Hitbox Info"
			hitboxTitle.Font = Enum.Font.GothamBold
			hitboxTitle.TextSize = 12
			hitboxTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
			hitboxTitle.TextXAlignment = Enum.TextXAlignment.Left
			hitboxTitle.ZIndex = 102
			
			local hitboxContent = Instance.new("Frame", hitboxPanel)
			hitboxContent.Size = UDim2.new(1, -16, 0, 80)
			hitboxContent.Position = UDim2.fromOffset(8, 26)
			hitboxContent.BackgroundTransparency = 1
			hitboxContent.ClipsDescendants = true
			hitboxContent.ZIndex = 102
			
			local hitboxLayout = Instance.new("UIGridLayout", hitboxContent)
			hitboxLayout.CellSize = UDim2.fromOffset(105, 16)
			hitboxLayout.CellPadding = UDim2.fromOffset(4, 2)
			
			local hitboxParts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
			
			local character = player.Character
			for _, partName in ipairs(hitboxParts) do
				local partFrame = Instance.new("Frame", hitboxContent)
				partFrame.BackgroundTransparency = 1
				partFrame.ZIndex = 102
				
				local indicator = Instance.new("Frame", partFrame)
				indicator.Size = UDim2.fromOffset(6, 6)
				indicator.Position = UDim2.fromOffset(0, 5)
				indicator.ZIndex = 103
				Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
				
				local partLabel = Instance.new("TextLabel", partFrame)
				partLabel.Size = UDim2.new(1, -10, 1, 0)
				partLabel.Position = UDim2.fromOffset(10, 0)
				partLabel.BackgroundTransparency = 1
				partLabel.Text = partName
				partLabel.Font = Enum.Font.Gotham
				partLabel.TextSize = 9
				partLabel.TextXAlignment = Enum.TextXAlignment.Left
				partLabel.ZIndex = 103
				
				local part = character and character:FindFirstChild(partName)
				if part then
					indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
					partLabel.TextColor3 = Color3.new(1, 1, 1)
				else
					indicator.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
					partLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
				end
			end
			
			viewerFrame.Size = UDim2.fromOffset(280, 0)
			TweenService:Create(viewerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
				Size = UDim2.fromOffset(280, 380)
			}):Play()
			
			if callback then
				callback(player)
			end
		end
		
		local function createListFrame()
			if listFrame then listFrame:Destroy() end
			
			listFrame = Instance.new("ScrollingFrame", gui)
			listFrame.Size = UDim2.fromOffset(200, 0)
			listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			listFrame.ClipsDescendants = true
			listFrame.ScrollBarThickness = 6
			listFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
			listFrame.ZIndex = 150
			listFrame.Visible = false
			Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 10)
			UI:RegisterPopup(listFrame, function()
				listFrame = nil
				opened = false
			end)
			
			local listStroke = Instance.new("UIStroke", listFrame)
			listStroke.Color = Color3.fromRGB(0, 170, 255)
			listStroke.Thickness = 1

			local pad = Instance.new("UIPadding", listFrame)
			pad.PaddingLeft = UDim.new(0, 8)
			pad.PaddingRight = UDim.new(0, 8)
			pad.PaddingTop = UDim.new(0, 6)
			pad.PaddingBottom = UDim.new(0, 6)

			local layout = Instance.new("UIListLayout", listFrame)
			layout.Padding = UDim.new(0, 4)
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

			layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
			end)
		end
		
		local function refreshPlayerList()
			if not listFrame then createListFrame() end
			
			for _, child in ipairs(listFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			
			local players = Players:GetPlayers()
			for _, player in ipairs(players) do
				local opt = Instance.new("TextButton", listFrame)
				opt.Size = UDim2.fromOffset(180, 28)
				opt.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				opt.Text = ""
				opt.AutoButtonColor = false
				opt.ZIndex = 151
				Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 6)
				
				local thumb = Instance.new("ImageLabel", opt)
				thumb.Size = UDim2.fromOffset(22, 22)
				thumb.Position = UDim2.fromOffset(3, 3)
				thumb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				thumb.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=48&height=48&format=png"
				thumb.ZIndex = 152
				Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
				
				local playerName = Instance.new("TextLabel", opt)
				playerName.Size = UDim2.new(1, -30, 1, 0)
				playerName.Position = UDim2.fromOffset(28, 0)
				playerName.BackgroundTransparency = 1
				playerName.Text = player.Name
				playerName.Font = Enum.Font.Gotham
				playerName.TextSize = 11
				playerName.TextColor3 = Color3.new(1, 1, 1)
				playerName.TextXAlignment = Enum.TextXAlignment.Left
				playerName.ZIndex = 152
				
				opt.MouseEnter:Connect(function()
					TweenService:Create(opt, TweenInfo.new(0.15), {
						BackgroundColor3 = Color3.fromRGB(0, 170, 255)
					}):Play()
				end)
				
				opt.MouseLeave:Connect(function()
					TweenService:Create(opt, TweenInfo.new(0.15), {
						BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					}):Play()
				end)
				
				opt.MouseButton1Click:Connect(function()
					selectedPlayer = player
					selectedLabel.Text = player.Name
					
					opened = false
					local tween = TweenService:Create(listFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
						Size = UDim2.fromOffset(200, 0)
					})
					tween:Play()
					tween.Completed:Once(function()
						listFrame.Visible = false
					end)
					TweenService:Create(arrow, TweenInfo.new(0.2), {
						Rotation = 0
					}):Play()
					
					viewerOpen = true
					createViewer(player)
				end)
			end
		end
		
		local function toggle(state)
			opened = state
			
			if opened then
				if not listFrame then createListFrame() end
				refreshPlayerList()
				
				local absPos = h.AbsolutePosition
				local absSize = h.AbsoluteSize
				listFrame.Position = UDim2.fromOffset(absPos.X + absSize.X + 5, absPos.Y)
				listFrame.Visible = true
				
				local playerCount = #Players:GetPlayers()
				local targetHeight = math.min(playerCount * 32 + 12, 180)
				
				listFrame.Size = UDim2.fromOffset(200, 0)
				TweenService:Create(listFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
					Size = UDim2.fromOffset(200, targetHeight)
				}):Play()
				TweenService:Create(arrow, TweenInfo.new(0.2), {
					Rotation = 90
				}):Play()
			else
				if listFrame then
					local tween = TweenService:Create(listFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
						Size = UDim2.fromOffset(200, 0)
					})
					tween:Play()
					tween.Completed:Once(function()
						listFrame.Visible = false
					end)
				end
				TweenService:Create(arrow, TweenInfo.new(0.2), {
					Rotation = 0
				}):Play()
			end
		end

		btn.MouseButton1Click:Connect(function()
			toggle(not opened)
		end)
	end


	local function makeColumnAPI(col)
		return {
			CreateSwitchToggle = function(_, ...) return PanelAPI.CreateSwitch(col, ...) end,
			CreateTextbox      = function(_, ...) PanelAPI.CreateTextbox(col, ...) end,
			CreateButton       = function(_, ...) PanelAPI.CreateButton(col, ...) end,
			CreateCopyButton   = function(_, ...) PanelAPI.CreateCopyButton(col, ...) end,
			Craetedropdown     = function(_, title, list, default, multi, callback)
				-- เช็คว่าเป็น multi หรือไม่
				if multi == true or multi == "Multi" then
					return PanelAPI.CreateMultiDropdown(col, title, list, default, callback)
				else
					-- ถ้า multi เป็น function แสดงว่าไม่มี multi parameter
					if type(multi) == "function" then
						return PanelAPI.CreateDropdown(col, title, list, default, multi)
					else
						return PanelAPI.CreateDropdown(col, title, list, default, callback)
					end
				end
			end,
			CreateSlider       = function(_, ...) PanelAPI.CreateSlider(col, ...) end,
			CreateKeybind      = function(_, ...) PanelAPI.CreateKeybind(col, ...) end,
			CreateColorPicker  = function(_, ...) PanelAPI.CreateColorPicker(col, ...) end,
			CreatePhoto        = function(_, ...) PanelAPI.CreatePhoto(col, ...) end,
		}
	end


	table.insert(self.Panels, panel)

	return {
		Panel = panel,
		Left   = makeColumnAPI(leftCol),
		Right  = makeColumnAPI(rightCol),
		Center = makeColumnAPI(centerCol),
	}
end


openBtn.MouseButton1Click:Connect(function()
	if rotating then return end
	rotating = true
	
	openBtn.Rotation = 0
	local t = TweenService:Create(openBtn, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 360})
	t:Play()
	t.Completed:Once(function()
		openBtn.Rotation = 0
		rotating = false
	end)
	
	UI.IsOpen = not UI.IsOpen

	if UI.IsOpen then
		if UI.TabBar then
			UI.TabBar.Visible = true
			TweenService:Create(UI.TabBar, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, 0, 0.22, 0)
			}):Play()
		end
		
		for i, p in ipairs(UI.Panels) do
			local savedState = _G.UIPanelStates[i]
			if savedState and savedState.isOpen then
				UI.OpenPanels[i] = true
				
				local targetPos = UDim2.new(
					savedState.position.xScale,
					savedState.position.xOffset,
					savedState.position.yScale,
					savedState.position.yOffset
				)
				
				p.Visible = true
				p.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, 0, -400)
				TweenService:Create(p, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = targetPos
				}):Play()
				
				local tabBtn = UI.TabButtons[i] and UI.TabButtons[i].Button
				if tabBtn then
					TweenService:Create(tabBtn, TweenInfo.new(0.25), {
						TextColor3 = Color3.new(1, 1, 1)
					}):Play()
				end
			end
		end
	else
		UI:AnimateAndClosePopups()
		
		if UI.TabBar then
			local tabTween = TweenService:Create(UI.TabBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0, -50)
			})
			tabTween:Play()
			tabTween.Completed:Once(function()
				UI.TabBar.Visible = false
			end)
		end

		for i, p in ipairs(UI.Panels) do
			if UI.OpenPanels[i] then
				_G.UIPanelStates[i] = {
					isOpen = true,
					position = {
						xScale = p.Position.X.Scale,
						xOffset = p.Position.X.Offset,
						yScale = p.Position.Y.Scale,
						yOffset = p.Position.Y.Offset
					}
				}
				
				local tween = TweenService:Create(p, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Position = UDim2.new(p.Position.X.Scale, p.Position.X.Offset, 0, -400)
				})
				tween:Play()
				tween.Completed:Once(function()
					p.Visible = false
				end)
				
				local tabBtn = UI.TabButtons[i] and UI.TabButtons[i].Button
				if tabBtn then
					TweenService:Create(tabBtn, TweenInfo.new(0.25), {
						TextColor3 = Color3.fromRGB(140, 140, 140)
					}):Play()
				end
			end
			UI.OpenPanels[i] = false
		end
	end
	
	TweenService:Create(Blur, TweenInfo.new(0.45), {
		Size = UI.IsOpen and 18 or 0
	}):Play()
end)

do
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "NotifyGui"
    notifyGui.IgnoreGuiInset = true
    notifyGui.ResetOnSpawn = false
    notifyGui.Parent = game.CoreGui

    local holder = Instance.new("Frame", notifyGui)
    holder.Size = UDim2.fromOffset(320, 400)
    holder.Position = UDim2.new(1, -20, 1, -20)
    holder.AnchorPoint = Vector2.new(1,1)
    holder.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", holder)
    layout.Padding = UDim.new(0,10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

-- Extra Mouse Effect
do
    local mouseGui = nil
    local mouseContainer = nil
    local dashes = {}
    local running = false
    local dashCount = 8
    local radius = 25
    local dashLength = 12
    local dashThickness = 3
    local rotationSpeed = 2
    local currentRotation = 0
    
    function UI:ExtraMouse(options)
        options = options or {}
        dashCount = options.dashCount or 8
        radius = options.radius or 25
        dashLength = options.dashLength or 12
        dashThickness = options.dashThickness or 3
        rotationSpeed = options.speed or 2
        local color = options.color or Color3.fromRGB(0, 170, 255)
        
        if running then
            self:StopExtraMouse()
        end
        
        dashes = {}
        currentRotation = 0
        
        mouseGui = Instance.new("ScreenGui")
        mouseGui.Name = "ExtraMouseGui"
        mouseGui.IgnoreGuiInset = true
        mouseGui.ResetOnSpawn = false
        mouseGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mouseGui.Parent = game.CoreGui
        
        mouseContainer = Instance.new("Frame", mouseGui)
        mouseContainer.Name = "MouseContainer"
        mouseContainer.Size = UDim2.fromOffset(100, 100)
        mouseContainer.BackgroundTransparency = 1
        mouseContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        mouseContainer.Position = UDim2.fromOffset(0, 0)
        
        -- สร้าง dashes รอบวงกลม
        for i = 1, dashCount do
            local angle = (i - 1) * (360 / dashCount)
            local rad = math.rad(angle)
            
            local dash = Instance.new("Frame", mouseContainer)
            dash.Name = "Dash" .. i
            dash.Size = UDim2.fromOffset(dashLength, dashThickness)
            dash.AnchorPoint = Vector2.new(0.5, 0.5)
            dash.BackgroundColor3 = color
            dash.BorderSizePixel = 0
            
            -- Position บนวงกลม
            local x = math.cos(rad) * radius
            local y = math.sin(rad) * radius
            dash.Position = UDim2.new(0.5, x, 0.5, y)
            dash.Rotation = angle
            
            Instance.new("UICorner", dash).CornerRadius = UDim.new(1, 0)
            
            -- Stroke glow
            local stroke = Instance.new("UIStroke", dash)
            stroke.Color = color
            stroke.Thickness = 1
            stroke.Transparency = 0.5
            
            table.insert(dashes, {frame = dash, baseAngle = angle})
        end
        
        running = true
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local mouse = player:GetMouse()
        local GuiService = game:GetService("GuiService")
        local guiInset = GuiService:GetGuiInset()
        
        -- Animation loop
        task.spawn(function()
            while running and mouseGui and mouseGui.Parent do
                -- อัพเดท position ตาม mouse (ลบ GUI inset)
                local mouseX = mouse.X
                local mouseY = mouse.Y + guiInset.Y
                mouseContainer.Position = UDim2.fromOffset(mouseX, mouseY)
                
                -- หมุน dashes
                currentRotation = currentRotation + rotationSpeed
                if currentRotation >= 360 then
                    currentRotation = currentRotation - 360
                end
                
                for i, dashData in ipairs(dashes) do
                    if dashData.frame and dashData.frame.Parent then
                        local newAngle = dashData.baseAngle + currentRotation
                        local rad = math.rad(newAngle)
                        
                        -- คำนวณ position บนวงกลม
                        local x = math.cos(rad) * radius
                        local y = math.sin(rad) * radius
                        
                        dashData.frame.Position = UDim2.new(0.5, x, 0.5, y)
                        dashData.frame.Rotation = newAngle
                        
                        -- Pulse effect
                        local pulse = 0.5 + 0.5 * math.sin(math.rad(currentRotation * 3 + i * 45))
                        dashData.frame.BackgroundTransparency = 0.2 + (0.3 * (1 - pulse))
                    end
                end
                
                task.wait(0.016)
            end
        end)
        
        return self
    end
    
    function UI:StopExtraMouse()
        running = false
        if mouseGui then
            mouseGui:Destroy()
            mouseGui = nil
            mouseContainer = nil
        end
        dashes = {}
    end
    
    function UI:SetExtraMouseColor(color)
        for _, dashData in ipairs(dashes) do
            dashData.frame.BackgroundColor3 = color
            local stroke = dashData.frame:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = color
            end
        end
    end
    
    function UI:SetExtraMouseSpeed(speed)
        rotationSpeed = speed
    end
    
    function UI:SetExtraMouseRadius(newRadius)
        radius = newRadius
    end
end

do
    local notifyHolder = nil
    
    local function getNotifyHolder()
        if notifyHolder and notifyHolder.Parent then
            return notifyHolder
        end
        
        local notifyGui = Instance.new("ScreenGui")
        notifyGui.Name = "NotifyGui"
        notifyGui.IgnoreGuiInset = true
        notifyGui.ResetOnSpawn = false
        notifyGui.Parent = game.CoreGui
        
        notifyHolder = Instance.new("Frame", notifyGui)
        notifyHolder.Size = UDim2.fromOffset(320, 400)
        notifyHolder.Position = UDim2.new(1, -20, 1, -20)
        notifyHolder.AnchorPoint = Vector2.new(1,1)
        notifyHolder.BackgroundTransparency = 1
        
        local layout = Instance.new("UIListLayout", notifyHolder)
        layout.Padding = UDim.new(0,10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        
        return notifyHolder
    end
    
    function UI:Notify(titleText, descText, duration)
        duration = duration or 3
        local holder = getNotifyHolder()

        local box = Instance.new("Frame", holder)
        box.BackgroundColor3 = Color3.fromRGB(22,22,22)
        box.BackgroundTransparency = 0
        box.AnchorPoint = Vector2.new(1,0)
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,12)

        local title = Instance.new("TextLabel", box)
        title.Size = UDim2.new(1,-20,0,22)
        title.Position = UDim2.fromOffset(10,6)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.new(1,1,1)

        local desc = Instance.new("TextLabel", box)
        desc.Size = UDim2.new(1,-20,0,30)
        desc.Position = UDim2.fromOffset(10,28)
        desc.BackgroundTransparency = 1
        desc.TextWrapped = true
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = descText
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 13
        desc.TextColor3 = Color3.fromRGB(200,200,200)

        local barBg = Instance.new("Frame", box)
        barBg.Size = UDim2.new(1,-20,0,4)
        barBg.Position = UDim2.new(0,10,1,-10)
        barBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

        local bar = Instance.new("Frame", barBg)
        bar.Size = UDim2.fromScale(0,1)
        bar.BackgroundColor3 = Color3.fromRGB(0,170,255)
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        box.BackgroundTransparency = 1
        box.Size = UDim2.fromOffset(300, 60)

        TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(300, 70)
        }):Play()

        TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.fromScale(1,1)
        }):Play()

        task.delay(duration, function()
            local tween = TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(300, 60)
            })
            tween:Play()
            tween.Completed:Once(function()
                box:Destroy()
            end)
        end)
    end
end

return UI

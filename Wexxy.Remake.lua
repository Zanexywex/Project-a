-- remake v2.2

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Theme = {
        Accent = Color3.fromRGB(130, 82, 255),
        AccentDark = Color3.fromRGB(67, 42, 120),
        Background = Color3.fromRGB(12, 12, 19),
        BackgroundDark = Color3.fromRGB(17, 16, 26),
        Surface = Color3.fromRGB(22, 21, 31),
        Outline = Color3.fromRGB(38, 36, 51),
        Text = Color3.fromRGB(241, 240, 247),
        TextDark = Color3.fromRGB(143, 141, 158),
        Success = Color3.fromRGB(57, 214, 116),
        Font = Enum.Font.Gotham,
    },
    ThemeRegistry = {},
    ConfigRegistry = {},
    Popups = {},
}

local Theme = Library.Theme
local LocalPlayer = Players.LocalPlayer

local function Create(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do object[property] = value end
    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 8)})
end

local function Stroke(parent, color, transparency)
    return Create("UIStroke", {Parent = parent, Color = color or Theme.Outline, Transparency = transparency or 0, Thickness = 1})
end

local function Padding(parent, left, right, top, bottom)
    return Create("UIPadding", {Parent = parent, PaddingLeft = UDim.new(0, left or 0), PaddingRight = UDim.new(0, right or 0), PaddingTop = UDim.new(0, top or 0), PaddingBottom = UDim.new(0, bottom or 0)})
end

local function Tween(object, properties, duration)
    TweenService:Create(object, TweenInfo.new(duration or .18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
end

local function MakeDraggable(handle, object)
    local dragging, startMouse, startPosition
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, startMouse, startPosition = true, input.Position, object.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startMouse
            object.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
end

function Library:SafeCallback(callback, ...)
    if not callback then return end
    local ok, result = pcall(callback, ...)
    if not ok then warn("[Remake UI] " .. tostring(result)) end
    return ok, result
end

function Library:SaveConfig(configName)
    local data = {}
    for flag, widget in pairs(self.ConfigRegistry) do data[flag] = widget.Get() end
    if not writefile then return self:Notify("Config Error", "Executor does not support writefile", 3) end
    if not isfolder("ProjectA_Configs") then makefolder("ProjectA_Configs") end
    writefile("ProjectA_Configs/" .. configName .. ".json", game:GetService("HttpService"):JSONEncode(data))
    self:Notify("Config Saved", configName, 3)
end

function Library:LoadConfig(configName)
    local path = "ProjectA_Configs/" .. configName .. ".json"
    if not (readfile and isfile(path)) then return self:Notify("Config Error", "Config not found", 3) end
    local data = game:GetService("HttpService"):JSONDecode(readfile(path))
    for flag, value in pairs(data) do if self.ConfigRegistry[flag] then self.ConfigRegistry[flag].Set(value) end end
    self:Notify("Config Loaded", configName, 3)
end

function Library:SetDefaultConfig()
    for _, widget in pairs(self.ConfigRegistry) do widget.Set(widget.Default) end
end

function Library:GetConfigs()
    local configs = {}
    if listfiles and isfolder("ProjectA_Configs") then
        for _, path in ipairs(listfiles("ProjectA_Configs")) do
            local name = path:match("([^/\\]+)%.json$")
            if name then table.insert(configs, name) end
        end
    end
    return configs
end

function Library:ApplyTheme(object, property, key)
    object[property] = Theme[key]
    table.insert(self.ThemeRegistry, {object, property, key})
end

function Library:UpdateTheme(key, color)
    Theme[key] = color
    for index = #self.ThemeRegistry, 1, -1 do
        local item = self.ThemeRegistry[index]
        if item[1] and item[1].Parent then
            if item[3] == key then item[1][item[2]] = color end
        else
            table.remove(self.ThemeRegistry, index)
        end
    end
end

function Library:Notify(title, description, duration)
    if not self.ScreenGui then return end
    duration = duration or 4
    local holder = self.NotifyContainer
    if not holder then
        holder = Create("Frame", {Parent = self.ScreenGui, BackgroundTransparency = 1, Position = UDim2.new(1, -344, 1, -22), AnchorPoint = Vector2.new(0, 1), Size = UDim2.fromOffset(324, 400), ZIndex = 6000})
        Create("UIListLayout", {Parent = holder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10)})
        self.NotifyContainer = holder
    end
    local card = Create("CanvasGroup", {Parent = holder, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 82), GroupTransparency = 1, ZIndex = 6001})
    Corner(card, 11); Stroke(card, Theme.Outline, .05)
    local scale = Create("UIScale", {Parent = card, Scale = .92})
    local icon = Create("Frame", {Parent = card, BackgroundColor3 = Theme.Accent, BackgroundTransparency = .82, BorderSizePixel = 0, Position = UDim2.fromOffset(13, 14), Size = UDim2.fromOffset(34, 34), ZIndex = 6002}); Corner(icon, 9); Stroke(icon, Theme.Accent, .25)
    Create("TextLabel", {Parent = icon, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, Text = "A", TextColor3 = Theme.Accent, TextSize = 14, ZIndex = 6003})
    Create("TextLabel", {Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(58, 11), Size = UDim2.new(1, -92, 0, 22), Font = Enum.Font.GothamMedium, Text = title or "Notification", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6002})
    Create("TextLabel", {Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(58, 32), Size = UDim2.new(1, -74, 0, 32), Font = Theme.Font, Text = description or "", TextColor3 = Theme.TextDark, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 6002})
    local close = Create("TextButton", {Parent = card, BackgroundTransparency = 1, Position = UDim2.new(1, -31, 0, 8), Size = UDim2.fromOffset(22, 22), Font = Enum.Font.GothamBold, Text = "×", TextColor3 = Theme.TextDark, TextSize = 13, AutoButtonColor = false, ZIndex = 6003})
    local progressTrack = Create("Frame", {Parent = card, BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Position = UDim2.new(0, 13, 1, -9), Size = UDim2.new(1, -26, 0, 3), ZIndex = 6002}); Corner(progressTrack, 2)
    local progress = Create("Frame", {Parent = progressTrack, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 6003}); Corner(progress, 2)
    local dismissed = false
    local function dismiss()
        if dismissed or not card.Parent then return end
        dismissed = true
        Tween(card, {GroupTransparency = 1}, .22); Tween(scale, {Scale = .94}, .22)
        task.delay(.23, function() if card.Parent then card:Destroy() end end)
    end
    close.MouseEnter:Connect(function() Tween(close, {TextColor3 = Theme.Accent}, .12) end)
    close.MouseLeave:Connect(function() Tween(close, {TextColor3 = Theme.TextDark}, .12) end)
    close.MouseButton1Click:Connect(dismiss)
    Tween(card, {GroupTransparency = 0}, .25); Tween(scale, {Scale = 1}, .28)
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.delay(duration, dismiss)
end

function Library:Success(description) self:Notify("Success", description or "Completed", 3) end
function Library:Succes(description) self:Success(description) end
function Library:Fail(description) self:Notify("Error", description or "Something went wrong", 4) end

function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Project A"
    local subtitle = options.Subtitle or "CONTROL PANEL"
    local parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    local old = parent:FindFirstChild("ProjectARemake")
    if old then old:Destroy() end

    local gui = Create("ScreenGui", {Name = "ProjectARemake", Parent = parent, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local main = Create("CanvasGroup", {Name = "Main", Parent = gui, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(.5, -390, .5, -250), Size = UDim2.fromOffset(780, 540), ClipsDescendants = true, GroupTransparency = 1})
    Corner(main, 16); Stroke(main, Theme.Outline, .25)
    local mainScale = Create("UIScale", {Parent = main, Scale = .92})
    local responsiveScale, window = 1, nil
    local camera = workspace.CurrentCamera
    local function updateResponsive()
        if not camera then return end
        local viewport = camera.ViewportSize
        responsiveScale = math.min(1, (viewport.X - 24) / 780, (viewport.Y - 70) / 540)
        responsiveScale = math.max(responsiveScale, .48)
        local visible = not window or window.Visible
        mainScale.Scale = responsiveScale * (visible and 1 or .92)
        main.Position = UDim2.new(.5, -390 * responsiveScale, .5, -270 * responsiveScale)
    end
    updateResponsive()
    if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive) end
    Library.ScreenGui, Library.MainFrame = gui, main

    local sidebar = Create("Frame", {Parent = main, BackgroundColor3 = Color3.fromRGB(14, 14, 22), BorderSizePixel = 0, Size = UDim2.new(0, 210, 1, 0), ClipsDescendants = true})
    Create("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0)})
    local logo = Create("TextLabel", {Parent = sidebar, BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 18), Size = UDim2.fromOffset(42, 42), Font = Enum.Font.GothamBold, Text = "A", TextColor3 = Theme.Accent, TextSize = 32})
    Create("TextLabel", {Parent = sidebar, BackgroundTransparency = 1, Position = UDim2.fromOffset(69, 19), Size = UDim2.fromOffset(120, 22), Font = Enum.Font.GothamBold, Text = title, TextColor3 = Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = sidebar, BackgroundTransparency = 1, Position = UDim2.fromOffset(70, 41), Size = UDim2.fromOffset(115, 14), Font = Theme.Font, Text = subtitle, TextColor3 = Theme.TextDark, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left})

    local tabHolder = Create("Frame", {Parent = sidebar, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 92), Size = UDim2.new(1, -24, 1, -160)})
    Create("UIListLayout", {Parent = tabHolder, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder})
    local userCard = Create("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new(0, 12, 1, -62), Size = UDim2.new(1, -24, 0, 48)})
    Corner(userCard, 10)
    local avatar = Create("ImageLabel", {Parent = userCard, BackgroundColor3 = Theme.AccentDark, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(32, 32), Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=100&h=100"})
    Corner(avatar, 16)
    local usernameLabel = Create("TextLabel", {Parent = userCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(49, 7), Size = UDim2.new(1, -57, 0, 18), Font = Enum.Font.GothamMedium, Text = "Wexxy Protect", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = userCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(49, 25), Size = UDim2.new(1, -57, 0, 15), Font = Theme.Font, Text = "Online", TextColor3 = Theme.Success, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
    local profilePopup = Create("CanvasGroup", {Parent = main, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -28, 1, -28), Visible = false, GroupTransparency = 1, ZIndex = 100}); Corner(profilePopup, 14); Stroke(profilePopup, Theme.Outline, .08)
    local profileScale = Create("UIScale", {Parent = profilePopup, Scale = .94})
    local profileBanner = Create("Frame", {Parent = profilePopup, BackgroundColor3 = Theme.AccentDark, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 108), ZIndex = 101})
    Create("UIGradient", {Parent = profileBanner, Rotation = 15, Color = ColorSequence.new(Theme.Accent, Theme.AccentDark), Transparency = NumberSequence.new(.08, .35)})
    local largeAvatar = Create("ImageLabel", {Parent = profilePopup, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(28, 67), Size = UDim2.fromOffset(76, 76), Image = avatar.Image, ZIndex = 103}); Corner(largeAvatar, 38); Stroke(largeAvatar, Theme.Surface, 0)
    Create("TextLabel", {Parent = profilePopup, BackgroundTransparency = 1, Position = UDim2.fromOffset(120, 112), Size = UDim2.new(1, -165, 0, 24), Font = Enum.Font.GothamBold, Text = "Wexxy Protect", TextColor3 = Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103})
    local profileClose = Create("TextButton", {Parent = profilePopup, BackgroundColor3 = Theme.BackgroundDark, BackgroundTransparency = .2, BorderSizePixel = 0, Position = UDim2.new(1, -46, 0, 16), Size = UDim2.fromOffset(30, 30), Font = Enum.Font.GothamBold, Text = "×", TextColor3 = Theme.Text, TextSize = 14, AutoButtonColor = false, ZIndex = 104}); Corner(profileClose, 8)
    local accountLabel = Create("TextLabel", {Parent = profilePopup, BackgroundTransparency = 1, Position = UDim2.fromOffset(120, 137), Size = UDim2.new(1, -165, 0, 18), Font = Theme.Font, Text = "@" .. LocalPlayer.Name, TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103})
    local sessionCard = Create("Frame", {Parent = profilePopup, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(28, 178), Size = UDim2.new(1, -56, 0, 66), ZIndex = 101}); Corner(sessionCard, 10); Stroke(sessionCard, Theme.Outline, .3)
    Create("TextLabel", {Parent = sessionCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 18), Font = Enum.Font.GothamMedium, Text = "SCRIPT SESSION", TextColor3 = Theme.TextDark, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102})
    local uptimeLabel = Create("TextLabel", {Parent = sessionCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 29), Size = UDim2.new(1, -28, 0, 23), Font = Theme.Font, Text = "Status • 0s", TextColor3 = Theme.Success, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102})
    local privacyCard = Create("Frame", {Parent = profilePopup, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(28, 258), Size = UDim2.new(1, -56, 0, 72), ZIndex = 101}); Corner(privacyCard, 10); Stroke(privacyCard, Theme.Outline, .3)
    Create("TextLabel", {Parent = privacyCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -82, 0, 20), Font = Enum.Font.GothamMedium, Text = "Hide name", TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102})
    Create("TextLabel", {Parent = privacyCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 30), Size = UDim2.new(1, -82, 0, 25), Font = Theme.Font, Text = "Hide your Roblox username inside this interface", TextColor3 = Theme.TextDark, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102})
    local hideSwitch = Create("TextButton", {Parent = privacyCard, BackgroundColor3 = Color3.fromRGB(54, 53, 66), BorderSizePixel = 0, Position = UDim2.new(1, -55, .5, -11), Size = UDim2.fromOffset(41, 22), Text = "", AutoButtonColor = false, ZIndex = 103}); Corner(hideSwitch, 11)
    local hideKnob = Create("Frame", {Parent = hideSwitch, BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(14, 14), ZIndex = 104}); Corner(hideKnob, 7)
    local profileButton = Create("TextButton", {Parent = userCard, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 10})
    local popupOpen, hideName, startedAt = false, false, os.clock()
    local function setProfileOpen(value)
        popupOpen = value
        if value then profilePopup.Visible = true; profilePopup.GroupTransparency = 1; profileScale.Scale = .94; Tween(profilePopup, {GroupTransparency = 0}, .18); Tween(profileScale, {Scale = 1}, .2)
        else Tween(profilePopup, {GroupTransparency = 1}, .15); Tween(profileScale, {Scale = .94}, .15); task.delay(.16, function() if not popupOpen then profilePopup.Visible = false end end) end
    end
    profileButton.MouseButton1Click:Connect(function() setProfileOpen(not popupOpen) end)
    profileClose.MouseEnter:Connect(function() Tween(profileClose, {TextColor3 = Theme.Accent}, .12) end)
    profileClose.MouseLeave:Connect(function() Tween(profileClose, {TextColor3 = Theme.TextDark}, .12) end)
    profileClose.MouseButton1Click:Connect(function() setProfileOpen(false) end)
    hideSwitch.MouseButton1Click:Connect(function()
        hideName = not hideName
        accountLabel.Text = hideName and "@hidden" or "@" .. LocalPlayer.Name
        Tween(hideSwitch, {BackgroundColor3 = hideName and Theme.Accent or Color3.fromRGB(54, 53, 66)}, .18)
        Tween(hideKnob, {Position = hideName and UDim2.fromOffset(23, 4) or UDim2.fromOffset(4, 4)}, .18)
    end)
    task.spawn(function()
        while gui.Parent do
            local seconds = math.floor(os.clock() - startedAt)
            local text = seconds < 60 and seconds .. "s" or seconds < 3600 and math.floor(seconds / 60) .. "m " .. seconds % 60 .. "s" or math.floor(seconds / 3600) .. "h " .. math.floor(seconds % 3600 / 60) .. "m"
            uptimeLabel.Text = "Status • Running " .. text
            task.wait(1)
        end
    end)

    local header = Create("Frame", {Parent = main, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(210, 0), Size = UDim2.new(1, -210, 0, 78)})
    local pageTitle = Create("TextLabel", {Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 13), Size = UDim2.new(1, -260, 0, 24), Font = Enum.Font.GothamBold, Text = "Dashboard", TextColor3 = Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    local pageDesc = Create("TextLabel", {Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 40), Size = UDim2.new(1, -260, 0, 18), Font = Theme.Font, Text = "Manage your modules and settings", TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
    local search = Create("TextBox", {Parent = header, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new(1, -222, .5, -18), Size = UDim2.fromOffset(198, 36), Font = Theme.Font, PlaceholderText = "Search controls...", PlaceholderColor3 = Theme.TextDark, Text = "", TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    Corner(search, 9); Stroke(search); Padding(search, 30, 10)
    local searchIcon = Create("ImageLabel", {Parent = search, BackgroundTransparency = 1, Position = UDim2.fromOffset(-18, 11), Size = UDim2.fromOffset(14, 14), Image = "rbxassetid://6031154871", ImageColor3 = Theme.TextDark, ScaleType = Enum.ScaleType.Fit})
    local content = Create("Frame", {Parent = main, BackgroundTransparency = 1, Position = UDim2.fromOffset(210, 78), Size = UDim2.new(1, -210, 1, -78), ClipsDescendants = true})
    local collapse = Create("TextButton", {Parent = main, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 205, .5, -30), Size = UDim2.fromOffset(10, 60), Font = Enum.Font.GothamBold, Text = "|", TextColor3 = Theme.TextDark, TextSize = 18, AutoButtonColor = false, ZIndex = 20})
    local collapseScale = Create("UIScale", {Parent = collapse, Scale = 1})
    local collapsed, draggingHandle, dragStart, suppressClick = false, false, 0, false
    local function setCollapsed(value)
        collapsed = value
        Tween(sidebar, {Size = UDim2.new(0, collapsed and 0 or 210, 1, 0)}, .3)
        Tween(header, {Position = UDim2.fromOffset(collapsed and 0 or 210, 0), Size = UDim2.new(1, collapsed and 0 or -210, 0, 78)}, .3)
        Tween(content, {Position = UDim2.fromOffset(collapsed and 0 or 210, 78), Size = UDim2.new(1, collapsed and 0 or -210, 1, -78)}, .3)
        Tween(collapse, {Position = UDim2.new(0, collapsed and 0 or 205, .5, -30)}, .3)
    end
    collapse.MouseEnter:Connect(function() Tween(collapseScale, {Scale = 1.25}, .14); Tween(collapse, {TextColor3 = Theme.Accent}, .14) end)
    collapse.MouseLeave:Connect(function() Tween(collapseScale, {Scale = 1}, .14); Tween(collapse, {TextColor3 = Theme.TextDark}, .14) end)
    collapse.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHandle, dragStart = true, input.Position.X end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if draggingHandle and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            draggingHandle = false
            local delta = input.Position.X - dragStart
            if math.abs(delta) > 20 then suppressClick = true; setCollapsed(delta < 0); task.defer(function() suppressClick = false end) end
        end
    end)
    collapse.MouseButton1Click:Connect(function() if not suppressClick then setCollapsed(not collapsed) end end)
    MakeDraggable(header, main)

    local resizing, resizeEdges, resizeStartMouse, resizeStartSize, resizeStartPosition
    local function beginResize(edges, input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        resizing, resizeEdges = true, edges
        resizeStartMouse, resizeStartSize, resizeStartPosition = input.Position, main.AbsoluteSize, main.Position
    end
    local function resizeHandle(edges, position, size)
        local handle = Create("TextButton", {Parent = main, BackgroundTransparency = 1, BorderSizePixel = 0, Position = position, Size = size, Text = "", AutoButtonColor = false, ZIndex = 100})
        handle.InputBegan:Connect(function(input) beginResize(edges, input) end)
        return handle
    end
    resizeHandle("L", UDim2.new(0, 0, 0, 12), UDim2.new(0, 7, .5, -54))
    resizeHandle("L", UDim2.new(0, 0, .5, 42), UDim2.new(0, 7, .5, -54))
    resizeHandle("R", UDim2.new(1, -7, 0, 12), UDim2.new(0, 7, 1, -24))
    resizeHandle("T", UDim2.new(0, 12, 0, 0), UDim2.new(1, -24, 0, 7))
    resizeHandle("B", UDim2.new(0, 12, 1, -7), UDim2.new(1, -24, 0, 7))
    resizeHandle("LT", UDim2.fromOffset(0, 0), UDim2.fromOffset(14, 14))
    resizeHandle("RT", UDim2.new(1, -14, 0, 0), UDim2.fromOffset(14, 14))
    resizeHandle("LB", UDim2.new(0, 0, 1, -14), UDim2.fromOffset(14, 14))
    resizeHandle("RB", UDim2.new(1, -14, 1, -14), UDim2.fromOffset(14, 14))
    UserInputService.InputChanged:Connect(function(input)
        if not resizing or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end
        local delta = input.Position - resizeStartMouse
        local width, height = resizeStartSize.X, resizeStartSize.Y
        local moveX, moveY = 0, 0
        if resizeEdges:find("R") then width = math.max(560, resizeStartSize.X + delta.X) end
        if resizeEdges:find("B") then height = math.max(380, resizeStartSize.Y + delta.Y) end
        if resizeEdges:find("L") then width = math.max(560, resizeStartSize.X - delta.X); moveX = resizeStartSize.X - width end
        if resizeEdges:find("T") then height = math.max(380, resizeStartSize.Y - delta.Y); moveY = resizeStartSize.Y - height end
        main.Size = UDim2.fromOffset(width, height)
        main.Position = UDim2.new(resizeStartPosition.X.Scale, resizeStartPosition.X.Offset + moveX, resizeStartPosition.Y.Scale, resizeStartPosition.Y.Offset + moveY)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)

    window = {Visible = true, Tabs = {}, CurrentTab = nil}
    local visibilityToken = 0
    function window:SetVisible(state)
        if self.Visible == state then return end
        self.Visible = state; visibilityToken += 1
        local token = visibilityToken
        if state then
            main.Visible = true; main.GroupTransparency = 1; mainScale.Scale = responsiveScale * .92
            Tween(main, {GroupTransparency = 0}, .25); Tween(mainScale, {Scale = responsiveScale}, .3)
        else
            for _, popup in ipairs(Library.Popups) do if popup and popup.Parent then popup.Visible = false end end
            Tween(main, {GroupTransparency = 1}, .2); Tween(mainScale, {Scale = responsiveScale * .92}, .2)
            task.delay(.21, function() if token == visibilityToken and not self.Visible then main.Visible = false end end)
        end
    end
    function window:Toggle() self:SetVisible(not self.Visible) end
    function window:Notify(...) return Library:Notify(...) end
    function window:Destroy() Library:Unload() end
    local mobile = UserInputService.TouchEnabled
    local quickToggle = Create("TextButton", {Name = "QuickToggle", Parent = gui, BackgroundColor3 = Theme.BackgroundDark, BackgroundTransparency = .08, BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, 8), Size = mobile and UDim2.fromOffset(44, 34) or UDim2.fromOffset(32, 26), Font = Enum.Font.GothamBold, Text = "|", TextColor3 = Theme.Accent, TextSize = mobile and 20 or 16, AutoButtonColor = false, ZIndex = 10000}); Corner(quickToggle, 8); Stroke(quickToggle, Theme.Outline, .1)
    local quickScale = Create("UIScale", {Parent = quickToggle, Scale = 1})
    quickToggle.MouseEnter:Connect(function() Tween(quickScale, {Scale = 1.08}, .12) end)
    quickToggle.MouseLeave:Connect(function() Tween(quickScale, {Scale = 1}, .12) end)
    quickToggle.MouseButton1Down:Connect(function() Tween(quickScale, {Scale = .9}, .08) end)
    quickToggle.MouseButton1Up:Connect(function() Tween(quickScale, {Scale = 1}, .12) end)
    quickToggle.MouseButton1Click:Connect(function() window:Toggle() end)

    local function selectTab(tab)
        if window.CurrentTab then
            window.CurrentTab.Frame.Visible = false
            Tween(window.CurrentTab.Button, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark})
            window.CurrentTab.Bar.Visible = false
        end
        window.CurrentTab = tab
        tab.Frame.Visible = true
        tab.Frame.Position = UDim2.fromOffset(18, 20)
        tab.Bar.Visible = true
        Tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(28, 22, 48), TextColor3 = Theme.Text})
        Tween(tab.Frame, {Position = UDim2.fromOffset(18, 14)}, .25)
        pageTitle.Text, pageDesc.Text = tab.Name, tab.Description
        search.Text = ""
    end

    function window:AddTab(name, tabOptions)
        tabOptions = type(tabOptions) == "table" and tabOptions or {}
        local button = Create("TextButton", {Parent = tabHolder, BackgroundColor3 = Color3.fromRGB(28, 22, 48), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 42), Font = Enum.Font.GothamMedium, Text = "   " .. tostring(name), TextColor3 = Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
        Corner(button, 9)
        local bar = Create("Frame", {Parent = button, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.new(0, 0, .5, -12), Size = UDim2.fromOffset(3, 24), Visible = false})
        Corner(bar, 2)
        local frame = Create("ScrollingFrame", {Parent = content, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(18, 14), Size = UDim2.new(1, -36, 1, -28), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, Visible = false})
        local columns = Create("Frame", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local left = Create("Frame", {Parent = columns, BackgroundTransparency = 1, Size = UDim2.new(.5, -7, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local right = Create("Frame", {Parent = columns, BackgroundTransparency = 1, Position = UDim2.new(.5, 7, 0, 0), Size = UDim2.new(.5, -7, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        Create("UIListLayout", {Parent = left, Padding = UDim.new(0, 12)}); Create("UIListLayout", {Parent = right, Padding = UDim.new(0, 12)})
        local tab = {Name = name, Description = tabOptions.Description or "Manage your modules and settings", Button = button, Bar = bar, Frame = frame, Controls = {}}
        function tab:AddLeftGroupbox(groupName) return Library:CreateGroupbox(left, groupName, tab) end
        function tab:AddRightGroupbox(groupName) return Library:CreateGroupbox(right, groupName, tab) end
        function tab:AddGroupbox(groupName, side) return Library:CreateGroupbox(side == "Right" and right or left, groupName, tab) end
        button.MouseButton1Click:Connect(function() selectTab(tab) end)
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then selectTab(tab) end
        return tab
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local tab = window.CurrentTab
        if not tab then return end
        local query = search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        for _, control in ipairs(tab.Controls) do
            control.Frame.Visible = query == "" or control.Name:lower():find(query, 1, true) ~= nil or control.Type:lower():find(query, 1, true) ~= nil
        end
    end)
    function window:AddBuiltinSettingsTab()
        local settings = self:AddTab("Settings", {Description = "Manage theme and configurations"})
        local configs = settings:AddLeftGroupbox("Configurations")
        local configName = configs:AddTextbox("Config Name", {Default = "default", Placeholder = "Config name"})
        configs:AddButton("Save Config", {Callback = function() Library:SaveConfig(configName:GetValue()) end})
        configs:AddButton("Load Config", {Callback = function() Library:LoadConfig(configName:GetValue()) end})
        configs:AddButton("Reset Config", {Callback = function() Library:SetDefaultConfig() end})
        return settings
    end
    Library.Window = window
    mainScale.Scale = responsiveScale * .92
    Tween(main, {GroupTransparency = 0}, .42); Tween(mainScale, {Scale = responsiveScale}, .42)
    return window
end

function Library:CreateGroupbox(parent, title, tab)
    local group = Create("Frame", {Name = tostring(title) .. "Group", Parent = parent, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
    Corner(group, 12)
    local groupStroke = Stroke(group, Theme.Outline, .2)
    groupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local groupHeader = Create("Frame", {Parent = group, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 43)})
    local accent = Create("Frame", {Parent = groupHeader, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.fromOffset(14, 15), Size = UDim2.fromOffset(3, 14)}); Corner(accent, 2)
    Create("TextLabel", {Parent = groupHeader, BackgroundTransparency = 1, Position = UDim2.fromOffset(25, 8), Size = UDim2.new(1, -39, 0, 28), Font = Enum.Font.GothamMedium, Text = tostring(title):upper(), TextColor3 = Theme.TextDark, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left})
    Create("Frame", {Parent = groupHeader, BackgroundColor3 = Theme.Outline, BackgroundTransparency = .35, BorderSizePixel = 0, Position = UDim2.new(0, 14, 1, -1), Size = UDim2.new(1, -28, 0, 1)})
    local container = Create("Frame", {Parent = group, BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 52), Size = UDim2.new(1, -22, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
    Create("UIListLayout", {Parent = container, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}); Padding(container, 0, 0, 0, 11)
    local functions = {}
    local function chain(object)
        return setmetatable(object or {}, {__index = functions})
    end
    local function register(frame, name, kind)
        frame.Name = tostring(name) .. kind
        if tab then table.insert(tab.Controls, {Frame = frame, Name = tostring(name), Type = kind}) end
        return frame
    end
    local function row(name, kind, height)
        return register(Create("Frame", {Parent = container, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height or 40)}), name, kind)
    end
    local function label(parentFrame, text, width)
        return Create("TextLabel", {Parent = parentFrame, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, width or -24, 1, 0), Font = Theme.Font, Text = tostring(text), TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
    end

    function functions:AddToggle(name, options)
        options = options or {}; local state = options.Default or false
        local frame = row(name, "Toggle", 40); Corner(frame, 8)
        local toggleLabel = label(frame, options.Text or name, -70); toggleLabel.Size = UDim2.new(1, -70, 0, 40)
        local switch = Create("TextButton", {Parent = frame, BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(54, 53, 66), BorderSizePixel = 0, Position = UDim2.new(1, -49, 0, 10), Size = UDim2.fromOffset(37, 20), Text = "", AutoButtonColor = false}); Corner(switch, 10)
        local switchScale = Create("UIScale", {Parent = switch, Scale = 1})
        local knob = Create("Frame", {Parent = switch, BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Position = state and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(14, 14)}); Corner(knob, 7)
        local object = {}
        function object:SetValue(value)
            state = not not value
            Tween(switch, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(54, 53, 66)})
            Tween(knob, {Position = state and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3)})
            Library:SafeCallback(options.Callback, state)
        end
        function object:GetValue() return state end
        function object:AddKeybind(keybindName, keybindOptions)
            if type(keybindName) == "table" then keybindOptions, keybindName = keybindName, name .. " Keybind" end
            keybindOptions = keybindOptions or {}
            keybindName = keybindName or name .. " Keybind"
            local currentKey = keybindOptions.Default or Enum.KeyCode.Unknown
            local binding = false
            toggleLabel.Size = UDim2.new(1, -145, 0, 40)
            local keyButton = Create("TextButton", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(1, -122, 0, 8), Size = UDim2.fromOffset(66, 24), Font = Theme.Font, Text = currentKey == Enum.KeyCode.Unknown and "NONE" or currentKey.Name:upper(), TextColor3 = Theme.TextDark, TextSize = 8, AutoButtonColor = false, ZIndex = 4}); Corner(keyButton, 6); local keyStroke = Stroke(keyButton, Theme.Outline, .25)
            local keyScale = Create("UIScale", {Parent = keyButton, Scale = 1})
            local function displayKey()
                keyButton.Text = currentKey == Enum.KeyCode.Unknown and "NONE" or currentKey.Name:upper()
            end
            function object:SetKey(value) currentKey = value; displayKey() end
            function object:GetKey() return currentKey end
            keyButton.MouseEnter:Connect(function() Tween(keyScale, {Scale = 1.05}, .14); Tween(keyStroke, {Color = Theme.Accent, Transparency = .1}, .14) end)
            keyButton.MouseLeave:Connect(function() Tween(keyScale, {Scale = 1}, .14); if not binding then Tween(keyStroke, {Color = Theme.Outline, Transparency = .25}, .14) end end)
            keyButton.MouseButton1Click:Connect(function()
                binding = true; keyButton.Text = "..."; Tween(keyStroke, {Color = Theme.Accent, Transparency = 0}, .14)
            end)
            UserInputService.InputBegan:Connect(function(input, processed)
                if binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then currentKey = input.KeyCode
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then currentKey = input.UserInputType
                    else return end
                    binding = false; displayKey(); Tween(keyStroke, {Color = Theme.Outline, Transparency = .25}, .14)
                    if keybindOptions.ChangedCallback then Library:SafeCallback(keybindOptions.ChangedCallback, currentKey) end
                    return
                end
                if not processed and (input.KeyCode == currentKey or input.UserInputType == currentKey) then object:SetValue(not state) end
            end)
            Library.ConfigRegistry[keybindOptions.Flag or keybindName] = {Type = "Keybind", Set = function(value) object:SetKey(value) end, Get = function() return currentKey end, Default = keybindOptions.Default or Enum.KeyCode.Unknown}
            return object
        end
        function object:AddColorPicker(pickerName, pickerOptions)
            pickerOptions = pickerOptions or {}
            pickerOptions._InlineParent = frame
            pickerOptions._ToggleLabel = toggleLabel
            functions:AddColorPicker(pickerName, pickerOptions)
            return object
        end
        function object:AddSlider(sliderName, sliderOptions)
            sliderOptions = sliderOptions or {}
            local minimum, maximum = sliderOptions.Min or 0, sliderOptions.Max or 100
            local sliderValue = math.clamp(sliderOptions.Default or minimum, minimum, maximum)
            frame.Size = UDim2.new(1, 0, 0, 88)
            local divider = Create("Frame", {Parent = frame, BackgroundColor3 = Theme.Outline, BackgroundTransparency = .25, BorderSizePixel = 0, Position = UDim2.fromOffset(10, 40), Size = UDim2.new(1, -20, 0, 1)})
            local sliderLabel = Create("TextLabel", {Parent = frame, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 44), Size = UDim2.new(1, -78, 0, 20), Font = Theme.Font, Text = sliderOptions.Text or sliderName, TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
            local valueBox = Create("TextBox", {Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(1, -68, 0, 44), Size = UDim2.fromOffset(56, 20), Font = Theme.Font, TextColor3 = Theme.TextDark, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = false})
            local sliderBar = Create("Frame", {Parent = frame, BackgroundColor3 = Color3.fromRGB(54, 52, 66), BorderSizePixel = 0, Position = UDim2.fromOffset(12, 70), Size = UDim2.new(1, -24, 0, 5)}); Corner(sliderBar, 3)
            local sliderFill = Create("Frame", {Parent = sliderBar, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)}); Corner(sliderFill, 3)
            local knob = Create("Frame", {Parent = sliderFill, BackgroundColor3 = Theme.Text, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(11, 11), ZIndex = 3}); Corner(knob, 6); Stroke(knob, Theme.Accent, .1)
            local sliderHit = Create("TextButton", {Parent = sliderBar, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, -8), Size = UDim2.new(1, 0, 1, 16), Text = "", ZIndex = 4})
            local dragging, sliderObject = false, {}
            local function formatSliderValue(val)
                if val == math.floor(val) then return tostring(math.floor(val)) end
                local s = string.format("%.2f", val)
                s = s:gsub("0+$", ""):gsub("%.$", "")
                return s
            end
            function sliderObject:SetValue(newValue)
                sliderValue = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
                local percent = (sliderValue - minimum) / math.max(maximum - minimum, 0.001)
                valueBox.Text = formatSliderValue(sliderValue) .. (sliderOptions.Suffix or "")
                Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, .1)
                Library:SafeCallback(sliderOptions.Callback, sliderValue)
            end
            function sliderObject:GetValue() return sliderValue end
            local function updateFromInput(input)
                local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                local increment = sliderOptions.Increment or 1
                sliderObject:SetValue(math.floor((minimum + (maximum - minimum) * percent) / increment + .5) * increment)
            end
            sliderHit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateFromInput(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromInput(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            valueBox.FocusLost:Connect(function()
                sliderObject:SetValue(tonumber(valueBox.Text:match("-?[%d%.]+")) or sliderValue)
            end)
            Library.ConfigRegistry[sliderOptions.Flag or sliderName] = {Type = "Slider", Set = function(value) sliderObject:SetValue(value) end, Get = function() return sliderValue end, Default = sliderOptions.Default or minimum}
            sliderObject:SetValue(sliderValue)
            return chain(sliderObject)
        end
        switch.MouseButton1Click:Connect(function() object:SetValue(not state) end)
        switch.MouseEnter:Connect(function() Tween(switchScale, {Scale = 1.08}, .15) end)
        switch.MouseLeave:Connect(function() Tween(switchScale, {Scale = 1}, .15) end)
        local flag = options.Flag or name
        Library.ConfigRegistry[flag] = {Type = "Toggle", Set = function(value) object:SetValue(value) end, Get = function() return state end, Default = options.Default or false}
        return chain(object)
    end

    function functions:AddButton(name, options)
        options = options or {}
        local frame = register(Create("TextButton", {Parent = container, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40), Font = Enum.Font.GothamMedium, Text = options.Text or name, TextColor3 = Theme.Text, TextSize = 11, AutoButtonColor = false}), name, "Button")
        Corner(frame, 8); Stroke(frame, Theme.Outline, .25)
        local buttonScale = Create("UIScale", {Parent = frame, Scale = 1})
        frame.MouseEnter:Connect(function() Tween(frame, {BackgroundColor3 = Theme.AccentDark}) end)
        frame.MouseLeave:Connect(function() Tween(frame, {BackgroundColor3 = Theme.Surface}) end)
        frame.MouseButton1Down:Connect(function() Tween(buttonScale, {Scale = .96}, .09); Tween(frame, {BackgroundColor3 = Theme.Accent}, .09) end)
        frame.MouseButton1Up:Connect(function() Tween(buttonScale, {Scale = 1}, .14); Tween(frame, {BackgroundColor3 = Theme.AccentDark}, .14) end)
        frame.MouseButton1Click:Connect(function() Library:SafeCallback(options.Callback) end)
        return chain({Instance = frame})
    end

    function functions:AddDropdown(name, default, options, multi, callback)
        if type(default) == "table" and default.Options then
            local config = default; default, options, multi, callback = config.Default, config.Options or config.Values, config.Multi, config.Callback
        end
        options, callback = options or {}, callback or function() end
        local selected = multi and {} or default
        if multi and type(default) == "table" then for _, value in ipairs(default) do table.insert(selected, value) end end
        local frame = row(name, "Dropdown", 66); Corner(frame, 8)
        local titleLabel = label(frame, name, -24); titleLabel.Size = UDim2.new(1, -24, 0, 25)
        local box = Create("TextButton", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 27), Size = UDim2.new(1, -16, 0, 31), Font = Theme.Font, TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, ClipsDescendants = true, AutoButtonColor = false}); Corner(box, 7); Padding(box, 10, 28)
        local arrow = Create("TextLabel", {Parent = box, BackgroundTransparency = 1, Position = UDim2.new(1, -23, 0, 0), Size = UDim2.fromOffset(20, 31), Font = Enum.Font.GothamBold, Text = "+", TextColor3 = Theme.TextDark, TextSize = 14})
        local list = Create("Frame", {Parent = frame, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 64), Size = UDim2.new(1, -16, 0, 0), ClipsDescendants = true, Visible = false, ZIndex = 10}); Corner(list, 8); Stroke(list, Theme.Outline)
        local find = Create("TextBox", {Parent = list, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 28), Font = Theme.Font, PlaceholderText = "Search options...", PlaceholderColor3 = Theme.TextDark, Text = "", TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 11}); Corner(find, 6); Stroke(find, Theme.Outline, .2); Padding(find, 9)
        -- Add All / Clear All buttons
        local btnRow = Create("Frame", {Parent = list, BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 38), Size = UDim2.new(1, -12, 0, 22), ZIndex = 11})
        local addAllBtn = Create("TextButton", {Parent = btnRow, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(.5, -2, 1, 0), Font = Enum.Font.GothamMedium, Text = "Add All", TextColor3 = Theme.Success, TextSize = 9, AutoButtonColor = false, ZIndex = 12}); Corner(addAllBtn, 5)
        local clearAllBtn = Create("TextButton", {Parent = btnRow, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new(.5, 2, 0, 0), Size = UDim2.new(.5, -2, 1, 0), Font = Enum.Font.GothamMedium, Text = "Clear All", TextColor3 = Color3.fromRGB(255, 100, 100), TextSize = 9, AutoButtonColor = false, ZIndex = 12}); Corner(clearAllBtn, 5)
        addAllBtn.MouseEnter:Connect(function() Tween(addAllBtn, {BackgroundColor3 = Theme.AccentDark}, .12) end)
        addAllBtn.MouseLeave:Connect(function() Tween(addAllBtn, {BackgroundColor3 = Theme.Surface}, .12) end)
        clearAllBtn.MouseEnter:Connect(function() Tween(clearAllBtn, {BackgroundColor3 = Theme.AccentDark}, .12) end)
        clearAllBtn.MouseLeave:Connect(function() Tween(clearAllBtn, {BackgroundColor3 = Theme.Surface}, .12) end)
        local choices = Create("ScrollingFrame", {Parent = list, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 64), Size = UDim2.new(1, -12, 1, -70), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ZIndex = 11})
        Create("UIListLayout", {Parent = choices, Padding = UDim.new(0, 3)})
        local opened, optionButtons = false, {}
        local object = {}
        local function display()
            if multi then
                local values = {}; for _, value in ipairs(selected) do table.insert(values, tostring(value)) end
                box.Text = #values > 0 and table.concat(values, ", ") or "Select..."
            else box.Text = selected ~= nil and tostring(selected) or "Select..." end
        end
        local function render()
            for _, child in ipairs(choices:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            optionButtons = {}
            for _, value in ipairs(options) do
                local text = tostring(value)
                local isSelected = not multi and selected == value
                if multi == true then
                    isSelected = false
                    for _, current in ipairs(selected) do if current == value then isSelected = true; break end end
                end
                local button = Create("TextButton", {Parent = choices, BackgroundColor3 = Theme.Accent, BackgroundTransparency = isSelected and .88 or 1, BorderSizePixel = 0, Size = UDim2.new(1, -3, 0, 27), Font = Theme.Font, Text = text, TextColor3 = isSelected and Theme.Accent or Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12}); Padding(button, 9)
                Corner(button, 4)
                table.insert(optionButtons, {Button = button, Text = text:lower()})
                button.MouseEnter:Connect(function() Tween(button, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = .9, TextColor3 = isSelected and Theme.Accent or Theme.Text}) end)
                button.MouseLeave:Connect(function() Tween(button, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = isSelected and .88 or 1, TextColor3 = isSelected and Theme.Accent or Theme.TextDark}) end)
                button.MouseButton1Click:Connect(function()
                    if multi then
                        local found
                        for index, current in ipairs(selected) do if current == value then table.remove(selected, index); found = true; break end end
                        if not found then table.insert(selected, value) end
                    else selected = value; opened = false end
                    find.Text = ""
                    display(); Library:SafeCallback(callback, selected)
                    if opened then render() else list.Visible = false; frame.Size = UDim2.new(1, 0, 0, 66); arrow.Text = "+" end
                end)
            end
        end
        -- Add All / Clear All button logic
        addAllBtn.MouseButton1Click:Connect(function()
            if multi then
                selected = {}
                for _, value in ipairs(options) do table.insert(selected, value) end
            else
                if #options > 0 then selected = options[1] end
            end
            display(); Library:SafeCallback(callback, selected)
            if opened then render() end
        end)
        clearAllBtn.MouseButton1Click:Connect(function()
            if multi then
                selected = {}
            else
                selected = nil
            end
            display(); Library:SafeCallback(callback, selected)
            if opened then render() end
        end)
        local function setOpen(value)
            opened = value; arrow.Text = value and "−" or "+"
            if value then
                render()
                list.Visible = true; list.Size = UDim2.new(1, -16, 0, 0)
                Tween(frame, {Size = UDim2.new(1, 0, 0, 250)}, .24)
                Tween(list, {Size = UDim2.new(1, -16, 0, 178)}, .24)
                Tween(arrow, {Rotation = 180}, .2); find:CaptureFocus()
            else
                find.Text = ""
                Tween(frame, {Size = UDim2.new(1, 0, 0, 66)}, .2)
                Tween(list, {Size = UDim2.new(1, -16, 0, 0)}, .18)
                Tween(arrow, {Rotation = 0}, .2)
                task.delay(.19, function() if not opened then list.Visible = false end end)
            end
        end
        box.MouseButton1Click:Connect(function() setOpen(not opened) end)
        find:GetPropertyChangedSignal("Text"):Connect(function() local query = find.Text:lower(); for _, item in ipairs(optionButtons) do item.Button.Visible = query == "" or item.Text:find(query, 1, true) ~= nil end end)
        function object:SetValue(value) selected = value; display(); render(); Library:SafeCallback(callback, selected) end
        function object:GetValue() return selected end
        function object:Refresh(values) options = values or {}; render(); display() end
        function object:Add(value) table.insert(options, value); render(); display() end
        function object:AddAutoRefresh()
            Players.PlayerAdded:Connect(function() object:Refresh(Players:GetPlayers()) end)
            Players.PlayerRemoving:Connect(function() object:Refresh(Players:GetPlayers()) end)
            return object
        end
        Library.ConfigRegistry[name] = {Type = "Dropdown", Set = function(value) object:SetValue(value) end, Get = function() return selected end, Default = default}
        render(); display(); return chain(object)
    end

    function functions:AddSlider(name, options)
        options = options or {}; local minimum, maximum = options.Min or 0, options.Max or 100; local value = math.clamp(options.Default or minimum, minimum, maximum)
        local frame = row(name, "Slider", 55); Corner(frame, 8)
        local text = label(frame, options.Text or name, -70); text.Size = UDim2.new(1, -70, 0, 32)
        local valueLabel = Create("TextBox", {Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(1, -65, 0, 0), Size = UDim2.fromOffset(53, 32), Font = Theme.Font, TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = false})
        local bar = Create("Frame", {Parent = frame, BackgroundColor3 = Color3.fromRGB(48, 46, 59), BorderSizePixel = 0, Position = UDim2.fromOffset(12, 38), Size = UDim2.new(1, -24, 0, 5)}); Corner(bar, 3)
        local fill = Create("Frame", {Parent = bar, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)}); Corner(fill, 3)
        local knob = Create("Frame", {Parent = fill, BackgroundColor3 = Theme.Text, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(11, 11), ZIndex = 3}); Corner(knob, 6); Stroke(knob, Theme.Accent, .1)
        local hit = Create("TextButton", {Parent = bar, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, -7), Size = UDim2.new(1, 0, 1, 14), Text = "", ZIndex = 4})
        local dragging, object = false, {}
        hit.MouseEnter:Connect(function() Tween(knob, {Size = UDim2.fromOffset(14, 14)}, .14) end)
        hit.MouseLeave:Connect(function() if not dragging then Tween(knob, {Size = UDim2.fromOffset(11, 11)}, .14) end end)
        local function formatSliderVal(val)
            if val == math.floor(val) then return tostring(math.floor(val)) end
            local s = string.format("%.2f", val)
            s = s:gsub("0+$", ""):gsub("%.$", "")
            return s
        end
        function object:SetValue(newValue)
            value = math.clamp(tonumber(newValue) or minimum, minimum, maximum)
            valueLabel.Text = formatSliderVal(value) .. (options.Suffix or "")
            fill.Size = UDim2.new((value - minimum) / math.max(maximum - minimum, 0.001), 0, 1, 0)
            Library:SafeCallback(options.Callback, value)
        end
        function object:GetValue() return value end
        valueLabel.Focused:Connect(function() Tween(valueLabel, {TextColor3 = Theme.Accent}, .15) end)
        valueLabel.FocusLost:Connect(function()
            Tween(valueLabel, {TextColor3 = Theme.TextDark}, .15)
            object:SetValue(tonumber(valueLabel.Text:match("-?[%d%.]+")) or value)
        end)
        local function update(input)
            local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local increment = options.Increment or .01
            object:SetValue(math.floor((minimum + (maximum - minimum) * percent) / increment + .5) * increment)
        end
        hit.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false; Tween(knob, {Size = UDim2.fromOffset(11, 11)}, .12) end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
        Library.ConfigRegistry[options.Flag or name] = {Type = "Slider", Set = function(newValue) object:SetValue(newValue) end, Get = function() return value end, Default = options.Default or minimum}
        object:SetValue(value); return chain(object)
    end

    function functions:AddRange(name, options)
        options = options or {}
        local minimum, maximum = options.Min or 0, options.Max or 100
        local low, high = options.DefaultMin or minimum, options.DefaultMax or maximum
        local frame = row(name, "Range", 76); Corner(frame, 8)
        local titleLabel = label(frame, options.Text or name, -24); titleLabel.Size = UDim2.new(1, -24, 0, 26)
        local lowBox = Create("TextBox", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 31), Size = UDim2.new(.5, -12, 0, 34), Font = Theme.Font, Text = tostring(low), TextColor3 = Theme.Text, TextSize = 10, ClearTextOnFocus = false}); Corner(lowBox, 6)
        local highBox = Create("TextBox", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(.5, 4, 0, 31), Size = UDim2.new(.5, -12, 0, 34), Font = Theme.Font, Text = tostring(high), TextColor3 = Theme.Text, TextSize = 10, ClearTextOnFocus = false}); Corner(highBox, 6)
        lowBox.Focused:Connect(function() Tween(lowBox, {BackgroundColor3 = Theme.Surface}, .18) end)
        lowBox.FocusLost:Connect(function() Tween(lowBox, {BackgroundColor3 = Theme.Background}, .18) end)
        highBox.Focused:Connect(function() Tween(highBox, {BackgroundColor3 = Theme.Surface}, .18) end)
        highBox.FocusLost:Connect(function() Tween(highBox, {BackgroundColor3 = Theme.Background}, .18) end)
        local object = {}
        function object:SetValue(values)
            low = math.clamp(tonumber(values[1]) or minimum, minimum, maximum)
            high = math.clamp(tonumber(values[2]) or maximum, low, maximum)
            lowBox.Text, highBox.Text = tostring(low), tostring(high)
            Library:SafeCallback(options.Callback, {low, high})
        end
        function object:GetValue() return {low, high} end
        function object:SetRange(minimumValue, maximumValue) object:SetValue({minimumValue, maximumValue}) end
        function object:GetRange() return low, high end
        local function update() object:SetValue({tonumber(lowBox.Text) or low, tonumber(highBox.Text) or high}) end
        lowBox.FocusLost:Connect(update); highBox.FocusLost:Connect(update)
        Library.ConfigRegistry[options.Flag or name] = {Type = "Range", Set = function(value) object:SetValue(value) end, Get = function() return {low, high} end, Default = {low, high}}
        return chain(object)
    end

    function functions:AddKeybind(name, options)
        options = options or {}; local key = options.Default or Enum.KeyCode.Unknown; local listening = false
        local frame = row(name, "Keybind", 40); Corner(frame, 8); label(frame, options.Text or name, -88)
        local button = Create("TextButton", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(1, -78, .5, -13), Size = UDim2.fromOffset(66, 26), Font = Theme.Font, Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper(), TextColor3 = Theme.TextDark, TextSize = 9}); Corner(button, 6)
        local object = {}
        function object:SetKey(newKey) key = newKey; button.Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name:upper() end
        function object:GetKey() return key end
        button.MouseButton1Click:Connect(function() listening = true; button.Text = "..." end)
        UserInputService.InputBegan:Connect(function(input, processed)
            if listening then listening = false; object:SetKey(input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType); return end
            if not processed and (input.KeyCode == key or input.UserInputType == key) then Library:SafeCallback(options.Callback, key) end
        end)
        Library.ConfigRegistry[options.Flag or name] = {Type = "Keybind", Set = function(value) object:SetKey(value) end, Get = function() return key end, Default = options.Default or Enum.KeyCode.Unknown}
        return chain(object)
    end

    function functions:AddTextbox(name, options)
        options = options or {}; local frame = row(name, "Textbox", 66); Corner(frame, 8)
        local titleLabel = label(frame, options.Text or name, -24); titleLabel.Size = UDim2.new(1, -24, 0, 27)
        local input = Create("TextBox", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 28), Size = UDim2.new(1, -16, 0, 30), Font = Theme.Font, Text = options.Default or "", PlaceholderText = options.Placeholder or "Enter text...", PlaceholderColor3 = Theme.TextDark, TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}); Corner(input, 6); Padding(input, 9)
        local inputScale = Create("UIScale", {Parent = input, Scale = 1})
        input.Focused:Connect(function() Tween(input, {BackgroundColor3 = Theme.Surface}, .18); Tween(inputScale, {Scale = 1.012}, .18) end)
        input.FocusLost:Connect(function() Tween(input, {BackgroundColor3 = Theme.Background}, .18); Tween(inputScale, {Scale = 1}, .18) end)
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if input:IsFocused() then Tween(inputScale, {Scale = 1.018}, .06); task.delay(.06, function() if input:IsFocused() then Tween(inputScale, {Scale = 1.012}, .09) end end) end
        end)
        local mask
        if options.Sensor or options.sensor then
            input.TextTransparency = 1
            mask = Create("TextLabel", {Parent = input, BackgroundTransparency = 1, Size = UDim2.new(1, -18, 1, 0), Position = UDim2.fromOffset(9, 0), Font = Theme.Font, Text = string.rep("*", #input.Text), TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
            input:GetPropertyChangedSignal("Text"):Connect(function() mask.Text = string.rep("*", #input.Text) end)
        end
        if options.Live then input:GetPropertyChangedSignal("Text"):Connect(function() Library:SafeCallback(options.Callback, input.Text) end) else input.FocusLost:Connect(function(enter) Library:SafeCallback(options.Callback, input.Text, enter) end) end
        local object = {SetValue = function(_, value) input.Text = tostring(value) end, GetValue = function() return input.Text end}
        Library.ConfigRegistry[options.Flag or name] = {Type = "Textbox", Set = function(value) object:SetValue(value) end, Get = function() return input.Text end, Default = options.Default or ""}
        return chain(object)
    end

    function functions:AddLabel(text)
        local frame = register(Create("TextLabel", {Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Font = Theme.Font, Text = tostring(text), TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left}), text, "Label")
        return chain({SetText = function(_, value) frame.Text = tostring(value) end})
    end

    function functions:AddDivider()
        return chain({Instance = Create("Frame", {Parent = container, BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)})})
    end

    function functions:AddColorPicker(name, options)
        options = options or {}; local color = options.Default or Color3.new(1, 1, 1)
        local inline = options._InlineParent ~= nil
        local frame = options._InlineParent or row(name, "ColorPicker", 40)
        if not inline then Corner(frame, 8); label(frame, options.Text or name, -62) elseif options._ToggleLabel then options._ToggleLabel.Size = UDim2.new(1, -112, 0, 40) end
        local preview = Create("TextButton", {Parent = frame, BackgroundColor3 = color, BorderSizePixel = 0, Position = inline and UDim2.new(1, -88, 0, 12) or UDim2.new(1, -48, .5, -10), Size = inline and UDim2.fromOffset(28, 16) or UDim2.fromOffset(36, 20), Text = "", ZIndex = inline and 4 or 1}); Corner(preview, 5); Stroke(preview)
        local popup = Create("CanvasGroup", {Parent = Library.ScreenGui, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Size = UDim2.fromOffset(236, 224), Visible = false, ZIndex = 5000, GroupTransparency = 1}); Corner(popup, 10); Stroke(popup, Theme.Outline)
        table.insert(Library.Popups, popup)
        local popupScale = Create("UIScale", {Parent = popup, Scale = .94})
        Create("TextLabel", {Parent = popup, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 7), Size = UDim2.new(1, -24, 0, 20), Font = Enum.Font.GothamMedium, Text = tostring(name), TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5001})
        local sv = Create("Frame", {Parent = popup, BackgroundColor3 = Color3.fromHSV(0, 1, 1), BorderSizePixel = 0, Position = UDim2.fromOffset(12, 33), Size = UDim2.fromOffset(180, 150), ZIndex = 5001}); Corner(sv, 5)
        local white = Create("Frame", {Parent = sv, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 5002}); Corner(white, 5)
        Create("UIGradient", {Parent = white, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})
        local black = Create("Frame", {Parent = sv, BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 5003}); Corner(black, 5)
        Create("UIGradient", {Parent = black, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
        local svHit = Create("TextButton", {Parent = sv, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 5005})
        local svPin = Create("Frame", {Parent = sv, BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(10, 10), ZIndex = 5004}); Corner(svPin, 5); Stroke(svPin, Color3.new(0, 0, 0))
        local hue = Create("Frame", {Parent = popup, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Position = UDim2.fromOffset(202, 33), Size = UDim2.fromOffset(22, 150), ZIndex = 5001}); Corner(hue, 5)
        Create("UIGradient", {Parent = hue, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(.17, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
        local hueHit = Create("TextButton", {Parent = hue, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 5005})
        local huePin = Create("Frame", {Parent = hue, BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, 0), Size = UDim2.new(1, 6, 0, 3), ZIndex = 5004}); Corner(huePin, 2); Stroke(huePin, Color3.new(0, 0, 0))
        local hex = Create("TextBox", {Parent = popup, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.fromOffset(12, 191), Size = UDim2.fromOffset(180, 24), Font = Theme.Font, TextColor3 = Theme.Text, TextSize = 10, ClearTextOnFocus = false, ZIndex = 5001}); Corner(hex, 5)
        local close = Create("TextButton", {Parent = popup, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.fromOffset(202, 191), Size = UDim2.fromOffset(22, 24), Font = Enum.Font.GothamBold, Text = "×", TextColor3 = Theme.Text, TextSize = 13, ZIndex = 5001}); Corner(close, 5)
        local h, s, v = color:ToHSV(); local dragSV, dragHue = false, false
        local object = {}
        local function hexText(value) return string.format("#%02X%02X%02X", math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255)) end
        function object:SetValue(value)
            color = value; h, s, v = color:ToHSV(); preview.BackgroundColor3 = color; sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svPin.Position = UDim2.fromScale(s, 1 - v); huePin.Position = UDim2.fromScale(.5, h); hex.Text = hexText(color)
            Library:SafeCallback(options.Callback, value)
        end
        function object:GetValue() return color end
        function object:Set(value) object:SetValue(value) end
        function object:Get() return color end
        local function updateSV(input) s = math.clamp((input.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1); v = 1 - math.clamp((input.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1); object:SetValue(Color3.fromHSV(h, s, v)) end
        local function updateHue(input) h = math.clamp((input.Position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1); object:SetValue(Color3.fromHSV(h, s, v)) end
        svHit.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = true; updateSV(input) end end)
        hueHit.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true; updateHue(input) end end)
        UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then if dragSV then updateSV(input) elseif dragHue then updateHue(input) end end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragSV, dragHue = false, false end end)
        hex.FocusLost:Connect(function()
            local value = hex.Text:gsub("#", "")
            if #value == 6 then local number = tonumber(value, 16); if number then object:SetValue(Color3.fromRGB(math.floor(number / 65536) % 256, math.floor(number / 256) % 256, number % 256)) end end
        end)
        local function setPopup(open)
            if open then
                popup.Position = UDim2.fromOffset(preview.AbsolutePosition.X - 188, preview.AbsolutePosition.Y + 28)
                popup.Visible = true; popup.GroupTransparency = 1; popupScale.Scale = .94
                Tween(popup, {GroupTransparency = 0}, .2); Tween(popupScale, {Scale = 1}, .22)
            else
                Tween(popup, {GroupTransparency = 1}, .16); Tween(popupScale, {Scale = .94}, .16)
                task.delay(.17, function() if popup.GroupTransparency > .9 then popup.Visible = false end end)
            end
        end
        preview.MouseButton1Click:Connect(function() setPopup(not popup.Visible) end)
        close.MouseButton1Click:Connect(function() setPopup(false) end)
        object:SetValue(color)
        Library.ConfigRegistry[options.Flag or name] = {Type = "ColorPicker", Set = function(value) object:SetValue(value) end, Get = function() return color end, Default = options.Default or Color3.new(1, 1, 1)}
        return chain(object)
    end

    function functions:AddDoubleButton(name1, name2, options1, options2)
        local frame = register(Create("Frame", {Parent = container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40)}), name1 .. " " .. name2, "Button")
        for index, data in ipairs({{name1, options1 or {}}, {name2, options2 or {}}}) do
            local button = Create("TextButton", {Parent = frame, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new((index - 1) * .5, index == 2 and 4 or 0, 0, 0), Size = UDim2.new(.5, -4, 1, 0), Font = Theme.Font, Text = data[2].Text or data[1], TextColor3 = Theme.Text, TextSize = 10}); Corner(button, 7)
            local scale = Create("UIScale", {Parent = button, Scale = 1})
            button.MouseEnter:Connect(function() Tween(button, {BackgroundColor3 = Theme.AccentDark}, .15) end)
            button.MouseLeave:Connect(function() Tween(button, {BackgroundColor3 = Theme.Surface}, .15); Tween(scale, {Scale = 1}, .12) end)
            button.MouseButton1Down:Connect(function() Tween(scale, {Scale = .95}, .08); Tween(button, {BackgroundColor3 = Theme.Accent}, .08) end)
            button.MouseButton1Up:Connect(function() Tween(scale, {Scale = 1}, .13); Tween(button, {BackgroundColor3 = Theme.AccentDark}, .13) end)
            button.MouseButton1Click:Connect(function() Library:SafeCallback(data[2].Callback) end)
        end
        return chain({Instance = frame})
    end
    return functions
end

function Library:Unload()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui, self.MainFrame, self.Window, self.NotifyContainer = nil, nil, nil, nil
    table.clear(self.ThemeRegistry)
    table.clear(self.Popups)
end

return Library

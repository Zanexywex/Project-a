-- v2.8


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
    ThemeListeners = {},
    ConfigRegistry = {},
    Popups = {},
    ActiveToggles = {},
    LoaderImage = "rbxassetid://89626946480449",
}

local Theme = Library.Theme
local LocalPlayer = Players.LocalPlayer
local function GetGuiParent()
    if type(gethui) == "function" then
        local ok, parent = pcall(gethui)
        if ok and typeof(parent) == "Instance" then return parent end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local function ClearGuiCopies(name, parent)
    local containers = {parent, LocalPlayer:FindFirstChildOfClass("PlayerGui")}
    local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if ok then containers[#containers + 1] = coreGui end
    for _, container in ipairs(containers) do
        if container then pcall(function()
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("ScreenGui") and child.Name == name then child:Destroy() end
            end
        end) end
    end
end

local function Create(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
        if typeof(value) == "Color3" then
            for themeKey, themeValue in pairs(Library.Theme) do
                if typeof(themeValue) == "Color3" and value == themeValue then
                    table.insert(Library.ThemeRegistry, {object, property, themeKey})
                    break
                end
            end
        end
    end
    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 8)})
end

local function Stroke(parent, color, transparency)
    local stroke = Create("UIStroke", {Parent = parent, Color = color or Theme.Outline, Transparency = transparency or 0, Thickness = 1})
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

local function Padding(parent, left, right, top, bottom)
    return Create("UIPadding", {Parent = parent, PaddingLeft = UDim.new(0, left or 0), PaddingRight = UDim.new(0, right or 0), PaddingTop = UDim.new(0, top or 0), PaddingBottom = UDim.new(0, bottom or 0)})
end

local function Tween(object, properties, duration)
    TweenService:Create(object, TweenInfo.new(duration or .25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
end

local function Wave(button, input)
    local position = input and input.Position or button.AbsolutePosition + button.AbsoluteSize / 2
    local diameter = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2
    local wave = Create("Frame", {Parent = button, BackgroundColor3 = Theme.Accent, BackgroundTransparency = .52, BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(position.X - button.AbsolutePosition.X, position.Y - button.AbsolutePosition.Y), Size = UDim2.fromOffset(0, 0), ZIndex = button.ZIndex + 1})
    Corner(wave, 999)
    local animation = TweenService:Create(wave, TweenInfo.new(.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1})
    animation:Play()
    animation.Completed:Connect(function() wave:Destroy() end)
end

local function AnimateInput(textBox, options)
    options = options or {}
    local strokeObj = options.Stroke
    local strokeDefaultColor = options.StrokeColor or Theme.Outline
    local strokeDefaultTransparency = options.StrokeTransparency or 0
    local icon = options.Icon
    local disabled = options.Disabled
    local display
    local animationId = 0
    if not disabled then
        display = Create("TextLabel", {Name = "SmoothText", Parent = textBox, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = textBox.Font, Text = textBox.Text, TextColor3 = textBox.TextColor3, TextSize = textBox.TextSize, TextXAlignment = textBox.TextXAlignment, TextYAlignment = textBox.TextYAlignment, TextTruncate = textBox.TextTruncate, ClipsDescendants = true, ZIndex = textBox.ZIndex + 1})
        textBox.TextTransparency = 1
    end
    local function characters(text)
        local result = {}
        for _, codepoint in utf8.codes(text) do table.insert(result, utf8.char(codepoint)) end
        return result
    end
    local function commonPrefix(a, b)
        local limit = math.min(#a, #b)
        local index = 0
        while index < limit and a[index + 1] == b[index + 1] do index += 1 end
        return index
    end
    local function playTypewriter()
        if disabled or not display then return end
        animationId += 1
        local id, target = animationId, textBox.Text
        local targetCharacters, shownCharacters = characters(target), characters(display.Text)
        local prefix = commonPrefix(shownCharacters, targetCharacters)
        if #targetCharacters <= #shownCharacters then display.Text = target; return end
        local visible = {}; for index = 1, prefix do visible[index] = targetCharacters[index] end
        display.Text = table.concat(visible)
        task.spawn(function()
            for index = prefix + 1, #targetCharacters do
                if id ~= animationId or not display.Parent then return end
                visible[index] = targetCharacters[index]
                display.Text = table.concat(visible)
                display.TextTransparency = .45
                Tween(display, {TextTransparency = 0}, .08)
                task.wait(math.min(.09, .9 / math.max(#targetCharacters - prefix, 1)))
            end
        end)
    end

    textBox.Focused:Connect(function()
        if strokeObj then Tween(strokeObj, {Color = Theme.Accent, Transparency = 0}, .25) end
        if icon then Tween(icon, {ImageColor3 = Theme.Accent}, .25) end
        if display then display.Text = textBox.Text end
    end)

    textBox.FocusLost:Connect(function()
        if strokeObj then Tween(strokeObj, {Color = strokeDefaultColor, Transparency = strokeDefaultTransparency}, .25) end
        if icon then Tween(icon, {ImageColor3 = Theme.TextDark}, .25) end
        if display then display.Text = textBox.Text; display.TextTransparency = 0 end
    end)

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if textBox:IsFocused() then playTypewriter() elseif display then display.Text = textBox.Text end
    end)
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

local HttpService = game:GetService("HttpService")

local function EncodeConfigValue(value)
    local valueType = typeof(value)
    if valueType == "Color3" then return {__type = "Color3", R = value.R, G = value.G, B = value.B} end
    if valueType == "EnumItem" then return {__type = "EnumItem", Value = tostring(value)} end
    if valueType == "table" then local result = {}; for key, item in pairs(value) do result[key] = EncodeConfigValue(item) end; return result end
    return value
end

local function DecodeConfigValue(value)
    if type(value) ~= "table" then return value end
    if value.__type == "Color3" then return Color3.new(value.R, value.G, value.B) end
    if value.__type == "EnumItem" then
        local enumType, enumName = tostring(value.Value):match("^Enum%.([^.]+)%.(.+)$")
        return enumType and Enum[enumType] and Enum[enumType][enumName] or Enum.KeyCode.Unknown
    end
    local result = {}; for key, item in pairs(value) do result[key] = DecodeConfigValue(item) end; return result
end

function Library:GetConfigData()
    local data = {}
    for flag, widget in pairs(self.ConfigRegistry) do data[flag] = EncodeConfigValue(widget.Get()) end
    return data
end

function Library:ApplyConfigData(data)
    for flag, value in pairs(data or {}) do if self.ConfigRegistry[flag] then self.ConfigRegistry[flag].Set(DecodeConfigValue(value)) end end
end

function Library:SaveConfig(configName)
    configName = tostring(configName or "default"):gsub("[^%w%-%_]", "_")
    if not writefile then return self:Notify("Config Error", "Executor does not support writefile", 3) end
    if not isfolder("ProjectA_Configs") then makefolder("ProjectA_Configs") end
    writefile("ProjectA_Configs/" .. configName .. ".json", HttpService:JSONEncode(self:GetConfigData()))
    self:Notify("Config Saved", configName, 3)
    return configName
end

function Library:LoadConfig(configName)
    local path = "ProjectA_Configs/" .. configName .. ".json"
    if not (readfile and isfile(path)) then return self:Notify("Config Error", "Config not found", 3) end
    local data = HttpService:JSONDecode(readfile(path))
    self:ApplyConfigData(data)
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
    table.sort(configs)
    return configs
end

function Library:ExportConfigCode()
    local json = HttpService:JSONEncode(self:GetConfigData())
    return "WEX1-" .. json:gsub(".", function(character) return string.format("%02X", string.byte(character)) end)
end

function Library:ImportConfigCode(code)
    local hex = tostring(code or ""):match("^WEX1%-(.+)$")
    if not hex or #hex % 2 ~= 0 then return false, "Invalid private code" end
    local json = hex:gsub("%x%x", function(pair) return string.char(tonumber(pair, 16)) end)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
    if not ok or type(data) ~= "table" then return false, "Invalid private code" end
    self:ApplyConfigData(data)
    self:Notify("Private Config", "Imported successfully", 3)
    return true
end

function Library:GetConfigSummary()
    local lines = {}
    for flag, widget in pairs(self.ConfigRegistry) do
        local value = widget.Get()
        if typeof(value) == "Color3" then value = string.format("#%02X%02X%02X", math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255))
        elseif typeof(value) == "EnumItem" then value = value.Name
        elseif type(value) == "table" then local values = {}; for _, item in ipairs(value) do table.insert(values, tostring(item)) end; value = table.concat(values, ", ") end
        table.insert(lines, tostring(flag) .. " = " .. tostring(value))
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

function Library:ApplyTheme(object, property, key)
    object[property] = Theme[key]
    table.insert(self.ThemeRegistry, {object, property, key})
end

function Library:UpdateTheme(key, color)
    Theme[key] = color
    if key == "Accent" then Theme.AccentDark = color:Lerp(Color3.new(0, 0, 0), .55) end
    for index = #self.ThemeRegistry, 1, -1 do
        local item = self.ThemeRegistry[index]
        if item[1] and item[1].Parent then
            if item[3] == key then item[1][item[2]] = color
            elseif key == "Accent" and item[3] == "AccentDark" then item[1][item[2]] = Theme.AccentDark end
        else
            table.remove(self.ThemeRegistry, index)
        end
    end
    for _, listener in ipairs(self.ThemeListeners) do task.spawn(listener, key) end
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
    local parent = GetGuiParent()
    ClearGuiCopies("ProjectARemake", parent)

    local gui = Create("ScreenGui", {Name = "ProjectARemake", Parent = parent, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local main = Create("CanvasGroup", {Name = "Main", Parent = gui, BackgroundColor3 = Theme.Background, BackgroundTransparency = .28, BorderSizePixel = 0, Position = UDim2.new(.5, -390, .5, -250), Size = UDim2.fromOffset(780, 540), ClipsDescendants = true, Visible = false})
    Corner(main, 16); Stroke(main, Theme.Outline, .25)
    local fadeBackground = Create("Frame", {Parent = main, BackgroundColor3 = Theme.Background, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1})
    Create("UIGradient", {Parent = fadeBackground, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 20, 52)), ColorSequenceKeypoint.new(.22, Theme.Background), ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 9, 15))})})
    local topFade = Create("Frame", {Parent = main, BackgroundColor3 = Theme.Accent, BackgroundTransparency = .18, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), ZIndex = 90})
    Create("UIGradient", {Parent = topFade, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.18, .15), NumberSequenceKeypoint.new(.82, .15), NumberSequenceKeypoint.new(1, 1)})})
    local mainScale = Create("UIScale", {Parent = main, Scale = .92})
    local responsiveScale, window, preferredScale = 1, nil, 1
    local camera = workspace.CurrentCamera
    local function updateResponsive()
        if not camera then return end
        local viewport = camera.ViewportSize
        responsiveScale = math.min(1, (viewport.X - 24) / 780, (viewport.Y - 70) / 540) * preferredScale
        responsiveScale = math.max(responsiveScale, .48)
        local visible = not window or window.Visible
        mainScale.Scale = responsiveScale * (visible and 1 or .92)
        main.Position = UDim2.new(.5, -390 * responsiveScale, .5, -270 * responsiveScale)
    end
    updateResponsive()
    if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive) end
    Library.ScreenGui, Library.MainFrame = gui, main

    local sidebar = Create("Frame", {Parent = main, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Size = UDim2.new(0, 132, 1, 0), ClipsDescendants = true})
    Corner(sidebar, 16)
    Create("UIGradient", {Parent = sidebar, Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(29, 23, 45), Color3.fromRGB(16, 15, 26))})
    Create("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Outline, BackgroundTransparency = .35, BorderSizePixel = 0, Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0)})
    local logoPanel = Create("Frame", {Parent = sidebar, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(10, 13), Size = UDim2.new(1, -20, 0, 54)})
    local logoBadge = Create("Frame", {Parent = logoPanel, BackgroundColor3 = Theme.AccentDark, BorderSizePixel = 0, Position = UDim2.fromOffset(31, 2), Size = UDim2.fromOffset(50, 50)})
    Corner(logoBadge, 25); Stroke(logoBadge, Theme.Accent, .35)
    Create("UIGradient", {Parent = logoBadge, Rotation = 45, Color = ColorSequence.new(Theme.AccentDark, Theme.BackgroundDark)})
    local logo = Create("TextLabel", {Parent = logoBadge, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, Text = "A", TextColor3 = Theme.Text, TextSize = 27})

    local tabHolder = Create("ScrollingFrame", {Parent = sidebar, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 77), Size = UDim2.new(1, -16, 1, -171), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = tabHolder, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
    Create("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Outline, BackgroundTransparency = .35, BorderSizePixel = 0, Position = UDim2.new(0, 14, 1, -94), Size = UDim2.new(1, -28, 0, 1)})
    local userCard = Create("Frame", {Parent = sidebar, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new(0, 8, 1, -86), Size = UDim2.new(1, -16, 0, 78)})
    Corner(userCard, 14); Stroke(userCard, Theme.Outline, .4)
    local avatar = Create("ImageLabel", {Parent = userCard, BackgroundColor3 = Theme.AccentDark, BorderSizePixel = 0, Position = UDim2.fromOffset(40, 5), Size = UDim2.fromOffset(36, 36), Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=100&h=100"})
    Corner(avatar, 18)
    local usernameLabel = Create("TextLabel", {Parent = userCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 43), Size = UDim2.new(1, -8, 0, 15), Font = Enum.Font.GothamMedium, Text = LocalPlayer.DisplayName, TextColor3 = Theme.Text, TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd})
    Create("TextLabel", {Parent = userCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 58), Size = UDim2.new(1, -8, 0, 12), Font = Theme.Font, Text = "● Online", TextColor3 = Theme.Success, TextSize = 8})
    local profilePopup = Create("CanvasGroup", {Parent = main, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.new(1, -28, 1, -28), ClipsDescendants = true, Visible = false, GroupTransparency = 1, ZIndex = 100}); Corner(profilePopup, 14); Stroke(profilePopup, Theme.Outline, .08)
    local profileBack = Create("Frame", {Parent = main, BackgroundColor3 = Theme.AccentDark, BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.new(1, -28, 1, -28), ClipsDescendants = true, Visible = false, ZIndex = 99}); Corner(profileBack, 14); Stroke(profileBack, Theme.Accent, .35)
    Create("UIGradient", {Parent = profileBack, Rotation = 25, Color = ColorSequence.new(Theme.AccentDark, Theme.BackgroundDark)})
    Create("TextLabel", {Parent = profileBack, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, Text = "A", TextColor3 = Theme.Accent, TextSize = 64, ZIndex = 100})
    local function profileText(parent, value, position, size, color, textSize, bold)
        return Create("TextLabel", {Parent = parent, BackgroundTransparency = 1, Position = position, Size = size, Font = bold and Enum.Font.GothamBold or Theme.Font, Text = value, TextColor3 = color or Theme.Text, TextSize = textSize or 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 103})
    end
    local function profileCard(position, size)
        local card = Create("Frame", {Parent = profilePopup, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = position, Size = size, ZIndex = 101}); Corner(card, 11); Stroke(card, Theme.Outline, .2)
        return card
    end
    profileText(profilePopup, "⌂  Welcome to " .. title .. "!", UDim2.fromOffset(18, 4), UDim2.new(1, -72, 0, 27), Theme.Text, 15, true)
    local profileClose = Create("TextButton", {Parent = profilePopup, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(1, -38, 0, 3), Size = UDim2.fromOffset(28, 28), Font = Enum.Font.GothamBold, Text = "×", TextColor3 = Theme.TextDark, TextSize = 19, AutoButtonColor = false, ZIndex = 104})
    local profileBanner = profileCard(UDim2.fromOffset(10, 36), UDim2.new(1, -20, 0, 118))
    profileBanner.BackgroundColor3 = Theme.AccentDark
    Create("UIGradient", {Parent = profileBanner, Rotation = 15, Color = ColorSequence.new(Theme.Accent, Theme.AccentDark), Transparency = NumberSequence.new(.55, .2)})
    local largeAvatar = Create("ImageLabel", {Parent = profileBanner, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(17, 17), Size = UDim2.fromOffset(84, 84), Image = avatar.Image, ZIndex = 103}); Corner(largeAvatar, 42); Stroke(largeAvatar, Theme.Accent, .25)
    profileText(profileBanner, "Welcome back,", UDim2.fromOffset(116, 27), UDim2.new(1, -260, 0, 17), Theme.TextDark, 10)
    local displayNameLabel = profileText(profileBanner, LocalPlayer.DisplayName, UDim2.fromOffset(116, 47), UDim2.new(1, -260, 0, 23), Theme.Text, 17, true)
    local accountLabel = profileText(profileBanner, "@" .. LocalPlayer.Name, UDim2.fromOffset(116, 74), UDim2.new(1, -260, 0, 17), Theme.TextDark, 10)
    local privacyCard = Create("Frame", {Parent = profileBanner, BackgroundTransparency = 1, Position = UDim2.new(1, -216, 1, -38), Size = UDim2.fromOffset(202, 29), ZIndex = 102})
    local function profileSwitch(labelText, position)
        local button = Create("TextButton", {Parent = privacyCard, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = position, Size = UDim2.new(.5, -2, 1, 0), Text = "", AutoButtonColor = false, ZIndex = 103}); Corner(button, 7); Stroke(button, Theme.Outline, .1)
        Create("TextLabel", {Parent = button, BackgroundTransparency = 1, Position = UDim2.fromOffset(7, 0), Size = UDim2.new(1, -39, 1, 0), Font = Theme.Font, Text = labelText, TextColor3 = Theme.Text, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104})
        local track = Create("Frame", {Parent = button, BackgroundColor3 = Color3.fromRGB(54, 53, 66), BorderSizePixel = 0, Position = UDim2.new(1, -35, .5, -9), Size = UDim2.fromOffset(29, 18), ZIndex = 104}); Corner(track, 9)
        local knob = Create("Frame", {Parent = track, BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(12, 12), ZIndex = 105}); Corner(knob, 6)
        return button, track, knob
    end
    local hideSwitch, nameTrack, nameKnob = profileSwitch("Name", UDim2.new(0, 0, 0, 0))
    local hideProfile, profileTrack, profileKnob = profileSwitch("Profile", UDim2.new(.5, 2, 0, 0))
    local stats = {}
    for index, info in ipairs({{"Players", "0/0"}, {"Session", "0s"}, {"FPS", "0"}, {"Ping", "0ms"}}) do
        local card = profileCard(UDim2.new((index - 1) / 4, 10 + (index - 1) * 2, 0, 161), UDim2.new(.25, -14, 0, 63))
        profileText(card, info[1], UDim2.fromOffset(12, 9), UDim2.new(1, -24, 0, 18), Theme.TextDark, 9)
        stats[index] = profileText(card, info[2], UDim2.fromOffset(12, 32), UDim2.new(1, -24, 0, 20), Theme.Text, 13, true)
    end
    local uptimeLabel = stats[2]
    local serverCard = profileCard(UDim2.fromOffset(10, 231), UDim2.new(1, -20, 0, 118))
    local gameIcon = Create("ImageLabel", {Parent = serverCard, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(12, 17), Size = UDim2.fromOffset(60, 60), Image = "rbxthumb://type=GameIcon&id=" .. game.PlaceId .. "&w=150&h=150", ZIndex = 103}); Corner(gameIcon, 9)
    local gameNameLabel = profileText(serverCard, game.Name, UDim2.fromOffset(83, 15), UDim2.new(1, -320, 0, 19), Theme.Text, 12, true)
    task.spawn(function()
        local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId, Enum.InfoType.Asset) end)
        if ok and info and gameNameLabel.Parent then
            gameNameLabel.Text = info.Name or game.Name
            if info.IconImageAssetId and info.IconImageAssetId > 0 then gameIcon.Image = "rbxassetid://" .. info.IconImageAssetId end
        end
    end)
    profileText(serverCard, "Job  " .. game.JobId:sub(1, 16) .. "...", UDim2.fromOffset(83, 43), UDim2.new(1, -320, 0, 14), Theme.TextDark, 8)
    profileText(serverCard, "Place  " .. game.PlaceId, UDim2.fromOffset(83, 60), UDim2.new(1, -320, 0, 14), Theme.TextDark, 8)
    profileText(serverCard, "Universe  " .. game.GameId, UDim2.fromOffset(83, 77), UDim2.new(1, -320, 0, 14), Theme.TextDark, 8)
    local function profileAction(parent, textValue, position, size, action)
        local button = Create("TextButton", {Parent = parent, BackgroundColor3 = Theme.AccentDark, BackgroundTransparency = .35, BorderSizePixel = 0, Position = position, Size = size, Font = Enum.Font.GothamMedium, Text = textValue, TextColor3 = Theme.Text, TextSize = 10, AutoButtonColor = false, ZIndex = 103}); Corner(button, 7); Stroke(button, Theme.Accent, .65)
        button.MouseEnter:Connect(function() Tween(button, {BackgroundTransparency = .05}, .15) end)
        button.MouseLeave:Connect(function() Tween(button, {BackgroundTransparency = .35}, .15) end)
        button.MouseButton1Click:Connect(function() Library:SafeCallback(action) end)
        return button
    end
    local function copyValue(value)
        if setclipboard then setclipboard(tostring(value)); Library:Notify("Copied", "Copied to clipboard", 2) else Library:Notify("Clipboard", "Clipboard unavailable", 2) end
    end
    profileAction(serverCard, "Rejoin", UDim2.new(1, -226, 0, 13), UDim2.fromOffset(104, 28), function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    profileAction(serverCard, "Copy Job ID", UDim2.new(1, -116, 0, 13), UDim2.fromOffset(104, 28), function() copyValue(game.JobId) end)
    profileAction(serverCard, "Copy Place ID", UDim2.new(1, -226, 0, 46), UDim2.fromOffset(104, 28), function() copyValue(game.PlaceId) end)
    profileAction(serverCard, "Copy Universe", UDim2.new(1, -116, 0, 46), UDim2.fromOffset(104, 28), function() copyValue(game.GameId) end)
    profileAction(serverCard, "Join New Server", UDim2.new(1, -226, 0, 79), UDim2.fromOffset(214, 28), function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
    local executorCard = profileCard(UDim2.fromOffset(10, 356), UDim2.new(1, -20, 0, 55))
    profileText(executorCard, "♢  " .. title, UDim2.fromOffset(14, 8), UDim2.new(1, -28, 0, 18), Theme.Text, 11, true)
    profileText(executorCard, "Profile and server information", UDim2.fromOffset(14, 27), UDim2.new(1, -28, 0, 16), Theme.TextDark, 9)
    local infoCard = profileCard(UDim2.fromOffset(10, 418), UDim2.new(1, -20, 0, 55))
    profileText(infoCard, "User ID", UDim2.fromOffset(14, 8), UDim2.new(.5, -28, 0, 18), Theme.Text, 10, true)
    profileText(infoCard, tostring(LocalPlayer.UserId), UDim2.fromOffset(14, 27), UDim2.new(.5, -28, 0, 16), Theme.TextDark, 9)
    profileAction(infoCard, "Copy User ID", UDim2.new(1, -116, 0, 13), UDim2.fromOffset(104, 28), function() copyValue(LocalPlayer.UserId) end)
    local profileButton = Create("TextButton", {Parent = userCard, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 10})
    local popupOpen, hideName, hideProfileName, startedAt, flipToken = false, false, false, os.clock(), 0
    local function setProfileOpen(value)
        if popupOpen == value then return end
        popupOpen = value
        flipToken += 1
        local token = flipToken
        local fullSize, edgeSize = UDim2.new(1, -28, 1, -28), UDim2.new(0, 0, 1, -28)
        local function flip(object, size, duration, direction)
            local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, direction), {Size = size})
            tween:Play(); tween.Completed:Wait()
        end
        task.spawn(function()
            if value then
                profilePopup.Visible = false; profileBack.Visible = true; profileBack.Size = fullSize
                flip(profileBack, edgeSize, .16, Enum.EasingDirection.In)
                if token ~= flipToken then return end
                profileBack.Visible = false; profilePopup.Size = edgeSize; profilePopup.GroupTransparency = 0; profilePopup.Visible = true
                flip(profilePopup, fullSize, .22, Enum.EasingDirection.Out)
            else
                profileBack.Visible = false; profilePopup.Visible = true; profilePopup.GroupTransparency = 0
                flip(profilePopup, edgeSize, .17, Enum.EasingDirection.In)
                if token ~= flipToken then return end
                profilePopup.Visible = false; profileBack.Size = edgeSize; profileBack.Visible = true
                flip(profileBack, fullSize, .17, Enum.EasingDirection.Out)
                if token ~= flipToken then return end
                flip(profileBack, edgeSize, .16, Enum.EasingDirection.In)
                if token == flipToken then profileBack.Visible = false end
            end
        end)
    end
    profileButton.MouseButton1Click:Connect(function() setProfileOpen(not popupOpen) end)
    profileClose.MouseEnter:Connect(function() Tween(profileClose, {TextColor3 = Theme.Accent}, .12) end)
    profileClose.MouseLeave:Connect(function() Tween(profileClose, {TextColor3 = Theme.TextDark}, .12) end)
    profileClose.MouseButton1Click:Connect(function() setProfileOpen(false) end)
    hideSwitch.MouseButton1Click:Connect(function()
        hideName = not hideName
        accountLabel.Text = hideName and "@hidden" or "@" .. LocalPlayer.Name
        Tween(nameTrack, {BackgroundColor3 = hideName and Theme.Accent or Color3.fromRGB(54, 53, 66)}, .18)
        Tween(nameKnob, {Position = hideName and UDim2.fromOffset(14, 3) or UDim2.fromOffset(3, 3)}, .18)
    end)
    hideProfile.MouseButton1Click:Connect(function()
        hideProfileName = not hideProfileName
        displayNameLabel.Text = hideProfileName and "Hidden" or LocalPlayer.DisplayName
        usernameLabel.Text = displayNameLabel.Text
        Tween(profileTrack, {BackgroundColor3 = hideProfileName and Theme.Accent or Color3.fromRGB(54, 53, 66)}, .18)
        Tween(profileKnob, {Position = hideProfileName and UDim2.fromOffset(14, 3) or UDim2.fromOffset(3, 3)}, .18)
    end)
    local frames = 0
    local fpsConnection = RunService.RenderStepped:Connect(function() frames += 1 end)
    gui.Destroying:Connect(function() fpsConnection:Disconnect() end)
    task.spawn(function()
        while gui.Parent do
            local seconds = math.floor(os.clock() - startedAt)
            local text = seconds < 60 and seconds .. "s" or seconds < 3600 and math.floor(seconds / 60) .. "m " .. seconds % 60 .. "s" or math.floor(seconds / 3600) .. "h " .. math.floor(seconds % 3600 / 60) .. "m"
            uptimeLabel.Text = text
            stats[1].Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
            stats[3].Text = tostring(frames); frames = 0
            stats[4].Text = math.floor(LocalPlayer:GetNetworkPing() * 1000 + .5) .. "ms"
            task.wait(1)
        end
    end)

    local header = Create("Frame", {Parent = main, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(132, 0), Size = UDim2.new(1, -132, 0, 78), ZIndex = 80})
    Corner(header, 16)
    Create("Frame", {Parent = header, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -16), Size = UDim2.new(1, 0, 0, 16), ZIndex = 80})
    local pageTitle = Create("TextLabel", {Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 13), Size = UDim2.new(1, -260, 0, 24), Font = Enum.Font.GothamBold, Text = "Dashboard", TextColor3 = Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    local pageDesc = Create("TextLabel", {Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 40), Size = UDim2.new(1, -260, 0, 18), Font = Theme.Font, Text = "Manage your modules and settings", TextColor3 = Theme.TextDark, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
    local search = Create("TextBox", {Parent = header, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new(1, -222, .5, -18), Size = UDim2.fromOffset(198, 36), Font = Theme.Font, PlaceholderText = "Search", PlaceholderColor3 = Theme.TextDark, Text = "", TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 81})
    Corner(search, 9); local searchStroke = Stroke(search); Padding(search, 30, 10)
    local searchIcon = Create("ImageLabel", {Parent = search, BackgroundTransparency = 1, Position = UDim2.fromOffset(-18, 11), Size = UDim2.fromOffset(14, 14), Image = "rbxassetid://6031154871", ImageColor3 = Theme.TextDark, ScaleType = Enum.ScaleType.Fit})
    AnimateInput(search, {Stroke = searchStroke, Icon = searchIcon})
    local searchResults = Create("ScrollingFrame", {Parent = header, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.new(1, -222, 0, 69), Size = UDim2.fromOffset(198, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, Visible = false, ZIndex = 80}); Corner(searchResults, 9); Stroke(searchResults, Theme.Outline, .1)
    Create("UIListLayout", {Parent = searchResults, Padding = UDim.new(0, 2)})
    local content = Create("Frame", {Parent = main, BackgroundTransparency = 1, Position = UDim2.fromOffset(132, 78), Size = UDim2.new(1, -132, 1, -78), ClipsDescendants = true})
    local collapse = Create("TextButton", {Parent = main, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 127, .5, -30), Size = UDim2.fromOffset(10, 60), Font = Enum.Font.GothamBold, Text = "‹", TextColor3 = Theme.Accent, TextSize = 15, AutoButtonColor = false, ZIndex = 90})
    local collapseScale = Create("UIScale", {Parent = collapse, Scale = 1})
    local collapsed, draggingHandle, dragStart, suppressClick, collapseToken = false, false, 0, false, 0
    local function setCollapsed(value)
        if collapsed == value then return end
        collapsed = value
        collapseToken += 1
        local token = collapseToken
        Tween(sidebar, {Size = UDim2.new(0, collapsed and 0 or 132, 1, 0)}, .3)
        Tween(header, {Position = UDim2.fromOffset(collapsed and 0 or 132, 0), Size = UDim2.new(1, collapsed and 0 or -132, 0, 78)}, .3)
        Tween(content, {Position = UDim2.fromOffset(collapsed and 0 or 132, 78), Size = UDim2.new(1, collapsed and 0 or -132, 1, -78)}, .3)
        Tween(collapse, {Position = UDim2.new(0, collapsed and 0 or 127, .5, -30)}, .3)
        task.delay(.31, function()
            if token ~= collapseToken or not main.Parent then return end
            local offset = collapsed and 0 or 132
            sidebar.Size = UDim2.new(0, offset, 1, 0)
            header.Position = UDim2.fromOffset(offset, 0); header.Size = UDim2.new(1, -offset, 0, 78)
            content.Position = UDim2.fromOffset(offset, 78); content.Size = UDim2.new(1, -offset, 1, -78)
            collapse.Position = UDim2.new(0, collapsed and 0 or 127, .5, -30)
        end)
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
            if math.abs(delta) > 20 then suppressClick = true; setCollapsed(delta < 0); task.delay(.15, function() suppressClick = false end) end
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
    function window:ShowEntrance()
        if not self.Visible then return end
        local target = main.Position
        main.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 30)
        mainScale.Scale = responsiveScale * .76
        main.GroupTransparency = 1
        main.Visible = true
        Tween(main, {Position = target, GroupTransparency = 0}, .38)
        TweenService:Create(mainScale, TweenInfo.new(.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = responsiveScale}):Play()
    end
    function window:SetVisible(state)
        if self.Visible == state then return end
        self.Visible = state; visibilityToken += 1
        local token = visibilityToken
        if state then
            if collapsed then setCollapsed(false) end
            setProfileOpen(false)
            self:ShowEntrance()
        else
            for _, popup in ipairs(Library.Popups) do if popup and popup.Parent then popup.Visible = false end end
            Tween(mainScale, {Scale = responsiveScale * .92}, .2)
            task.delay(.21, function() if token == visibilityToken and not self.Visible then main.Visible = false end end)
        end
    end
    function window:Toggle() self:SetVisible(not self.Visible) end
    function window:Notify(...) return Library:Notify(...) end
    function window:Destroy() Library:Unload() end
    local mobile = UserInputService.TouchEnabled
    local quickToggle = Create("TextButton", {Name = "QuickToggle", Parent = gui, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 70), Size = UDim2.fromOffset(48, 48), Font = Enum.Font.GothamBold, Text = "◉", TextColor3 = Theme.Accent, TextSize = 27, AutoButtonColor = false, ZIndex = 10000}); Corner(quickToggle, 24); Stroke(quickToggle, Theme.Accent, .35)
    window.QuickToggle = quickToggle
    local hoverCard = Create("Frame", {Parent = gui, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(66, 62), Size = UDim2.fromOffset(180, 88), Visible = false, ZIndex = 10001}); Corner(hoverCard, 12); Stroke(hoverCard, Theme.Outline, 0)
    Create("TextLabel", {Parent = hoverCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 18), Font = Enum.Font.GothamBold, Text = title, TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    Create("TextLabel", {Parent = hoverCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -24, 0, 14), Font = Theme.Font, Text = subtitle, TextColor3 = Theme.TextDark, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    local activeLabel = Create("TextLabel", {Parent = hoverCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 48), Size = UDim2.new(1, -24, 0, 20), Font = Theme.Font, Text = "0 running", TextColor3 = Theme.Accent, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    local namesLabel = Create("TextLabel", {Parent = hoverCard, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 68), Size = UDim2.new(1, -24, 0, 0), Font = Theme.Font, Text = "", TextColor3 = Theme.Text, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 10002})
    local hintLabel = Create("TextLabel", {Parent = hoverCard, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 1, -19), Size = UDim2.new(1, -24, 0, 12), Font = Theme.Font, Text = "Click or press RCtrl to open", TextColor3 = Theme.TextDark, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    local function updateHoverCard()
        local names = {}
        for name, enabled in pairs(Library.ActiveToggles) do if enabled then table.insert(names, name) end end
        table.sort(names)
        activeLabel.Text = #names .. " running"
        local shown = {}
        for i = 1, math.min(#names, 6) do shown[i] = "• " .. names[i] end
        if #names > 6 then table.insert(shown, "+" .. (#names - 6) .. " more") end
        namesLabel.Text = table.concat(shown, "\n")
        namesLabel.Size = UDim2.new(1, -24, 0, #shown * 14)
        hoverCard.Size = UDim2.fromOffset(180, 88 + #shown * 14)
        hintLabel.Text = window.Visible and "Click or press RCtrl to close" or "Click or press RCtrl to open"
    end
    local quickScale = Create("UIScale", {Parent = quickToggle, Scale = 1})
    quickToggle.MouseEnter:Connect(function()
        updateHoverCard()
        local viewport = workspace.CurrentCamera.ViewportSize
        local x = quickToggle.AbsolutePosition.X < viewport.X / 2 and quickToggle.AbsolutePosition.X + quickToggle.AbsoluteSize.X + 10 or quickToggle.AbsolutePosition.X - hoverCard.AbsoluteSize.X - 10
        hoverCard.Position = UDim2.fromOffset(x, math.clamp(quickToggle.AbsolutePosition.Y - 8, 0, math.max(0, viewport.Y - hoverCard.AbsoluteSize.Y)))
        hoverCard.Visible = true; Tween(quickScale, {Scale = 1.08}, .12)
    end)
    quickToggle.MouseLeave:Connect(function() hoverCard.Visible = false; Tween(quickScale, {Scale = 1}, .12) end)
    quickToggle.MouseButton1Down:Connect(function() Tween(quickScale, {Scale = .9}, .08) end)
    quickToggle.MouseButton1Up:Connect(function() Tween(quickScale, {Scale = 1}, .12) end)
    local quickDragging, quickMoved, quickStart, quickPosition = false, false, nil, nil
    quickToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            quickDragging, quickMoved, quickStart, quickPosition = true, false, input.Position, quickToggle.Position
        end
    end)
    local quickMoveConnection = UserInputService.InputChanged:Connect(function(input)
        if not quickDragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end
        local delta = input.Position - quickStart
        if delta.Magnitude < 6 and not quickMoved then return end
        quickMoved = true; hoverCard.Visible = false
        local viewport = workspace.CurrentCamera.ViewportSize
        quickToggle.Position = UDim2.fromOffset(math.clamp(quickPosition.X.Offset + delta.X, 0, viewport.X - quickToggle.AbsoluteSize.X), math.clamp(quickPosition.Y.Offset + delta.Y, 0, viewport.Y - quickToggle.AbsoluteSize.Y))
    end)
    local quickEndConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            quickDragging = false
            if quickMoved then task.delay(.15, function() quickMoved = false end) end
        end
    end)
    quickToggle.MouseButton1Click:Connect(function() if quickMoved then quickMoved = false; return end; window:Toggle(); updateHoverCard() end)
    local quickKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then window:Toggle(); updateHoverCard() end
    end)
    gui.Destroying:Connect(function() quickKeyConnection:Disconnect(); quickMoveConnection:Disconnect(); quickEndConnection:Disconnect() end)

    local function selectTab(tab)
        if window.CurrentTab == tab then return end
        local previous = window.CurrentTab
        if previous then
            Tween(previous.Page, {GroupTransparency = 1, Position = UDim2.fromOffset(6, 14)}, .16)
            task.delay(.17, function() if window.CurrentTab ~= previous then previous.Page.Visible = false end end)
            Tween(previous.Button, {BackgroundTransparency = 1})
            Tween(previous.ButtonStroke, {Transparency = 1})
            Tween(previous.Label, {TextColor3 = Theme.TextDark})
            Tween(previous.ButtonScale, {Scale = 1}, .15)
            previous.Bar.Visible = false
        end
        window.CurrentTab = tab
        tab.Page.Position = previous and UDim2.fromOffset(30, 14) or UDim2.fromOffset(18, 14)
        tab.Page.GroupTransparency = previous and 1 or 0
        tab.Page.Visible = true
        if previous then Tween(tab.Page, {Position = UDim2.fromOffset(18, 14), GroupTransparency = 0}, .22) end
        tab.Bar.Visible = true; tab.Bar.Size = UDim2.fromOffset(4, 0); tab.Bar.Position = UDim2.new(0, -6, .5, 0)
        Tween(tab.Button, {BackgroundTransparency = .08, BackgroundColor3 = Theme.AccentDark})
        Tween(tab.ButtonStroke, {Transparency = .7})
        Tween(tab.Label, {TextColor3 = Theme.Text})
        Tween(tab.ButtonScale, {Scale = 1.02}, .16)
        Tween(tab.Bar, {Size = UDim2.fromOffset(4, 28), Position = UDim2.new(0, -6, .5, -14)}, .24)
        pageTitle.Text, pageDesc.Text = tab.Name, tab.Description
        pageTitle.TextTransparency = 0.5; pageDesc.TextTransparency = 0.5
        Tween(pageTitle, {TextTransparency = 0}, .25); Tween(pageDesc, {TextTransparency = 0}, .25)
        search.Text = ""
    end

    function window:AddTab(name, tabOptions)
        tabOptions = type(tabOptions) == "table" and tabOptions or {}
        local button = Create("TextButton", {Parent = tabHolder, BackgroundColor3 = Theme.AccentDark, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(94, 52), Text = "", AutoButtonColor = false})
        Corner(button, 14)
        local buttonStroke = Stroke(button, Theme.Accent, 1)
        local tabLabel = Create("TextLabel", {Parent = button, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamMedium, Text = tostring(name), TextColor3 = Theme.TextDark, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd})
        local buttonScale = Create("UIScale", {Parent = button, Scale = 1})
        local bar = Create("Frame", {Parent = button, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.new(0, -6, .5, -14), Size = UDim2.fromOffset(4, 28), Visible = false})
        Corner(bar, 2)
        local page = Create("CanvasGroup", {Parent = content, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(18, 14), Size = UDim2.new(1, -36, 1, -28), GroupTransparency = 1, Visible = false})
        local frame = Create("ScrollingFrame", {Parent = page, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent})
        local columns = Create("Frame", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local left = Create("Frame", {Parent = columns, BackgroundTransparency = 1, Size = UDim2.new(.5, -7, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        local right = Create("Frame", {Parent = columns, BackgroundTransparency = 1, Position = UDim2.new(.5, 7, 0, 0), Size = UDim2.new(.5, -7, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
        Create("UIListLayout", {Parent = left, Padding = UDim.new(0, 12)}); Create("UIListLayout", {Parent = right, Padding = UDim.new(0, 12)})
        local tab = {Name = name, Description = tabOptions.Description or "Manage your modules and settings", Button = button, ButtonStroke = buttonStroke, ButtonScale = buttonScale, Label = tabLabel, Bar = bar, Page = page, Frame = frame, Controls = {}}
        function tab:AddLeftGroupbox(groupName) return Library:CreateGroupbox(left, groupName, tab) end
        function tab:AddRightGroupbox(groupName) return Library:CreateGroupbox(right, groupName, tab) end
        function tab:AddGroupbox(groupName, side) return Library:CreateGroupbox(side == "Right" and right or left, groupName, tab) end
        button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Tween(buttonScale, {Scale = .98}, .08) end end)
        button.MouseButton1Up:Connect(function() Tween(buttonScale, {Scale = window.CurrentTab == tab and 1.02 or 1}, .16) end)
        button.MouseEnter:Connect(function() if window.CurrentTab ~= tab then Tween(button, {BackgroundTransparency = .65}, .15); Tween(tabLabel, {TextColor3 = Theme.Text}, .15) end end)
        button.MouseLeave:Connect(function() if window.CurrentTab ~= tab then Tween(button, {BackgroundTransparency = 1}, .15); Tween(tabLabel, {TextColor3 = Theme.TextDark}, .15) end end)
        button.MouseButton1Click:Connect(function() if window.CurrentTab ~= tab then selectTab(tab) else Tween(buttonScale, {Scale = 1.04}, .1); task.delay(.1, function() Tween(buttonScale, {Scale = 1.02}, .14) end) end end)
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then selectTab(tab) end
        return tab
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local query = search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        for _, child in ipairs(searchResults:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        if query == "" then searchResults.Visible = false; return end
        local count = 0
        for _, tab in ipairs(window.Tabs) do
            for _, control in ipairs(tab.Controls) do
                if count >= 8 then break end
                if control.Name:lower():find(query, 1, true) or tab.Name:lower():find(query, 1, true) then
                    count += 1
                    local result = Create("TextButton", {Parent = searchResults, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 42), Text = "", AutoButtonColor = false, ZIndex = 81}); Corner(result, 6)
                    Create("TextLabel", {Parent = result, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 17), Font = Theme.Font, Text = control.Name, TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 82})
                    Create("TextLabel", {Parent = result, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 22), Size = UDim2.new(1, -20, 0, 13), Font = Theme.Font, Text = tab.Name .. " › " .. control.Type, TextColor3 = Theme.TextDark, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 82})
                    result.MouseButton1Click:Connect(function()
                        if window.CurrentTab ~= tab then selectTab(tab) end
                        tab.Frame.CanvasPosition = Vector2.new(0, math.max(0, control.Frame.AbsolutePosition.Y - tab.Frame.AbsolutePosition.Y + tab.Frame.CanvasPosition.Y - 12))
                        search.Text = ""; searchResults.Visible = false
                    end)
                end
            end
        end
        searchResults.Size = UDim2.fromOffset(198, math.min(count * 44 + 6, 270))
        searchResults.Visible = count > 0
    end)
    function window:AddBuiltinSettingsTab()
        local settings = self:AddTab("Settings", {Description = "Manage theme and configurations"})
        local menu = settings:AddLeftGroupbox("Menu")
        menu:AddLabel("Toggle UI", {Text = "RCtrl"})
        menu:AddDropdown("Toggle button", "Always", {"Always", "Mobile only", "Hidden"}, false, function(value)
            quickToggle.Visible = value == "Always" or value == "Mobile only" and mobile
        end)
        menu:AddButton("Unload", {Callback = function() Library:Unload() end})
        local themes = settings:AddRightGroupbox("Themes")
        local presets = {Sakura = Color3.fromRGB(255, 153, 204), Violet = Color3.fromRGB(130, 82, 255), Rose = Color3.fromRGB(235, 99, 151), Blue = Color3.fromRGB(91, 163, 255)}
        themes:AddDropdown("Preset", "Violet", {"Sakura", "Violet", "Rose", "Blue"}, false, function(value)
            Library:UpdateTheme("Accent", presets[value])
        end)
        themes:AddColorPicker("Accent color", {Default = Theme.Accent, Callback = function(value) Library:UpdateTheme("Accent", value) end})
        local dim = Create("Frame", {Parent = main, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = .75, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, Active = false, ZIndex = 95})
        themes:AddToggle("Dim", {Default = false, Callback = function(value) dim.Visible = value end})
        themes:AddToggle("Transparent", {Default = false, Callback = function(value) main.BackgroundTransparency = value and .55 or .28 end})
        themes:AddSlider("UI Scale", {Min = 60, Max = 140, Default = 100, Increment = 5, Suffix = "%", Callback = function(value) preferredScale = value / 100; updateResponsive() end})
        themes:AddDropdown("Density", "Default", {"Compact", "Default", "Spacious"}, false, function(value)
            for _, tab in ipairs(window.Tabs) do
                tab.Button.Size = UDim2.fromOffset(108, value == "Compact" and 44 or value == "Spacious" and 58 or 50)
            end
        end)
        themes:AddDropdown("Background", "Dark", {"Dark", "Plum", "Black"}, false, function(value)
            main.BackgroundColor3 = value == "Plum" and Color3.fromRGB(36, 19, 35) or value == "Black" and Color3.fromRGB(4, 4, 7) or Theme.Background
        end)
        themes:AddSlider("Background Opacity", {Min = 0, Max = 100, Default = 72, Increment = 1, Suffix = "%", Callback = function(value) main.BackgroundTransparency = 1 - value / 100 end})
        menu:AddSlider("Toggle size", {Min = 36, Max = 64, Default = 48, Increment = 2, Callback = function(value) quickToggle.Size = UDim2.fromOffset(value, value) end})
        local configs = settings:AddLeftGroupbox("Configs")
        local sharing = settings:AddRightGroupbox("Private Config")
        local configName = configs:AddTextbox("Config Name", {Default = "default", Placeholder = "Config name", NoConfig = true})
        local configList = Library:GetConfigs()
        local selectedConfig = configList[1]
        local configDropdown = configs:AddDropdown("Saved Configs", selectedConfig, configList, false, function(value)
            selectedConfig = value
            if value then configName:SetValue(tostring(value)) end
        end)
        Library.ConfigRegistry["Saved Configs"] = nil
        local stateLabel = sharing:AddLabel("Current State", {Text = Library:GetConfigSummary()})
        local function refreshConfigs(selectName)
            local names = Library:GetConfigs()
            configDropdown:Refresh(names)
            if selectName then selectedConfig = selectName; configDropdown:SetValue(selectName) end
            stateLabel:SetText(Library:GetConfigSummary())
        end
        configs:AddButton("Save Config", {Callback = function() local saved = Library:SaveConfig(configName:GetValue()); refreshConfigs(saved) end})
        configs:AddButton("Load Selected", {Callback = function() Library:LoadConfig(selectedConfig or configName:GetValue()); stateLabel:SetText(Library:GetConfigSummary()) end})
        configs:AddButton("Refresh List", {Callback = function() refreshConfigs(selectedConfig) end})
        configs:AddButton("Reset Config", {Callback = function() Library:SetDefaultConfig(); stateLabel:SetText(Library:GetConfigSummary()) end})
        local privateCode = sharing:AddTextbox("Private Code", {Default = "", Placeholder = "Paste WEX1 code...", Sensor = false, NoConfig = true})
        sharing:AddButton("Export Private Code", {Callback = function()
            local code = Library:ExportConfigCode()
            privateCode:SetValue(code)
            if setclipboard then setclipboard(code) end
            Library:Notify("Private Config", setclipboard and "Copied to clipboard" or "Code placed in textbox", 3)
        end})
        sharing:AddButton("Import Private Code", {Callback = function()
            local ok, reason = Library:ImportConfigCode(privateCode:GetValue())
            if not ok then Library:Notify("Import Error", reason, 4) end
            stateLabel:SetText(Library:GetConfigSummary())
        end})
        sharing:AddButton("Refresh State", {Callback = function() stateLabel:SetText(Library:GetConfigSummary()) end})
        return settings
    end
    Library.Window = window
    main.Visible = false
    if not Library.Loader then window:ShowEntrance() end
    return window
end

function Library:CreateGroupbox(parent, title, tab)
    local group = Create("Frame", {Name = tostring(title) .. "Group", Parent = parent, BackgroundColor3 = Theme.BackgroundDark, BackgroundTransparency = .08, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
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
        Library.ActiveToggles[tostring(name)] = state
        local frame = row(name, "Toggle", 40); Corner(frame, 8)
        frame.BackgroundColor3 = state and Theme.AccentDark or Theme.Surface
        frame.BackgroundTransparency = state and .32 or 0
        local stateStroke = Stroke(frame, state and Theme.Accent or Theme.Outline, state and .45 or 1)
        local toggleLabel = label(frame, options.Text or name, -70); toggleLabel.Size = UDim2.new(1, -70, 0, 40)
        toggleLabel.TextColor3 = state and Theme.Text or Theme.TextDark
        local switch = Create("TextButton", {Parent = frame, BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(54, 53, 66), BorderSizePixel = 0, Position = UDim2.new(1, -49, 0, 10), Size = UDim2.fromOffset(37, 20), Text = "", AutoButtonColor = false, ClipsDescendants = true}); Corner(switch, 10)
        local switchScale = Create("UIScale", {Parent = switch, Scale = 1})
        local knob = Create("Frame", {Parent = switch, BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Position = state and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(14, 14)}); Corner(knob, 7)
        local toggleGlow = Create("Frame", {Parent = switch, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(-16, 0), Size = UDim2.fromOffset(16, 20), ZIndex = 2}); Corner(toggleGlow, 10)
        local extensionArea = Create("Frame", {Parent = frame, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -55, 0, 0), Size = UDim2.new(0, 0, 0, 40), ZIndex = 4})
        local extensionLayout = Create("UIListLayout", {Parent = extensionArea, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6)})
        local toggleHit = Create("TextButton", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 40), Text = "", AutoButtonColor = false, ZIndex = 3})
        extensionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            extensionArea.Size = UDim2.fromOffset(extensionLayout.AbsoluteContentSize.X, 40)
            toggleLabel.Size = UDim2.new(1, -76 - extensionLayout.AbsoluteContentSize.X, 0, 40)
            toggleHit.Size = UDim2.new(1, -61 - extensionLayout.AbsoluteContentSize.X, 0, 40)
        end)
        local object = {}
        function object:SetValue(value)
            state = not not value
            Library.ActiveToggles[tostring(name)] = state
            Tween(frame, {BackgroundColor3 = state and Theme.AccentDark or Theme.Surface, BackgroundTransparency = state and .32 or 0}, .3)
            Tween(stateStroke, {Color = state and Theme.Accent or Theme.Outline, Transparency = state and .45 or 1}, .3)
            Tween(toggleLabel, {TextColor3 = state and Theme.Text or Theme.TextDark}, .25)
            Tween(switch, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(54, 53, 66)}, .3)
            TweenService:Create(knob, TweenInfo.new(.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = state and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3)}):Play()
            toggleGlow.Position = UDim2.fromOffset(-16, 0); toggleGlow.BackgroundTransparency = .72
            local flow = TweenService:Create(toggleGlow, TweenInfo.new(.38, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(37, 0), BackgroundTransparency = 1}); flow:Play()
            Tween(switchScale, {Scale = 1.1}, .1); task.delay(.1, function() if switch.Parent then Tween(switchScale, {Scale = 1}, .2) end end)
            Library:SafeCallback(options.Callback, state)
        end
        function object:GetValue() return state end
        table.insert(Library.ThemeListeners, function(changedKey)
            if changedKey ~= "Accent" or not frame.Parent then return end
            if state then frame.BackgroundColor3 = Theme.AccentDark; switch.BackgroundColor3 = Theme.Accent; stateStroke.Color = Theme.Accent end
        end)
        toggleHit.MouseEnter:Connect(function() Tween(frame, {BackgroundColor3 = Color3.fromRGB(28, 26, 40)}, .16); Tween(toggleLabel, {TextColor3 = Theme.Text}, .16) end)
        toggleHit.MouseLeave:Connect(function() Tween(frame, {BackgroundColor3 = state and Theme.AccentDark or Theme.Surface, BackgroundTransparency = state and .32 or 0}, .16); Tween(toggleLabel, {TextColor3 = state and Theme.Text or Theme.TextDark}, .16) end)
        toggleHit.MouseButton1Click:Connect(function() object:SetValue(not state) end)
        function object:AddKeybind(keybindName, keybindOptions)
            if type(keybindName) == "table" then keybindOptions, keybindName = keybindName, name .. " Keybind" end
            keybindOptions = keybindOptions or {}
            keybindName = keybindName or name .. " Keybind"
            local currentKey = keybindOptions.Default or Enum.KeyCode.Unknown
            local binding = false
            local keyButton = Create("TextButton", {Parent = extensionArea, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Size = UDim2.fromOffset(66, 24), Font = Theme.Font, Text = currentKey == Enum.KeyCode.Unknown and "NONE" or currentKey.Name:upper(), TextColor3 = Theme.TextDark, TextSize = 8, AutoButtonColor = false, ZIndex = 4}); Corner(keyButton, 6); local keyStroke = Stroke(keyButton, Theme.Outline, .25)
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
            pickerOptions._InlineParent = extensionArea
            pickerOptions._ToggleLabel = toggleLabel
            functions:AddColorPicker(pickerName, pickerOptions)
            return object
        end
        function object:AddSlider(sliderName, sliderOptions)
            sliderOptions = sliderOptions or {}
            local minimum, maximum = sliderOptions.Min or 0, sliderOptions.Max or 100
            local sliderValue = math.clamp(sliderOptions.Default or minimum, minimum, maximum)
            frame.Size = UDim2.new(1, 0, 0, 96)
            local divider = Create("Frame", {Parent = frame, BackgroundColor3 = Theme.Outline, BackgroundTransparency = .25, BorderSizePixel = 0, Position = UDim2.fromOffset(10, 40), Size = UDim2.new(1, -20, 0, 1)})
            local sliderLabel = Create("TextLabel", {Parent = frame, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 44), Size = UDim2.new(1, -82, 0, 32), Font = Theme.Font, Text = sliderOptions.Text or sliderName, TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
            local valueBox = Create("TextBox", {Parent = frame, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.new(1, -58, 0, 45), Size = UDim2.fromOffset(47, 25), Font = Theme.Font, TextColor3 = Theme.Accent, TextSize = 10, ClearTextOnFocus = false}); Corner(valueBox, 6); Stroke(valueBox, Theme.Outline, .25)
            AnimateInput(valueBox)
            local sliderBar = Create("Frame", {Parent = frame, BackgroundColor3 = Color3.fromRGB(48, 31, 44), BorderSizePixel = 0, Position = UDim2.fromOffset(12, 80), Size = UDim2.new(1, -24, 0, 5)}); Corner(sliderBar, 3)
            local sliderFill = Create("Frame", {Parent = sliderBar, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)}); Corner(sliderFill, 3)
            local knob = Create("Frame", {Parent = sliderFill, BackgroundColor3 = Theme.Accent, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(12, 12), ZIndex = 3}); Corner(knob, 6)
            local sliderHit = Create("TextButton", {Parent = sliderBar, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, -7), Size = UDim2.new(1, 0, 1, 14), Text = "", ZIndex = 4})
            local dragging, sliderObject = false, {}
            sliderHit.MouseEnter:Connect(function() Tween(knob, {Size = UDim2.fromOffset(14, 14)}, .14) end)
            sliderHit.MouseLeave:Connect(function() if not dragging then Tween(knob, {Size = UDim2.fromOffset(12, 12)}, .14) end end)
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
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false; Tween(knob, {Size = UDim2.fromOffset(12, 12)}, .12) end
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
        local frame = register(Create("TextButton", {Parent = container, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40), Font = Enum.Font.GothamMedium, Text = options.Text or name, TextColor3 = Theme.Text, TextSize = 11, AutoButtonColor = false, ClipsDescendants = true}), name, "Button")
        Corner(frame, 8); Stroke(frame, Theme.Outline, .25)
        local buttonScale = Create("UIScale", {Parent = frame, Scale = 1})
        frame.MouseEnter:Connect(function() Tween(frame, {BackgroundColor3 = Theme.AccentDark}) end)
        frame.MouseLeave:Connect(function() Tween(frame, {BackgroundColor3 = Theme.Surface}) end)
        frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Wave(frame, input) end end)
        frame.MouseButton1Down:Connect(function() Tween(buttonScale, {Scale = .96}, .09); Tween(frame, {BackgroundColor3 = Theme.Accent}, .09); Tween(frame, {TextTransparency = .12}, .08) end)
        frame.MouseButton1Up:Connect(function() Tween(buttonScale, {Scale = 1}, .14); Tween(frame, {BackgroundColor3 = Theme.AccentDark}, .14) end)
        frame.MouseButton1Up:Connect(function() Tween(frame, {TextTransparency = 0}, .16) end)
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
        local arrow = Create("Frame", {Parent = box, BackgroundTransparency = 1, Position = UDim2.new(1, -23, 0, 0), Size = UDim2.fromOffset(20, 31)})
        local leftLine = Create("Frame", {Parent = arrow, BackgroundColor3 = Theme.TextDark, BorderSizePixel = 0, Position = UDim2.fromOffset(4, 14), Size = UDim2.fromOffset(8, 2), Rotation = 45}); Corner(leftLine, 1)
        local rightLine = Create("Frame", {Parent = arrow, BackgroundColor3 = Theme.TextDark, BorderSizePixel = 0, Position = UDim2.fromOffset(9, 14), Size = UDim2.fromOffset(8, 2), Rotation = -45}); Corner(rightLine, 1)
        local list = Create("CanvasGroup", {Parent = frame, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 64), Size = UDim2.new(1, -16, 0, 0), ClipsDescendants = true, Visible = false, GroupTransparency = 1, ZIndex = 10}); Corner(list, 8); Stroke(list, Theme.Outline)
        local listScale = Create("UIScale", {Parent = list, Scale = .97})
        local find = Create("TextBox", {Parent = list, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 28), Font = Theme.Font, PlaceholderText = "Search", PlaceholderColor3 = Theme.TextDark, Text = "", TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 11}); Corner(find, 6); local findStroke = Stroke(find, Theme.Outline, .2); Padding(find, 28, 24, 0, 0)
        Create("ImageLabel", {Parent = find, BackgroundTransparency = 1, Position = UDim2.fromOffset(-19, 7), Size = UDim2.fromOffset(14, 14), Image = "rbxassetid://6031154871", ImageColor3 = Theme.TextDark, ZIndex = 12})
        AnimateInput(find, {Stroke = findStroke, StrokeTransparency = .2})
        local findClear = Create("TextButton", {Parent = find, BackgroundTransparency = 1, Position = UDim2.new(1, -20, .5, -9), Size = UDim2.fromOffset(18, 18), Font = Enum.Font.GothamBold, Text = "×", TextColor3 = Theme.TextDark, TextSize = 13, Visible = false, ZIndex = 13})
        findClear.MouseEnter:Connect(function() Tween(findClear, {TextColor3 = Theme.Text}, .1) end)
        findClear.MouseLeave:Connect(function() Tween(findClear, {TextColor3 = Theme.TextDark}, .1) end)
        -- Add All / Clear All buttons
        local btnRow = Create("Frame", {Parent = list, BackgroundTransparency = 1, Position = UDim2.fromOffset(6, 38), Size = UDim2.new(1, -12, 0, 22), Visible = multi == true, ZIndex = 11})
        local addAllBtn = Create("TextButton", {Parent = btnRow, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(.5, -2, 1, 0), Font = Enum.Font.GothamMedium, Text = "Select all", TextColor3 = Theme.Text, TextSize = 9, AutoButtonColor = false, ZIndex = 12}); Corner(addAllBtn, 5)
        local clearAllBtn = Create("TextButton", {Parent = btnRow, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new(.5, 2, 0, 0), Size = UDim2.new(.5, -2, 1, 0), Font = Enum.Font.GothamMedium, Text = "Clear all", TextColor3 = Theme.Text, TextSize = 9, AutoButtonColor = false, ZIndex = 12}); Corner(clearAllBtn, 5)
        addAllBtn.MouseEnter:Connect(function() Tween(addAllBtn, {BackgroundColor3 = Theme.AccentDark}, .12) end)
        addAllBtn.MouseLeave:Connect(function() Tween(addAllBtn, {BackgroundColor3 = Theme.Surface}, .12) end)
        clearAllBtn.MouseEnter:Connect(function() Tween(clearAllBtn, {BackgroundColor3 = Theme.AccentDark}, .12) end)
        clearAllBtn.MouseLeave:Connect(function() Tween(clearAllBtn, {BackgroundColor3 = Theme.Surface}, .12) end)
        local choices = Create("ScrollingFrame", {Parent = list, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(6, multi and 64 or 38), Size = UDim2.new(1, -12, 1, multi and -70 or -44), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingEnabled = true, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, Active = true, ZIndex = 11})
        Create("UIListLayout", {Parent = choices, Padding = UDim.new(0, 3)})
        local opened, optionButtons = false, {}
        local object, setOpen = {}, nil
        local function display()
            if multi then
                local values = {}; for _, value in ipairs(selected) do table.insert(values, tostring(value)) end
                box.Text = #values > 0 and table.concat(values, ", ") or "Select..."
            else box.Text = selected ~= nil and tostring(selected) or "Select..." end
            box.TextTransparency = 0.4
            Tween(box, {TextTransparency = 0}, .25)
        end
        local function updateFilter()
            local query = find.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
            for _, item in ipairs(optionButtons) do
                local shouldBeVisible = query == "" or item.Text:find(query, 1, true) ~= nil
                if shouldBeVisible and not item.Button.Visible then
                    item.Button.Visible = true
                    item.Button.TextTransparency = 0.4
                    Tween(item.Button, {TextTransparency = 0}, .25)
                else
                    item.Button.Visible = shouldBeVisible
                end
            end
            findClear.Visible = find.Text ~= ""
        end
        findClear.MouseButton1Click:Connect(function()
            find.Text = ""
            find:CaptureFocus()
            updateFilter()
        end)
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
                local button = Create("TextButton", {Parent = choices, BackgroundColor3 = Theme.Accent, BackgroundTransparency = isSelected and .88 or 1, BorderSizePixel = 0, Size = UDim2.new(1, -3, 0, 27), Font = Theme.Font, Text = text, TextColor3 = isSelected and Theme.Accent or Theme.TextDark, TextTransparency = 0.4, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12}); Padding(button, 9)
                Corner(button, 4)
                Tween(button, {TextTransparency = 0}, .25)
                table.insert(optionButtons, {Button = button, Text = text:lower(), Value = value})
                button.MouseEnter:Connect(function() Tween(button, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = .9, TextColor3 = isSelected and Theme.Accent or Theme.Text}) end)
                button.MouseLeave:Connect(function() Tween(button, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = isSelected and .88 or 1, TextColor3 = isSelected and Theme.Accent or Theme.TextDark}) end)
                button.MouseButton1Click:Connect(function()
                    if multi then
                        local found
                        for index, current in ipairs(selected) do if current == value then table.remove(selected, index); found = true; break end end
                        if not found then table.insert(selected, value) end
                    else selected = value; opened = false end
                    display(); Library:SafeCallback(callback, selected)
                    if opened then render() else setOpen(false) end
                end)
            end
            updateFilter()
        end
        -- Add All / Clear All button logic
        addAllBtn.MouseButton1Click:Connect(function()
            if multi then
                local query = find.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
                if query ~= "" then
                    for _, item in ipairs(optionButtons) do
                        if item.Button.Visible then
                            local exists = false
                            for _, v in ipairs(selected) do if v == item.Value then exists = true; break end end
                            if not exists then table.insert(selected, item.Value) end
                        end
                    end
                else
                    selected = {}
                    for _, value in ipairs(options) do table.insert(selected, value) end
                end
            else
                if #options > 0 then selected = options[1] end
            end
            display(); Library:SafeCallback(callback, selected)
            if opened then render() end
        end)
        clearAllBtn.MouseButton1Click:Connect(function()
            if multi then
                local query = find.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
                if query ~= "" then
                    for _, item in ipairs(optionButtons) do
                        if item.Button.Visible then
                            for idx = #selected, 1, -1 do
                                if selected[idx] == item.Value then table.remove(selected, idx) end
                            end
                        end
                    end
                else
                    selected = {}
                end
            else
                selected = nil
            end
            display(); Library:SafeCallback(callback, selected)
            if opened then render() end
        end)
        setOpen = function(value)
            opened = value
            if value then
                render()
                list.Visible = true; list.Size = UDim2.new(1, -16, 0, 0); list.GroupTransparency = 1; listScale.Scale = .97
                Tween(frame, {Size = UDim2.new(1, 0, 0, 250)}, .3)
                Tween(list, {Size = UDim2.new(1, -16, 0, 178), GroupTransparency = 0}, .3)
                Tween(listScale, {Scale = 1}, .3)
                Tween(arrow, {Rotation = 180}, .2); find:CaptureFocus()
            else
                Tween(frame, {Size = UDim2.new(1, 0, 0, 66)}, .24)
                Tween(list, {Size = UDim2.new(1, -16, 0, 0), GroupTransparency = 1}, .2)
                Tween(listScale, {Scale = .97}, .2)
                Tween(arrow, {Rotation = 0}, .2)
                task.delay(.21, function() if not opened then list.Visible = false end end)
            end
        end
        box.MouseButton1Click:Connect(function() setOpen(not opened) end)
        find:GetPropertyChangedSignal("Text"):Connect(updateFilter)
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
        local valueLabel = Create("TextBox", {Parent = frame, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Position = UDim2.new(1, -58, 0, 5), Size = UDim2.fromOffset(47, 25), Font = Theme.Font, TextColor3 = Theme.Accent, TextSize = 10, ClearTextOnFocus = false}); Corner(valueLabel, 6); Stroke(valueLabel, Theme.Outline, .25)
        AnimateInput(valueLabel)
        local bar = Create("Frame", {Parent = frame, BackgroundColor3 = Color3.fromRGB(48, 31, 44), BorderSizePixel = 0, Position = UDim2.fromOffset(12, 40), Size = UDim2.new(1, -24, 0, 5)}); Corner(bar, 3)
        local fill = Create("Frame", {Parent = bar, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0)}); Corner(fill, 3)
        local knob = Create("Frame", {Parent = fill, BackgroundColor3 = Theme.Accent, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(12, 12), ZIndex = 3}); Corner(knob, 6)
        local hit = Create("TextButton", {Parent = bar, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, -7), Size = UDim2.new(1, 0, 1, 14), Text = "", ZIndex = 4})
        local dragging, object = false, {}
        hit.MouseEnter:Connect(function() Tween(knob, {Size = UDim2.fromOffset(14, 14)}, .14) end)
        hit.MouseLeave:Connect(function() if not dragging then Tween(knob, {Size = UDim2.fromOffset(12, 12)}, .14) end end)
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
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false; Tween(knob, {Size = UDim2.fromOffset(12, 12)}, .12) end end)
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
        AnimateInput(lowBox); AnimateInput(highBox)
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
        options = options or {}; local frame = row(name, "Textbox", 40); Corner(frame, 8)
        local titleLabel = label(frame, options.Text or name, -24); titleLabel.Size = UDim2.new(.45, -12, 1, 0); titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        local input = Create("TextBox", {Parent = frame, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(.45, 0, .5, -13), Size = UDim2.new(.55, -9, 0, 26), Font = Theme.Font, Text = options.Default or "", PlaceholderText = options.Placeholder or "Enter text...", PlaceholderColor3 = Theme.TextDark, TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, ClipsDescendants = true, ClearTextOnFocus = false}); Corner(input, 6); Padding(input, 9, 9)
        local inputStroke = Stroke(input, Theme.Outline, .1)
        AnimateInput(input, {Disabled = true, Stroke = inputStroke, StrokeTransparency = .1})
        input.Focused:Connect(function() Tween(input, {BackgroundColor3 = Theme.Surface}, .18) end)
        input.FocusLost:Connect(function() Tween(input, {BackgroundColor3 = Theme.Background}, .18) end)
        local mask
        if options.Sensor or options.sensor then
            input.TextTransparency = 1
            mask = Create("TextLabel", {Parent = input, BackgroundTransparency = 1, Size = UDim2.new(1, -18, 1, 0), Position = UDim2.fromOffset(9, 0), Font = Theme.Font, Text = string.rep("*", #input.Text), TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left})
            input:GetPropertyChangedSignal("Text"):Connect(function() mask.Text = string.rep("*", #input.Text) end)
        end
        if options.Live then input:GetPropertyChangedSignal("Text"):Connect(function() Library:SafeCallback(options.Callback, input.Text) end) else input.FocusLost:Connect(function(enter) Library:SafeCallback(options.Callback, input.Text, enter) end) end
        local object = {SetValue = function(_, value) input.Text = tostring(value) end, GetValue = function() return input.Text end}
        if not options.NoConfig then Library.ConfigRegistry[options.Flag or name] = {Type = "Textbox", Set = function(value) object:SetValue(value) end, Get = function() return input.Text end, Default = options.Default or ""} end
        return chain(object)
    end

    function functions:AddLabel(title, options)
        options = type(options) == "table" and options or {}
        local frame = register(Create("Frame", {Parent = container, BackgroundColor3 = Theme.BackgroundDark, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true}), title, "Label")
        Corner(frame, 8); Stroke(frame, Theme.Outline, .15); Padding(frame, 9, 9, 7, 9)
        Create("UIListLayout", {Parent = frame, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
        local header = Create("Frame", {Parent = frame, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true, LayoutOrder = 1}); Corner(header, 4); Stroke(header, Theme.Outline, .3)
        local accent = Create("Frame", {Parent = header, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 6), Size = UDim2.fromOffset(3, 18)}); Corner(accent, 1)
        local titleLabel = Create("TextLabel", {Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -11, 1, 0), Font = Enum.Font.GothamMedium, Text = tostring(options.Title or title), TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
        Create("Frame", {Parent = frame, BackgroundColor3 = Theme.Outline, BackgroundTransparency = .2, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 2})
        local contentLabel = Create("TextLabel", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = options.Font or Theme.Font, Text = tostring(options.Text or options.Content or ""), TextColor3 = options.TextColor or Theme.Text, TextSize = options.TextSize or 12, TextWrapped = true, RichText = options.RichText or false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 3})
        if contentLabel.Text == "" then contentLabel.Visible = false end
        local object = {}
        function object:SetText(value) contentLabel.Text = tostring(value); contentLabel.Visible = contentLabel.Text ~= "" end
        function object:SetTitle(value) titleLabel.Text = tostring(value) end
        function object:GetText() return contentLabel.Text end
        return chain(object)
    end

    function functions:AddDivider()
        return chain({Instance = Create("Frame", {Parent = container, BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)})})
    end

    function functions:AddColorPicker(name, options)
        options = options or {}; local color = options.Default or Color3.new(1, 1, 1)
        local inline = options._InlineParent ~= nil
        local frame = options._InlineParent or row(name, "ColorPicker", 40)
        if not inline then Corner(frame, 8); label(frame, options.Text or name, -62) end
        local preview = Create("TextButton", {Parent = frame, BackgroundColor3 = color, BorderSizePixel = 0, Position = inline and UDim2.new() or UDim2.new(1, -48, .5, -10), Size = inline and UDim2.fromOffset(28, 16) or UDim2.fromOffset(36, 20), Text = "", ZIndex = inline and 4 or 1}); Corner(preview, 5); Stroke(preview)
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
        AnimateInput(hex)
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
            local button = Create("TextButton", {Parent = frame, BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Position = UDim2.new((index - 1) * .5, index == 2 and 4 or 0, 0, 0), Size = UDim2.new(.5, -4, 1, 0), Font = Theme.Font, Text = data[2].Text or data[1], TextColor3 = Theme.Text, TextSize = 10, ClipsDescendants = true}); Corner(button, 7)
            local scale = Create("UIScale", {Parent = button, Scale = 1})
            button.MouseEnter:Connect(function() Tween(button, {BackgroundColor3 = Theme.AccentDark}, .15) end)
            button.MouseLeave:Connect(function() Tween(button, {BackgroundColor3 = Theme.Surface}, .15); Tween(scale, {Scale = 1}, .12) end)
            button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Wave(button, input) end end)
            button.MouseButton1Down:Connect(function() Tween(scale, {Scale = .95}, .08); Tween(button, {BackgroundColor3 = Theme.Accent, TextTransparency = .12}, .08) end)
            button.MouseButton1Up:Connect(function() Tween(scale, {Scale = 1}, .13); Tween(button, {BackgroundColor3 = Theme.AccentDark}, .13) end)
            button.MouseButton1Up:Connect(function() Tween(button, {TextTransparency = 0}, .15) end)
            button.MouseButton1Click:Connect(function() Library:SafeCallback(data[2].Callback) end)
        end
        return chain({Instance = frame})
    end
    return functions
end

function Library:Unload()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    if self.Loader and self.Loader.Gui then self.Loader.Gui:Destroy() end
    self.Loader = nil
    self.ScreenGui, self.MainFrame, self.Window, self.NotifyContainer = nil, nil, nil, nil
    table.clear(self.ThemeRegistry)
    table.clear(self.ThemeListeners)
    table.clear(self.Popups)
    table.clear(self.ActiveToggles)
end
function Library:BeginLoader(title)
    local parent = GetGuiParent()
    ClearGuiCopies("ProjectARemake", parent)
    ClearGuiCopies("ProjectARemakeLoader", parent)
    local gui = Create("ScreenGui", {Name = "ProjectARemakeLoader", Parent = parent, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10000})
    local root = Create("CanvasGroup", {Parent = gui, BackgroundColor3 = Color3.fromRGB(5, 4, 18), BackgroundTransparency = .08, Size = UDim2.fromScale(1, 1), ZIndex = 10000})
    Create("UIGradient", {Parent = root, Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(12, 46, 90), Color3.fromRGB(5, 4, 18))})
    local card = Create("Frame", {Parent = root, BackgroundColor3 = Color3.fromRGB(11, 13, 32), BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(510, 270), ZIndex = 10001}); Corner(card, 18); Stroke(card, Color3.fromRGB(98, 137, 255), .25)
    local cardScale = Create("UIScale", {Parent = card, Scale = 1})
    local function updateLoaderScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        cardScale.Scale = math.min(1, (viewport.X - 24) / 510, (viewport.Y - 24) / 270)
    end
    updateLoaderScale()
    local camera = workspace.CurrentCamera
    if camera then
        local resizeConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLoaderScale)
        gui.Destroying:Connect(function() resizeConnection:Disconnect() end)
    end
    local art = Create("ImageLabel", {Parent = card, BackgroundColor3 = Color3.fromRGB(46, 64, 116), BorderSizePixel = 0, Size = UDim2.fromOffset(190, 270), Image = self.LoaderImage, ScaleType = Enum.ScaleType.Crop, ZIndex = 10002}); Corner(art, 18)
    Create("UIGradient", {Parent = art, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, .05), NumberSequenceKeypoint.new(1, .35)}), Color = ColorSequence.new(Color3.fromRGB(172, 215, 255), Color3.fromRGB(107, 83, 255))})
    Create("TextLabel", {Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(214, 42), Size = UDim2.fromOffset(270, 24), Font = Enum.Font.GothamBold, Text = title, TextColor3 = Theme.Text, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    Create("TextLabel", {Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(214, 76), Size = UDim2.fromOffset(270, 20), Font = Theme.Font, Text = "DEMON LORD AWAKENS", TextColor3 = Theme.Accent, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    local status = Create("TextLabel", {Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(214, 177), Size = UDim2.fromOffset(210, 20), Font = Theme.Font, Text = "Loading artwork...", TextColor3 = Theme.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002})
    local percent = Create("TextLabel", {Parent = card, BackgroundTransparency = 1, Position = UDim2.fromOffset(435, 177), Size = UDim2.fromOffset(49, 20), Font = Enum.Font.GothamBold, Text = "0%", TextColor3 = Theme.Accent, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10002})
    local track = Create("Frame", {Parent = card, BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Position = UDim2.fromOffset(214, 211), Size = UDim2.fromOffset(270, 9), ZIndex = 10002}); Corner(track, 5); Stroke(track, Theme.AccentDark, .45)
    local fill = Create("Frame", {Parent = track, BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), ZIndex = 10003}); Corner(fill, 5)
    local shine = Create("UIGradient", {Parent = fill, Color = ColorSequence.new(Color3.fromRGB(71, 204, 255), Color3.fromRGB(174, 108, 255)), Offset = Vector2.new(-1, 0)})
    local spark = Create("Frame", {Parent = fill, BackgroundColor3 = Theme.Text, BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(11, 11), ZIndex = 10004}); Corner(spark, 6); Stroke(spark, Theme.Accent, .2)
    fill:GetPropertyChangedSignal("Size"):Connect(function() percent.Text = math.floor(fill.Size.X.Scale * 100 + .5) .. "%" end)
    local loader = {Gui = gui, Root = root, Fill = fill, Status = status, ImageReady = false, UiReady = false, Started = false}
    self.Loader = loader
    local function startProgress()
        if self.Loader ~= loader or not loader.ImageReady or not loader.UiReady or loader.Started then return end
        loader.Started = true
        status.Text = "Opening control panel..."
        Tween(shine, {Offset = Vector2.new(1, 0)}, 1.35)
        local progress = TweenService:Create(fill, TweenInfo.new(1.35, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(1, 1)})
        progress.Completed:Connect(function()
            if self.Loader ~= loader then return end
            percent.Text = "100%"; status.Text = "Ready"
            if self.Window then self.Window:ShowEntrance() end
            Tween(root, {GroupTransparency = 1}, .38)
            task.delay(.4, function() if self.Loader == loader then gui:Destroy(); self.Loader = nil end end)
        end)
        progress:Play()
    end
    loader.TryStart = startProgress
    local function imageReady()
        if self.Loader ~= loader or loader.ImageReady then return end
        loader.ImageReady = true
        status.Text = "Preparing interface..."
        startProgress()
    end
    local imageConnection = art:GetPropertyChangedSignal("IsLoaded"):Connect(function() if art.IsLoaded then imageReady() end end)
    gui.Destroying:Connect(function() imageConnection:Disconnect() end)
    if art.IsLoaded then imageReady() end
    task.spawn(function()
        pcall(function() game:GetService("ContentProvider"):PreloadAsync({art}) end)
        if art.IsLoaded then imageReady() end
    end)
    task.delay(10, function() if self.Loader == loader then imageReady() end end)
end
function Library:FinishLoader()
    local loader = self.Loader
    if not loader then return end
    loader.UiReady = true
    loader.TryStart()
end


return Library

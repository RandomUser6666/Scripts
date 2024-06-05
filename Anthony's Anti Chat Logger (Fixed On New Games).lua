if not game:IsLoaded() then
    game.Loaded:wait()
end

local ACL_LoadTime = tick()
local NotificationTitle = "Anthony's ACL"

local OldCoreTypeSettings = {}
local WhitelistedCoreTypes = {
    "Chat",
    "All",
    Enum.CoreGuiType.Chat,
    Enum.CoreGuiType.All
}

local OldCoreSetting = nil

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Notify = function(_Title, _Text , Time)
    StarterGui:SetCore("SendNotification", {Title = _Title, Text = _Text, Icon = "rbxassetid://2541869220", Duration = Time})
end

local Tween = function(Object, Time, Style, Direction, Property)
    return TweenService:Create(Object, TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction]), Property)
end

local PlayerGui = Player:FindFirstChildWhichIsA("PlayerGui") do
    if not PlayerGui then
        local Timer = tick() + 5
        repeat task.wait() until Player:FindFirstChildWhichIsA("PlayerGui") or (tick() > Timer)
        PlayerGui = Player:FindFirstChildWhichIsA("PlayerGui") or false
        if not PlayerGui then
            return Notify(NotificationTitle, "Failed to find PlayerGui!", 10)
        end
    end
end

if getgenv().AntiChatLogger then
    return Notify(NotificationTitle, "Anti Chat & Screenshot Logger already loaded!", 15)
else
    getgenv().AntiChatLogger = true
end

local Metatable = getrawmetatable(StarterGui)
setreadonly(Metatable, false)

local MessageEvent = Instance.new("BindableEvent")

local function hookOldChatSystem()
    if hookmetamethod then
        local CoreHook do
            CoreHook = hookmetamethod(StarterGui, "__namecall", newcclosure(function(self, ...)
                local Method = getnamecallmethod()
                local Arguments = {...}
                
                if self == StarterGui and not checkcaller() then
                    if Method == "SetCoreGuiEnabled" then
                        local CoreType = Arguments[1]
                        local Enabled = Arguments[2]
                        
                        if table.find(WhitelistedCoreTypes, CoreType) and Enabled == false then
                            OldCoreTypeSettings[CoreType] = Enabled
                            return
                        end
                    elseif Method == "SetCore" then
                        local Core = Arguments[1]
                        local Connection = Arguments[2]
                        
                        if Core == "CoreGuiChatConnections" then
                            OldCoreSetting = Connection
                            return
                        end
                    end
                end
                
                return CoreHook(self, ...)
            end))
        end

        if not getgenv().ChattedFix then
            getgenv().ChattedFix = true

            local ChattedFix do
                ChattedFix = hookmetamethod(Player, "__index", newcclosure(function(self, index)
                    if self == Player and tostring(index):lower():match("chatted") and MessageEvent.Event then
                        return MessageEvent.Event
                    end

                    return ChattedFix(self, index)
                end))
            end

            local AnimateChattedFix = task.spawn(function()
                local ChattedSignal = false

                for _, x in next, getgc() do
                    if type(x) == "function" and getfenv(x).script ~= nil and tostring(getfenv(x).script) == "Animate" then
                        if islclosure(x) then
                            local Constants = getconstants(x)

                            for _, v in next, Constants do
                                if v == "Chatted" then
                                    ChattedSignal = x
                                end
                            end
                        end
                    end
                end

                if ChattedSignal then
                    ChattedSignal()
                end
            end)
        end
    end

    local EnabledChat = task.spawn(function()
        repeat
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            task.wait()
        until StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
    end)
end

local function hookNewChatSystem()
    local ChatConnect = TextChatService.OnIncomingMessage:Connect(function(Message)
        Message.TextChannel = nil
    end)

    local StarterGuiChatConnect = task.spawn(function()
        local Connection

        Connection = TextChatService.OnIncomingMessage:Connect(function(Message)
            if Message.TextChannel == TextChatService.TextChannels.RBXSystem or Message.TextChannel == TextChatService.TextChannels.RBXGeneral then
                Message.TextChannel = nil
                Warning(NotificationTitle, "Chat logger found", 5)
            end
        end)

        task.spawn(function()
            while Connection do
                task.wait(1)
            end
        end)
    end)
end

local function Warning(Title, Content, Duration)
    pcall(function()
        if WarningGuiThread then
            coroutine.close(WarningGuiThread)
        end

        WarningGuiThread = coroutine.create(WarningGuiThread)

        coroutine.resume(WarningGuiThread)
    end)

    Notify(Title, Content, Duration)
end

local WarningGuiThread = task.spawn(function()
    local WarningUI = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local BackgroundHolder = Instance.new("Frame")
    local Background = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local UIGradient = Instance.new("UIGradient")
    local TitleHolder = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Holder = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    local Reason_1 = Instance.new("TextLabel")
    local Reason_2 = Instance.new("TextLabel")
    local Reason_3 = Instance.new("TextLabel")
    local WarningText = Instance.new("TextLabel")
    local Exit = Instance.new("TextButton")
    local ImageLabel = Instance.new("ImageLabel")
    
    WarningUI.Enabled = false
    WarningUI.Name = "WarningUI"
    WarningUI.Parent = CoreGui
    
    Main.Name = "Main"
    Main.Parent = WarningUI
    Main.AnchorPoint = Vector2.new(.5, .5)
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 1
    Main.Position = UDim2.new(.5, 0, .5, 0)
    Main.Size = UDim2.new(0, 400, 0, 400)
    
    BackgroundHolder.Name = "BackgroundHolder"
    BackgroundHolder.Parent = Main
    BackgroundHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    BackgroundHolder.BackgroundTransparency = .25
    BackgroundHolder.BorderSizePixel = 0
    BackgroundHolder.Size = UDim2.new(1, 0, 1, 0)
    
    Background.Name = "Background"
    Background.Parent = BackgroundHolder
    Background.AnchorPoint = Vector2.new(.5, .5)
    Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Background.BorderSizePixel = 0
    Background.Position = UDim2.new(.5, 0, .5, 0)
    Background.Size = UDim2.new(.96, 0, .96, 0)
    
    TopBar.Name = "TopBar"
    TopBar.Parent = Background
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    
    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(53, 149, 146)), ColorSequenceKeypoint.new(.29, Color3.fromRGB(93, 86, 141)), ColorSequenceKeypoint.new(.50, Color3.fromRGB(126, 64, 138)), ColorSequenceKeypoint.new(.75, Color3.fromRGB(143, 112, 112)), ColorSequenceKeypoint.new(1, Color3.fromRGB(159, 159, 80))}
    UIGradient.Parent = TopBar
    
    TitleHolder.Name = "TitleHolder"
    TitleHolder.Parent = Background
    TitleHolder.AnchorPoint = Vector2.new(.5, .5)
    TitleHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleHolder.BorderColor3 = Color3.fromRGB(44, 44, 44)
    TitleHolder.BorderSizePixel = 2
    TitleHolder.Position = UDim2.new(.5, 0, .5, 0)
    TitleHolder.Size = UDim2.new(.9, 0, .9, 0)
    
    Title.Name = "Title"
    Title.Parent = TitleHolder
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, .1, 0)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "Warning!"
    Title.TextColor3 = Color3.fromRGB(235, 235, 235)
    Title.TextScaled = true
    Title.TextWrapped = true
    
    Holder.Name = "Holder"
    Holder.Parent = TitleHolder
    Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Holder.BackgroundTransparency = 1
    Holder.Position = UDim2.new(0, 0, .25, 0)
    Holder.Size = UDim2.new(1, 0, .7, 0)
    
    UIListLayout.Parent = Holder
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    Reason_1.Name = "Reason_1"
    Reason_1.Parent = Holder
    Reason_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Reason_1.BackgroundTransparency = 1
    Reason_1.Size = UDim2.new(1, 0, .3, 0)
    Reason_1.Font = Enum.Font.SourceSans
    Reason_1.Text = "- Chat logger found"
    Reason_1.TextColor3 = Color3.fromRGB(235, 235, 235)
    Reason_1.TextScaled = true
    Reason_1.TextWrapped = true
    Reason_1.TextXAlignment = Enum.TextXAlignment.Left
    
    Reason_2.Name = "Reason_2"
    Reason_2.Parent = Holder
    Reason_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Reason_2.BackgroundTransparency = 1
    Reason_2.Size = UDim2.new(1, 0, .3, 0)
    Reason_2.Font = Enum.Font.SourceSans
    Reason_2.Text = "- Possible screenshot being taken"
    Reason_2.TextColor3 = Color3.fromRGB(235, 235, 235)
    Reason_2.TextScaled = true
    Reason_2.TextWrapped = true
    Reason_2.TextXAlignment = Enum.TextXAlignment.Left
    
    Reason_3.Name = "Reason_3"
    Reason_3.Parent = Holder
    Reason_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Reason_3.BackgroundTransparency = 1
    Reason_3.Size = UDim2.new(1, 0, .3, 0)
    Reason_3.Font = Enum.Font.SourceSans
    Reason_3.Text = "- Protected chat data"
    Reason_3.TextColor3 = Color3.fromRGB(235, 235, 235)
    Reason_3.TextScaled = true
    Reason_3.TextWrapped = true
    Reason_3.TextXAlignment = Enum.TextXAlignment.Left
    
    WarningText.Name = "WarningText"
    WarningText.Parent = TitleHolder
    WarningText.AnchorPoint = Vector2.new(.5, 0)
    WarningText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WarningText.BackgroundTransparency = 1
    WarningText.Position = UDim2.new(.5, 0, 0, 15)
    WarningText.Size = UDim2.new(.8, 0, .125, 0)
    WarningText.Font = Enum.Font.SourceSans
    WarningText.Text = "You have been warned!"
    WarningText.TextColor3 = Color3.fromRGB(235, 235, 235)
    WarningText.TextScaled = true
    WarningText.TextWrapped = true
    
    Exit.Name = "Exit"
    Exit.Parent = TitleHolder
    Exit.AnchorPoint = Vector2.new(.5, 0)
    Exit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Exit.Position = UDim2.new(.5, 0, 1, -35)
    Exit.Size = UDim2.new(.75, 0, .075, 0)
    Exit.Font = Enum.Font.SourceSansBold
    Exit.Text = "Exit"
    Exit.TextColor3 = Color3.fromRGB(20, 20, 20)
    Exit.TextScaled = true
    Exit.TextWrapped = true
    
    ImageLabel.Parent = Background
    ImageLabel.AnchorPoint = Vector2.new(.5, 0)
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Position = UDim2.new(.5, 0, 0, 15)
    ImageLabel.Size = UDim2.new(.125, 0, .125, 0)
    ImageLabel.Image = "rbxassetid://2541869220"
    
    local Enabled = WarningUI.Enabled
    
    local ExitTween = Tween(Exit, .25, "Sine", "InOut", {BackgroundColor3 = Color3.fromRGB(255, 45, 45), TextColor3 = Color3.fromRGB(245, 245, 245)})
    
    WarningUI.Enabled = true

    task.spawn(function()
        local Connection

        Connection = Exit.MouseButton1Click:Connect(function()
            if Enabled then
                Enabled = false
                WarningUI.Enabled = false
                Connection:Disconnect()
            end
        end)
    end)

    Tween(Main, .75, "Sine", "InOut", {BackgroundTransparency = 0}):Play()
    Tween(TitleHolder, .75, "Sine", "InOut", {BackgroundTransparency = 0}):Play()
end)

-- Detect if the game supports the new chat system
if TextChatService and TextChatService.OnIncomingMessage then
    hookNewChatSystem()
else
    hookOldChatSystem()
end

Notify(NotificationTitle, "Anti Chat & Screenshot Logger loaded successfully!", 15)

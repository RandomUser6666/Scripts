local Library = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Constants
Library.Settings = {
    -- UI Size limits
    MinSize = Vector2.new(400, 300),
    MaxSize = Vector2.new(800, 600),
    DefaultSize = UDim2.new(0, 500, 0, 350),

    -- Default theme colors
    DefaultTheme = {
        Primary = Color3.fromRGB(30, 30, 30),    -- Main background
        Secondary = Color3.fromRGB(25, 25, 25),  -- Secondary background
        Accent = Color3.fromRGB(40, 40, 40),     -- Borders and accents
        Text = Color3.fromRGB(255, 255, 255),    -- Primary text
        TextDark = Color3.fromRGB(180, 180, 180) -- Secondary text
    },

    -- Notification colors
    NotificationColors = {
        Message = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(130, 255, 130),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 130, 130)
    },

    -- Animation settings
    TweenInfo = {
        Short = TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        Long = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
    }
}

-- Hide UI
Library.ToggleUI = {
    KeyCode = Enum.KeyCode.RightControl,
    Visible = true
}

function Library:SetUIKeybind(keycode)
    self.ToggleUI.KeyCode = keycode
    _G.UIKeybind = keycode -- Global değişken olarak kaydet
end

-- Utility Functions
local function CreateElement(class, properties)
    local element = Instance.new(class)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

-- Notification System
do
    local NotificationHolder = CreateElement("Frame", {
        Name = "NotificationHolder",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 0, 500),
        Position = UDim2.new(0, 20, 1, -20),
        AnchorPoint = Vector2.new(0, 1),
        Parent = CoreGui
    })

    local ListLayout = CreateElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = NotificationHolder
    })

    function Library:Notify(title, content, notifyType, duration)
        duration = duration or 5
        
        -- Create notification frame
        local notification = CreateElement("Frame", {
            Size = UDim2.new(0, 300, 0, 75),
            BackgroundColor3 = self.Settings.DefaultTheme.Primary,
            BackgroundTransparency = 0.1,
            Position = UDim2.new(-1, 0, 0, 0),
            Parent = NotificationHolder
        })

        -- Add corner radius and stroke
        CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 5),
            Parent = notification
        })

        CreateElement("UIStroke", {
            Thickness = 1.5,
            Color = self.Settings.DefaultTheme.Accent,
            Parent = notification
        })

        -- Get status color
        local statusColor = self.Settings.NotificationColors[notifyType or "Message"]

        -- Create status indicator
        local status = CreateElement("Frame", {
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new(0.01, 0, 0.118, 0),
            BackgroundColor3 = statusColor,
            Parent = notification
        })

        CreateElement("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = status
        })

        -- Create title
        local titleLabel = CreateElement("TextLabel", {
            Size = UDim2.new(0, 244, 0, 17),
            Position = UDim2.new(0.09301, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.Settings.DefaultTheme.Text,
            TextSize = 20,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notification
        })

        -- Create content
        local contentLabel = CreateElement("TextLabel", {
            Size = UDim2.new(0, 282, 0, 43),
            Position = UDim2.new(0.02667, 0, 0.32, 0),
            BackgroundTransparency = 1,
            Text = content,
            TextColor3 = self.Settings.DefaultTheme.Text,
            TextSize = 17,
            Font = Enum.Font.SourceSansMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = notification
        })

        -- Create time bar
        local timeBar = CreateElement("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 1, -4),
            BackgroundColor3 = statusColor,
            Parent = notification
        })

        CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 5),
            Parent = timeBar
        })
        -- Create close button
        local closeButton = CreateElement("TextButton", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0.94667, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = self.Settings.DefaultTheme.Text,
            TextSize = 20,
            Font = Enum.Font.SourceSansBold,
            Parent = notification
        })

        -- Hover effects for close button
        closeButton.MouseEnter:Connect(function()
            TweenService:Create(closeButton, 
                self.Settings.TweenInfo.Short,
                {TextTransparency = 0.4}
            ):Play()
        end)

        closeButton.MouseLeave:Connect(function()
            TweenService:Create(closeButton,
                self.Settings.TweenInfo.Short,
                {TextTransparency = 0}
            ):Play()
        end)

        -- Slide in animation
        TweenService:Create(notification,
            self.Settings.TweenInfo.Medium,
            {Position = UDim2.new(0, 0, 0, 0)}
        ):Play()

        -- Timer system
        local timeLeft = duration
        local timerConnection
        local hovering = false

        -- Pause timer when hovering
        notification.MouseEnter:Connect(function()
            hovering = true
        end)

        notification.MouseLeave:Connect(function()
            hovering = false
        end)

        -- Close notification function
        local function closeNotification()
            if timerConnection then
                timerConnection:Disconnect()
            end

            -- Fade out animations
            local fadeOutTweens = {}
            
            -- Main frame fade
            table.insert(fadeOutTweens, TweenService:Create(notification,
                self.Settings.TweenInfo.Medium,
                {BackgroundTransparency = 1}
            ))

            -- Fade out all elements
            for _, child in pairs(notification:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    table.insert(fadeOutTweens, TweenService:Create(child,
                        self.Settings.TweenInfo.Medium,
                        {TextTransparency = 1}
                    ))
                elseif child:IsA("Frame") then
                    table.insert(fadeOutTweens, TweenService:Create(child,
                        self.Settings.TweenInfo.Medium,
                        {BackgroundTransparency = 1}
                    ))
                elseif child:IsA("UIStroke") then
                    table.insert(fadeOutTweens, TweenService:Create(child,
                        self.Settings.TweenInfo.Medium,
                        {Transparency = 1}
                    ))
                end
            end

            -- Play all tweens
            for _, tween in ipairs(fadeOutTweens) do
                tween:Play()
            end

            -- Wait for tweens to complete
            fadeOutTweens[1].Completed:Wait()
            notification:Destroy()
        end

        -- Close button handler
        closeButton.MouseButton1Click:Connect(closeNotification)

        -- Start timer
        timerConnection = RunService.Heartbeat:Connect(function(delta)
            if not hovering then
                timeLeft = timeLeft - delta
                
                -- Update time bar
                local timeScale = math.clamp(timeLeft / duration, 0, 1)
                TweenService:Create(timeBar,
                    self.Settings.TweenInfo.Short,
                    {Size = UDim2.new(timeScale, 0, 0, 4)}
                ):Play()

                if timeLeft <= 0 then
                    closeNotification()
                end
            end
        end)
    end
end

-- Main UI Creation
function Library:Init(title)
    -- Create main ScreenGui
    local gui = CreateElement("ScreenGui", {
        Name = "FreshUI",
        Parent = CoreGui,
        ResetOnSpawn = false
    })

    -- Create main frame with transparency effect
    local main = CreateElement("Frame", {
        Name = "Main",
        Size = self.Settings.DefaultSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Settings.DefaultTheme.Primary,
        BackgroundTransparency = 0.1, -- Windows-like transparency
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = gui
    })
    UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == (_G.UIKeybind or Library.ToggleUI.KeyCode) then
        Library.ToggleUI.Visible = not Library.ToggleUI.Visible
        
        -- Smooth fade animation
        local tweenInfo = Library.Settings.TweenInfo.Medium
        local transparency = Library.ToggleUI.Visible and 0 or 1
        
        -- Animate main frame
        TweenService:Create(main, tweenInfo, {
            BackgroundTransparency = transparency + 0.1 -- Base transparency
        }):Play()
        
        -- Animate all elements
        for _, element in pairs(main:GetDescendants()) do
            if element:IsA("Frame") then
                TweenService:Create(element, tweenInfo, {
                    BackgroundTransparency = transparency + element.BackgroundTransparency
                }):Play()
            elseif element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                TweenService:Create(element, tweenInfo, {
                    TextTransparency = transparency
                }):Play()
            elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
                TweenService:Create(element, tweenInfo, {
                    ImageTransparency = transparency
                }):Play()
            elseif element:IsA("UIStroke") then
                TweenService:Create(element, tweenInfo, {
                    Transparency = transparency
                }):Play()
            end
        end
    end
end)

    -- Add modern effects
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = main
    })

    CreateElement("UIStroke", {
        Color = self.Settings.DefaultTheme.Accent,
        Thickness = 1.5,
        Parent = main
    })

    -- Create top bar with gradient
    local topBar = CreateElement("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = main
    })

    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = topBar
    })

    -- Add gradient to top bar
    local topBarGradient = CreateElement("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.9),
            NumberSequenceKeypoint.new(1, 0.95)
        }),
        Parent = topBar
    })

    -- Title with modern font and gradient
    local titleLabel = CreateElement("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0.02, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Settings.DefaultTheme.Text,
        TextSize = 18,
        Font = Enum.Font.BuilderSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    -- Add gradient to title
    local titleGradient = CreateElement("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
        }),
        Parent = titleLabel
    })

    -- Modern control buttons
    local controlButtons = CreateElement("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1,
        Parent = topBar
    })

    -- Create control buttons layout
    local controlLayout = CreateElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = controlButtons
    })

    -- Minimize button
    local minBtn = CreateElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundTransparency = 1,
        Text = "−",
        TextColor3 = self.Settings.DefaultTheme.Text,
        TextSize = 20,
        Font = Enum.Font.BuilderSansBold,
        LayoutOrder = 1,
        Parent = controlButtons
    })

    -- Close button
    local closeBtn = CreateElement("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = self.Settings.DefaultTheme.Text,
        TextSize = 20,
        Font = Enum.Font.BuilderSansBold,
        LayoutOrder = 2,
        Parent = controlButtons
    })

    -- Control buttons hover effect
    local function createButtonHoverEffect(button)
        local hoverFrame = CreateElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = self.Settings.DefaultTheme.Accent,
            BackgroundTransparency = 1,
            Parent = button
        })

        CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = hoverFrame
        })

        button.MouseEnter:Connect(function()
            TweenService:Create(hoverFrame, 
                self.Settings.TweenInfo.Short,
                {BackgroundTransparency = 0.9}
            ):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(hoverFrame,
                self.Settings.TweenInfo.Short,
                {BackgroundTransparency = 1}
            ):Play()
        end)
    end

    createButtonHoverEffect(minBtn)
    createButtonHoverEffect(closeBtn)

    -- Create main content container
    local contentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = main
    })

    -- Create tab container
    local tabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
        BackgroundTransparency = 0.2,
        Parent = contentContainer
    })

    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = tabContainer
    })

    -- Create tab scroll
    local tabScroll = CreateElement("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Settings.DefaultTheme.Accent,
        ScrollBarImageTransparency = 0.5,
        Parent = tabContainer
    })

    -- Create tab list layout
    local tabListLayout = CreateElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabScroll
    })

    -- Create tab padding
    CreateElement("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = tabScroll
    })

    -- Create page container
    local pageContainer = CreateElement("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 155, 0, 0),
        BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
        BackgroundTransparency = 0.2,
        Parent = contentContainer
    })

    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = pageContainer
    })

    -- Create page holder
    local pageHolder = CreateElement("Frame", {
        Name = "PageHolder",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Parent = pageContainer
    })

    -- Variables for tab system
    local tabs = {}
    local selectedTab = nil

    -- Function to create new tab
    function Library:CreateTab(name, icon)
        local tab = {
            Name = name,
            Sections = {},
            Elements = {}
        }

        -- Create tab button
        tab.Button = CreateElement("TextButton", {
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = self.Settings.DefaultTheme.Primary,
            BackgroundTransparency = 0.9,
            Text = "",
            AutoButtonColor = false,
            Parent = tabScroll
        })
        -- Create tab button styling
        CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tab.Button
        })

        -- Create tab button content holder
        local tabContent = CreateElement("Frame", {
            Size = UDim2.new(1, -10, 1, -6),
            Position = UDim2.new(0, 5, 0, 3),
            BackgroundTransparency = 1,
            Parent = tab.Button
        })

        -- Create icon if provided
        if icon then
            local iconImage = CreateElement("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 5, 0.5, -10),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = self.Settings.DefaultTheme.Text,
                Parent = tabContent
            })

            -- Add gradient to icon
            CreateElement("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
                }),
                Parent = iconImage
            })
        end

        -- Create tab name label
        local tabName = CreateElement("TextLabel", {
            Size = UDim2.new(1, icon and -35 or -10, 1, 0),
            Position = UDim2.new(0, icon and 30 or 5, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = self.Settings.DefaultTheme.Text,
            TextSize = 14,
            Font = Enum.Font.BuilderSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabContent
        })

        -- Create tab page
        tab.Page = CreateElement("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = self.Settings.DefaultTheme.Accent,
            ScrollBarImageTransparency = 0.5,
            Visible = false,
            Parent = pageHolder
        })

        -- Create page layout
        local pageLayout = CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = tab.Page
        })

        -- Create page padding
        CreateElement("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = tab.Page
        })

        -- Auto-size content
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.Page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Tab selection handler
        local function selectTab()
            if selectedTab == tab then return end

            -- Deselect current tab
            if selectedTab then
                TweenService:Create(selectedTab.Button, self.Settings.TweenInfo.Short, {
                    BackgroundTransparency = 0.9
                }):Play()
                selectedTab.Page.Visible = false
            end

            -- Select new tab
            selectedTab = tab
            TweenService:Create(tab.Button, self.Settings.TweenInfo.Short, {
                BackgroundTransparency = 0.7
            }):Play()
            tab.Page.Visible = true
        end

        -- Tab button handler
        tab.Button.MouseButton1Click:Connect(selectTab)

        -- Select first tab by default
        if not selectedTab then
            selectTab()
        end

        -- Section creation function
        function tab:AddSection(name)
            local section = {}

            -- Create section frame
            section.Frame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                BackgroundTransparency = 0.5,
                Parent = tab.Page
            })

            CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = section.Frame
            })

            -- Create section title
            section.Title = CreateElement("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = self.Settings.DefaultTheme.Text,
                TextSize = 16,
                Font = Enum.Font.BuilderSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section.Frame
            })

            -- Create section content
            section.Content = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = tab.Page
            })

            -- Create content layout
            local contentLayout = CreateElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                Parent = section.Content
            })

            -- Auto-size content
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Content.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
            end)

            -- Element creation functions
            function section:AddButton(text, callback)
                local button = {}

                -- Create button frame
                button.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = button.Frame
                })
                -- Create button click area
                button.ClickArea = CreateElement("TextButton", {
                    Size = UDim2.new(1, -10, 1, -6),
                    Position = UDim2.new(0, 5, 0, 3),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.8,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = button.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = button.ClickArea
                })

                -- Create button text
                button.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = button.ClickArea
                })

                -- Create button icon
                button.Icon = CreateElement("ImageLabel", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7733715400", -- Modern arrow icon
                    ImageColor3 = self.Settings.DefaultTheme.TextDark,
                    Parent = button.ClickArea
                })

                -- Button animations
                local function buttonAnimation()
                    local tweenInfo = self.Settings.TweenInfo.Short
                    
                    -- Click effect
                    TweenService:Create(button.Frame, tweenInfo, {
                        BackgroundTransparency = 0.5
                    }):Play()
                    
                    TweenService:Create(button.ClickArea, tweenInfo, {
                        BackgroundTransparency = 0.6
                    }):Play()
                    
                    wait(tweenInfo.Time)
                    
                    TweenService:Create(button.Frame, tweenInfo, {
                        BackgroundTransparency = 0.7
                    }):Play()
                    
                    TweenService:Create(button.ClickArea, tweenInfo, {
                        BackgroundTransparency = 0.8
                    }):Play()
                end

                -- Button hover effect
                button.ClickArea.MouseEnter:Connect(function()
                    TweenService:Create(button.Frame, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.6
                    }):Play()
                    
                    TweenService:Create(button.Icon, self.Settings.TweenInfo.Short, {
                        ImageColor3 = self.Settings.DefaultTheme.Text
                    }):Play()
                end)

                button.ClickArea.MouseLeave:Connect(function()
                    TweenService:Create(button.Frame, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.7
                    }):Play()
                    
                    TweenService:Create(button.Icon, self.Settings.TweenInfo.Short, {
                        ImageColor3 = self.Settings.DefaultTheme.TextDark
                    }):Play()
                end)

                -- Button click handler
                button.ClickArea.MouseButton1Click:Connect(function()
                    buttonAnimation()
                    if callback then
                        callback()
                    end
                end)

                return button
            end

            function section:AddToggle(text, default, callback)
                local toggle = {}
                toggle.Value = default or false

                -- Create toggle frame
                toggle.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = toggle.Frame
                })

                -- Create toggle text
                toggle.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggle.Frame
                })

                -- Create toggle switch
                toggle.Switch = CreateElement("Frame", {
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.5,
                    Parent = toggle.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggle.Switch
                })

                -- Create toggle indicator
                toggle.Indicator = CreateElement("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = self.Settings.DefaultTheme.Text,
                    Parent = toggle.Switch
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggle.Indicator
                })

                -- Toggle function
                function toggle:Set(value)
                    toggle.Value = value
                    
                    local togglePos = toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    local toggleColor = toggle.Value and Color3.fromRGB(0, 255, 128) or self.Settings.DefaultTheme.Text

                    TweenService:Create(toggle.Indicator, self.Settings.TweenInfo.Short, {
                        Position = togglePos,
                        BackgroundColor3 = toggleColor
                    }):Play()

                    if callback then
                        callback(toggle.Value)
                    end
                end
                -- Toggle click handler
                toggle.Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggle:Set(not toggle.Value)
                    end
                end)

                -- Set default state
                toggle:Set(toggle.Value)

                return toggle
            end

            function section:AddSlider(text, options)
                local slider = {}
                slider.Value = options.default or options.min
                slider.Min = options.min or 0
                slider.Max = options.max or 100
                slider.Decimals = options.decimals or 0

                -- Create slider frame
                slider.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = slider.Frame
                })

                -- Create slider text
                slider.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider.Frame
                })

                -- Create value display
                slider.ValueDisplay = CreateElement("TextBox", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -60, 0, 5),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    Text = tostring(slider.Value),
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 12,
                    Font = Enum.Font.BuilderSansBold,
                    Parent = slider.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = slider.ValueDisplay
                })

                -- Create slider bar
                slider.Bar = CreateElement("Frame", {
                    Size = UDim2.new(1, -20, 0, 4),
                    Position = UDim2.new(0, 10, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    Parent = slider.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = slider.Bar
                })

                -- Create slider fill
                slider.Fill = CreateElement("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = self.Settings.DefaultTheme.Accent,
                    BackgroundTransparency = 0.2,
                    Parent = slider.Bar
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = slider.Fill
                })

                -- Create slider knob
                slider.Knob = CreateElement("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, -6, 0.5, -6),
                    BackgroundColor3 = self.Settings.DefaultTheme.Text,
                    Parent = slider.Fill
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = slider.Knob
                })

                -- Slider functions
                function slider:Set(value)
                    value = math.clamp(value, slider.Min, slider.Max)
                    if slider.Decimals > 0 then
                        value = math.floor(value * (10 ^ slider.Decimals)) / (10 ^ slider.Decimals)
                    else
                        value = math.floor(value)
                    end

                    slider.Value = value
                    slider.ValueDisplay.Text = tostring(value)

                    local percent = (value - slider.Min) / (slider.Max - slider.Min)
                    TweenService:Create(slider.Fill, self.Settings.TweenInfo.Short, {
                        Size = UDim2.new(percent, 0, 1, 0)
                    }):Play()

                    if options.callback then
                        options.callback(value)
                    end
                end

                -- Slider interaction
                local dragging = false

                slider.Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local percent = math.clamp((input.Position.X - slider.Bar.AbsolutePosition.X) / slider.Bar.AbsoluteSize.X, 0, 1)
                        local value = slider.Min + (slider.Max - slider.Min) * percent
                        slider:Set(value)
                    end
                end)

                slider.Bar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - slider.Bar.AbsolutePosition.X) / slider.Bar.AbsoluteSize.X, 0, 1)
                        local value = slider.Min + (slider.Max - slider.Min) * percent
                        slider:Set(value)
                    end
                end)

                -- Value input handling
                slider.ValueDisplay.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        local value = tonumber(slider.ValueDisplay.Text)
                        if value then
                            slider:Set(value)
                        else
                            slider.ValueDisplay.Text = tostring(slider.Value)
                        end
                    else
                        slider.ValueDisplay.Text = tostring(slider.Value)
                    end
                end)

                -- Set default value
                slider:Set(slider.Value)

                return slider
            end

            function section:AddDropdown(text, options)
                local dropdown = {}
                dropdown.Options = options.list or {}
                dropdown.Selected = options.default or dropdown.Options[1]
                dropdown.Open = false

                -- Create dropdown frame
                dropdown.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    ClipsDescendants = true,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdown.Frame
                })
                -- Create dropdown header
                dropdown.Header = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Parent = dropdown.Frame
                })

                -- Create dropdown text
                dropdown.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdown.Header
                })

                -- Create selected value display
                dropdown.Selected = CreateElement("TextLabel", {
                    Size = UDim2.new(0, 200, 1, 0),
                    Position = UDim2.new(1, -210, 0, 0),
                    BackgroundTransparency = 1,
                    Text = dropdown.Selected,
                    TextColor3 = self.Settings.DefaultTheme.TextDark,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = dropdown.Header
                })

                -- Create dropdown arrow
                dropdown.Arrow = CreateElement("ImageLabel", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7734053426",
                    ImageColor3 = self.Settings.DefaultTheme.TextDark,
                    Parent = dropdown.Header
                })

                -- Create dropdown content
                dropdown.Content = CreateElement("Frame", {
                    Size = UDim2.new(1, -10, 0, 0),
                    Position = UDim2.new(0, 5, 0, 40),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.5,
                    Parent = dropdown.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdown.Content
                })

                -- Create scroll frame for options
                dropdown.Scroll = CreateElement("ScrollingFrame", {
                    Size = UDim2.new(1, -10, 1, -10),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = self.Settings.DefaultTheme.TextDark,
                    Parent = dropdown.Content
                })

                -- Create option list layout
                local optionList = CreateElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5),
                    Parent = dropdown.Scroll
                })

                -- Create search bar
                dropdown.SearchBar = CreateElement("TextBox", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    Text = "",
                    PlaceholderText = "Search...",
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    PlaceholderColor3 = self.Settings.DefaultTheme.TextDark,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansMedium,
                    Parent = dropdown.Scroll,
                    LayoutOrder = -1
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdown.SearchBar
                })

                -- Create search icon
                dropdown.SearchIcon = CreateElement("ImageLabel", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0.5, -8),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://7734053426",
                    ImageColor3 = self.Settings.DefaultTheme.TextDark,
                    Parent = dropdown.SearchBar
                })

                -- Dropdown functions
                function dropdown:Refresh(newList)
                    dropdown.Options = newList or dropdown.Options
                    
                    -- Clear existing options
                    for _, child in pairs(dropdown.Scroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    -- Create new options
                    for _, option in pairs(dropdown.Options) do
                        local optionButton = CreateElement("TextButton", {
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                            BackgroundTransparency = 0.8,
                            Text = option,
                            TextColor3 = self.Settings.DefaultTheme.Text,
                            TextSize = 14,
                            Font = Enum.Font.BuilderSansMedium,
                            Parent = dropdown.Scroll
                        })

                        CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 6),
                            Parent = optionButton
                        })

                        -- Option hover effect
                        optionButton.MouseEnter:Connect(function()
                            TweenService:Create(optionButton, self.Settings.TweenInfo.Short, {
                                BackgroundTransparency = 0.6
                            }):Play()
                        end)

                        optionButton.MouseLeave:Connect(function()
                            TweenService:Create(optionButton, self.Settings.TweenInfo.Short, {
                                BackgroundTransparency = 0.8
                            }):Play()
                        end)

                        -- Option selection
                        optionButton.MouseButton1Click:Connect(function()
                            dropdown.Selected.Text = option
                            dropdown:Toggle(false)
                            
                            if options.callback then
                                options.callback(option)
                            end
                        end)
                    end
                end

                -- Search functionality
                dropdown.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
                    local search = dropdown.SearchBar.Text:lower()
                    
                    for _, child in pairs(dropdown.Scroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            if search == "" then
                                child.Visible = true
                            else
                                child.Visible = child.Text:lower():find(search) ~= nil
                            end
                        end
                    end
                end)

                -- Toggle dropdown
                function dropdown:Toggle(state)
                    dropdown.Open = state or not dropdown.Open
                    
                    local size = dropdown.Open and 
                        UDim2.new(1, 0, 0, math.min(35 + 40 + (#dropdown.Options * 35), 200)) or
                        UDim2.new(1, 0, 0, 35)
                    
                    TweenService:Create(dropdown.Frame, self.Settings.TweenInfo.Medium, {
                        Size = size
                    }):Play()
                    
                    TweenService:Create(dropdown.Arrow, self.Settings.TweenInfo.Medium, {
                        Rotation = dropdown.Open and 180 or 0
                    }):Play()
                end

                -- Header click handler
                dropdown.Header.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dropdown:Toggle()
                    end
                end)

                -- Initial refresh
                dropdown:Refresh()

                return dropdown
            end
            function section:AddColorPicker(text, options)
                local colorPicker = {}
                colorPicker.Value = options.default or Color3.fromRGB(255, 255, 255)
                colorPicker.Open = false

                -- Create color picker frame
                colorPicker.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    ClipsDescendants = true,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorPicker.Frame
                })

                -- Create header
                colorPicker.Header = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Parent = colorPicker.Frame
                })

                -- Create text label
                colorPicker.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = colorPicker.Header
                })

                -- Create color display
                colorPicker.Display = CreateElement("Frame", {
                    Size = UDim2.new(0, 30, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    BackgroundColor3 = colorPicker.Value,
                    Parent = colorPicker.Header
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorPicker.Display
                })

                -- Create color picker content
                colorPicker.Content = CreateElement("Frame", {
                    Size = UDim2.new(1, -10, 0, 165),
                    Position = UDim2.new(0, 5, 0, 40),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.5,
                    Visible = false,
                    Parent = colorPicker.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorPicker.Content
                })

                -- Create color space
                colorPicker.ColorSpace = CreateElement("ImageLabel", {
                    Size = UDim2.new(1, -10, 0, 100),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    Image = "rbxassetid://4155801252",
                    Parent = colorPicker.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorPicker.ColorSpace
                })

                -- Create color picker cursor
                colorPicker.Cursor = CreateElement("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = colorPicker.ColorSpace
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = colorPicker.Cursor
                })

                -- Create hue slider
                colorPicker.HueSlider = CreateElement("Frame", {
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 5, 0, 110),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = colorPicker.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = colorPicker.HueSlider
                })

                -- Create hue gradient
                local hueGradient = CreateElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Parent = colorPicker.HueSlider
                })

                -- Create hue slider cursor
                colorPicker.HueCursor = CreateElement("Frame", {
                    Size = UDim2.new(0, 2, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = colorPicker.HueSlider
                })

                -- Create RGB inputs
                colorPicker.RGBInput = CreateElement("Frame", {
                    Size = UDim2.new(1, -10, 0, 25),
                    Position = UDim2.new(0, 5, 0, 135),
                    BackgroundTransparency = 1,
                    Parent = colorPicker.Content
                })

                -- Create RGB layout
                local rgbLayout = CreateElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5),
                    Parent = colorPicker.RGBInput
                })

                -- Create RGB text boxes
                local function createRGBInput(name)
                    local input = CreateElement("TextBox", {
                        Size = UDim2.new(0, 50, 1, 0),
                        BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                        BackgroundTransparency = 0.7,
                        Text = "255",
                        TextColor3 = self.Settings.DefaultTheme.Text,
                        TextSize = 12,
                        Font = Enum.Font.BuilderSansMedium,
                        Parent = colorPicker.RGBInput
                    })

                    CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = input
                    })

                    return input
                end

                colorPicker.R = createRGBInput("R")
                colorPicker.G = createRGBInput("G")
                colorPicker.B = createRGBInput("B")

                -- Color picker functions
                function colorPicker:UpdateColor(noCallback)
                    local color = colorPicker.Value
                    colorPicker.Display.BackgroundColor3 = color
                    
                    if not noCallback and options.callback then
                        options.callback(color)
                    end
                end

                function colorPicker:SetColor(color)
                    colorPicker.Value = color
                    colorPicker:UpdateColor()
                end

                -- Color space interaction
                local picking = false
                colorPicker.ColorSpace.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        picking = true
                    end
                end)

                colorPicker.ColorSpace.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        picking = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if picking and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local bounds = colorPicker.ColorSpace.AbsoluteSize
                        local position = input.Position - colorPicker.ColorSpace.AbsolutePosition
                        local x = math.clamp(position.X / bounds.X, 0, 1)
                        local y = math.clamp(position.Y / bounds.Y, 0, 1)
                        
                        colorPicker.Cursor.Position = UDim2.new(x, 0, y, 0)
                        colorPicker:UpdateColor()
                    end
                end)

                -- Toggle color picker
                function colorPicker:Toggle()
                    colorPicker.Open = not colorPicker.Open
                    colorPicker.Content.Visible = colorPicker.Open
                    
                    local size = colorPicker.Open and UDim2.new(1, 0, 0, 210) or UDim2.new(1, 0, 0, 35)
                    TweenService:Create(colorPicker.Frame, self.Settings.TweenInfo.Medium, {
                        Size = size
                    }):Play()
                end

                -- Header click handler
                colorPicker.Header.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        colorPicker:Toggle()
                    end
                end)

                return colorPicker
            end

            function section:AddKeybind(text, options)
                local keybind = {}
                keybind.Value = options.default
                keybind.Binding = false

                -- Create keybind frame
                keybind.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = keybind.Frame
                })
                -- Create keybind text
                keybind.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -140, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybind.Frame
                })

                -- Create keybind button
                keybind.Button = CreateElement("TextButton", {
                    Size = UDim2.new(0, 120, 0, 24),
                    Position = UDim2.new(1, -130, 0.5, -12),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    Text = keybind.Value and keybind.Value.Name or "None",
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 12,
                    Font = Enum.Font.BuilderSansMedium,
                    Parent = keybind.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybind.Button
                })

                -- Keybind functions
                function keybind:Set(key)
                    keybind.Value = key
                    keybind.Button.Text = key and key.Name or "None"
                    
                    if options.callback then
                        options.callback(key)
                    end
                end

                -- Keybind input handler
                keybind.Button.MouseButton1Click:Connect(function()
                    if keybind.Binding then return end
                    
                    keybind.Binding = true
                    keybind.Button.Text = "..."
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            connection:Disconnect()
                            keybind.Binding = false
                            
                            if input.KeyCode == Enum.KeyCode.Escape then
                                keybind:Set(nil)
                            else
                                keybind:Set(input.KeyCode)
                            end
                        end
                    end)
                end)

                -- Button hover effect
                keybind.Button.MouseEnter:Connect(function()
                    TweenService:Create(keybind.Button, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.5
                    }):Play()
                end)

                keybind.Button.MouseLeave:Connect(function()
                    TweenService:Create(keybind.Button, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.7
                    }):Play()
                end)

                -- Set default keybind
                if options.default then
                    keybind:Set(options.default)
                end

                return keybind
            end

            -- Add modern textbox element
            function section:AddTextbox(text, options)
                local textbox = {}
                textbox.Value = options.default or ""

                -- Create textbox frame
                textbox.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = textbox.Frame
                })

                -- Create textbox label
                textbox.Label = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -160, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textbox.Frame
                })
                -- Create modern textbox input
                textbox.Input = CreateElement("TextBox", {
                    Size = UDim2.new(0, 140, 0, 24),
                    Position = UDim2.new(1, -150, 0.5, -12),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    Text = textbox.Value,
                    PlaceholderText = options.placeholder or "Enter text...",
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    PlaceholderColor3 = self.Settings.DefaultTheme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.BuilderSansMedium,
                    ClearTextOnFocus = options.clearOnFocus ~= false,
                    Parent = textbox.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = textbox.Input
                })

                -- Create underline effect
                textbox.Underline = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = self.Settings.DefaultTheme.Accent,
                    BackgroundTransparency = 0.7,
                    Parent = textbox.Input
                })

                -- Textbox functions
                function textbox:Set(value)
                    textbox.Value = value
                    textbox.Input.Text = value
                    
                    if options.callback then
                        options.callback(value)
                    end
                end

                -- Input focus effects
                textbox.Input.Focused:Connect(function()
                    TweenService:Create(textbox.Input, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.5
                    }):Play()
                    
                    TweenService:Create(textbox.Underline, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 0, 2)
                    }):Play()
                end)

                textbox.Input.FocusLost:Connect(function(enterPressed)
                    TweenService:Create(textbox.Input, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.7
                    }):Play()
                    
                    TweenService:Create(textbox.Underline, self.Settings.TweenInfo.Short, {
                        BackgroundTransparency = 0.7,
                        Size = UDim2.new(1, 0, 0, 1)
                    }):Play()

                    if enterPressed or options.focusLostCallback then
                        textbox:Set(textbox.Input.Text)
                    end
                end)

                -- Set default value
                if options.default then
                    textbox:Set(options.default)
                end

                return textbox
            end

            -- Add modern label element
            function section:AddLabel(text)
                local label = {}

                -- Create label frame
                label.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Parent = section.Content
                })

                -- Create label text
                label.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.TextDark,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansMedium,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = label.Frame
                })

                -- Label functions
                function label:Set(newText)
                    label.Text.Text = newText
                end

                -- Add subtle animation
                local textTransparency = 0.3
                local tweenInfo = self.Settings.TweenInfo.Long

                spawn(function()
                    while label.Frame.Parent do
                        TweenService:Create(label.Text, tweenInfo, {
                            TextTransparency = textTransparency
                        }):Play()
                        
                        wait(tweenInfo.Time)
                        textTransparency = textTransparency == 0.3 and 0 or 0.3
                    end
                end)

                return label
            end

            -- Add modern separator element
            function section:AddSeparator()
                local separator = {}

                -- Create separator frame
                separator.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 10),
                    BackgroundTransparency = 1,
                    Parent = section.Content
                })

                -- Create separator line
                separator.Line = CreateElement("Frame", {
                    Size = UDim2.new(0.9, 0, 0, 1),
                    Position = UDim2.new(0.05, 0, 0.5, 0),
                    BackgroundColor3 = self.Settings.DefaultTheme.TextDark,
                    BackgroundTransparency = 0.7,
                    Parent = separator.Frame
                })

                CreateElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.5, self.Settings.DefaultTheme.Accent),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.5, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Parent = separator.Line
                })

                return separator
            end
            -- Add modern paragraph element for longer text
            function section:AddParagraph(title, content)
                local paragraph = {}

                -- Create paragraph frame
                paragraph.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 0), -- Auto size
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.9,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = paragraph.Frame
                })

                -- Create title
                paragraph.Title = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = title,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 15,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = paragraph.Frame
                })

                -- Create content
                paragraph.Content = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 0),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    Text = content,
                    TextColor3 = self.Settings.DefaultTheme.TextDark,
                    TextSize = 13,
                    Font = Enum.Font.BuilderSansMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    Parent = paragraph.Frame
                })

                -- Auto size handling
                paragraph.Content:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    paragraph.Content.Size = UDim2.new(1, -20, 0, paragraph.Content.TextBounds.Y)
                    paragraph.Frame.Size = UDim2.new(1, 0, 0, paragraph.Content.TextBounds.Y + 35)
                end)

                -- Update function
                function paragraph:Update(newTitle, newContent)
                    paragraph.Title.Text = newTitle
                    paragraph.Content.Text = newContent
                end

                return paragraph
            end

            -- Add modern progress bar element
            function section:AddProgressBar(text, options)
                local progressBar = {}
                progressBar.Value = options.default or 0

                -- Create progress bar frame
                progressBar.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = progressBar.Frame
                })

                -- Create text label
                progressBar.Text = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 14,
                    Font = Enum.Font.BuilderSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = progressBar.Frame
                })

                -- Create progress background
                progressBar.Background = CreateElement("Frame", {
                    Size = UDim2.new(1, -20, 0, 10),
                    Position = UDim2.new(0, 10, 0, 28),
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    Parent = progressBar.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = progressBar.Background
                })

                -- Create progress fill
                progressBar.Fill = CreateElement("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = self.Settings.DefaultTheme.Accent,
                    BackgroundTransparency = 0.2,
                    Parent = progressBar.Background
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = progressBar.Fill
                })

                -- Create gradient effect
                CreateElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
                    }),
                    Rotation = 90,
                    Parent = progressBar.Fill
                })

                -- Progress bar functions
                function progressBar:Set(value)
                    value = math.clamp(value, 0, 100)
                    progressBar.Value = value
                    
                    TweenService:Create(progressBar.Fill, self.Settings.TweenInfo.Medium, {
                        Size = UDim2.new(value/100, 0, 1, 0)
                    }):Play()
                    
                    if options.showPercentage ~= false then
                        progressBar.Text.Text = text .. " - " .. tostring(value) .. "%"
                    end
                    
                    if options.callback then
                        options.callback(value)
                    end
                end

                -- Set default value
                progressBar:Set(progressBar.Value)

                return progressBar
            end
            -- Add modern chip/tag element
            function section:AddChip(text, options)
                local chip = {}
                chip.Selected = options.default or false

                -- Create chip frame
                chip.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = section.Content
                })

                -- Create chip button
                chip.Button = CreateElement("TextButton", {
                    Size = UDim2.new(0, 0, 1, 0), -- Auto size
                    BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                    BackgroundTransparency = 0.7,
                    AutoButtonColor = false,
                    Text = text,
                    TextColor3 = self.Settings.DefaultTheme.Text,
                    TextSize = 13,
                    Font = Enum.Font.BuilderSansMedium,
                    Parent = chip.Frame
                })

                CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = chip.Button
                })

                -- Auto size handling
                chip.Button:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    chip.Button.Size = UDim2.new(0, chip.Button.TextBounds.X + 20, 1, 0)
                end)

                -- Chip functions
                function chip:Set(selected)
                    chip.Selected = selected
                    
                    TweenService:Create(chip.Button, self.Settings.TweenInfo.Short, {
                        BackgroundColor3 = selected and self.Settings.DefaultTheme.Accent or self.Settings.DefaultTheme.Secondary,
                        BackgroundTransparency = selected and 0.5 or 0.7
                    }):Play()
                    
                    if options.callback then
                        options.callback(selected)
                    end
                end

                -- Click handler
                chip.Button.MouseButton1Click:Connect(function()
                    chip:Set(not chip.Selected)
                end)

                -- Set default state
                chip:Set(chip.Selected)

                return chip
            end

            -- Add modern list element
            function section:AddList(text, options)
                local list = {}
                list.Items = options.items or {}
                list.Selected = options.default or list.Items[1]

                -- Create list frame
                list.Frame = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = self.Settings.DefaultTheme.Primary,
                    BackgroundTransparency = 0.7,
                    Parent = section.Content
                })

                CreateElement("UICorner", {

                    CornerRadius = UDim.new(0, 6),
                    Parent = list.Frame
                })

                -- Create scroll frame
                list.Scroll = CreateElement("ScrollingFrame", {
                    Size = UDim2.new(1, -20, 1, -10),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 0,
                    ScrollingDirection = Enum.ScrollingDirection.X,
                    Parent = list.Frame
                })

                -- Create list layout
                CreateElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5),
                    Parent = list.Scroll
                })

                -- List functions
                function list:Refresh(items)
                    list.Items = items or list.Items
                    
                    -- Clear existing items
                    for _, child in pairs(list.Scroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    -- Create new items
                    for _, item in pairs(list.Items) do
                        local itemButton = CreateElement("TextButton", {
                            Size = UDim2.new(0, 0, 1, 0),
                            BackgroundColor3 = self.Settings.DefaultTheme.Secondary,
                            BackgroundTransparency = 0.7,
                            AutoButtonColor = false,
                            Text = item,
                            TextColor3 = self.Settings.DefaultTheme.Text,
                            TextSize = 13,
                            Font = Enum.Font.BuilderSansMedium,
                            Parent = list.Scroll
                        })

                        CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = itemButton
                        })

                        -- Auto size
                        itemButton:GetPropertyChangedSignal("TextBounds"):Connect(function()
                            itemButton.Size = UDim2.new(0, itemButton.TextBounds.X + 20, 1, 0)
                        end)

                        -- Click handler
                        itemButton.MouseButton1Click:Connect(function()
                            list:Select(item)
                        end)

                        -- Update selection
                        if item == list.Selected then
                            TweenService:Create(itemButton, self.Settings.TweenInfo.Short, {
                                BackgroundColor3 = self.Settings.DefaultTheme.Accent,
                                BackgroundTransparency = 0.5
                            }):Play()
                        end
                    end
                end

                function list:Select(item)
                    list.Selected = item
                    list:Refresh()
                    
                    if options.callback then
                        options.callback(item)
                    end
                end

                -- Initial refresh
                list:Refresh()

                return list
            end

            return section
        end

        return tab
    end

    -- Final UI setup
    do
        -- Add window shadow
        local windowShadow = CreateElement("ImageLabel", {
            Size = UDim2.new(1, 47, 1, 47),
            Position = UDim2.new(0, -23, 0, -23),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6015897843",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.6,
            Parent = main
        })

        -- Add window animations
        local openTween = TweenService:Create(main, self.Settings.TweenInfo.Long, {
            Size = self.Settings.DefaultSize,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })

        openTween:Play()
    end

    return gui
end

return Library

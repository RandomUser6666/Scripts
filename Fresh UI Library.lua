local Library = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Constants
Library.Settings = {
	-- UI Size limits
	MinSize = Vector2.new(400, 300),
	MaxSize = Vector2.new(800, 600),
	DefaultSize = UDim2.new(0, 500, 0, 350),

	-- Default theme colors
	DefaultTheme = {
		Primary = Color3.fromRGB(36, 36, 36),    -- Main background
		Secondary = Color3.fromRGB(21, 21, 21),  -- Secondary background
		Accent = Color3.fromRGB(201, 201, 201),  -- Borders and accents
		Text = Color3.fromRGB(255, 255, 255),    -- Primary text
		TextDark = Color3.fromRGB(101, 101, 101) -- Secondary text
	},

	-- Notification colors for different types
	NotificationColors = {
		Message = Color3.fromRGB(180, 180, 180), -- Default/neutral message
		Success = Color3.fromRGB(130, 255, 130), -- Success/completion
		Warning = Color3.fromRGB(255, 200, 80),  -- Warning/caution
		Error = Color3.fromRGB(255, 130, 130)    -- Error/failure
	},

	-- Animation settings
	TweenInfo = {
		Short = TweenInfo.new(0.2, Enum.EasingStyle.Quad),
		Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		Long = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
	}
}

-- Notification System
do
	-- Create notification holder
	local NotificationHolder = Instance.new("Frame")
	NotificationHolder.Name = "NotificationHolder"
	NotificationHolder.BackgroundTransparency = 1
	NotificationHolder.Size = UDim2.new(0, 300, 0, 500)
	NotificationHolder.Position = UDim2.new(0, 20, 1, -20)
	NotificationHolder.AnchorPoint = Vector2.new(0, 1)
	NotificationHolder.Parent = CoreGui

	-- Auto-arrange notifications
	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0, 10)
	ListLayout.Parent = NotificationHolder

	-- Create notification function
	function Library:Notify(title, content, notifyType, duration)
		duration = duration or 5

		-- Create main notification frame
		local notification = Instance.new("Frame")
		notification.Size = UDim2.new(0, 300, 0, 75)
		notification.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		notification.BackgroundTransparency = 0.1
		notification.Position = UDim2.new(-1, 0, 0, 0)
		notification.Parent = NotificationHolder

		-- Add corner radius
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = notification

		-- Add stroke
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.5
		stroke.Color = self.Settings.DefaultTheme.Accent
		stroke.Parent = notification

		-- Get status color
		local statusColor = self.Settings.NotificationColors[notifyType or "Message"]

		-- Create status indicator
		local status = Instance.new("Frame")
		status.Size = UDim2.new(0, 13, 0, 13)
		status.Position = UDim2.new(0.01, 0, 0.118, 0)
		status.BackgroundColor3 = statusColor
		status.Parent = notification

		local statusCorner = Instance.new("UICorner")
		statusCorner.CornerRadius = UDim.new(1, 0)
		statusCorner.Parent = status

		-- Create title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(0, 244, 0, 17)
		titleLabel.Position = UDim2.new(0.09301, 0, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = self.Settings.DefaultTheme.Text
		titleLabel.TextSize = 20
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = notification

		-- Create content
		local contentLabel = Instance.new("TextLabel")
		contentLabel.Size = UDim2.new(0, 282, 0, 43)
		contentLabel.Position = UDim2.new(0.02667, 0, 0.32, 0)
		contentLabel.BackgroundTransparency = 1
		contentLabel.Text = content
		contentLabel.TextColor3 = self.Settings.DefaultTheme.Text
		contentLabel.TextSize = 17
		contentLabel.Font = Enum.Font.GothamMedium
		contentLabel.TextXAlignment = Enum.TextXAlignment.Left
		contentLabel.TextYAlignment = Enum.TextYAlignment.Top
		contentLabel.TextWrapped = true
		contentLabel.Parent = notification

		-- Create time bar
		local timeBar = Instance.new("Frame")
		timeBar.Size = UDim2.new(1, 0, 0, 4)
		timeBar.Position = UDim2.new(0, 0, 1, -4)
		timeBar.BackgroundColor3 = statusColor
		timeBar.Parent = notification

		local timeBarCorner = Instance.new("UICorner")
		timeBarCorner.CornerRadius = UDim.new(0, 5)
		timeBarCorner.Parent = timeBar
		-- Create close button
		local closeButton = Instance.new("TextButton")
		closeButton.Size = UDim2.new(0, 16, 0, 16)
		closeButton.Position = UDim2.new(0.94667, 0, 0, 0)
		closeButton.BackgroundTransparency = 1
		closeButton.Text = "X"
		closeButton.TextColor3 = self.Settings.DefaultTheme.Text
		closeButton.TextSize = 20
		closeButton.Font = Enum.Font.SourceSansSemibold
		closeButton.Parent = notification

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
		local slideIn = TweenService:Create(notification,
			self.Settings.TweenInfo.Medium,
			{Position = UDim2.new(0, 0, 0, 0)}
		)
		slideIn:Play()

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

			-- Fade out animation
			local fadeOut = TweenService:Create(notification,
				self.Settings.TweenInfo.Medium,
				{BackgroundTransparency = 1}
			)

			-- Fade out all children
			for _, child in pairs(notification:GetDescendants()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					TweenService:Create(child,
						self.Settings.TweenInfo.Medium,
						{TextTransparency = 1}
					):Play()
				elseif child:IsA("Frame") then
					TweenService:Create(child,
						self.Settings.TweenInfo.Medium,
						{BackgroundTransparency = 1}
					):Play()
				elseif child:IsA("UIStroke") then
					TweenService:Create(child,
						self.Settings.TweenInfo.Medium,
						{Transparency = 1}
					):Play()
				end
			end

			fadeOut:Play()
			fadeOut.Completed:Wait()
			notification:Destroy()
		end

		-- Close button handler
		closeButton.MouseButton1Click:Connect(closeNotification)

		-- Start timer
		timerConnection = game:GetService("RunService").Heartbeat:Connect(function(delta)
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
	local gui = Instance.new("ScreenGui")
	gui.Name = "FreshUI"
	gui.Parent = CoreGui

	-- Create main frame
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = self.Settings.DefaultSize
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = self.Settings.DefaultTheme.Primary
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = gui

	-- Add corner radius
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 5)
	mainCorner.Parent = main

	-- Add stroke
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = self.Settings.DefaultTheme.Accent
	mainStroke.Parent = main    -- Create top bar
	local topBar = Instance.new("Frame")
	topBar.Name = "Top"
	topBar.Size = UDim2.new(1, 0, 0, 20)
	topBar.BackgroundColor3 = self.Settings.DefaultTheme.Secondary
	topBar.BorderSizePixel = 0
	topBar.Parent = main

	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 5)
	topBarCorner.Parent = topBar

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 100, 1, 0)
	titleLabel.Position = UDim2.new(0.032, 0, -0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = self.Settings.DefaultTheme.Text
	titleLabel.TextSize = 25
	titleLabel.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = topBar

	-- Add gradient to title
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Rotation = 90
	titleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
	}
	titleGradient.Parent = titleLabel

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Destroy"
	closeBtn.Size = UDim2.new(0, 26, 0, 20)
	closeBtn.Position = UDim2.new(0.948, 0, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "X"
	closeBtn.TextColor3 = self.Settings.DefaultTheme.Text
	closeBtn.TextSize = 20
	closeBtn.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Regular)
	closeBtn.Parent = topBar

	-- Minimize button
	local minBtn = Instance.new("TextButton")
	minBtn.Name = "Minimize"
	minBtn.Size = UDim2.new(0, 26, 0, 20)
	minBtn.Position = UDim2.new(0.896, 0, 0, 0)
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "-"
	minBtn.TextColor3 = self.Settings.DefaultTheme.Text
	minBtn.TextSize = 30
	minBtn.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Regular)
	minBtn.Parent = topBar

	-- Top bar line
	local topBarLine = Instance.new("Frame")
	topBarLine.Name = "Bar"
	topBarLine.Size = UDim2.new(1, 0, 0, -1)
	topBarLine.Position = UDim2.new(0, 0, 1, 0)
	topBarLine.BackgroundColor3 = Color3.fromRGB(168, 168, 168)
	topBarLine.BorderSizePixel = 0
	topBarLine.Parent = topBar

	-- Add gradient to line
	local lineGradient = Instance.new("UIGradient")
	lineGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21))
	}
	lineGradient.Parent = topBarLine

	-- Inside frame
	local insideFrame = Instance.new("Frame")
	insideFrame.Name = "InsideFrame"
	insideFrame.Size = UDim2.new(0, 484, 0, 309)
	insideFrame.Position = UDim2.new(0.016, 0, 0.08286, 0)
	insideFrame.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
	insideFrame.BorderSizePixel = 0
	insideFrame.Parent = main

	local insideCorner = Instance.new("UICorner")
	insideCorner.CornerRadius = UDim.new(0, 5)
	insideCorner.Parent = insideFrame

	-- Tab buttons frame
	local tabBtns = Instance.new("Frame")
	tabBtns.Name = "TabBtns"
	tabBtns.Size = UDim2.new(0, 141, 0, 309)
	tabBtns.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
	tabBtns.BorderSizePixel = 0
	tabBtns.ClipsDescendants = true
	tabBtns.Parent = insideFrame

	local tabBtnsCorner = Instance.new("UICorner")
	tabBtnsCorner.CornerRadius = UDim.new(0, 5)
	tabBtnsCorner.Parent = tabBtns

	-- Tab buttons scroll frame
	-- Create top bar
	local topBar = Instance.new("Frame")
	topBar.Name = "Top"
	topBar.Size = UDim2.new(1, 0, 0, 20)
	topBar.BackgroundColor3 = self.Settings.DefaultTheme.Secondary
	topBar.BorderSizePixel = 0
	topBar.Parent = main

	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 5)
	topBarCorner.Parent = topBar

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 100, 1, 0)
	titleLabel.Position = UDim2.new(0.032, 0, -0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = self.Settings.DefaultTheme.Text
	titleLabel.TextSize = 25
	titleLabel.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = topBar

	-- Add gradient to title
	local titleGradient = Instance.new("UIGradient")
	titleGradient.Rotation = 90
	titleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
	}
	titleGradient.Parent = titleLabel

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Destroy"
	closeBtn.Size = UDim2.new(0, 26, 0, 20)
	closeBtn.Position = UDim2.new(0.948, 0, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "X"
	closeBtn.TextColor3 = self.Settings.DefaultTheme.Text
	closeBtn.TextSize = 20
	closeBtn.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Regular)
	closeBtn.Parent = topBar

	-- Minimize button
	local minBtn = Instance.new("TextButton")
	minBtn.Name = "Minimize"
	minBtn.Size = UDim2.new(0, 26, 0, 20)
	minBtn.Position = UDim2.new(0.896, 0, 0, 0)
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "-"
	minBtn.TextColor3 = self.Settings.DefaultTheme.Text
	minBtn.TextSize = 30
	minBtn.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Regular)
	minBtn.Parent = topBar

	-- Top bar line
	local topBarLine = Instance.new("Frame")
	topBarLine.Name = "Bar"
	topBarLine.Size = UDim2.new(1, 0, 0, -1)
	topBarLine.Position = UDim2.new(0, 0, 1, 0)
	topBarLine.BackgroundColor3 = Color3.fromRGB(168, 168, 168)
	topBarLine.BorderSizePixel = 0
	topBarLine.Parent = topBar

	-- Add gradient to line
	local lineGradient = Instance.new("UIGradient")
	lineGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21))
	}
	lineGradient.Parent = topBarLine

	-- Inside frame
	local insideFrame = Instance.new("Frame")
	insideFrame.Name = "InsideFrame"
	insideFrame.Size = UDim2.new(0, 484, 0, 309)
	insideFrame.Position = UDim2.new(0.016, 0, 0.08286, 0)
	insideFrame.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
	insideFrame.BorderSizePixel = 0
	insideFrame.Parent = main

	local insideCorner = Instance.new("UICorner")
	insideCorner.CornerRadius = UDim.new(0, 5)
	insideCorner.Parent = insideFrame

	-- Tab buttons frame
	local tabBtns = Instance.new("Frame")
	tabBtns.Name = "TabBtns"
	tabBtns.Size = UDim2.new(0, 141, 0, 309)
	tabBtns.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
	tabBtns.BorderSizePixel = 0
	tabBtns.ClipsDescendants = true
	tabBtns.Parent = insideFrame

	local tabBtnsCorner = Instance.new("UICorner")
	tabBtnsCorner.CornerRadius = UDim.new(0, 5)
	tabBtnsCorner.Parent = tabBtns

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Size = UDim2.new(0, 139, 0, 309)
	tabScroll.BackgroundTransparency = 1
	tabScroll.ScrollBarThickness = 2
	tabScroll.ScrollBarImageColor3 = Color3.fromRGB(241, 241, 241)
	tabScroll.Parent = tabBtns    -- Add padding to tab scroll
	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 3)
	tabPadding.Parent = tabScroll

	-- Add UIStroke to tab buttons frame
	local tabStroke = Instance.new("UIStroke")
	tabStroke.Transparency = 0.65
	tabStroke.Thickness = 2
	tabStroke.Parent = tabBtns

	-- Page holder
	local pageHolder = Instance.new("Frame")
	pageHolder.Name = "PageHolder"
	pageHolder.Size = UDim2.new(0, 325, 0, 298)
	pageHolder.Position = UDim2.new(0.31818, 0, 0.01942, 0)
	pageHolder.BackgroundColor3 = self.Settings.DefaultTheme.Secondary
	pageHolder.BorderSizePixel = 0
	pageHolder.Parent = insideFrame

	local pageHolderCorner = Instance.new("UICorner")
	pageHolderCorner.CornerRadius = UDim.new(0, 5)
	pageHolderCorner.Parent = pageHolder

	local pageHolderStroke = Instance.new("UIStroke")
	pageHolderStroke.Transparency = 0.5
	pageHolderStroke.Thickness = 3
	pageHolderStroke.Color = Color3.fromRGB(11, 11, 11)
	pageHolderStroke.Parent = pageHolder

	-- Button hover effect function
	local function createButtonHoverEffect(button)
		local tweenInfo = self.Settings.TweenInfo.Short

		button.MouseEnter:Connect(function()
			if button ~= self.SelectedButton then
				TweenService:Create(button, tweenInfo, {
					TextTransparency = 0.4
				}):Play()
			end
		end)

		button.MouseLeave:Connect(function()
			if button ~= self.SelectedButton then
				TweenService:Create(button, tweenInfo, {
					TextTransparency = 0
				}):Play()
			end
		end)
	end

	-- Create page function
	function Library:CreatePage(name)
		-- Create tab button
		local tabButton = Instance.new("TextButton")
		tabButton.Size = UDim2.new(0, 141, 0, 40)
		tabButton.BackgroundTransparency = 1
		tabButton.Text = name
		tabButton.TextColor3 = self.Settings.DefaultTheme.Text
		tabButton.TextSize = 20
		tabButton.Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		tabButton.Parent = tabScroll

		-- Create page
		local page = Instance.new("Frame")
		page.Name = name.."Page"
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.Parent = pageHolder

		-- Create scroll frame for page
		local pageScroll = Instance.new("ScrollingFrame")
		pageScroll.Size = UDim2.new(1, 0, 1, 0)
		pageScroll.BackgroundTransparency = 1
		pageScroll.ScrollBarThickness = 2
		pageScroll.ScrollBarImageColor3 = Color3.fromRGB(241, 241, 241)
		pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		pageScroll.Parent = page

		-- Add list layout to page scroll
		local pageList = Instance.new("UIListLayout")
		pageList.Padding = UDim.new(0, 5)
		pageList.Parent = pageScroll

		-- Add padding to page scroll
		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop = UDim.new(0, 5)
		pagePadding.PaddingLeft = UDim.new(0, 5)
		pagePadding.PaddingRight = UDim.new(0, 5)
		pagePadding.Parent = pageScroll

		-- Button click handler
		tabButton.MouseButton1Click:Connect(function()
			-- Hide all pages
			for _, v in pairs(pageHolder:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end

			-- Show selected page
			page.Visible = true

			-- Reset all buttons
			for _, v in pairs(tabScroll:GetChildren()) do
				if v:IsA("TextButton") then
					TweenService:Create(v, self.Settings.TweenInfo.Short, {
						TextTransparency = 0.4
					}):Play()
				end
			end

			-- Highlight selected button
			TweenService:Create(tabButton, self.Settings.TweenInfo.Short, {
				TextTransparency = 0
			}):Play()

			self.SelectedButton = tabButton
		end)

		-- Add hover effect
		createButtonHoverEffect(tabButton)

		-- Select first page by default
		if not self.SelectedButton then
			self.SelectedButton = tabButton
			page.Visible = true
		end

		return page
	end
	-- Create section function
	function Library:CreateSection(page, title)
		-- Create section holder
		local sectionHolder = Instance.new("Frame")
		sectionHolder.Name = "BarHolder"
		sectionHolder.Size = UDim2.new(0, 305, 0, 3)
		sectionHolder.BackgroundTransparency = 1
		sectionHolder.Parent = page

		-- Create left bar
		local leftBar = Instance.new("Frame")
		leftBar.Name = "Bar1"
		leftBar.Size = UDim2.new(0, 90, 0, 2)
		leftBar.Position = UDim2.new(0.00328, 0, -0.33333, 0)
		leftBar.BackgroundColor3 = Color3.fromRGB(171, 171, 171)
		leftBar.BorderSizePixel = 0
		leftBar.Parent = sectionHolder

		local leftBarCorner = Instance.new("UICorner")
		leftBarCorner.CornerRadius = UDim.new(0, 100)
		leftBarCorner.Parent = leftBar

		-- Create right bar
		local rightBar = Instance.new("Frame")
		rightBar.Name = "Bar2"
		rightBar.Size = UDim2.new(0, 90, 0, 2)
		rightBar.Position = UDim2.new(0.70492, 0, -0.33333, 0)
		rightBar.BackgroundColor3 = Color3.fromRGB(171, 171, 171)
		rightBar.BorderSizePixel = 0
		rightBar.Parent = sectionHolder

		local rightBarCorner = Instance.new("UICorner")
		rightBarCorner.CornerRadius = UDim.new(0, 100)
		rightBarCorner.Parent = rightBar

		-- Create section text
		local sectionText = Instance.new("TextLabel")
		sectionText.Name = "BarText"
		sectionText.Size = UDim2.new(0, 103, 0, 3)
		sectionText.Position = UDim2.new(0.33115, 0, -0.33333, 0)
		sectionText.BackgroundTransparency = 1
		sectionText.Text = title
		sectionText.TextColor3 = self.Settings.DefaultTheme.Text
		sectionText.TextSize = 20
		sectionText.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		sectionText.Parent = sectionHolder

		-- Add gradient to text
		local textGradient = Instance.new("UIGradient")
		textGradient.Rotation = 90
		textGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		textGradient.Parent = sectionText

		return sectionHolder
	end

	-- Create button function
	function Library:CreateButton(parent, text, callback)
		local buttonFrame = Instance.new("Frame")
		buttonFrame.Size = UDim2.new(0, 305, 0, 45)
		buttonFrame.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		buttonFrame.BorderSizePixel = 0
		buttonFrame.Parent = parent

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 5)
		buttonCorner.Parent = buttonFrame

		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.Thickness = 1.5
		buttonStroke.Color = self.Settings.DefaultTheme.Accent
		buttonStroke.Parent = buttonFrame

		local clickableButton = Instance.new("TextButton")
		clickableButton.Name = "ClickableButton"
		clickableButton.Size = UDim2.new(0, 287, 0, 30)
		clickableButton.Position = UDim2.new(0.02951, 0, 0.15222, 0)
		clickableButton.BackgroundTransparency = 0.9
		clickableButton.Text = ""
		clickableButton.Parent = buttonFrame

		local buttonCorner2 = Instance.new("UICorner")
		buttonCorner2.CornerRadius = UDim.new(0, 3)
		buttonCorner2.Parent = clickableButton

		local buttonStroke2 = Instance.new("UIStroke")
		buttonStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		buttonStroke2.Thickness = 1.5
		buttonStroke2.Color = self.Settings.DefaultTheme.Accent
		buttonStroke2.Parent = clickableButton

		local buttonText = Instance.new("TextLabel")
		buttonText.Size = UDim2.new(0, 247, 0, 29)
		buttonText.Position = UDim2.new(0.03103, 0, 0.03333, 0)
		buttonText.BackgroundTransparency = 1
		buttonText.Text = text
		buttonText.TextColor3 = self.Settings.DefaultTheme.Text
		buttonText.TextSize = 20
		buttonText.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		buttonText.TextXAlignment = Enum.TextXAlignment.Left
		buttonText.Parent = clickableButton
		-- Add gradient to button text
		local buttonTextGradient = Instance.new("UIGradient")
		buttonTextGradient.Rotation = 90
		buttonTextGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		buttonTextGradient.Parent = buttonText

		-- Add icon (optional)
		local buttonIcon = Instance.new("ImageLabel")
		buttonIcon.Size = UDim2.new(0, 30, 0, 29)
		buttonIcon.Position = UDim2.new(0.89199, 0, 0.03333, 0)
		buttonIcon.BackgroundTransparency = 1
		buttonIcon.Image = "rbxassetid://12333784627"
		buttonIcon.Parent = clickableButton

		-- Button hover effect
		createButtonHoverEffect(clickableButton)

		-- Button click handler
		clickableButton.MouseButton1Click:Connect(function()
			if callback then
				callback()
			end
		end)

		return buttonFrame
	end

	-- Create toggle function
	function Library:CreateToggle(parent, text, default, callback)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 305, 0, 45)
		toggleFrame.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = parent

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 5)
		toggleCorner.Parent = toggleFrame

		local toggleStroke = Instance.new("UIStroke")
		toggleStroke.Thickness = 1.5
		toggleStroke.Color = self.Settings.DefaultTheme.Accent
		toggleStroke.Parent = toggleFrame

		local toggleText = Instance.new("TextLabel")
		toggleText.Size = UDim2.new(0, 223, 0, 29)
		toggleText.Position = UDim2.new(0.03738, 0, 0.17444, 0)
		toggleText.BackgroundTransparency = 1
		toggleText.Text = text
		toggleText.TextColor3 = self.Settings.DefaultTheme.Text
		toggleText.TextSize = 20
		toggleText.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		toggleText.TextXAlignment = Enum.TextXAlignment.Left
		toggleText.Parent = toggleFrame

		-- Add gradient to toggle text
		local toggleTextGradient = Instance.new("UIGradient")
		toggleTextGradient.Rotation = 90
		toggleTextGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		toggleTextGradient.Parent = toggleText

		-- Create toggle button
		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 60, 0, 30)
		toggleButton.Position = UDim2.new(0.77049, 0, 0.15222, 0)
		toggleButton.BackgroundTransparency = 0.9
		toggleButton.Text = ""
		toggleButton.Parent = toggleFrame

		local toggleButtonCorner = Instance.new("UICorner")
		toggleButtonCorner.CornerRadius = UDim.new(0, 3)
		toggleButtonCorner.Parent = toggleButton

		local toggleButtonStroke = Instance.new("UIStroke")
		toggleButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		toggleButtonStroke.Thickness = 1.5
		toggleButtonStroke.Color = self.Settings.DefaultTheme.Accent
		toggleButtonStroke.Parent = toggleButton

		-- Create toggle indicator
		local toggleIndicator = Instance.new("Frame")
		toggleIndicator.Size = UDim2.new(0, 30, 0, 30)
		toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 101, 101)
		toggleIndicator.BorderSizePixel = 0
		toggleIndicator.Name = "ToggleBtnFrame"
		toggleIndicator.Parent = toggleButton

		local toggleIndicatorCorner = Instance.new("UICorner")
		toggleIndicatorCorner.CornerRadius = UDim.new(0, 3)
		toggleIndicatorCorner.Parent = toggleIndicator

		-- Toggle state
		local enabled = default or false
		local tweenInfo = self.Settings.TweenInfo.Short
		-- Update toggle state
		local function updateToggle()
			local targetColor = enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 101, 101)
			local targetPosition = enabled and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)

			TweenService:Create(toggleIndicator, tweenInfo, {
				BackgroundColor3 = targetColor,
				Position = targetPosition
			}):Play()

			if callback then
				callback(enabled)
			end
		end

		-- Toggle click handler
		toggleButton.MouseButton1Click:Connect(function()
			enabled = not enabled
			updateToggle()
		end)

		-- Set initial state
		updateToggle()

		return toggleFrame
	end

	-- Create slider function
	function Library:CreateSlider(parent, text, min, max, default, callback)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(0, 305, 0, 45)
		sliderFrame.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		sliderFrame.BorderSizePixel = 0
		sliderFrame.Parent = parent

		local sliderCorner = Instance.new("UICorner")
		sliderCorner.CornerRadius = UDim.new(0, 5)
		sliderCorner.Parent = sliderFrame

		local sliderStroke = Instance.new("UIStroke")
		sliderStroke.Thickness = 1.5
		sliderStroke.Color = self.Settings.DefaultTheme.Accent
		sliderStroke.Parent = sliderFrame

		local sliderTitle = Instance.new("TextLabel")
		sliderTitle.Size = UDim2.new(0, 294, 0, 10)
		sliderTitle.Position = UDim2.new(0.02426, 0, 0.02222, 0)
		sliderTitle.BackgroundTransparency = 1
		sliderTitle.Text = text
		sliderTitle.TextColor3 = self.Settings.DefaultTheme.Text
		sliderTitle.TextSize = 20
		sliderTitle.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
		sliderTitle.Parent = sliderFrame

		-- Add gradient to slider title
		local titleGradient = Instance.new("UIGradient")
		titleGradient.Rotation = 90
		titleGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		titleGradient.Parent = sliderTitle

		-- Create slider button
		local slider = Instance.new("TextButton")
		slider.Size = UDim2.new(0, 231, 0, 26)
		slider.Position = UDim2.new(0.01639, 0, 0.33, 0)
		slider.BackgroundTransparency = 1
		slider.Text = ""
		slider.Parent = sliderFrame

		local sliderButtonCorner = Instance.new("UICorner")
		sliderButtonCorner.CornerRadius = UDim.new(0, 3)
		sliderButtonCorner.Parent = slider

		local sliderButtonStroke = Instance.new("UIStroke")
		sliderButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		sliderButtonStroke.Thickness = 1.5
		sliderButtonStroke.Color = self.Settings.DefaultTheme.Accent
		sliderButtonStroke.Parent = slider

		-- Create value text
		local valueText = Instance.new("TextLabel")
		valueText.Size = UDim2.new(0, 294, 0, 10)
		valueText.Position = UDim2.new(0.01746, 0, 0.29145, 0)
		valueText.BackgroundTransparency = 1
		valueText.Text = tostring(default or min)
		valueText.TextColor3 = self.Settings.DefaultTheme.Text
		valueText.TextSize = 20
		valueText.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		valueText.TextXAlignment = Enum.TextXAlignment.Left
		valueText.Parent = slider

		-- Add gradient to value text
		local valueGradient = Instance.new("UIGradient")
		valueGradient.Rotation = 90
		valueGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		valueGradient.Parent = valueText
		-- Create slider fill
		local sliderFill = Instance.new("CanvasGroup")
		sliderFill.Size = UDim2.new(0, 0, 0, 26)
		sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderFill.GroupColor3 = self.Settings.DefaultTheme.Accent
		sliderFill.Parent = slider

		local sliderFillCorner = Instance.new("UICorner")
		sliderFillCorner.CornerRadius = UDim.new(0, 3)
		sliderFillCorner.Parent = sliderFill

		-- Create value input
		local valueInput = Instance.new("TextBox")
		valueInput.Size = UDim2.new(0, 45, 0, 24)
		valueInput.Position = UDim2.new(0.81861, 0, 0.33448, 0)
		valueInput.BackgroundTransparency = 0.9
		valueInput.Text = ""
		valueInput.PlaceholderText = "Input"
		valueInput.TextColor3 = self.Settings.DefaultTheme.Text
		valueInput.Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		valueInput.Parent = sliderFrame

		local valueInputCorner = Instance.new("UICorner")
		valueInputCorner.CornerRadius = UDim.new(0, 3)
		valueInputCorner.Parent = valueInput

		local valueInputStroke = Instance.new("UIStroke")
		valueInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		valueInputStroke.Thickness = 1.5
		valueInputStroke.Color = self.Settings.DefaultTheme.Accent
		valueInputStroke.Parent = valueInput

		-- Slider variables
		local dragging = false
		local value = default or min
		local maxWidth = slider.AbsoluteSize.X

		-- Update slider function
		local function updateSlider(input)
			local relativeX = input - slider.AbsolutePosition.X
			local tweenInfo = self.Settings.TweenInfo.Short
			local percentage = math.clamp(relativeX / maxWidth, 0, 1)
			value = math.floor(min + (max - min) * percentage)
			

			-- Update value text and input
			valueText.Text = tostring(value)
			valueInput.Text = tostring(value)

			-- Update slider fill
			local targetWidth = percentage * maxWidth
			TweenService:Create(sliderFill, tweenInfo, {
				Size = UDim2.new(0, targetWidth, 0, 26)
			}):Play()

			-- Check if value text is covered by fill
			if targetWidth >= valueText.AbsolutePosition.X - slider.AbsolutePosition.X then
				TweenService:Create(valueText, tweenInfo, {
					TextColor3 = self.Settings.DefaultTheme.Primary
				}):Play()
			else
				TweenService:Create(valueText, tweenInfo, {
					TextColor3 = self.Settings.DefaultTheme.Text
				}):Play()
			end

			if callback then
				callback(value)
			end
		end

		-- Slider input handlers
		slider.MouseButton1Down:Connect(function()
			dragging = true
			updateSlider(UserInputService:GetMouseLocation().X)
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSlider(UserInputService:GetMouseLocation().X)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		-- Value input handler
		valueInput.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local inputValue = tonumber(valueInput.Text)
				if inputValue then
					value = math.clamp(inputValue, min, max)
					local percentage = (value - min) / (max - min)
					updateSlider(slider.AbsolutePosition.X + (percentage * maxWidth))
				end
			end
			valueInput.Text = tostring(value)
		end)

		-- Set initial value
		updateSlider(slider.AbsolutePosition.X + ((value - min) / (max - min) * maxWidth))

		return sliderFrame
	end
	-- Create dropdown function
	function Library:CreateDropdown(parent, text, options, callback)
		local dropdownFrame = Instance.new("Frame")
		dropdownFrame.Size = UDim2.new(0, 305, 0, 45)
		dropdownFrame.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		dropdownFrame.BorderSizePixel = 0
		dropdownFrame.Parent = parent

		local dropdownCorner = Instance.new("UICorner")
		dropdownCorner.CornerRadius = UDim.new(0, 5)
		dropdownCorner.Parent = dropdownFrame

		local dropdownStroke = Instance.new("UIStroke")
		dropdownStroke.Thickness = 1.5
		dropdownStroke.Color = self.Settings.DefaultTheme.Accent
		dropdownStroke.Parent = dropdownFrame

		local dropdownText = Instance.new("TextLabel")
		dropdownText.Size = UDim2.new(0, 172, 0, 10)
		dropdownText.Position = UDim2.new(0.0341, 0, 0.35556, 0)
		dropdownText.BackgroundTransparency = 1
		dropdownText.Text = text
		dropdownText.TextColor3 = self.Settings.DefaultTheme.Text
		dropdownText.TextSize = 20
		dropdownText.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		dropdownText.TextXAlignment = Enum.TextXAlignment.Left
		dropdownText.Parent = dropdownFrame

		-- Add gradient to dropdown text
		local textGradient = Instance.new("UIGradient")
		textGradient.Rotation = 90
		textGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		textGradient.Parent = dropdownText

		-- Create dropdown button
		local dropdownButton = Instance.new("TextButton")
		dropdownButton.Size = UDim2.new(0, 100, 0, 28)
		dropdownButton.Position = UDim2.new(0.63738, 0, 0.19667, 0)
		dropdownButton.BackgroundTransparency = 0.9
		dropdownButton.Text = "Select"
		dropdownButton.TextColor3 = self.Settings.DefaultTheme.Text
		dropdownButton.TextSize = 14
		dropdownButton.Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		dropdownButton.Parent = dropdownFrame

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 3)
		buttonCorner.Parent = dropdownButton

		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		buttonStroke.Thickness = 1.5
		buttonStroke.Color = self.Settings.DefaultTheme.Accent
		buttonStroke.Parent = dropdownButton

		-- Create dropdown list frame
		local dropdownList = Instance.new("Frame")
		dropdownList.Size = UDim2.new(0, 100, 0, 28)
		dropdownList.Position = UDim2.new(0.63738, 0, 0.19667, 0)
		dropdownList.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		dropdownList.BorderSizePixel = 0
		dropdownList.ClipsDescendants = true
		dropdownList.Parent = dropdownFrame

		local listCorner = Instance.new("UICorner")
		listCorner.CornerRadius = UDim.new(0, 5)
		listCorner.Parent = dropdownList

		local listStroke = Instance.new("UIStroke")
		listStroke.Thickness = 1.5
		listStroke.Color = self.Settings.DefaultTheme.Accent
		listStroke.Parent = dropdownList

		-- Create scroll frame for options
		local optionScroll = Instance.new("ScrollingFrame")
		optionScroll.Size = UDim2.new(1, 0, 0, 127)
		optionScroll.Position = UDim2.new(0, 0, 0.1859, 0)
		optionScroll.BackgroundTransparency = 1
		optionScroll.ScrollBarThickness = 2
		optionScroll.ScrollBarImageColor3 = Color3.fromRGB(241, 241, 241)
		optionScroll.Parent = dropdownList

		-- Add list layout
		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 5)
		listLayout.Parent = optionScroll

		-- Variables
		local isOpen = false
		local selected = "None"

		-- Toggle dropdown function
		local function toggleDropdown()
			isOpen = not isOpen
			local targetSize = isOpen and UDim2.new(0, 100, 0, 156) or UDim2.new(0, 100, 0, 28)
			local tweenInfo = self.Settings.TweenInfo.Short

			TweenService:Create(dropdownList, tweenInfo, {
				Size = targetSize
			}):Play()
		end
		-- Create option buttons
		for _, option in pairs(options) do
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(0, 100, 0, 30)
			optionButton.BackgroundTransparency = 1
			optionButton.Text = option
			optionButton.TextColor3 = self.Settings.DefaultTheme.Text
			optionButton.TextSize = 14
			optionButton.Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
			optionButton.Parent = optionScroll

			-- Option button click handler
			optionButton.MouseButton1Click:Connect(function()
				selected = option
				dropdownButton.Text = option
				toggleDropdown()

				if callback then
					callback(option)
				end
			end)

			-- Add hover effect
			createButtonHoverEffect(optionButton)
		end

		-- Dropdown button click handler
		dropdownButton.MouseButton1Click:Connect(toggleDropdown)

		return dropdownFrame
	end

	-- Create keybind function
	function Library:CreateKeybind(parent, text, default, callback)
		local keybindFrame = Instance.new("Frame")
		keybindFrame.Size = UDim2.new(0, 305, 0, 45)
		keybindFrame.BackgroundColor3 = self.Settings.DefaultTheme.Primary
		keybindFrame.BorderSizePixel = 0
		keybindFrame.Parent = parent

		local frameCorner = Instance.new("UICorner")
		frameCorner.CornerRadius = UDim.new(0, 5)
		frameCorner.Parent = keybindFrame

		local frameStroke = Instance.new("UIStroke")
		frameStroke.Thickness = 1.5
		frameStroke.Color = self.Settings.DefaultTheme.Accent
		frameStroke.Parent = keybindFrame

		local keybindText = Instance.new("TextLabel")
		keybindText.Size = UDim2.new(0, 244, 0, 10)
		keybindText.Position = UDim2.new(0.0341, 0, 0.35556, 0)
		keybindText.BackgroundTransparency = 1
		keybindText.Text = text
		keybindText.TextColor3 = self.Settings.DefaultTheme.Text
		keybindText.TextSize = 20
		keybindText.Font = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.ExtraBold)
		keybindText.TextXAlignment = Enum.TextXAlignment.Left
		keybindText.Parent = keybindFrame

		-- Add gradient to keybind text
		local textGradient = Instance.new("UIGradient")
		textGradient.Rotation = 90
		textGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 101, 101))
		}
		textGradient.Parent = keybindText

		-- Create keybind button
		local keybindButton = Instance.new("TextButton")
		keybindButton.Size = UDim2.new(0, 40, 0, 26)
		keybindButton.Position = UDim2.new(0.83607, 0, 0.19667, 0)
		keybindButton.BackgroundTransparency = 0.9
		keybindButton.Text = default and default.Name or "..."
		keybindButton.TextColor3 = self.Settings.DefaultTheme.Text
		keybindButton.TextSize = 14
		keybindButton.Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		keybindButton.Parent = keybindFrame

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 3)
		buttonCorner.Parent = keybindButton

		local buttonStroke = Instance.new("UIStroke")
		buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		buttonStroke.Thickness = 1.5
		buttonStroke.Color = self.Settings.DefaultTheme.Accent
		buttonStroke.Parent = keybindButton

		-- Variables
		local currentKey = default
		local isBinding = false

		-- Update keybind display
		local function updateKeybind()
			keybindButton.Text = currentKey and currentKey.Name or "..."

			if callback then
				callback(currentKey)
			end
		end
		-- Keybind input handler
		keybindButton.MouseButton1Click:Connect(function()
			if isBinding then return end

			isBinding = true
			keybindButton.Text = "..."

			local connection
			connection = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = input.KeyCode
					isBinding = false
					updateKeybind()
					connection:Disconnect()
				end
			end)
		end)

		-- Add hover effect
		createButtonHoverEffect(keybindButton)

		-- Set initial keybind
		updateKeybind()

		return keybindFrame
	end

	-- Aero/Fluent design effects
	do
		-- Add window blur effect
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 10
		blurEffect.Parent = game:GetService("Lighting")

		-- Create hover glow effect for UIStrokes
		local function createStrokeGlowEffect(frame)
			local originalColor = frame.UIStroke.Color
			local tweenInfo = self.Settings.TweenInfo.Short

			frame.MouseEnter:Connect(function()
				TweenService:Create(frame.UIStroke, tweenInfo, {
					Color = Color3.new(1, 1, 1)
				}):Play()
			end)

			frame.MouseLeave:Connect(function()
				TweenService:Create(frame.UIStroke, tweenInfo, {
					Color = originalColor
				}):Play()
			end)
		end

		-- Apply glow effect to all frames with UIStroke
		for _, v in pairs(main:GetDescendants()) do
			if v:IsA("Frame") and v:FindFirstChild("UIStroke") then
				createStrokeGlowEffect(v)
			end
		end
	end

	-- Dragging system
	do
		local dragging = false
		local dragInput
		local dragStart
		local startPos

		local function updateDrag(input)
			local delta = input.Position - dragStart
			local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)

			TweenService:Create(main, TweenInfo.new(0.1), {
				Position = targetPos
			}):Play()
		end

		topBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
			end
		end)

		topBar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				updateDrag(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	-- Resize system
	do
		local resizing = false
		local resizeType = nil
		local startSize
		local startPos
		local mouseStart

		-- Mouse cursors for different resize areas
		local cursors = {
			TopLeft = "rbxasset://SystemCursors/SizeNWSE",
			TopRight = "rbxasset://SystemCursors/SizeNESW",
			BottomLeft = "rbxasset://SystemCursors/SizeNESW",
			BottomRight = "rbxasset://SystemCursors/SizeNWSE",
			Top = "rbxasset://SystemCursors/SizeNS",
			Bottom = "rbxasset://SystemCursors/SizeNS",
			Left = "rbxasset://SystemCursors/SizeEW",
			Right = "rbxasset://SystemCursors/SizeEW"
		}
		-- Create resize handles
		local function createResizeHandle(name, size, position)
			local handle = Instance.new("Frame")
			handle.Name = name
			handle.Size = size
			handle.Position = position
			handle.BackgroundTransparency = 1
			handle.Parent = main

			handle.MouseEnter:Connect(function()
				UserInputService.MouseIcon = cursors[name]
			end)

			handle.MouseLeave:Connect(function()
				if not resizing then
					UserInputService.MouseIcon = ""
				end
			end)

			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					resizing = true
					resizeType = name
					startSize = main.Size
					startPos = main.Position
					mouseStart = UserInputService:GetMouseLocation()
				end
			end)
		end

		-- Create all resize handles
		createResizeHandle("TopLeft", UDim2.new(0, 10, 0, 10), UDim2.new(0, -5, 0, -5))
		createResizeHandle("TopRight", UDim2.new(0, 10, 0, 10), UDim2.new(1, -5, 0, -5))
		createResizeHandle("BottomLeft", UDim2.new(0, 10, 0, 10), UDim2.new(0, -5, 1, -5))
		createResizeHandle("BottomRight", UDim2.new(0, 10, 0, 10), UDim2.new(1, -5, 1, -5))
		createResizeHandle("Top", UDim2.new(1, -20, 0, 10), UDim2.new(0, 10, 0, -5))
		createResizeHandle("Bottom", UDim2.new(1, -20, 0, 10), UDim2.new(0, 10, 1, -5))
		createResizeHandle("Left", UDim2.new(0, 10, 1, -20), UDim2.new(0, -5, 0, 10))
		createResizeHandle("Right", UDim2.new(0, 10, 1, -20), UDim2.new(1, -5, 0, 10))

		-- Handle resize
		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
				local delta = UserInputService:GetMouseLocation() - mouseStart
				local newSize = startSize
				local newPos = startPos

				-- Calculate new size and position based on resize type
				if resizeType:find("Left") then
					newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset - delta.X, newSize.Y.Scale, newSize.Y.Offset)
					newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, newPos.Y.Scale, newPos.Y.Offset)
				elseif resizeType:find("Right") then
					newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset + delta.X, newSize.Y.Scale, newSize.Y.Offset)
				end

				if resizeType:find("Top") then
					newSize = UDim2.new(newSize.X.Scale, newSize.X.Offset, startSize.Y.Scale, startSize.Y.Offset - delta.Y)
					newPos = UDim2.new(newPos.X.Scale, newPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				elseif resizeType:find("Bottom") then
					newSize = UDim2.new(newSize.X.Scale, newSize.X.Offset, startSize.Y.Scale, startSize.Y.Offset + delta.Y)
				end

				-- Apply size limits
				local minSize = self.Settings.MinSize
				local maxSize = self.Settings.MaxSize
				newSize = UDim2.new(
					newSize.X.Scale,
					math.clamp(newSize.X.Offset, minSize.X, maxSize.X),
					newSize.Y.Scale,
					math.clamp(newSize.Y.Offset, minSize.Y, maxSize.Y)
				)

				-- Update UI
				main.Size = newSize
				main.Position = newPos
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
				UserInputService.MouseIcon = ""
			end
		end)
	end

	-- Minimize button handler
	minBtn.MouseButton1Click:Connect(function()
		local minimized = main.Size.Y.Offset <= topBar.Size.Y.Offset + 5

		local targetSize = minimized and 
			self.Settings.DefaultSize or 
			UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, topBar.Size.Y.Offset)

		TweenService:Create(main, self.Settings.TweenInfo.Medium, {
			Size = targetSize
		}):Play()
	end)

	-- Close button handler
	closeBtn.MouseButton1Click:Connect(function()
		-- Fade out animation
		local fadeOut = TweenService:Create(main, self.Settings.TweenInfo.Medium, {
			BackgroundTransparency = 1
		})

		-- Fade out all elements
		for _, v in pairs(main:GetDescendants()) do
			if v:IsA("TextLabel") or v:IsA("TextButton") then
				TweenService:Create(v, self.Settings.TweenInfo.Medium, {
					TextTransparency = 1
				}):Play()
			elseif v:IsA("Frame") or v:IsA("ScrollingFrame") then
				TweenService:Create(v, self.Settings.TweenInfo.Medium, {
					BackgroundTransparency = 1
				}):Play()
			elseif v:IsA("UIStroke") then
				TweenService:Create(v, self.Settings.TweenInfo.Medium, {
					Transparency = 1
				}):Play()
			end
		end

		fadeOut:Play()
		fadeOut.Completed:Wait()
		gui:Destroy()
	end)

	return gui
end

return Library

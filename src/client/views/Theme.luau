--[[
	Theme
	Location: src/client/views/Theme.luau
	Design tokens for Project Genesis UI.
--]]

local Theme = {
	Colors = {
		-- Base theme colors
		Primary = Color3.fromRGB(120, 80, 220),         -- Indigo/Violet
		PrimaryHover = Color3.fromRGB(140, 100, 240),
		PrimaryDisabled = Color3.fromRGB(80, 60, 130),
		
		Accent = Color3.fromRGB(240, 180, 30),          -- Neon Amber/Gold
		AccentHover = Color3.fromRGB(255, 200, 50),
		
		Background = Color3.fromRGB(20, 20, 25),        -- Frosted Obsidian base
		PanelBackground = Color3.fromRGB(30, 30, 35),
		FrostedGlass = Color3.fromRGB(40, 40, 50),
		
		White = Color3.fromRGB(255, 255, 255),
		Muted = Color3.fromRGB(150, 150, 150),
		DarkText = Color3.fromRGB(10, 10, 15),

		-- Rarity colors
		Common = Color3.fromRGB(140, 140, 140),
		Rare = Color3.fromRGB(0, 160, 255),
		Legendary = Color3.fromRGB(255, 170, 0),
		
		-- Alert/Status colors
		Success = Color3.fromRGB(40, 190, 100),
		SuccessHover = Color3.fromRGB(60, 210, 120),
		Error = Color3.fromRGB(220, 60, 60),
		ErrorHover = Color3.fromRGB(240, 80, 80),
		Warning = Color3.fromRGB(240, 160, 20),
		
		-- Interactive/Outline colors
		SelectionOutline = Color3.fromRGB(0, 255, 120),  -- Glowing neon outline
		Border = Color3.fromRGB(60, 60, 70),
		BorderTransparent = Color3.fromRGB(200, 200, 200), -- Semi-transparent stroke
	},
	
	Fonts = {
		Regular = Enum.Font.Gotham,
		Bold = Enum.Font.GothamBold,
		Header = Enum.Font.GothamBold,
	},
	
	CornerRadius = UDim.new(0, 8),
	CornerRadiusLarge = UDim.new(0, 12),
	
	StrokeThickness = 1,
	StrokeThicknessSelected = 2,
	
	AnimationDuration = 0.25,
	
	ZIndex = {
		Default = 1,
		Overlay = 10,
		Modal = 100,
		Toast = 1000,
	}
}

return Theme

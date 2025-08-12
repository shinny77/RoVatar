-- @ScriptType: ModuleScript
local skinColors = {
	[1] = "255, 224, 189",  -- Fair skin (Peach)
	[2] = "255, 219, 172",  -- Light skin (Warm Ivory)
	[3] = "250, 210, 161",  -- Fair with warm undertone
	[4] = "245, 205, 156",  -- Beige
	[5] = "240, 194, 136",  -- Light tan
	[6] = "225, 184, 132",  -- Golden tan
	[7] = "216, 175, 127",  -- Medium tan
	[8] = "202, 157, 106",  -- Caramel
	[9] = "190, 140, 95",   -- Warm honey
	[10] = "179, 125, 81",  -- Deep tan
	[11] = "166, 111, 74",  -- Light brown
	[12] = "153, 97, 64",   -- Medium brown
	[13] = "140, 85, 56",   -- Deep brown
	[14] = "128, 72, 49",   -- Chocolate brown
	[15] = "116, 63, 42",   -- Dark caramel
	[16] = "105, 55, 36",   -- Deep cocoa
	[17] = "94, 48, 30",    -- Warm espresso
	[18] = "83, 42, 26",    -- Dark espresso
	[19] = "73, 37, 23",    -- Ebony
	[20] = "63, 32, 20"     -- Deep ebony
}

return function(Constants)
	return {
		Skin_01 = {
			Id = "Skin_01",
			Name = "Fair Skin",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 1,
			Color = skinColors[1],
		},
		Skin_02 = {
			Id = "Skin_02",
			Name = "Light Skin",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 2,
			Color = skinColors[2],
		},
		Skin_03 = {
			Id = "Skin_03",
			Name = "Fair with Warm Undertone",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 3,
			Color = skinColors[3],
		},
		Skin_04 = {
			Id = "Skin_04",
			Name = "Beige",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 4,
			Color = skinColors[4],
		},
		Skin_05 = {
			Id = "Skin_05",
			Name = "Light Tan",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 5,
			Color = skinColors[5],
		},
		Skin_06 = {
			Id = "Skin_06",
			Name = "Golden Tan",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 6,
			Color = skinColors[6],
		},
		Skin_07 = {
			Id = "Skin_07",
			Name = "Medium Tan",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 7,
			Color = skinColors[7],
		},
		Skin_08 = {
			Id = "Skin_08",
			Name = "Caramel",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 8,
			Color = skinColors[8],
		},
		Skin_09 = {
			Id = "Skin_09",
			Name = "Warm Honey",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 9,
			Color = skinColors[9],
		},
		Skin_10 = {
			Id = "Skin_10",
			Name = "Deep Tan",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 10,
			Color = skinColors[10],
		},
		Skin_11 = {
			Id = "Skin_11",
			Name = "Light Brown",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 11,
			Color = skinColors[11],
		},
		Skin_12 = {
			Id = "Skin_12",
			Name = "Medium Brown",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 12,
			Color = skinColors[12],
		},
		Skin_13 = {
			Id = "Skin_13",
			Name = "Deep Brown",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 13,
			Color = skinColors[13],
		},
		Skin_14 = {
			Id = "Skin_14",
			Name = "Chocolate Brown",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 14,
			Color = skinColors[14],
		},
		Skin_15 = {
			Id = "Skin_15",
			Name = "Dark Caramel",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 15,
			Color = skinColors[15],
		},
		Skin_16 = {
			Id = "Skin_16",
			Name = "Deep Cocoa",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 16,
			Color = skinColors[16],
		},
		Skin_17 = {
			Id = "Skin_17",
			Name = "Warm Espresso",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 17,
			Color = skinColors[17],
		},
		Skin_18 = {
			Id = "Skin_18",
			Name = "Dark Espresso",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 18,
			Color = skinColors[18],
		},
		Skin_19 = {
			Id = "Skin_19",
			Name = "Ebony",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 19,
			Color = skinColors[19],
		},
		Skin_20 = {
			Id = "Skin_20",
			Name = "Deep Ebony",
			Image = "rbxassetid://94402570023845",
			CurrencyType = Constants.CurrencyTypes.Free,
			InventoryType = Constants.InventoryType.Styling,
			ItemType = Constants.ItemType.Skin,
			LayoutOrder = 20,
			Color = skinColors[20],
		},
	}
end

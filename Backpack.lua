local addOnName = ...
assert(LibContainer, 'LibContainer dependency missing.')
LibContainer:SetDatabase(addOnName .. 'DB')

local LE_ITEM_QUALITY_UNCOMMON = LE_ITEM_QUALITY_UNCOMMON or Enum.ItemQuality.ItemQualityGood or 2
local LE_ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON or 2
local LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR or 4
local LE_ITEM_CLASS_GEM = LE_ITEM_CLASS_GEM or 3
local LE_ITEM_SUBCLASS_RELIC = 11

local ICONS = [[Interface\AddOns\Backpack\assets\icons.tga]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

local function onAutoVendorClick(self)
	if(LibContainer:GetVariable('autoSellJunk')) then
		self:GetNormalTexture():SetVertexColor(1, 0.1, 0.1)
	else
		self:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
	end
end

local function onAutoDepositClick(self)
	if(LibContainer:GetVariable('autoDeposit')) then
		self:GetNormalTexture():SetVertexColor(0, 0.6, 1)
	else
		self:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.3)
	end
end

local function updateSlot(Slot)
	SetItemButtonTexture(Slot, Slot:GetItemTexture())
	SetItemButtonCount(Slot, Slot:GetItemCount())
	SetItemButtonDesaturated(Slot, Slot:IsItemLocked())

	local itemQuality = Slot:GetItemQuality()
	local itemQualityColor = Slot:GetItemQualityColor()
	local itemClass = Slot:GetItemClass()
	if(itemQuality >= LE_ITEM_QUALITY_UNCOMMON and (itemClass == LE_ITEM_CLASS_WEAPON or itemClass == LE_ITEM_CLASS_ARMOR or (itemClass == LE_ITEM_CLASS_GEM and Slot:GetItemSubClass() == LE_ITEM_SUBCLASS_RELIC))) then
		local ItemLevel = Slot.ItemLevel
		ItemLevel:SetText(Slot:GetItemLevel())
		ItemLevel:SetTextColor(itemQualityColor:GetRGB())
		ItemLevel:Show()
	else
		Slot.ItemLevel:Hide()
	end

	if(Slot:GetItemQuestID() or Slot:IsItemQuestItem()) then
		Slot:SetBackdropBorderColor(1, 1, 0)
	elseif(itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
		Slot:SetBackdropBorderColor(itemQualityColor:GetRGB())
	else
		Slot:SetBackdropBorderColor(0, 0, 0)
	end
end

local function clearSlot(Slot)
	if(Slot:IsItemEmpty()) then
		local Icon = Slot.Icon
		Icon:SetTexture(nil)
		Icon:SetDesaturated(false)

		Slot.Count:SetText('')
		Slot.ItemLevel:Hide()
		Slot:SetBackdropBorderColor(0, 0, 0)
	end
end

local function styleSlot(Slot)
	Slot:SetSize(32, 32)
	Slot:SetBackdrop(BACKDROP)
	Slot:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	Slot:SetBackdropBorderColor(0, 0, 0)
	Slot:Show()
	Slot.Update = updateSlot
	Slot:On('PostUpdateVisibility', clearSlot)

	local Icon = Slot.Icon
	Icon:ClearAllPoints()
	Icon:SetPoint('TOPLEFT', 1, -1)
	Icon:SetPoint('BOTTOMRIGHT', -1, 1)
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local Count = Slot.Count
	Count:ClearAllPoints()
	Count:SetPoint('BOTTOMRIGHT', 0, 2)
	Count:SetFontObject('PixelFontNormal')
	Count:Show()

	local ItemLevel = Slot:CreateFontString('$parentItemLevel', 'ARTWORK', 'PixelFontNormal')
	ItemLevel:SetPoint('BOTTOM', 2, 2)
	ItemLevel:SetJustifyH('CENTER')
	Slot.ItemLevel = ItemLevel

	local Pushed = Slot.PushedTexture
	Pushed:ClearAllPoints()
	Pushed:SetPoint('TOPLEFT', 1, -1)
	Pushed:SetPoint('BOTTOMRIGHT', -1, 1)
	Pushed:SetColorTexture(1, 1, 1, 0.3)

	local Highlight = Slot.HighlightTexture
	Highlight:ClearAllPoints()
	Highlight:SetPoint('TOPLEFT', 1, -1)
	Highlight:SetPoint('BOTTOMRIGHT', -1, 1)
	Highlight:SetColorTexture(0, 0.6, 1, 0.3)

	Slot.NormalTexture:SetSize(0.01, 0.01)

	local QuestIcon = Slot.QuestIcon
	if(QuestIcon) then
		QuestIcon:Hide()
	end

	local Flash = Slot.Flash
	if(Flash) then
		Flash:Hide()
	end

	local BattlePay = Slot.BattlePay
	if(BattlePay) then
		BattlePay:Hide()
	end
end

local function styleContainer(Container)
	local isBank = Container:GetParent():GetType() == 'bank'

	Container:SetBackdrop(BACKDROP)
	Container:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	Container:SetBackdropBorderColor(0, 0, 0)

	Container:SetSlotSize(32, 32)
	Container:SetSlotSpacing(4)
	Container:SetSlotPadding(10)
	Container:SetSlotRelPoint('TOPLEFT')
	Container:SetSlotGrowDirection('RIGHT', 'DOWN')

	Container:SetMaxColumns(8)
	Container:SetSpacing(2)

	if(isBank) then
		Container:SetRelPoint('TOPLEFT')
		Container:SetGrowDirection('RIGHT', 'DOWN')
	else
		Container:SetRelPoint('BOTTOMRIGHT')
		Container:SetGrowDirection('LEFT', 'UP')
	end

	local Name = Container:CreateFontString('$parentName', 'ARTWORK', 'PixelFontNormal')
	Name:SetPoint('TOPLEFT', 11, -10)
	Name:SetText(Container:GetLocalizedName())

	local category = Container:GetName()
	if(category == 'Inventory' and not isBank) then

		local Money = Container:AddWidget('Money')
		Money:SetPoint('BOTTOMRIGHT', -8, 6)
		Money.Label:SetFontObject('PixelFontNormal')

		local Currencies = Container:AddWidget('Currencies')
		Currencies:SetPoint('BOTTOMLEFT', 8, 6)
		Currencies:SetSize(1, 1)

		for index, Currency in next, Currencies.buttons do
			Currency.Label:SetFontObject('PixelFontNormal')
			Currency.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

			if(index ~= 1) then
				Currency:ClearAllPoints()
				Currency:SetPoint('BOTTOMLEFT', Currencies.buttons[index - 1], 'BOTTOMRIGHT', 5, 0)
			end
		end

		Container:SetPadding(10, 0, 26, 16)
	else
		Container:SetPadding(10, 0, 26, 0)
	end

	if(category == 'Junk' and not isBank) then
		local AutoVendor = Container:AddWidget('AutoVendor')
		AutoVendor:SetPoint('TOPRIGHT', -8, -6)
		AutoVendor:SetSize(16, 16)
		AutoVendor:SetNormalTexture(ICONS)
		AutoVendor:GetNormalTexture():SetTexCoord(0, 0.25, 0, 0.25)
		AutoVendor:HookScript('OnClick', onAutoVendorClick)
		onAutoVendorClick(AutoVendor)
	elseif(category == 'New') then
		local MarkKnown = Container:AddWidget('MarkKnown')
		MarkKnown:SetPoint('TOPRIGHT', -8, -6)
		MarkKnown:SetSize(16, 16)
		MarkKnown:SetNormalTexture(ICONS)
		MarkKnown:GetNormalTexture():SetTexCoord(0.75, 1, 0, 0.25)
	elseif(category == 'ReagentBank') then
		local Deposit = Container:AddWidget('Deposit')
		Deposit:SetPoint('TOPRIGHT', -28, -6)
		Deposit:SetSize(16, 16)
		Deposit:SetNormalTexture(ICONS)
		Deposit:GetNormalTexture():SetTexCoord(0.5, 0.75, 0, 0.25)

		local AutoDeposit = Container:AddWidget('AutoDeposit')
		AutoDeposit:SetPoint('TOPRIGHT', -48, -6)
		AutoDeposit:SetSize(16, 16)
		AutoDeposit:SetNormalTexture(ICONS)
		AutoDeposit:GetNormalTexture():SetTexCoord(0.5, 0.75, 0, 0.25)
		AutoDeposit:HookScript('OnClick', onAutoDepositClick)
		onAutoDepositClick(AutoDeposit)
	end

	if(category == 'Inventory' or category == 'ReagentBank') then
		local Restack = Container:AddWidget('Restack')
		Restack:SetPoint('TOPRIGHT', -8, -6)
		Restack:SetSize(16, 16)
		Restack:SetNormalTexture(ICONS)
		Restack:GetNormalTexture():SetTexCoord(0.25, 0.5, 0, 0.25)
	end
end

local Bags = LibContainer:New('bags', addOnName .. 'Bags', UIParent)
Bags:On('PostCreateSlot', styleSlot)
Bags:On('PostCreateContainer', styleContainer)
Bags:SetPoint('BOTTOMRIGHT', -50, 50)
Bags:AddFreeSlot()
Bags:OverrideToggles()

local Bank = LibContainer:New('bank', addOnName .. 'Bank', UIParent)
Bank:On('PostCreateSlot', styleSlot)
Bank:On('PostCreateContainer', styleContainer)
Bank:SetPoint('TOPLEFT', 50, -50)
Bank:AddFreeSlot()

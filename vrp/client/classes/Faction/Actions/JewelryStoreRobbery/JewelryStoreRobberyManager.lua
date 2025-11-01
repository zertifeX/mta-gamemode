-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Actions/JewelryStoreRobbery/JewelryStoreRobberyManager.lua
-- *  PURPOSE:     Jewelry store robbery manager class
-- *
-- ****************************************************************************

JewelryStoreRobberyManager = inherit(Singleton)

function JewelryStoreRobberyManager:constructor()
	self.m_Interior = 0
	self.m_Dimension = 60001

	addRemoteEvents{"jewelryStoreRobberySound", "jewelryStoreRobberyPedAnimation", "jewelryStoreRobberyAlarmStart", "jewelryStoreRobberyAlarmEnd", "jewelryStoreRobberyBreakGlass", "jewelryStoreRobberyDeliveryStart", "jewelryStoreRobberyDeliveryCancel"}

	self.m_AlarmInside = nil
	self.m_AlarmOutside = nil
	self.m_DeliveryCountdown = nil
	self.m_DeliveryCancelGUI = nil
	self.m_CancelButton = nil

	addEventHandler("jewelryStoreRobberySound", root, bind(self.Event_PlaySound, self))
	addEventHandler("jewelryStoreRobberyPedAnimation", root, bind(self.Event_ShopPedAnimation, self))
	addEventHandler("jewelryStoreRobberyAlarmStart", root, bind(self.Event_StartAlarm, self))
	addEventHandler("jewelryStoreRobberyAlarmEnd", root, bind(self.Event_EndAlarm, self))
	addEventHandler("jewelryStoreRobberyBreakGlass", root, bind(self.Event_BreakGlass, self))
	addEventHandler("jewelryStoreRobberyDeliveryStart", root, bind(self.Event_DeliveryStart, self))
	addEventHandler("jewelryStoreRobberyDeliveryCancel", root, bind(self.Event_DeliveryCancel, self))
end

function JewelryStoreRobberyManager:destructor()
end

function JewelryStoreRobberyManager:Event_PlaySound(reverse)
	local sound = playSound3D("files/audio/JewelryStoreRobbery/money.mp3", Vector3(32.613, 102.031, 698.455))
	sound:setDimension(self.m_Dimension)
	sound:setInterior(self.m_Interior)
	sound:setMinDistance(30)
	sound:setMaxDistance(50)
	local sampleRate, tempo, pitch, reverse2 = sound:getProperties()
	sound:setProperties(sampleRate, tempo, pitch, reverse)
end

function JewelryStoreRobberyManager:Event_BreakGlass(x, y, z)
	local sound = playSound3D("files/audio/JewelryStoreRobbery/glass_break.mp3", Vector3(x, y, z))
	sound:setDimension(self.m_Dimension)
	sound:setInterior(self.m_Interior)
	sound:setMinDistance(15)
	sound:setMaxDistance(20)
end

function JewelryStoreRobberyManager:Event_ShopPedAnimation(block, anim, time, loop, updatePosition, interruptable, freezeLastFrame)
	source:setAnimation(block, anim, time, loop, updatePosition, interruptable, freezeLastFrame)
end

function JewelryStoreRobberyManager:Event_StartAlarm()
	if not self.m_AlarmInside then
		self.m_AlarmInside = playSound3D("files/audio/Alarm.mp3", Vector3(30.79, 116.5, 700), true)
		self.m_AlarmInside:setDimension(self.m_Dimension)
		self.m_AlarmInside:setInterior(self.m_Interior)
		self.m_AlarmInside:setMaxDistance(50)
	end

	if not self.m_AlarmOutside then
		self.m_AlarmOutside = playSound3D("files/audio/Alarm.mp3", Vector3(557.41015625, -1498.75, 20.875), true)
		self.m_AlarmOutside:setMinDistance(100)
		self.m_AlarmOutside:setMaxDistance(300)
	end
end

function JewelryStoreRobberyManager:Event_EndAlarm()
	if isElement(self.m_AlarmInside) then
		self.m_AlarmInside:destroy()
	end

	if isElement(self.m_AlarmOutside) then
		self.m_AlarmOutside:destroy()
	end

	self.m_AlarmInside = nil
	self.m_AlarmOutside = nil
end

function JewelryStoreRobberyManager:Event_DeliveryStart(time, deliveryType)
	-- Cancel any existing countdown
	if self.m_DeliveryCountdown then
		delete(self.m_DeliveryCountdown)
		self.m_DeliveryCountdown = nil
	end
	
	-- Cancel any existing cancel GUI
	if self.m_DeliveryCancelGUI then
		delete(self.m_DeliveryCancelGUI)
		self.m_DeliveryCancelGUI = nil
	end
	
	-- Create the countdown with icon (similar to treatment)
	local title = deliveryType == "evil" and "Beute abgeben" or "Beute sicherstellen"
	local icon = "files/images/Inventory/items/Objekte/dufflebag.png"
	self.m_DeliveryCountdown = ShortCountdown:new(time, title, icon)
	
	-- Create cancel button next to countdown (simple GUIForm approach)
	setTimer(function()
		if self.m_DeliveryCountdown then
			local buttonX = self.m_DeliveryCountdown.m_AbsoluteX + self.m_DeliveryCountdown.m_Width
			local buttonY = self.m_DeliveryCountdown.m_AbsoluteY
			local buttonWidth = screenWidth*0.06
			local buttonHeight = screenHeight*0.03
			
			self.m_DeliveryCancelGUI = GUIForm:new(buttonX, buttonY, buttonWidth, buttonHeight, false)
			self.m_CancelButton = GUIButton:new(0, 0, buttonWidth, buttonHeight, "Abbruch", self.m_DeliveryCancelGUI)
			self.m_CancelButton.onLeftClick = function()
				triggerServerEvent("jewelryStoreRobberyDeliveryCancel", localPlayer)
			end
		end
	end, 50, 1)
end

function JewelryStoreRobberyManager:Event_DeliveryCancel()
	-- Cancel the countdown
	if self.m_DeliveryCountdown then
		delete(self.m_DeliveryCountdown)
		self.m_DeliveryCountdown = nil
	end
	
	-- Cancel the cancel button
	if self.m_CancelButton then
		self.m_CancelButton = nil
	end
	
	-- Cancel the cancel GUI
	if self.m_DeliveryCancelGUI then
		delete(self.m_DeliveryCancelGUI)
		self.m_DeliveryCancelGUI = nil
	end
end

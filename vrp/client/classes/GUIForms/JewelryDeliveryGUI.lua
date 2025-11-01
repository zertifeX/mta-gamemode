-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JewelryDeliveryGUI.lua
-- *  PURPOSE:     Jewelry delivery cancel button GUI class
-- *
-- ****************************************************************************
JewelryDeliveryGUI = inherit(GUIForm)
inherit(Singleton, JewelryDeliveryGUI)

function JewelryDeliveryGUI:constructor(posX, posY)
    GUIForm.constructor(self, posX, posY, screenWidth*0.06, screenHeight*.03, false)
    self.m_Cancel = GUIButton:new(0, 0, self.m_Width, self.m_Height, "Abbruch", self)
    self.m_Cancel.onLeftClick = function()
        triggerServerEvent("jewelryStoreRobberyDeliveryCancel", localPlayer)
    end
end

function JewelryDeliveryGUI:destructor()
    GUIForm.destructor(self)
end
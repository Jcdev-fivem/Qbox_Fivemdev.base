Config = {}

-- Max character slots available per player (Single character mode)
Config.DefaultSlots = 1
Config.SingleCharacterMode = true

-- Default nationality assigned if left blank
Config.DefaultNationality = 'Thai'

-- Default spawn coordinates for fresh characters (Legion Square)
Config.DefaultSpawn = vec4(195.17, -933.77, 29.7, 144.5)

-- Staging coordinates for dummy spawn during register screen
Config.SkinStaging = {
    pedCoords = vec4(-75.29, -819.12, 326.18, 0.0), -- Heading 0.0 faces North towards camera
    camCoords = vec3(-74.72, -816.8, 326.5),        -- Shifted horizontally so ped stands clear on screen right
    camHeading = 180.0,
    camFov = 45.0
}

-- Allow players to delete characters from the selection screen
Config.AllowDelete = true

-- ====================================================================
-- Appearance & Clothing Integration (ระบบแต่งตัว)
-- ====================================================================
-- กำหนดระบบแต่งตัวที่ต้องการเชื่อมต่อหลังจากสมัครตัวละคร:
--   'none'                : เข้าเมืองทันที ไม่ต้องมีระบบแต่งตัว (ค่าเริ่มต้น)
--   'illenium-appearance' : เรียกใช้ illenium-appearance
--   'fivem-appearance'    : เรียกใช้ fivem-appearance
--   'qb-clothing'         : เรียกใช้ qb-clothing
--   'custom'              : เรียก Custom Event ตามที่ตั้งไว้ใน Config.CustomAppearanceEvent
Config.Appearance = 'none'

-- สำหรับกรณีเลือก Config.Appearance = 'custom'
Config.CustomAppearanceEvent = 'jacob_appearance:client:startCreator'

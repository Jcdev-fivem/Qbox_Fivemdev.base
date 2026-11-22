# jacob_multicharacter

ระบบเลือกและสร้างตัวละคร (Multicharacter & Registration) สำหรับ FiveM Framework Qbox

## คุณสมบัติ (Features)
- รองรับทั้งโหมดตัวละครเดี่ยว (Single Character) และหลายตัวละคร (Multicharacter)
- หน้าต่างสร้างตัวละคร (Registration Form) สวยงาม ทันสมัย รองรับชื่อ, นามสกุล, วันเกิด, เพศ, ส่วนสูง
- **Modular Appearance System**: ยืดหยุ่นสูง สามารถเลือกเชื่อมต่อกับระบบแต่งตัวใดก็ได้ หรือข้ามเข้าเมืองได้ทันที
  - `none` : เข้าเมืองทันที ไม่ต้องมีสคริปต์แต่งตัว
  - `illenium-appearance`
  - `fivem-appearance`
  - `qb-clothing`
  - `custom` : รองรับ Custom Event ตามต้องการ
- ระบบป้องกันการค้างหน้า Staging / Rooftop แม้ไม่มีสคริปต์แต่งตัว

## การติดตั้ง (Installation)
1. นำโฟลเดอร์ `jacob_multicharacter` ไปวางในโฟลเดอร์ `resources/[Jacob]/`
2. Import ไฟล์ SQL ในโฟลเดอร์ `sql/` เข้าฐานข้อมูล MariaDB/MySQL:
   - `jacob_multicharacter.sql`
   - `jacob_outfits.sql`
3. ใน `server.cfg` เพิ่ม:
   ```cfg
   ensure [Jacob]
   # หรือ ensure jacob_multicharacter
   ```
4. ใน `resources/[qbx]/qbx_core/config/client.lua`:
   ตั้งค่า `characters.useExternalCharacters = true`
5. กำหนดค่าระบบแต่งตัวและจุดเกิดได้ใน `config.lua`

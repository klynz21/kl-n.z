-- ============================================
--           STATUS: MAINTENANCE / OUTDATED
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Thông báo hiển thị khi bị Kick
local kickReason = "\n\n[ SCRIPT THÔNG BÁO ]\n\nScript này ko dùng được hãy đợi từ nhà phát triển bruh :)) 🗿🤑💀\n"

-- Thực hiện Kick người chơi
if LocalPlayer then
    LocalPlayer:Kick(kickReason)
end

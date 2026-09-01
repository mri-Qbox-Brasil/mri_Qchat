-- [[ UTILITÁRIOS E PROCESSAMENTO DE CONFIG ]] --

local function HexToRGB(hex)
    hex = hex:gsub("#","")
    return {
        tonumber("0x"..hex:sub(1,2)),
        tonumber("0x"..hex:sub(3,4)),
        tonumber("0x"..hex:sub(5,6))
    }
end

-- Converte os hex de Config.Colors (cores por canal de mensagem) para RGB.
-- Config.UIPrimaryColor já vem resolvido do config.lua via GetConvar.
Citizen.CreateThread(function()
    for channel, hex in pairs(Config.Colors) do
        if type(hex) == "string" and hex:sub(1,1) == "#" then
            Config.Colors[channel] = HexToRGB(hex)
        end
    end
end)

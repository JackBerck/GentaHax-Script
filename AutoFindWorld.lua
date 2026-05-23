-- ========================================================
-- AUTO FINDER WORLD (4 & 5 LETTERS No Numbers)
-- CREATOR: Jakjul
-- ========================================================

math.randomseed(os.time())
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local isPaused = false
local hasStartedOnce = false
local skipCurrentWorld = false

function generateRandomName(length)
    local name = ""
    for i = 1, length do
        local idx = math.random(1, #alphabet)
        name = name .. string.sub(alphabet, idx, idx)
    end
    return name
end

-- ========================================================
-- 1. INFORMASI UI VIA CONSOLE
-- ========================================================
logToConsole("=========================================")
logToConsole("`2AUTO WORLD FINDER`o by Jakjul")
logToConsole("Fitur: Lag Handler (Door Check) & Smart Skip")
logToConsole("`4PENTING:`o Buka menu STORE untuk MULAI pertama kali.")
logToConsole("Setelah mulai, buka STORE lagi untuk PAUSE/RESUME.")
logToConsole("=========================================")
doToast(1, 5000, "Script Siap! Tekan STORE untuk MULAI.")

-- ========================================================
-- 2. HOOK: KONTROL UTAMA
-- ========================================================
AddHook("OnTextPacket", "MainControllerHook", function(flag, packet)
    if packet:find("action|store") then
        if not hasStartedOnce then
            hasStartedOnce = true
            doToast(1, 3000, "Auto Finder by Jakjul - Dimulai!")
            
            runThread(function()
                startFindingWorlds()
            end, "WorldFinderThread")
        else
            isPaused = not isPaused
            if isPaused then
                callToast("Auto Finder: PAUSED", 1)
                logToConsole("`4[PAUSE] Auto Finder dijeda.``")
            else
                callToast("Auto Finder: RESUMED", 1)
                logToConsole("`2[RESUME] Auto Finder dilanjutkan.``")
            end
        end
        return true 
    end
end)

-- ========================================================
-- 3. HOOK: PENDETEKSI SERVER REJECTION
-- ========================================================
AddHook("OnVarlist", "ServerRejectionHook", function(varlist, netID)
    if not hasStartedOnce then return end
    
    local command = tostring(varlist[0])
    if command == "OnConsoleMessage" then
        local msg = tostring(varlist[1]):lower()
        if msg:find("inaccessible") or msg:find("level") or msg:find("too low") or msg:find("can't enter") or msg:find("restricted") then
            logToConsole("`4[SKIP] World terkunci/inaccessible. Langsung ganti!``")
            skipCurrentWorld = true
        end
    end
end)

-- ========================================================
-- 4. FUNGSI UTAMA PENCARIAN WORLD
-- ========================================================
function startFindingWorlds()
    local limit = 100 -- Jumlah percobaan masuk world
    local delayMs = 10000 -- Waktu tunggu di DALAM world (10 Detik)
    local maxLoadingTime = 30000 -- Maksimal nunggu loading map (30 detik)

    for i = 1, limit do
        while isPaused do
            sleep(200)
        end

        local nameLength = math.random(4, 5)
        local targetWorld = generateRandomName(nameLength)

        logToConsole("`w[" .. i .. "/" .. limit .. "] Mencoba: `2" .. targetWorld .. "``")
        sendPacket(3, "action|join_request\nname|" .. targetWorld)

        skipCurrentWorld = false 
        
        -- ====================================================
        -- FASE 1: POLLING WHITE DOOR (LOADING HANDLER)
        -- ====================================================
        local isLoaded = false
        local loadingTime = 0
        
        while loadingTime < maxLoadingTime do
            if skipCurrentWorld then
                break 
            end
            
            local worldData = getWorld()
            if worldData and worldData.name == targetWorld:upper() then
                local tiles = getTile()
                if tiles then
                    for t = 1, #tiles do
                        if tiles[t].fg == 6 then
                            isLoaded = true
                            break
                        end
                    end
                end
            end
            
            if isLoaded then
                break 
            end
            
            sleep(500)
            loadingTime = loadingTime + 500
        end

        -- ====================================================
        -- FASE 2: COUNTDOWN DI DALAM WORLD
        -- ====================================================
        if isLoaded then
            logToConsole("`9[+] Berhasil masuk ke " .. targetWorld .. ". Pantauan 10 detik.``")
            local elapsed = 0
            while elapsed < delayMs do
                if skipCurrentWorld then break end
                
                if isPaused then
                    while isPaused do sleep(200) end
                end
                
                sleep(200)
                elapsed = elapsed + 200
            end
        else
            if not skipCurrentWorld then
                logToConsole("`4[-] Lag parah/Timeout di " .. targetWorld .. ". Skip ke world selanjutnya.``")
            end
        end
    end

    hasStartedOnce = false
    doToast(1, 3000, "Auto Finder Selesai! - by Jakjul")
end

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
-- 1. UI INFORMATION VIA CONSOLE
-- ========================================================
logToConsole("=========================================")
logToConsole("`2AUTO WORLD FINDER`o by Jakjul")
logToConsole("Feature: Lag Handler (Door Check) & Smart Skip")
logToConsole("`4IMPORTANT:`o Open STORE menu to START for the first time.")
logToConsole("After starting, open STORE again to PAUSE/RESUME.")
logToConsole("=========================================")
doToast(1, 5000, "Script Ready! Press STORE to START.")

-- ========================================================
-- 2. HOOK: MAIN CONTROL
-- ========================================================
AddHook("OnTextPacket", "MainControllerHook", function(flag, packet)
    if packet:find("action|store") then
        if not hasStartedOnce then
            hasStartedOnce = true
            doToast(1, 3000, "Auto Finder by Jakjul - Started!")
            
            runThread(function()
                startFindingWorlds()
            end, "WorldFinderThread")
        else
            isPaused = not isPaused
            if isPaused then
                callToast("Auto Finder: PAUSED", 1)
                logToConsole("`4[PAUSE] Auto Finder paused.``")
            else
                callToast("Auto Finder: RESUMED", 1)
                logToConsole("`2[RESUME] Auto Finder resumed.``")
            end
        end
        return true 
    end
end)

-- ========================================================
-- 3. HOOK: SERVER REJECTION DETECTOR
-- ========================================================
AddHook("OnVarlist", "ServerRejectionHook", function(varlist, netID)
    if not hasStartedOnce then return end
    
    local command = tostring(varlist[0])
    if command == "OnConsoleMessage" then
        local msg = tostring(varlist[1]):lower()
        if msg:find("inaccessible") or msg:find("level") or msg:find("too low") or msg:find("can't enter") or msg:find("restricted") then
            logToConsole("`4[SKIP] World is locked/inaccessible. Skipping!``")
            skipCurrentWorld = true
        end
    end
end)

-- ========================================================
-- 4. MAIN WORLD SEARCH FUNCTION
-- ========================================================
function startFindingWorlds()
    local limit = 100 -- Number of world join attempts
    local delayMs = 10000 -- Wait time INSIDE the world (10 seconds)
    local maxLoadingTime = 30000 -- Maximum wait for map loading (30 seconds)

    for i = 1, limit do
        while isPaused do
            sleep(200)
        end

        local nameLength = math.random(4, 5)
        local targetWorld = generateRandomName(nameLength)

        logToConsole("`w[" .. i .. "/" .. limit .. "] Trying: `2" .. targetWorld .. "``")
        sendPacket(3, "action|join_request\nname|" .. targetWorld)

        skipCurrentWorld = false 
        
        -- ====================================================
        -- PHASE 1: POLLING WHITE DOOR (LOADING HANDLER)
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
        -- PHASE 2: COUNTDOWN INSIDE THE WORLD
        -- ====================================================
        if isLoaded then
            logToConsole("`9[+] Successfully entered " .. targetWorld .. ". Monitoring for 10 seconds.``")
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
                logToConsole("`4[-] Severe lag/Timeout at " .. targetWorld .. ". Skipping to next world.``")
            end
        end
    end

    hasStartedOnce = false
    doToast(1, 3000, "Auto Finder Finished! - by Jakjul")
end

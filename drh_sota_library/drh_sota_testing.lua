local DEBUG = false;

local ScriptName = "DRH Testing Tool";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "Testing Calls and Callbacks from SOTA";
local IconPath = "drh_sota_assets/skill_alchemy.png";

local DRH_TESTING = DRH_TESTING or {
    ---@type boolean
    started = false;

    ---@type boolean
    init = false;

    ---@type string
    userInfoPath;

    ---@type number
    updateIntervalMs = 5000;

    ---@type number
    screenWidth = 0;

    ---@type number
    screenHeight = 0;

    testPanel = {};

    printPlayerStatus = function()
        local playerHealth = ShroudGetStatValueByNumber(14);
        local playerMaxHealth = ShroudGetStatValueByNumber(30);
        local playerFocus = ShroudGetStatValueByNumber(13)
        local playerMaxFocus = ShroudGetStatValueByNumber(27);

        DRH.infoMessage(ScriptName, string.format("Health: %.2f/%.2f Focus: %.2f/%.2f", playerHealth, playerMaxHealth, playerFocus, playerMaxFocus));

        local playerX = ShroudPlayerX;
        local playerY = ShroudPlayerX;
        local playerZ = ShroudPlayerZ;

        DRH.infoMessage(ScriptName, string.format("Position X=%.3f, Y=%.3f, Z=%.3f", playerX, playerY, playerZ));

        local alpha = ShroudGetPlayerOrientation();
        local beta =  ShroudGetCurrentSceneOrientation();

        if not beta then
            beta = 0;
        end

        DRH.infoMessage(ScriptName, string.format("Bearing: %.3f, Scene: %.3f", alpha, beta));
    end;

    createTestPanel = function()
        screenWidth = ShroudGetScreenX();
        screenHeight = ShroudGetScreenY();

        testPanel = {};

        -- Create the main panel
        testPanel.x = 0;
        testPanel.y = screenHeight / 2;
        testPanel.w = DRH.VERTICAL_SPACING_BUTTONS;
        testPanel.h = DRH.VERTICAL_SPACING_BUTTONS;

        DRH.infoMessage(ScriptName, "MainPanel 1");

        testPanel.id = ShroudUIPanel(testPanel.x, testPanel.y, testPanel.w, testPanel.h);

        DRH.infoMessage(ScriptName, "MainPanel 2");

        ShroudSetColor(testPanel.id, UI.Panel, "#000000");
        ShroudSetTransparency(testPanel.id, UI.Panel, 0.8);

    end;

    --
    --
    --
    boundaryCheck = function(objectId, objectKind)
        DRH.infoMessage(ScriptName, "Checking object boundary vs screen.");

        if objectId == testPanel.id and objectKind == UI.Panel then
            DRH.panelBoundaryCheck(testPanel);
        end;
    end;

    --
    --
    --
    printBuffs = function()
        for index = 1, ShroudGetBuffCount() do
            local name = ShroudGetBuffName(index);
            local desc = ShroudGetBuffDescription(index);
            local remain = ShroudGetBuffTimeRemaining(index);

            DRH.infoMessage(ScriptName, string.format("%d: name=%s, description=%s, remain=%s", index, name, desc, remain));
        end;
    end;

    printOtherBuffs = function()
        local buffs = ShroudGetPlayerBuff()
        if buffs then
            for i,v in pairs(buffs) do
                DRH.infoMessage(ScriptName, string.format("name=%s", v.RuneName));
                for j,y in pairs(v.effects) do
                    DRH.infoMessage(ScriptName, "Effects:" .. y.value .. " " .. y.description .. " Duration: " .. y.currentDuration .. "/" .. y.totalDuration .. " Ticks: " .. y.totalTick);
                end;
            end;
        end;

    end;

    printInventory = function()
        inventory = ShroudGetInventory();
        if inventory then
            for _, item in ipairs(inventory) do
                local name, durability, primaryDurability, maxDurability, weight, quantity, createdBy, creationTime, creationScene, lengthOrSize, value = item;

                if name:find("Fish") and createdBy and creationScene then
                    DRH.infoMessage(ScriptName, string.format("--> name=%s, by=%s, where=%s, when=%s", name, createdBy, creationScene, creationTime));
                end;
            end ;
        end ;

    end;
};

---@type number
local timestamp = 0;

---@type number
local currentTime = 0;

---@type number
local elapsedTime = 0;

--
-- Called when SOTA scripting is started
--
function ShroudOnStart()

    DRH_TESTING.started = false;
    DRH_TESTING.init = false;

    DRH.infoMessage(ScriptName, "--TEST-- ShroudOnStart / -");
    DRH.propertiesPath = ShroudLuaPath .. '/drh.properties'

    ShroudConsoleLog("Started!");

    DRH_TESTING.createTestPanel();

    DRH_TESTING.started = true;
end

--
-- Called when scene is unloaded
--
function ShroudOnSceneUnloaded()
    DRH.infoMessage(ScriptName,"--TEST-- Scene ShroudOnSceneUnloaded / -");
end

function ShroudOnSceneLoaded(sceneName)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnSceneLoaded / sceneName=%s", sceneName));
end

--
-- Called when user is logged out
--
function ShroudOnLogout()
    DRH.infoMessage(ScriptName, "--TEST-- ShroudOnLogout / -");
end

function ShroudOnMouseOver(objectId, objectKind)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnMouseOver / objectId=%s", objectId));
    DRH_TESTING.boundaryCheck(objectId, objectKind);
end

function ShroudOnMouseOut(objectId, objectKind)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnMouseOut / objectId=%s", objectId));
    DRH_TESTING.boundaryCheck(objectId, objectKind);
end

function ShroudOnMouseClick(objectId, objectKind)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnMouseClick / objectId=%s", objectId));
end

function ShroudOnInputChange(objectId, text)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnMouseOut / objectId=%s, text=%s", objectId, text));
end

function ShroudOnToggleChange(objectId, isOn)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnToggleChange / objectId=%s, text=%s", objectId, isOn));
end

function ShroudOnPlayFX(fxName)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnPlayFX / fxName=%s", fxName));
end

function ShroudOnPlaySound(soundName)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnPlaySound / soundName=%s", soundName));
end

function ShroudOnExperienceGain(type, amount)
    DRH.infoMessage(ScriptName,string.format("--TEST-- Scene ShroudOnExperienceGain / type=%s, amount=%s", type, amount));
end


function ShroudOnDisableScript()
    DRH.infoMessage(ScriptName, "--TEST-- ShroudOnDisableScript / -");
end

function ShroudOnConsoleInput(channel, sender, message)
    DRH.infoMessage(ScriptName, string.format("--TEST-- ShroudOnConsoleInput / channel=%s, sender=%s, message=%s", channel, sender, message));
end




function ShroudOnUpdate()
    if not DRH_TESTING.started then
        return
    end

    if not DRH_TESTING.init then
        if not ShroudServerTime then
            return
        end
        init = true;
    end

    currentTime = ShroudTime * 1000;
    elapsedTime = currentTime - timestamp;

    if (elapsedTime) < DRH_TESTING.updateIntervalMs then
        return
    end

    timestamp = currentTime;


    DRH_TESTING.printPlayerStatus();
--    DRH_TESTING.printBuffs();
--    DRH_TESTING.printOtherBuffs();

    DRH_TESTING.printInventory();

    delta = elapsedTime;

    DRH.infoMessage(ScriptName, string.format("%02f ms passed since last call", delta));
end

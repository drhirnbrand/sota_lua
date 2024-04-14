local DEBUG = false;

-- These values can be changed
local updateMinimumInMs = 20; -- the minimum number of ms between each update
local updateDriftSpeed = 100; -- drift of health/focus per time, how fast the bar moves to the current value after a change. Large number make it move faster.


-- Do not change anything below this line
local ScriptName = "DRH Health Bar";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "A simple moveable health/focus and pet/summon health bar";
local IconPath = "drh_sota_assets/healthbar_icon.png";

local INDEX_MAIN = { panel = 1 };
local INDEX_TITLE = { panel = 1, text = 5 };
local INDEX_PLAYER_HEALTH = { panel = 2, bar = 2, down = 3, up = 4, text = 2, tx_bg = 1, tx = 2, tx_up = 3, tx_down = 4 };
local INDEX_PLAYER_FOCUS = { panel = 3, bar = 5, down = 6, up = 7, text = 3, tx_bg = 1, tx = 5, tx_up = 6, tx_down = 7 };
local INDEX_SUMMON_HEALTH = { panel = 4, bar = 8, down = 9, up = 10, text = 4, tx_bg = 1, tx = 8, tx_up = 9, tx_down = 10 };
local VERTICAL_SPACING = 16;

local now = 0;
local elapsedTime = 0;
local timestamp = 0;
local delta = 0;

local init = false;

local playerHealthPrevious = 0;
local playerFocusPrevious = 0;
local summonHealthPrevious = 0;

local summonHealth = 0;
local summonMaxHealth = 0;
local playerHealth = 0;
local playerMaxHealth = 0;
local playerFocus = 0;
local playerMaxFocus = 0;

local summonPercentage = 0;

local LogPrefixInfo = "[0000ff]drh_sota_healthbar: "
local LogPrefixWarn = "[ff0000]drh_sota_healthbar: "
local LogPrefixDebug = "[ff0000]DEBUG drh_sota_healthbar: "
local LogSuffix = "[-]"

--- This is a structure that stores the main information objects
---
local HEALTHBAR = HEALTHBAR or {
    -- Datastructure for Panel positions, filled during startup
    panelsSpec = {
        { desc = "Main",          border = 0, bgColor = "#000000", transparency = 0.8 },
        { desc = "Player Health", border = 2, bgColor = "#000000", transparency = 0.8 },
        { desc = "Player Focus",  border = 2, bgColor = "#000000", transparency = 0.8 },
        { desc = "Summon Health", border = 2, bgColor = "#000000", transparency = 0.8 }
    },

    texturesSpec = { { name = "Background", filename = 'drh_sota_assets/bg.png' },
        { name = "Player Health",      filename = 'drh_sota_assets/playerHealth.png' },
        { name = "Player Health Up",   filename = 'drh_sota_assets/playerHealthUp.png' },
        { name = "Player Health Down", filename = 'drh_sota_assets/playerHealthDown.png' },
        { name = "Player Focus",       filename = 'drh_sota_assets/playerFocus.png' },
        { name = "Player Focus Up",    filename = 'drh_sota_assets/playerFocusUp.png' },
        { name = "Player Focus Down",  filename = 'drh_sota_assets/playerFocusDown.png' },
        { name = "Summon Health",      filename = 'drh_sota_assets/summonHealth.png' },
        { name = "Summon Health Up",   filename = 'drh_sota_assets/summonHealthUp.png' },
        { name = "Summon Health Down", filename = 'drh_sota_assets/summonHealthDown.png' }
    },

    textsSpec = {
        { fontSize = 10, text = "DRH Healthbar",             color = "#ffffff" },
        { fontSize = 10, text = "0 / 0",                     color = "#ffffff" },
        { fontSize = 10, text = "0 / 0",                     color = "#ffffff" },
        { fontSize = 10, text = "0 / 0",                     color = "#ffffff" },
        { fontSize = 10, text = "DRH Healthbar " .. Version, color = "#8f8f8f" }
    },

    buttonsCurrent = {},
    panelsCurrent = {},
    texturesCurrent = {},
    barsCurrent = {},
    textsCurrent = {},

    panelXPosPercent = 80000,
    panelYPosPercent = 80000,

    counter = 0,

    userInfo = "",

    ready = false,

    currentStats = {},
}

-- Executed when SOTA Lua scripting is started
function ShroudOnStart()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Health Monitor %s" .. LogSuffix, Version));

    HEALTHBAR.userInfo = ShroudLuaPath .. '/drh_sota_healthbar/user.ini';

    -- Restore the previously stored panel positions
    loadSettings();

    -- Load textures and other assets
    loadAssets();

    local screenWidth = ShroudGetScreenX();
    local screenHeight = ShroudGetScreenY();
    local mainPanelSpec = HEALTHBAR.panelsSpec[INDEX_MAIN.panel];

    local mainPanel = {};
    HEALTHBAR.panelsCurrent[INDEX_MAIN.panel] = mainPanel;

    -- Create the main panel
    mainPanel.x = HEALTHBAR.panelXPosPercent * screenWidth / 100000;
    mainPanel.y = HEALTHBAR.panelYPosPercent * screenHeight / 100000;
    mainPanel.w = VERTICAL_SPACING * 12;
    mainPanel.h = VERTICAL_SPACING * 4;

    mainPanel.id = ShroudUIPanel(mainPanel.x, mainPanel.y, mainPanel.w, mainPanel.h);
    ShroudSetColor(mainPanel.id, UI.Panel, mainPanelSpec.bgColor);
    ShroudSetTransparency(mainPanel.id, UI.Panel, mainPanelSpec.transparency);

    -- On top of the panel, create a centered title text
    prepareTitle();

    preparePanel(INDEX_PLAYER_HEALTH, 1);
    preparePanel(INDEX_PLAYER_FOCUS, 2);
    preparePanel(INDEX_SUMMON_HEALTH, 3);

    ShroudConsoleLog(string.format(LogPrefixInfo .. "Started!" .. LogSuffix))

    HEALTHBAR.ready = true;
end

function prepareTitle()
    local mainPanel = HEALTHBAR.panelsCurrent[INDEX_MAIN.panel];
    local titleTextSpec = HEALTHBAR.textsSpec[INDEX_TITLE.text];
    local titleBorder = 48

    local titleText = {};
    HEALTHBAR.textsCurrent[INDEX_TITLE.text] = titleText;

    titleText.w = mainPanel.w - (titleBorder * 2);
    titleText.h = VERTICAL_SPACING;
    titleText.x = titleBorder;
    titleText.y = 0;
    titleText.id = ShroudUIText(titleTextSpec.text, titleTextSpec.fontSize, titleText.x, titleText.y, titleText.w,
        titleText.h, mainPanel.id, UI.Panel);
    ShroudSetColor(titleText.id, UI.Text, titleTextSpec.color);
    ShroudSetTextAlignment(titleText.id, TextAnchor.MiddleCenter);
end

function preparePanel(index, row)
    local mainPanel = HEALTHBAR.panelsCurrent[INDEX_MAIN.panel];
    local barBorder = 2;

    local panelSpec = HEALTHBAR.panelsSpec[index.panel];
    local textSpec = HEALTHBAR.textsSpec[index.text];

    local panel = {};
    HEALTHBAR.panelsCurrent[index.panel] = panel;

    panel.w = mainPanel.w;
    panel.h = VERTICAL_SPACING - (2 * panelSpec.border);
    panel.x = 0;
    panel.y = (VERTICAL_SPACING * row) + panelSpec.border;
    panel.id = ShroudUIPanel(panel.x, panel.y, panel.w, panel.h, HEALTHBAR.texturesCurrent[index.tx_bg].id, mainPanel.id,
        UI.Panel);
    ShroudUnsetDragguable(panel.id, UI.Panel)
    ShroudSetColor(panel.id, UI.Panel, panelSpec.bgColor);

    local bar = {};
    local up = {}
    local down = {}

    bar.w = panel.w - (barBorder * 2);
    bar.wMax = bar.w;
    bar.h = panel.h - (barBorder * 2);
    bar.x = barBorder;
    bar.y = barBorder;
    bar.id = ShroudUIImage(bar.x, bar.y, bar.w, bar.h, HEALTHBAR.texturesCurrent[index.tx].id, panel.id, UI.Panel);

    up.w = 0;
    up.wMax = bar.w;
    up.h = bar.h
    up.x = bar.x + bar.w
    up.y = bar.y
    up.id = ShroudUIImage(up.x, up.y, up.w, up.h, HEALTHBAR.texturesCurrent[index.tx_up].id, panel.id, UI.Panel);

    down.w = 0;
    down.wMax = bar.w;
    down.h = bar.h
    down.x = bar.x + bar.w
    down.y = bar.y
    down.id = ShroudUIImage(down.x, down.y, down.w, down.h, HEALTHBAR.texturesCurrent[index.tx_down].id, panel.id,
        UI.Panel);

    HEALTHBAR.barsCurrent[index.bar] = bar;
    HEALTHBAR.barsCurrent[index.up] = up;
    HEALTHBAR.barsCurrent[index.down] = down;

    local text = {};
    HEALTHBAR.textsCurrent[index.text] = text;

    text.w = panel.w;
    text.h = panel.h;
    text.x = 0;
    text.y = 0
    text.id = ShroudUIText(textSpec.text, textSpec.fontSize, text.x, text.y, text.w, text.h, panel.id, UI.Panel);
    ShroudSetColor(text.id, UI.Text, textSpec.color);
    ShroudSetTextAlignment(text.id, TextAnchor.MiddleCenter);
end

function ShroudOnSceneUnloaded()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Scene unloading..." .. LogSuffix));
    updateAndSavePositions()
end

function ShroudOnLogout()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Logout..." .. LogSuffix));
    updateAndSavePositions()
end

function ShroudOnDisableScript()
    HEALTHBAR.ready = false;

    updateAndSavePositions();
    for i = 1, #HEALTHBAR.panelsCurrent do
        ShroudDestroyObject(HEALTHBAR.panelsCurrent[i].id, UI.Panel);
    end
end

-- Allows to save the current configuration/settings with "!commit" in local chat.
function ShroudOnConsoleInput(channel, sender, message)
    if ShroudGetPlayerName() == sender and channel == 'Local' then
        if string.find(message, '!commit') then
            updateAndSavePositions()
        end
    end
end

function ShroudOnUpdate()
    if not init then
        if not ShroudServerTime then
            return
        end
        init = true;
    end
    if not HEALTHBAR.ready then
        return
    end

    now = ShroudTime * 1000;
    elapsedTime = now - timestamp;

    if (elapsedTime) < updateMinimumInMs then
        return
    end

    timestamp = now;

    --
    -- Update the health bars
    --
    summonHealth = 0;
    summonMaxHealth = 0;
    summonPercentage = 1.0;

    if ShroudGetPetInfo() then
        summonHealth = ShroudGetPetInfo().CurrentHealth;
        summonMaxHealth = ShroudGetPetInfo().MaxHealth;

        updateBar(INDEX_SUMMON_HEALTH, summonHealth, summonHealthPrevious, summonMaxHealth);
    else
        updateBar(INDEX_SUMMON_HEALTH, 0, 0, 0);
    end

    playerHealth = ShroudGetStatValueByNumber(14);
    playerMaxHealth = ShroudGetStatValueByNumber(30);
    playerFocus = ShroudGetStatValueByNumber(13)
    playerMaxFocus = ShroudGetStatValueByNumber(27);

    updateBar(INDEX_PLAYER_HEALTH, playerHealth, playerHealthPrevious, playerMaxHealth);
    updateBar(INDEX_PLAYER_FOCUS, playerFocus, playerFocusPrevious, playerMaxFocus);

    --
    -- move bars according to time passed
    delta = elapsedTime * updateDriftSpeed * 10E-6;

    playerHealthPrevious = drift(playerHealth, playerHealthPrevious, delta, playerMaxHealth);
    playerFocusPrevious = drift(playerFocus, playerFocusPrevious, delta, playerMaxFocus);
    summonHealthPrevious = drift(summonHealth, summonHealthPrevious, delta, summonMaxHealth);
end

function drift(current, previous, delta, max)
    local difference = current - previous;
    local drift = sign(difference) * delta * max;
    local adjusted = previous;

    if difference < 0 then
        adjusted = math.max(previous + drift, current);
    elseif difference > 0 then
        adjusted = math.min(previous + drift, current);
    end

    return adjusted;
end

function sign(number)
    return (number > 0 and 1) or (number == 0 and 0) or -1;
end

function updateBar(index, current, previous, max)
    local text = HEALTHBAR.textsCurrent[index.text];
    local bar = HEALTHBAR.barsCurrent[index.bar];
    local up = HEALTHBAR.barsCurrent[index.up];
    local down = HEALTHBAR.barsCurrent[index.down];

    --local factor = 0;
    --local factorPrevious = 0;
    --
    --if not max == 0 then
    factor = current / max
    factorPrevious = previous / max
    --end

    text.text = string.format("%i / %i", math.floor(current + 0.5), math.floor(max + 0.5));

    local difference = current - previous;

    if difference < 0 then
        bar.w = math.floor((bar.wMax * factor) + 0.5);

        up.w = 0;
        down.w = down.wMax * (factorPrevious - factor)

        up.x = bar.x + bar.w;
        down.x = bar.x + bar.w;
    elseif difference > 0 then
        w = bar.wMax * factor;
        bar.w = math.floor((bar.wMax * factorPrevious) + 0.5);

        up.w = w - bar.w;
        down.w = 0;

        up.x = bar.x + bar.w;
        down.x = bar.x + bar.w;
    elseif difference == 0 then
        bar.w = bar.wMax * factor;

        up.w = 0;
        down.w = 0;

        up.x = bar.x + bar.w;
        down.x = bar.x + bar.w;
    end

    ShroudModifyText(text.id, text.text);
    ShroudSetSize(bar.id, UI.Image, bar.w, bar.h)
    ShroudSetSize(down.id, UI.Image, down.w, down.h)
    ShroudSetPosition(down.id, UI.Image, down.x, down.y)
    ShroudSetSize(up.id, UI.Image, up.w, up.h)
    ShroudSetPosition(up.id, UI.Image, up.x, up.y)
end

function updateAndSavePositions()
    ShroudConsoleLog("HM: Storing settings...");
    local screenWidth = ShroudGetScreenX();
    local screenHeight = ShroudGetScreenY();
    local mainPanel = HEALTHBAR.panelsCurrent[INDEX_MAIN.panel];
    local mainPosition = ShroudGetPosition(mainPanel.id, UI.Panel);

    HEALTHBAR.panelXPosPercent = math.floor(mainPanel.x * 100000 / screenWidth);
    HEALTHBAR.panelYPosPercent = math.floor(mainPanel.y * 100000 / screenHeight);

    mainPanel.x = math.min(mainPosition.x, screenWidth - mainPanel.w);
    mainPanel.y = math.min(mainPosition.y, screenHeight - mainPanel.h);

    ShroudConsoleLog(string.format(LogPrefixInfo .. "Main panel position: %s,%s" .. LogSuffix, HEALTHBAR
        .panelXPosPercent, HEALTHBAR.panelYPosPercent))
    saveSettings();
end

function saveSettings()
    file = io.open(HEALTHBAR.userInfo, "w")

    if file then
        file:write("panelXPosPercent=" .. HEALTHBAR.panelXPosPercent .. "\n");
        file:write("panelYPosPercent=" .. HEALTHBAR.panelYPosPercent .. "\n");
        file:close()
    end
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Settings saved!" .. LogSuffix));
end

function loadSettings()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Loading settings..." .. LogSuffix));

    ---- Create if not exist.
    local file = io.open(HEALTHBAR.userInfo, "r")

    if file == nil then
        saveSettings()
    else
        file:close()
    end
    --
    ---- Load file in key-value store
    file = io.open(HEALTHBAR.userInfo, "r");

    for line in file:lines() do
        local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
        if (param and value ~= nil) then
            if param == 'panelXPosPercent' then
                HEALTHBAR.panelXPosPercent = tonumber(value);
            elseif param == 'panelYPosPercent' then
                HEALTHBAR.panelYPosPercent = tonumber(value);
            end
        end
    end

    file:close();
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Settings loaded!" .. LogSuffix));
end

--
-- Asset loading (Textures, Images, etc)
--
function loadAssets()
    for index = 1, #HEALTHBAR.texturesSpec do
        loadAsset(index);
    end
    ShroudConsoleLog(LogPrefixInfo .. " Assets loaded." .. LogSuffix)
end

function loadAsset(index)
    local filename = HEALTHBAR.texturesSpec[index].filename;
    local name = HEALTHBAR.texturesSpec[index].name;
    local texture = {}

    texture.id = ShroudLoadTexture(filename, false);

    HEALTHBAR.texturesCurrent[index] = texture;

    if texture.id == -1 then
        ShroudConsoleLog(string.format(LogPrefixWarn .. "'%s' not found (file: %s)!" .. LogSuffix, name, filename));
    else
        if DEBUG then
            ShroudConsoleLog(string.format(LogPrefixDebug .. " Asset '%s' (file: %s) loaded as id %s" .. LogSuffix, name,
                filename, texture.id));
        end
    end
end

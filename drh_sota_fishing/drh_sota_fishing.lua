-- Do not change anything below this line
local ScriptName = "DRH Fishing Tracker & Tool";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "Add-On to track fishing and help with fishing contests";
local IconPath = "drh_sota_assets/fishing_icon.png";

local DRH_FISHING = {
    UserInfoPath = ShroudLuaPath .. '/drh_sota_fishing/user.ini',

    started = false,

    INDEX_MAIN = { panel = 1, texture = 1 },
    INDEX_FISHING_TRACKER = { button = 1, texture = 2 },
    INDEX_FISHING_CONTEST = { button = 2, texture = 3 },

    panelsSpec = {
        { desc = "Main",            border = 0, bgColor = "#000000", transparency = 0.8 },
        { desc = "Fishing Tracker", border = 2, bgColor = "#000000", transparency = 0.8 },
        { desc = "Contest Results", border = 2, bgColor = "#000000", transparency = 0.8 },
        --        { desc = "Statistics", border = 2, bgColor = "#000000", transparency = 0.8 }
    },

    buttonsSpec = {
        { desc = "Fishing Tracker", border = 2, bgColor = "#000000", transparency = 0.8 },
        { desc = "Contest Results", border = 2, bgColor = "#000000", transparency = 0.8 },
    },

    texturesSpec = {
        { name = "Background",      filename = 'drh_sota_assets/bg.png' },
        { name = "Fishing Pole",    filename = 'drh_sota_assets/fishing_pole.png' },
        { name = "Fishing Contest", filename = 'drh_sota_assets/fishing_contest.png' }
    },

    textsSpec = {
        { fontSize = 10, text = "DRH Healthbar",             color = "#ffffff" },
        { fontSize = 10, text = "0 / 0",                     color = "#ffffff" },
        { fontSize = 10, text = "0 / 0",                     color = "#ffffff" },
        { fontSize = 10, text = "0 / 0",                     color = "#ffffff" },
        { fontSize = 10, text = "DRH Healthbar " .. Version, color = "#8f8f8f" }
    },

    panelsCurrent = {},
    texturesCurrent = {},
    buttonsCurrent = {},
    textsCurrent = {},

    panelXPosPercent = 0,
    panelYPosPercent = 0,

    fishingPanel,

    --
    --
    --
    createFishingPanel = function()
        local fishingPanelSpec = DRH_FISHING.panelsSpec[INDEX_MAIN.panel];

        fishingPanel = {};

        -- Create the main panel
        fishingPanel.x = DRH_FISHING.panelXPosPercent * screenWidth / DRH.SCREEN_SIZE_DIVISOR;
        fishingPanel.y = DRH_FISHING.panelYPosPercent * screenHeight / DRH.SCREEN_SIZE_DIVISOR;
        fishingPanel.w = DRH.VERTICAL_SPACING_BUTTONS * 2;
        fishingPanel.h = DRH.VERTICAL_SPACING_BUTTONS * 1;

        fishingPanel.id = ShroudUIPanel(mainPanel.x, mainPanel.y, mainPanel.w, mainPanel.h);
        ShroudSetColor(fishingPanel.id, UI.Panel, fishingPanelSpec.bgColor);
        ShroudSetTransparency(fishingPanel.id, UI.Panel, fishingPanelSpec.transparency);

        panelsCurrent[INDEX_MAIN.panel] = fishingPanel;

        return mainPanel;
    end
}

-- Executed when SOTA Lua scripting is started
function ShroudOnStart()
    DRH_FISHING.started = false;

    DRH_FISHING.texturesCurrent = DRH.loadTextures(ScriptName, DRH_FISHING.texturesSpec);

    mainPanel = DRH_FISHING.createFishingPanel();

    DRH.infoMessage(ScriptName, "Started.");

    DRH_FISHING.started = true;
end

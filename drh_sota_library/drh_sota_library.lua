local ScriptName = "DRH library of functions";
local Version = "0.1";
local CreatorName = "Doktor Hirnbrand";
local Description = "A library of useful functions and constants";
local IconPath = "drh_sota_assets/books-colored.png";

DRH = {
    LogPrefixInfo = "[0000ff]%s: ";
    LogPrefixWarn = "[ff0000]%s: ";
    LogPrefixDebug = "[ff0000]DEBUG %s: ";
    LogSuffix = "[-]";

    DEBUG = false;
    SCREEN_SIZE_DIVISOR = 100000;

    VERTICAL_SPACING_BUTTONS = 32;

    ---@param addOnName string
    ---@param message string
    infoMessage = function(addOnName, message)
        ShroudConsoleLog(string.format(DRH.LogPrefixInfo .. "%s" .. DRH.LogSuffix, addOnName, message));
    end;

    ---@param addOnName string
    ---@param message string
    warnMessage = function(addOnName, message)
        ShroudConsoleLog(string.format(DRH.LogPrefixWarn .. "%s" .. DRH.LogSuffix, addOnName, message));
    end;

    ---@param addOnName string
    ---@param message string
    debugMessage = function(addOnName, message)
        ShroudConsoleLog(string.format(DRH.LogPrefixDebug .. "%s" .. DRH.LogSuffix, addOnName, message));
    end;

    --
    -- Texture loading
    --
    ---@param addOnName string
    ---@param spec table
    loadTextures = function(addOnName, spec)
        local texturesCurrent = {};
        local count = #spec;
        for index = 1, #spec do
            texturesCurrent[index] = DRH.loadTexture(addOnName, spec, index);
        end

        DRH.infoMessage(addOnName, string.format("%d Asset(s) loaded.", count));
        return texturesCurrent;
    end;

    ---@param addOnName string
    ---@param spec table
    ---@param index number
    loadTexture = function(addOnName, spec, index)
        local name = spec[index].name;
        local filename = spec[index].filename;

        local texture = {};

        texture.id = ShroudLoadTexture(filename, false);

        if texture.id == -1 then
            DRH.warnMessage(addOnName, string.format("'%s' not found (file: %s)!", name, filename));
        else
            if DRH.DEBUG then
                DRH.debugMessage(addOnName, string.format("Asset '%s' (file: %s) loaded as id %s", name, filename, texture.id));
            end
        end

        return texture;
    end;


    --saveSettings = function(addOnName, path, properties)
    --    file = io.open(path, "w");
    --
    --    for key, value in pairs(properties) do
    --        file:write(string.format("%s=%s" .. "\n", key, value));
    --    end
    --    file:close();
    --
    --    DRH.infoMessage(addOnName, "Settings saved.");
    --end;

    --loadSettings = function()
    --    ShroudConsoleLog(string.format(LogPrefixInfo .. "Loading settings..." .. LogSuffix));
    --
    --    ---- Create if not exist.
    --    local file = io.open(HEALTHBAR.userInfo, "r")
    --
    --    if file == nil then
    --        saveSettings()
    --    else
    --        file:close()
    --    end
    --    --
    --    ---- Load file in key-value store
    --    file = io.open(HEALTHBAR.userInfo, "r");
    --
    --    for line in file:lines() do
    --        local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
    --        if (param and value ~= nil) then
    --            if param == 'panelXPosPercent' then
    --                HEALTHBAR.panelXPosPercent = tonumber(value);
    --            elseif param == 'panelYPosPercent' then
    --                HEALTHBAR.panelYPosPercent = tonumber(value);
    --            end
    --        end
    --    end
    --
    --    file:close();
    --    ShroudConsoleLog(string.format(LogPrefixInfo .. "Settings loaded!" .. LogSuffix));
    --
    --      end

    ---@param panel table
    panelBoundaryCheck = function(panel)

        local pos = ShroudGetPosition(panel.id, UI.Panel);
        local x = pos.x;
        local y = pos.y;

        if x < 0 then
            x = 0;
        end
        if y < 0 then
            y = 0;
        end

        if (x + panel.w) > ShroudGetScreenX() then
            x = ShroudGetScreenX() - panel.w
        end
        if (y + panel.h) > ShroudGetScreenY() then
            y = ShroudGetScreenY() - panel.h
        end

        ShroudSetPosition(panel.id, UI.Panel, x, y);
        panel.x = x;
        panel.y = y;
    end
}

return DRH;

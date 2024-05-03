--[[
Copyright 2022 <COPYRIGHT HOLDER>
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]
local ScriptName = "DRH library of functions";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "A library of useful functions and constants";
local IconPath = "drh_sota_assets/books-colored.png";

DRH = {
    ---@type number
    frame = 0,

    ---@type boolean
    Debug = true,

    ---@type boolean
    Ready = false,

    ---@type boolean
    Active = false,

    ---@type boolean
    Initialized = false,

    ---@type boolean
    Halted = false,

    ---@type boolean
    Hidden = false,

    ---@type number
    screen_x = 0,

    ---@type number
    screen_y = 0,

    --- Global constants

    ---@type string
    LogPrefixInfo = "[0000ff]%s: ",

    ---@type string
    LogPrefixWarn = "[ffff00]%s: ",

    ---@type string
    LogPrefixError = "[ff0000]%s: ",

    ---@type string
    LogPrefixDebug = "[7f7f7f]DEBUG %s: ",

    ---@type string
    LogSuffix = "[-]",

    ---@type number
    SCREEN_SIZE_FRACTION = 1E6,

    ---@type number
    DEFAULT_VERTICAL_SPACING = 32,


    ---@type string
    DEFAULT_MODULE_EXTENSION = ".lua",

    ---@type string
    DEFAULT_PROPERTIES_PATH = "/drh_global.properties",

    ---@type string
    DEFAULT_ASSETS_PATH = "/drh_sota_assets",

    ---@type string
    DEFAULT_PATH_SEPARATOR = "/",

    ---@type string
    PROPERTY_NAME_KEY = "_name",

    --- Level Information

    ---@type table
    level_to_xp_map = {},

    ---@type table
    listeners = {},

    arrays = {
        ---@param array: the array from which to return the last element
        get_last = function(array)
            return array[#array]
        end,

        ---@param array: the array from which to remove the last entry
        remove_last = function(array)
            array[#array] = nil
        end,
    },

    strings = {
        ---@param input_string: the input string to split into parts
        split_path = function(input_string)
            local parts = {}
            for part in input_string:gmatch("[^\\/]+") do
                parts[#parts + 1] = part
            end
            return parts
        end,

        ends_with = function(input_string, ending)
            if ending == "" then
                return true
            end

            return input_string:sub(- #ending) == ending
        end
    },

    modules = {
        -- taking hints from libsota and bms
        ---@param module_name: the module to load, needs to be a relative path to LUA base directory
        load_module = function(module_name)
            local parts = DRH.strings.split_path(module_name)

            local path_string = table.concat(parts, "/")

            local last_part = DRH.arrays.get_last(parts)
            if not DRH.strings.ends_with(last_part, DRH.DEFAULT_MODULE_EXTENSION) then
                path_string = path_string .. DRH.DEFAULT_MODULE_EXTENSION
            end

            local module_path = ShroudLuaPath .. DRH.DEFAULT_PATH_SEPARATOR .. path_string

            fd = io.open(module_path, "r")

            if not fd then
                DRH.errorMessage("library",
                    "load_module: module not found at " .. module_path .. "!")
                return nil
            end

            local content = fd:read("*a")
            fd:close()

            local module, exception = loadsafe(content, module_name, "bt", _G)

            if not module then
                errorMessage("library", "load_module: module exception:" .. exception)
                return nil
            end

            return module
        end,
    },


    ---@param addOnName string
    ---@param message string
    infoMessage = function(addOnName, message)
        ShroudConsoleLog(string.format(DRH.LogPrefixInfo .. "%s" .. DRH.LogSuffix, addOnName, message));
    end,

    ---@param addOnName string
    ---@param message string
    warnMessage = function(addOnName, message)
        ShroudConsoleLog(string.format(DRH.LogPrefixWarn .. "%s" .. DRH.LogSuffix, addOnName, message));
    end,

    ---@param addOnName string
    ---@param message string
    errorMessage = function(addOnName, message)
        ShroudConsoleLog(string.format(DRH.LogPrefixError .. "%s" .. DRH.LogSuffix, addOnName, message));
    end,

    ---@param addOnName string
    ---@param message string
    debugMessage = function(addOnName, message)
        if DRH.Debug then
            ShroudConsoleLog(string.format(DRH.LogPrefixDebug .. "%s" .. DRH.LogSuffix, addOnName, message));
        end
    end,

    assets = {
        --
        -- Image/Texture loading
        --
        ---@param addOnName string
        ---@param spec table
        loadAssets = function(addOnName, component_specs, component, clamp)
            if not component.assets then
                component.assets = {}
            end

            local assets = component.assets

            local asset_count = 0;
            for index, spec in ipairs(component_specs.assets) do
                asset = DRH.assets.loadAsset(addOnName, spec, index, clamp);
                if asset then
                    table.insert(assets, asset)
                    asset_count = asset_count + 1
                end
            end

            DRH.infoMessage(addOnName, string.format("%d Asset(s) loaded.", asset_count));
        end,

        ---@param addOnName string
        ---@param spec table
        ---@param clamp boolean
        loadAsset = function(addOnName, spec, clamp)
            local name = spec.name
            local path = spec.path

            local image = { assetID = -1 }

            image.assetID = ShroudLoadTexture(path, clamp);

            if image.assetID == -1 then
                DRH.warnMessage(addOnName, string.format("'%s' not found (file: %s)!", name, path));
            else
                DRH.debugMessage(addOnName,
                    string.format("Asset '%s' (file: %s) loaded as id %s", name, path, image.assetID));
            end

            return image;
        end,
    },

    properties = {
        save = function(addOnName, path, properties)
            local file = io.open(ShroudLuaPath .. path, "w");
            local key_count = 0

            if properties == nil then
                DRH.infoMessage(addOnName, "properties.save: Properties is nil");
                return
            end

            for key, value in pairs(properties) do
                file:write(string.format("%s=%s" .. "\n", key, value));
                key_count = key_count + 1
            end

            file:close();

            if not properties[DRH.PROPERTY_NAME_KEY] == nil then
                DRH.infoMessage(addOnName,
                    key_count .. "Properties from " .. properties[DRH.PROPERTY_NAME_KEY] .. " saved to " .. path)
            end
            DRH.infoMessage(addOnName, key_count .. " Properties saved to " .. path);
        end,

        load = function(addOnName, path, properties)
            DRH.infoMessage(addOnName, "Loading properties from " .. path)

            --- Load file in key-value store
            local file = io.open(ShroudLuaPath .. path, "r");
            local key_count = 0

            for line in file:lines() do
                local key, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
                if (key and value) then
                    DRH.properties.set(addOnName, properties, key, value)
                    key_count = key_count + 1
                end
            end
            DRH.infoMessage(addOnName, key_count .. " properties loaded")
        end,

        ---@param addOnName: caller's name
        ---@param properties: loaded key-value pairs will be added to this table
        ---@param key: value key
        ---@param value: value
        set  = function(addOnName, properties, key, value)
            local decoded_value

            decoded_value = tonumber(value)
            if decoded_value then
                properties[key] = decoded_value
                DRH.debugMessage(addOnName, decoded_value .. " decoded as number")
                return
            end

            decoded_value = tostring(value)
            if decoded_value then
                if value.upper == "TRUE" or value.upper == "YES" then
                    properties[key] = true
                    DRH.debugMessage(addOnName, decoded_value .. " decoded as boolean")
                    return
                end
                if value.upper == "FALSE" or value.upper == "NO" then
                    properties[key] = false
                    DRH.debugMessage(addOnName, decoded_value .. " decoded as boolean")
                    return
                end

                properties[key] = decoded_value
                DRH.debugMessage(addOnName, decoded_value .. " decoded as string")
                return
            end

            DRH.debugMessage(addOnName, value .. " not decoded, stored as-is")
            properties[key] = value
        end,
    },

    ui_checks = {
        ---@param panel table
        check_panel_boundary_against_screen = function(self, panel)
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
        end,

        update_screen_size = function(self)
            local old_ScreenX = DRH.screen_x
            local old_ScreenY = DRH.screen_y

            DRH.screen_x = ShroudGetScreenX()
            DRH.screen_y = ShroudGetScreenY()

            DRH.debugMessage(ScriptName,
                "ScreenX " .. old_ScreenX .. " -> " .. DRH.screen_x ..
                ", ScreenY " .. old_ScreenY .. " -> " .. DRH.screen_y)

            return DRH.screen_x, DRH.screen_y
        end
    },

    math = {
        pow = function(base, exponent)
            return base ^ exponent
        end
    },

    levels = {
        load_level_xp_maps = function()
            --- Load 2-column csv file into key-value store
            local file = io.open(ShroudLuaPath .. "/drh_sota_library/sota_experience.csv", "r");
            local key_count = 0

            for line in file:lines() do
                local row = {}
                for str in string.gmatch(line, "([^,]+)") do
                    table.insert(row, str)
                end
                local level = tonumber(row[1])
                local xp = tonumber(row[2])

                if (level and xp) then
                    DRH.level_to_xp_map[level] = xp
                    key_count = key_count + 1
                end
            end
            DRH.infoMessage(ScriptName, "Loaded " .. key_count .. " level and xp data")
        end,

        ---@param xp
        get_level = function(xp)
            for _level, _xp in ipairs(DRH.level_to_xp_map) do
                if _xp >= xp then
                    return _level
                end
            end
            return nil
        end,

        get_xp = function(level)
            if level > 200 then
                DRH.errorMessage(ScriptName, "Asking for lvl > 200")
                return nil
            end
            return DRH.level_to_xp_map[level]
        end
    },

    registry = {
        add_listener = function(id, object)
            DRH.listeners[id] = object
            DRH.infoMessage(ScriptName, "registered " .. id)
        end,

        notify_hidden = function(hidden)
            for id, listener in pairs(DRH.listeners) do
                listener.notify_hidden(hidden)
            end
        end,
    },

    console = {
        DAMAGE_PLAYER_ON_TARGET = 1,

        classify = function(line)
            return DAMAGE_PLAYER_ON_TARGET
        end
    },

    ui = {
        create_images_and_textures = function(addOnName, component_specs, component)
            if not component.images then
                component.images = {}
            end


            if not component.textures then
                component.textures = {}
            end

            local _assets = component.assets

            if component_specs.images then
                local _images = component.images
                for index, image_spec in ipairs(component_specs.images) do
                    local image = {}
                    image.index = index
                    local _assetID = _assets[image_spec.asset_index].assetID

                    image.objectID = ShroudUIImage(image_spec.x, image_spec.y,
                        image_spec.width, image_spec.height,
                        _assetID);

                    local w, h = ShroudGetTextureSize(image_spec.objectID)
                    image.w = w
                    image.h = h

                    table.insert(_images, image)
                end
            end

            if component_specs.textures then
                local _textures = component.textures
                for index, texture_spec in ipairs(component_specs.textures) do
                    local texture = {}
                    texture.index = index
                    local _assetID = _assets[texture_spec.asset_index].assetID
                    texture.objectID = ShroudUIImage(texture_spec.x, texture_spec.y,
                        texture_spec.w, texture_spec.h,
                        _assetID);

                    local w, h = ShroudGetTextureSize(_assetID)
                    texture.w = w
                    texture.h = h

                    table.insert(_textures, texture)
                end
            end
        end,

        ---@param component_specs
        create_panel = function(addOnName, component_specs, component, index)
            local name = "<unknown>"

            if (component_specs.panels[index].name) then
                name = component_specs.panels[index].name
            end

            DRH.debugMessage(ScriptName .. ":" .. addOnName,
                string.format("create_panel index %d (%s)", index, name))

            local panel = {}
            local panel_spec = component_specs.panels[index]

            if not component.panels then
                component.panels = {}
            end

            local _panels = component.panels

            table.insert(_panels, index, panel)

            local objectID = ShroudUIPanel(panel_spec.x, panel_spec.y, panel_spec.w, panel_spec.h);
            panel.objectID = objectID

            local x, y = ShroudGetPosition(objectID, UI.Panel)
            panel.x = x
            panel.y = y

            if panel_spec.anchor_min_x and panel_spec.anchor_min_y then
                DRH.debugMessage(ScriptName .. ":" .. addOnName,
                    string.format("setting min anchor %.02f,%.02f", panel_spec.anchor_min_x, panel_spec.anchor_min_y))
                ShroudSetAnchorMin(objectID, UI.Panel, panel_spec.anchor_min_x, panel_spec.anchor_min_y)
            end

            if panel_spec.anchor_max_x and panel_spec.anchor_max_y then
                DRH.debugMessage(ScriptName .. ":" .. addOnName,
                    string.format("setting max anchor %.02f,%.02f", panel_spec.anchor_min_x, panel_spec.anchor_min_y))
                ShroudSetAnchorMin(objectID, UI.Panel, panel_spec.anchor_max_x, panel_spec.anchor_max_y)
            end

            if panel_spec.pivot_x and panel_spec.pivot_y then
                ShroudSetPivot(objectID, UI.Panel, panel_spec.pivot_x, panel_spec.pivot_y)
                DRH.debugMessage(ScriptName .. ":" .. addOnName,
                    string.format("setting pivot %.02f,%.02f", panel_spec.pivot_x, panel_spec.pivot_y))
            end

            if panel_spec.raycast then
                ShroudRaycastObject(objectID, UI.Panel, panel_spec.raycast)
            end

            if panel_spec.parent_index then
                local parent_index = panel_spec.parent_index
                local parent_target = _panels[parent_index]
                if parent_target then
                    local parent_objectID = parent_target.objectID
                    if not parent_objectID or parent_objectID == -1 then
                        DRH.errorMessage(ScriptName .. addOnName, "parent not yet initialized!")
                    end
                    ShroudSetParent(objectID, UI.Panel, parent_objectID, UI.Panel)
                end
            end

            if panel_spec.bg then
                ShroudSetColor(objectID, UI.Panel, panel_spec.bg)
            end

            if panel_spec.resizable then
                ShroudSetResizable(objectID, UI.Panel)

                local w_max = 0
                local h_max = 0
                local w_min = 0
                local h_min = 0

                if panel_spec.w_max then
                    w_max = panel_spec.w_max
                end
                if panel_spec.h_max then
                    h_max = panel_spec.h_max
                end

                if panel_spec.w_min then
                    w_min = panel_spec.w_min
                end
                if panel_spec.h_min then
                    h_min = panel_spec.h_min
                end

                w_max = math.max(panel_spec.w, math.min(w_max, DRH.screen_x))
                h_max = math.max(panel_spec.h, math.min(h_max, DRH.screen_y))

                ShroudMinMaxSize(objectID, UI.Panel, w_min, w_max, "Horizontal")
                ShroudMinMaxSize(objectID, UI.Panel, h_min, h_max, "Vertical")
            end

            if panel_spec.texture_index then
                local texture_index = panel_spec.texture_index
                local texture = component.textures[texture_index]
                if texture then
                    local texture_objectID = texture.objectID

                    if not texture_objectID or texture_objectID == -1 then
                        DRH.errorMessage(ScriptName .. addOnName, "asset not yet initialized!")
                    end
                    DRH.debugMessage(ScriptName .. addOnName,
                        string.format("create_panel: adding texture %d", texture_objectID))

                    ShroudSetParent(texture_objectID, UI.Image, objectID, UI.Panel)
                    ShroudSetAnchorMin(texture_objectID, UI.Image, 0.0, 0.0)
                    ShroudSetAnchorMax(texture_objectID, UI.Image, 1.0, 1.0)
                    ShroudRaycastObject(texture_objectID, UI.Image, false)
                end
            end

            if panel_spec.children then
                for _, child in ipairs(panel_spec.children) do
                    local child_objectID = DRH.ui.create_panel(addOnName, component_specs, component, child)
                    DRH.debugMessage(ScriptName .. ":" .. addOnName,
                        string.format("create_panel adding child %d to %d", child_objectID, objectID))
                    ShroudSetParent(child_objectID, UI.Panel, objectID, UI.Panel)
                end
            end

            return objectID
        end
    }
}


function ShroudOnStart()
    DRH.debugMessage(ScriptName, "Version:" .. Version)
    DRH.levels.load_level_xp_maps()
    DRH.Ready = true
end

function ShroudOnDisableScript()
end

function ShroudOnSceneLoaded(sceneName)
    DRH.debugMessage(ScriptName, "Scene " .. sceneName .. " loaded, updating screen sizes")
end

function ShroudOnConsoleInput(channel, sender, message)
    ---    DRH.debugMessage(ScriptName, "console input: (sender: " .. sender .. ") " .. message)
end

function ShroudOnUpdate()
    if not DRH.Ready then
        return
    end

    if not DRH.Active then
        -- We wait at least until the server time is available
        if not DRH.Initialized then
            if not ShroudServerTime then
                return
            end
            DRH.Initialized = true;
        end

        -- At this point we are done with the startup
        if not DRH.Halted then
            DRH.Active = true
        end

        return
    end

    if ShroudIsUIActive() then
        if DRH.Hidden then
            DRH.Hidden = false
            DRH.registry.notify_hidden(false)
            DRH.infoMessage(ScriptName, "Un-Hiding UI")
        end
    else
        if not DRH.Hidden then
            DRH.Hidden = true
            DRH.registry.notify_hidden(true)
            DRH.infoMessage(ScriptName, "Hiding UI")
        end
    end
end

return DRH;

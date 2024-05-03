-- Do not change anything below this line
local ScriptName = "DRH XP Info & Statistics";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "Show Information and Statistics about Adventure and Production XP and Levels";
local IconPath = "drh_sota_assets/xpinfo_icon.png";

DRH_XP_INFO = {
    ID_PANEL_MAIN = 1,
    ID_PANEL_WINDOW_BUTTONS = 2,
    ID_TEXTURE_BACKGROUND = 1,

    ID_BUTTON_CLOSE = 1,
    ID_BUTTON_RESET = 2,
    ID_BUTTON_MODE = 3,

    ID_LABEL_ADV_XP_TITLE = 1,
    ID_LABEL_ADV_XP_VALUE = 2,
    ID_LABEL_PROD_XP_TITLE = 3,
    ID_LABEL_PROD_XP_VALUE = 4,

    GRID_WIDTH = 16,
    GRID_HEIGHT = 16,
    HISTOGRAM_WIDTH = 3,

    adventurer_attenuation = false,
    producer_attenuation = false,

    adventurer_xp_ring = {},
    producer_xp_ring = {},
    xp_ring_size = 60,
    adventurer_xp_session_start = 0,
    producer_xp_session_start = 0,

    xp_info = {},

    xp_info_specs = {

        assets = { { name = "Background", path = "drh_sota_assets/bg.png",  clamp = false },
            { name = "Title Background", path = "drh_sota_assets/bg_title.png", clamp = false }, },

        textures = { { asset_index = 1, x = 0, y = 0, w = 1, h = 1 },
            { asset_index = 2, x = 0, y = 0, w = 1, h = 1 }, },

        images = {},

        panels = {
            {
                name = "XP",
                x = 0,
                y = 0,
                w = 60 * 3,
                h = 16 * 4,
                w_max = 60 * 5,
                h_max = 16 * 8,
                texture_index = 1,
                resizable = true,
                children = { 2 }
            },
            {
                name = "XP_Title",
                x = 0,
                y = 0,
                w = 1,
                h = 16,
                texture_index = 2,
                anchor_min_x = 0.0,
                anchor_min_y = 0.0,
                anchor_max_x = 1.0,
                anchor_max_y = 0.0,
                raycast = false
            },
            {
                name = "Window_Buttons",
                x = 0,
                y = 0,
                w = 3 * 16,
                h = 1 * 16,
                anchor_min_x = 0.0,
                anchor_min_y = 0.0,
                anchor_max_x = 1.0,
                anchor_max_y = 0.0,
                pivot_x = 1.0,
                pivot_y = 1.0,
                raycast = false
            },
        },

        buttons = {
            { text = "X", x = 0, y = 0, w = 8, h = 8 },
            { text = "R", x = 0, y = 0, w = 8, h = 8 },
            { text = "M", x = 0, y = 0, w = 8, h = 8 },
        },

        labels = {
            { label = "Adv",  x = 0, y = 0, w = 8 * 5,  h = 8, fs = 8 },
            { label = "0",    x = 0, y = 0, w = 8 * 24, h = 8, fs = 8 },
            { label = "Prod", x = 0, y = 0, w = 8 * 5,  h = 8, fs = 8 },
            { label = "0",    x = 0, y = 0, w = 8 * 24, h = 8, fs = 8 },
        },
    },

    notify_hidden = function(hidden)
        if not DRH_XP_INFO.xp_info.panels[1] then
            return
        end

        if hidden then
            ShroudHideObject(DRH_XP_INFO.xp_info.panels[1].objectID, UI.Panel)
            return
        end

        ShroudShowObject(DRH_XP_INFO.xp_info.panels[1].objectID, UI.Panel)
    end,

    update_adventurer_xp = function(amount)
    end,

    update_producer_xp = function(amount)
    end,

    ---@type boolean
    hide_adv_xp_pool = false,

    hide_adv_xp_hourly = false,

    hide_adv_xp_session = false,

    hide_prod_xp_pool = false,

    hide_prod_xp_hourly = false,

    hide_prod_xp_session = false,
}

function ShroudOnExperienceGain(type, amount)
    if type == "Adventurer" then
        DRH_XP_INFO.update_adventurer_xp(amount)
    end
    if type == "Producer" then
        DRH_XP_INFO.update_producer_xp(amount)
    end
end

function ShroudOnLogout()

end

function ShroudOnStart()
    DRH.registry.add_listener(ScriptName, DRH_XP_INFO)
    DRH.infoMessage(ScriptName, Version);
    DRH.modules.load_module("drh_sota_xpinfo/extra.lua")

    DRH.assets.loadAssets(ScriptName, DRH_XP_INFO.xp_info_specs, DRH_XP_INFO.xp_info)

    create_xp_panel()
end

function ShroudOnUpdate()
    if not DRH.Ready then
        return
    end
end

function create_xp_panel()
    DRH.ui.create_images_and_textures(ScriptName, DRH_XP_INFO.xp_info_specs, DRH_XP_INFO.xp_info)
    DRH.ui.create_panel(ScriptName, DRH_XP_INFO.xp_info_specs, DRH_XP_INFO.xp_info, 1)

    --_images[2].objectID = ShroudUIImage(
    --    _images[2].x, _images[2].y,
    --    _images[2].width, _images[2].height,
    --    _images[2].textureID);
    --
    ----Here we set the logo as a child of the background, so later, if we move the background, the childs will follow.
    --ShroudSetParent(
    --    _images[2].objectID, UI.Image,
    --    _images[1].objectID, UI.Image);
    --
    ---- Adding texts
    --_texts[1].objectID = ShroudUIText(_texts[1].text,
    --    _texts[1].fontSize,
    --    _texts[1].x, _texts[1].y,
    --    _texts[1].width, _texts[1].height,
    --    _images[1].objectID,
    --    UI.Image);
    ----you can also set the parent directly to a previously created object. objectID and depth are optional parameters
    ----Here is the defined UI element of that _images[1].objectID.
    --
    ---- It's important to set this with the object ID we want to access because object IDs are saved by element kind.
    ---- It could be a panel or image and both would have an id of 1 so the game would'nt know which kind of object you want to access if it's not set.
    --
    --_texts[2].objectID = ShroudUIText(_texts[2].text,
    --    _texts[2].fontSize,
    --    _texts[2].x, _texts[2].y,
    --    _texts[2].width, _texts[2].height,
    --    _panels[1].objectID,
    --    UI.Panel);
    --
    --_texts[3].objectID = ShroudUIText(_texts[3].text,
    --    _texts[3].fontSize,
    --    _texts[3].x, _texts[3].y,
    --    _texts[3].width, _texts[3].height,
    --    _panels[1].objectID,
    --    UI.Panel);
    --
    --ShroudRaycastObject(_texts[1].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false
    --ShroudRaycastObject(_texts[2].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false
    --ShroudRaycastObject(_texts[3].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false
    --
    ---- Suddenly we decide to attach background.jpg image as a child of panel. All child attached to our image will move with it.
    --ShroudSetParent(_images[1].objectID, UI.Image, _panels[1].objectID, UI.Panel);
    --
    --ShroudSetAnchorMin(_texts[1].objectID, UI.Text, 0.5, 0.5);   --This is where we place the object in relation of the parent, in this case, the middle
    --ShroudSetAnchorMax(_texts[1].objectID, UI.Text, 0.5, 0.5);
    --ShroudSetPivot(_texts[1].objectID, UI.Text, 0.5, 0.5);       --Setting the point of pivot to middle of the image (where the position and rotation will occur from)
    --ShroudSetTextAlignment(_texts[1].objectID, TextAnchor.MiddleCenter); -- This is where the text is displayed within the width and height of the box. MiddleCenter and UpperLeft will be the most used. It goes from LowerLeft to MiddleCenter to UpperRight (uppercenter... middleright... etc)
    --ShroudSetTextAlignment(_texts[2].objectID, TextAnchor.UpperLeft);
    --ShroudSetTextAlignment(_texts[3].objectID, TextAnchor.LowerLeft);
    --
    --ShroudSetColor(_texts[2].objectID, UI.Text, "#FF0000");
    --
    --
    ----Lets add a button
    --_buttons[1].objectID = ShroudUIButton(
    --    _buttons[1].x, _buttons[1].y,
    --    _buttons[1].width, _buttons[1].height,
    --    _images[1].textureID,
    --    _panels[1].objectID,
    --    UI.Panel);
    ----Texture argument is needed before setting an object parent optional but can be set to null with the value -1
    ----Here we will use the same image as background.jpg (this could have been saved in a different lua table called _textures for efficacity)
    ----We set this button on the panel parent
    --
    ----We are going to set this button anchor top right of the panel, then set the pivot point of the button itself top right
    ----This will make our "hide window" button fixed in the right corner of the panel even if we would increase the size of the panel or reduce it.
    --ShroudSetAnchorMin(_buttons[1].objectID, UI.Button, 1.0, 1.0);
    --ShroudSetAnchorMax(_buttons[1].objectID, UI.Button, 1.0, 1.0);
    --ShroudSetPivot(_buttons[1].objectID, UI.Button, 1.0, 1.0);
    --
    ----Lets add a X text on that button
    --_texts[3].objectID = ShroudUIText(_texts[4].text,
    --    _texts[4].fontSize,
    --    _texts[4].x, _texts[4].y,
    --    _texts[4].width, _texts[4].height,
    --    _buttons[1].objectID,
    --    UI.Button);
    --
    --ShroudSetColor(_texts[4].objectID, UI.Text, "#FF0000");      -- and make it red
    --
    --ShroudSetAnchorMin(_texts[4].objectID, UI.Text, 0.5, 0.5);   --set the middle of the button as the anchor
    --ShroudSetAnchorMax(_texts[4].objectID, UI.Text, 0.5, 0.5);
    --ShroudSetPivot(_texts[4].objectID, UI.Text, 0.5, 0.5);       -- set center of our text as our middle
    --ShroudSetTextAlignment(_texts[4].objectID, TextAnchor.MiddleCenter); --set text within the text rect in middle also
end

function notify_ready()
    load_assets();
end

return DRH_XP_INFO

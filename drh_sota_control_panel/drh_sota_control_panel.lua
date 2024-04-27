-- Do not change anything below this line
local ScriptName = "DRH XP Control Panel";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "A control panel for DRH tools";
local IconPath = "drh_sota_assets/control_panel_icon.png";

DRH_CONTROL_PANEL = {

    out = false,
    out_position = 0,

    out_timer = 0,

    ---@type number out timer in milliseconds
    out_timer_default = 1000,
    out_position_default = 5,

    ID_PANEL_MAIN = 1,
    ID_TEXTURE_BACKGROUND = 1,

    control_panel = {},

    control_panel_spec = {
        images = {
            { name = 'Background', sprite = DRH.DEFAULT_ASSETS_PATH .. "/bg.png", clamp = false },
        },

        panels = {
            { name = 'Control Panel', x = 0, y = 0, width = 5, height = 24 },
        },

    },

}

function create_control_panel()
    DRH_CONTROL_PANEL.control_panel.panels = {
        { x = 0, y = 0, width = 0, height = 0, objectID = -1, parentID = -1 }
    }

    DRH_CONTROL_PANEL.control_panel.images = {
        { x = 0, y = 75.0, width = 1024, height = 768, textureID = -1, objectID = -1, parentID = -1 },
    }

    --_text_area_1.texts = {
    --    { text = "This is just a demo!", x = 0, y = 0, width = 1000, height = 32, fontSize = 24, objectID = -1, parentID = -1 },
    --    { text = "Click and drag me!",   x = 0, y = 0, width = 1000, height = 32, fontSize = 24, objectID = -1, parentID = -1 },
    --    { text = "Click and drag me!",   x = 0, y = 0, width = 1000, height = 32, fontSize = 24, objectID = -1, parentID = -1 },
    --    { text = "X",                    x = 0, y = 0, width = 32,   height = 32, fontSize = 24, objectID = -1, parentID = -1 }
    --}
    --
    --_text_area_1.buttons = {
    --    { x = 0, y = 0, width = 32, height = 32, objectID = -1, parentID = -1 }
    --}

    local _panels = DRH_CONTROL_PANEL.control_panel.panels
    local _images = DRH_CONTROL_PANEL.control_panel.images
    local _texts = DRH_CONTROL_PANEL.control_panel.texts
    local _buttons = DRH_CONTROL_PANEL.control_panel.buttons

    _panels[1].objectID = ShroudUIPanel(
        _panels[1].x, _panels[1].y,
        _panels[1].width, _panels[1].height);

    _images[1].textureID = ShroudLoadTexture(
        _images[1].sprite);

    _images[1].objectID = ShroudUIImage(
        _images[1].x, _images[1].y,
        _images[1].width, _images[1].height,
        _images[1].textureID);

    _images[2].textureID = ShroudLoadTexture(
        _images[2].sprite);

    _images[2].objectID = ShroudUIImage(
        _images[2].x, _images[2].y,
        _images[2].width, _images[2].height,
        _images[2].textureID);

    --Here we set the logo as a child of the background, so later, if we move the background, the childs will follow.
    ShroudSetParent(
        _images[2].objectID, UI.Image,
        _images[1].objectID, UI.Image);

    -- Adding texts
    _texts[1].objectID = ShroudUIText(_texts[1].text,
        _texts[1].fontSize,
        _texts[1].x, _texts[1].y,
        _texts[1].width, _texts[1].height,
        _images[1].objectID,
        UI.Image);
    --you can also set the parent directly to a previously created object. objectID and depth are optional parameters
    --Here is the defined UI element of that _images[1].objectID.

    -- It's important to set this with the object ID we want to access because object IDs are saved by element kind.
    -- It could be a panel or image and both would have an id of 1 so the game would'nt know which kind of object you want to access if it's not set.

    _texts[2].objectID = ShroudUIText(_texts[2].text,
        _texts[2].fontSize,
        _texts[2].x, _texts[2].y,
        _texts[2].width, _texts[2].height,
        _panels[1].objectID,
        UI.Panel);

    _texts[3].objectID = ShroudUIText(_texts[3].text,
        _texts[3].fontSize,
        _texts[3].x, _texts[3].y,
        _texts[3].width, _texts[3].height,
        _panels[1].objectID,
        UI.Panel);

    ShroudRaycastObject(_texts[1].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false
    ShroudRaycastObject(_texts[2].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false
    ShroudRaycastObject(_texts[3].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false

    -- Suddenly we decide to attach background.jpg image as a child of panel. All child attached to our image will move with it.
    ShroudSetParent(_images[1].objectID, UI.Image, _panels[1].objectID, UI.Panel);

    ShroudSetAnchorMin(_texts[1].objectID, UI.Text, 0.5, 0.5);           --This is where we place the object in relation of the parent, in this case, the middle
    ShroudSetAnchorMax(_texts[1].objectID, UI.Text, 0.5, 0.5);
    ShroudSetPivot(_texts[1].objectID, UI.Text, 0.5, 0.5);               --Setting the point of pivot to middle of the image (where the position and rotation will occur from)
    ShroudSetTextAlignment(_texts[1].objectID, TextAnchor.MiddleCenter); -- This is where the text is displayed within the width and height of the box. MiddleCenter and UpperLeft will be the most used. It goes from LowerLeft to MiddleCenter to UpperRight (uppercenter... middleright... etc)
    ShroudSetTextAlignment(_texts[2].objectID, TextAnchor.UpperLeft);
    ShroudSetTextAlignment(_texts[3].objectID, TextAnchor.LowerLeft);

    ShroudSetColor(_texts[2].objectID, UI.Text, "#FF0000");


    --Lets add a button
    _buttons[1].objectID = ShroudUIButton(
        _buttons[1].x, _buttons[1].y,
        _buttons[1].width, _buttons[1].height,
        _images[1].textureID,
        _panels[1].objectID,
        UI.Panel);
    --Texture argument is needed before setting an object parent optional but can be set to null with the value -1
    --Here we will use the same image as background.jpg (this could have been saved in a different lua table called _textures for efficacity)
    --We set this button on the panel parent

    --We are going to set this button anchor top right of the panel, then set the pivot point of the button itself top right
    --This will make our "hide window" button fixed in the right corner of the panel even if we would increase the size of the panel or reduce it.
    ShroudSetAnchorMin(_buttons[1].objectID, UI.Button, 1.0, 1.0);
    ShroudSetAnchorMax(_buttons[1].objectID, UI.Button, 1.0, 1.0);
    ShroudSetPivot(_buttons[1].objectID, UI.Button, 1.0, 1.0);

    --Lets add a X text on that button
    _texts[3].objectID = ShroudUIText(_texts[4].text,
        _texts[4].fontSize,
        _texts[4].x, _texts[4].y,
        _texts[4].width, _texts[4].height,
        _buttons[1].objectID,
        UI.Button);

    ShroudSetColor(_texts[4].objectID, UI.Text, "#FF0000");              -- and make it red

    ShroudSetAnchorMin(_texts[4].objectID, UI.Text, 0.5, 0.5);           --set the middle of the button as the anchor
    ShroudSetAnchorMax(_texts[4].objectID, UI.Text, 0.5, 0.5);
    ShroudSetPivot(_texts[4].objectID, UI.Text, 0.5, 0.5);               -- set center of our text as our middle
    ShroudSetTextAlignment(_texts[4].objectID, TextAnchor.MiddleCenter); --set text within the text rect in middle also
end

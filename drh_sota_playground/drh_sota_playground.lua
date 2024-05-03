-- Do not change anything below this line
local ScriptName = "DRH Playground";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "Playground for Testing and New Functions";
local IconPath = "drh_sota_assets/tango/categories/applications-system.png";

--- @type number
local FRAME_SKIP = 120

--- @type number
local MAX_MS_COUNT = 5

--- @type table
local _ms_times = {}

--- @type number
local _frame_skip_count = 1

--- @type number
local _ms_count = 1

--- @type number
local old_time = 0.0

--- @type boolean
local _Started = false

--- @type boolean
local _Initialized = false

--- @type boolean
local _Active = false

--- @type boolean
local _Halted = false

--- @type number
local _test_skip_count_1 = 0

--- @type number
local _avg_fps = 0

--- @type table
local _text_area_1 = {}

-- This function is called when the scripts are started
function ShroudOnStart()
    DRH.debugMessage(ScriptName, "Playground " .. Version)
    _Started = true
    _Halted = false

    --- create_text_area_1()
    --- show_text_area_1()
end

function ShroudOnDisableScript()
    _Halted = true
    _Active = false
end

-- This function is called for each frame
function ShroudOnUpdate()
    if not DRH.Ready then
        return
    end

    if not _Active then
        -- We make sure that ShroudOnStart was called
        if not _Started then
            return
        end

        -- We wait at least until the server time is available
        if not _Initialized then
            if not ShroudServerTime then
                DRH.debugMessage(ScriptName, "Shroud Server Time still missing!")
                return
            end
            _Initialized = true;
        end

        -- At this point we are done with the startup
        if not _Halted then
            _Active = true
        end

        return
    end

    if false == true then
        if _frame_skip_count > FRAME_SKIP then
            _frame_skip_count = 1
            print_avg_fps(_ms_times)

            if _ms_count > MAX_MS_COUNT then
                _ms_count = 1
            end

            local new_time = os.time()
            _ms_times[_ms_count] = new_time - old_time
            _ms_count = _ms_count + 1
            old_time = new_time
        end
        _frame_skip_count = _frame_skip_count + 1

        _test_skip_count_1 = _test_skip_count_1 + 1
        if _test_skip_count_1 > 1000 then
            _test_skip_count_1 = 0

            local props = {}
            props[DRH.PROPERTY_NAME_KEY] = "global"

            local screen_x, screen_y = DRH.ui_checks.update_screen_size()

            props.fps_count = _avg_fps
            props.screen_x = screen_x
            props.screen_y = screen_y

            DRH.infoMessage(ScriptName, props[DRH.PROPERTY_NAME_KEY])

            for i, line in pairs(props) do
                DRH.infoMessage(ScriptName, i .. ": " .. line)
            end

            DRH.properties.save(ScriptName, DRH.DEFAULT_PROPERTIES_PATH, props)
        end

        if _test_skip_count_1 == 750 then
            local props2 = {}
            DRH.properties.load(ScriptName, DRH.DEFAULT_PROPERTIES_PATH, props2)
        end
    end
    -- After pressing the X button of our window, pressing F8 will show it again
    if ShroudGetOnKeyUp("F8") then
        show_text_area_1()
    end
end

function print_avg_fps(ms_times)
    i = 1
    t = 0
    c = 0
    while i < MAX_MS_COUNT and ms_times[i] do
        t_i = ms_times[i]
        t = t + (t_i / FRAME_SKIP)
        c = c + 1
        i = i + 1
    end

    if t > 0 then
        _avg_fps = (c / t)
        DRH.debugMessage(ScriptName, "FPS: " .. _avg_fps)
    end
end

function create_text_area_1()
    _text_area_1.panels = {
        { x = 300.0, y = 300.0, width = 1024, height = 768, objectID = -1, parentID = -1 }
    }

    _text_area_1.images = {
        { sprite = DRH.DEFAULT_ASSETS_PATH .. "/bg.png", x = 0, y = 75.0, width = 1024, height = 768, textureID = -1, objectID = -1, parentID = -1 },
        { sprite = IconPath,                             x = 0, y = 5.0,  width = 24,   height = 24,  textureID = -1, objectID = -1, parentID = -1 }
    }

    _text_area_1.texts = {
        { text = "This is just a demo!", x = 0, y = 0, width = 1000, height = 32, fontSize = 24, objectID = -1, parentID = -1 },
        { text = "Click and drag me!",   x = 0, y = 0, width = 1000, height = 32, fontSize = 24, objectID = -1, parentID = -1 },
        { text = "Click and drag me!",   x = 0, y = 0, width = 1000, height = 32, fontSize = 24, objectID = -1, parentID = -1 },
        { text = "X",                    x = 0, y = 0, width = 32,   height = 32, fontSize = 24, objectID = -1, parentID = -1 }
    }

    _text_area_1.buttons = {
        { x = 0, y = 0, width = 32, height = 32, objectID = -1, parentID = -1 }
    }

    local _panels = _text_area_1.panels
    local _images = _text_area_1.images
    local _texts = _text_area_1.texts
    local _buttons = _text_area_1.buttons

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

function show_text_area_1()
    ShroudShowObject(_text_area_1.panels[1].objectID, UI.Panel);
end

function hide_text_area_1()
    ShroudHideObject(_text_area_1.panels[1].objectID, UI.Panel);
end

function ShroudOnMouseClick(objectID, objectKind)
    DRH.infoMessage(ScriptName, string.format("MouseClick: %s - %s", tostring(objectID), tostring(objectKind)));

    --Here we check for our button click and hide the whole window when pressed
    if objectKind == UI.Button and objectID == _text_area_1.buttons[1].objectID then
        hide_text_area_1()
    end
end

--function ShroudOnMouseOver(objectID, objectKind)
--    DRH.infoMessage(ScriptName, string.format("MouseOver: %s - %s", tostring(objectID), tostring(objectKind)));
--    --could highlight stuff here when mouse is over or whatever you want
--end
--
function ShroudOnMouseOut(objectID, objectKind)
    if true then
        return
    end

    DRH.infoMessage(ScriptName, string.format("MouseOut: %s - %s", tostring(objectID), tostring(objectKind)));
    --to know when mouse has left the object

    local buff_count = ShroudGetBuffCount()

    for i = 1, buff_count do
        local buff_name = ShroudGetBuffName(i)
        local buff_remaining = ShroudGetBuffTimeRemaining(i)
        local buff_description = ShroudGetBuffDescription(i)

        DRH.infoMessage(ScriptName, buff_name .. " (" .. buff_description .. ") " .. buff_remaining .. " remaining")
    end

    local player_buff = ShroudGetPlayerBuff()
    for _, v in pairs(player_buff) do
        DRH.infoMessage(ScriptName, "v=" .. v.RuneName)
        for _, w in pairs(v.Effects) do
            DRH.infoMessage(ScriptName,
                w.Description ..
                "(" .. w.value .. ") -> " .. w.CurrentDuration .. "/" .. w.TotalDuration .. " Tick " .. w.TotalTick)
        end
    end
end

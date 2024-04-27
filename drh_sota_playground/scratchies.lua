function ShroudOnStart()
    local currentDeck = ShroudCurrentDeck();

    ConsoleLog(string.format("Current Deck ID: %s Name: %s", currentDeck.id, currentDeck.name));

    local cardList = ShroudGetDeckCardList("Blades");

    if cardList then
        for i,v in pairs(cardList) do
            ConsoleLog(string.format("Deck Card ID: %s Name: %s Qty: %s", v.id, v.name, v.quantity));
        end
    end

    local deckList = ShroudDeckList();

    if deckList then
        for i,v in pairs(deckList) do
            ConsoleLog(string.format("Deck Name: %s Qty Cards: %s", v.name, v.quantity));
        end
    end

    local emoteList = ShroudEmoteList()

    if emoteList then
        for i,v in pairs(emoteList) do
            ConsoleLog(string.format("Emote Name: %s ", v));
        end
    end

    ShroudPlayEmote("Akimbo");
end

function ShroudOnStart()
    ShroudConsoleLog("Scene: " .. ShroudGetCurrentSceneNameRaw()); -- Display raw scene name
    ShroudConsoleLog("--- Pet Info:");
    DisplayPetInfo(); -- Display pet info
    ShroudConsoleLog("--- Pet Buff:");
    DisplayBuff(true); -- Display pet buff
    ShroudConsoleLog("--- Player Buff:");
    DisplayBuff(); -- Display player buff
end

function DisplayPetInfo()
    --Display pet informations, wont show anything if there is no pet
    local _petInfo = ShroudGetPetInfo();
    if _petInfo then
        ShroudConsoleLog("Name: " .. _petInfo.name);
        ShroudConsoleLog("Level: " .. _petInfo.level);
        ShroudConsoleLog("Strength: " .. round(_petInfo.strength,0));
        ShroudConsoleLog("Dexterity: " .. round(_petInfo.dexterity,0));
        ShroudConsoleLog("Intelligence: " .. round(_petInfo.intelligence,0));
        ShroudConsoleLog("Health: " .. _petInfo.currentHealth .. "/" .. _petInfo.maxHealth);
        ShroudConsoleLog("Health Regen: " .. (round(_petInfo.healthRegen,2)*100) .. "% Combat: " .. (round(_petInfo.healthRegenCombat,2) * 100) .. "%");
        ShroudConsoleLog("Attack Speed: " .. (round(_petInfo.attackSpeed,2) * 100) .. "%");
        ShroudConsoleLog("Resistance: " .. _petInfo.resist);

        ShroudConsoleLog("Magic Resistance: " .. _petInfo.magicResist);
        ShroudConsoleLog("Absorption: " .. (round(_petInfo.absorb,2) * 100) .. "%");
        ShroudConsoleLog("Move Speed: " .. _petInfo.moveSpeed .. " Rate: " .. (round(_petInfo.moveRate,2)*100) .. "%");
        ShroudConsoleLog("Strength Power: " .. _petInfo.strengthPower);
        ShroudConsoleLog("Taunt Power: " .. _petInfo.tauntPower);
        ShroudConsoleLog("Critical Hit Chance: " .. round(_petInfo.criticalHit,2) .. "%");
    end
end

function DisplayBuff(isPet)
    local _buffs;

    if isPet then
        _buffs = ShroudGetPetBuff();
    else
        _buffs = ShroudGetPlayerBuff();
    end

    --Display pet buff and their effects, wont show anything if there is no buff
    if _buffs then
        for _,v in pairs(_buffs) do
            ShroudConsoleLog(v.runeName);
            for _,y in pairs(v.effects) do
                ShroudConsoleLog(y.value .. " " .. y.description .. " Duration: " .. y.currentDuration .. "/" .. y.totalDuration .. " Ticks: " .. y.totalTick);
            end
        end
    end
end

--helper function to round numbers to X decimal

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end


--[[ Lua Demo Example for Shroud of the Avatar

A concept to understand before starting (Parent and child):

Imagine a genealogy tree, where there is parent and their child and grand child linked together by a line, this is the same.
We use this method to attach object to each other and keep track of what belong to what, also keep track of depth (image or text shown over each other).
We can then, for example, move a parent position and all its child and grand childs will follow since they are attached to that parent.
Hiding a parent object would also hide all of its child.
Setting a child on a parent will make the child show in front of that parent UI element and any previous child of that element.
If you want a child to show over another child, set that child as the parent of that other child.
--]]


-- Lua Demo Example

--First we create an array of a UI element that will references all our images and attributes.
--The value objectID, parentID and depth will be returned when you create one of this UI element: Panel, Image, Text or Button.
--An ID with -1 mean its null or 'nil' in lua language. It's very important to save this value if you want to keep tracks of your UI elements.
--Losing this mean you wont have access to that UI element anymore and won't be able to change position or image etc later.
--The reason why each kind of object is separated here is to keep track what kind of UI it is. You know when it is a UI.Panel or UI.Image for example. (See the new UI enum on SOTA API doc)

local _panels = {{ x = 300.0, y = 300.0, width = 622, height = 700, objectID = -1, parendID = -1}}
local _images = {{ sprite = "ShroudLuaTest/Background.jpg", x = 5.0, y = 75.0, width = 612, height = 612, textureID = -1, objectID = -1, parentID = -1 },
                 { sprite = "ShroudLuaTest/Logo.png", x = 100.0, y = 100.0, width = 387, height = 65, textureID = -1, objectID = -1, parentID = -1 }}


local _texts = {{ text = "This is just a demo!", x = 0.0, y = 0.0, width = 300, height = 50, fontSize = 30, objectID = -1, parentID = -1 },
                { text = "Click and drag me!", x = 0.0, y = 0.0, width = 300, height = 50, fontSize = 30, objectID = -1, parentID = -1 },
                { text = "X", x = 0.0, y = 0.0, width = 50, height = 50, fontSize = 30, objectID = -1, parentID = -1 }}

local _buttons = {{ x = 0.0, y = 0.0, width = 50, height = 50, objectID = -1, parentID = -1 }}

--Here we start creating the UI elements
--I did this on ShroudOnStart() function but it could be done anywhere.
function ShroudOnStart()
    -- Adding a new Panel and making sure we save the returned ID

    _panels[1].objectID = ShroudUIPanel(_panels[1].x,
            _panels[1].y,
            _panels[1].width,
            _panels[1].height);

    -- Adding Images and saving IDs, same way as you did before with textures

    _images[1].textureID = ShroudLoadTexture(_images[1].sprite);

    _images[1].objectID = ShroudUIImage(_images[1].x,
            _images[1].y,
            _images[1].width,
            _images[1].height,
            _images[1].textureID);

    _images[2].textureID = ShroudLoadTexture(_images[2].sprite);

    _images[2].objectID = ShroudUIImage(_images[2].x,
            _images[2].y,
            _images[2].width,
            _images[2].height,
            _images[2].textureID);

    --Here we set the logo as a child of the background, so later, if we move the background, the childs will follow.
    --If you are not familiar with parent and chi
    ShroudSetParent(_images[2].objectID, UI.Image, _images[1].objectID, UI.Image);

    -- Adding texts

    _texts[1].objectID = ShroudUIText(_texts[1].text,
            _texts[1].fontSize,
            _texts[1].x,
            _texts[1].y,
            _texts[1].width,
            _texts[1].height,
            _images[1].objectID, --you can also set the parent directly to a previously created object. objectID and depth are optional parameters
            UI.Image); --Here is the defined UI element of that _images[1].objectID.
    -- It's important to set this with the object ID we want to access because object IDs are saved by element kind.
    -- It could be a panel or image and both would have an id of 1 so the game would'nt know which kind of object you want to access if it's not set.


    _texts[2].objectID = ShroudUIText(_texts[2].text,
            _texts[2].fontSize,
            _texts[2].x,
            _texts[2].y,
            _texts[2].width,
            _texts[2].height,
            _panels[1].objectID,
            UI.Panel);

    ShroudRaycastObject(_texts[2].objectID, UI.Text, false); -- This text "drag me" which will be shown over the panel would have blocked our click to move the panel if this was not set to false

    -- Suddenly we decide to attach background.jpg image as a child of panel. All child attached to our image will move with it.
    ShroudSetParent(_images[1].objectID, UI.Image, _panels[1].objectID, UI.Panel);

    ShroudSetAnchorMin(_texts[1].objectID, UI.Text, 0.5, 0.5); --This is where we place the object in relation of the parent, in this case, the middle
    ShroudSetAnchorMax(_texts[1].objectID, UI.Text, 0.5, 0.5);
    ShroudSetPivot(_texts[1].objectID, UI.Text, 0.5, 0.5); --Setting the point of pivot to middle of the image (where the position and rotation will occur from)
    ShroudSetTextAlignment(_texts[1].objectID, TextAnchor.MiddleCenter); -- This is where the text is displayed within the width and height of the box. MiddleCenter and UpperLeft will be the most used. It goes from LowerLeft to MiddleCenter to UpperRight (uppercenter... middleright... etc)

    ShroudSetTextAlignment(_texts[2].objectID, TextAnchor.UpperLeft);
    ShroudSetColor(_texts[2].objectID, UI.Text, "#FF0000");


    --Lets add a button
    _buttons[1].objectID = ShroudUIButton(_buttons[1].x,
            _buttons[1].y,
            _buttons[1].width,
            _buttons[1].height,
            _images[1].textureID, --Texture argument is needed before setting an object parent optional but can be set to null with the value -1
    --Here we will use the same image as background.jpg (this could have been saved in a different lua table called _textures for efficacity)
            _panels[1].objectID, --We set this button on the panel parent
            UI.Panel);

    --We are going to set this button anchor top right of the panel, then set the pivot point of the button itself top right
    --This will make our "hide window" button fixed in the right corner of the panel even if we would increase the size of the panel or reduce it.
    ShroudSetAnchorMin(_buttons[1].objectID, UI.Button, 1.0,1.0);
    ShroudSetAnchorMax(_buttons[1].objectID, UI.Button, 1.0,1.0);
    ShroudSetPivot(_buttons[1].objectID, UI.Button, 1.0, 1.0);

    --Lets add a X text on that button
    _texts[3].objectID = ShroudUIText(_texts[3].text,
            _texts[3].fontSize,
            _texts[3].x,
            _texts[3].y,
            _texts[3].width,
            _texts[3].height,
            _buttons[1].objectID,
            UI.Button);

    ShroudSetColor(_texts[3].objectID, UI.Text, "#FF0000"); -- and make it red

    ShroudSetAnchorMin(_texts[3].objectID, UI.Text, 0.5, 0.5); --set the middle of the button as the anchor
    ShroudSetAnchorMax(_texts[3].objectID, UI.Text, 0.5, 0.5);
    ShroudSetPivot(_texts[3].objectID, UI.Text, 0.5, 0.5); -- set center of our text as our middle
    ShroudSetTextAlignment(_texts[3].objectID, TextAnchor.MiddleCenter); --set text within the text rect in middle also
end

--some variable for our little animation of the logo
local goUp = false;
local goUpAndDownMax = 0;

--Here we made a small animation of the logo moving up and down in the background.
function ShroudOnUpdate()
    -- After pressing the X button of our window, pressing F8 will show it again
    if ShroudGetOnKeyUp("F8") then
        ShroudShowObject(_panels[1].objectID, UI.Panel);
    end

    --Make note that our animation will continue to play even if the window is hidden. Might want to set a bool on this to enable/disable number of codes running
    if goUp then
        _images[2].y = _images[2].y + 1;
        ShroudSetPosition(_images[2].objectID, UI.Image, _images[2].x, _images[2].y);

        goUpAndDownMax = goUpAndDownMax + 1;
        if goUpAndDownMax == 60 then
            goUp = false;
            goUpAndDownMax = 0;
        end
    else
        _images[2].y = _images[2].y - 1;
        ShroudSetPosition(_images[2].objectID, UI.Image, _images[2].x, _images[2].y);

        goUpAndDownMax = goUpAndDownMax + 1;
        if goUpAndDownMax == 60 then
            goUp = true;
            goUpAndDownMax = 0;
        end
    end

end

function ShroudOnMouseClick(objectID, objectKind)
    ConsoleLog(string.format("MouseClick: %s - %s", tostring(objectID), tostring(objectKind)));

    --Here we check for our button click and hide the whole window when pressed
    if objectKind == UI.Button and objectID == _buttons[1].objectID then
        ShroudHideObject(_panels[1].objectID, UI.Panel);
    end
end

function ShroudOnMouseOver(objectID, objectKind)
    ConsoleLog(string.format("MouseOver: %s - %s", tostring(objectID), tostring(objectKind)));
    --could highlight stuff here when mouse is over or whatever you want
end

function ShroudOnMouseOut(objectID, objectKind)
    ConsoleLog(string.format("MouseOut: %s - %s", tostring(objectID), tostring(objectKind)));
    --to know when mouse has left the object
end
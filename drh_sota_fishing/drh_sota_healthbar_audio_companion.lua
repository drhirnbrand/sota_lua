local DEBUG = true;

--- This is a structure that stores the main information objects
---
local HEALTHBAR_AUDIO_COMPANION = HEALTHBAR_AUDIO_COMPANION or {
    -- Audio-Files
    audioSpec = {
        { filename = "drh_assets/low_health.wav", name = "LowHealthWarning" },
        { filename = "drh_assets/low_focus.wav", name = "LowFocusWarning" };
    };

    channelsCurrent = {};

    audioCurrent = {};

    ready = false;
}

-- Do not change anything below this line

local ScriptName = "DRH Audio Companion";
local Version = "0.1";
local CreatorName = "Doktor Hirnbrand";
local Description = "Audible warning healthbar companion script";
local IconPath = "drh_assets/healthbar_audio_icon.png";

local SOUND_LOW_HEALTH = 1;
local SOUND_LOW_FOCUS = 2;

local LogPrefixInfo = "[0000ff]drh_sota_healthbar_audio_companion: "
local LogPrefixWarn = "[ff0000]drh_sota_healthbar_audio_companion:: "
local LogPrefixDebug = "[ff0000]DEBUG drh_sota_healthbar_audio_companion: "
local LogSuffix = "[-]"


-- Executed when SOTA Lua scripting is started
function ShroudOnStart()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Health Monitor Audio Companion %s" .. LogSuffix, Version));

    -- Load textures and other assets
    loadAudioAssets();

    sounds = ShroudListSound();
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Sound List: %s entries." .. LogSuffix, #sounds))
    for index = 1, #sounds do
        ShroudConsoleLog(sounds[index]);
    end

    ShroudConsoleLog(string.format(LogPrefixInfo .. "Started!" .. LogSuffix))

    HEALTHBAR_AUDIO_COMPANION.ready = true;

end

function ShroudOnSceneUnloaded()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Scene unloading..." .. LogSuffix));
    updateAndSavePositions()
end

function ShroudOnLogout()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Logout..." .. LogSuffix));
    updateAndSavePositions()
end

--function ShroudOnDisableScript()
--
--end


function ShroudOnUpdate()
    if not HEALTHBAR_AUDIO_COMPANION.ready then
        return
    end

    --local playerHealth = ShroudPlayerCurrentHealth;
    --local playerFocus = ShroudPlayerCurrentFocus;
    local playerHealth = ShroudGetStatValueByNumber(14);
    local playerMaxHealth = ShroudGetStatValueByNumber(30);
    local playerFocus = ShroudGetStatValueByNumber(13)
    local playerMaxFocus = ShroudGetStatValueByNumber(27);

end



--
-- Asset loading (Textures, Images, etc)
--
function loadAudioAssets()
    for index = 1, #HEALTHBAR_AUDIO_COMPANION.audioSpec do
        loadAudioAsset(index);
    end
    ShroudConsoleLog(string.format(LogPrefixInfo .. "%s Audio Asset(s) loaded." .. LogSuffix, #HEALTHBAR_AUDIO_COMPANION.audioCurrent))
end

function loadAudioAsset(index)
    local filename = HEALTHBAR_AUDIO_COMPANION.audioSpec[index].filename;
    local name = HEALTHBAR_AUDIO_COMPANION.audioSpec[index].name;
    local audio = {}

    audio.id = ShroudLoadSound(filename, AudioType.WAV);
    HEALTHBAR_AUDIO_COMPANION.audioCurrent[index] = audio;

    if audio.id == -1 then
        --        ShroudConsoleLog(string.format(LogPrefixWarn .. "'%s' not found (file: %s)!" .. LogSuffix, name, filename));
        ShroudConsoleLog(string.format(LogPrefixWarn .. "'%s' not found!" .. LogSuffix, name));
    else
        if DEBUG then
            ShroudConsoleLog(string.format(LogPrefixDebug .. " Asset '%s' (file: %s) loaded: %s." .. LogSuffix, name, filename, tostring(audio.id)));
        end
    end
end


local DEBUG = false;

local LOW_HEALTH_FACTOR = 0.33;
local LOW_FOCUS_FACTOR = 0.33;
local HIGH_HEALTH_FACTOR = 0.5
local HIGH_FOCUS_FACTOR = 0.5;

local LOW_HEALTH_VOLUME = 80;
local LOW_FOCUS_VOLUME = 80;

local REPEAT_INTERVAL_MS = 5000;

--- This is a structure that stores the main information objects
---
local HEALTHBAR_AUDIO_COMPANION = HEALTHBAR_AUDIO_COMPANION or {
    -- Audio-Files
    audioSpec = {
        { filename = "drh_assets/low_health.wav", name = "low_health" },
        { filename = "drh_assets/low_focus.wav", name = "low_focus" };
    };

    channelsCurrent = {};

    audioCurrent = {};

    ready = false;
    soundsLoaded = false;
}

-- Do not change anything below this line

local ScriptName = "DRH Audio Companion";
local Version = "%%%VERSION%%%";
local CreatorName = "Doktor Hirnbrand";
local Description = "Audible warning healthbar companion script";
local IconPath = "drh_assets/healthbar_audio_icon.png";

local SOUND_LOW_HEALTH = 1;
local SOUND_LOW_FOCUS = 2;

local LogPrefixInfo = "[0000ff]drh_sota_healthbar_audio_companion: "
local LogPrefixWarn = "[ff0000]drh_sota_healthbar_audio_companion:: "
local LogPrefixDebug = "[ff0000]DEBUG drh_sota_healthbar_audio_companion: "
local LogSuffix = "[-]"

local timestampLowHealthState;
local timestampLowFocusState;
local activeIndex = -1;

-- Executed when SOTA Lua scripting is started
function ShroudOnStart()
    HEALTHBAR_AUDIO_COMPANION.ready = false;
    HEALTHBAR_AUDIO_COMPANION.soundsLoaded = false;
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Health Monitor Audio Companion %s" .. LogSuffix, Version));

    -- Load textures and other assets
    loadAudioAssets();

    ShroudConsoleLog(string.format(LogPrefixInfo .. "Started!" .. LogSuffix))

    local now = ShroudTime * 1000;
    timestampLowFocusState = now;
    timestampLowHealthState = now;

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

function ShroudOnDisableScript()
    ShroudListSoundReset();
    HEALTHBAR_AUDIO_COMPANION.ready = false;
    HEALTHBAR_AUDIO_COMPANION.soundsLoaded = false;
end

function checkForSoundsLoaded()
    local sounds = ShroudListSound();

    lowFocusSpec = HEALTHBAR_AUDIO_COMPANION.audioSpec[SOUND_LOW_FOCUS];
    lowHealthSpec = HEALTHBAR_AUDIO_COMPANION.audioSpec[SOUND_LOW_HEALTH];

    for index = 1, #sounds do
        name = sounds[index];

        if name == lowFocusSpec.name then
            local audioLowFocus = {};
            audioLowFocus.index = index;
            audioLowFocus.name = lowFocusSpec.name;
            audioLowFocus.volume = LOW_FOCUS_VOLUME;
            HEALTHBAR_AUDIO_COMPANION.audioCurrent[SOUND_LOW_FOCUS] = audioLowFocus;
        end

        if name == lowHealthSpec.name then
            local audioLowHealth = {};
            audioLowHealth.index = index;
            audioLowHealth.name = lowHealthSpec.name;
            audioLowHealth.volume = LOW_HEALTH_VOLUME;
            HEALTHBAR_AUDIO_COMPANION.audioCurrent[SOUND_LOW_HEALTH] = audioLowHealth;
        end
    end

    if #HEALTHBAR_AUDIO_COMPANION.audioCurrent == #HEALTHBAR_AUDIO_COMPANION.audioSpec then
        ShroudConsoleLog(string.format(LogPrefixInfo .. "Sounds loaded: %s Asset(s) ready." .. LogSuffix, #HEALTHBAR_AUDIO_COMPANION.audioCurrent))
        HEALTHBAR_AUDIO_COMPANION.soundsLoaded = true;
    end
end
function ShroudOnUpdate()
    if not HEALTHBAR_AUDIO_COMPANION.ready then
        return;
    end

    if not HEALTHBAR_AUDIO_COMPANION.soundsLoaded then
        checkForSoundsLoaded();
        return;
    end


    lowFocusSound = HEALTHBAR_AUDIO_COMPANION.audioCurrent[SOUND_LOW_FOCUS];
    lowHealthSound = HEALTHBAR_AUDIO_COMPANION.audioCurrent[SOUND_LOW_HEALTH];

    --local playerHealth = ShroudPlayerCurrentHealth;
    --local playerFocus = ShroudPlayerCurrentFocus;
    local playerHealth = ShroudGetStatValueByNumber(14);
    local playerMaxHealth = ShroudGetStatValueByNumber(30);
    local playerFocus = ShroudGetStatValueByNumber(13)
    local playerMaxFocus = ShroudGetStatValueByNumber(27);

    healthFactor = playerHealth / playerMaxHealth;
    focusFactor = playerFocus / playerMaxFocus;

    if healthFactor < LOW_HEALTH_FACTOR and not HEALTHBAR_AUDIO_COMPANION.lowHealthState == true then
        HEALTHBAR_AUDIO_COMPANION.lowHealthState = true
    end
    if focusFactor < LOW_FOCUS_FACTOR and not HEALTHBAR_AUDIO_COMPANION.lowFocusState == true then
        HEALTHBAR_AUDIO_COMPANION.lowFocusState = true;
    end

    if healthFactor > HIGH_HEALTH_FACTOR and HEALTHBAR_AUDIO_COMPANION.lowHealthState == true then
        HEALTHBAR_AUDIO_COMPANION.lowHealthState = false;
    end
    if focusFactor > HIGH_FOCUS_FACTOR and HEALTHBAR_AUDIO_COMPANION.lowFocusState == true then
        HEALTHBAR_AUDIO_COMPANION.lowFocusState = false;
    end

    local now = ShroudTime * 1000;

    activeIndex = -1;

    if HEALTHBAR_AUDIO_COMPANION.lowHealthState then
        local elapsedTime = now - timestampLowHealthState;

        if elapsedTime > REPEAT_INTERVAL_MS then
            ShroudConsoleLog(string.format(LogPrefixInfo .. "Triggering on Low Health: %s" .. LogSuffix, healthFactor));
            timestampLowHealthState = now;
            activeIndex = SOUND_LOW_HEALTH;
        end
    end

    if HEALTHBAR_AUDIO_COMPANION.lowFocusState then
        local elapsedTime = now - timestampLowFocusState;

        if elapsedTime > REPEAT_INTERVAL_MS then
            ShroudConsoleLog(string.format(LogPrefixInfo .. "Triggering on Low Focus: %s" .. LogSuffix, focusFactor));
            timestampLowFocusState = now;
            activeIndex = SOUND_LOW_FOCUS;
        end
    end



    if activeIndex > 0 then
        local audioCurrent = HEALTHBAR_AUDIO_COMPANION.audioCurrent[activeIndex];
        local soundIndex = audioCurrent.index;
        ShroudConsoleLog(string.format(LogPrefixInfo .. "Playing sound %s (index %s/ sound index %s) with volume %s" .. LogSuffix, audioCurrent.name, audioCurrent.index, soundIndex, audioCurrent.volume));
        local channel = ShroudPlaySound(soundIndex, audioCurrent.volume);
        ShroudConsoleLog(string.format(LogPrefixInfo .. "on channel %s" .. LogSuffix, channel));
        audioCurrent.channel = channel;
    end

end



--
-- Asset loading (Textures, Images, etc)
--
function loadAudioAssets()
    for index = 1, #HEALTHBAR_AUDIO_COMPANION.audioSpec do
        loadAudioAsset(index);
    end
end

function loadAudioAsset(index)
    local filename = HEALTHBAR_AUDIO_COMPANION.audioSpec[index].filename;
    local name = HEALTHBAR_AUDIO_COMPANION.audioSpec[index].name;

    result = ShroudLoadSound(filename, AudioType.WAV);
    if not result then
        ShroudConsoleLog(string.format(LogPrefixWarn .. "Sound '%s' not found (file: %s)!" .. LogSuffix, name, filename));
        return
    end

    if DEBUG then
        ShroudConsoleLog(string.format(LogPrefixDebug .. "Sound '%s' (file: %s) loaded." .. LogSuffix, name, filename));
    end
end


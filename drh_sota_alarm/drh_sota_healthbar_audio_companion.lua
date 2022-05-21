local DEBUG = false;
local INDEX_ADJUSTMENT = -1;

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
        { filename = "drh_sota_assets/low_health.wav", name = "low_health" },
        { filename = "drh_sota_assets/low_focus.wav", name = "low_focus" };
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
local IconPath = "drh_sota_assets/healthbar_audio_icon.png";

local SOUND_LOW_HEALTH = 1;
local SOUND_LOW_FOCUS = 2;

local LogPrefixInfo = "[0000ff]drh_sota_healthbar_audio_companion: "
local LogPrefixWarn = "[ff0000]drh_sota_healthbar_audio_companion:: "
local LogPrefixDebug = "[ff0000]DEBUG drh_sota_healthbar_audio_companion: "
local LogSuffix = "[-]"

local timestampLowHealthState;
local timestampLowFocusState;
local now;

local activeIndex = -1;
local init = false;
local elapsedTime = 0;

local healthFactor = 0;
local focusFactor = 0;
local lowHealthSound;
local lowFocusSound;

-- Executed when SOTA Lua scripting is started
function ShroudOnStart()
    HEALTHBAR_AUDIO_COMPANION.ready = false;
    HEALTHBAR_AUDIO_COMPANION.soundsLoaded = false;
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Health Monitor Audio Companion %s" .. LogSuffix, Version));

    -- Load textures and other assets
    loadAudioAssets();

    ShroudConsoleLog(string.format(LogPrefixInfo .. "Started!" .. LogSuffix))

    timestampLowFocusState = 0;
    timestampLowHealthState = 0;

    HEALTHBAR_AUDIO_COMPANION.ready = true;
end

function ShroudOnSceneUnloaded()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Scene unloading..." .. LogSuffix));
end

function ShroudOnLogout()
    ShroudConsoleLog(string.format(LogPrefixInfo .. "Logout..." .. LogSuffix));
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
    if not init then
        if not ShroudServerTime then
            return
        end
        init = true;
    end

    if not HEALTHBAR_AUDIO_COMPANION.ready then
        return;
    end

    if not HEALTHBAR_AUDIO_COMPANION.soundsLoaded then
        checkForSoundsLoaded();
        return;
    end

    if not ShroudGetPlayerCombatMode() then
        return;
    end

    lowFocusSound = HEALTHBAR_AUDIO_COMPANION.audioCurrent[SOUND_LOW_FOCUS];
    lowHealthSound = HEALTHBAR_AUDIO_COMPANION.audioCurrent[SOUND_LOW_HEALTH];

    healthFactor = ShroudGetStatValueByNumber(14) / ShroudGetStatValueByNumber(30);
    focusFactor = ShroudGetStatValueByNumber(13) / ShroudGetStatValueByNumber(27);

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

    now = ShroudTime * 1000;

    activeIndex = -1;
    elapsedTime = 0;

    if HEALTHBAR_AUDIO_COMPANION.lowFocusState then
        elapsedTime = now - timestampLowFocusState;

        if elapsedTime > REPEAT_INTERVAL_MS then
            ShroudConsoleLog(string.format(LogPrefixInfo .. "You are low on focus! (%.2f %% < %.2f %%)" .. LogSuffix, focusFactor * 100, LOW_FOCUS_FACTOR * 100));
            timestampLowFocusState = now;
            activeIndex = SOUND_LOW_FOCUS;
        end
    end

    if HEALTHBAR_AUDIO_COMPANION.lowHealthState then
        elapsedTime = now - timestampLowHealthState;

        if elapsedTime > REPEAT_INTERVAL_MS then
            ShroudConsoleLog(string.format(LogPrefixInfo .. "Your health is low! (%.2f %% < %.2f %%)" .. LogSuffix, healthFactor * 100, LOW_HEALTH_FACTOR * 100));
            timestampLowHealthState = now;
            activeIndex = SOUND_LOW_HEALTH;
        end
    end

    if activeIndex > 0 then
        local audioCurrent = HEALTHBAR_AUDIO_COMPANION.audioCurrent[activeIndex];
        local soundIndex = audioCurrent.index;
        local channel = ShroudPlaySound(soundIndex + INDEX_ADJUSTMENT, audioCurrent.volume);
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


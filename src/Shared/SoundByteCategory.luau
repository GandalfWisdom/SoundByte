--!strict
local require = require(script.Parent.loader).load(script);
local Maid = require("Maid");

local SoundCategory = {};
SoundCategory.__index = SoundCategory;
SoundCategory.ClassName = "SoundCategory";

--Variables
local VOLUME_RANGE: NumberRange = NumberRange.new(0, 100);

export type SoundCategory = typeof(setmetatable(
    {} :: {
        _maid: Maid.Maid,
        Name: string,
        Volume: number,
    },
    {} :: typeof({ __index = SoundCategory })
));

--[=[
    Constructs a new SoundCategory object.
    @param category_name string -- The name of the category to add.
    @param volume_number? -- Set the volume to a starting value. Default is 50; or half of the max value in VOLUME_RANGE.
    @return SoundCategory
]=]
function SoundCategory.new(category_name: string, volume_number: number?): SoundCategory
    local self: SoundCategory = setmetatable({} :: any, SoundCategory);
    self._maid = Maid.new();

    self.Name = assert(category_name, "No category name given to class parameter!");
    self.Volume = if (volume_number) then (math.clamp(volume_number, VOLUME_RANGE.Min, VOLUME_RANGE.Max)) else (VOLUME_RANGE.Min + VOLUME_RANGE.Max) / 2; 

    return self;
end;

--[=[
    Increase volume by set number.
    @param increment_amount number -- The number to increment the volume by
    @return boolean Returns a boolean. True if sound increment attempts to exceed max volume, else false. Useful for settings menu effects.
]=]
function SoundCategory.VolumeUp(self: SoundCategory, increment_amount: number): boolean
    local new_volume_value: number = self.Volume + increment_amount;
    self.Volume = math.clamp(math.round(new_volume_value), VOLUME_RANGE.Min, VOLUME_RANGE.Max);
    return (new_volume_value > VOLUME_RANGE.Max);
end;
--[=[
    Decrease volume by set number.
    @param increment_amount number -- The number to increment the volume by
    @return boolean Returns a boolean. True if sound increment attempts to fall below min volume, else false. Useful for settings menu effects.
]=]
function SoundCategory.VolumeDown(self: SoundCategory, increment_amount: number): boolean
    local new_volume_value: number = self.Volume - increment_amount;
    self.Volume = math.clamp(math.round(new_volume_value), VOLUME_RANGE.Min, VOLUME_RANGE.Max);
    return (new_volume_value < VOLUME_RANGE.Min);
end;
--[=[
    Sets the volume to specified value.
    @param volume number -- The number to set volume to.
]=]
function SoundCategory.SetVolume(self: SoundCategory, volume: number): ()
    self.Volume = math.clamp(volume, VOLUME_RANGE.Min, VOLUME_RANGE.Max);
end;
--[=[
    Returns the multiplied decimal value to be used by a sound object.
    @return number
]=]
function SoundCategory.VolumeMult(self: SoundCategory): number
    if (self.Volume < 1) then return self.Volume; end; -- Returns the base volume modifier if volume is set as a decimal number.
    return (self.Volume / VOLUME_RANGE.Max) * 2; 
end;

--[=[
    Cleans up the SoundCategory object and sets it's metatable to nil.
]=]
function SoundCategory.Destroy(self: SoundCategory): ()
    self._maid:DoCleaning();
    setmetatable(self :: any, nil);
end;

return SoundCategory;
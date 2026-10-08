--!strict
local require = require(script.Parent.loader).load(script);
local SoundCategory = require("SoundByteCategory");

export type SoundSettings = {
    Settings: {[string]: SoundCategory.SoundCategory};
    GetCategory: (string) -> SoundCategory.SoundCategory?;
    AddCategory: (string, number?) -> ();
    RemoveCategory: (string) -> ();
};

local SoundSettings: SoundSettings = {} :: SoundSettings;

SoundSettings.Settings = {};

--[=[
    Gets the specified SoundByteCategory object within Settings table.
    @param category string -- The category name to retrieve.
]=]
function SoundSettings.GetCategory(category: string): SoundCategory.SoundCategory?
    if not (SoundSettings.Settings[category]) then warn(`Category ({category}) does not exist within Settings`); end;
    return SoundSettings.Settings[category];
end;

--[=[
    Adds a sound category to settings table.
]=]
function SoundSettings.AddCategory(category: string, volume: number?): ()
    if (SoundSettings.Settings[category]) then warn(`Attempting to add duplicate category! ({category})`); return; end;
    SoundSettings.Settings[category] = SoundCategory.new(category, volume);
end;
--[=[
    Removes a sound category from the settings table.
]=]
function SoundSettings.RemoveCategory(category: string): ()
    if not (SoundSettings.Settings[category]) then return; end;
    SoundSettings.Settings[category]:Destroy();
    SoundSettings.Settings[category] = nil;
end;


return SoundSettings :: SoundSettings;
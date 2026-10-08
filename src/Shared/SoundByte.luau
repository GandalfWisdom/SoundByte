--!strict
--[=[
	--SoundByte by GandalfWisdom--

	HOW TO USE:

	Simply use SoundByte.new("sound name") and play the new sound like any other sound object.
	Example:
	```luau
	local example_sound = SoundByte.new("SwordSwing1");
	example_sound:Play();
	```
	Be sure to look at the full list of functions below as they have a lot of different uses. For example
	the :PlayOnce() function is useful for playing a sound once and cleaning itself up afterwards.
	This means you don't even need set the sound as a variable when playing. Example:
	```luau
	SoundByte.new("SwordSwing1"):PlayOnce();
	```

	@class SoundByte
]=]
local require = require(script.Parent.loader).load(script);
local Maid = require("Maid");
local SoundCategory = require("SoundByteCategory");
local SoundSettings = require("SoundByteSettings");
local SS: SoundService = game:GetService("SoundService");
local CS: CollectionService = game:GetService("CollectionService");

--Variables
local COLLECTION_TAG: string = "SoundByte"; --PROVIDES A FASTER WAY TO INDEX SOUNDS. MAKE SURE YOUR SOUND OBJECT MODULES HAVE THIS TAG.
local ACTIVE_SOUND_TAG: string = "ActiveSound"; -- A tag given to all active sound instances.
local sound_cache: {[string]: SoundInfo} = {}; -- Caches all of the sound info in one large table.

--Class
local SoundByte = {};
SoundByte.__index = SoundByte;
SoundByte.ClassName = "SoundByte";

export type SoundInfo = {
	Name: string;
	SoundId: string;
	Looped: boolean;
	PlaybackSpeed: number;
	Volume: number;
	RollOffMaxDistance: number;
	RollOffMinDistance: number;
	RollOffMode: Enum.RollOffMode;
	Category: string;
};
export type SoundByte = typeof(setmetatable(
	{} :: {
		_maid: Maid.Maid;
		_sound_info: SoundInfo;
		Target: Attachment;
		Sound: Sound;
	},
	{} :: typeof( {__index = SoundByte} )
));

--[=[
	Constructs SoundByte class.
	@param sound_name string -- The name of the sound to create
]=]
function SoundByte.new(sound_name: string): SoundByte
	local sound_info = assert(sound_cache[assert(sound_name, "No sound_name provided!")], "Sound module not found!");

    local self: SoundByte = setmetatable({} :: any, SoundByte);
    self._maid = Maid.new();
	self._sound_info = sound_info;
	self.Sound = self:Create();

    return self;
end;

--[=[
	Creates a sound object with the sound info object found upon construction.
	@return Sound
]=]
function SoundByte.Create(self: SoundByte): Sound
	local sound: Sound = self._maid:Add(Instance.new("Sound"));
	sound:AddTag(ACTIVE_SOUND_TAG); -- Adds a tag so it can be tracked (E.G. :StopAll() or )

	sound.Name = self._sound_info["Name"];
	sound.SoundId = self._sound_info["SoundId"];
	sound.Looped = self._sound_info["Looped"];
	sound.PlaybackSpeed = self._sound_info["PlaybackSpeed"];
	sound.Volume = self._sound_info["Volume"];
	sound.RollOffMaxDistance = self._sound_info["RollOffMaxDistance"];
	sound.RollOffMinDistance = self._sound_info["RollOffMinDistance"];
	sound.RollOffMode = self._sound_info["RollOffMode"];

	sound.Parent = SS;

	-- Destroys this class if sound itself is destroyed
	sound.Destroying:Once(function() self:Destroy(); end);

	return sound;
end;

--[=[
	Creates an attachment for sound to be nested in, usually used in the :PlayAtVector3 methods.
	@param position Vector3? -- Position the part is set to when created.
]=]
function SoundByte.CreateAttachment(self: SoundByte, position: Vector3?): ()
	self.Target = self._maid:Add(Instance.new("Attachment"));
	if (position ~= nil) then self.Target.WorldPosition = position; end;
end;

--[=[
	Sets modifiers for sound object. Simplifies parameter checking on functions
	@param playback_speed number -- The speed to play the sound at.
	@param volume number -- The volume to play the sound at.
	@param time_position -- The time position to play the sound at.
	@param pitch -- The pitch to play the sound at.
]=]
function SoundByte.SetModifiers(self: SoundByte, playback_speed: number?, volume: number?, time_position : number?, pitch : number?): ()
	-- VOLUME SETTINGS FUNCTIONALITY: Sets the base volume to be played by sound as determined by volume category set within settings
	local category: SoundCategory.SoundCategory = SoundSettings.Settings[self._sound_info.Category];
	if (category) then self.Sound.Volume = category:VolumeMult(); end;

	--PLAYBACK SPEED MODIFIER
	if (playback_speed ~= nil) then self.Sound.PlaybackSpeed = playback_speed; end;
	--VOLUME MODIFIER
	if (volume ~= nil) then self.Sound.Volume = volume; end;
	--TIME POSITION MODIFIER
	if (time_position ~= nil) then self.Sound.TimePosition = time_position; end;
	--PITCH MODIFIER
	if (pitch ~= nil) then
		local pitch_shift = self._maid:Add(Instance.new("PitchShiftSoundEffect", self.Sound));
		pitch_shift.Octave = pitch;
	end;
end;

--================================
-- PLAY FUNCTIONS
--================================

--[=[
	Plays the sound.
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.Play(self: SoundByte, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);
	self.Sound:Play();
end;
--[=[
	Plays the sound once, and then destroys itself.
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.PlayOnce(self: SoundByte, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);
	self.Sound.PlayOnRemove = true;
	self:Destroy();
end;
--[=[
	Plays the sound looped.
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.Loop(self: SoundByte, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);
	self.Sound.Looped = true;
	self.Sound:Play();
end;

--================================
-- VECTOR3 FUNCTIONS
--================================
--[=[
	Plays the sound at specified Vector3 coordinates.
	@param position Vector3
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.PlayAtVector3(self: SoundByte, position: Vector3, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);
	self:CreateAttachment(position);
	self.Sound.Parent = self.Target;
	self.Sound:Play();
end;
--[=[
	Plays the sound once at specified Vector3 coordinates, then destroys itself.
	@param position Vector3
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.PlayOnceAtVector3(self: SoundByte, position: Vector3, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self:CreateAttachment(position);
	self.Sound.Parent = self.Target;
	self.Sound.PlayOnRemove = true;
	self:Destroy();
end;
--[=[
	Plays the sound looped at specified Vector3 coordinates.
	@param position Vector3
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.LoopAtVector3(self: SoundByte, position: Vector3, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);
	self:CreateAttachment(position);
	self.Sound.Looped = true;
	self.Sound.Parent = self.Target;
	self.Sound:Play();
end;

--================================
-- INSTANCE FUNCTIONS
--================================

--[=[
	Plays the sound as a child of the specified instance.
	@param instance Instance
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.PlayAtInstance(self: SoundByte, instance: Instance, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	if (self.Sound.Parent ~= instance) then self.Sound.Parent = instance; end; --Sets sound's parent to instance variable.
	self.Sound:Play();

	self._maid:GiveTask(instance.AncestryChanged:Connect(function() -- If instance part is attached to is removed, then destroy the sound.
		if (instance.Parent == nil) then self:Destroy(); end;
	end));
end;
--[=[
	Plays the sound as a child of the specified instance, then destroys itself.
	@param instance Instance
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.PlayOnceAtInstance(self: SoundByte, instance: Instance, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound.Parent = instance;
	self.Sound.PlayOnRemove = true;
	self:Destroy();
end;
--[=[
	Plays the sound as a child of the specified instance, then waits until the sound is finished playing before destroying itself. 
	(Used as an alternative to :PlayOnceAtInstance() when you want the sound to stay attached to instance while playing).
	@param instance Instance
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.PlayStackAtInstance(self: SoundByte, instance: Instance, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound.Parent = instance;
	self.Sound:Play();
	
	self._maid:GiveTask(self.Sound.Ended:Connect(function()
		self:Destroy();
	end));
end;
--[=[
	Plays the sound looped as a child of the specified instance.
	@param instance Instance
	@param playback_speed number?
	@param volume number?
	@param time_position number?
	@param pitch number?
]=]
function SoundByte.LoopAtInstance(self: SoundByte, instance: Instance, playback_speed: number?, volume: number?, time_position: number?, pitch: number?): ()
	if not (self.Sound) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	if (self.Sound.Parent ~= instance) then self.Sound.Parent = instance; end; --Sets sound's parent to instance variable.
	self.Sound.Looped = true;
	self.Sound:Play();

	self._maid:GiveTask(instance.AncestryChanged:Connect(function()	
		if (instance.Parent == nil) then self:Destroy(); end;
	end));
end;

--================================
-- STOP FUNCTIONS
--================================

--[=[
	Stops the sound.
]=]
function SoundByte.Stop(self: SoundByte): ()
	if not (self.Sound) then return; end;
	self.Sound:Stop();
end;
--[=[
	Stops all sounds that share the same name.
]=]
function SoundByte.StopAll(self: SoundByte): ()
	if not (self.Sound) then return; end;
	for _, sound in (CS:GetTagged(ACTIVE_SOUND_TAG)) do
		if not (sound:IsA("Sound")) then continue; end;
		if (sound.Name ~= self._sound_info.Name) then continue; end;
		sound:Stop();
	end;
end;
--[=[
	Pauses the sound.
]=]
function SoundByte.Pause(self: SoundByte): ()
	if not (self.Sound) then return; end;
	self.Sound:Pause();
end;
--[=[
	Pauses all sounds that share the same name.
]=]
function SoundByte.PauseAll(self: SoundByte): ()
	if not (self.Sound) then return; end;
	for _, sound in (CS:GetTagged(ACTIVE_SOUND_TAG)) do
		if not (sound:IsA("Sound")) then continue; end;
		if (sound.Name ~= self._sound_info.Name) then continue; end;
		sound:Pause();
	end;
end;
--[=[
	Resumes the sound.
]=]
function SoundByte.Resume(self: SoundByte): ()
	if not (self.Sound) then return; end;
	self.Sound:Resume();
end;
--[=[
	Resumes all sounds thatt share the same name.
]=]
function SoundByte.ResumeAll(self: SoundByte): ()
	if not (self.Sound) then return; end;
	for _, sound in (CS:GetTagged(ACTIVE_SOUND_TAG)) do
		if not (sound:IsA("Sound")) then continue; end;
		if (sound.Name ~= self._sound_info.Name) then continue; end;
		sound:Resume();
	end;
end;

--[=[
	Destroy the SoundByte object.
]=]
function SoundByte.Destroy(self: SoundByte): ()
    self._maid:DoCleaning();
    setmetatable(self :: any, nil);
end;

--================================
-- SOUND CACHE
--================================

--[=[
	Adds sound to cache when tagged module is added.
	@param sound_module Instance -- The sound module that was added.
]=]
local function add_sound(sound_module: Instance): ()
	if not (sound_module:IsA("ModuleScript")) then return; end;
	local sound_info: SoundInfo = require(sound_module);
	sound_cache[sound_info.Name] = sound_info;
end;
--[=[
	Removes sound from cache when tagged module is destroyed.
	@param sound_module Instance -- The sound module that was destroyed.
]=]
local function remove_sound(sound_module: Instance): ()
	if not (sound_module:IsA("ModuleScript")) then return; end;
	local sound_info: SoundInfo = require(sound_module);
	if not (sound_cache[sound_info.Name]) then return; end;
	sound_cache[sound_info.Name] = nil;
end;
--[=[
	Constructs the cache of all available sounds.
]=]
local function construct_cache(): ()
	for _, sound_module in (CS:GetTagged(COLLECTION_TAG)) do
		add_sound(sound_module);
	end;
end;

CS:GetInstanceAddedSignal(COLLECTION_TAG):Connect(add_sound);
CS:GetInstanceRemovedSignal(COLLECTION_TAG):Connect(remove_sound);
construct_cache();

return SoundByte;
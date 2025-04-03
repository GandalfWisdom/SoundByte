--[=[
	--SoundByte by GandalfWisdom--

	HOW TO USE:
	Make sure the SOUND_FOLDER variable below is set to whatever folder you plan on storing your sound files (ReplicatedStorage or SoundService is a good place for it)
	If SOUND_FOLDER is NIL, it will instead use collection service.

	Simply use SoundByte.new([Name of sound]) and play the new sound like any other sound object.
	Example:
	```lua
	local example_sound = SoundByte.new("SoundExample");
	example_sound:Play();
	```
	Be sure to look at the full list of functions below as they have a lot of different uses. For example
	the :PlayOnce() function is useful for playing a sound once and cleaning itself up afterwards.
	This means you don't even need set the sound as a variable when playing. Example:
	```lua
	SoundByte.new("SoundExample"):PlayOnce();
	```
]=]
local require = require(script.Parent.loader).load(script);
local Maid = require("Maid");
local SS = game:GetService("SoundService");
local CS = game:GetService("CollectionService");

--Variables
local SOUND_FOLDER = SS;--[[CHANGE THIS TO MAIN SOUND DIRECTORY (Folder where all of your sound files are)]]--
local COLLECTION_TAG = "SoundByte"; --PROVIDES A FASTER WAY TO INDEX SOUNDS. MAKE SURE YOUR SOUND OBJECT MODULES HAVE THIS TAG.

local active_sounds_table= {};
local ACTIVE_SOUNDS_FOLDER = SS:FindFirstChild("ActiveSounds");
if not (ACTIVE_SOUNDS_FOLDER) then 
    ACTIVE_SOUNDS_FOLDER = Instance.new("Folder"); 
    ACTIVE_SOUNDS_FOLDER.Parent = SS;
    ACTIVE_SOUNDS_FOLDER.Name = "ActiveSounds";
end;

local v3_new = Vector3.new;

--Class
local SoundByte = {};
SoundByte.__index = SoundByte;
SoundByte.ClassName = "SoundByte";

local function find_sound_module(sound_name: string)
	local sound_module = nil;
	for _, sound_module_val: ModuleScript in pairs(CS:GetTagged(COLLECTION_TAG)) do
		if not (sound_module_val:IsA("ModuleScript")) or (sound_module_val.Name ~= sound_name) then continue; end;
		sound_module = sound_module_val;
		break;
	end;
	if (sound_module == nil) then sound_module = SOUND_FOLDER:FindFirstChild(sound_name, true); end; --Finds sound module through :FindFirstChild() if collection service method fails
	return sound_module;
end;

--Constructor
function SoundByte.new(sound_name: string)
	local sound_module: ModuleScript = find_sound_module(sound_name);
	assert(sound_module ~= nil, "Sound module not found! Try setting the correct SOUND_FOLDER variable, or properly tagging your sound instances!");
	assert(SOUND_FOLDER ~= nil,"SOUND_FOLDER variable is nil. Remember to set SOUND_FOLDER to the folder your sounds will be stored.");

    local self = setmetatable({}, SoundByte);
    self._maid = Maid.new();

	self.SoundInfo = nil;
	if (sound_module) then self.SoundInfo = require(sound_module); end;
	self.Sound = self:Create():: Sound;

	--Variables
	self.TargetPart = nil;
	active_sounds_table[self] = self;
    return self;
end;

--Functions
--[[
	Base :Play() functions for playing sounds
	
	Arguments: 
	vv--Optional--vv
	playback_speed -> The speed the sound will play at.
	volume -> The volume the sound will play at.
	time_position -> The point in time the sound will play at.
	pitch -> The pitch the sound will play at.

]]

--Plays sound from ActiveSounds folder in SoundService
function SoundByte:Play(playback_speed: number, volume: number, time_position: number, pitch: number)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound:Play();
end;
--Same as above but destroys itself when played, useful for playing the sound once.
function SoundByte:PlayOnce(playback_speed: number, volume: number, time_position: number, pitch: number)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound.PlayOnRemove = true;
	self:Destroy();
end;
--Plays the sound as a loop
function SoundByte:Loop(playback_speed: number, volume: number, time_position: number, pitch: number)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound.Looped = true;
	self.Sound:Play();
end;
--[[
	Vector3 :Play() functions. 
	
	Arguments: 
	vv--Necessary--vv
	position -> A Vector3 the sound will play at.
	vv--Optional--vv
	playback_speed -> The speed the sound will play at.
	volume -> The volume the sound will play at.
	time_position -> The point in time the sound will play at.
	pitch -> The pitch the sound will play at.
]]
--Plays the sound at specified Vector3 (The first argument passed through the function)
function SoundByte:PlayAtVector3(position: Vector3?, playback_speed: number, volume: number, time_position: number, pitch: number)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self:CreatePart(position);
	self.Sound.Parent = self.TargetPart;
	self.Sound:Play();
end;
--Same as above but destroys itself when played, useful for playing the sound once.
function SoundByte:PlayOnceAtVector3(position: Vector3?, playback_speed: number?, volume: number?, time_position: number?, pitch: number?)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self:CreatePart(position);
	self.Sound.Parent = self.TargetPart;
	self.Sound.PlayOnRemove = true;
	self:Destroy();
end;
--Plays the sound as a loop at specified Vector3 (The first argument passed through the function)
function SoundByte:LoopAtVector3(position: Vector3?, playback_speed: number?, volume: number?, time_position: number?, pitch: number?)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self:CreatePart(position);
	self.Sound.Looped = true;
	self.Sound.Parent = self.TargetPart;
	self.Sound:Play();
end;

--[[
	Instance :Play() functions. 
	
	Arguments: 
	vv--Necessary--vv
	instance -> An Instance the sound will play from.
	vv--Optional--vv
	playback_speed -> The speed the sound will play at.
	volume -> The volume the sound will play at.
	time_position -> The point in time the sound will play at.
	pitch -> The pitch the sound will play at.
]]
--Plays a sound inside of the specified instance.
function SoundByte:PlayAtInstance(instance: Instance?, playback_speed: number?, volume: number?, time_position: number?, pitch: number?)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	if (self.Sound.Parent ~= instance) then self.Sound.Parent = instance; end; --Sets sound's parent to instance variable.
	self.Sound:Play();

	self._part_destroyed_event = self._maid:GiveTask(instance.AncestryChanged:Connect(function()
		if (instance.Parent == nil) then self:Destroy(); end;
	end));
end;
--Same as above but destroys itself when played, useful for playing the sound once.
function SoundByte:PlayOnceAtInstance(instance: Instance?, playback_speed: number?, volume: number?, time_position: number?, pitch: number?)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound.Parent = instance;
	self.Sound.PlayOnRemove = true;
	self:Destroy();
end;
--Alternative to :PlayOnceAtInstance(). Creates a new sound each time and destroys itself after it is finished playing. This is used so the sound will still follow the object it's parented to.
function SoundByte:PlayStackAtInstance(instance: Instance, playback_speed: number, volume: number, time_position: number, pitch: number) 
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	self.Sound.Parent = instance;
	self.Sound:Play();
	
	self._sound_ended_event = self._maid:GiveTask(self.Sound.Ended:Connect(function()
		self:Destroy();
	end));
end;
--Plays the sound as a loop inside of the specified Instance (The first argument passed through the function)
function SoundByte:LoopAtInstance(instance: Instance, playback_speed: number, volume: number, time_position: number, pitch: number)
	if (self.Sound == nil) then return; end;
	self:SetModifiers(playback_speed, volume, time_position, pitch);

	if (self.Sound.Parent ~= instance) then self.Sound.Parent = instance; end; --Sets sound's parent to instance variable.
	self.Sound.Looped = true;
	self.Sound:Play();

	self._part_destroyed_event = self._maid:GiveTask(instance.AncestryChanged:Connect(function()	
		if (instance.Parent == nil) then self:Destroy(); end;
	end));
end;

--[[
	Functions for stopping sounds
]]
function SoundByte:Stop()
	if (self.Sound == nil) then return; end;
	self.Sound:Stop();
end;
--Stops all sounds of the same name.
function SoundByte:StopAll()
	if (self.Sound == nil) then return; end;
	for _, soundbyte_object in pairs(active_sounds_table) do
		if (soundbyte_object == nil) then continue; end;
		soundbyte_object:Stop();
	end;
	self.Sound:Stop();
end;
function SoundByte:Pause()
	if (self.Sound == nil) then return; end;
	self.Sound:Pause();
end;
function SoundByte:Resume()
	if (self.Sound == nil) then return; end;
	self.Sound:Resume();
end;


--[[
	Sets modifiers for sound object, so each function can modify each sound with the arguments passed through.
]]
function SoundByte:SetModifiers(playback_speed : number, volume : number, time_position : number, pitch : number)
	--self.Sound.Loaded:Wait(); --Waits until sound is loaded before coninuing
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

--[[
	Creates a sound object with the sound info object found upon construction.
]]
function SoundByte:Create() 
	local sound = self._maid:Add(Instance.new("Sound"));

	sound.Name = self.SoundInfo["Name"];
	sound.SoundId = self.SoundInfo["SoundId"];
	sound.Looped = self.SoundInfo["Looped"];
	sound.PlaybackSpeed = self.SoundInfo["PlaybackSpeed"];
	sound.Volume = self.SoundInfo["Volume"];
	sound.RollOffMaxDistance = self.SoundInfo["RollOffMaxDistance"];
	sound.RollOffMinDistance = self.SoundInfo["RollOffMinDistance"];
	sound.RollOffMode = self.SoundInfo["RollOffMode"];

	local oldSound = ACTIVE_SOUNDS_FOLDER:FindFirstChild(self.SoundInfo["Name"]);
	if (oldSound) then
		oldSound:Destroy();
	end

	CS:AddTag(sound, COLLECTION_TAG); --Collection service tag, mostly used for the :StopAll() method.
	sound.Parent = ACTIVE_SOUNDS_FOLDER;
	return sound;
end;

--[[
	Creates part for sound to be nested in, usually used in the :PlayAtVector3 method. 
]]
function SoundByte:CreatePart(position: Vector3?)
	self.TargetPart = self._maid:Add(Instance.new("Part"));
	self.TargetPart.Size = v3_new(1, 1, 1);
	self.TargetPart.Transparency = 1;
	self.TargetPart.CanCollide = false;
	self.TargetPart.Anchored = true;
	if (position ~= nil) then self.TargetPart.Position = position; end;
end;

--Destroys SoundByte object.
function SoundByte:Destroy()
	active_sounds_table[self] = nil;
    self._maid:DoCleaning();
    setmetatable(self, nil);
end;

return SoundByte;
--[=[
	--SoundByte by GandalfWisdom--

	HOW TO USE:
	Make sure the SOUND_FOLDER variable below is set to whatever folder you plan on storing your sound files (ReplicatedStorage or SoundService is a good place for it)

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
local Maid = require(script.Maid);
local SS = game:GetService("SoundService");

--Variables
local SOUND_FOLDER = nil;--[[CHANGE THIS TO MAIN SOUND DIRECTORY (Folder where all of your sound files are)]]--

local ACTIVE_SOUNDS = SS:FindFirstChild("ActiveSounds", true);
if not (ACTIVE_SOUNDS) then 
    ACTIVE_SOUNDS = Instance.new("Folder"); 
    ACTIVE_SOUNDS.Parent = SS;
    ACTIVE_SOUNDS.Name = "ActiveSounds";
end;

local v3_new = Vector3.new;

--Class
local SoundByte = {};
SoundByte.__index = SoundByte;
SoundByte.ClassName = "SoundByte";

--Constructor
function SoundByte.new(sound_name: string)
	if (SOUND_FOLDER == nil) then error("SOUND_FOLDER variable is nil. Remember to set SOUND_FOLDER to the folder your sounds will be stored."); end;
    local self = setmetatable({}, SoundByte);
    self._maid = Maid.new();

	--Sound Create
	self._sound_module = SOUND_FOLDER:FindFirstChild(sound_name, true);
	self.SoundInfo = nil;
	if (self._sound_module) then self.SoundInfo = require(self._sound_module); end;
	self.Sound = self:Create():: Sound;

	--Variables
	self.TargetPart = nil;

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

	local oldSound = ACTIVE_SOUNDS:FindFirstChild(self.SoundInfo["Name"]);
	if (oldSound) then
		oldSound:Destroy();
	end

	sound.Parent = ACTIVE_SOUNDS;
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
    self._maid:DoCleaning();
    setmetatable(self, nil);
end;

return SoundByte;
local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local HttpService = game:GetService("HttpService");

local LocalPlayer = Players.LocalPlayer;

local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/NicksRBLX/RBLX_Games/refs/heads/master/Games.lua"))();

local PlaceID = game.PlaceId;
local UniverseID = HttpService:JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/".. PlaceID .."/universe")).universeId;

StarterGui:SetCore("SendNotification", { Title = "NeoPulse"; Text = "Welcome "..LocalPlayer.DisplayName.."!"; });
if Games["UniverseIDs"][UniverseID] then
	loadstring(game:HttpGet(Games["UniverseIDs"][UniverseID]))();
elseif Games["PlaceIDs"][PlaceID] then
	loadstring(game:HttpGet(Games["PlaceIDs"][PlaceID]))();
end
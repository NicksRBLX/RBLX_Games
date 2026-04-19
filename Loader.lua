local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/NicksRBLX/RBLX_Games/refs/heads/master/Games.lua"))();
local UniverseID = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/".. game.PlaceId .."/universe")).universeId;

if Games["UniverseIDs"][UniverseID] then
	loadstring(game:HttpGet(Games["UniverseIDs"][UniverseID]))();
elseif Games["PlaceIDs"][game.PlaceId] then
	loadstring(game:HttpGet(Games["PlaceIDs"][game.PlaceId]))();
end
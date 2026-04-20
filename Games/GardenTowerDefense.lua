--[[
    ╔═════════════════════════════════════════════════════════════╗
    ║                          NeoPulse                           ║
    ║                Garden Tower Defense - Roblox                ║
    ║                                                             ║
    ║  UI: Obsidian by deivid (https://docs.mspaint.cc/obsidian)  ║
    ║                                                             ║
    ║  Features:                                                  ║
    ║    • 	Auto Play | Auto Replay | Auto Difficulty             ║
	║    • 	Macro Play                                            ║
    ╚═════════════════════════════════════════════════════════════╝
--]]

local ObsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/";
local Library = loadstring(game:HttpGet(ObsidianRepo .. "Library.lua"))();

local Loading = Library:CreateLoading({
    Title = "NeoPulse",
    Icon = 0,
    TotalSteps = 4,
});

-- ═══════════════════════════════════════════════════════════════
-- PRELOAD
-- ═══════════════════════════════════════════════════════════════
Loading:SetMessage("Initializing...");
Loading:SetDescription("Loading game...");

if not game:IsLoaded() then game.Loaded:Wait() end
if game:GetService("HttpService"):JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/".. game.PlaceId .."/universe")).universeId ~= 7703614594 then return; end

local ThemeManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/ThemeManager.lua"))();
local SaveManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/SaveManager.lua"))();

local DATA_LIBRARY = loadstring(game:HttpGet("https://raw.githubusercontent.com/NicksRBLX/RBLX_Datas/refs/heads/master/GardenTowerDefense/DATA.lua"))();
local UTILITY_LIBRARY = loadstring(game:HttpGet("https://raw.githubusercontent.com/NicksRBLX/Paradoxium/refs/heads/main/modules/UtilityModule.lua"))();

local HUBPATH = "NeoPulse";
local SAVEPATH = "GardenTowerDefense";

local Loading_Success, Loading_Result = pcall(function()

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & REFERENCES
-- ═══════════════════════════════════════════════════════════════
Loading:SetDescription("Loading services...");
task.wait(1);

local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local Lighting = game:GetService("Lighting");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local VirtualUser = game:GetService("VirtualUser");
local RunService = game:GetService("RunService");
local Workspace = game:GetService("Workspace");
local TweenService = game:GetService("TweenService");
local Debris = game:GetService("Debris");
local TeleportService = game:GetService("TeleportService");

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer.PlayerGui;
local Camera = Workspace.CurrentCamera;
local Mouse = LocalPlayer:GetMouse();

-- ═══════════════════════════════════════════════════════════════
-- GAME PATHS (from decompiled scripts & lists)
-- ═══════════════════════════════════════════════════════════════
Loading:SetDescription("Loading game paths...")
repeat task.wait() until Workspace:FindFirstChild("Map");

local MAP_FOLDER = Workspace:FindFirstChild("Map");
local REMOTEEVENTS_FOLDER = ReplicatedStorage:FindFirstChild("RemoteEvents");
local REMOTEFUNCTIONS_FOLDER = ReplicatedStorage:FindFirstChild("RemoteFunctions");

local COLLECTABLES_FOLDER = PlayerGui["LogicHolder"]["ClientLoader"]["Modules"]:FindFirstChild("SharedCollectables")

local EGG_LIST = {}
for _, egg in pairs(COLLECTABLES_FOLDER["Models"]["easter26"]:GetChildren()) do table.insert(EGG_LIST, egg.Name); end
for _, egg in pairs(COLLECTABLES_FOLDER["Models"]["easter26v2"]:GetChildren()) do table.insert(EGG_LIST, egg.Name); end

-- ═══════════════════════════════════════════════════════════════
-- OBSIDIAN UI SETUP
-- ═══════════════════════════════════════════════════════════════
Loading:SetCurrentStep(1);
Loading:SetMessage("Setting up user interface...");
Loading:SetDescription("Initializing variables...");

local Options = Library.Options;
local Toggles = Library.Toggles;

Library.ForceCheckbox = false;
Library.ShowToggleFrameInKeybinds = true;

local Window = Library:CreateWindow({
    Title = "NeoPulse",
    Footer = "Garden Tower Defense",
    NotifySide = "Right",
    ShowCustomCursor = false,
    Center = true,
    Resizable = true,
});

-- ═══════════════════════════════════════════════════════════════
-- TABS
-- ═══════════════════════════════════════════════════════════════

local Tabs = {
    Lobby = Window:AddTab("Lobby", "house"),
    Game = Window:AddTab("Game", "gamepad-2"),
    Inventory = Window:AddTab("Inventory", "backpack"),
	Shop = Window:AddTab("Shop", "shopping-cart"),
    Events = Window:AddTab("Events", "calendars"),
    ["UI Settings"] = Window:AddTab("Settings", "settings"),
};

-- ═══════════════════════════════════════════════════════════════
-- LOBBY TAB
-- ═══════════════════════════════════════════════════════════════

local LobbyMapManagerBox = Tabs.Lobby:AddLeftGroupbox("Map Manager");
local LobbyAutomationBox = Tabs.Lobby:AddRightGroupbox("Automations");
local TeleportManagerBox = Tabs.Lobby:AddRightGroupbox("Teleporters");

-- ── Select Map ─────────────────────────────────────────────────


-- ── Teleports ──────────────────────────────────────────────────
TeleportManagerBox:AddButton({
    Text = "Teleport to Lobby",
    Func = function()
        TeleportService:Teleport(108533757090220, LocalPlayer);
    end
});
if Workspace:GetAttribute("IsLobby") == true then
	TeleportManagerBox:AddButton({
		Text = "Teleport to Obby Finish Line",
		Func = function()
			LocalPlayer.Character["HumanoidRootPart"].CFrame = CFrame.new(Vector3.new(127, 690, 2170));
		end
	});
end

-- ═══════════════════════════════════════════════════════════════
-- GAME TAB
-- ═══════════════════════════════════════════════════════════════

local MacroManagerBox = Tabs.Game:AddLeftTabbox();
local MacroManagerTab = MacroManagerBox:AddTab("Macro");
local MacroSettingsTab = MacroManagerBox:AddTab("Settings");
local MacroStatusBox = Tabs.Game:AddLeftGroupbox("Macro Status");
local MapMacroManagerBox = Tabs.Game:AddRightTabbox();
local ClassicMapMacroBox = MapMacroManagerBox:AddTab("Classic");
local EndlessMapMacroBox = MapMacroManagerBox:AddTab("Endless");

local MacroLists = {}
local function RefreshMacroList()
    MacroLists = {};
    for _, file in pairs(UTILITY_LIBRARY:GetFiles(HUBPATH.."/"..SAVEPATH.."/macro")) do
        table.insert(MacroLists, (file:split("/")[5]):split(".")[1]);
    end
end
RefreshMacroList();

-- ── Map Macro Manager ──────────────────────────────────────────
local ClassicMapsMacro = {};
local EndlessMapsMacro = {};
for _, map in pairs(DATA_LIBRARY["MAP_LIST"]) do
	ClassicMapsMacro[map] = ClassicMapMacroBox:AddDropdown(DATA_LIBRARY["MAPS"][map]["ID"].."_classic", {
		Text = map,
		Values = MacroLists,
		Default = nil,
		Searchable = true,
        AllowNull = true,
	});
	EndlessMapsMacro[map] = EndlessMapMacroBox:AddDropdown(DATA_LIBRARY["MAPS"][map]["ID"].."_endless", {
		Text = map,
		Values = MacroLists,
		Default = nil,
		Searchable = true,
        AllowNull = true,
	});
end

-- ── Macro Manager ──────────────────────────────────────────────
local GeneralMacro = MacroManagerTab:AddDropdown("GeneralMacro", {
    Text = "Macro",
	Values = MacroLists,
	Default = nil,
	Searchable = true,
    AllowNull = true,
});
MacroManagerTab:AddToggle("EnableMacroToggle", {
	Text = "Enable Macro",
	Default = false,
	Tooltip = "Let the macro play the map."
});
MacroManagerTab:AddButton({
    Text = "Refresh Macro List",
    Func = function()
        RefreshMacroList();
        GeneralMacro:SetValues(MacroLists);
        for _, map in pairs(DATA_LIBRARY["MAP_LIST"]) do
            ClassicMapsMacro[map]:SetValues(MacroLists);
            EndlessMapsMacro[map]:SetValues(MacroLists);
        end
        task.wait(2);
        Library:Notify({
            Title = "NeoPulse";
            Description = "Successfully refreshed Macro Lists";
            Time = 5;
        })
    end
});

-- ── Game Manager ───────────────────────────────────────────────
if Workspace:GetAttribute("Difficulty") ~= "dif_endless" then
    local Difficulties_Values = UTILITY_LIBRARY:GetTableKeys(DATA_LIBRARY["DIFFICULTY_LIST"]);
    if Workspace:GetAttribute("IsLobby") == false and Workspace:GetAttribute("MapId") ~= "map_halloween_event" then
        Difficulties_Values = DATA_LIBRARY["MAPS"][Workspace:GetAttribute("MapName")]["Difficulties"]
    end
    MacroSettingsTab:AddDropdown("MacroAutoDifficulty", {
        Text = "Auto Place Difficulty Vote",
        Values = Difficulties_Values,
        Default = "Easy",
    });
end
MacroSettingsTab:AddDropdown("OnVictoryNext", {
    Text = "On Victory Next",
    Values = { "None", "Play again", "Return to lobby" },
    Default = "None",
    Tooltip = "Next to do when round is victory."
});
MacroSettingsTab:AddDropdown("OnDefeatNext", {
    Text = "On Defeat Next",
    Values = { "None", "Play again", "Return to lobby" },
    Default = "None",
    Tooltip = "Next to do when round is defeat."
});
MacroSettingsTab:AddDropdown("AutoGameSpeed", {
    Text = "Auto Game Tick Speed",
    Values = { "Disable", "1", "2", "3" },
    Default = "Disable",
    Tooltip = "Set the game tick speed automatically."
});
MacroSettingsTab:AddDivider();

-- ── Macro Settings ─────────────────────────────────────────────
MacroSettingsTab:AddLabel("Anti Macro Nerf")
MacroSettingsTab:AddToggle("EnableRandomWalk", {
    Text = "Enable Random Walk",
    Default = false,
});
MacroSettingsTab:AddToggle("EnableRandomJump", {
    Text = "Enable Random Jump",
    Default = false,
});
MacroSettingsTab:AddSlider("RandomPlacementOffset", {
    Text = "Random Placement Offset",
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
});

-- ── Macro Status ───────────────────────────────────────────────
local MacroStatus = MacroStatusBox:AddLabel("Status: Not Running");
local MacroStatusLines = {};
for i = 1, 5 do
    MacroStatusLines[i] = MacroStatusBox:AddLabel("");
    MacroStatusLines[i]:SetVisible(false);
end

-- ═══════════════════════════════════════════════════════════════
-- INVENTORY TAB
-- ═══════════════════════════════════════════════════════════════

local LoadoutBox = Tabs.Inventory:AddLeftGroupbox("Loadout");
local DeleteUnitBox = Tabs.Inventory:AddRightGroupbox("Delete Unit");
local AutoDeleteUnitBox = Tabs.Inventory:AddRightGroupbox("Auto Delete Units");

-- ── Loadout Manager ────────────────────────────────────────────
local UnitSlots = {}
for slot = 1, tonumber(LocalPlayer:GetAttribute("PropertyTotalValue_MaxUnitsEquipped")) do
    UnitSlots[slot] = LoadoutBox:AddDropdown("UnitSlot"..slot, {
        Text = "Unit " .. slot,
        Values = {},
        Default = nil,
        Searchable = true,
    });
end
LoadoutBox:AddDivider();
LoadoutBox:AddButton({
    Text = "Equip Loadout",
    Func = function()

    end
});
LoadoutBox:AddButton({
    Text = "Unequip All Units",
    Func = function()

    end
})

-- ═══════════════════════════════════════════════════════════════
-- SHOP TAB
-- ═══════════════════════════════════════════════════════════════

local GnomeSummonBox = Tabs.Shop:AddLeftGroupbox("Gnome Shop");
local LimitedStockBox = Tabs.Shop:AddLeftGroupbox("Limited Stock Units");
local EventSummonBox = Tabs.Shop:AddRightGroupbox("Event Shop");
local TradersBox = Tabs.Shop:AddRightGroupbox("Traders");

-- ── Gnome Summon ───────────────────────────────────────────────
GnomeSummonBox:AddDropdown("GnomeUnitBox", {
	Text = "Unit/Summon Box",
	Values = UTILITY_LIBRARY:GetTableKeys(DATA_LIBRARY["SUMMON"]["SEEDS"]),
	Default = "Classic Summon",
	Searchable = true,
});
local x1GnomeSummon = GnomeSummonBox:AddButton({
    Text = "x1 | 100",
    Func = function()
        REMOTEFUNCTIONS_FOLDER["BuyUnitBox"]:InvokeServer(DATA_LIBRARY["SUMMON"]["SEEDS"][Options["GnomeUnitBox"].Value]["ID"], 1);
    end
});
local x10GnomeSummon = x1GnomeSummon:AddButton({
    Text = "x10 | 900",
    Func = function()
        REMOTEFUNCTIONS_FOLDER["BuyUnitBox"]:InvokeServer(DATA_LIBRARY["SUMMON"]["SEEDS"][Options["GnomeUnitBox"].Value]["ID"], 10);
    end
});
Options.GnomeUnitBox:OnChanged(function()
	x1GnomeSummon:SetText("x1 | " .. DATA_LIBRARY["SUMMON"]["SEEDS"][Options["GnomeUnitBox"].Value]["PRICE_X1"]);
	x10GnomeSummon:SetText("x10 | " .. DATA_LIBRARY["SUMMON"]["SEEDS"][Options["GnomeUnitBox"].Value]["PRICE_X10"]);
end);

-- ── Limited Stock Units ────────────────────────────────────────
for name, values in pairs(DATA_LIBRARY["LIMITED_STOCK_UNITS"]) do
    LimitedStockBox:AddLabel(name);
    LimitedStockBox:AddButton({
        Text = values["PRICE"],
        Func = function()
            REMOTEFUNCTIONS_FOLDER["BuyUnitWithSeeds"]:InvokeServer(values["ID"]);
        end,
        DoubleClick = true,
    })
end

-- ── Event Summon ───────────────────────────────────────────────
EventSummonBox:AddLabel("Bunny Summon");
EventSummonBox:AddButton({
	Text = "x1 | 100",
	Func = function()
        REMOTEFUNCTIONS_FOLDER["BuyUnitBox"]:InvokeServer("ub_easter", 1);
    end
}):AddButton({
	Text = "x10 | 900",
	Func = function()
        REMOTEFUNCTIONS_FOLDER["BuyUnitBox"]:InvokeServer("ub_easter", 10);
    end
});
EventSummonBox:AddDivider();
EventSummonBox:AddLabel("Galaxy Summon");
EventSummonBox:AddButton({
	Text = "x1 | 25",
	Func = function()
        REMOTEFUNCTIONS_FOLDER["BuyUnitBox"]:InvokeServer("ub_space", 1);
    end
}):AddButton({
	Text = "x10 | 225",
	Func = function()
        REMOTEFUNCTIONS_FOLDER["BuyUnitBox"]:InvokeServer("ub_space", 10);
    end
});

-- ── Traders Summon ─────────────────────────────────────────────
TradersBox:AddLabel("Mystery Trader");
TradersBox:AddDivider();
TradersBox:AddLabel("Easter Trader");


-- ═══════════════════════════════════════════════════════════════
-- EVENTS TAB
-- ═══════════════════════════════════════════════════════════════

local EasterBox = Tabs.Events:AddLeftGroupbox("Easter Hunt");

-- ── Auto Collect Eggs ──────────────────────────────────────────
EasterBox:AddToggle("AutoCollectEggs", {
	Text = "Enable Auto Collect Eggs",
	Default = false,
	Tooltip = "Automatic collection of spawned eggs",
});
EasterBox:AddDropdown("AutoCollectEggsBlacklist", {
    Text = "Auto Collect Eggs Blacklist",
    Values = EGG_LIST,
    Default = nil,
    Multi = true,
    Searchable = true,
    MaxVisibleDropdownItems = 15,
});

-- ═══════════════════════════════════════════════════════════════
-- UI SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu");

-- ── UI Menu Settings ───────────────────────────────────────────
MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
});
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
});
MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
});
MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
});
MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(value)
        Window:SetCornerRadius(value)
    end,
});
MenuGroup:AddDivider();
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" });
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end);

Library.ToggleKeybind = Options.MenuKeybind;

-- ═══════════════════════════════════════════════════════════════
-- SAVE & THEME MANAGERS
-- ═══════════════════════════════════════════════════════════════

local IgnoreIndexes = { "MenuKeybind", "GeneralMacro" }

ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);
SaveManager:IgnoreThemeSettings();
SaveManager:SetIgnoreIndexes(IgnoreIndexes);
ThemeManager:SetFolder(HUBPATH);
SaveManager:SetFolder(HUBPATH.."/"..SAVEPATH);
SaveManager:BuildConfigSection(Tabs["UI Settings"]);
ThemeManager:ApplyToTab(Tabs["UI Settings"]);
SaveManager:LoadAutoloadConfig();

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
Loading:SetCurrentStep(2);
Loading:SetMessage("Creating methods...");
Loading:SetDescription("Helper functions...");
task.wait(1);

-- ═══════════════════════════════════════════════════════════════
-- FEATURE: AUTO PLAY
-- ═══════════════════════════════════════════════════════════════
Loading:SetDescription("Auto play feature...");



-- ═══════════════════════════════════════════════════════════════
-- FEATURE: MACRO
-- ═══════════════════════════════════════════════════════════════
Loading:SetDescription("Macro feature...");

local macroThread = nil;
local gameThread = nil;

if Workspace:GetAttribute("IsLobby") == false then
    local MacroData = {};
    local PlacedUnits = {};
    local Counter = 1;

    local function GetMacro()
        if Workspace:GetAttribute("Difficulty") ~= "dif_endless" then
            if Options[Workspace:GetAttribute("MapId").."_classic"].Value ~= nil then
                return HttpService:JSONDecode(readfile(HUBPATH.."/"..SAVEPATH.."/macro/"..Options[Workspace:GetAttribute("MapId").."_classic"].Value..".json"):gsub("%s", ""));
            end
            if Options["GeneralMacro"].Value ~= nil then
                return HttpService:JSONDecode(readfile(HUBPATH.."/"..SAVEPATH.."/macro/"..Options["GeneralMacro"].Value..".json"):gsub("%s", ""));
            end
        else
            if Options[Workspace:GetAttribute("MapId").."_endless"].Value ~= nil then
                return HttpService:JSONDecode(readfile(HUBPATH.."/"..SAVEPATH.."/macro/"..Options[Workspace:GetAttribute("MapId").."_endless"].Value..".json"):gsub("%s", ""));
            end
            if Options["GeneralMacro"].Value ~= nil then
                return HttpService:JSONDecode(readfile(HUBPATH.."/"..SAVEPATH.."/macro/"..Options["GeneralMacro"].Value..".json"):gsub("%s", ""));
            end
        end
        return {};
    end
    MacroData = GetMacro();

    local function ValidateCondition(Condition)
        if Condition["Type"] == "Time" then
            local TimeDifference = os.time() - Workspace:GetAttribute("GameStartTime");
            if TimeDifference >= Condition["Data"] then return true; end
            return false;
        end
        if Condition["Type"] == "Cash" then
            local Cash = LocalPlayer:GetAttribute("Cash");
            if Cash >= Condition["Data"] then return true; end
            return false;
        end
        if Condition["Type"] == "Wave" then
            local Wave = Workspace:GetAttribute("Round");
            if Wave >= Condition["Data"] then return true; end
            return false;
        end
    end

    -- Macro Thread
    macroThread = UTILITY_LIBRARY:Thread("MacroThread", function()
        while task.wait() do
            -- Unloaded Check
            if Library.Unloaded then break; end

            -- Macro Check
            if not Toggles["EnableMacroToggle"].Value then
                MacroStatus:SetText("Status: Not Running");
                for i = 1, 5 do MacroStatusLines[i]:SetVisible(false); end
                continue;
            else
                MacroStatus:SetText("Status: Running");
                if MacroData == {} then continue; end
                if #MacroData < Counter then
                    MacroStatus:SetText("Status: Finished");
                    for i = 1, 5 do MacroStatusLines[i]:SetVisible(false); end
                    continue;
                end
            end

            -- Game Running Check
            if Workspace:GetAttribute("GameStartTime") == nil then continue; end
            if Workspace:GetAttribute("GameEndTime") ~= nil then continue; end

            -- Status Lines Update
            task.spawn(function()
                MacroStatus:SetText("Status: Running ["..Counter.."/"..#MacroData.."]");
                for i = 1, 5 do MacroStatusLines[i]:SetVisible(false); end
                MacroStatusLines[1]:SetText("Condition: "..MacroData[Counter]["Condition"]["Type"].." | "..MacroData[Counter]["Condition"]["Data"]);
                MacroStatusLines[2]:SetText("Task: "..MacroData[Counter]["Task"]);

                if MacroData[Counter]["Task"] == "PlaceUnit" then
                    MacroStatusLines[3]:SetText("Placing unit: "..MacroData[Counter]["Unit"]);
                    MacroStatusLines[4]:SetText("Position: ["..MacroData[Counter]["Data"]["Position"][1]..", "..MacroData[Counter]["Data"]["Position"][2]..", "..MacroData[Counter]["Data"]["Position"][3].."]");
                    MacroStatusLines[5]:SetText("ID: "..MacroData[Counter]["ID"]);
                    for i = 1, 5 do MacroStatusLines[i]:SetVisible(true); end
                elseif MacroData[Counter]["Task"] == "UpgradeUnit" then
                    MacroStatusLines[3]:SetText("Upgrade times: "..MacroData[Counter]["Upgrades"]);
                    MacroStatusLines[4]:SetText("ID: "..MacroData[Counter]["ID"]);
                    for i = 1, 4 do MacroStatusLines[i]:SetVisible(true); end
                elseif MacroData[Counter]["Task"] == "SellUnit" then
                    MacroStatusLines[3]:SetText("ID: "..MacroData[Counter]["ID"]);
                    for i = 1, 3 do MacroStatusLines[i]:SetVisible(true); end
                end
            end)

            -- Condition Check
            if not ValidateCondition(MacroData[Counter]["Condition"]) then continue; end

            if MacroData[Counter]["Task"] == "PlaceUnit" then
                -- Cooldown Check
                if LocalPlayer:FindFirstChild("PlacementCooldowns") then
                    if LocalPlayer["PlacementCooldowns"]:FindFirstChild(MacroData[Counter]["Unit"].."/1") then continue; end
                end

                local number = tonumber(Options["RandomPlacementOffset"].Value);
                local randomVector = Vector3.new(
                    -number + (number - (-number)) * math.random(),
                    0 + (1 - 0) * math.random(),
                    -number + (number - (-number)) * math.random()
                );
                local NewData = {
                    Valid = true,
                    Position = Vector3.new(unpack(MacroData[Counter]["Data"]["Position"])) + randomVector,
                    CF = CFrame.new(unpack(MacroData[Counter]["Data"]["CF"])) + randomVector,
                    Rotation = MacroData[Counter]["Data"]["Rotation"]
                };
                if MacroData[Counter]["Data"]["PathIndex"] then NewData["PathIndex"] = MacroData[Counter]["Data"]["PathIndex"]; end
                if MacroData[Counter]["Data"]["DistanceAlongPath"] then NewData["DistanceAlongPath"] = MacroData[Counter]["Data"]["DistanceAlongPath"]; end
                local valid, id = REMOTEFUNCTIONS_FOLDER["PlaceUnit"]:InvokeServer(MacroData[Counter]["Unit"], NewData);
                if not valid then continue; end
                task.wait();
                repeat
                    for _, entity in (MAP_FOLDER:FindFirstChild("Entities"):GetChildren()) do
                        local entityNameSplit = entity.Name:split("_");
                        if entityNameSplit[1] == "enemy" then continue; end
                        if tonumber(entity:GetAttribute("ID")) == id then
                            PlacedUnits[MacroData[Counter]["ID"]] = {
                                ["Entity"] = entity,
                                ["ID"] = id
                            };
                            break;
                        end
                    end
                    task.wait();
                until PlacedUnits[MacroData[Counter]["ID"]] ~= nil
            elseif MacroData[Counter]["Task"] == "UpgradeUnit" then
                -- Valid Unit Check
                if PlacedUnits[MacroData[Counter]["ID"]] == nil then continue; end

                local valid = true;
                for _ = 1, MacroData[Counter]["Upgrades"] do
                    local success = REMOTEFUNCTIONS_FOLDER["UpgradeUnit"]:InvokeServer(tonumber(PlacedUnits[MacroData[Counter]["ID"]]["ID"]))
                    if not success then valid = false; break; end
                    task.wait(0.1);
                end
                if not valid then continue; end
            elseif MacroData[Counter]["Task"] == "UpgradeAll" then

            elseif MacroData[Counter]["Task"] == "SellUnit" then
                -- Valid Unit Check
                if PlacedUnits[MacroData[Counter]["ID"]] == nil then continue; end

                local valid = REMOTEFUNCTIONS_FOLDER["SellUnit"]:InvokeServer(tonumber(PlacedUnits[MacroData[Counter]["ID"]]["ID"]));
                if not valid then continue; end
            elseif MacroData[Counter]["Task"] == "SellAll" then

            end

            Counter = Counter + 1;
        end
    end):Start();

    -- Game Thread
    gameThread = UTILITY_LIBRARY:Thread("GameThread", function()
        while task.wait() do
            if Library.Unloaded then break; end
            if Workspace:GetAttribute("GameEndTime") == nil then continue; end

            if Workspace:GetAttribute("BaseHP") > 0 then
                if Options["OnVictoryNext"].Value == "Play again" then
                    REMOTEFUNCTIONS_FOLDER["RestartGame"]:InvokeServer();
                    if Workspace:GetAttribute("Difficulty") ~= "dif_endless" then
                        task.wait();
                        REMOTEFUNCTIONS_FOLDER["PlaceDifficultyVote"]:InvokeServer("dif_"..string.lower(Options["MacroAutoDifficulty"].Value));
                        if Options["AutoGameSpeed"].Value ~= "Disable" then
                            REMOTEFUNCTIONS_FOLDER["ChangeTickSpeed"]:InvokeServer(tonumber(Options["AutoGameSpeed"].Value));
                        end
                    end
                    PlacedUnits = {};
                    Counter = 1;
                    MacroData = GetMacro();
                    continue;
                elseif Options["OnVictoryNext"].Vlaue == "Return to bobby" then
                    TeleportService:Teleport(108533757090220, LocalPlayer);
                end
            else
                if Options["OnDefeatNext"].Value == "Play again" then
                    REMOTEFUNCTIONS_FOLDER["RestartGame"]:InvokeServer();
                    if Workspace:GetAttribute("Difficulty") ~= "dif_endless" then
                        task.wait();
                        REMOTEFUNCTIONS_FOLDER["PlaceDifficultyVote"]:InvokeServer("dif_"..string.lower(Options["MacroAutoDifficulty"].Value));
                        if Options["AutoGameSpeed"].Value ~= "Disable" then
                            REMOTEFUNCTIONS_FOLDER["ChangeTickSpeed"]:InvokeServer(tonumber(Options["AutoGameSpeed"].Value));
                        end
                    end
                    PlacedUnits = {};
                    Counter = 1;
                    MacroData = GetMacro();
                    continue;
                elseif Options["OnVictoryNext"].Vlaue == "Return to bobby" then
                    TeleportService:Teleport(108533757090220, LocalPlayer);
                end
            end
        end
    end):Start();
end

-- ═══════════════════════════════════════════════════════════════
-- FEATURE: AUTO COLLECT EGGS
-- ═══════════════════════════════════════════════════════════════
Loading:SetDescription("Events feature...");

local autoCollectEggsConnection = nil;

local function CollectSpawnedEggs(part)
	if part.Name ~= "Collectable" then return; end
	if not Workspace:FindFirstChild(part:GetAttribute("ItemId")) then return; end
	if table.find(Options["AutoCollectEggsBlacklist"].Value, part:GetAttribute("ItemId")) then return; end
	task.wait(0.1);
	REMOTEEVENTS_FOLDER["CollectCollectable"]:FireServer(tonumber(part:GetAttribute("ID")));
end

Toggles["AutoCollectEggs"]:OnChanged(function()
	if Toggles["AutoCollectEggs"].Value then
		for _, part in pairs(Workspace:GetChildren()) do CollectSpawnedEggs(part); end
	end
end)

autoCollectEggsConnection = Workspace.ChildAdded:Connect(function(part)
	if Toggles["AutoCollectEggs"].Value then CollectSpawnedEggs(part); end
end)

if Toggles["AutoCollectEggs"].Value then
	for _, part in pairs(Workspace:GetChildren()) do CollectSpawnedEggs(part); end
end

-- ═══════════════════════════════════════════════════════════════
-- DRAGGABLE MACRO STATUS
-- ═══════════════════════════════════════════════════════════════

local DraggableMacroStatus = Library:AddDraggableLabel("Macro Status")
DraggableMacroStatus:SetVisible(false)

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP ON UNLOAD
-- ═══════════════════════════════════════════════════════════════
Loading:SetCurrentStep(3);
Loading:SetMessage("Creating safe cleanup...");
Loading:SetMessage("Unload function...");

Library:OnUnload(function()
	-- Disconnect auto collect eggs
	if autoCollectEggsConnection then
		autoCollectEggsConnection:Disconnect()
        autoCollectEggsConnection = nil
	end

    -- Stop Macro Thread
    if macroThread then
        macroThread:Stop();
        macroThread = nil;
    end

    -- Stop Game Thread
    if gameThread then
        gameThread:Stop();
        gameThread = nil;
    end
	
	-- Notify
    Library:Notify({
        Title = "NeoPulse",
        Description = "NeoPulse unloaded. All features disabled.",
        Time = 3,
    })
end);

-- ═══════════════════════════════════════════════════════════════
-- STARTUP NOTIFICATION
-- ═══════════════════════════════════════════════════════════════

task.wait(1)
Loading:SetCurrentStep(4);
Loading:SetMessage("Almost done!")
Loading:SetDescription("Applying anti afk...")

LocalPlayer.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame);
	task.wait(1);
	VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame);
end);

end)
if Loading_Success then
    Loading:Continue();
    Library:Notify({
        Title = "NeoPulse",
        Description = "Loaded successfully for Garden Tower Defense!\nPress RightShift to toggle menu.",
        Time = 5,
    });
else
    Loading:ShowErrorPage(true);
    Loading:SetErrorMessage(Loading_Result);
    task.wait(10);
    Library:Unload();
end
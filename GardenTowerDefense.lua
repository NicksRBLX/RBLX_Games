if not game:IsLoaded() then game.Loaded:Wait() end

--------------------
-- [[ SERVICES ]] --
--------------------
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local StarterGui = game:GetService("StarterGui");
local Lighting = game:GetService("Lighting");
local RStorage = game:GetService("ReplicatedStorage");
local UserIS = game:GetService("UserInputService");
local RService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");
local VirtualUser = game:GetService("VirtualUser");

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer.PlayerGui;
local Mouse = LocalPlayer:GetMouse();

local Success, Result = pcall(function()
	print("Loading Garden Tower Defense Script!");
    repeat task.wait(.1) until RStorage:FindFirstChild("RemoteFunctions");
    task.wait(5);

    local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/NicksRBLX/Paradoxium/refs/heads/main/modules/UtilityModule.lua"))()

    ------------------
	-- [[ CONFIG ]] --
	------------------
    local AntiAFK = true;
    local RandomWalk = true;
    getgenv().AutoReplay = false;
    getgenv().Difficulty = "dif_easy";
    getgenv().Macro = {};

    --------------------------
	-- [[ USER INTERFACE ]] --
	--------------------------

    ---------------------
	-- [[ VARIABLES ]] --
	---------------------
    local Remotes = RStorage:FindFirstChild("RemoteFunctions");
    local RestartGameRemote = Remotes:FindFirstChild("RestartGame");
    local PlaceDifficultyVoteRemote = Remotes:FindFirstChild("PlaceDifficultyVote");
    local PlaceUnit = Remotes:FindFirstChild("PlaceUnit");
    local UpgradeUnit = Remotes:FindFirstChild("UpgradeUnit");
    local SellUnit = Remotes:FindFirstChild("SellUnit");

    local Map = game.Workspace:FindFirstChild("Map");
    local Entities = Map:FindFirstChild("Entities");

    local PlacedUnits = {};
    local DoneTasks = {};
    local GameStarted = (game.Workspace:GetAttribute("GameStartTime") ~= nil);
    local GameEnded = (game.Workspace:GetAttribute("GameEndTime") ~= nil);

    ---------------------
	-- [[ FUNCTIONS ]] --
	---------------------
    local function PlaceUnitHandler(data)
        local valid, id
        repeat
            local randomX = -2 + (2 - (-2)) * math.random();
            local randomY = 0 + (1 - 0) * math.random();
            local randomZ = -2 + (2 - (-2)) * math.random();
            local randomData = {
                Valid = true,
                PathIndex = data["Data"]["PathIndex"],
                Position = (data["Data"]["Position"] + Vector3.new(randomX, randomY, randomZ)),
                DistanceAlongPath = data["Data"]["DistanceAlongPath"],
                CF = (data["Data"]["CF"] + Vector3.new(randomX, randomY, randomZ)),
                Rotation = data["Data"]["Rotation"]
            }
            valid, id = PlaceUnit:InvokeServer(data["Unit"], randomData);
            task.wait()
        until valid

        task.wait()

        for _, entity in (Entities:GetChildren()) do
            if tonumber(entity:GetAttribute("ID")) == id then
                PlacedUnits[data["ID"]] = {
                    ["Object"] = entity,
                    ["ID"] = id
                };
            end
        end
    end
    local function UpgradeUnitHandler(data)
        for counter = 1, data["Upgrades"] do
            UpgradeUnit:InvokeServer(tonumber(PlacedUnits[data["ID"]]["ID"]))
        end
    end
    local function SellUnitHandler(data)
        SellUnit:InvokeServer(tonumber(PlacedUnits[data["ID"]]["ID"]))
    end
    local function RestartGame()
        RestartGameRemote:InvokeServer();
        task.wait();
        PlaceDifficultyVoteRemote:InvokeServer(getgenv().Difficulty);
    end

    ------------------
	-- [[ EVENTS ]] --
	------------------
    local MacroThread = Utility:Thread("Macro", function()
        while task.wait() do
            if GameEnded then
                task.wait()
                if getgenv().AutoReplay then
                    task.wait(5);
                    RestartGame();
                end
                PlacedUnits = {};
                DoneTasks = {};
                continue;
            end
            if GameStarted and (not GameEnded) and Utility:Length(getgenv().Macro) then
                local TimeDifference = os.time() - game.Workspace:GetAttribute("GameStartTime")
                if getgenv().Macro[TimeDifference] and (not table.find(DoneTasks, TimeDifference)) then
                    for _, tasks in pairs(getgenv().Macro[TimeDifference]) do
                        if tasks["Task"] == "Place Unit" then PlaceUnitHandler(tasks); continue; end
                        if tasks["Task"] == "Upgrade Unit" then UpgradeUnitHandler(tasks); continue; end
                        if tasks["Task"] == "Sell Unit" then SellUnitHandler(tasks); continue; end
                    end
                    table.insert(DoneTasks, TimeDifference)
                end
            end
        end
    end):Start()

    local HumanoidThread = Utility:Thread("Humanoid", function()
        while task.wait(60) do
            if RandomWalk then
                local randomX = -20 + (20 - (-20)) * math.random();
                local randomZ = -20 + (20 - (-20)) * math.random();

                local Character = LocalPlayer.Character
                Character["Humanoid"]:MoveTo(Character["HumanoidRootPart"].CFrame.Position + Vector3.new(randomX, 0, randomZ))
            end
        end
    end):Start()

    game.Workspace:GetAttributeChangedSignal("GameStartTime"):Connect(function()
        local attribute = game.Workspace:GetAttribute("GameStartTime");
        GameStarted = (attribute ~= nil);
    end)
    game.Workspace:GetAttributeChangedSignal("GameEndTime"):Connect(function()
        local attribute = game.Workspace:GetAttribute("GameEndTime");
        GameEnded = (attribute ~= nil);
    end)

    LocalPlayer.Idled:Connect(function()
        if AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0,0), game.Workspace.CurrentCamera.CFrame);
            task.wait(1);
            VirtualUser:Button2Up(Vector2.new(0,0), game.Workspace.CurrentCamera.CFrame);
        end
    end)

    print("Loaded Garden Tower Defense Script!");
end)
RaidRoll = LibStub("AceAddon-3.0"):NewAddon("RaidRoll", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
RaidRollIcon = LibStub("LibDBIcon-1.0")

local textStore = ''
local registeredEvents = {}
local rollcount
local rollers = {}
local outText
RaidRollListen = false


local RaidRollLDB = LibStub("LibDataBroker-1.1"):NewDataObject("RaidRoll", {
type = "data source",
text = "RaidRoll",
icon = "Interface\\Addons\\RaidRoll\\RaidRollIconON",
OnClick = function() RaidRoll:ToggleWindow() end,
})


function RaidRoll:ToggleWindow()
	if frame:IsShown() then
		frame:Hide()
		RaidRollLDB.icon = "Interface\\Addons\\RaidRoll\\RaidRollIconOFF"
		-- RaidRollIcon:Refresh()
	else
		frame:Show()
		RaidRollLDB.icon = "Interface\\Addons\\RaidRoll\\RaidRollIconON"
		
	end
end


function RaidRoll:OnInitialize()
	RaidRoll:Print(ChatFrame4, "Hello, world!")
	RaidRoll.db = LibStub("AceDB-3.0"):New("RaidRollDB", { profile = { minimap = { hide = false, }, }, }) 
	RaidRollIcon:Register("RaidRoll", RaidRollLDB, RaidRoll.db.profile.minimap) 
end


function RaidRoll:OnEnable()
    -- Called when the addon is enabled
end

function RaidRoll:OnDisable()
    -- Called when the addon is disabled
end

function RaidRoll:chatEvent(...)
    -- Called when the addon is disabled
	local arg1 = select(2, ...)
	local name,roll,minRoll,maxRoll = arg1:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")
    if name then
      rollers[name] = roll 
    end
end

function RaidRoll:GuildParseRollers(rollers)
    numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
	-- build guildTable based on whos online
	local guildTable = {}
	i=1
	while i<=numOnlineMembers do
		name,rank,rankIndex = GetGuildRosterInfo(i)
		name = name:match("^(.+)-")
		guildTable[name] = {rank, rankIndex}
		i = i+1
	end
	-- update rollers
	for k,v in pairs(rollers) do
		rollers[k] = {v, guildTable[k][1], guildTable[k][2]}
	end
	
	return rollers
end

function RaidRoll:printRollers(rollers)
	rollers = RaidRoll:GuildParseRollers(rollers)
	outText = ""
	table.sort( rollers, tableSortCat)
    for k, v in pairs(rollers) do
		outText = outText .. "NAME: " .. k .. " - ROLLED: " .. v[1] .. " - RANK: " .. v[2] .. "\n"
	end
	textbox:SetText(outText)
	rollers = {}
	return rollers
end


function RaidRoll:ToggleListen(RaidRollListen)
	if RaidRollListen == true  then
		RaidRoll:UnregisterEvent("CHAT_MSG_SYSTEM")
		-- RaidRoll:Print(ChatFrame4, "<< STOPPED LISTENING >>")
		button:SetText("Stop Listening!")
		rollers = RaidRoll:printRollers(rollers)
		RaidRollListen = false
		
	else
		RaidRoll:RegisterEvent("CHAT_MSG_SYSTEM", "chatEvent")
		-- RaidRoll:Print(ChatFrame4, "<< LISTENING >>")
		button:SetText("Listening!")
		textbox:SetText("<< LISTENING >>")
		SetGuildRosterShowOffline(false)
		RaidRollListen = true
	end
	return RaidRollListen, rollers
end

function tableSortCat (a, b )
    if (a[3] > b[3]) then
           return true
        elseif (a[3] < b[3]) then
            return false
        else
              return a[1] > b[1]
        end
end


frame = AceGUI:Create("Frame")
frame:SetTitle("Raid Roll Tracker")
frame:SetStatusText("Super Duper Beta of RaidRoll")
frame:SetWidth(400)
frame:SetHeight(350)
frame:SetHeight(350)
frame:SetLayout("Flow")


textbox = AceGUI:Create("MultiLineEditBox")
textbox:SetLabel("Rollers!")
textbox:SetRelativeWidth(1)
textbox:SetHeight(200)
frame:AddChild(textbox)

button = AceGUI:Create("Button")
if RaidRollListen == true then
	button:SetText("Listening!")
else 
	button:SetText("Click Me to Listen")
end
button:SetRelativeWidth(1)
button:SetCallback("OnClick", function() RaidRollListen, rollers = RaidRoll:ToggleListen(RaidRollListen) 
	if RaidRollListen == true then 
		button:SetText("Listening!") 
	else 
		button:SetText("Click Me to Listen") 
	end 
end)
frame:AddChild(button)

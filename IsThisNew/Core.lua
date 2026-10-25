-- IsThisNew? - Core
-- WoW: Forever (Interface 16001) tooltip provenance tagger. Answers
-- "is this new, changed, or am I misremembering Classic?" for the
-- items and NPCs in its sourced seed database - and says nothing at
-- all about anything else, because untagged means UNKNOWN, never
-- "classic". Display only: no combat data, no automation.
local ADDON, ns = ...

ns.VERSION = "0.1.0"

local function Print(msg)
    local chat = DEFAULT_CHAT_FRAME
    if chat and chat.AddMessage then
        chat:AddMessage("|cffb2f5e9IsThisNew?:|r " .. tostring(msg))
    end
end
ns.Print = Print

-- SavedVariables: shape-validated on load, version-stamped. A save
-- written by a NEWER version is left untouched, never downgraded.
local DB_VERSION = 1
local function EnsureDB()
    if type(IsThisNewDB) ~= "table" then IsThisNewDB = {} end
    local db = IsThisNewDB
    if type(db.settings) ~= "table" then db.settings = {} end
    if db.settings.enabled == nil then db.settings.enabled = true end
    if db.settings.showNote == nil then db.settings.showNote = true end
    if db.settings.showSource == nil then db.settings.showSource = false end
    if type(db.version) ~= "number" then db.version = 0 end
    if db.version < DB_VERSION then db.version = DB_VERSION end
    ns.db = db
end
ns.EnsureDB = EnsureDB

local function StatsLine()
    local items, npcs, changed = 0, 0, 0
    for i = 1, #ns.Records do
        local r = ns.Records[i]
        if r.kind == "item" then items = items + 1 else npcs = npcs + 1 end
        if r.tag == "changed" then changed = changed + 1 end
    end
    return "database: " .. #ns.Records .. " records (" .. items ..
        " items, " .. npcs .. " NPCs, " .. changed ..
        " changed) - untagged means unknown, not classic."
end

-- /itin lookup <name or id>: chat-side answer using the same Lookup
-- the tooltips use. The miss wording is deliberate and load-bearing.
local function LookupCommand(arg)
    arg = (arg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if arg == "" then
        Print("usage: /itin lookup <item or NPC name, or numeric id>")
        return
    end
    local id = tonumber(arg)
    local hit = nil
    if id then
        hit = ns.Lookup("item", id, nil) or ns.Lookup("npc", id, nil)
    else
        hit = ns.Lookup("item", nil, arg) or ns.Lookup("npc", nil, arg)
    end
    if hit then
        local label = hit.tag == "changed" and "Changed in Forever" or "Forever Exclusive"
        Print(hit.name .. " - " .. label .. ".")
        if hit.note then Print(hit.note) end
        if hit.source then Print("Source: " .. hit.source) end
    else
        Print("no record for '" .. arg ..
            "' - unknown, which is not proof it is Classic. " ..
            "IsThisNew? only tags what a cited source confirms.")
    end
end
ns.LookupCommand = LookupCommand

local function GuidNpcID(unit)
    if not unit or not UnitGUID then return nil, nil end
    local guid = UnitGUID(unit)
    if issecretvalue and issecretvalue(guid) then return nil, nil end
    return ns.NpcIDFromGUID(guid), guid
end

-- /itin dump: the collector. Prints the identifiers the seed database
-- needs to graduate from name matching to verified ID matching on the
-- live build: mouseover and target NPC IDs (from GUIDs) and the last
-- item tooltip's ID (from its link). Paste the output into a data
-- commit; an ID is only added to Data.lua with this dump (or a
-- published source) behind it.
local function DumpCommand()
    local printed = false
    for _, unit in ipairs({ "mouseover", "target" }) do
        if UnitExists and UnitExists(unit) then
            local id, guid = GuidNpcID(unit)
            local uname = UnitName and UnitName(unit)
            Print(unit .. ": name=" .. tostring(uname) ..
                " npcID=" .. tostring(id) .. " guid=" .. tostring(guid))
            printed = true
        end
    end
    if ns.lastItemName or ns.lastItemID then
        Print("last item tooltip: name=" .. tostring(ns.lastItemName) ..
            " itemID=" .. tostring(ns.lastItemID))
        printed = true
    end
    if ns.lastUnitName or ns.lastUnitID then
        Print("last unit tooltip: name=" .. tostring(ns.lastUnitName) ..
            " npcID=" .. tostring(ns.lastUnitID))
        printed = true
    end
    if not printed then
        Print("nothing to dump yet: hover an item or an NPC, or target an NPC, then /itin dump again.")
    end
end
ns.DumpCommand = DumpCommand

local function Debug()
    Print("version " .. ns.VERSION .. " | " .. StatsLine())
    if GetBuildInfo then
        local v, b = GetBuildInfo()
        Print("client build: " .. tostring(v) .. " (" .. tostring(b) .. ")")
    end
    Print("tooltip hooks: " .. tostring(ns.hookMode or "not attached yet"))
end

local function SlashHandler(msg)
    EnsureDB()
    local cmd, rest = "", ""
    if type(msg) == "string" then
        cmd = (msg:match("^%s*(%S+)") or ""):lower()
        rest = msg:match("^%s*%S+%s+(.-)%s*$") or ""
    end
    if cmd == "on" then
        ns.db.settings.enabled = true
        Print("tagging on.")
    elseif cmd == "off" then
        ns.db.settings.enabled = false
        Print("tagging off. Your database is unchanged; tooltips just stay silent.")
    elseif cmd == "note" then
        ns.db.settings.showNote = not ns.db.settings.showNote
        Print("note line " .. (ns.db.settings.showNote and "shown." or "hidden."))
    elseif cmd == "source" then
        ns.db.settings.showSource = not ns.db.settings.showSource
        Print("source line " .. (ns.db.settings.showSource and "shown." or "hidden."))
    elseif cmd == "lookup" then
        LookupCommand(rest)
    elseif cmd == "dump" then
        DumpCommand()
    elseif cmd == "stats" then
        Print(StatsLine())
    elseif cmd == "debug" then
        Debug()
    elseif cmd == "help" or cmd == "" then
        Print("Commands: /itin on|off - tagging | /itin note - toggle the note line | /itin source - toggle the source line | /itin lookup <name|id> - ask the database | /itin dump - print item/NPC IDs for data collection | /itin stats | /itin debug | /itin help")
        Print("Untagged means unknown - IsThisNew? never guesses that something is Classic.")
    else
        Print("unknown command '" .. cmd .. "' - /itin help lists them all.")
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        EnsureDB()
        if ns.BuildIndexes then ns.BuildIndexes() end
    elseif event == "PLAYER_LOGIN" then
        EnsureDB()
        SLASH_ISTHISNEW1 = "/isthisnew"
        SLASH_ISTHISNEW2 = "/itin"
        SlashCmdList["ISTHISNEW"] = SlashHandler
        if ns.AttachTooltipHooks then ns.AttachTooltipHooks() end
        Print("loaded v" .. ns.VERSION .. " - " .. #ns.Records ..
            " sourced records. Hover something the timeline changed.")
    end
end)

#!/usr/bin/env python3
"""IsThisNew? startup + tooltip-simulation harness.

Loads the addon files listed in the Camelot .toc against a mocked WoW
API using lupa, fires ADDON_LOADED -> PLAYER_LOGIN, then drives the
real code paths: slash commands, settings toggles, and tooltip tagging
through the mocked GameTooltip (HookScript path) for a seeded item, a
seeded NPC, a changed NPC, an unknown item, a repeat show (dedupe),
and a cleared-then-reshown tooltip. Any Lua error or failed assertion
fails the harness.

This proves the files parse, boot, and tag correctly against the mock.
It does NOT prove in-game behaviour - that label stays Unverified
until a run in the live WoW: Forever client (launch Nov 4, 2026).
"""
import pathlib
import sys

import lupa

ROOT = pathlib.Path(__file__).resolve().parent.parent
ADDON = ROOT / "IsThisNew"

PRELUDE = r"""
CHATLOG = {}
local function newFS()
    local fs = { _text = "" }
    return setmetatable(fs, { __index = function() return function(...) return nil end end })
end
FRAMES = {}
local function newFrame(kind, name, parent, template)
    local f = { _name = name or "", _scripts = {}, _events = {}, _shown = true }
    local methods = {
        GetName = function() return f._name end,
        IsShown = function() return f._shown end,
        Show = function() f._shown = true end,
        Hide = function() f._shown = false end,
        SetScript = function(_, k, fn) f._scripts[k] = fn end,
        GetScript = function(_, k) return f._scripts[k] end,
        HookScript = function(_, k, fn) f._scripts[k] = fn end,
        RegisterEvent = function(_, e) f._events[e] = true end,
        UnregisterEvent = function(_, e) f._events[e] = nil end,
        CreateFontString = function() return newFS() end,
    }
    setmetatable(f, { __index = function(_, k)
        if methods[k] then return methods[k] end
        return function(...) return nil end
    end })
    FRAMES[#FRAMES + 1] = f
    if name then _G[name] = f end
    return f
end
CreateFrame = newFrame
UIParent = newFrame("Frame", "UIParent")
DEFAULT_CHAT_FRAME = { AddMessage = function(_, msg) CHATLOG[#CHATLOG + 1] = tostring(msg) end }
SlashCmdList = {}
GetBuildInfo = function() return "1.60.1", "70450", "Oct 2026", 16001 end
issecretvalue = function(v) return false end

-- Mock GameTooltip: records AddLine calls, serves one item/unit at a
-- time, and can be cleared (which must fire OnTooltipCleared so the
-- addon's dedupe key resets).
GameTooltip = newFrame("GameTooltip", "GameTooltip")
GameTooltip._lines = {}
GameTooltip._item = nil
GameTooltip._unit = nil
GameTooltip.AddLine = function(self, text) self._lines[#self._lines + 1] = tostring(text) end
GameTooltip.GetItem = function(self) return self._item[1], self._item[2] end
GameTooltip.GetUnit = function(self) return self._unit[1], self._unit[2] end
GameTooltip.ClearLines = function(self)
    self._lines = {}
    local h = self._scripts and self._scripts["OnTooltipCleared"]
    if h then h(self) end
end
-- NOTE: TooltipDataProcessor is deliberately absent in this mock, so
-- the harness exercises the HookScript fallback path. The processor
-- path is a thin wrapper over the same handlers.
UnitGUID = function(unit)
    if unit == "mouseover" then return "Creature-0-1-2-3-424242-0000000001" end
    if unit == "target" then return "Creature-0-1-2-3-515151-0000000002" end
    return nil
end
UnitExists = function(unit) return unit == "mouseover" or unit == "target" end
UnitName = function(unit) return unit == "mouseover" and "Garion Wendell" or "Lyn the Ignored" end
"""

DRIVER = r"""
local report = {}
local function note(s) report[#report + 1] = s end
local function try(label, fn)
    local ok, e = pcall(fn)
    note(label .. ": " .. (ok and "ok" or ("FAIL " .. tostring(e))))
    if not ok then error(label) end
end
local NS = {}
for _, item in ipairs(FILES) do
    local fn, err = load(item.code, item.name)
    if not fn then note("LOADFAIL " .. item.name .. ": " .. tostring(err)); return table.concat(report, "\n") end
    local ok, e = pcall(fn, "IsThisNew", NS)
    if not ok then note("RUNFAIL " .. item.name .. ": " .. tostring(e)); return table.concat(report, "\n") end
end
note("loaded " .. #FILES .. " files, records=" .. #NS.Records)
local function fire(ev, ...)
    for _, f in ipairs(FRAMES) do
        if f._events and f._events[ev] and f._scripts and f._scripts.OnEvent then
            local ok, e = pcall(f._scripts.OnEvent, f, ev, ...)
            if not ok then note("EVENTFAIL " .. ev .. ": " .. tostring(e)) end
        end
    end
end
fire("ADDON_LOADED", "IsThisNew")
fire("PLAYER_LOGIN")
note("login fired, hookMode=" .. tostring(NS.hookMode))

local function linesText()
    return table.concat(GameTooltip._lines, "\n")
end
local function setItem(name, id)
    GameTooltip._item = { name, "|Hitem:" .. id .. ":0:0:0|h[" .. name .. "]|h" }
    GameTooltip._scripts["OnTooltipSetItem"](GameTooltip)
end
local function setUnit(name, unit)
    GameTooltip._unit = { name, unit }
    GameTooltip._scripts["OnTooltipSetUnit"](GameTooltip)
end

try("seeded item tooltip tagged exclusive", function()
    GameTooltip:ClearLines()
    setItem("Cozy Sleeping Bag", 999001)
    local t = linesText()
    assert(t:find("Forever Exclusive", 1, true), "no exclusive line: " .. t)
    assert(t:find("%+3%% XP") or t:find("jumping-puzzle", 1, true), "note line missing: " .. t)
    assert(not t:find("Source:", 1, true), "source line shown while setting off")
end)
try("repeat show of same item does not double-tag", function()
    local before = #GameTooltip._lines
    setItem("Cozy Sleeping Bag", 999001)
    assert(#GameTooltip._lines == before, "double-tagged a repeat show")
end)
try("cleared tooltip tags again on reshow", function()
    GameTooltip:ClearLines()
    setItem("Cozy Sleeping Bag", 999001)
    assert(linesText():find("Forever Exclusive", 1, true), "no tag after clear+reshow")
end)
try("unknown item stays silent", function()
    GameTooltip:ClearLines()
    setItem("Defias Bandana", 751)
    assert(#GameTooltip._lines == 0, "tagged an item with no record")
end)
try("seeded NPC tooltip tagged, by name and GUID id recorded", function()
    GameTooltip:ClearLines()
    setUnit("Garion Wendell", "mouseover")
    assert(linesText():find("Forever Exclusive", 1, true), "NPC not tagged")
    assert(NS.lastUnitID == 424242, "npcID from GUID wrong: " .. tostring(NS.lastUnitID))
end)
try("changed NPC gets the changed tag", function()
    GameTooltip:ClearLines()
    setUnit("Archmage Ataeric", "target")
    assert(linesText():find("Changed in Forever", 1, true), "changed tag missing")
end)
try("unknown NPC stays silent", function()
    GameTooltip:ClearLines()
    setUnit("Hogger", "target")
    assert(#GameTooltip._lines == 0, "tagged an NPC with no record")
end)
try("tag by verified ID beats name (synthetic ID record)", function()
    NS.Records[#NS.Records + 1] = { kind = "item", id = 777, name = "Unrelated Name",
        tag = "changed", note = "id record", source = "test" }
    NS.BuildIndexes()
    GameTooltip:ClearLines()
    setItem("Anything At All", 777)
    assert(linesText():find("Changed in Forever", 1, true), "ID lookup did not win")
end)
try("source toggle shows the source line", function()
    SlashCmdList["ISTHISNEW"]("source")
    GameTooltip:ClearLines()
    setItem("Wolf's Bane", 999002)
    assert(linesText():find("Source: http", 1, true), "source line missing after toggle")
    SlashCmdList["ISTHISNEW"]("source")
end)
try("off toggle silences tagging, on restores it", function()
    SlashCmdList["ISTHISNEW"]("off")
    GameTooltip:ClearLines()
    setItem("Coldflame Saber", 999003)
    assert(#GameTooltip._lines == 0, "tagged while off")
    SlashCmdList["ISTHISNEW"]("on")
    GameTooltip:ClearLines()
    setItem("Coldflame Saber", 999003)
    assert(linesText():find("Forever Exclusive", 1, true), "did not tag after on")
end)
try("lookup hit + honest miss wording", function()
    CHATLOG = {}
    SlashCmdList["ISTHISNEW"]("lookup malignant root")
    local t = table.concat(CHATLOG, "\n")
    assert(t:find("Forever Exclusive", 1, true), "lookup miss on a seeded name: " .. t)
    CHATLOG = {}
    SlashCmdList["ISTHISNEW"]("lookup Linen Cloth")
    t = table.concat(CHATLOG, "\n")
    assert(t:find("not proof it is Classic", 1, true), "miss wording wrong: " .. t)
end)
try("dump prints mouseover/target ids and last item", function()
    CHATLOG = {}
    SlashCmdList["ISTHISNEW"]("dump")
    local t = table.concat(CHATLOG, "\n")
    assert(t:find("npcID=424242", 1, true), "mouseover id missing: " .. t)
    assert(t:find("npcID=515151", 1, true), "target id missing: " .. t)
    assert(t:find("last item tooltip", 1, true), "last item line missing: " .. t)
end)
try("stats + debug run", function()
    SlashCmdList["ISTHISNEW"]("stats")
    SlashCmdList["ISTHISNEW"]("debug")
end)
note("chat lines: " .. #CHATLOG)
note("DONE")
return table.concat(report, "\n")
"""


def toc_files(toc_name):
    lines = (ADDON / toc_name).read_text().splitlines()
    return [ln.strip() for ln in lines if ln.strip().endswith(".lua")]


def main():
    files = toc_files("IsThisNew_Camelot.toc")
    rt = lupa.LuaRuntime(unpack_returned_tuples=True)
    rt.execute(PRELUDE)
    rt.globals().FILES = rt.table_from(
        [{"name": n, "code": (ADDON / n).read_text()} for n in files])
    out = rt.execute(DRIVER)
    print(f"--- harness (IsThisNew_Camelot.toc: {', '.join(files)}) ---")
    print(out)
    bad = [ln for ln in out.splitlines() if "FAIL" in ln]
    if bad or "DONE" not in out:
        print("HARNESS: FAIL")
        sys.exit(1)
    print("HARNESS: PASS")


if __name__ == "__main__":
    main()

-- IsThisNew? - Tooltip tagging
-- Adds ONE provenance line (plus an optional note and source) to item
-- and unit tooltips for records in the seed database. Untagged means
-- unknown: this file never adds a "classic" line and never guesses.
--
-- Hook strategy (both paths guarded; whichever the client offers):
--  1. TooltipDataProcessor.AddTooltipPostCall for Item / Unit data -
--     the modern Mainline path Forever's API is derived from.
--  2. GameTooltip HookScript OnTooltipSetItem / OnTooltipSetUnit.
-- Dedupe: the tooltip frame remembers the content key it last tagged;
-- OnTooltipCleared (or a changed key) resets it, so reused tooltip
-- frames tag fresh content and never double-tag the same content.
-- Secret values: names, links and GUIDs read here are ordinary UI
-- data, but every read is wrapped so that a secret value is skipped
-- (never compared, never formatted) instead of erroring.
local _, ns = ...

local TAG_TEXT = {
    exclusive = "|cffb2f5e9IsThisNew? - Forever Exclusive|r",
    changed   = "|cfff7d774IsThisNew? - Changed in Forever|r",
}

local function SafeStr(v)
    if issecretvalue and issecretvalue(v) then return nil end
    if type(v) ~= "string" then return nil end
    return v
end

local function ItemIDFromLink(link)
    link = SafeStr(link)
    if not link then return nil end
    local id = link:match("item:(%d+)")
    return id and tonumber(id) or nil
end
ns.ItemIDFromLink = ItemIDFromLink

local function NpcIDFromGUID(guid)
    guid = SafeStr(guid)
    if not guid then return nil end
    -- Creature-0-<server>-<instance>-<zone>-<npcID>-<spawnUID>
    local id = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        or guid:match("^Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    return id and tonumber(id) or nil
end
ns.NpcIDFromGUID = NpcIDFromGUID

local function TagTooltip(tooltip, kind, id, name)
    if not tooltip or not tooltip.AddLine then return false end
    if not (ns.db and ns.db.settings and ns.db.settings.enabled) then return false end
    local record = ns.Lookup(kind, id, name)
    if not record then return false end
    local key = kind .. ":" .. tostring(id or name)
    if tooltip._itinKey == key then return false end
    tooltip._itinKey = key
    tooltip:AddLine(TAG_TEXT[record.tag] or TAG_TEXT.exclusive)
    if ns.db.settings.showNote and record.note then
        tooltip:AddLine(record.note, 0.85, 0.82, 0.72, true)
    end
    if ns.db.settings.showSource and record.source then
        tooltip:AddLine("Source: " .. record.source, 0.55, 0.55, 0.55, true)
    end
    if tooltip.Show then tooltip:Show() end
    return true
end
ns.TagTooltip = TagTooltip

local function OnItemTooltip(tooltip)
    if not tooltip or not tooltip.GetItem then return end
    local name, link = tooltip:GetItem()
    name = SafeStr(name)
    ns.lastItemName, ns.lastItemID = name, ItemIDFromLink(link)
    TagTooltip(tooltip, "item", ns.lastItemID, name)
end

local function OnUnitTooltip(tooltip)
    if not tooltip or not tooltip.GetUnit then return end
    local name, unit = tooltip:GetUnit()
    name = SafeStr(name)
    local guid = unit and UnitGUID and SafeStr(UnitGUID(unit))
    ns.lastUnitName, ns.lastUnitID = name, NpcIDFromGUID(guid)
    TagTooltip(tooltip, "npc", ns.lastUnitID, name)
end

local attached = false
local function Attach()
    if attached then return end
    attached = true
    local usedProcessor = false
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
        and Enum and Enum.TooltipDataType then
        if Enum.TooltipDataType.Item then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,
                function(tooltip) OnItemTooltip(tooltip) end)
            usedProcessor = true
        end
        if Enum.TooltipDataType.Unit then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit,
                function(tooltip) OnUnitTooltip(tooltip) end)
            usedProcessor = true
        end
    end
    if not usedProcessor and GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetItem", OnItemTooltip)
        GameTooltip:HookScript("OnTooltipSetUnit", OnUnitTooltip)
    end
    if GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipCleared", function(tooltip)
            tooltip._itinKey = nil
        end)
    end
    ns.hookMode = usedProcessor and "TooltipDataProcessor" or "HookScript"
end
ns.AttachTooltipHooks = Attach

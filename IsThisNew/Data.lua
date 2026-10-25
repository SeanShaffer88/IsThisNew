-- IsThisNew? - Seed provenance database (v0.1)
--
-- HONESTY RULES for this file (they are the product):
-- 1. Every record was transcribed from a cited source. The seed set is
--    the named items and NPCs of the SecretGPS WoW: Forever catalog
--    (~/workspace/secretgps), whose entries cite the guides in each
--    record's `source` field. Nothing here is from memory.
-- 2. NO item or NPC IDs are recorded in v0.1, because no source above
--    publishes them and inventing IDs would tag the wrong things.
--    Matching is by exact name until the /itin dump collector harvest
--    on the live Nov 4 build produces verified IDs (the ByID tables
--    below exist for those records; a record gains an `id` field only
--    with a dump or a published source behind it).
-- 3. Where a source names a set or a reward tier but not the individual
--    item names (e.g. the Blessing of Kalimdor pieces, the Al'aketh
--    gear Brother Zendraas sells), those items are NOT seeded.
-- 4. tag = "exclusive" (did not exist before Forever) or "changed"
--    (existed in Classic, plays a new or altered role in Forever).
--    There is deliberately NO "classic" tag in v0.1: absence from this
--    small database is not evidence of anything.
local _, ns = ...

ns.Records = ns.Records or {}
local function Add(r) ns.Records[#ns.Records + 1] = r end

local WOWDB = "https://wowdb.wiki/forever/guides/secrets-and-hidden-quests"
local BOOKS = "https://lostwow.com/ForeverLibraryBooks.shtml"
local CITYPETS = "https://lostwow.com/ForeverCityPets.shtml"
local SHOVEL = "https://lostwow.com/ForeverGraverobbersShovel.shtml"
local RUINS = "https://lostwow.com/ForeverRuinsOfLordaeron.shtml"
local ZENDRAAS = "https://lostwow.com/ForeverZendraas.shtml"
local HIDDENQ = "https://lostwow.com/ForeverHiddenQuests.shtml"
local TOME = "https://www.warcrafttavern.com/forever/news/tome-of-dalaran-mystery-solved-in-wow-forever/"
local KEYSTONE = "https://www.warcrafttavern.com/forever/news/secret-finders-are-investigating-a-keystone-fragment-in-wow-forever/"

-- ================= Items: Forever Exclusive =================

Add({ kind = "item", name = "Cozy Sleeping Bag", tag = "exclusive", source = WOWDB,
      note = "Sleeping in it grants up to +3% XP. End reward of the four-zone jumping-puzzle chain that starts at a burnt camp in Westfall (Alliance) or The Barrens (Horde)." })
Add({ kind = "item", name = "Scholarly Pendant", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: necklace choice when you hand in 10 books to your faction librarian." })
Add({ kind = "item", name = "Erudite's Amulet", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: necklace choice when you hand in 10 books to your faction librarian." })
Add({ kind = "item", name = "Field Researcher's Loop", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: ring choice when you hand in 20 books (level 20)." })
Add({ kind = "item", name = "Philanthropist's Ring", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: ring choice when you hand in 20 books (level 20)." })
Add({ kind = "item", name = "Truthseeker's Bow", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: choice at 25 books (level 30 quest). Players call it the best bow at its level." })
Add({ kind = "item", name = "Crest of Elucidation", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: shield choice at 25 books (needs level 40)." })
Add({ kind = "item", name = "Researcher's Night Light", tag = "exclusive", source = BOOKS,
      note = "Library Books reward: off-hand choice at 25 books (needs level 40)." })
Add({ kind = "item", name = "Musical Gustjumper", tag = "exclusive", source = WOWDB,
      note = "Companion pet: sing (/sing) to five frogs on Zephras Isle, the Skyborne starting zone." })
Add({ kind = "item", name = "Excitable Slime", tag = "exclusive", source = CITYPETS,
      note = "Companion pet from the Forever city-pet hunt." })
Add({ kind = "item", name = "Baby Crocolisk", tag = "exclusive", source = CITYPETS,
      note = "Companion pet from the Forever city-pet hunt." })
Add({ kind = "item", name = "Night Watchman's Torch", tag = "exclusive", source = CITYPETS,
      note = "Toy: can be lit every 30 seconds." })
Add({ kind = "item", name = "Rockslicer", tag = "exclusive", source = WOWDB,
      note = "Two-hand axe that harvests Copper, Tin, Silver and Iron veins without the Mining profession." })
Add({ kind = "item", name = "First Mate Band", tag = "exclusive", source = WOWDB,
      note = "Ring. At level 60, worn with Band of the Better Half it forms the Partners in Crime set: +20 Strength and a chance to become Angry (+50 Strength)." })
Add({ kind = "item", name = "Band of the Better Half", tag = "exclusive", source = WOWDB,
      note = "Ring. At level 60, worn with First Mate Band it forms the Partners in Crime set: +20 Strength and a chance to become Angry (+50 Strength)." })
Add({ kind = "item", name = "Wolf's Bane", tag = "exclusive", source = WOWDB,
      note = "Weapon that punishes wolves and worgen." })
Add({ kind = "item", name = "Coldflame Saber", tag = "exclusive", source = WOWDB,
      note = "Sword: +98 Fire damage against frozen targets." })
Add({ kind = "item", name = "Graverobber's Shovel", tag = "exclusive", source = SHOVEL,
      note = "Two-hand mace from the graverobber hunt - and whatever its graves contain." })
Add({ kind = "item", name = "Scepter of the Abandoned", tag = "exclusive", source = RUINS,
      note = "Loot of The Abandoned, a secret boss in the Ruins of Lordaeron." })
Add({ kind = "item", name = "Rotmender's Leggings", tag = "exclusive", source = RUINS,
      note = "Loot from the Ruins of Lordaeron secret bosses; part of the Rotmender's Raiment set hunt." })
Add({ kind = "item", name = "Repurposed Hair Band", tag = "exclusive", source = HIDDENQ,
      note = "Cloth wrists (+2 Intellect, +2 Spirit), reward of the Silver of the Waves hidden quest." })
Add({ kind = "item", name = "Malignant Root", tag = "exclusive", source = HIDDENQ,
      note = "Ring with no level requirement: +7 Stamina, +8 Attack Power, +spell power." })
Add({ kind = "item", name = "Burnt Page", tag = "exclusive", source = KEYSTONE,
      note = "Found in the hidden room at Thoradin's Wall; starts the still-unsolved Keystone Fragment mystery." })
Add({ kind = "item", name = "Keystone Fragment", tag = "exclusive", source = KEYSTONE,
      note = "Part of the unsolved Thoradin's Wall mystery chain that begins with the Burnt Page." })
Add({ kind = "item", name = "Stone Key", tag = "exclusive", source = KEYSTONE,
      note = "Obtained during the Keystone Fragment mystery. Its use is still unknown." })
Add({ kind = "item", name = "Black Tome", tag = "exclusive", source = TOME,
      note = "Taken from the alchemy table behind Arugal's room in Shadowfang Keep; starts the Tome of Dalaran chain." })
Add({ kind = "item", name = "Tome of Dalaran", tag = "exclusive", source = TOME,
      note = "Made from the Black Tome at the Ambermill Leyline Focus. Used at the summoning circle in the City of Dalaran dungeon to summon Lyn the Ignored." })

-- ================= NPCs: Forever Exclusive =================

Add({ kind = "npc", name = "Lyn the Ignored", tag = "exclusive", source = TOME,
      note = "Secret boss summoned with the Tome of Dalaran in the City of Dalaran dungeon." })
Add({ kind = "npc", name = "Atrexis the Grave Knight", tag = "exclusive", source = TOME,
      note = "Boss in the City of Dalaran dungeon, on the path to the room where Lyn the Ignored is summoned." })
Add({ kind = "npc", name = "Garion Wendell", tag = "exclusive", source = BOOKS,
      note = "Stormwind librarian: hand Library Books to him for the Librarian reward tiers." })
Add({ kind = "npc", name = "Owen Thadd", tag = "exclusive", source = BOOKS,
      note = "Undercity librarian: hand Library Books to him for the Librarian reward tiers." })
Add({ kind = "npc", name = "Brother Zendraas", tag = "exclusive", source = ZENDRAAS,
      note = "Windstone vendor: sells 24 pieces of Al'aketh cloth, leather and mail gear for Windstones." })
Add({ kind = "npc", name = "The Abandoned", tag = "exclusive", source = RUINS,
      note = "Secret boss in the Ruins of Lordaeron. Drops the Scepter of the Abandoned." })
Add({ kind = "npc", name = "Viktor the Vile", tag = "exclusive", source = RUINS,
      note = "Secret boss in the Ruins of Lordaeron; part of the Rotmender's Raiment set hunt." })

-- ================= Changed in Forever =================

Add({ kind = "npc", name = "Archmage Ataeric", tag = "changed", source = TOME,
      note = "The Classic Ambermill archmage, in a new Forever role: the Leyline Focus by his town hall turns the Black Tome into the Tome of Dalaran." })

-- ================= Indexes =================
-- Lookup order is ID first, then exact (case-insensitive) name. The
-- ByID tables are empty in the shipped v0.1 data - they fill as
-- collector-verified ID records are added to the seed file.

ns.ByName = { item = {}, npc = {} }
ns.ByID = { item = {}, npc = {} }

local function BuildIndexes()
    ns.ByName = { item = {}, npc = {} }
    ns.ByID = { item = {}, npc = {} }
    for i = 1, #ns.Records do
        local r = ns.Records[i]
        if r and (r.kind == "item" or r.kind == "npc") and type(r.name) == "string" then
            ns.ByName[r.kind][r.name:lower()] = r
            if type(r.id) == "number" then ns.ByID[r.kind][r.id] = r end
        end
    end
end
ns.BuildIndexes = BuildIndexes
BuildIndexes()

-- Find a record: kind is "item" or "npc"; id (number or nil) wins over
-- name; name matching is exact and case-insensitive. Returns the record
-- or nil. A nil return means UNKNOWN - never read it as "classic".
local function Lookup(kind, id, name)
    if kind ~= "item" and kind ~= "npc" then return nil end
    if type(id) == "number" and ns.ByID[kind][id] then
        return ns.ByID[kind][id]
    end
    if type(name) == "string" and name ~= "" then
        return ns.ByName[kind][name:lower()]
    end
    return nil
end
ns.Lookup = Lookup

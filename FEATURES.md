# IsThisNew? — Features

## Tooltip provenance (v0.1.0)
- Item tooltip tagging: **Forever Exclusive** / **Changed in Forever** line for seeded items.
- NPC (unit) tooltip tagging: same treatment on mouseover.
- Optional note line per record (on by default): what the thing is and where it comes from.
- Optional source line per record (off by default): the guide URL behind the record.
- Matching precedence: verified ID first, exact case-insensitive name second.
- Deduplication: a tooltip is tagged once per content; the tag resets when the tooltip clears, so reused tooltip frames tag fresh content correctly.
- Secret-value safe: tooltip reads are guarded so a secret value is skipped, never compared or formatted.
- Hook strategy: `TooltipDataProcessor` post-calls where the client offers them, `GameTooltip` script hooks as fallback; `/itin debug` reports which path attached.

## Database
- 35 seed records (27 items, 8 NPCs; 34 Forever Exclusive, 1 Changed in Forever), every one transcribed from a cited source — the SecretGPS Forever catalog's guides (wowdb.wiki, Lost WOW, Warcraft Tavern).
- No invented IDs: the shipped seed is name-keyed; ID records only enter the database with an in-game `/itin dump` or a published source behind them.
- No "Classic" tag in v0.1, by design: absence from the database is unknown, not evidence.

## Chat commands (`/itin`, `/isthisnew`)
- `on` / `off` — enable/disable tagging (database untouched).
- `note` / `source` — toggle the note and source lines.
- `lookup <name|id>` — answer from chat, with honest miss wording.
- `dump` — collector: mouseover + target NPC IDs (from GUIDs) and the last item tooltip's item ID (from its link), for building the verified-ID database.
- `stats` — record counts by kind and tag.
- `debug` — version, client build, hook mode.

## Settings
- SavedVariables `IsThisNewDB`, shape-validated and version-stamped on load; a save from a newer version is never downgraded.
- Settings: `enabled` (default on), `showNote` (default on), `showSource` (default off).

## Not features (deliberate)
- No quest or spell tooltip tagging in v0.1 (roadmap).
- No user-editable database UI: data ships as a reviewed Lua file so every record stays auditable in a diff.
- No combat interaction of any kind.

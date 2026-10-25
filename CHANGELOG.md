# Changelog

## 0.1.0 — 2026-10-24 (pre-launch)

First build, for WoW: Forever (Interface 16001) only.

- Item and NPC tooltip provenance tags: **Forever Exclusive** and **Changed in Forever**, with an optional note line (on by default) and source line (off by default).
- Seed database of 35 records (27 items, 8 NPCs) transcribed from the cited guides behind the SecretGPS Forever catalog — wowdb.wiki's Forever secrets guide, Lost WOW (Library Books, City Pets, Graverobber's Shovel, Ruins of Lordaeron, Zendraas, Hidden Quests), and Warcraft Tavern (Tome of Dalaran, Keystone Fragment). Name-keyed matching; no IDs are recorded because no source publishes them and invented IDs would tag the wrong things.
- Matching precedence: verified ID records first, exact case-insensitive name second. Dedupe per tooltip content, reset on tooltip clear. Secret-value-safe tooltip reads.
- Hook strategy: TooltipDataProcessor post-calls preferred, GameTooltip script hooks as fallback; `/itin debug` reports the attached path.
- `/itin` commands: `on|off`, `note`, `source`, `lookup <name|id>` (honest miss wording — "not proof it is Classic"), `dump` (collector: mouseover/target NPC IDs from GUIDs + last item tooltip ID, for the v0.2 verified-ID migration), `stats`, `debug`, `help`.
- SavedVariables `IsThisNewDB`, shape-validated and version-stamped.
- Deliberately absent: a "Classic" tag (a small database cannot prove a negative), quest/spell tooltips, any combat interaction.
- Local gate green (parse + TOC + data audit + version consistency + mocked-API harness). **Runtime in the live Forever client is Unverified** — Forever launches Nov 4, 2026; see docs/VERIFICATION.md.

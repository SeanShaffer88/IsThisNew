# IsThisNew?

## TL;DR

IsThisNew? is a tiny World of Warcraft: Forever addon that answers the question the alternate timeline asks on every loot drop and every mouseover — *"is this new, changed, or am I misremembering Classic?"* It adds one line to item and NPC tooltips — **Forever Exclusive** or **Changed in Forever** — for the things its sourced database knows about, with a short note on what changed or where it comes from. Anything it doesn't know about stays untagged, because untagged means *unknown* — this addon never guesses that something is Classic. It ships with 35 records transcribed from cited Forever guides (the same sources behind the SecretGPS catalog), a `/itin lookup` command that answers from chat with the same honesty, and a `/itin dump` collector that prints real item/NPC IDs in game so the database can graduate from name-matching to verified ID-matching after launch.

See also: `FEATURES.md` (full feature list), `DESCRIPTION.md` (store-listing copy), `CHANGELOG.md` (version history), `docs/SPEC.md` (build spec), `docs/VERIFICATION.md` (what has and hasn't been proven).

## What it does

- **Item tooltips** — a provenance line for seeded items: the Cozy Sleeping Bag, the Library Books reward tiers (Truthseeker's Bow, Scholarly Pendant, …), Rockslicer, Coldflame Saber, Wolf's Bane, the Partners in Crime rings, Malignant Root, the Tome of Dalaran chain items, and more.
- **NPC tooltips** — the same for seeded NPCs: Lyn the Ignored, the Stormwind and Undercity librarians, Brother Zendraas, the Ruins of Lordaeron secret bosses — and Archmage Ataeric, tagged **Changed in Forever** for his new role in the Tome of Dalaran chain.
- **A note, not just a label** — each tag carries a one-line note (what it is, where it comes from), and an optional source line names the guide behind the record, so any tag can be audited.
- **`/itin lookup <name|id>`** — asks the database from chat. A miss answers honestly: *"no record — unknown, which is not proof it is Classic."*
- **`/itin dump`** — the collector: prints the mouseover/target NPC IDs and the last item tooltip's ID, the raw material for the verified-ID database in v0.2.

## Commands

- `/itin` or `/isthisnew` — help
- `/itin on` / `/itin off` — tagging on/off
- `/itin note` — toggle the note line
- `/itin source` — toggle the source line
- `/itin lookup <name|id>` — ask the database
- `/itin dump` — print item/NPC IDs for data collection
- `/itin stats` — database size
- `/itin debug` — version, client build, hook mode

## Install

Unzip so the `IsThisNew` folder sits in your WoW: Forever client's `Interface/AddOns/` folder. Forever only: the `.toc` is interface 16001 (`IsThisNew_Camelot.toc`).

## Honest limits

- **v0.1.0 is a pre-launch build.** It has passed its local gate (Lua parse, data audit, mocked-API harness — see `docs/VERIFICATION.md`) but has **not yet run in the live client**; Forever launches November 4, 2026, and every record comes from beta-era guides and must be re-verified on the live build.
- **Matching is by exact name in v0.1**, because no cited source publishes the Forever item/NPC IDs and inventing IDs would tag the wrong things. A same-named Classic item could in principle be tagged by mistake; ID records (collected with `/itin dump`) take precedence over names as they are added, and v0.2 migrates the seed to verified IDs.
- **No "Classic" tag, deliberately.** A database this size cannot prove a negative. Untagged means unknown.
- IsThisNew? only reads tooltip data and displays its own lines. It touches no combat data, casts nothing, and automates nothing.

## Screenshots

Screenshots will be added from real runs on the live client (see `docs/screenshots/CAPTURE.md` for the capture list). No placeholder images.

## License

MIT — see `LICENSE`.

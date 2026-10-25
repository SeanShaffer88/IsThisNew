# IsThisNew? — Build Spec (v0.1.0)

The full five-addon spec bundle (IsThisNew?, LFG Lens, Party Quest Roll
Call, Fallen Journal, MulePost) lives with the project records as
`wow-forever-addon-specs-all-five.md`. This file is the IsThisNew?
build summary.

**Client:** WoW: Forever only — Interface 16001, `IsThisNew_Camelot.toc`,
modern Mainline-derived API, addon disarmament rules respected (display
only, no combat data, no logic on secret values).

**Product rule (load-bearing):** tag only positive matches —
`Forever Exclusive`, `Changed in Forever`. Untagged = unknown. There is
no "Classic" tag until the database passes a published coverage bar;
shipping one on a 35-record seed would be guessing, and a wrong
provenance tool is worse than none (the beta's inaccurate "IRS"
gold-audit addon is the cautionary precedent in the ecosystem research).

**MVP (as built):**
1. Item + NPC tooltip tag line, optional note line (default on),
   optional source line (default off).
2. Matching: ID first (itemID from the tooltip link, NPC ID from the
   unit GUID), exact case-insensitive name second. Dedupe per tooltip
   content key, reset on `OnTooltipCleared`.
3. Seed DB: 35 records, name-keyed, every record carrying `note` and a
   `source` URL transcribed from the SecretGPS Forever catalog's cited
   guides. No invented IDs; sets/tiers whose individual item names no
   source names are not seeded.
4. `/itin dump` collector mode — prints mouseover/target NPC IDs and
   the last item tooltip ID, the bootstrap for the v0.2 verified-ID
   migration on the live Nov 4 build.
5. `/itin lookup` with honest miss wording; settings in versioned,
   shape-validated SavedVariables (`enabled`, `showNote`, `showSource`).

**Spike list (live build, Nov 4):** confirm TooltipDataProcessor
Item/Unit post-calls fire on Forever; confirm GUID NPC-ID field
position; confirm `GetItem()` link format; run the CAPTURE.md list.
Fallback already built: GameTooltip HookScript path if the processor
path does not attach (`/itin debug` reports which is live).

**Kill criterion:** if the live build blocks both tooltip hook paths,
stop — no frame-scraping workarounds.

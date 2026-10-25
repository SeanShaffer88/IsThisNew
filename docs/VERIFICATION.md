# IsThisNew? — Verification

## v0.1.0 (2026-10-24)

| Check | Result |
|---|---|
| Local gate (`python3 tools/gate.py`): Lua parse (luaparser) for all files | **PASS** (2026-10-24, run by Muse: parse ok ×3, schema 35 records 0 problems, version 0.1.0 consistent, harness PASS) |
| TOC cross-check: interface 16001, every .lua listed, no unlisted files | Gate |
| Data audit: 35 records, every record has kind/tag/note + http source, no duplicate names per kind, no "classic" tag present | Gate |
| Version consistency: TOC == Core.lua == tools/package.py (0.1.0) | Gate |
| Mocked-API harness (lupa): boot, PLAYER_LOGIN, hook fallback attach | Gate / harness |
| Harness: seeded item tagged Exclusive (+ note, no source while off), repeat show not double-tagged, clear+reshow re-tags | Harness |
| Harness: unknown item and unknown NPC stay silent | Harness |
| Harness: seeded NPC tagged with NPC ID parsed from GUID; Changed NPC (Ataeric) gets the Changed tag | Harness |
| Harness: synthetic ID record wins over name matching | Harness |
| Harness: source toggle, off/on toggle, lookup hit, lookup honest miss, dump output, stats/debug | Harness |
| **Live client (WoW: Forever) runtime** | **Unverified** — Forever launches Nov 4, 2026. Field test: hover the CAPTURE.md list on the live build, run `/itin dump` over seeded items/NPCs to begin the verified-ID migration, screenshot the tooltips. |
| TooltipDataProcessor path in the live client | Unverified — the HookScript fallback is what the harness exercises; `/itin debug` reports which path attaches live. |

Labels follow SEAN's standard: Verified / Partially Verified / Unverified.
A green gate is syntax-and-mock proof only, never a runtime claim.

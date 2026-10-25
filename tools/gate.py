#!/usr/bin/env python3
"""IsThisNew? gate: Lua parse + TOC cross-check + seed-data audit +
version consistency + harness.

Run: python3 tools/gate.py
Exit 0 only when every check passes. This gate proves the files parse,
the seed data obeys the honesty rules (every record sourced, no
invented IDs, no duplicate names), and the addon boots and tags
correctly against a mocked API. It does NOT prove in-game behaviour -
that label stays Unverified until a real client run.
"""
import pathlib
import re
import subprocess
import sys

from luaparser import ast

ROOT = pathlib.Path(__file__).resolve().parent.parent
ADDON = ROOT / "IsThisNew"
TOC = "IsThisNew_Camelot.toc"
EXPECTED_RECORDS = 35  # 27 items + 8 NPCs; bump with the seed, never silently

VALIDATOR_LUA = r"""
function(ns)
  local bad = {}
  local function add(s) bad[#bad + 1] = s end
  local seen = {}
  for i = 1, #ns.Records do
    local r = ns.Records[i]
    local id = (type(r.name) == "string" and r.name) or ("<record " .. i .. ">")
    if r.kind ~= "item" and r.kind ~= "npc" then add(id .. ": kind invalid") end
    if type(r.name) ~= "string" or r.name == "" then add(id .. ": name missing") end
    if r.tag ~= "exclusive" and r.tag ~= "changed" then add(id .. ": tag invalid") end
    if type(r.source) ~= "string" or r.source:sub(1, 4) ~= "http" then add(id .. ": source missing or not http") end
    if type(r.note) ~= "string" or r.note == "" then add(id .. ": note missing") end
    if r.id ~= nil and (type(r.id) ~= "number" or r.id <= 0) then add(id .. ": id not a positive number") end
    local key = tostring(r.kind) .. ":" .. (type(r.name) == "string" and r.name:lower() or "?")
    if seen[key] then add(id .. ": duplicate name for kind") end
    seen[key] = true
  end
  if #ns.Records ~= EXPECTED then
    add("record count " .. #ns.Records .. " != expected " .. EXPECTED)
  end
  return bad
end
"""


def schema_failures():
    try:
        import lupa
    except ImportError:
        return ["lupa not available for schema validation"]
    lua = lupa.LuaRuntime()
    lua.globals().EXPECTED = EXPECTED_RECORDS
    validate = lua.eval(VALIDATOR_LUA)
    ns = lua.table()
    ns.Records = lua.table()
    chunk = lua.compile((ADDON / "Data.lua").read_text())
    chunk("IsThisNew", ns)
    bad = validate(ns)
    problems = [bad[i] for i in range(1, len(bad) + 1)]
    print(f"schema: {len(ns.Records)} records, {len(problems)} problem(s)")
    return [f"schema: {p}" for p in problems]


def main():
    failures = []
    lua_files = sorted(ADDON.glob("*.lua"))
    for path in lua_files:
        try:
            ast.parse(path.read_text())
            print(f"parse ok: {path.name}")
        except Exception as exc:
            failures.append(f"parse FAIL {path.name}: {exc}")
    lines = (ADDON / TOC).read_text().splitlines()
    listed = [ln.strip() for ln in lines if ln.strip().endswith(".lua")]
    iface = [ln for ln in lines if ln.startswith("## Interface:")]
    print(f"{TOC}: interface {iface} files {listed}")
    if iface != ["## Interface: 16001"]:
        failures.append(f"{TOC} interface is {iface}, want 16001 (Forever only)")
    for name in listed:
        if not (ADDON / name).exists():
            failures.append(f"{TOC} lists missing file {name}")
    for path in lua_files:
        if path.name not in listed:
            failures.append(f"{path.name} exists but is not in the TOC")
    # Data honesty: the seed file must never carry a "classic" tag -
    # v0.1 tags positive matches only (see docs/SPEC.md).
    data_text = (ADDON / "Data.lua").read_text()
    if re.search(r'tag\s*=\s*"classic"', data_text):
        failures.append('Data.lua contains a "classic" tag - not allowed in v0.1')
    failures += schema_failures()
    versions = {}
    m = re.search(r"^## Version:\s*(\S+)", (ADDON / TOC).read_text(), re.M)
    versions[TOC] = m.group(1) if m else None
    m = re.search(r'ns\.VERSION = "([^"]+)"', (ADDON / "Core.lua").read_text())
    versions["Core.lua"] = m.group(1) if m else None
    m = re.search(r'^VERSION = "([^"]+)"',
                  (ROOT / "tools" / "package.py").read_text(), re.M)
    versions["package.py"] = m.group(1) if m else None
    if len(set(versions.values())) == 1 and None not in versions.values():
        print(f"version consistency: {versions['Core.lua']} in all 3 places")
    else:
        failures.append(f"version mismatch: {versions}")
    proc = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "harness.py")],
        capture_output=True, text=True)
    print(proc.stdout)
    if proc.returncode != 0:
        failures.append("harness FAIL")
        print(proc.stderr)
    if failures:
        print("GATE: FAIL")
        for f in failures:
            print(" -", f)
        sys.exit(1)
    print("GATE: PASS (parse + toc + data audit + version + harness)")


if __name__ == "__main__":
    main()

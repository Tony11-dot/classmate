#!/usr/bin/env python3
import sys, pathlib

def die(msg):
    print("patch.py:", msg, file=sys.stderr)
    sys.exit(1)

if len(sys.argv) < 4:
    die("usage: patch.py <file> <find> <replace>")

path = pathlib.Path(sys.argv[1])
find = sys.argv[2]
replace = sys.argv[3]

if not path.exists():
    die(f"file not found: {path}")

s = path.read_text(encoding="utf-8")
if find not in s:
    die("find string not found (nothing changed)")

path.write_text(s.replace(find, replace, 1), encoding="utf-8")
print(f"OK patched: {path}")

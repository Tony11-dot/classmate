#!/usr/bin/env python3
import sys, pathlib, re

def die(msg):
    print("patchre.py:", msg, file=sys.stderr)
    sys.exit(1)

if len(sys.argv) < 4:
    die("usage: patchre.py <file> <pattern> <replace>")

path = pathlib.Path(sys.argv[1])
pat = sys.argv[2]
rep = sys.argv[3]

if not path.exists():
    die(f"file not found: {path}")

s = path.read_text(encoding="utf-8")
rx = re.compile(pat, re.MULTILINE)

m = rx.search(s)
if not m:
    die("pattern not found (nothing changed)")

out = rx.sub(rep, s, count=1)
path.write_text(out, encoding="utf-8")
print(f"OK patched: {path}")

"""Count bit toggles per signal name in a VCD file (2026-11 recovery audit).

Usage: python vcd_toggle_count.py file1.vcd [file2.vcd ...]
Prints, for every signal name, (total bit toggles, value changes) summed over
all instances. Used to check whether the SADCG RTL changes multiplier register
switching relative to the base RTL.
"""
import collections
import sys


def parse(path):
    ids = {}
    last = {}
    toggles = collections.Counter()
    changes = collections.Counter()
    with open(path) as fh:
        for line in fh:
            tok = line.split()
            if not tok:
                continue
            if tok[0] == "$var":
                ids.setdefault(tok[3], []).append(tok[4])
            elif tok[0][0] == "b" and len(tok) == 2:
                val, ident = tok[0][1:], tok[1]
                if ident in last:
                    a, b = last[ident], val
                    width = max(len(a), len(b))
                    a, b = a.rjust(width, "0"), b.rjust(width, "0")
                    toggles[ident] += sum(x != y for x, y in zip(a, b))
                    changes[ident] += 1
                last[ident] = val
    per_name = collections.Counter()
    per_name_changes = collections.Counter()
    for ident, names in ids.items():
        for name in set(names):
            per_name[name] += toggles[ident]
            per_name_changes[name] += changes[ident]
    return per_name, per_name_changes


if __name__ == "__main__":
    for vcd in sys.argv[1:]:
        tog, chg = parse(vcd)
        print(vcd)
        for name in sorted(tog):
            print(f"  {name:12s} bit_toggles={tog[name]:>10d} value_changes={chg[name]:>8d}")

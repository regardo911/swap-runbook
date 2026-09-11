#!/usr/bin/env python3
"""sheet.py — Chapter 4. Turn one run's raw agent output plus the evaluator's
exit code into four numbers.

    sheet.py <alias> <wall-seconds> <checker-exit-code> <raw-json-file>

The three input figures get summed. Cached reads and cache writes are real
tokens that were really sent, and the uncached input_tokens field on its own is
small enough to make a run look free.
"""
import json
import sys

model, wall, passed, raw_path = sys.argv[1:5]
d = json.loads(open(raw_path).read())
u = d.get("usage", {})
tok_in = (u.get("input_tokens", 0)
          + u.get("cache_read_input_tokens", 0)
          + u.get("cache_creation_input_tokens", 0))
tok_out = u.get("output_tokens", 0)

reason = {"0": "pass", "1": "json contract wrong", "2": "test suite failed",
          "3": "no work dir"}.get(passed, f"exit {passed}")
print(f"{model:<10} {reason:<20} in={tok_in:<8} out={tok_out:<6} "
      f"turns={d.get('num_turns', 0):<3} {wall}s  ${d.get('total_cost_usd', 0.0):.4f}")

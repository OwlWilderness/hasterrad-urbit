#!/usr/bin/env python3
"""Emit a retained native assertion fragment as a %fyrd strand body.

This prepares text only. It does not connect to a ship or execute Hoon.
"""
from pathlib import Path
import argparse

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('case', choices=['levels', 'wave', 'agent', 'opening', 'gentle', 'no-carry'])
args = parser.parse_args()
desk = root / 'desk'
core = (desk / 'lib/hasterrad-core.hoon').read_text()
head = '=/  hasterrad-enemies  ' + (desk / 'lib/hasterrad-enemies.hoon').read_text() + '\n=/  c  ' + core.split('\n', 1)[1] + '\n'
if args.case in ('agent', 'no-carry'):
    skeleton = '\n'.join(line for line in (desk / 'lib/skeleton.hoon').read_text().splitlines() if not line.lstrip().startswith('::'))
    default = (desk / 'lib/default-agent.hoon').read_text().split('\n', 1)[1]
    agent = (desk / 'app/hasterrad.hoon').read_text().split('\n', 2)[2]
    head += '=/  hasterrad-core  c\n=/  skeleton  ' + skeleton + '\n=/  default-agent  ' + default + '\n=/  a  =,  c\n=>  ' + agent + '\n'
code = head + (root / 'tests/native' / (args.case + '.hoon')).read_text() + '\n=/  m  (strand ,vase)\n(pure:m !>(%polish-pass))'
print('\n'.join(line for line in code.splitlines() if not line.lstrip().startswith('::')))

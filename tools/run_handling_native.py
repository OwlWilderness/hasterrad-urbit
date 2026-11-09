#!/usr/bin/env python3
"""Offline pure Ivory handling check; no pier, Gall, network or ship claims."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--case', choices=['handling', 'levels'], default='handling')
p.add_argument('--image', required=True, help='Already-local image with /bin/urbit; no pull is allowed')
p.add_argument('--receipt-dir', required=True, type=Path)
a = p.parse_args()
a.receipt_dir.mkdir(parents=True, exist_ok=False)
paths = ['desk/lib/hasterrad-enemies.hoon', 'desk/lib/hasterrad-core.hoon', 'tests/native/' + a.case + '.hoon']
(a.receipt_dir / 'runner.py').write_bytes(Path(__file__).read_bytes())
inputs = {path: (ROOT / path).read_bytes() for path in paths}
code = ('=/  hasterrad-enemies  ' + inputs[paths[0]].decode() + '\n=/  c  ' + inputs[paths[1]].decode().split('\n', 1)[1] + '\n' + inputs[paths[2]].decode() + '\n%handling-pass\n')
code = '\n'.join(line for line in code.splitlines() if not line.lstrip().startswith('::')) + '\n'
(a.receipt_dir / 'evaluated.hoon').write_text(code)
for path, data in inputs.items():
    destination = a.receipt_dir / 'inputs' / path
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(data)
command = ['docker', 'run', '--rm', '--pull=never', '--platform', 'linux/amd64', '--network', 'none', '--read-only', '-i', '--entrypoint', '/bin/urbit', a.image, 'eval', '-n']
result = subprocess.run(command, input=code.encode(), capture_output=True, timeout=90)
(a.receipt_dir / 'stdout.txt').write_bytes(result.stdout)
(a.receipt_dir / 'stderr.txt').write_bytes(result.stderr)
clean = re.sub(r'\x1b\[[0-9;]*m', '', (result.stdout + result.stderr).decode(errors='replace'))
passed = result.returncode == 0 and any(line.strip() == '%handling-pass' for line in clean.splitlines()) and 'eval: bail:' not in clean
receipt = {'command': command, 'cwd': str(ROOT), 'returncode': result.returncode, 'passed': passed, 'sha256': {path: hashlib.sha256(data).hexdigest() for path, data in inputs.items()}, 'evaluated_sha256': hashlib.sha256(code.encode()).hexdigest()}
(a.receipt_dir / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(clean)
print(json.dumps(receipt, indent=2))
raise SystemExit(0 if passed else 1)

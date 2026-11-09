#!/usr/bin/env python3
"""Rebuild the complete fingerprinted public graph from portable source inputs."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / 'frontend/public'
SOURCE = ROOT / 'frontend/source'
assert SOURCE.is_dir() and PUBLIC.parent == SOURCE.parent
if PUBLIC.exists():
    shutil.rmtree(PUBLIC)
shutil.copytree(SOURCE, PUBLIC)
mapping = {}
files = list((PUBLIC / 'assets').glob('*.mjs')) + [PUBLIC / 'assets/style.css']
while files:
    progress = False
    for path in list(files):
        text = path.read_text()
        deps = re.findall(r"(?:from\s*|import\s*)['\"]\./([^'\"]+)['\"]", text)
        if any((PUBLIC / 'assets' / dep) in files for dep in deps):
            continue
        for old, new in mapping.items():
            text = text.replace(old, new)
        data = text.encode()
        name = path.stem + '.' + hashlib.sha256(data).hexdigest()[:12] + path.suffix
        (path.parent / name).write_bytes(data)
        mapping[path.name] = name
        path.unlink()
        files.remove(path)
        progress = True
    assert progress, 'Cyclic module dependencies'
index = PUBLIC / 'index.html'
text = index.read_text()
for old, new in mapping.items():
    text = text.replace('assets/' + old, 'assets/' + new)
index.write_text(text)
(ROOT / 'frontend/asset-map.json').write_text(json.dumps(mapping, indent=2, sort_keys=True))
manifest = []
for path in sorted(PUBLIC.rglob('*')):
    if not path.is_file():
        continue
    data = path.read_bytes()
    manifest.append({'path': str(path.relative_to(PUBLIC)), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
    if path.suffix in ('.html', '.mjs'):
        for ref in re.findall(r'''(?:src=|href=|from\s*|import\s*)['"]([^'"]+)['"]''', path.read_text()):
            if ref.startswith(('assets/', './')):
                assert (path.parent / ref).is_file(), ref
    if re.search(r'\.[0-9a-f]{12}\.(mjs|css)$', path.name):
        assert path.name.split('.')[-2] == hashlib.sha256(data).hexdigest()[:12]
assert len(manifest) == len([p for p in SOURCE.rglob('*') if p.is_file()])
for canonical, packaged in [('LICENSE', 'hasterrad.txt'), ('THIRD-PARTY-NOTICES.md', 'THIRD-PARTY-NOTICES.md'), ('licenses/urbit-native.txt', 'urbit-native.txt')]:
    assert (ROOT / canonical).read_bytes() == (PUBLIC / 'licenses' / packaged).read_bytes(), canonical
assert (PUBLIC / 'licenses/index.html').is_file()
build = ROOT / '.build'
build.mkdir(exist_ok=True)
(build / 'public-manifest.json').write_text(json.dumps(manifest, indent=2))
archive = build / 'hasterrad-public.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as output:
    for item in manifest:
        output.write(PUBLIC / item['path'], item['path'])
with zipfile.ZipFile(archive) as output:
    assert sorted(output.namelist()) == sorted(item['path'] for item in manifest)
    for item in manifest:
        assert hashlib.sha256(output.read(item['path'])).hexdigest() == item['sha256']
print(f'Built and verified {len(manifest)} frontend files; archive: .build/hasterrad-public.zip')

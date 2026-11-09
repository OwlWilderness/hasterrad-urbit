#!/usr/bin/env python3
"""Self-contained source closure checks; not a native Hoon compiler."""
from pathlib import Path
import base64
import hashlib
import json
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]

class SourceContract(unittest.TestCase):
    def test_release_hashes(self):
        manifest = json.loads((ROOT / 'source-manifest.json').read_text())
        for entry in manifest['files']:
            with self.subTest(path=entry['path']):
                self.assertEqual(hashlib.sha256((ROOT / entry['path']).read_bytes()).hexdigest(), entry['sha256'])

    def test_fresh_install_descriptor(self):
        text = (ROOT / 'desk/desk.docket-0').read_text()
        self.assertEqual(re.findall(r'glob-ames\+\[(~[a-z-]+) (0v[\w.]+)\]', text), [('~sitnup-ronsym-dirted-pallup', '0v0')])
        self.assertIn("info+'An asteroid shooter with Urbit sigils.'", text)
        match = re.search(r"image\+'data:image/png;base64,([^']+)'", text)
        assert match is not None
        image = match.group(1)
        self.assertTrue(base64.b64decode(image, validate=True).startswith(b'\x89PNG\r\n\x1a\n'))
        for name in ('ship', 'docket-0', 'bill', 'kelvin', 'mime', 'json', 'noun', 'hoon', 'txt'):
            self.assertTrue((ROOT / 'desk/mar' / (name + '.hoon')).is_file())
        self.assertEqual((ROOT / 'desk/sys.kelvin').read_text().strip(), '[%zuse 408]')

    def test_local_frontend_dependency_closure(self):
        public = ROOT / 'frontend/public'
        html = (public / 'index.html').read_text()
        for ref in re.findall(r'(?:src|href)="(assets/[^"#?]+)', html):
            self.assertTrue((public / ref).is_file(), ref)
        for source in (public / 'assets').glob('*.mjs'):
            for ref in re.findall(r"(?:from\s*|import\s*)['\"](\./[^'\"]+)['\"]", source.read_text()):
                self.assertTrue((source.parent / ref).is_file(), ref)
        self.assertIn('One active game tab per ship.', html)
        self.assertEqual(len(list((public / 'licenses').glob('*.txt'))), 11)
        self.assertIn('https://github.com/OwlWilderness/hasterrad-urbit', html)
        mapping = json.loads((ROOT / 'frontend/asset-map.json').read_text())
        self.assertEqual(len(mapping), 7)
        for name in mapping.values():
            data = (public / 'assets' / name).read_bytes()
            self.assertEqual(name.split('.')[-2], hashlib.sha256(data).hexdigest()[:12])

    def test_source_authority_contract(self):
        agent = (ROOT / 'desk/app/hasterrad.hoon').read_text()
        core = (ROOT / 'desk/lib/hasterrad-core.hoon').read_text()
        self.assertIn('(scag 4 shots.w.s)', agent)
        self.assertIn('saved  [%5', agent)
        self.assertIn('(gte (lent shots.w.s) 4)', agent)
        self.assertIn('pressed.d &(fire.input.d !fire.input.s)', agent)
        self.assertIn('=(our.bowl src.bowl)', agent)
        self.assertIn('(lent shots.', core)
        # Contract sentinels only: behavioral proof is the retained native qualification.
        for path in [* (ROOT / 'desk').rglob('*'), * (ROOT / 'frontend/public').rglob('*')]:
            if path.is_file():
                data = path.read_bytes()
                for forbidden in (b'/Users/', b'hasterrad-pubtest', b'.dappnode.private', b'PRIVATE KEY-----'):
                    self.assertNotIn(forbidden, data, str(path.relative_to(ROOT)))

if __name__ == '__main__':
    unittest.main()

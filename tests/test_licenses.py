"""Distribution-license contract; not a legal-clearance test."""
from pathlib import Path
import hashlib
import json
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]

class LicensePayload(unittest.TestCase):
    def test_distribution_carries_complete_notices(self):
        public = ROOT / 'frontend/public'
        self.assertTrue((public / 'licenses/hasterrad.txt').is_file(), 'frontend omits first-party MIT license')
        self.assertEqual((ROOT / 'LICENSE').read_bytes(), (public / 'licenses/hasterrad.txt').read_bytes())
        self.assertEqual((ROOT / 'THIRD-PARTY-NOTICES.md').read_bytes(), (public / 'licenses/THIRD-PARTY-NOTICES.md').read_bytes())
        manifest = json.loads((ROOT / 'license-manifest.json').read_text())
        for entry in manifest['notices']:
            for tree in ('source', 'public'):
                data = (ROOT / 'frontend' / tree / 'licenses' / entry['file']).read_bytes()
                self.assertEqual(hashlib.sha256(data).hexdigest(), entry['sha256'])
                self.assertIn(b'Permission is hereby granted', data)
                self.assertIn(b'WARRANTY', data)
        self.assertEqual((ROOT / 'licenses/urbit-native.txt').read_bytes(), (public / 'licenses/urbit-native.txt').read_bytes())
        self.assertIn('licenses/index.html', (public / 'index.html').read_text())
        index = (public / 'licenses/index.html').read_text()
        for entry in manifest['notices']:
            self.assertIn(entry['file'], index)
        with zipfile.ZipFile(ROOT / '.build/hasterrad-public.zip') as archive:
            expected = {str(p.relative_to(public)) for p in public.rglob('*') if p.is_file()}
            self.assertEqual(set(archive.namelist()), expected)
            for name in archive.namelist():
                self.assertEqual(archive.read(name), (public / name).read_bytes())

if __name__ == '__main__':
    unittest.main()

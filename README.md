# HASTERRAD — native Urbit game

An asteroid shooter with Urbit sigils. **Hoon owns the game; JavaScript renders it and transports controls.** Version **0.0.1** is the initial experimental source release; see [VERSION](VERSION) and [CHANGELOG.md](CHANGELOG.md). It includes the accepted gentle-levels, Info, one-button UI and licensed 29-file frontend. The released runtime and frontend bytes are unchanged from accepted build `0f6e80fc5ab52ab0cf31e3be5b91ba2fc7786aeb`. That released version contains no player-speed/turn tuning. This branch is a subsequent, unreleased #13 candidate; source publication is separate from live Urbit activation.

## Unreleased handling candidate — Refs #13

Only player handling changes: fixed thrust doubles from 8 to 16 world units per native tick, and rotation doubles from 5 to 10 degrees per tick. The unchanged 100 ms native cadence gives nominal 80 → 160 world units/second and 50 → 100 degrees/second; full rotation takes 7.2 → 3.6 seconds. These rates follow the existing scheduler, not a new live timing measurement. No acceleration or inertia: releasing thrust stops immediately. Left and right cancel. Player bullets remain 24 units/tick (240 units/second), faster than the player. Four-shot press-only fire, cooldown, enemies, levels, collision rules, save version/world molds, protocol, control rate and bounded velocity-based frontend prediction are unchanged.

`tests/native/handling.hoon` is compiled against the actual core using the offline pure Ivory evaluator. It checks movement, turn directions/cancellation, immediate stop, heading/position wrapping, matching turn/thrust direction, bullet speed/cap and a full turn. This is pure-library evidence, not Gall installation, Eyre integration or owner feel acceptance. Existing official-client input/fire evidence is retained for the unchanged agent/frontend; no live watch is opened by this work.

With Docker and an **already-local compatible Urbit image** providing `/bin/urbit eval -n`, run from a clean source snapshot:

```sh
python3 tools/run_handling_native.py --image YOUR_LOCAL_IMAGE --receipt-dir "$TMPDIR/handling-new-receipt"
python3 tools/run_handling_native.py --case levels --image YOUR_LOCAL_IMAGE --receipt-dir "$TMPDIR/levels-new-receipt"
```

Receipt directories must not already exist. The runner disables network access and image pulls, uses no pier mounts, preserves exact evaluated source/output and rejects `eval: bail:` even when Vere exits zero. The tested local image was `ship.uvm.public.dappnode.eth:0.1.323`; the image is not bundled.

The qualified native change is a **single-file source overlay**, `lib/hasterrad-core.hoon`. Its exact staged bytes were independently read back, and the owner subsequently ran `|commit %hasterrad` on the publisher moon: Gall reload was observed with no shown compile error. That commit also included an existing Docket descriptor change and explicitly reported that Docket was awaiting a manual glob. Although no frontend code changed, this actual commit therefore requires the owner to re-glob the existing licensed 29-file `frontend/public/` payload, explicitly selecting **hasterrad**; no additional native commit is needed after that glob. The descriptor-change mechanism is not established. The latest re-glob, current consumer core activation and handling feel/playtest are **not yet confirmed**. #13 remains open for those acceptance gates. Source publication is not a new release or live-acceptance claim; `VERSION` and the frozen v0.0.1 tag/assets remain unchanged.

## Architecture and accepted baseline

- `desk/app/hasterrad.hoon`: Gall agent, existing Eyre session, input sequencing, watches, persisted world and safe control release. The installing ship is the pilot; the publisher is not the player identity. No EAuth, separate login, external HTTP backend or SQLite service is required.
- `desk/lib/hasterrad-core.hoon` and `hasterrad-enemies.hoon`: movement, precise shot/thrust vectors, swept collisions, random valid four-syllable targets, 4 → 2 → 1 fragmentation, armed large/small zods, scoring and host-syllable lives. Rounds end on lost lives, not a 60-second gameplay cap.
- `frontend/public/`: complete prebuilt frontend, official sigil artwork generation, touch controls and bounded presentation interpolation. Art tiles remain inside the directional player triangle and disappear with lives; moon hosts retain their full identity. Presentation never creates authoritative hits, bullets or score.
- `desk/mar/`, `sur/` and support libraries: native metadata/mark closure, including `mar/ship.hoon`. `desk.docket-0` includes a self-contained discovery icon.

### Controls

Arrow Left/Right or **A/D** rotate; Arrow Up or **W** thrust; **Space** fires. Touch buttons provide the same controls. One shared button shows **Start game** when ready and **Play again** at game over, and is hidden while playing, including intermission. Full screen and accessible **Info** are available. Info links to the exact source repository and supports Close/Escape with focus return.

The committed native source permits **at most four simultaneous player projectiles**, not four shots per second. Each distinct press requests one shot; holding or OS key repeat does not autofire. Short taps survive input coalescing, Hoon retains its cooldown, and presses made at capacity are discarded rather than banked. Enemy projectiles are separate. Saved-world loading trims only excess player shots and safety-clears controls, retaining the rest of the world.

**Levels:** Hoon starts Level 1 with two slow rocks/no enemies and Level 2 with three/no enemies. Level 3 allows one large slow zod after about 15 seconds active play; no small enemy before Level 5. Clear all asteroids/fragments to advance through a safe intermission, retaining score/lives. Difficulty grows gradually with caps; the HUD shows level. Saved state migrates from `%4` to `%5`.

**Delivery boundary:** native levels/migration and four-shot behavior have accepted disposable-ship qualification; the one-button UI has accepted isolated-browser fixture-state qualification, not an independently replayed real loss. Parent accepted the frozen combined source; this checkout does not repeat those native campaigns. The owner subsequently committed/globbed the baseline and accepted its appearance; all 29 ordinary consumer frontend files were independently verified. Those accepted baseline results are distinct from the latest #13 commit, whose manual re-glob and consumer handling acceptance remain pending.

One active game tab per installing ship is supported. Closing another game tab may pause this session (#8); this does not pause other subscriber ships. The permanent gold playfield border and warning are included. There is no explicit Quit button: leave using browser Back/close, and exit fullscreen first if necessary (#10).

## Install the published desk

From your own ship's Dojo, the distribution source is the publisher moon, **~sitnup-ronsym-dirted-pallup**, and the desk is **%hasterrad**:

```hoon
|install ~sitnup-ronsym-dirted-pallup %hasterrad
```

Wait for native installation to complete, then open HASTERRAD from Landscape under your existing ship session. `~dirted-pallup` is the known consumer, not the publisher. A UI may abbreviate the moon's identity; use the full publisher above. Do not run a second copy of a real ship identity, uninstall an existing game merely to refresh assets, or bypass Eyre authentication.

This installs whatever the publisher has actually released, **not automatically this Git branch**. Historical consumer installation and complete frontend readbacks were accepted; fresh availability and this candidate's native activation are not asserted here.

### Source installation and frontend releases

The source targets **Kelvin 408**. Start with a compatible native base and qualify a fresh disposable desk before real installation. `desk/` supplies app-specific files and metadata; it is not a ship/pier/bootstrap bundle. Runtime and base libraries come from the compatible Urbit installation.

`desk/desk.docket-0` is deliberately a **fresh-install template**: its glob reference is `0v0`. The inherited production descriptor contained an older nonzero glob and was unsafe to publish as current. Public publisher identity and embedded artwork are retained, but **this descriptor is not a live release reference**.

For an existing publisher, preserve its actual native Docket source/glob and icon. Apply only reviewed changed source paths, then use the publisher's normal native Clay commit workflow. Never copy this template or an old full desk over a newer live descriptor. A source Git commit, a native Clay commit and a frontend Docket glob are different operations. The accepted combined baseline already delivered `app/hasterrad.hoon`, `lib/hasterrad-core.hoon` and `lib/hasterrad-enemies.hoon`. The subsequent #13 overlay changes only `lib/hasterrad-core.hoon`; do not redeploy the full source desk to update handling.

For a frontend release, open the publisher's native glob-upload UI, explicitly select **hasterrad**, and select the entire `frontend/public/` directory (29 files in this licensed build, including complete notices). Do not select the repository root or another desk. Publish a fresh glob only after native source acceptance when both contracts change; border/copy-only changes need a glob, not a Hoon commit. Native-only changes normally need no new frontend glob if the installed descriptor remains unchanged. This is not a blanket exemption: the latest #13 owner commit touched Docket and explicitly awaits a manual glob, as described above. Verify consumer metadata and exact assets after publication; never replay a stale glob identifier.

Ordinary CDN requests have previously returned old CSS while a unique-query request matched the new origin. Browser `no-store` is not sufficient evidence of a fresh edge response. Seven first-party modules/CSS now use content fingerprints (#7), including transitive imports. Ordinary root HTML freshness and consumer asset readback still require post-publication verification; content hashes do not by themselves make a cached root index fresh. Do not repeatedly re-upload to diagnose caching.

## Clean-checkout checks

Prerequisites: Python 3.10+ and Node.js with the built-in test runner (Node 18+). There is no npm install; dependencies and notices are bundled. Editable inputs are in `frontend/source/`. The portable Python build regenerates `frontend/public/`, fingerprints imports, validates all 29 files and writes a verified ZIP to ignored `.build/`.

Run from the repository root:

```sh
python3 tools/build.py
python3 -m unittest discover -s tests -p 'test_*.py' -v
node --test tests/frontend.test.mjs tests/one-button.test.mjs
python3 tools/export_native_test.py gentle > "$TMPDIR/hasterrad-gentle.hoon"
```

Set `TMPDIR` to a writable scratch directory if your shell does not provide one. The Python suite checks source hashes, metadata syntax/mark presence, local dependency closure and native-authority contract sentinels. The Node suites exercise quick-tap edges, held heartbeats, safe release/sequences, moon artwork, bounded interpolation, native transport routing and the composed one-button/Info lifecycle. **Neither suite compiles Hoon or proves live deployment.**

`tests/native/` retains six native level/wave/opening/gentle-enemy/migration/no-carry fragments. The earlier four-shot `%4` fixtures remain in baseline commit history, not falsely offered against the new world mold. `tools/export_native_test.py CASE` assembles one against this checkout's actual source as a `%fyrd` strand body, without connecting to any ship. Native execution requires a separately owned compatible disposable ship and the normal native evaluation transport; that runtime is intentionally not bundled. Never execute these fixtures against an owner's real game. The portable descriptor check is textual, not a fresh native Docket-parser admission; clean native packaging remains a release gate (#2).

`source-manifest.json` seals the imported baseline, native fixtures and deliberate `0v0` template. Updating source requires updating that manifest deliberately after review. Historical private runtime receipts, pier state and operational scripts are not clean-checkout dependencies.

## Work tracked separately

| Issue | Scope / status |
| --- | --- |
| #1 | Historical native installation/score tracking; not automatically closed by this source snapshot |
| #2 | Accepted native source, portable packaging and release qualification |
| #3 | Four-shot press-only source and owner-controlled activation |
| #4 | Border/warning source and frontend delivery |
| #5 | Gentle Hoon-owned levels: accepted native source and owner commit/glob; baseline appearance and 29-file consumer frontend readback accepted |
| #6 | Proposed local stats API and opt-in native Ames moon leaderboard; bounded/idempotent/offline-safe, sender authenticated, community trust rather than anti-cheat |
| #7 | Seven fingerprinted first-party assets and portable build included; baseline ordinary root/consumer assets verified; future publications require fresh verification |
| #8 | Same-ship multi-tab lifecycle hardening: pending |
| #9 | Accessible Info/source link and single Start game / Play again button included; accepted UI evidence, not live-delivery proof |
| #10 | Explicit Quit/return-to-Landscape: potential follow-up, not implemented |
| #11 | Distributor moon package source: destination decision pending, not imported here |
| #12 | Owner-selected first-party MIT policy, nine preserved component notices, native Urbit support notice and frontend license index included; exact per-file source/embedded-package matches documented; historical import/build events and owner rights/branding review remain open |

Source home: https://github.com/OwlWilderness/hasterrad-urbit . Version 0.0.1 is already published as a private experimental prerelease at the frozen tag `v0.0.1` (remote source `a047f50f272a48b72e8cb757f357abbef1d1cdd6`). This subsequent #13 source is unreleased; publishing it on `earth` neither moves that tag nor replaces its assets, changes visibility, or establishes live acceptance. The standalone browser game and website remain separate products. See [CONTRIBUTING.md](CONTRIBUTING.md) for issue-linked commits and ownership boundaries.

## Notices

The owner selected **MIT for project-specific code and documentation**; see [LICENSE](LICENSE). The collective attribution “2026 HASTERRAD contributors” describes project contributions, not a proven rights chain or invented legal entity. It grants only rights contributors can grant and does not relicense third-party components or clear legacy artwork. See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for the component/version/scope table and remaining provenance limits, and `license-manifest.json` for notice hashes.

All nine existing MIT notices are preserved byte-for-byte. The complete Urbit MIT notice now covers supplied native support libraries/molds/marks in `licenses/urbit-native.txt`; 12 native files have exact pinned upstream matches and the Docket mark differs only by two removed trailing spaces. The hoon mark matches a different revision; no coherent original base or historical import is claimed. Embedded browser-or-node 1.3.0 and fetch-event-source 2.0.1 match official npm source bytes, not merely dependency ranges; the original installation/build event remains unknown. Per-file revisions, URLs, hashes and component versions are in `license-manifest.json`. The frontend includes the full project license, component notices and native notice, with an accessible **Info → Licenses and notices** index. Keep these with every distribution; build checks canonical notice parity and ZIP contents.

Owner confirmation of contributor/predecessor rights, external code/art inputs and icon provenance, plus branding/name review, remains required before public release (#12). Excluded legacy SAN Sound/HARDWIRE product-reference artwork is not licensed or cleared by this change. No legal clearance, clean-room or noninfringement claim is made. MIT selection resolves the license-policy decision, not those external rights questions. See [NOTICE.md](NOTICE.md).

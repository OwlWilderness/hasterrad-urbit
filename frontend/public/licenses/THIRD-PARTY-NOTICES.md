# Licensing scope and third-party notices

## HASTERRAD contributions

The owner selected MIT for HASTERRAD-specific code and documentation. `LICENSE`
contains the full grant, attributed collectively to **2026 HASTERRAD contributors**;
this names project contributors, not a newly asserted legal entity or a finding
that every contribution has proven ownership. The grant applies only to rights
contributors can grant in the project-specific agent/core/enemy code, frontend
presentation/wrapper, tools, tests and documentation. It does not relicense the
bundled components below, represent permission for excluded predecessor material,
or establish ownership/copyrightability of AI-assisted output. The icon's input
and contribution provenance still requires owner confirmation; this notice does
not manufacture an artwork permission. Names, marks and third-party rights are
not licensed by this project notice.

## Bundled MIT components

Keep the full notice files, including copyright, permission and warranty text,
with redistributed source, bundles, source maps and generated sigil assets.
Paths below are relative to `frontend/public/licenses/` (editable copies are in
`frontend/source/licenses/`). No existing component notice has been shortened.

| Component | Version / provenance limit | Distributed material | Full notice |
| --- | --- | --- | --- |
| @urbit/sigil-js | 2.2.0; retained package lock/input graph | sigil-runtime module and four static ship SVGs | `urbit-sigil-js.txt` |
| urbit-ob | 5.0.1; retained package lock/input graph | sigil-runtime module | `urbit-ob.txt` |
| bn.js | 4.12.5; retained package lock/input graph | sigil-runtime module | `bn.js.txt` |
| invariant | 2.2.4; retained browser.js input | sigil-runtime module | `invariant.txt` |
| lodash.chunk | 4.2.0; retained input graph | sigil-runtime module | `lodash.chunk.txt` |
| lodash.isequal | 4.5.0; retained input graph | sigil-runtime module | `lodash.isequal.txt` |
| @urbit/http-api | 2.3.0; retained vendor distribution byte match | urbit-http-api-2.3.0.min.js and source map | `urbit-http-api.txt` |
| browser-or-node | 1.3.0; exact embedded source-map content match to official npm package | HTTP client/source map | `browser-or-node.txt` |
| @microsoft/fetch-event-source | 2.0.1; exact embedded parse.js and fetch.js source-map content matches | HTTP client/source map | `fetch-event-source.txt` |
| Urbit native support | 12 exact per-file matches plus one whitespace-only transformation; pinned revisions below, historical import unknown | desk support paths below | `urbit-native.txt`; also root `licenses/urbit-native.txt` |

Urbit native coverage: `desk/lib/default-agent.hoon`, `desk/lib/skeleton.hoon`,
`desk/lib/docket.hoon`, `desk/sur/docket.hoon`, and all supplied `desk/mar/*.hoon`
(bill, docket-0, hoon, json, kelvin, mime, noun, ship, txt). The Urbit notice is
retained for the whole inherited support slice. Native metadata is an adapted
project template and contains an embedded project icon; it is not a claim of
upstream artwork rights.

### Pinned source-content provenance

`license-manifest.json` records all 13 native paths, immutable upstream URLs,
revisions, local/upstream SHA-256, matching methods and notice SHA-256, plus all
nine JavaScript component versions, package hashes and source matches.

- Eleven native files match Urbit `408k-rc1`, commit
  `0f94550b941dfe046d9dff4a541330bd084e8cd1`, exactly: default-agent, skeleton,
  Docket lib/sur, and bill/json/kelvin/mime/noun/ship/txt marks.
- `desk/mar/docket-0.hoon` matches that commit after removing only two trailing
  spaces following `++  mime` (438 upstream bytes, 436 distributed bytes).
- `desk/mar/hoon.hoon` instead matches commit
  `9ae55333899fccdf6e50e5f0563425e5eae4c383` exactly, not the 408k-rc1 mark.
- The complete root MIT notices at both pinned revisions match
  `licenses/urbit-native.txt`, SHA-256
  `b5d62c0a6f6b17ff490de29606527bf77b6509998ef07048488d659e2b719e52`.
  Immutable license source:
  https://raw.githubusercontent.com/urbit/urbit/0f94550b941dfe046d9dff4a541330bd084e8cd1/LICENSE.txt
- The HTTP API 2.3.0 bundle and map match its official npm archive exactly.
  Embedded browser-or-node source matches 1.3.0, and both embedded Microsoft
  fetch-event-source sources match 2.0.1. These are source-content comparisons,
  not deductions from dependency ranges. The API notice is verified at npm
  gitHead `06fc1897b79c0219295e62172c6b9837593471bb`.
- All nine complete component notices match the corresponding upstream notices;
  the six sigil runtime inputs retain their verified version/input graph.

These reproducible per-file matches do **not** recover the original native
import event/revision or establish one coherent original base. The original
upstream HTTP installation/build lock/event is also unknown. Preserve license
comments in bundles/maps and all full notice texts.

Static ship sigils were generated with the sigil libraries, not evidenced as
Atari assets; dynamic moon composition is application presentation, not an official
whole-moon sigil. Represented ships do not thereby endorse this game. System font
stacks are referenced, not bundled; this native frontend ships no audio files.

## Exclusions and open owner review

The superseded browser/bootstrap game and its SAN Sound / HARDWIRE
product-reference silhouettes are outside this native source distribution and
outside this grant. They have not been cleared by renaming or rewriting gameplay.
Before public release the owner must confirm the predecessor/contributor rights
chain, external code/art inputs and icon provenance, and resolve uncertain
branding/name rights with appropriate human review. Historical native import and original HTTP installation/build events remain
unknown despite the resolved per-file and embedded-source matches. These notices implement known licensing
obligations, not legal clearance, clean-room certification or a noninfringement
warranty. Issue #12 remains open; publication/deployment is separately controlled.

# HASTERRAD — native Urbit port (in progress)

This repository preserves an unfinished native-port scaffold. It is **not a
release, installable handoff, or runtime-accepted game**. The current Hoon-owned
rewrite is being developed separately and has not been integrated into this
checkout. Do not treat the preserved JavaScript-authoritative game as that rewrite.

## Current architecture boundary

The intended native game puts simulation, rules, collisions, scoring and lives in
Hoon; the browser is a thin renderer/input client. Player identity comes from the
host ship's ordinary authenticated Urbit session, with lives based on the ship's
syllables. There is no game-level login: no EAuth, RemiliaNET or external account
backend. Eyre access security must remain intact.

The current target-generation design uses valid four-syllable Urbit names,
authentic generated sigils and four-to-two-to-one syllable fragmentation.
Ingredient source identities are provenance, not claims that generated targets
are installed or owned. These are rewrite requirements, not verified behavior of
this checkout.

## What is actually here

- `desk/` contains the earlier Gall agent, molds, marks, docket support and
  generated frontend assets. It was designed around ship-local run records while
  JavaScript still owned gameplay, not the new Hoon simulation.
- `frontend/` contains that earlier browser game and native-score adapter.
- `tools/` and `bootstrap/` contain experimental local build/upload/install probes;
  they are not a closed or verified installation workflow.

The paused scaffold reached compile/start on a disposable fake ship, but its HTTP
routes still returned 500. Successful score save/read, owner/foreign mutation
refusal, bounded score validation and state-reload persistence were not accepted.
A transport or compiler success does not establish game acceptance. The isolated
rewrite's compile, renderer and integration outcomes remain unsettled here.

## Usage and continuation limits

There is no supported play/install command for this checkout yet. Do not paste the
retained bootstrap commands into a real ship, restart a ship, or install these
artifacts based on this README. Coordinate with the rewrite owner before editing
source or using any disposable runtime. Integration must first establish the exact
Hoon/frontend contract, compile and gameplay behavior, persistence/access checks,
and a reviewed installation bundle with explicit target authorization.

The maintained standalone web game and website remain separate products in
`hasterrad` and `quantumtekh-com`. This README-only change neither integrates the
rewrite nor changes those products, any live ship, package, DNS, tunnel or service.

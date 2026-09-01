# Compatibility harness

The harness compiles the same scenario sources against either OpenFL 9.5.2 or
openfl-flight. Run all commands from the repository root.

Capture reference fixtures with the pinned OpenFL release:

```sh
haxe test/harness/capture.hxml
```

Capture mode pins Lime 8.3.2, the release paired with OpenFL 9.5.2. Both
haxelibs must be installed before running the command.

Compare openfl-flight with the committed fixtures:

```sh
haxe test/harness/compare.hxml
```

Compare mode resolves `openfl.*` only from the repository's `src/` tree. A
scenario for an OpenFL type that has not been implemented yet therefore fails at
compile time instead of silently falling back to the reference OpenFL library.

Capture mode rewrites the matching files under `test/fixtures/`. Review those
changes before committing them. Compare mode runs every scenario, reports each
failure, and exits nonzero if any observed result differs.

Add scenarios to `harness.Scenarios`. Scenario code must use only the public
`openfl.*` API and return JSON-compatible, deterministic data.

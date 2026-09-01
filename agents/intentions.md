# Intentions

## Why this project exists

OpenFL provides a Flash-compatible display-list API for Haxe, targeting native (cpp, hashlink),
web (js), and managed (neko) platforms through its Lime backend. Its internals carry a decade of
accumulated rendering logic, platform shims, and workarounds tightly coupled to Lime's low-level
abstractions.

Flight is a modern, from-scratch multimedia SDK built around explicit data, free functions, and
side-effect-free composition. It covers the same domain — 2D/3D scene graphs, rendering, input,
text, audio — but with a fundamentally different API shape: static facades, out-parameter
mutation, and a flat node graph instead of deep class hierarchies. Flight already has a Lime
host integration layer.

openfl-flight replaces OpenFL's internals with Flight while preserving OpenFL's public API
surface exactly. Existing OpenFL applications compile and behave identically; the implementation
underneath is Flight.

## What success looks like

- Every public class, method, property, enum, and typedef in OpenFL 9.5.2 exists in
  openfl-flight with the same fully-qualified name and the same signature.
- The compatibility harness — which captures OpenFL 9.5.2's observable behavior as fixture
  data — passes green when run against openfl-flight.
- Flight is the sole implementation substrate. No OpenFL internal code (`openfl._internal`)
  is carried over. Where Flight lacks coverage for an OpenFL behavior, the gap is filed as a
  requirement on flight-hx, not worked around in openfl-flight.
- An existing OpenFL project can swap its haxelib dependency from `openfl` to `openfl-flight`
  and compile without source changes.

## What this is not

- Not a fork of OpenFL. The public API is copied; the internals are new.
- Not an extension of OpenFL. No new public API beyond what 9.5.2 defines.
- Not a compatibility layer that wraps OpenFL at runtime. OpenFL is not a dependency of
  openfl-flight — it is only used by the harness to capture reference behavior.
- Not a port of Flight to Haxe. flight-hx already exists. This is an OpenFL-shaped skin
  over flight-hx.

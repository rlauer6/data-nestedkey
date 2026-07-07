# Data::NestedKey 1.2.0 Release Notes

**Released:** 2026-07-07
**Author:** Rob Lauer <rclauer@gmail.com>
**Repository:** https://github.com/rlauer6/Data-NestedKey

---

## Overview

Version 1.2.0 is a feature release that extends `Data::NestedKey` with
top-level array support, a new CLI interface (`dnk`), and a significantly
overhauled build system powered by `CPAN::Maker::Bootstrapper`.

---

## New Features

### Array Root Support

The data root of a `Data::NestedKey` object may now be an **array reference**
in addition to a hash reference. A path beginning with a bare subscript indexes
the top-level array directly.

```perl
my $nk = Data::NestedKey->new($array_ref);

my $first = $nk->get('[0]');
my $name  = $nk->get('[0].name');
my $last  = $nk->get('[-1]');
```

### Array Subscript Support in `get`, `delete`, and `exists_key`

Array elements can now be accessed at any depth using zero-based `[n]`
subscripts appended to a hash key segment. Negative indices count from the end
of the array (`-1` is the last element).

```perl
my $uri  = $nk->get('repositories[0].repositoryUri');
my $last = $nk->get('items[-1].name');
my $val  = $nk->get('a.b[2].c.d[-1]');
```

Support is provided in:

- `get` — returns `undef` for missing or out-of-range subscripts
- `exists_key` — a subscript past the end of an array, or pointing to an
  `undef` slot, is treated as non-existent
- `delete` — array elements are removed with `splice` (the array shrinks; no
  `undef` hole is left); empty parent hashes are still pruned automatically

### `set` Restriction on Array Subscripts

`set` continues to operate on **plain dot-separated hash paths only**. Passing
a path containing `[n]` subscript notation to `set` now throws an explicit
exception rather than silently misbehaving.

```perl
# Dies with a clear error message:
$nk->set('repositories[0].uri' => 'https://...');
```

Similarly, passing key-value pairs to `new` when the root is an array reference
now throws an exception immediately.

### New CLI Script: `dnk`

A new command-line utility `bin/dnk` (via `bin/dnk.in`) has been added,
backed by a new `Data::NestedKey::CLI` module. This provides command-line
access to nested key operations.

---

## Internal Changes

### New Private Helpers

Two new internal subroutines have been added to support the above features:

- **`_parse_path($path)`** — parses a dot-separated path string into a list of
  segment hashrefs, each carrying a `key` and an optional `index`. Handles bare
  subscripts (e.g. `[0]`) for array-rooted structures.

- **`_walk($data, $segments, $create)`** — traverses a parsed path one segment
  from the end, returning the innermost container and the final segment
  descriptor. Auto-vivifies intermediate hash keys when `$create` is true.

---

## Dependency Changes

### Runtime Dependencies

| Module | Version | Change |
|---|---|---|
| `CLI::Simple` | 2.0.11 | **Added** |
| `CLI::Simple::Constants` | 2.0.11 | **Added** |
| `CLI::Simple::Utils` | 2.0.11 | **Added** |
| `JSON` | 4.10 | Version pinned (was unpinned) |
| `YAML::XS` | v0.904.0 | Version pinned (was unpinned) |
| `List::Util` | 1.32 | **Removed** (now treated as core) |

### Test Dependencies

Core modules (`Test::More`, `Storable`) have been removed from `test-requires`.
`JSON` and `YAML::XS` remain with explicit version pins.

---

## New Tests

| File | Description |
|---|---|
| `t/00-data-nestedkey.t` | Basic module load and sanity checks |
| `t/01-subscript.t` | Array subscript notation in `get`, `delete`, `exists_key` |
| `t/02-array.t` | Top-level array root support |

---

## Build System

The `Makefile` has been substantially updated by `CPAN::Maker::Bootstrapper`.
Notable changes include:

- Makefile include fragments moved to `.includes/` (`version.mk`,
  `release-notes.mk`) and new fragments added (`git.mk`, `help.mk`, `perl.mk`,
  `update.mk`, `upgrade.mk`).
- `buildspec.yml` updated with corrected key names (`pm-module`,
  `test-requires`, `exe-files`) and updated contact/repository URLs.
- `cpanfile` is now generated automatically from `requires` and
  `test-requires`.
- A `build-ci` target supports Docker-based CI builds.
- The top-level `version.mk` has been removed; version management is now
  handled via `.includes/version.mk`.

---

## Upgrading

Users of `get`, `delete`, or `exists_key` with plain dot-path keys will see no
behaviour change. To take advantage of array subscript access, update path
strings as shown in the examples above. No changes to `set` call sites are
required provided they do not contain `[` characters in key paths.
# Data::NestedKey 1.3.0 Release Notes

## Overview

This release delivers meaningful improvements to both the core library
and the `dnk` CLI tool, with particular focus on array traversal
correctness, safer in-place file writes, Bedrock XML support, and an
overhaul of the CPAN::Maker-based build infrastructure. Three new test
files expand coverage for CLI behaviour, format handling, and path
regression cases.

---

## Core Library: `Data::NestedKey`

### Array Traversal Rewrites (`delete`, `exists_key`)

Both `delete` and `exists_key` have been rewritten to handle
array-rooted structures—documents whose top-level value is an array
rather than a hash. Bare leading subscripts (e.g., `[0].name`,
`[-1]`) now work correctly against such roots.

Negative subscripts are fully supported in intermediate and final path
segments across both methods. `exists_key` returns `0` for
out-of-range indices or `undef` slots rather than dying.

`delete` now ignores nonexistent and out-of-range paths without
modifying the structure. Empty-parent pruning is intentionally
skipped when an array index was traversed on the way to the deletion
target, preventing unintended removal of still-populated ancestors.

The internal `_walk` helper has been removed; its logic is inlined
directly into the methods that used it.

### Scalar Context for `exists_key`

`exists_key` now returns the first result when called in scalar
context, consistent with how `get` behaves.

---

## CLI Tool: `dnk` / `Data::NestedKey::CLI`

### New `--replace` / `-r` Option

Previously the only way to write changes back to the input file was
`--backup`. The new `--replace` (`-r`) option triggers an in-place
rewrite without requiring a backup to be named. Either `--replace` or
`--backup` now triggers `_write_file`; without either flag, `set`
continues to print the modified document to standard output.

### New `--output-format` / `-o` Option

A separate output format can now be specified independently of the
input format. This allows, for example, reading a YAML file and
writing the result as JSON, or vice versa. The resolved output format
is determined in order: `--output-format`, the detected input format,
then `json` as the default.

### Default `get` Key

When `dnk get` is invoked without a key argument, it now defaults to
`.` (the entire document), printing the full serialized structure
rather than producing an error.

### Safer In-Place File Writes (`_write_file`)

The file-write path has been rewritten for safety:

- Changes are written to a temporary file in the same directory as
  the input, then atomically renamed into place (keeping the
  operation on the same filesystem).
- Original file permissions are preserved on the replacement.
- If `--backup` is requested and a backup file already exists, the
  operation is aborted rather than silently overwriting it.
- On any failure, an in-progress backup is restored to the original
  filename.
- Reading from stdin is rejected when `--replace` or `--backup` is
  set, since there is no file to write back.

### Bedrock XML Support (`_xml_data`, `_serialize`)

The `dnk` tool can now read and write Bedrock XML documents.
`Bedrock::XML` is an optional dependency (`suggests`); it is
lazy-loaded only when XML input or output is actually requested. Auto-
detection recognises `.xml` file extensions and documents that begin
with `<object` or `<array` markup (optionally preceded by an XML
declaration), falling back to JSON then YAML for unrecognised input.

Format validation in `init` now covers both `--format` and
`--output-format`. The global `$Data::NestedKey::FORMAT` is no longer
mutated by `init`; `_serialize` uses `local` to avoid affecting other
instances in the same process.

### Dependency Cleanup

`CLI::Simple::Constants` and `CLI::Simple::Utils` are no longer pinned
separately in `requires` and `cpanfile`; they are sub-modules of
`CLI::Simple` and the top-level pin is sufficient.

---

## New Tests

Three test files have been added:

- `t/02-cli.t` — CLI command behaviour
- `t/03-cli-formats.t` — format handling (JSON, YAML, XML)
- `t/03-path-regressions.t` — path traversal regression cases

---

## Build System

Extensive build system updates to the `Makefile` and `.includes/`
machinery, including a new requirement for GNU Make 4.3, several new
`.includes/*.mk` files, new `config.mk` and `project.mk` project
scaffolding files, explicit `recommends` and `suggests` dependency
tiers, and a `next-release` workflow target. See the ChangeLog for
full details.

---

# Release Notes: Data::NestedKey 1.2.1

**Released:** Thu Jul 9, 2026
**Author:** Rob Lauer <rclauer@gmail.com>

---

## Overview

Version 1.2.1 is a maintenance and usability release that improves the
`dnk` CLI tool with a more intuitive default command behaviour, adds
`YML` as an accepted format alias in `as_string()`, fixes POD encoding
issues, and bumps the `CLI::Simple` dependency to 2.0.12.

---

## What's New

### CLI Improvements (`Data::NestedKey::CLI`)

- **Default command is now `get`** — You no longer need to explicitly
  type the `get` subcommand when using `dnk`. A path expression passed
  directly to `dnk` without a subcommand will now be treated as a
  `get` operation automatically:

  ```bash
  # These are now equivalent:
  cat ecr-response.json | dnk get 'repositories[0].repositoryUri'
  cat ecr-response.json | dnk 'repositories[0].repositoryUri'
  ```

- **`validate_command` disabled** — Command validation is now set to
  `false` in `main()` to support the default `get` command behaviour
  described above.

- **Man page link added** — A `man-links` entry for `dnk` →
  `Data::NestedKey::CLI` has been added to `buildspec.yml`, so the
  `dnk` script will have a proper man page reference.

- **Minor documentation fixes** — Corrected `dnky` references in POD
  examples to `dnk`. Removed a blank `DESCRIPTION` section from the
  CLI POD.

---

### `Data::NestedKey` Module

- **`YML` format alias in `as_string()`** — The `as_string()` method
  now accepts both `'YML'` and `'YAML'` as valid values for
  `$Data::NestedKey::FORMAT`, both mapping to `YAML::XS::Dump()`
  output:

  ```perl
  $Data::NestedKey::FORMAT = 'YML';
  print $nk->as_string();  # outputs YAML
  ```

- **POD encoding fix** — Added `=encoding utf8` to the module POD,
  resolving the `Non-ASCII character seen before =encoding` warning
  that previously appeared in the generated `README.md`.

- **Improved DESCRIPTION** — The module documentation now clearly
  describes both the OO (`Data::NestedKey`) and CLI (`dnk`)
  interfaces, and notes that these tools can serve as a lightweight
  alternative to `jq` for simple data extraction tasks.

- **Removed duplicated POD paragraph** — A redundant paragraph about
  array subscript notation in the `DESCRIPTION` section has been
  removed.

---

## Dependency Updates

| Dependency              | Previous | New    |
|-------------------------|----------|--------|
| `CLI::Simple`           | 2.0.11   | 2.0.12 |
| `CLI::Simple::Constants`| 2.0.11   | 2.0.12 |
| `CLI::Simple::Utils`    | 2.0.11   | 2.0.12 |

---

## Files Changed

| File | Change |
|------|--------|
| `lib/Data/NestedKey.pm.in` | Added `=encoding utf8`; added `YML` format alias in `as_string()`; updated POD |
| `lib/Data/NestedKey::CLI.pm.in` | Default `get` command support; `validate_command => false`; POD fixes |
| `buildspec.yml` | Added `man-links` entry for `dnk` |
| `cpanfile` | Bumped `CLI::Simple*` to 2.0.12 |
| `requires` | Bumped `CLI::Simple*` to 2.0.12 |
| `README.md` | Regenerated |
| `VERSION` | Bumped to `1.2.1` |

---

## Upgrading

This is a backward-compatible release. No changes to existing method
signatures or public APIs were made. Users of the `dnk` CLI tool will
notice the improved ergonomics of being able to omit the `get`
subcommand.

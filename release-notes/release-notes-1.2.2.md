# Release Notes — Data::NestedKey 1.2.2

**Release Date:** 2026-07-15
**Distribution:** Data::NestedKey
**Version:** 1.2.2

---

## Summary

This is a minor bug fix release addressing a case-sensitivity issue in
format detection within the CLI's data-fetching logic.

---

## Bug Fixes

### Case-Insensitive Format Matching in `_fetch_data` (`Data::NestedKey::CLI`)

The `_fetch_data` method in `Data::NestedKey::CLI` previously compared
the user-supplied `--format` value against decoder keys using a
mixed-case comparison that could fail depending on how the format
string was provided. The comparison now normalises both sides to
uppercase before comparing, ensuring that format values such as
`json`, `JSON`, `Json`, `yaml`, `YAML`, etc. are all handled correctly
and consistently.

**Before:**
```perl
next if $format && $format eq uc $_;
```

**After:**
```perl
next if uc $format eq uc $f;
```

This also corrects a subtle logic error in the original condition: the
old code short-circuited on `$format` being falsy before performing
the comparison, which could lead to unexpected decoder filtering
behaviour. The new code is cleaner and unambiguous.

---

## Changed Files

| File | Change |
|---|---|
| `lib/Data/NestedKey/CLI.pm.in` | Bug fix: case-insensitive format comparison in `_fetch_data` |
| `VERSION` | Bumped to `1.2.2` |
| `release-notes.md` | Updated symlink to current release notes |

---

## Upgrade Notes

No API changes were made in this release. Users who pass `--format`
values in lowercase (e.g. `--format json`) to the `dnk` CLI tool and
experienced unexpected decoding behaviour should upgrade to this
version.

---

## Author

Rob Lauer &lt;rclauer@gmail.com&gt;

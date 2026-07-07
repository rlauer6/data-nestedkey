# Data::NestedKey 1.1.0 Release Notes

## Summary

Adds array subscript notation to `get`, `exists_key`, and `delete`,
enabling direct access to elements of nested arrays using `[n]` syntax
in dot-separated path strings. `set` continues to support plain
dot-separated paths only. A new test file covers all subscript cases.

---

## Changes

### `lib/Data/NestedKey.pm.in`

**`_parse_path` (new)**

Replaces the inline `split /[.]/, $path` used throughout the module.
Parses a dot-separated path string into a list of segment hashrefs,
each with a `key` (hash key name) and an optional `index` (integer
array subscript, possibly negative). Examples:

- `'foo.bar'` → `[{key=>'foo'}, {key=>'bar'}]`
- `'repositories[0].repositoryUri'` → `[{key=>'repositories', index=>0}, {key=>'repositoryUri'}]`
- `'items[-1]'` → `[{key=>'items', index=>-1}]`

**`_walk` (new)**

Shared path-traversal helper used by `get`, `delete`, and `exists_key`.
Walks a parsed segment list down into the data structure, stopping one
segment before the end. Returns `($node, $final_segment)` or
`(undef, undef)` if any intermediate step is missing or of the wrong
type. When the `$create` flag is set, missing intermediate hash keys
are auto-vivified (preserving the existing `set` behaviour).

**`get`**

Rewritten to use `_parse_path`. Array subscripts are now honoured at
any segment. Negative indices count from the end of the array.
Returns `undef` for any path that does not exist or whose subscript is
out of range. Scalar context returns the first value; list context
returns all requested values.

**`exists_key`**

Rewritten to use `_parse_path`. A subscript pointing past the end of
an array, or to an undef slot, is treated as non-existent.

**`delete`**

Rewritten to use `_parse_path`. When the final segment carries an
array subscript, the element is removed with `splice` — the array
shrinks and no undef hole is left. Empty parent hashes are pruned
automatically when no array is traversed on the way down.

**`set`**

Unchanged in behaviour. Now explicitly croaks when a path containing
`[` is passed, making the restriction on subscripts in set paths clear
rather than silently misbehaving.

### `t/01-subscript.t` (new)

108-line test file covering:

- Basic subscript `get` for first and subsequent elements
- Negative index access (`[-1]` is the last element)
- Out-of-range and missing key returning `undef`
- `exists_key` with subscripts, including out-of-range false case
- Multi-value `get` in list context with subscripts
- Array-at-leaf access (subscript with no further hash key)
- `delete` with subscript using `splice` (array shrinks, no undef hole)
- `delete` with negative subscript
- `set` croaking on subscript paths
- Plain dot-separated paths continuing to work unchanged

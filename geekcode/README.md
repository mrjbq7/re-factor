# Geek Code

Decode Robert A. Hayden's Geek Code 3.12 in Factor. Plain strings and
blocks labeled `Version: 3.1` or `Version: 3.12` are accepted. Other
explicit versions raise `unsupported-geekcode-version`.

```factor
USING: geekcode prettyprint ;
"GCS e++ a?" geekcode .
```

`geekcode` returns an ordered sequence of `{ category description }` pairs.
`geekcode-unknown` returns tokens that could not be decoded, in input order.
`geekcode.` prints the decoded rows and reports unrecognized tokens.
All three use the bundled specification; decoding and testing require no
network access.

Supported syntax includes all 303 explicit ratings across 34 categories,
slash-separated types (`GCS/MU`), trailing `@` and `$`, a single parenthesized
range (`C++(++++)`), and a single goal (`C++>++++` or `PS++>$`). Generic `?`
and leading `!` apply to bare categories; explicit table entries take
precedence, so `a?` means immortal. Case matters: `W` and `w` differ.

Mixed shape ratings (`s:++`), Unix flavors (`ULU++`), gender aliases,
and combined sex ratings (`y++**`) are also supported. Shape components
use short descriptions for height and build; Unix and sex ratings reuse
the published U and z descriptions. Hayden's complete example decodes
without unrecognized tokens.

This is not a complete implementation of the 3.12 grammar. Exact ages
(`a42`), nested ranges, and repeated goals are not implemented. These tokens are returned whole by `geekcode-unknown`;
they are not partially decoded. In particular, an unrecognized token may
be valid Geek Code. This API is not a validator.

Run the tests with the parent directory on Factor's vocabulary roots:

```factor
USE: tools.test
"geekcode" test
```

Or from the Factor installation:

```sh
./factor -roots=/path/to/re-factor -run=tools.test geekcode
```

## Specification provenance

`geekcode-3.12.html` is an unmodified download of the archival mirror:

- Original: http://www.geekcode.com/geek.html
- Download: https://geekcode.xyz/geek.html
- Specification: **The Code of the Geeks v3.12**, Robert A. Hayden,
  last updated **March 5, 1996**; HTML formatting by Dylan Northrup.
- Retrieved: **2026-09-25**.
- SHA-256: `6d4590194bee206d11fa08187146f53d9ce74c1afb987a7cad944846815f06f2`

The mirror includes its own archival annotations from 2017. The downloaded
file, including those annotations and the original copyright notice, is
preserved byte for byte. The specification retains its own copyright and
redistribution terms, reproduced within the file; it is not covered by
the Factor source files' BSD license.

Version 3.12 is the last original Hayden specification located in the
2026-09-25 review. There are later independent revisions, including
[the community 6.0 format](https://github.com/telavivmakers/geek_code),
which changes categories and syntax. This vocabulary targets the original
3.12 format, not those revisions.

To update the snapshot, verify the version and provenance, preserve the
source document intact, update this hash, and run the full tests. Changes
to the spec should be reviewed alongside changes to the decoder and its
expected output.

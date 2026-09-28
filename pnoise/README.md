# pnoise

A Factor port of [nsf/pnoise's Python example](https://github.com/nsf/pnoise/blob/master/test.py).

Create a noise field and sample it with a two-element coordinate array:

```factor
USING: pnoise ;
{ 0.25 0.5 } <pnoise> noise-at
```

Keep the same noise object when sampling multiple points. For repeatable fields,
use Factor's random generator scope:

```factor
USING: pnoise random random.mersenne-twister ;
42 <mersenne-twister> [ <pnoise> ] with-random
```

The algorithm matches the reference, but Factor's random initialization and
shuffle do not produce the same fields as Python for a given seed.

Run `pnoise-demo` (or `-run=pnoise`) for the 256-by-256 terminal image. It renders
the reference's final frame without computing the preceding undisplayed frames.

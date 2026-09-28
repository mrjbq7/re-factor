# Factor filesystems with libfuse

`fuse` provides a read-only filesystem protocol implemented in Factor. A small
C bridge handles the native libfuse ABI (including `struct stat`, directory
fillers, and differences between libfuse 2 and 3). It supports Linux libfuse 3
and macFUSE's libfuse 2 API. It does not implement writable filesystems yet.

## Build

Install your platform's development headers and library, then:

```sh
make -C fuse
```

On Debian/Ubuntu the dependencies are `build-essential pkg-config libfuse3-dev
fuse3`. On macOS install the macFUSE package and `pkg-config`; its `fuse.pc` must
be on `PKG_CONFIG_PATH` (usually `/usr/local/lib/pkgconfig`). macOS may require
approval/restart before mounting. The bridge itself requires no Factor headers.

Linux libfuse 2 is also selectable with `FUSE_PKG=fuse FUSE_API=26`.
The bridge is loaded from this vocabulary's directory. To use another build,
set `FACTOR_FUSE_LIBRARY` to its absolute path **before loading `fuse`**.

## Help filesystem

Add this repository as a vocabulary root, load the vocabularies you want to
browse, and run in a dedicated Factor listener/process:

```factor
USING: fuse.help ;
"/absolute/path/to/empty/mountpoint" mount-help
```

Create the mountpoint first. `mount-help` blocks until unmount. From another
terminal:

```sh
ls /absolute/path/to/empty/mountpoint
ls /absolute/path/to/empty/mountpoint/kernel
cat /absolute/path/to/empty/mountpoint/kernel/dup
cat /absolute/path/to/empty/mountpoint/math/%2F
```

Each loaded vocabulary becomes one directory (dots remain in the name).
Each word becomes a UTF-8 plain-text help file, rendered with Factor's normal
help printer, including its definition. `/` becomes `%2F`, `%` becomes `%25`,
and special names `.` and `..` are escaped. Other reserved characters are
percent-encoded too. Use the spelling shown by `ls`.

The index captures loaded vocabularies at construction; it does not load every
vocabulary on disk. Help documents for those vocabularies are loaded, and each
word's rendered bytes are cached on first access so file size and subsequent
reads agree. To mount just selected vocabularies:

```factor
USING: fuse fuse.help ;
{ "kernel" "math" "sequences" } <help-fs-for>
"/absolute/path/to/empty/mountpoint" mount-fuse
```

Unmount with `fusermount3 -u /path/to/mountpoint` on Linux (or `fusermount` for
libfuse 2), or `umount /path/to/mountpoint` on macOS.

## Implement another filesystem

Subclass `fuse-fs` and implement:

- `fs-getattr ( path fs -- entry )`: return `t 0 <fuse-entry>` for a directory,
  or `f byte-length <fuse-entry>` for a file.
- `fs-readdir ( path fs -- names )`: return a stable sequence of child names,
  excluding `.` and `..`. Names must be valid filesystem components.
- `fs-read ( path size offset fs -- bytes )`: return a byte array of at most
  `size` bytes, starting at the byte offset; return `B{ }` at EOF.
  `fuse-slice` implements bounded reads from a byte array.

Raise an appropriate POSIX error with, for example, `ENOENT fuse-fail`.
Unexpected Factor errors are contained at the callback boundary and become
`EIO`. Paths are absolute within the mounted filesystem, starting with `/`.

The mount runs in the foreground on the calling VM thread with libfuse's
single-threaded loop. One mount per Factor VM is supported. The filesystem is
rooted for the lifetime of the mount and released on exit, including failure.
All mounts use `ro,default_permissions`; files are `0444`, directories `0555`,
and write opens are rejected. There is no callback from a foreign worker
thread and no daemonization/fork of the Factor VM.

## Tests

Use the Factor language executable, not GNU coreutils `factor`:

```sh
make -C fuse test FACTOR=/absolute/path/to/factor
make -C fuse test-native FACTOR=/absolute/path/to/factor
make -C fuse test-mount FACTOR=/absolute/path/to/factor
```

`test` runs Factor unit tests without FUSE installed. `test-native` compiles a
harness against the real FUSE headers and calls into Factor through the real C
bridge. It checks native metadata, partial reads, directory-buffer exhaustion
and continuation offsets, errors, read-only opens, and repeated callback
cleanup. It requires headers but no driver or mount privileges.

`test-mount` is a Linux integration test. It builds the production library,
mounts in a temporary directory, checks `ls`/`cat`, `pread`, sizes and
permissions, rejects mutations, and unmounts. It requires working `/dev/fuse`
access and `fusermount3` (or `fusermount`).

ABI references: [libfuse high-level API](https://github.com/libfuse/libfuse/blob/master/include/fuse.h)
and [macFUSE libfuse API](https://github.com/macfuse/library/blob/master/include/fuse.h).

Verified on `linuxmini` (x86-64 Linux, libfuse 3.18.2) on 2026-09-28:
Factor unit tests, native callback tests, and a real mount with read-only
mutation checks all passed. The test unmounted cleanly. Native callback tests
also pass against macFUSE headers on macOS; a real macOS mount is not yet tested.

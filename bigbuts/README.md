# BigButs

A Factor implementation of Martin Blais's [BigButs launcher](https://furius.ca/pubcode/pub/conf/bin/bigbuts.html), for macOS and Unix desktops with Factor's UI available.

From the repository root, using a Factor language executable (not GNU coreutils `factor`):

```sh
export FACTOR_BIN=/Users/john/Developer/factor/factor
export PATH="$PWD/bigbuts/bin:$PATH"
bigbuts bigbuts/example.conf
```

The wrapper locates this repository automatically. It can also read standard input:

```sh
printf 'hello: echo "Hello $USER"\nwhere: pwd\n' | bigbuts
bigbuts -l /tmp/bigbuts-logs bigbuts/example.conf
```

Configuration is one `label: command` per line. Blank lines and lines beginning with `#` are ignored. The first colon separates the label from the command; subsequent colons are preserved. A line without a colon uses its first word as the label. Commands execute through `/bin/sh`, supporting environment variables, quoting, pipelines, and redirection. Each click starts another independent process without blocking the UI.

An executable configuration can start with `#!/usr/bin/env bigbuts`; give it execute permission and ensure `bigbuts/bin` is on `PATH`.

- **Tab** or **R** cycles through four button arrangements.
- **Ctrl-C** sends SIGINT to running command groups. Repeat to send SIGKILL. Launching a command, rotating, or scrolling resets escalation.
- **Mouse wheel** inserts blank lines into the terminal output.
- Closing the window leaves commands running. Keep the originating terminal open if commands still need its input or output.
- `-l DIRECTORY` or `--log DIRECTORY` mirrors output to `PID.stdout` and `PID.stderr` files using Bash and `tee`. Output stays visible in the originating terminal.
- Window position, size, and orientation are saved every second and on close in `~/.bigbuts/`. File configurations have independent entries keyed by absolute path; stdin configurations are keyed by contents. Identical configurations share an entry.
- `-g` or `--no-geometry` skips restoring saved geometry. `-h` or `--help` prints usage.

This implements the graphical launcher; the original's optional console menu and font-family flag are not included. The downloaded Python source is unchanged.

Run the tests in a Factor listener after adding this repository to the vocabulary roots:

```factor
USING: bigbuts tools.test ;
"bigbuts" test
```

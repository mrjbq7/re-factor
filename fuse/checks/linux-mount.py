#!/usr/bin/env python3
"""Real Linux FUSE mount test: python3 linux-mount.py /path/to/factor"""
import errno
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

root = Path(__file__).resolve().parents[2]
factor = str(Path(sys.argv[1]).resolve())
unmount = shutil.which("fusermount3") or shutil.which("fusermount")
if not unmount or not Path("/dev/fuse").exists():
    raise SystemExit("Install FUSE and make /dev/fuse available first")
env = dict(os.environ, FACTOR_FUSE_ROOT=str(root))
# Always test the production bridge, even after running the native harness.
env.pop("FACTOR_FUSE_LIBRARY", None)
subprocess.run(["make", "-C", str(root / "fuse")], check=True)
with tempfile.TemporaryDirectory(prefix="factor-fuse-") as tmp:
    mount = Path(tmp) / "mount"
    mount.mkdir()
    with open(Path(tmp) / "server.log", "w+") as log:
        server = subprocess.Popen(
            [factor, "-no-user-init", str(root / "fuse/checks/mount.factor"), str(mount)],
            env=env, stdout=log, stderr=subprocess.STDOUT,
        )
        try:
            deadline = time.monotonic() + 30
            while not os.path.ismount(mount):
                if server.poll() is not None or time.monotonic() > deadline:
                    log.seek(0)
                    raise RuntimeError("Mount failed:\n" + log.read())
                time.sleep(0.1)
            assert sorted(os.listdir(mount)) == ["kernel", "math"]
            assert "dup" in os.listdir(mount / "kernel")
            assert "%2F" in os.listdir(mount / "math")
            word = mount / "kernel/dup"
            text = subprocess.check_output(["cat", str(word)])
            assert b"Word description" in text and b"dup" in text
            assert word.stat().st_size == len(text)
            assert word.stat().st_mode & 0o777 == 0o444
            assert (mount / "kernel").stat().st_mode & 0o777 == 0o555
            with word.open("rb") as stream:
                assert os.pread(stream.fileno(), 7, 3) == text[3:10]
                assert os.pread(stream.fileno(), 100, len(text)) == b""
            assert (mount / "math/%2F").read_bytes()
            try:
                (mount / "kernel/no-such-word").stat()
            except FileNotFoundError:
                pass
            else:
                raise AssertionError("Missing word exists")
            mutations = [
                lambda: word.write_bytes(b"modified"),
                lambda: (mount / "kernel/new-word").write_bytes(b"new"),
                lambda: word.unlink(),
                lambda: word.rename(mount / "kernel/renamed"),
                lambda: word.chmod(0o600),
                lambda: (mount / "new-vocab").mkdir(),
            ]
            for mutate in mutations:
                try:
                    mutate()
                except OSError as error:
                    assert error.errno in (errno.EROFS, errno.EACCES, errno.EPERM), error
                else:
                    raise AssertionError("Read-only filesystem allowed a mutation")
            assert word.read_bytes() == text
            print("Linux mount, cat, byte ranges, filenames, metadata and read-only tests passed.")
        finally:
            if os.path.ismount(mount):
                subprocess.run([unmount, "-u", str(mount)], check=True)
            try:
                server.wait(timeout=10)
            except subprocess.TimeoutExpired:
                server.terminate()
                server.wait(timeout=10)
        assert server.returncode == 0, server.returncode

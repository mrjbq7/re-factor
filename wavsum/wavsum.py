#!/usr/bin/env python
from struct import calcsize, unpack
from sys import argv, exit

def word_iter(f):
    while True:
        _bytes = f.read(2)

    if len(_bytes) != 2:
        raise StopIteration

    yield unpack("=h", _bytes)[0]

try:
    with open(argv[1], "rb") as f:
        wav = "=4ci8cihhiihh4ci"
        wav_size = calcsize(wav)
        metadata = unpack(wav, f.read(wav_size))

        if "".join(metadata[:4]) != "RIFF":
            print "error: not wav file."
            exit(1)

        print sum(abs(word) for word in word_iter(f))
except IOError:
    print "error: can't open input file '%s'." % argv[1]
    exit(1)

from __future__ import print_function

import os
import re
import sys

# FIXME: initialize once, then shutdown at the end, rather than each call?
# FIXME: should we pass startIdx and endIdx into function?
# FIXME: don't return number of elements since it always equals allocation?

functions = []
if sys.platform == 'win32':
    include_dirs = [
        r"c:\ta-lib\c\include",
        r"c:\Program Files\TA-Lib\include",
        r"c:\Program Files (x86)\TA-Lib\include",
    ]
else:
    include_dirs = [
        '/usr/include',
        '/usr/local/include',
        '/opt/include',
        '/opt/local/include',
        '/opt/homebrew/include',
        '/opt/homebrew/opt/ta-lib/include',
    ]

if 'TA_INCLUDE_PATH' in os.environ:
    include_dirs = os.environ['TA_INCLUDE_PATH'].split(os.pathsep)

header_found = False
for path in include_dirs:
    ta_func_header = os.path.join(path, 'ta-lib', 'ta_func.h')
    if os.path.exists(ta_func_header):
        header_found = True
        break
if not header_found:
    print('Error: ta-lib/ta_func.h not found', file=sys.stderr)
    sys.exit(1)
with open(ta_func_header) as f:
    tmp = []
    for line in f:
        if line.startswith('TA_LIB_API'):
            line = line[10:]
        line = line.strip()
        if tmp or \
            line.startswith('TA_RetCode TA_') or \
            line.startswith('int TA_'):
            line = re.sub(r'/\*[^\*]+\*/', '', line) # strip comments
            tmp.append(line)
            if not line:
                s = ' '.join(tmp)
                s = re.sub(r'\s+', ' ', s)
                functions.append(s)
                tmp = []

# strip "float" functions
functions = [s for s in functions if not s.startswith('TA_RetCode TA_S_')]

# strip non-indicators
functions = [s for s in functions if not s.startswith('TA_RetCode TA_Set')]
functions = [s for s in functions if not s.startswith('TA_RetCode TA_Restore')]

# print headers
print("""\
! Copyright (C) 2025 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.data combinators
combinators.short-circuit formatting kernel locals math
math.order sequences sequences.private specialized-arrays
ta-lib.ffi ;

IN: ta-lib

SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: int

<PRIVATE

: ta-check-success ( ret_code -- )
    {
        { 0 [ f ] }
        { 1 [ "Library Not Initialized (TA_LIB_NOT_INITIALIZE)" ] }
        { 2 [ "Bad Parameter (TA_BAD_PARAM)" ] }
        { 3 [ "Allocation Error (TA_ALLOC_ERR)" ] }
        { 4 [ "Group Not Found (TA_GROUP_NOT_FOUND)" ] }
        { 5 [ "Function Not Found (TA_FUNC_NOT_FOUND)" ] }
        { 6 [ "Invalid Handle (TA_INVALID_HANDLE)" ] }
        { 7 [ "Invalid Parameter Holder (TA_INVALID_PARAM_HOLDER)" ] }
        { 8 [ "Invalid Parameter Holder Type (TA_INVALID_PARAM_HOLDER_TYPE)" ] }
        { 9 [ "Invalid Parameter Function (TA_INVALID_PARAM_FUNCTION)" ] }
        { 10 [ "Input Not All Initialized (TA_INPUT_NOT_ALL_INITIALIZE)" ] }
        { 11 [ "Output Not All Initialized (TA_OUTPUT_NOT_ALL_INITIALIZE)" ] }
        { 12 [ "Out-of-Range Start Index (TA_OUT_OF_RANGE_START_INDEX)" ] }
        { 13 [ "Out-of-Range End Index (TA_OUT_OF_RANGE_END_INDEX)" ] }
        { 14 [ "Invalid List Type (TA_INVALID_LIST_TYPE)" ] }
        { 15 [ "Bad Object (TA_BAD_OBJECT)" ] }
        { 16 [ "Not Supported (TA_NOT_SUPPORTED)" ] }
        { 5000 [ "Internal Error (TA_INTERNAL_ERROR)" ] }
        { 65535 [ "Unknown Error (TA_UNKNOWN_ERR)" ] }
        [ "Unknown Error (%d)" sprintf ]
    } case [ throw ] when* ;

ERROR: different-array-lengths ;

: check-array ( real -- real' )
    dup double-array? [ double >c-array ] unless ;

:: check-length2 ( a1 a2 -- n )
    a1 length :> len1
    a2 length :> len2
    len1 len2 = [ different-array-lengths ] unless
    len1 ;

:: check-length3 ( a1 a2 a3 -- n )
    a1 length :> len1
    a2 length :> len2
    a3 length :> len3
    len1 len2 = [ different-array-lengths ] unless
    len2 len3 = [ different-array-lengths ] unless
    len1 ;

:: check-length4 ( a1 a2 a3 a4 -- n )
    a1 length :> len1
    a2 length :> len2
    a3 length :> len3
    a4 length :> len4
    len1 len2 = [ different-array-lengths ] unless
    len2 len3 = [ different-array-lengths ] unless
    len3 len4 = [ different-array-lengths ] unless
    len1 ;

:: check-begidx1 ( a1 -- n )
    a1 [ fp-nan? not ] find drop [ a1 length 1 - ] unless* ;

:: check-begidx2 ( a1 a2 -- n )
    a1 length [
        {
            [ a1 nth-unsafe fp-nan? ]
            [ a2 nth-unsafe fp-nan? ]
        } 1|| not
    ] find-integer [ a1 length 1 - ] unless* ;

:: check-begidx3 ( a1 a2 a3 -- n )
    a1 length [
        {
            [ a1 nth-unsafe fp-nan? ]
            [ a2 nth-unsafe fp-nan? ]
            [ a3 nth-unsafe fp-nan? ]
        } 1|| not
    ] find-integer [ a1 length 1 - ] unless* ;

:: check-begidx4 ( a1 a2 a3 a4 -- n )
    a1 length [
        {
            [ a1 nth-unsafe fp-nan? ]
            [ a2 nth-unsafe fp-nan? ]
            [ a3 nth-unsafe fp-nan? ]
            [ a4 nth-unsafe fp-nan? ]
        } 1|| not
    ] find-integer [ a1 length 1 - ] unless* ;

:: make-double-array ( len lookback -- seq )
    len double (c-array) :> out
    len lookback min [ 0/0. swap out set-nth-unsafe ] each-integer
    out ;

:: make-int-array ( len lookback -- seq )
    len int (c-array) :> out
    len lookback min [ 0 swap out set-nth-unsafe ] each-integer
    out ;

PRIVATE>
""")

# cleanup variable names to make them more pythonic
def cleanup(name):
    name = name.replace('_', '-')
    if name.startswith('in'):
        return name[2:].lower()
    elif name.startswith('optIn'):
        return name[5:].lower()
    else:
        return name.lower()

# print functions
names = []
for f in functions:
    if 'Lookback' in f: # skip lookback functions
        continue

    i = f.index('(')
    name = f[:i].split()[1]
    args = f[i:].split(',')
    args = [re.sub(r'[\(\);]', '', s).strip() for s in args]

    shortname = name[3:].replace('_', '-')
    names.append(shortname)
    defaults, documentation = {}, ""

    print(':: %s (' % shortname, end=' ')
    for arg in args:
        var = arg.split()[-1]

        if var in ('startIdx', 'endIdx'):
            continue

        elif 'out' in var:
            break

        if var.endswith('[]'):
            var = cleanup(var[:-2])
            assert arg.startswith('const double'), arg
            print(var, end=' ')

        elif var.startswith('opt'):
            var = cleanup(var)
            print(var, end=' ')
            # XXX: default-values!

    print('--', end=' ')
    for arg in args:
        var = arg.split()[-1]
        if var in ('startIdx', 'endIdx', '*outBegIdx', '*outNBElement') or 'out' not in var:
            continue
        if var.endswith('[]'):
            var = cleanup(var[:-2])
            assert var.startswith('out'), var
            var = var[3:]
            print(var, end=' ')
        elif var.startswith('*'):
            var = cleanup(var[1:])
            assert var.startswith('out'), var
            var = var[3:]
            print(var, end=' ')
        else:
            assert False, arg

    print(')')

    for arg in args:
        var = arg.split()[-1]
        if 'out' not in var:
            continue
        if var.endswith('[]'):
            continue
        elif var.startswith('*'):
            var = cleanup(var[1:])
            print('    0 int <ref> :> %s' % var)
        else:
            assert False, arg

    for arg in args:
        var = arg.split()[-1]
        if 'out' in var:
            break
        if var.endswith('[]'):
            var = cleanup(var[:-2])
            print('    %s check-array :> in%s' % (var, var))

    # check all input array lengths are the same
    inputs = []
    for arg in args:
        var = arg.split()[-1]
        if 'out' in var:
            break
        if var.endswith('[]'):
            var = cleanup(var[:-2])
            inputs.append(var)
    if len(inputs) == 1:
        print('    in%s length :> len' % inputs[0])
    else:
        print('    %s check-length%s :> len' % (' '.join('in%s' % s for s in inputs), len(inputs)))

    # check for all input values are non-NaN
    print('    %s check-begidx%s :> begidx' % (' '.join('in%s' % s for s in inputs), len(inputs)))

    print('    len 1 - begidx - :> endidx')
    print('    ', end='')
    opts = [arg for arg in args if 'opt' in arg]
    for i, opt in enumerate(opts):
        if i > 0:
            print('', end=' ')
        var = opt.split()[-1]
        print(cleanup(var), end=' ')
    print('%s_Lookback begidx + :> lookback' % name)

    for arg in args:
        var = arg.split()[-1]

        if 'out' not in var:
            continue

        if var.endswith('[]'):
            var = cleanup(var[:-2])
            if 'double' in arg:
                print('    len lookback make-double-array :> %s' % var)
            elif 'int' in arg:
                print('    len lookback make-int-array :> %s' % var)
            else:
                assert False, args

    print('    ', end='')

    for i, arg in enumerate(args):
        var = arg.split()[-1]

        if var.endswith('[]'):
            var = cleanup(var[:-2])
            if 'out' in var:
                data = '%s lookback tail-slice' % var
            else:
                data = 'in%s begidx tail-slice' % var
            print('%s' % data, end=' ')

        elif var.startswith('*'):
            var = cleanup(var[1:])
            print('%s' % var, end=' ')

        else:
            cleaned = cleanup(var) if var != 'startIdx' else '0'
            print(cleaned, end=' ')

    print('%s ta-check-success' % name)
    if 'INDEX' in f:
        for arg in args:
            var = arg.split()[-1]

            if 'out' not in var:
                continue

            if var.endswith('[]'):
                var = cleanup(var[:-2])
                print('    lookback len %s <slice> [ begidx + ] map! drop' % var)
    print('    ', end='')
    i = 0
    for arg in args:
        var = arg.split()[-1]
        if var.endswith('[]'):
            var = var[:-2]
        elif var.startswith('*'):
            var = var[1:]
        if var.startswith('out'):
            if var not in ("outNBElement", "outBegIdx"):
                i += 1
                print(cleanup(var), end=' ')
        else:
            assert re.match('.*(void|startIdx|endIdx|opt|in)/*', arg), arg
    print(';')
    print('')

print('STARTUP-HOOK: [ TA_Initialize ta-check-success ]')

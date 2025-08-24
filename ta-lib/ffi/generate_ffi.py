from __future__ import print_function

import os
import re
import sys

# FIXME: initialize once, then shutdown at the end, rather than each call?
# FIXME: should we pass startIdx and endIdx into function?
# FIXME: don't return number of elements since it always equals allocation?

functions = []
include_paths = ['/usr/include', '/usr/local/include', '/opt/include', '/opt/local/include', '/opt/homebrew/include']
if sys.platform == 'win32':
    include_paths = [r'c:\ta-lib\c\include']
header_found = False
for path in include_paths:
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
            line = re.sub('/\*[^\*]+\*/', '', line) # strip comments
            tmp.append(line)
            if not line:
                s = ' '.join(tmp)
                s = re.sub('\s+', ' ', s)
                functions.append(s)
                tmp = []

# strip "float" functions
functions = [s for s in functions if not s.startswith('TA_RetCode TA_S_')]

# strip non-indicators
functions = [s for s in functions if not s.startswith('TA_RetCode TA_Set')]
functions = [s for s in functions if not s.startswith('TA_RetCode TA_Restore')]

# print functions
names = []
for f in functions:

    print("FUNCTION:", end=' ')
    i = f.index('(')
    print(f[:i], end=' ')

    args = f[i:-4]
    args = re.sub('void', '', args)
    args = re.sub('(?:const )?(\S+) (\S+)\[\]', '\\1* \\2', args)
    args = re.sub('(\S+) \*(\S+)', '\\1* \\2', args)
    args = args.strip()

    print(args, end=' ')
    print(')')

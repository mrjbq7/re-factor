#!/usr/bin/env python

import os
import re
import time
from collections import defaultdict
from operator import itemgetter

root = '/tmp/20_newsgroups'
#root = '/tmp/mini_newsgroups'

t0 = time.time()

counts = defaultdict(int)

for dirpath, dirname, filenames in os.walk(root):
    for filename in filenames:
        f = open(os.path.join(dirpath, filename))
        for word in re.findall('\w+', f.read()):
            counts[word.lower()] += 1
        f.close()

print "Writing counts in decreasing order"
f = open('counts-decreasing-python', 'w')
for k, v in sorted(counts.items(), key=itemgetter(1), reverse=True):
    print >> f, '%s\t%d' % (k, v)
f.close()

print "Writing counts in decreasing order"
f = open('counts-alphabetical-python', 'w')
for k, v in sorted(counts.items(), key=itemgetter(0)):
    print >> f, '%s\t%d' % (k, v)
f.close()

print 'Finished in %s seconds' % (time.time() - t0)


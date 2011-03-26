
import string

chars = string.digits + string.ascii_uppercase + string.ascii_lowercase
primes = [1,41,2377,147299,9132313,566201239,35104476161,2176477521929]

def base62(n):
    s = []
    while n > 0:
        n, c = divmod(n, 62)
        s.append(chars[c])
    return "".join(reversed(s))

def udihash(n, length=5):
    return "%0*s" % (length, base62((n * primes[length]) % (62 ** length)))

for x in range(10):
    print x, udihash(x)



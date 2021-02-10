primes = []

def erato(n): #to generate primes
    primes = [n for n in range(2, n+1)]
    for i in range(int(n**0.5)+1):
        if primes[i]:
            for j in range(2*(i+1), n-1, i+2):
                primes[j] = 0
    return [n for n in primes if n]

def prod(iterable): #to make phi func more readable
    p = 1
    for n in iterable: p *= n
    return p

def phi(n):
    global primes
    f = set()

    for p in primes:
        if p > n: break
        if n % p == 0: f.add(p)

    return n * prod([x-1 for x in f]) // prod(f)

def necklaces(k, n):
    f = {1, n}
    for i in range(2, int(n**0.5)+1):
        if n % i == 0: f.update({i, n//i})

    necklaces = 0
    for x in f:
        necklaces += (phi(x) * k**(n//x))

    return necklaces//n

if __name__ == "__main__":
    primes = erato(1000) #list of primes for phi to use
    inputs =    ((2,12),(3,7),(9,4),(21,3),(99,2),(3,90),
                (123,18),(1234567,6),(12345678910,3))

    for k, x in inputs:
        print('(' + str(k) + ", " + str(x) + "): " + str(necklaces(k, x)))

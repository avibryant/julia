library(R.utils)

assert = function(bool) {
    if (!bool) stop('Assertion failed')
}

timeit = function(name, f, ..., times=5) {
    tmin = Inf
    for (t in 1:times) {
        t = system.time(f(...))["elapsed"]
        if (t < tmin) tmin = t
    }
    cat(sprintf("r,%s,%.8f\n", name, tmin*1000))
}

## fib ##

fib = function(n) {
    if (n < 2) {
        return(n)
    } else {
        return(fib(n-1) + fib(n-2))
    }
}

assert(fib(20) == 6765)
timeit("fib", fib, 20)

## parse_int ##

parseintperf = function(t) {
    for (i in 1:t) {
        # R doesn't support uint32 values
        n = floor(2^31-1*runif(1))
        s = intToHex(n)
        m = as.numeric(paste("0x",s,sep=""))
        assert(m == n)
    }
}

timeit("parse_int", parseintperf, 1000)

## quicksort ##

qsort_kernel = function(a, lo, hi) {
    i = lo
    j = hi
    while (i < hi) {
        pivot = a[floor((lo+hi)/2)]
        while (i <= j) {
            while (a[i] < pivot) i = i + 1
            while (a[j] > pivot) j = j - 1
            if (i <= j) {
                t = a[i]
                a[i] = a[j]
                a[j] = t
            }
            i = i + 1;
            j = j - 1;
        }
        if (lo < j) qsort_kernel(a, lo, j)
        lo = i
        j = hi
    }
    return(a)
}

qsort = function(a) {
  return(qsort_kernel(a, 1, length(a)))
}

sortperf = function(n) {
    v = runif(n)
    return(qsort(v))
}

timeit('quicksort', sortperf, 5000)

## mandel ##

mandel = function(z) {
    c = z
    maxiter = 80
    for (n in 1:maxiter) {
        if (Mod(z) > 2) return(n-1)
        z = z^2+c
    }
    return(maxiter)
}

mandelperf = function() {
    re = seq(-2,0.5,.1)
    im = seq(-1,1,.1)
    M = matrix(0.0,nrow=length(re),ncol=length(im))
    count = 1
    for (r in re) {
        for (i in im) {
            M[count] = mandel(complex(real=r,imag=i))
            count = count + 1
        }
    }
    return(M)
}

assert(sum(mandelperf()) == 14660)
timeit("mandel", mandelperf)

## pi_sum ##

pisum = function() {
    t = 0.0
    for (j in 1:500) {
        t = 0.0
        for (k in 1:10000) {
            t = t + 1.0/(k*k)
        }
    }
    return(t)
}

assert(abs(pisum()-1.644834071848065) < 1e-12);
timeit("pi_sum", pisum, times=1)

## rand_mat_stat ##

randmatstat = function(t) {
    n = 5
    v = matrix(0, nrow=t)
    w = matrix(0, nrow=t)
    for (i in 1:t) {
        a = matrix(rnorm(n*n), ncol=n, nrow=n)
        b = matrix(rnorm(n*n), ncol=n, nrow=n)
        c = matrix(rnorm(n*n), ncol=n, nrow=n)
        d = matrix(rnorm(n*n), ncol=n, nrow=n)
        P = cbind(a,b,c,d)
        Q = rbind(cbind(a,b),cbind(c,d))
        v[i] = sum(diag((t(P)%*%P)^4))
        w[i] = sum(diag((t(Q)%*%Q)^4))
    }
    s1 = sd(v)/mean(v)
    s2 = sd(w)/mean(w)
    return(c(s1,s2))
}

timeit("rand_mat_stat", randmatstat, 1000)

## rand_mat_mul ##

randmatmul = function(n) {
    A = matrix(runif(n*n), ncol=n, nrow=n)
    B = matrix(runif(n*n), ncol=n, nrow=n)
    return(A %*% B)
}

assert(randmatmul(1000)[1] >= 0)
timeit("rand_mat_mul", randmatmul, 1000)

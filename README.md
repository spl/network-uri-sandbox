This repository serves to demonstrate the problem with dependencies such as
those introduced by `network-uri >= 2.6`.

## Introduction

When `network-uri` was introduced, the proposed Cabal configuration was:

```
flag network-uri
  description:          Get Network.URI from the network-uri package
  default:              True

library
  [...]
  if flag(network-uri)
    build-depends:      network-uri >= 2.6
  else
    build-depends:      network < 2.6,
                        network-uri < 2.6
```

I ran into some problem with this; however, I am now unable to reproduce that
same problem with the same code. But I wanted to explore the variations of
dependencies for `network` and `network-uri` to see the effects on a build.

I created multiple example package configurations using the same sources. Each
example package `ex` has the file [`Main.hs`](./Main.hs) and a dependency
package `dep` with the file [`Dep.hs`](./Dep.hs). The only differences between
the packages are the `build-depends` as defined behind a flag `myflag`.

For each example (e.g. [`dep1-ex1`](./dep1-ex1)), go into the directory and run
`build.sh` to build everything from scratch. To clean the results, run
`clean.sh` in the top-level directory.

For background on the errors, on my system, I have `network-2.4.2.3` installed
globally. It was provided by the Haskell Platform.

## Experiments

The following summarizes the configuration and errors, or lack thereof, observed.

**dep1-ex1**

[`dep.cabal`](./dep1/dep.cabal):
```
if flag(myflag)
  build-depends:      network-uri >= 2.6
```

[`ex.cabal`](./dep1-ex1/ex.cabal):
```
if flag(myflag)
  build-depends:      network < 2.6
```

Error:
```
[1 of 1] Compiling Main             ( Main.hs, dist/build/Main.o )

Main.hs:10:19:
    Couldn't match expected type ‘URI’
                with actual type ‘network-uri-2.6.0.0:Network.URI.URI’
    NB: ‘URI’ is defined in ‘Network.URI’ in package ‘network-2.4.2.3’
        ‘network-uri-2.6.0.0:Network.URI.URI’
          is defined in ‘Network.URI’ in package ‘network-uri-2.6.0.0’
    In the first argument of ‘consumeURI’, namely ‘produceURI’
    In the expression: consumeURI produceURI
```

**dep2-ex1**

[`dep.cabal`](./dep2/dep.cabal):
```
if flag(myflag)
  build-depends:      network < 2.6
```

[`ex.cabal`](./dep2-ex1/ex.cabal):
```
if flag(myflag)
  build-depends:      network-uri >= 2.6
```

Error:
```
[1 of 1] Compiling Main             ( Main.hs, dist/build/Main.o )

Main.hs:10:19:
    Couldn't match expected type ‘URI’
                with actual type ‘network-2.4.2.3:Network.URI.URI’
    NB: ‘URI’
          is defined in ‘Network.URI’ in package ‘network-uri-2.6.0.0’
        ‘network-2.4.2.3:Network.URI.URI’
          is defined in ‘Network.URI’ in package ‘network-2.4.2.3’
    In the first argument of ‘consumeURI’, namely ‘produceURI’
    In the expression: consumeURI produceURI
```

**dep3**

For the next three examples, we use this [`dep.cabal`](./dep3/dep.cabal):
```
if flag(myflag)
  build-depends:      network >= 2.6, network-uri >= 2.6
else
  build-depends:      network < 2.6
```

**dep3-ex1**

[`ex.cabal`](./dep3-ex1/ex.cabal):
```
if flag(myflag)
  build-depends:      network < 2.6
```

No error.

**dep3-ex2**

[`ex.cabal`](./dep3-ex2/ex.cabal):
```
if flag(myflag)
  build-depends:      network-uri >= 2.6
```

Error:
```
[1 of 1] Compiling Main             ( Main.hs, dist/build/Main.o )

Main.hs:10:19:
    Couldn't match expected type ‘URI’
                with actual type ‘network-2.4.2.3:Network.URI.URI’
    NB: ‘URI’
          is defined in ‘Network.URI’ in package ‘network-uri-2.6.0.0’
        ‘network-2.4.2.3:Network.URI.URI’
          is defined in ‘Network.URI’ in package ‘network-2.4.2.3’
    In the first argument of ‘consumeURI’, namely ‘produceURI’
    In the expression: consumeURI produceURI
```

**dep3-ex3**

[`ex.cabal`](./dep3-ex3/ex.cabal):
```
if flag(myflag)
  build-depends:      network >= 2.6, network-uri >= 2.6
```

Error:
```
Preprocessing library example5-0.1...

Main.hs:3:8:
    Could not find module ‘Network.URI’
    It is a member of the hidden package ‘network-2.4.2.3’.
    Perhaps you need to add ‘network’ to the build-depends in your .cabal file.
    Use -v to see a list of the files searched for.
```

**dep4-ex1**

[`dep.cabal`](./dep4/dep.cabal):
```
if flag(myflag)
  build-depends:      network >= 2.6, network-uri >= 2.6
else
  build-depends:      network < 2.6, network-uri < 2.6
```

[`ex.cabal`](./dep4-ex1/ex.cabal):
```
if flag(myflag)
  build-depends:      network-uri >= 2.6
```

No error.

## Conclusion

My conclusion is that the constraints in [`dep4`](./dep4/dep.cabal) should be
used for any libray package using the `Network.URI` module. It is more
comprehensive and may help avoid problems with downstream packages.

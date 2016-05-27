# UpdateIndex

[![Build Status](https://travis-ci.org/KristofferC/UpdateIndex.jl.svg?branch=master)](https://travis-ci.org/KristofferC/UpdateIndex.jl)

`UpdateIndex` is a package to explore a method to get around the the problem I wrote about in https://github.com/JuliaLang/julia/issues/15630.

The issue: In Julia, the command `A[i] += s` quickly gets lowered to `A[i] = A[i] + s`. For normal arrays this is fine but it is sometimes expensive to call `A[i]` and we would like to avoid that.

This package introduces the macro `@update!` that transforms the expression `A[i...] ?= s` where `?` is some binary infix operator to the call `updateindex!(A, ?, s, i...)`. The default fallback method for `updateindex!` is: `updateindex!(A, f::Function, s, I::Vararg) = A[I...] = f(A[I...], s)` which will just do the same thing as if no macro would have been used. 

A type that implements `getindex` and `setindex!` can now chose to implement `updateindex!` for faster updates.

As a proof of concept, this package implements `updateindex!` for scalar indexing into a sparse matrix.

```jl
julia>  const A = sprand(10^4, 10^4, 0.01);

julia> A[1000, 1000] = 1
1

julia> @time for i in 1:10^5 # Normal way
           A[1000, 1000] += 1
       end
  0.003079 seconds

julia> @time for i in 1:10^5 # With macro, almost 2x faster
           @update! A[1000, 1000] += 1
       end
  0.001677 seconds
```





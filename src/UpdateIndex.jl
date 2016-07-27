module UpdateIndex

export @update!, updateindex!

macro update!(ex)
    @assert isa(ex.head, Symbol)
    opstr = string(ex.head)
    @assert length(opstr) == 2
    op = Symbol(opstr[1:1])
    @assert Symbol(opstr[2:2]) == :(=)
    arr = ex.args[1].args[1]
    inds = ex.args[1].args[2:end]
    s = ex.args[2]
    return :(updateindex!($(esc(arr)), $(esc(op)), $(esc(s)), $(map(esc, inds)...)))
end

updateindex!(A, f, s, i) = A[i] = f(A[i], s)
updateindex!(A, f, s, i, j) = A[i, j] = f(A[i, j], s)
updateindex!(A, f, s, i, j, k) = A[i, j, k] = f(A[i, j, k], s)
updateindex!(A, f, s, i, j, k, l) = A[i, j, k, l] = f(A[i, j, k, l], s)
updateindex!(A, f, s, I::Vararg) = A[I...] = f(A[I...], s)

# SparseMatrix updateindex!
import Base.Order.Forward

function updateindex!{T,Ti}(A::SparseMatrixCSC{T,Ti}, f, s, i0::Integer, i1::Integer)
    i0 = convert(Ti, i0)
    i1 = convert(Ti, i1)
    if !(1 <= i0 <= A.m && 1 <= i1 <= A.n); throw(BoundsError()); end
    r1 = Int(A.colptr[i1])
    r2 = Int(A.colptr[i1+1]-1)
    i = (r1 > r2) ? r1 : searchsortedfirst(A.rowval, i0, r1, r2, Forward)

    if (i <= r2) && (A.rowval[i] == i0)
        A.nzval[i] = f(A.nzval[i], s)
    else
        insert!(A.rowval, i, i0)
        insert!(A.nzval, i, f(zero(T), s))
        @simd for j = (i1+1):(A.n+1)
            @inbounds A.colptr[j] += 1
        end
    end
    return A
end

end # module

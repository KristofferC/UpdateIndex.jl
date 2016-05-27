using UpdateIndex
using Base.Test


A = zeros(Int, 5,5)
@update! A[3,2] += 2
@test A[3,2] == 2
updateindex!(A, -, 2, 3, 2)
@test A[3,2] == 0

Asp = spzeros(5,5)
Asp[3,3] += 1.0
@update! Asp[3,3] += 2.0
@test Asp[3,3] == 3.0
updateindex!(Asp, -, 2.0, 3, 3)
@test Asp[3,3] == 1.0

met = @which(updateindex!(Asp, -, 2.0, 3, 3))
# Check overloading is woking
if VERSION <= v"0.5-dev"
    @test string(met.sig.parameters[1].name) == "SparseMatrixCSC"
else
    @test string(met.sig.parameters[2].name) == "SparseMatrixCSC"
end

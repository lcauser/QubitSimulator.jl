using QubitSimulator
using Test
using TeNe
using LinearAlgebra

@testset "Unit Testing" begin
    include("unit/qubits/qubit.jl")
    include("unit/qubits/qubitcollection.jl")
    include("unit/pulses/pulses.jl")
end

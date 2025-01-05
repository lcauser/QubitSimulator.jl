using QubitSimulator
using Test
using TeNe
using LinearAlgebra

@testset "Unit Testing" begin
    @testset "Qubit" begin
        include("unit/qubits/qubit.jl")
        include("unit/qubits/qubitcollection.jl")
    end 

    @testset "Pulses" begin
        include("unit/pulses/pulses.jl")
        include("unit/pulses/square.jl")
    end
end

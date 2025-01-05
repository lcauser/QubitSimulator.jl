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
    
    @testset "Calibrations" begin
        include("unit/calibrate/calibrate.jl")
        include("unit/calibrate/xcalibrate.jl")
    end
end

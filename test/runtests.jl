using QubitSimulator
using Test
using TeNe

@testset "QubitSimulator.jl" begin
    include("qubits.jl")
    include("hardwaremodel.jl")
end

using QubitSimulator
using Test

@testset "QubitSimulator.jl" begin
    include("qubits.jl")
    include("hardwaremodel.jl")
end

@testset "Grid-search" begin
    @testset "SquarePulse" begin
        qubit = Qubit(3)
        pulse = SquarePulse(; width=8e-7)
        cal = XCalibrate(qubit, pulse, :amplitude; steps=1)
        gridsearch(cal)
        
        @test false
    end
end
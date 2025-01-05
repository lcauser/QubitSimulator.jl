@testset "XCalibrate" begin 
    @testset "Instantiation" begin 
        @testset "Single-parameter" begin
            qubit = Qubit(2)
            pulse = SquarePulse()
            cal = XCalibrate(qubit, pulse, :width)
            @test length(getparameters(cal)) == 1
            @test getparameters(cal)[:width] == pulse.width
        end

        @testset "Two-parameters" begin
            qubit = Qubit(2)
            pulse = SquarePulse()
            cal = XCalibrate(qubit, pulse, [:width, :amplitude])
            @test length(getparameters(cal)) == 2
            @test getparameters(cal)[:width] == pulse.width
            @test getparameters(cal)[:amplitude] == pulse.amplitude
        end
    end

    @testset "createpulse" begin 
        @testset "SquarePulse" begin
            qubit = Qubit(2)
            pulse = SquarePulse()
            cal = XCalibrate(qubit, pulse, :width)
            getparameters(cal)[:width] = 10.0
            new_pulse = createpulse(cal)
            @test typeof(new_pulse) == SquarePulse
            @test new_pulse.width == 10.0 
            @test new_pulse.amplitude == pulse.amplitude
        end
    end
end
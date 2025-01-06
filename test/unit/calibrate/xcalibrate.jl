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

        @testset "Target-gate" begin 
            qubit = Qubit(2; T1=1e10, T2=1e10)
            pulse = SquarePulse(; width=1e-7, amplitude=(π/4)/1e-7)
            cal = XCalibrate(qubit, pulse, :width)
            actual_op = createLsuperop(qubit, pulse)
            @test isapprox(actual_op, cal.target)
            
            # long pulses give better results for no decoherence
            qubit = Qubit(3; T1=1e10, T2=1e10)
            pulse = SquarePulse(; width=1e-6, amplitude=(π/4)/1e-6)
            cal = XCalibrate(qubit, pulse, :width)
            actual_op = createLsuperop(qubit, pulse)
            diff = (1 .- isapprox.(cal.target,  0.0)) .* (abs.(actual_op .- cal.target))
            @test all(diff .< 1e-2)
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
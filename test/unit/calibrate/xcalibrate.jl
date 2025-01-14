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
            cal = XCalibrate(qubit, pulse, :width, :amplitude)
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

    @testset "objective" begin 
        @testset "SquarePulse" begin 
            @testset "Exact-two-level" begin
                qubit = Qubit(2; T1=1e10, T2=1e10)
                pulse = SquarePulse(; width=1e-6, amplitude=(π/4)/1e-6)
                cal = XCalibrate(qubit, pulse, :width)
                for i in [1, 5, 9]
                    cal.parameters[:width] = i * 1e-6
                    val = objective(cal)
                    @test val < 1e-10
                end
            end

            @testset "Inexact-two-level" begin
                qubit = Qubit(2)
                pulse = SquarePulse(; width=1e-6, amplitude=(π/4)/1e-6)
                cal = XCalibrate(qubit, pulse, :width)
                vals = []
                for i in [1, 5, 9]
                    cal.parameters[:width] = i * 1e-6
                    push!(vals, objective(cal))
                    if i > 1
                        @test vals[end] > vals[end-1]
                    end
                end
            end

            @testset "Three-level-no-decoherence" begin 
                qubit = Qubit(3; T1=1e10, T2=1e10)
                pulse = SquarePulse()
                cal = XCalibrate(qubit, pulse, :width, :amplitude)
                widths = 10 .^ (-8:0.1:-4)
                vals = []
                for width in widths
                    cal.parameters[:amplitude] = π/(4*width)
                    cal.parameters[:width] = width 
                    push!(vals, objective(cal))
                end
                diffs = vals[begin:end-1] - vals[begin+1:end]
                @test all(diffs .> 0.0)
                @test vals[end] < 1e-3
            end
        end
    end
end
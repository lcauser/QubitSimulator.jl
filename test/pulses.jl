@testset "Pulses" begin
    @testset "Square Pulse" begin
        @testset "Constructors" begin
            @test begin
                SquarePulse()
                true
            end
            @test begin
                SquarePulse(1.3)
                true
            end
            @test begin
                SquarePulse(1.3, 2.1)
                true
            end
            @test begin
                SquarePulse(width=1.3)
                true
            end
            @test begin
                SquarePulse(amplitude=2.1)
                true
            end
            @test begin
                SquarePulse(width=1.3, amplitude=2.1)
                true
            end
        end

        @testset "Shape" begin 
            pulse = SquarePulse(width=1e-7, amplitude=1e7)
            ts, pulse_shape = shape(pulse; steps=41)
            @test length(pulse_shape) == 42
            @test length(ts) == 42
            @test pulse_shape = 1e7*ones(42)
            @test ts == Base.range(0, pulse.width, step=pulse.width/41)
        end
    end
end
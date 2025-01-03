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
            pulse_shape = shape(pulse; steps=41)
            @test length(pulse_shape) == 42
            @test pulse_shape == 1e7*ones(42)
        end

        @testset "creatematrix" begin 
            for n = 2:5
                @testset "creatematrix-$(n)" begin
                    qubit = randomqubit(n) 
                    pulse = SquarePulse()
                    @testset "sanity" begin
                        U = creatematrix(qubit, pulse)
                        @test size(U) == (n, n)
                        @test isapprox(U * conj(transpose(U)),  diagm(ones(n)))
                    end

                    @testset "yields-same-as-single-exponential" begin
                        # square pulses are time-independant, so the exponention can be done
                        # as exp(integrate(H)).
                        U1 = creatematrix(qubit, pulse; steps=1)
                        U2 = creatematrix(qubit, pulse)
                        H = qubit.H0 + pulse.amplitude * (qubit.a + qubit.adag)
                        U3 = exp(-1im*width(pulse)*H)
                        @test isapprox(U1, U2)
                        @test isapprox(U2, U3)
                    end
                end
            end

            @testset "two-level-analytical-tests" begin
                qubit = randomqubit(2)
                pulse = SquarePulse((pi/2)/1.3e7, 1.3e7)
                U = creatematrix(qubit, pulse)
                @test isapprox(U, -1im*[0 1; 1 0])
                U = creatematrix(qubit, pulse; phase=pi/2)
                @test isapprox(U, [0 1; -1 0])
            end

            @testset "three-level-approximate-tests" begin 
                # optimal two-level pulses tested on three-level systems.
                # use slow pulses to reduce leakage into the third-level, check they're 
                # approximately the same
                qubit = randomqubit(3)
                amp = 1e6
                pulse = SquarePulse((pi/2)/amp, amp)
                U = creatematrix(qubit, pulse)
                @test isapprox(U, transpose(U))
                @test abs(U[1, 1]) < 5e-2
                @test abs(U[2, 2]) < 5e-2
                @test 1 - abs(U[1, 2]) < 5e-2

                U = creatematrix(qubit, pulse; phase=pi/2)
                @test isapprox(U[1, 2], -U[2, 1])
                @test abs(U[1, 1]) < 5e-2
                @test abs(U[2, 2]) < 5e-2
                @test 1 - abs(U[1, 2]) < 5e-2
            end
        end
    end
end
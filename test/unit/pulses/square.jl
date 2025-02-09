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

    @testset "shape" begin 
        pulse = SquarePulse(width=1e-7, amplitude=1e7)
        pulse_shape = shape(pulse; steps=50)
        @test length(pulse_shape) == 50
        @test pulse_shape == 1e7*ones(50)
    end

    @testset "midpointtimes" begin
        w = 1e-7
        pulse = SquarePulse(width=1e-7, amplitude=1e7)
        times = midpointtimes(pulse)
        diff = true
        δt = w / 100
        for i in Base.OneTo(99)
            diff = isapprox(times[i+1] - times[i], δt) ? diff : false
        end
        @test diff 
        @test isapprox(times[begin], -(w-δt)/2)
        @test isapprox(times[end], (w-δt)/2)
    end

    @testset "defaultparameterrange" begin
        width_grid = defaultparameterrange(SquarePulse(), :width, 51)
        @test width_grid[begin] == 10 ^ QubitSimulator._square_width_min_exponent
        @test width_grid[end] == 10 ^ QubitSimulator._square_width_max_exponent
        amp_grid = defaultparameterrange(SquarePulse(), :amplitude, 51)
        @test amp_grid[begin] == 10 ^ QubitSimulator._square_amp_min_exponent
        @test amp_grid[end] == 10 ^ QubitSimulator._square_amp_max_exponent
    end

    @testset "createH0unitary" begin 
        for n = 2:5
            @testset "createH0unitary-$(n)" begin
                qubit = randomqubit(n) 
                pulse = SquarePulse()
                @testset "sanity" begin
                    U = createH0unitary(qubit, pulse)
                    @test size(U) == (n, n)
                    @test isapprox(U * conj(transpose(U)),  diagm(ones(n)))
                end

                @testset "yields-same-as-single-exponential" begin
                    # square pulses are time-independant, so the exponention can be done
                    # as exp(integrate(H)).
                    U1 = createH0unitary(qubit, pulse; steps=1)
                    U2 = createH0unitary(qubit, pulse)
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
            U = createH0unitary(qubit, pulse)
            @test isapprox(U, -1im*[0 1; 1 0])
            U = createH0unitary(qubit, pulse; phase=pi/2)
            @test isapprox(U, [0 1; -1 0])
        end

        @testset "three-level-approximate-tests" begin 
            # optimal two-level pulses tested on three-level systems.
            # use slow pulses to reduce leakage into the third-level, check they're 
            # approximately the same
            qubit = randomqubit(3)
            amp = 1e6
            pulse = SquarePulse((pi/2)/amp, amp)
            U = createH0unitary(qubit, pulse)
            @test isapprox(U, transpose(U))
            @test abs(U[1, 1]) < 5e-2
            @test abs(U[2, 2]) < 5e-2
            @test 1 - abs(U[1, 2]) < 5e-2

            U = createH0unitary(qubit, pulse; phase=pi/2)
            @test isapprox(U[1, 2], -U[2, 1])
            @test abs(U[1, 1]) < 5e-2
            @test abs(U[2, 2]) < 5e-2
            @test 1 - abs(U[1, 2]) < 5e-2
        end
    end

    @testset "createHeffUnitary" begin
        @testset "Heff-equals-H0-with-no-decoherence" begin
            for n = 2:5
                for phase = [0.0, π/2, π, 0.721]
                    # set decay times to be very large so they're negliable
                    qubit = Qubit(n; T1=1e10, T2=1e10) 
                    pulse = SquarePulse()
                    H0 = createH0unitary(qubit, pulse; phase=phase)
                    Heff = createHeffunitary(qubit, pulse; phase=phase)
                    @test isapprox(H0, Heff)
                end
            end
        end
    end

    # TODO: determine better ways to super ops
    @testset "createL0superop-equals-createLsuperop-with-no-decoherence" begin 
        for n = 2:5
            for phase = [0.0, π/2, π, 0.721]
                # set decay times to be very large so they're negliable
                qubit = Qubit(n; T1=1e10, T2=1e10) 
                pulse = SquarePulse()
                L0 = createL0superop(qubit, pulse; phase=phase)
                L = createLsuperop(qubit, pulse; phase=phase)
                @test isapprox(L0, L)
            end
        end
    end
end
@testset "Qubits" begin
    # test levels
    for i = 2:4
        begin
            qubit = Qubit(i)
            @test levels(qubit) == i
        end
    end

    # test keyword arguments
    begin 
        qubit = Qubit(
            4;
            frequency=5e9,
            anharmonicity=2e8,
            T1=200e-6,
            T2=150e-6
        )
        @test qubit.frequency == 5e9
        @test qubit.anharmonicity == 2e8
        @test qubit.T1 == 200e-6
        @test qubit.T2 == 150e-6
    end

    # test random 
    begin 
        qubit1 = randomqubit(3)
        qubit2 = randomqubit(3)
        @test qubit1.frequency != qubit2.frequency
        @test qubit1.anharmonicity != qubit2.anharmonicity
        @test qubit1.T1 != qubit2.T1
        @test qubit1.T2 != qubit2.T2
    end

    # Test T1 times 
    begin
        for n = 2:5
            # set T2 time to be large so T2 decoherence is insignificant
            qubit = Qubit(n; T2=1e10)
            T1 = qubit.T1 

            # find the zero and one occupations to test T1 decohernece 
            bas = Basis(n)
            ts = 0.0:T1/100:2*T1
            st = state(bas.liouville, "1")
            occs = []
            for t in ts
                push!(occs, sum(st .* exp(t*qubit.L) * st))
            end
            @test isapprox(occs, exp.(-ts ./ T1))
        end
    end

    # Test T2 times 
    begin
        for n = 2:5
            # set T1 time to be large so T1 decoherence is insignificant
            qubit = Qubit(n; T1=1e10)
            T2 = qubit.T2 

            # Start in the |+> state and measure decoherence into |-> state 
            ts = 0.0:T2/100:2*T2
            occs = []
            st = zeros(ComplexF64, n)
            st[1] = st[2] = sqrt(0.5)
            st = kron(st, st)
            for t in ts
                push!(occs, sum((exp(t*qubit.L) * st))-1)
            end
            @test isapprox(occs, exp.(-ts ./ T2))
        end
    end
end
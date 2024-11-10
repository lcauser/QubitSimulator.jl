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
end
@testset begin "HardwareModel"
    # Test base model
    for n = 2:4
        begin
            # test initialization 
            model = HardwareModel(n)
            @test dim(model.lt) == n^2

            # test adding
            addqubit!(model, randomqubit(n))
            @test length(model.qubits) == 1
            @test qubit(model, 1) == model.qubits[1]
        end
    end

    # Test random model
    for n = 2:4
        for qubits = 1:10
            begin 
                model = randommodel(n, qubits)
                @test levels(model) == n
                @test length(model.qubits) == qubits
            end
        end
    end

    # Test the super operator 
    begin 
        model = randommodel(3, 5)
        proj = zeros(9)
        for i = 1:3
            proj += state(model.lt, string(i-1))
        end
        @test isapprox(sum(proj), 3.0)
        for i = 1:5
            rates = 0.0
            op = superop(model, i)
            @test size(op) == (9, 9)
            for j = 1:3
                st = state(model.lt, string(j-1))
                for k = 1:3
                    st2 = state(model.lt, string(k-1))
                    rates += transpose(st) * op * st2
                end
            end
            @test real(rates) < 1e-10
            @test imag(Rates)
        end
    end
end
@testset begin "QubitCollection"
    # Test base model
    for n = 2:4
        begin
            # test initialization 
            model = QubitCollection(n)
            @test dim(model.hilbert) == n
            @test dim(model.liouville) == n^2

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
            proj += state(model.liouville, string(i-1))
        end
        @test isapprox(sum(proj), 3.0)
        for i = 1:5
            rates = 0.0
            op = superop(model, i)
            @test size(op) == (9, 9)
            for j = 1:3
                st = state(model.liouville, string(j-1))
                for k = 1:3
                    st2 = state(model.liouville, string(k-1))
                    rates += transpose(st) * op * st2
                end
            end
            @test real(rates) < 1e-10
            @test imag(rates) < 1e-10
        end
    end

    # Test T1 times 
    begin
        model = randommodel(3, 1)

        # artifically set properties to just to see effects of T1
        model.qubits[1].T2 = 1e10
        T1 = model.qubits[1].T1
        ts = 0.0:T1/100:2*T1
        occs = []
        st = state(model.liouville, "1")
        for t in ts
            push!(occs, sum(st .* exp(t*superop(model, 1)) * st))
        end
        @test isapprox(occs, exp.(-ts ./ T1))
    end

    # Test T2 times 
    begin
        model = randommodel(3, 1)

        # artifically set properties to just to see effects of T1
        model.qubits[1].T1 = 1e10
        T2 = model.qubits[1].T2
        ts = 0.0:T2/100:2*T2
        occs = []
        st = kron([sqrt(0.5), sqrt(0.5), 0], [sqrt(0.5), sqrt(0.5), 0])
        for t in ts
            push!(occs, sum((exp(t*superop(model, 1)) * st))-1)
        end
        @test isapprox(occs, exp.(-ts ./ T2))
    end
end
@testset begin "QubitCollection"
    # Test base model
    @testset "Initiation-adding" begin
        for n = 2:4
            begin
                # test initialization 
                collection = QubitCollection(n)
                @test levels(collection) == levels(collection.basis) == n

                # test adding
                addqubit!(collection, randomqubit(n))
                @test length(collection.qubits) == 1
                @test qubit(collection, 1) == collection.qubits[1]
            end
        end
    end

    # Test random model
    @testset "random-collections" begin
        for n = 2:4
            for qubits = 1:10
                begin 
                    collection = randomcollection(n, qubits)
                    @test levels(collection) == n
                    @test length(collection.qubits) == qubits
                end
            end
        end
    end
end
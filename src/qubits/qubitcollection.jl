#=
    Models a collection of qubits.
=#

mutable struct QubitCollection
    basis::Basis
    qubits::Vector{Qubit}

    function QubitCollection(n::Int)
        return new(Basis(n), Qubit[])
    end
end
export QubitCollection

levels(collection::QubitCollection) = levels(collection.basis)

export qubit
qubit(model::QubitCollection, idx::Int) = model.qubits[idx]

export addqubit!
function addqubit!(collection::QubitCollection, qubit::Qubit)
    if levels(qubit) != levels(collection)
        throw(
            ArgumentError(
                "The number of levels in the qubit $(levels(qubit)) does " *
                "not match the qubit collection $(levels(collection))"
            )
        )
    end
    push!(collection.qubits, qubit)
end

export randomcollection
"""
    randomcollection(n::Int, num_qubits::Int; kwargs...)

Generate a collection of `num_qubits` random qubits with `n` levels. Use keyword arguments
to pass random arguments. 
"""
function randomcollection(n::Int, num_qubits::Int; kwargs...)
    collection = QubitCollection(n)
    for _ in Base.OneTo(num_qubits)
        addqubit!(collection, randomqubit(n; kwargs...))
    end

    return collection
end
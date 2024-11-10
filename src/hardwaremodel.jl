#=
    Models a collection of qubit and its pulse channels.
=#

mutable struct HardwareModel{n}
    lt::LatticeTypes
    qubits::Vector{Qubit{n}}
end

export HardwareModel
function HardwareModel(n::Int)
    return HardwareModel(
        LiouvilleWrapper(Bosons2(n)),
        Qubit{n}[]
    )
end

levels(qubit::HardwareModel{n}) where {n} = n

export qubit
qubit(model::HardwareModel, idx::Int) = model.qubits[idx]

export addqubit!
function addqubit!(model::HardwareModel, qubit::Qubit)
    push!(model.qubits, qubit)
end

export randommodel
function randommodel(n::Int, num_qubits::Int; kwargs...)
    model = HardwareModel(n)
    for i in Base.OneTo(num_qubits)
        addqubit!(model, randomqubit(n; kwargs...))
    end

    return model
end

export superop
function superop(model::HardwareModel, qubits::Int...)
    ops = OpList(model.lt, length(qubits))
    ctr = 1
    for idx in qubits
        qu = qubit(model, idx)

        # Add the Hamiltonian
        add!(ops, "n_id", ctr, -1im*qu.frequency)
        add!(ops, "id_n", ctr, 1im*qu.frequency)
        add!(ops, "n2_id", ctr, -1im*qu.anharmonicity/2)
        add!(ops, "id_n2", ctr, 1im*qu.anharmonicity/2)

        # Add T1 dissipator 
        add!(ops, "a_adag", ctr, 1/qu.T1)
        add!(ops, "n_id", ctr, -0.5/qu.T1)
        add!(ops, "id_n", ctr, -0.5/qu.T1)

        ctr += 1
    end

    return _createtensor(ops)
end

# tmp function: add quadratic terms to Bosons
function Bosons2(dim::Int)
    bosons = Bosons(dim)
    n2 = op(bosons, "adag")*op(bosons, "adag")*op(bosons, "a")*op(bosons, "a")
    add!(bosons, "n2", n2)
    return bosons
end

# tmp function: bugfix TeNe stateoperator(::oplist) and createtensor(::oplist)
# also dealing with "id_id" -> "id"
function _createtensor(ops::OpList)
    O = zeros(Base.eltype(ops), [dim(ops.lt) for _ = Base.OneTo(2*ops.length)]...)
    for i in eachindex(ops.ops)
        ten = ones(eltype(ops.lt), )
        k = 1
        for j = Base.OneTo(ops.length)
            if k <= length(ops.sites[i]) && ops.sites[i][k] == j
                oper = ops.ops[i][k]
                k += 1
            else
                oper = "id_id"
            end
            ten = tensorproduct(ten, op(ops.lt, oper))
        end
        O .+= ops.coeffs[i]*ten
    end
    return O
end
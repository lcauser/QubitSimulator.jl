#=
    Models a collection of qubit and its pulse channels.
=#

mutable struct HardwareModel{n}
    lt::LatticeTypes
    qubits::Vector{Qubit{n}}
end

export HardwareModel
function HardwareModel(n::Int)
    lt = Bosons(n)
    add!(lt, "z", op(lt, "id")-2*op(lt, "n"))
    add!(lt, "zdagz", adjoint(op(lt, "z"))*op(lt, "z"))
    return HardwareModel(
        LiouvilleWrapper(lt),
        Qubit{n}[]
    )
end

levels(model::HardwareModel{n}) where {n} = n

export qubit
qubit(model::HardwareModel, idx::Int) = model.qubits[idx]

export addqubit!
function addqubit!(model::HardwareModel, qubit::Qubit)
    push!(model.qubits, qubit)
end

export randommodel
function randommodel(n::Int, num_qubits::Int; kwargs...)
    model = HardwareModel(n)
    for _ in Base.OneTo(num_qubits)
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
        #add!(ops, "n_id", ctr, -1im*qu.frequency)
        #add!(ops, "id_n", ctr, 1im*qu.frequency)
        add!(ops, "n2_id", ctr, -1im*qu.anharmonicity/2)
        add!(ops, "id_n2", ctr, 1im*qu.anharmonicity/2)

        # Add T1 dissipator 
        add!(ops, "a_adag", ctr, 1/qu.T1)
        add!(ops, "n_id", ctr, -0.5/qu.T1)
        add!(ops, "id_n", ctr, -0.5/qu.T1)

        # Add T2 dissipator 
        add!(ops, "z_z", ctr, 0.5/qu.T2)
        add!(ops, "zdagz_id", ctr, -0.25/qu.T2)
        add!(ops, "id_zdagz", ctr, -0.25/qu.T2)

        ctr += 1
    end

    return totensor(ops)
end

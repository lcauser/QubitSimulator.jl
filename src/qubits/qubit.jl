#=
    A model of a qubit
=#

export Qubit
"""
    Qubit(n::Int; kwargs...)

Stores the properties of a qubit modelled as an `n`-level system. Computes and caches 
matrix computations on initialization.

# Optional keyword arguments
    - `frequency::Float64=4.45e9`
    - `anharmonicity::Float64=-1.80e8`
    - `T1::Float64=220e-6`
    - `T2::Float64=130e-6`
"""
struct Qubit
    # raw properties of the qubits
    n::Int
    frequency::Float64
    anharmonicity::Float64
    T1::Float64
    T2::Float64

    # pre-computed hilbert-space matrices 
    H0::Array
    Heff::Array
    a::Array
    adag::Array

    # pre-computered liouville-space matrices 
    L0::Array
    L::Array 


    function Qubit(n::Int; kwargs...)
        ω = get(kwargs, :frequency, 4.45e9)
        η = get(kwargs, :anharmonicity, -1.80e8)
        T1 = get(kwargs, :T1, 220e-6)
        T2 = get(kwargs, :T2, 130e-6)
        
        space = Basis(n)
        hilbert = space.hilbert
        H0 = _calculate_H0(hilbert, η) 
        Heff = _calculate_Heff(hilbert, η, T1, T2) 
        a = op(hilbert, "a")
        adag = op(hilbert, "adag")

        lioville = space.liouville
        L0 = _calculate_L0(lioville, η)
        L = _calculate_L(lioville, η, T1, T2)
        return new(
            n,
            ω,
            η,
            T1,
            T2, 
            H0,
            Heff,
            a,
            adag,
            L0,
            L
        )
    end
end

function _calculate_H0(hilbert::LatticeTypes, η::Float64)
    return 0.5*η*op(hilbert, "n2")
end

function _calculate_Heff(hilbert::LatticeTypes, η::Float64, T1::Float64, T2::Float64)
    return (
        0.5*η*op(hilbert, "n2")
        - 0.5im * T1 * op(hilbert, "n")
        - 0.25im * T2 * op(hilbert, "zdagz")
    )
end

function _calculate_L0(liouville::LatticeTypes, η::Float64)
    return (
        - 0.5im*η*op(liouville, "n2_id")
        + 0.5im*η*op(liouville, "id_n2")
    )
end

function _calculate_L(liouville::LatticeTypes, η::Float64, T1::Float64, T2::Float64)
    return (
        - 0.5im*η*op(liouville, "n2_id")
        + 0.5im*η*op(liouville, "id_n2")
        + (1/T1) * (
            op(liouville, "a_adag")
            - 0.5 * op(liouville, "n_id")
            - 0.5 * op(liouville, "id_n")
        )
        + (0.5/T2) * (
            op(liouville, "z_z")
            - 0.5 * op(liouville, "zdagz_id")
            - 0.5 * op(liouville, "id_zdagz")
        )
    )
end

export levels 
levels(qubit::Qubit) = qubit.n

export randomqubit
function randomqubit(n::Int)
    # TODO: add keyword arguments for randomization
    return Qubit(
        n;
        frequency=4.45e9+randn()*2e8,
        anharmonicity=-1.80e8+randn()*2e7,
        T1=220e-6+randn()*20e-6,
        T2=130e-6+randn()*10e-6
    )
end
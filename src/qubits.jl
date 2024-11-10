#=
    A model of a qubit
=#

export Qubit
mutable struct Qubit{n}
    frequency::Float64
    anharmonicity::Float64
    T1::Float64
    T2::Float64
end

function Qubit(n::Int; kwargs...)
    return Qubit{n}(
        get(kwargs, :frequency, 4.45e9),
        get(kwargs, :anharmonicity, -1.80e8),
        get(kwargs, :T1, 220e-6),
        get(kwargs, :T2, 130e-6),
    )
end

export levels 
levels(qubit::Qubit{n}) where {n} = n

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
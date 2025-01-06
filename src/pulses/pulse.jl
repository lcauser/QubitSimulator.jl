#=
    Pulses are used to drive and manipulate qubits.

    A pulse object contains information about the shape of the pulse. Other properties
    such as the phase and frequency come from the PulseChannel.
=#

abstract type Pulse end
export Pulse

### Signature properties
export width 
"""
    width(pulse::Pulse)

Returns the duration of a pulse.
"""
function width(pulse::Pulse)
    if !hasproperty(pulse, :width)
        throw(ArgumentError("Pulse does not have a defined width."))
    end
    return pulse.width
end

export midpointtimes
"""
    midpointtimes(pulse::Pulse; steps::Int=100)

For a discretized pulse with `steps+1` points, find the times at the midpoints between points.
"""
function midpointtimes(pulse::Pulse; steps::Int=100)
    w = width(pulse)
    δt = w/steps
    return LinRange(-(w-δt)/2, (w-δt)/2, steps)
end

export shape 
"""
    shape(pulse::Pulse; kwargs...)

Returns the  pulse shape of pulses as discretized arrays, at midpoint times.

# Optionial Keywork Arguments

    - `steps::Int=100`: The shape is returns as a `steps`-array.
"""
function shape(::Pulse; steps::Int=100)
    return zeros(ComplexF64, steps)
end

export defaultparameterrange
function defaultparameterrange(pulse::Pulse, parameter::Symbol, steps::Int)
    return nothing
end

### Determining the actions of pulses
export createH0unitary, createHeffunitary, createL0superop, createLsuperop

"""
    createH0unitary(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)

Creates the matrix for the approximate unitary operator for a pulse acting on a qubit.
Provide `phase` and `steps` as optional keyword arguments.
"""
function createH0unitary(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)
    return calculate_discrete_product(-1im*qubit.H0, -1im*interactionH(qubit, phase), pulse, steps)
end


"""
    createHeffunitary(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)

Creates the matrix for the approximate non-unitary operator for a pulse acting on a qubit.
Provide `phase` and `steps` as optional keyword arguments.
"""
function createHeffunitary(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)
    return calculate_discrete_product(-1im*qubit.Heff, -1im*interactionH(qubit, phase), pulse, steps)
end

"""
    createL0superop(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)

Creates the matrix for the approximate super operator without dissipation, for a pulse acting
on a qubit. Provide `phase` and `steps` as optional keyword arguments.
"""
function createL0superop(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)
    return calculate_discrete_product(qubit.L0, interactionL(qubit, phase), pulse, steps)
end

"""
    createLsuperop(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)

Creates the matrix for the approximate super operator with dissipation, for a pulse acting
on a qubit. Provide `phase` and `steps` as optional keyword arguments.
"""
function createLsuperop(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)
    return calculate_discrete_product(qubit.L, interactionL(qubit, phase), pulse, steps)
end

function calculate_discrete_product(H0::Array, V::Array, pulse::Pulse, steps::Int)
    cache = _discrete_product_cache(H0, V)
    return _calculate_discrete_product(cache, pulse, steps)
end

# a cache to work with calculating discrete products which will be used generally for time
# evolution operators
mutable struct _discrete_product_cache
    H0::Array
    V::Array
    H::Array

    function _discrete_product_cache(H0, V)
        if size(H0) != size(V)
            throw(ArgumentError("Sizes of H0 and V do not match."))
        end
        return new(H0, V, zeros(promote_type(eltype(H0), eltype(V)), size(H0)...))
    end
end

function _calculate_discrete_product(
    cache::_discrete_product_cache,
    pulse::Pulse,
    steps::Int
)
    U = diagm(ones(eltype(cache.H), size(cache.H, 1)))
    Ωs = shape(pulse; steps=steps)
    Δt = width(pulse) / steps
    for step in Base.OneTo(steps)
        cache.H .= cache.H0
        cache.H .+= Ωs[step] .* cache.V # does this create extra allocations to store mult result?
        U = exp(Δt*cache.H) * U
    end
    return U
end
#=
    Pulses are used to drive and manipulate qubits.

    A pulse object contains information about the shape of the pulse. Other properties
    such as the phase and frequency come from the PulseChannel.
=#

### Abstract typing for pulses: defines signature behaviour
abstract type Pulse end
export Pulse

export shape 
"""
    shape(pulse::Pulse; kwargs...)

Returns the times and pulse shape as discretized arrays.

# Optionial Keywork Arguments

    - `steps::Int=100`: The shape is returns as a `steps`-array.
"""
function shape(::Pulse; steps::Int=100)
    return zeros(Float64, steps+1), zeros(Float64, steps+1)
end

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

"""
    creatematrix(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)

Creates the matrix for the approximate unitary operator for a pulse acting on a qubit.
Provide `phase` and `steps` as optional keyword arguments.
"""
function creatematrix(qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)
    Ωs = shape(pulse; steps=steps)
    Δt = width(pulse) / steps

     # we need to average the pulse over intervals 
     Ωs = 0.5 * (Ωs[firstindex(Ωs):lastindex(Ωs)-1] + Ωs[firstindex(Ωs)+1:lastindex(Ωs)])

     U = diagm(ones(ComplexF64, levels(qubit)))
     ΔH = zeros(ComplexF64, levels(qubit), levels(qubit))
     V = exp(1im*phase)*qubit.a + exp(-1im*phase)*qubit.adag
     for step in Base.OneTo(steps)
        ΔH .= qubit.H0
        ΔH .+= Ωs[step] .* V # does this create extra allocations to store mult result?
        U = exp(-1im*Δt*ΔH) * U
     end
     return U
end
export creatematrix


### Square pulses 
"""
    SquarePulse(width::Float64=8e-8, amplitude::Float64=1.3e7)

A square pulse is a time-constant pulse. The `width` of the pulse determines how long it is
active. The `amplitude` determines the strength of the pulse..
"""
struct SquarePulse <: Pulse
    width::Float64
    amplitude::Float64

    function SquarePulse(width::Float64=8e-8, amplitude::Float64=1.3e7)
        return new(width, amplitude)
    end
    function SquarePulse(;width::Float64=8e-8, amplitude::Float64=1.3e7)
        return new(width, amplitude)
    end
end
export SquarePulse

function shape(pulse::SquarePulse; steps::Int=100)
    return pulse.amplitude*ones(Float64, steps+1)
end 


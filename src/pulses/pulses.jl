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
    if !hasproperty(pulse, "width")
        throw(ArgumentError("Pulse does not have a defined width."))
    end
    return pulse.width
end

function creategate(lt::LatticeTypes, qubit::Qubit, pulse::Pulse; phase::Float64=0.0, steps::Int=100)
    Ωs = shape(pulse; steps=steps)
    Δt = width(pulse) / steps 
    
    # we need to average the pulse over intervals 
    Ωs = 0.5 * (Ωs[firstindex(Ωs):lastindex(Ωs)-1] + Ωs[firstindex(Ωs)+1:lastindex(Ωs)])

    H0 = hamiltonian()
    ΔH = zeros(ComplexF64, levels(qubit), levels(qubit))
    U = diag(ones(ComplexF64, level(qubit)))
    for step in Base.range(steps)
        ΔH
    end
end

### Square pulses 
"""
    SquarePulse(width::Float64=8e-8, amplitude::Float64=1.3e7)

A square pulse is a time-constant pulse. The `width` of the pulse determines how long it is
active. The `amplitude` determines the strength of the pulse..
"""
struct SquarePulse <: Pulse
    width::Float64
    amplitude::Float64

    function SquarePulse(width::Float64=8e-8; amplitude::Float64=1.3e7)
        return new(width, amplitude, phase)
    end
    function SquarePulse(; width::Float64=8e-8, amplitude::Float64=1.3e7)
        return new(width, amplitude)
    end
end
export SquarePulse

function shape(pulse::SquarePulse; steps::Int=100)
    ts = Base.range(0, pulse.width, step=pulse.width/steps)
    amps = pulse.amplitude*ones(Float64, steps+1)
    return amps
end 


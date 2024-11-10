#=
    Pulses are used to drive and manipulate qubits.

    A pulse object contains information about the shape of the pulse. Other properties
    such as the phase and frequency come from the PulseChannel.
=#

abstract type Pulse end

### Square pulses 
mutable struct SquarePulse <: Pulse
    amplitude::Float64
    width::Float64
end
export SquarePulse

function SquarePulse(width::Float64=8e-8; amp::Float64=1.3e7)
    return SquarePulse(amp, width)
end

export shape
function shape(pulse::SquarePulse; steps::Int=100)
    ts = Base.range(0, pulse.width, step=pulse.width/steps)
    amps = pulse.amplitude*ones(Float64, steps+1)
    return ts, amps
end 


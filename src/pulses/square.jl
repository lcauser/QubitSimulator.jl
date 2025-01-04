#=
    Time-constant pulses
=#


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
    return pulse.amplitude*ones(Float64, steps)
end 


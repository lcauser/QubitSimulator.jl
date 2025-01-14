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

# Default parameters for grid searching square pulses
_square_width_min_exponent = -8.0
_square_width_max_exponent = -6.0
_square_amp_min_exponent = 5.0
_square_amp_max_exponent = 8.0

function defaultparameterrange(::SquarePulse, parameter::Symbol, steps::Int=100)
    if parameter == :width
        return 10.0 .^ Base.range(
            start=_square_width_min_exponent,
            stop=_square_width_max_exponent,
            length=steps
        )
        return _square_width_cycle_time:_square_width_cycle_time
    elseif parameter == :amplitude 
        return 10.0 .^ Base.range(
            start=_square_amp_min_exponent,
            stop=_square_amp_max_exponent,
            length=steps
        )
    else
        throw(ArgumentError("Parameter $(parameter) not known for SquarePulse."))
    end
end


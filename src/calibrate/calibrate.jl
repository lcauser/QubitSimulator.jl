#=
    Calibrate is used for tuning the parameters of a pulse to best match some objective.
=#

abstract type Calibrate end
export Calibrate, getparameters, getpulse, createpulse

getparameters(::Calibrate) = Dict()
getpulse(::Calibrate) = nothing

"""
    createpulse(calibrate::Calibrate)

Creates a copy of the original pulse with calibrated parameters substituted in.
"""
function createpulse(cal::Calibrate)
    pulse = getpulse(cal)
    pulse_dict = Dict(
        key=>getfield(pulse, key) for key in fieldnames(typeof(pulse))
    )
    for (key, val) in getparameters(cal)
        pulse_dict[key] = val
    end
    return typeof(pulse)(; pulse_dict...)
end
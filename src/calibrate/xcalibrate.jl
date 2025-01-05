#=
    Used to calibrate single qubit X gates.
=#

"""
    XCalibrate(qubit::Qubit, pulse::Pulse, parameters::Union{Symbol, AbstractArray{Symbol}})

An X calibration for a pulse, where the parameters to be calibrated are given by
`parameters`.
"""
mutable struct XCalibrate <: Calibrate
    qubit::Qubit 
    pulse::Pulse 
    parameters::Dict{Symbol, Number}

    function XCalibrate(
        qubit::Qubit,
        pulse::Pulse,
        parameters::Union{Symbol, AbstractArray{Symbol}}
    )
        parameters = typeof(parameters) <: AbstractArray ? parameters : [parameters]
        return new(
            qubit,
            pulse,
            Dict(key=>getfield(pulse, key) for key in parameters)
        )
    end
end
export XCalibrate

getparameters(cal::XCalibrate) = cal.parameters
getpulse(cal::XCalibrate) = cal.pulse
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
    target::AbstractArray

    function XCalibrate(
        qubit::Qubit,
        pulse::Pulse,
        parameters::Union{Symbol, AbstractArray{Symbol}}
    )
        parameters = typeof(parameters) <: AbstractArray ? parameters : [parameters]
        return new(
            qubit,
            pulse,
            Dict(key=>getfield(pulse, key) for key in parameters),
            _calculate_target_gate(qubit)
        )
    end
end
export XCalibrate

function _calculate_target_gate(qubit::Qubit)
    U = zeros(ComplexF64, levels(qubit), levels(qubit))
    # set the X gate 
    U[1, 1] = U[2, 2] = 1/sqrt(2)
    U[1, 2] = U[2, 1] = -1im/sqrt(2)
    # other levels should be unchanged and have 1 entries, but we're gonna ignore that
    # for pratical reasons. will probably need to be done more formally
    return kron(U, conj(U))
end

getparameters(cal::XCalibrate) = cal.parameters
getpulse(cal::XCalibrate) = cal.pulse

function objective(cal::XCalibrate)
    
end
#=
    A grid search calibration algorithm to determien the optimal parameters for a pulse.
=#

export gridsearch
function gridsearch(
    cal::Calibrate,
    parameters::Dict = Dict();
    parameter_range::Int = 10001
)
    _gridsearch_validate_keys(cal, parameters)
    _gridsearch_sanitise_keys!(cal, parameters, parameter_range)
    min_obj = -1.0
    params = [keys(parameters)...]
    vals = nothing 
    for param_values in Iterators.product(values(parameters)...)
        for j in Base.OneTo(length(params))
            cal.parameters[params[j]] = param_values[j]
        end
        
        obj = objective(cal)
        if min_obj == -1.0 || obj < min_obj
            min_obj = obj 
            vals = param_values
        end
    end
    println(min_obj)
    println(vals)    
end

function _gridsearch_validate_keys(cal, parameters)
    for key in keys(parameters)
        if !(key in keys(cal.parameters))
            throw(ArgumentError("$(key) is not a calibratable parameter."))
        end
    end
    return true
end

function _gridsearch_sanitise_keys!(cal, parameters, parameter_range)
    for key in keys(cal.parameters)
        if !(key in keys(parameters))
            parameters[key] = defaultparameterrange(cal.pulse, key, parameter_range)
        end
    end
end
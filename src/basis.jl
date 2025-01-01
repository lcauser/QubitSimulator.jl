#=
    The basis is used to construct operators for the simulations.
=#

"""
    Basis(n::Int)

Contains the Hilbert space and Liouville space information for qubits with `n` levels.
"""
struct Basis
    hilbert::LatticeTypes 
    liouville::LatticeTypes

    function Basis(n::Int)
        lt = Bosons(n)
        add!(lt, "z", op(lt, "id")-2*op(lt, "n"))
        add!(lt, "zdagz", adjoint(op(lt, "z"))*op(lt, "z"))
        return new(lt, LiouvilleWrapper(lt))
    end
end
export Basis

levels(basis::Basis) = dim(basis.hilbert)
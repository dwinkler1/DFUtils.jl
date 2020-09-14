module DFUtils
using DataFrames, Parsers

export complete, 
    mintype,
    tonumeric!

function complete(df, cols...; replace_missing = missing)
    T = eltype(cols)
    dfo = Iterators.product([unique(df[:, col]) for col in cols]...) |> DataFrame
    rename!(dfo, Symbol.(1:length(cols)) .=> cols)
    dfo = rightjoin(df, dfo, on = [cols...])
    if !ismissing(replace_missing)
        for col in filter(n->T(n) ∉ cols, names(df))
            dfo[!, col] = coalesce.(dfo[!, col], replace_missing) 
        end
    end
    return dfo
end

function mintype(s::String)
    s = strip(s)
    p = Parsers.tryparse(Float64, s) 
    if isnothing(p)
        return String
    else
        return mintype(p)
    end
end


function mintype(n::T) where T <: AbstractFloat
    if round(n) == n
        return Int
    else
        return T
    end
end

mintype(i::T) where T <: Signed = i > typemax(Int) ? BigInt : T

mintype(t::T) where T = T

function mintype(v::Vector) 
    T = Int
    for e in v
        T = promote_type(T, mintype(e))
    end
    return T
end

tonumeric(::Type{T}, v::V) where {T<:Number, V<:Number} = convert(T,v)
tonumeric(::Type{T}, v::String) where T<:Number = parse(T, v)
tonumeric(::Type{T}, v::Missing) where T = missing
function tonumeric(::Type{T}, v::String) where T<:Integer
    o = Parsers.tryparse(T, v)
    if !isnothing(o)
        return o
    else
        f = parse(Float64, v)
        i = tonumeric(T, f)
        return i
    end
end
function tonumeric!(::Type{T}, v::Vector) where T
    for (i,e) in enumerate(v)
       @inbounds v[i] = tonumeric(T, e)
    end
    v[:] = convert(Vector{T}, v)
end

end
module DFUtils
using DataFrames,
Parsers,
Missings,
Transducers

export complete, 
    realtype,
    toReal,
    fixnothing!,
    readtypes,
    dictstodf

"""
    complete(df, cols...; replace_missing = missing)

Creates a `DataFrame` that has rows all combinations of `cols...`. Optionally fill missing values in other columns with `replace_missing`.
"""
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

function realtype(s::S, r) where S <: AbstractString
    s = strip(s)
    o = Parsers.tryparse(Int, s)
    !isnothing(o) && return Int
    o = Parsers.tryparse(BigInt, s)
    !isnothing(o) && return BigInt
    p = Parsers.tryparse(Float64, s) 
    if isnothing(p)
        return r ? Missing : S
    else
        return realtype(p)
    end
end


function realtype(n::T, r = true) where T <: Union{Integer, AbstractFloat} 
    if round(n) == n
        return T <: Union{BigFloat, BigInt} ? BigInt : Int
    else
        return T
    end
end

realtype(m::Missing, r = true) = Missing

realtype(t::T, r = true) where T = T

"""
    realtype(v; replace_string = true)

Finds a subtype of `Real` that `v` can be converted to. Automatically handles `missing`s in vectors and optionally treats `String`s that cannot be parsed to any `Real` with `missing`
"""
function realtype(v::Vector; replace_string = true) 
    T = Int
    for e in v
        T = promote_type(T, realtype(e, replace_string))
    end
    return T
end

toReal(::Type{T}, v::V, r=true) where {T<:Union{Integer, AbstractFloat}, V<:Union{Integer, AbstractFloat}} = convert(T,v)

toReal(::Type{T}, v::S, r) where {T<: AbstractString, S<: AbstractString} = r ? missing : v

function toReal(::Type{T}, v::S, r) where T<: Union{Integer, AbstractFloat} where S<:AbstractString
    if r
        o = Parsers.tryparse(T, v)
        isnothing(o) ? missing : o
    else
        return parse(T, v)
    end
end

toReal(::Type{Real}, v, r) = toReal(realtype(v), v, r)

function toReal(::Type{T}, v::S, r) where T<: BigFloat where S<:AbstractString
    if r
        try
            o = parse(T, v)
            return o
        catch e 
            return missing
        end
    else
        return parse(T, v)
    end
end

toReal(::Type{T}, v::Missing, r = true) where T = missing
toReal(::Type{Missing}, v, r = true) = missing
toReal(::Type{Missing}, v::Missing, r = true) = missing

function toReal(::Type{T}, s::S, r) where T<:Integer where S<:AbstractString
    o = Parsers.tryparse(T, s)
    if !isnothing(o)
        return o
    else
        f = T <: BigInt ? toReal(BigFloat, s, r) : toReal(Float64, s, r)
        i = toReal(T, f)
        return i
    end
end

"""
    toReal(v; replace_string = true, threads = length(v) > 500)

Converts `v` to a `Vector{T}` where `T <: Real`. Automatically adds `Union{T, Missing}` if necessary and optionally replaces `Strings`s that cannot be parsed with `missing`.
"""
function toReal(v::Vector; replace_string = true, threads = length(v)>500)
    op = v |> Map(x -> toReal(realtype(x, replace_string), x, replace_string))
    if threads
        return tcollect(op)
    else
        return collect(op)
    end
end

toReal(x::Union{S, T, Missing}; replace_string = true) where S <: AbstractString where T <: Real = toReal(realtype(x), x, replace_string)

"""
    readtypes(U::Union, types = DataType[])

Get a vector of the types of a `Union` type
"""
function readtypes(U::Union, types = DataType[])
    push!(types, getfield(U, :a))
    if isa(getfield(U, :b), DataType)
        push!(types, getfield(U, :b))
        return types
    else
        readtypes(U.b, types)
    end
end

readtypes(T::DataType) = [T]

"""
    fixnothing!(df::DataFrame, col::Symbol)

Replace all `nothing` with `missing` in column and remove `Nothing` type.
"""
function fixnothing!(df::DataFrame, col::Symbol)
    if Nothing ∈ readtypes(eltype(df[!, col]))
        allowmissing!(df, col)
        replace!(df[!, col], nothing => missing)
        df[!, col] = convert(Vector{Core.Compiler.typesubtract(eltype(df[!, col]), Nothing)}, df[!, col])
    else
        return nothing
    end
end

"""
    dictstodf(dicts::Vector{Dict})

Create a DataFrame from a list of `Dict`s.
"""
function dictstodf(dicts)
    out = DataFrame()
    for l in dicts
        push!(out, l, cols = :union)
    end
    return out
end
    

end
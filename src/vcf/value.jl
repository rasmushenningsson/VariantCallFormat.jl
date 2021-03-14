struct VCFValue
    data::Vector{UInt8}
    val::UnitRange{Int} # empty for flags (info keys without value)
end

Base.isempty(v::VCFValue) = isempty(v.val)
isvector(v::VCFValue) = findfirst(==(','), view(v.data,v.val)) === nothing
checkscalar(v::VCFValue) = isvector(v) || error("getvalue() expected a single value, but found a vector. Did you want getvector()?")

Base.string(v::VCFValue) = String(v.data[v.val])


# TODO: handle missing values
function getvalue(::Type{T}, v::VCFValue) where T<:Real
    checkscalar(v)
    parse(T, string(v)) # TODO: avoid creating String as intermediate
end
getvalue(::Type{String}, v::VCFValue) = (checkscalar(v); string(v))



# TODO: return VCFVector
# TODO: handle missing values
getvector(::Type{T}, v::VCFValue) where T<:Real =
    parse.(T, split(string(v),',')) # TODO: avoid temp storage
getvector(::Type{String}, v::VCFValue) =
    String.(split(string(v),',')) # TODO: avoid temp storage

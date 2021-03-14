# TODO: handle missing values
function parse_vcf_value(::Type{T}, data::Vector{UInt8}, val::UnitRange{Int})::Union{T,Missing} where T<:Real
    length(val)==1 && data[first(val)]==UInt8('.') && return missing
    parse(T, String(data[val])) # TODO: avoid creating String as intermediate
end
function parse_vcf_value(::Type{String}, data::Vector{UInt8}, val::UnitRange{Int})::Union{String,Missing}
    length(val)==1 && data[first(val)]==UInt8('.') && return missing
    String(data[val])
end



struct VCFValue
    data::Vector{UInt8}
    val::UnitRange{Int} # empty for flags (info keys without value)
end

Base.isempty(v::VCFValue) = isempty(v.val)
isvector(v::VCFValue) = findfirst(==(UInt8(',')), view(v.data,v.val)) !== nothing
checkscalar(v::VCFValue) = isvector(v) && error("getvalue() expected a single value, but found a vector. Did you want getvector()?")

Base.string(v::VCFValue) = String(v.data[v.val])
Base.show(io::IO, v::VCFValue) = print(io,string(v))



function getvalue(v::VCFValue)
    # TODO: Should convert to type specified in VCF header (default to String if not specified in header)
    isvector(v) && return getvector(String,v)
    string(v)
end
getvalue(::Type{T}, v::VCFValue) where T = (checkscalar(v); parse_vcf_value(T, v.data, v.val))

getvector(::Type{T}, v::VCFValue) where T = VCFVector(T, v.data, v.val)
getvector(v::VCFValue) = getvector(String,v) # TODO: should use type specified in VCF header (default to String if not specified in header)



# A typed vector that is stored in memory as a comma-separated String
# Semi-lazy parsing. At creation, we determine the location of the commas to know vector length etc.
# But parsing of values is done when accessed.
struct VCFVector{T} <: AbstractVector{Union{T,Missing}}
    data::Vector{UInt8}
    vals::Vector{UnitRange{Int}}
end
function VCFVector(::Type{T}, data::Vector{UInt8}, val::UnitRange{Int}) where T
    vals = UnitRange{Int}[]
    i = 1
    while true
        i2 = findnext(==(UInt8(',')), view(data,val), i)
        i2 === nothing && break
        push!(vals, (i:i2-1) .+ (first(val)-1))
        i = i2+1
    end
    push!(vals,first(val)-1+i:last(val))
    VCFVector{T}(data, vals)
end

# AbstractVector interface
Base.IndexStyle(::Type{<:VCFVector}) = IndexLinear()
Base.size(v::VCFVector) = size(v.vals)

Base.getindex(v::VCFVector{T}, i) where T = parse_vcf_value(T, v.data, v.vals[i])
# End AbstractVector interface

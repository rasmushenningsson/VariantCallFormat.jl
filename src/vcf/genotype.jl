struct VCFGenotypeWrapper
    data::Vector{UInt8}
    format::Vector{UnitRange{Int}}
    genotype::Vector{Vector{UnitRange{Int}}}
end

function VCFGenotypeWrapper(record::VCFRecord)
	checkfilled(record)
	VCFGenotypeWrapper(record.data, record.format_, record.genotype_)
end

genotypewrapper(record::VCFRecord) = VCFGenotypeWrapper(record)


# Array-like interface
function Base.getindex(g::VCFGenotypeWrapper, index::Integer, ::Colon)
    return genotype_impl(g, index, 1:lastindex(g.format))
end

function Base.getindex(g::VCFGenotypeWrapper, index::Integer, key::String)::String
    k = findgenokey(g, key)
    if k == nothing
        throw(KeyError(key))
    end
    return genotype_impl(g, index, k)
end

function Base.getindex(g::VCFGenotypeWrapper, index::Integer, keys::AbstractVector{String})::Vector{String}
    return [g[index, key] for key in keys]
end

function Base.getindex(g::VCFGenotypeWrapper, indexes::AbstractVector{T}, key::String)::Vector{String} where T<:Integer
    k = findgenokey(g, key)
    if k == nothing
        throw(KeyError(key))
    end
    return [genotype_impl(g, i, k) for i in indexes]
end

function Base.getindex(g::VCFGenotypeWrapper, indexes::AbstractVector{T}, keys::AbstractVector{String})::Vector{Vector{String}} where T<:Integer
    ks = Vector{Int}(length(keys))
    for i in 1:lastindex(keys)
        key = keys[i]
        k = findgenokey(g, key)
        if k == nothing
            throw(KeyError(key))
        end
        ks[i] = k
    end
    return [genotype_impl(g, i, ks) for i in indexes]
end

function Base.getindex(g::VCFGenotypeWrapper, ::Colon, key::String)::Vector{String}
    return g[1:lastindex(g.genotype), key]
end





function findgenokey(g::VCFGenotypeWrapper, key::String)
    return findfirst(r -> isequaldata(key, g.data, r), g.format)
end

function genotype_impl(g::VCFGenotypeWrapper, index::Int, keys::AbstractVector{Int})
    return [genotype_impl(g, index, k) for k in keys]
end

function genotype_impl(g::VCFGenotypeWrapper, index::Int, key::Int)
    geno = g.genotype[index]
    if key > lastindex(geno)  # dropped field
        return "."
    else
        return String(g.data[geno[key]])
    end
end


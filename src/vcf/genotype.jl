struct VCFGenotypeWrapper <: AbstractMatrix{String}
    data::Vector{UInt8}
    format::Vector{UnitRange{Int}}
    genotype::Vector{Vector{UnitRange{Int}}}
end

function VCFGenotypeWrapper(record::VCFRecord)
	checkfilled(record)
	VCFGenotypeWrapper(record.data, record.format_, record.genotype_)
end

genotypewrapper(record::VCFRecord) = VCFGenotypeWrapper(record)


# AbstractMatrix interface (IndexStyle is IndexCartesian)
Base.size(g::VCFGenotypeWrapper) = (length(g.genotype),length(g.format))
Base.getindex(g::VCFGenotypeWrapper, i::Int, key::Int) = genotype_impl(g, i, key)

# Handling of String keys
# Base.getindex(g::VCFGenotypeWrapper, i::Int, key::String) = genotype_impl(g, i, findgenokey(g,key))
Base.getindex(g::VCFGenotypeWrapper, I, key::String) = g[I,findgenokey(g,key)]
Base.getindex(g::VCFGenotypeWrapper, I, key::AbstractVector{String}) = g[I,findgenokey.(Ref(g),key)]

# End AbstractMatrix interface


function findgenokey(g::VCFGenotypeWrapper, key::String)
    j = findfirst(r -> isequaldata(key, g.data, r), g.format)
    j === nothing && throw(KeyError(key))
    j
end

function genotype_impl(g::VCFGenotypeWrapper, index::Int, key::Int)
    geno = g.genotype[index]
    if key > lastindex(geno) # dropped field
        return "."
    else
        return String(g.data[geno[key]])
    end
end


struct VCFGenotypeMatrix <: AbstractMatrix{VCFValue}
    data::Vector{UInt8}
    format::Vector{UnitRange{Int}}
    genotype::Vector{Vector{UnitRange{Int}}}
end

function VCFGenotypeMatrix(record::VCFRecord)
    checkfilled(record)
    VCFGenotypeMatrix(record.data, record.format_, record.genotype_)
end

genotypematrix(record::VCFRecord) = VCFGenotypeMatrix(record)


# AbstractMatrix interface (IndexStyle is IndexCartesian)
Base.size(g::VCFGenotypeMatrix) = (length(g.genotype),length(g.format))
Base.getindex(g::VCFGenotypeMatrix, i::Integer, key::Int) = genotype_impl(g, i, key)

# Handling of String keys
# Base.getindex(g::VCFGenotypeMatrix, i::Int, key::String) = genotype_impl(g, i, findgenokey(g,key))
Base.getindex(g::VCFGenotypeMatrix, I, key::String) = g[I,findgenokey(g,key)]
Base.getindex(g::VCFGenotypeMatrix, I, key::AbstractVector{String}) = g[I,findgenokey.(Ref(g),key)]

# End AbstractMatrix interface



getvalue(::Type{T}, g::VCFGenotypeMatrix, i::Integer, key::String) where T = getvalue(T, g[i,key])
getvalue(g::VCFGenotypeMatrix, i::Integer, key::String) = getvalue(g[i,key])
getvector(::Type{T}, g::VCFGenotypeMatrix, i::Integer, key::String) where T = getvector(T, g[i,key])
getvector(g::VCFGenotypeMatrix, i::Integer, key::String) = getvector(g[i,key])




function findgenokey(g::VCFGenotypeMatrix, key::String)
    j = findfirst(x -> isequaldata(key, g.data, x), g.format)
    j === nothing && throw(KeyError(key))
    j
end

function genotype_impl(g::VCFGenotypeMatrix, index::Int, key::Int)
    geno = g.genotype[index]
    if key > lastindex(geno) # dropped field
        return VCFValue(UInt8['.'],1:1) # TODO: avoid allocating for dropped missing values
    else
        return VCFValue(g.data,geno[key])
    end
end

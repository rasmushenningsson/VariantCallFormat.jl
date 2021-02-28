struct BCFGenotypeMatrix <: AbstractMatrix{String}
    data::Vector{UInt8}
    sharedlen::UInt32
    strings::Vector{String}
    string2index::Dict{String,Int}
end

function BCFGenotypeMatrix(record::BCFRecord)
	checkfilled(record)
	BCFGenotypeMatrix(record.data, record.sharedlen, record.strings, record.string2index)
end

genotypematrix(record::BCFRecord) = BCFGenotypeMatrix(record)


# AbstractMatrix interface (IndexStyle is IndexCartesian)
Base.size(g::BCFGenotypeMatrix) = (n_sample(g),n_format(g))
Base.getindex(g::BCFGenotypeMatrix, i::Int, formatind::Int) = genotype_impl(g, i, formatind)

# Handling of String keys
# Base.getindex(g::BCFGenotypeMatrix, I, key::String) = g[I,findgenokey(g,key)]
# Base.getindex(g::BCFGenotypeMatrix, I, key::AbstractVector{String}) = g[I,findgenokey.(Ref(g),key)]

# TODO: implement more efficient iteration to avoid searching for every element

# End AbstractMatrix interface


# TODO: get rid of duplicate implementations
n_sample(g::BCFGenotypeMatrix) = (load(UInt32, g.data, 20)[1] & 0x00FFFFFF) % Int
n_format(g::BCFGenotypeMatrix) = (load(UInt32, g.data, 20)[1] >> 24) % Int



function genotype_impl(g::BCFGenotypeMatrix, sample::Int, formatind::Int)
    offset, k = find_genotype_offset(g, formatind)
    head, offset = loadvechead(g.data, offset)
    offset += bcftypesize(head[1]) * head[2] * (sample-1)
    val, offset = loadvecbody(g.data, offset, head)

    # Hack to handle GT. TODO: find a better implementation
    if g.strings[k+1]=="GT"
        io = IOBuffer()
        for (i,v) in enumerate(val)
            allele, phased = gt(v)
            i>1 && print(io, phased ? '|' : '/')
            if allele==-1
                print(io, '.')
            else
                print(io, allele)
            end
        end
        return String(take!(io))
    else
        # TODO: handle missing values properly
        join(val, ',') # String for compat with VCF - for now - both will change
    end
end

function find_genotype_offset(g::BCFGenotypeMatrix, formatind::Int)
    N = n_sample(g)
    offset::Int = g.sharedlen
    for j in 1:formatind-1
        # k, offset = loadvec(g.data, offset)
        # @assert length(k) == 1
        offset = skipvec(g.data, offset) # fmt_key
        head, offset = loadvechead(g.data, offset)
        offset += bcftypesize(head[1]) * head[2] * N
    end
    k, offset = loadvec(g.data, offset) # fmt_key
    @assert length(k) == 1
    # offset = skipvec(g.data, offset) # fmt_key
    offset, k[1]
end

struct BCFInfoDict <: AbstractDict{String,String}
    data::Vector{UInt8}
    strings::Vector{String} # BCF "Dictionary of Strings"
    string2index::Dict{String,Int} # reverse direction
end

function BCFInfoDict(record::BCFRecord)
	checkfilled(record)
	BCFInfoDict(record.data, record.strings, record.string2index)
end

infodict(record::BCFRecord) = BCFInfoDict(record)


# AbstractDict interface
Base.haskey(vinfo::BCFInfoDict, key::String) = find_info_offset(vinfo,key) !== nothing

function Base.get(f, vinfo::BCFInfoDict, key::String)
    offset = find_info_offset(vinfo, key)
    offset === nothing && return f()
    val, offset = loadvec(vinfo.data, offset) # TODO: retrieve with the desired type directly
    return join(val,',') # String for compat with VCF - for now - both will change
end
Base.get(vinfo::BCFInfoDict, key::String, default) = get(()->default, vinfo, key)
Base.getindex(vinfo::BCFInfoDict, key::String) = get(()->throw(KeyError(key)), vinfo, key)

Base.length(vinfo::BCFInfoDict) = n_info(vinfo)

function Base.iterate(vinfo::BCFInfoDict, state=(length(vinfo),first_info_offset(vinfo)))
    state[1]<=0 && return nothing
    offset = state[2]

    k, offset = loadvec(vinfo.data, offset)
    val, offset = loadvec(vinfo.data, offset) # TODO: How to handle types?
    key = vinfo.strings[k[1]+1]
    val = join(val,',') # String for compat with VCF - for now - both will change
    key=>val, (state[1]-1,offset)
end
# End AbstractDict interface


# TODO: get rid of duplicate implementations
n_allele(vinfo::BCFInfoDict) = (load(Int32, vinfo.data, 16)[1] >> 16) % Int
n_info(vinfo::BCFInfoDict) = (load(Int32, vinfo.data, 16)[1] & 0x0000FFFF) % Int


function find_info_offset(vinfo::BCFInfoDict, key::String)::Union{Int,Nothing}
    k = get(vinfo.string2index, key, nothing)
    return k === nothing ? nothing : find_info_offset(vinfo, k)
end
function find_info_offset(vinfo::BCFInfoDict, key::Integer)::Union{Int,Nothing}
    offset = first_info_offset(vinfo)
    # load INFO
    for _ in 1:n_info(vinfo)
        k, offset = loadvec(vinfo.data, offset)
        @assert length(k) == 1
        if k[1] == key
            return offset
        else
            offset = skipvec(vinfo.data, offset)
        end
    end
    return nothing
end

function first_info_offset(vinfo::BCFInfoDict)
    # skip ID, REF, ALTs and FILTER
    offset::Int = 24
    len = 0
    for _ in 1:n_allele(vinfo) + 2
        len, offset = loadveclen(vinfo.data, offset)
        offset += len
    end
    offset
end

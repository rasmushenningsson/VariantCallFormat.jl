struct VCFInfoDict <: AbstractDict{String,VCFValue}
    data::Vector{UInt8}
    infokey::Vector{UnitRange{Int}}
end

function VCFInfoDict(record::VCFRecord)
	checkfilled(record)
	VCFInfoDict(record.data, record.infokey_)
end

infodict(record::VCFRecord) = VCFInfoDict(record)



# AbstractDict interface
Base.haskey(vinfo::VCFInfoDict, key::String) = findinfokey(vinfo, key) !== nothing

function Base.get(f, vinfo::VCFInfoDict, key::String)
    i = findinfokey(vinfo, key)
    i === nothing && return f()
    VCFValue(vinfo.data, infovalrange(vinfo, i))
end
Base.get(vinfo::VCFInfoDict, key::String, default) = get(()->default, vinfo, key)
Base.getindex(vinfo::VCFInfoDict, key::String) = get(()->throw(KeyError(key)), vinfo, key)

Base.length(vinfo::VCFInfoDict) = length(vinfo.infokey)

function Base.iterate(vinfo::VCFInfoDict, i=1)
    i>length(vinfo) && return nothing
    key = String(vinfo.data[vinfo.infokey[i]])
    val = VCFValue(vinfo.data, infovalrange(vinfo, i))
    return key=>val, i+1
end
# End AbstractDict interface



getvalue(vinfo::VCFInfoDict, key::String) = getvalue(vinfo[key])
getvalue(::Type{T}, vinfo::VCFInfoDict, key::String) where T = getvalue(T, vinfo[key])
getvector(::Type{T}, vinfo::VCFInfoDict, key::String) where T = getvector(T, vinfo[key])





function findinfokey(vinfo::VCFInfoDict, key::String)
	findfirst(x->isequaldata(key,vinfo.data,x), vinfo.infokey)
end


# Returns the data range of the `i`-th value.
function infovalrange(vinfo::VCFInfoDict, i::Int)
    data = vinfo.data
    key = vinfo.infokey[i]
    if last(key) + 1 ≤ lastindex(data) && data[last(key)+1] == UInt8('=')
        endpos = something(findnext(isequal(0x3B), data, last(key)+1), 0) # 0x3B is byte equivalent of char ';'.
        if endpos == 0
            endpos = something(findnext(isequal(0x09), data, last(key)+1), 0) # 0x09 is byte equivalent of char '\t'
            @assert endpos != 0
        end
        return last(key)+2:endpos-1
    else
        return last(key)+1:last(key)
    end
end

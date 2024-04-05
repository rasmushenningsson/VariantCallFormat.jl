struct Header
    metainfo::Vector{MetaInfo}
    sampleID::Vector{String}

    function Header(metainfo::Vector{MetaInfo}, sampleID::Vector{String})
        return new(metainfo, sampleID)
    end
end

"""
    VCF.Header()
Create an empty VCF header.
"""
function Header()
    return Header(MetaInfo[], String[])
end

"""
    VCF.Header(metainfo::Vector, sampleID::Vector)
Create a VCF header with `metainfo` and `sampleID`.
"""
function Header(metainfo::Vector, sampleID::Vector)
    return Header(convert(Vector{MetaInfo}, metainfo), convert(Vector{String}, sampleID))
end

function Base.eltype(::Type{Header})
    return MetaInfo
end

function Base.length(header::Header)
    return length(header.metainfo)
end

function Base.iterate(header::Header, i = 1)
    return i > lastindex(header.metainfo) ? nothing : (header.metainfo[i], i + 1)
end

function Base.findall(header::Header, tag::AbstractString)
    return Base.filter(m -> isequaltag(m, tag), header.metainfo)
end

function Base.pushfirst!(header::Header, metainfo)
    pushfirst!(header.metainfo, convert(MetaInfo, metainfo))
    return header
end

function Base.push!(header::Header, metainfo)
    push!(header.metainfo, convert(MetaInfo, metainfo))
    return header
end

function Base.show(io::IO, header::Header)
    println(io, summary(header), ':')
    tags = metainfotag.(header.metainfo)
    println(io, "  metainfo tags: ", join(unique(tags), ' '))
      print(io, "     sample IDs: ", join(header.sampleID, ' '))
end

function Base.write(io::IO, header::Header)
    n = 0
    for metainfo in header.metainfo
        n += write(io, metainfo, '\n')
    end
    n += write(io, "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO")
    if !isempty(header.sampleID)
        n += write(io, '\t', "FORMAT")
        for id in header.sampleID
            n += write(io, '\t', id)
        end
    end
    n += write(io, '\n')
    return n
end

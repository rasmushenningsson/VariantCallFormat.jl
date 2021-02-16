struct Header
    metainfo::Vector{MetaInfo}
    sampleID::Vector{String}
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

metainfo(header::Header) = header.metainfo
metainfo(header::Header, tag::AbstractString) = Base.filter(m -> isequaltag(m, tag), header.metainfo)
sampleids(header::Header) = header.sampleID


import Base: eltype, length, iterate, pushfirst!, push!, findall # needed for deprecations to work
@deprecate eltype(::Type{Header}) MetaInfo false
@deprecate length(header::Header) length(metainfo(header)) false
@deprecate iterate(header::Header, i=1) iterate(metainfo(header),i) false
@deprecate pushfirst!(header::Header, minfo) pushfirst!(metainfo(header), minfo) false
@deprecate push!(header::Header, minfo) push!(metainfo(header), minfo) false
@deprecate findall(header::Header, tag::AbstractString) metainfo(header,tag) false


function Base.show(io::IO, header::Header)
    println(io, summary(header), ':')
    tags = BioCore.metainfotag.(header.metainfo)
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

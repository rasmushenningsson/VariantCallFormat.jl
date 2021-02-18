struct VCFHeader
    metainfo::Vector{MetaInfo}
    sampleID::Vector{String}
end

"""
    VCFHeader()
Create an empty VCF header.
"""
function VCFHeader()
    return VCFHeader(MetaInfo[], String[])
end

"""
    VCFHeader(metainfo::Vector, sampleID::Vector)
Create a VCF header with `metainfo` and `sampleID`.
"""
function VCFHeader(metainfo::Vector, sampleID::Vector)
    return VCFHeader(convert(Vector{MetaInfo}, metainfo), convert(Vector{String}, sampleID))
end

metainfo(header::VCFHeader) = header.metainfo
metainfo(header::VCFHeader, tag::AbstractString) = Base.filter(m -> isequaltag(m, tag), header.metainfo)
sampleids(header::VCFHeader) = header.sampleID


import Base: eltype, length, iterate, pushfirst!, push!, findall # needed for deprecations to work
@deprecate eltype(::Type{VCFHeader}) MetaInfo false
@deprecate length(header::VCFHeader) length(metainfo(header)) false
@deprecate iterate(header::VCFHeader, i=1) iterate(metainfo(header),i) false
@deprecate pushfirst!(header::VCFHeader, minfo) pushfirst!(metainfo(header), minfo) false
@deprecate push!(header::VCFHeader, minfo) push!(metainfo(header), minfo) false
@deprecate findall(header::VCFHeader, tag::AbstractString) metainfo(header,tag) false


function Base.show(io::IO, header::VCFHeader)
    println(io, summary(header), ':')
    tags = BioCore.metainfotag.(header.metainfo)
    println(io, "  metainfo tags: ", join(unique(tags), ' '))
      print(io, "     sample IDs: ", join(header.sampleID, ' '))
end

function Base.write(io::IO, header::VCFHeader)
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

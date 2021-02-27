struct BCFReader{T<:IO} <: BioCore.IO.AbstractReader
    version::Tuple{UInt8,UInt8}  # (major, minor)
    header::VCFHeader
    stream::BGZFStreams.BGZFStream{T}
    strings::Vector{String} # BCF "Dictionary of Strings"
    string2index::Dict{String,Int} # reverse direction
    contigs::Vector{String} # BCF "Dictionary of Contigs"
end

"""
    BCFReader(input::IO)
Create a data reader of the BCF file format.
# Arguments
* `input`: data source
"""
function BCFReader(input::IO)
    stream = BGZFStreams.BGZFStream(input)

    # magic bytes and BCF version
    B = read(stream, UInt8)
    C = read(stream, UInt8)
    F = read(stream, UInt8)
    major = read(stream, UInt8)
    minor = read(stream, UInt8)
    if (B, C, F) != map(UInt8, ('B', 'C', 'F'))
        error("not a BCF file")
    elseif (major, minor) != (0x02, 0x02)
        error("unsupported BCF version")
    end

    # NOTE: This isn't specified in the BCF specs, but seems to be a practice at least in htslib.
    # See: https://github.com/samtools/hts-specs/issues/138
    # It is mentioned in the BCF quick reference: http://samtools.github.io/hts-specs/BCFv2_qref.pdf
    l_header = read(stream, UInt32)
    data = read(stream, l_header)

    # parse VCF header
    vcfreader = VCFReader(BufferedStreams.BufferedInputStream(data))
    header = vcfreader.header

    # create BCF "Dictionary of Strings" data structures
    string2index = Dict{String,Int}()
    contig2index = Dict{String,Int}() # TODO: get rid of this?
    for minfo in metainfo(header)
        if isequaltag(minfo,"INFO") || isequaltag(minfo,"FORMAT") || isequaltag(minfo,"FILTER")
            idx = parse(Int,minfo["IDX"]) # TODO: support header without IDX tags
            string2index[minfo["ID"]] = idx
        elseif isequaltag(minfo,"contig")
            idx = parse(Int,minfo["IDX"]) # TODO: support header without IDX tags
            contig2index[minfo["ID"]] = idx
        end
    end
    get!(string2index, "PASS", 0) == 0 || error("Invalid BCF file. PASS must have IDX 0.")
    strings = fill("", maximum(values(string2index))+1)
    for (str,idx) in string2index
        strings[idx+1] = str
    end
    contigs = fill("", maximum(values(contig2index))+1)
    for (contig,idx) in contig2index
        contigs[idx+1] = contig
    end

    return BCFReader((major, minor), header, stream, strings, string2index, contigs)
end

function Base.eltype(::Type{BCFReader{T}}) where T
    return BCFRecord
end

function BioCore.IO.stream(reader::BCFReader)
    return reader.stream
end

"""
    header(reader::BCFReader)::VCFHeader
Get the header of `reader`.
"""
function header(reader::BCFReader)
    return reader.header
end

function Base.read!(reader::BCFReader, record::BCFRecord)
    sharedlen = read(reader.stream, UInt32)
    indivlen = read(reader.stream, UInt32)
    datalen = sharedlen + indivlen
    resize!(record.data, datalen)
    unsafe_read(reader.stream, pointer(record.data), datalen)
    record.filled = 1:datalen
    record.sharedlen = sharedlen
    record.indivlen = indivlen
    record.strings = reader.strings
    record.string2index = reader.string2index
    record.contigs = reader.contigs
    return record
end

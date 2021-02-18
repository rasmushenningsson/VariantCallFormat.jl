struct BCFWriter{T<:IO} <: BioCore.IO.AbstractWriter
    stream::BGZFStreams.BGZFStream{T}
end

"""
    BCFWriter(output::IO, header::VCFHeader)
Create a data writer of the BCF file format.
# Arguments
* `output`: data sink
* `header`: VCF header object
"""
function BCFWriter(output::IO, header::VCFHeader)
    stream = BGZFStreams.BGZFStream(output, "w")
    write(stream, b"BCF\x02\x02")
    buf = IOBuffer()
    len = write(buf, header)
    if len > typemax(Int32)
        error("too long header")
    end
    write(stream, htol(Int32(len)))
    data = take!(buf)
    @assert length(data) == len
    write(stream, data)
    return BCFWriter(stream)
end

function BioCore.IO.stream(writer::BCFWriter)
    return writer.stream
end

function Base.write(writer::BCFWriter, record::BCFRecord)
    n = 0
    n += write(writer.stream, htol(record.sharedlen))
    n += write(writer.stream, htol(record.indivlen))
    n += write(writer.stream, record.data)
    return n
end

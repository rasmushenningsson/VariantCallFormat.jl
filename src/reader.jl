mutable struct Reader <: BioGenerics.IO.AbstractReader
    state::ReaderHelper.State
    header::Header

    function Reader(input::BufferedStreams.BufferedInputStream)
        reader = new(ReaderHelper.State(1, input), Header())
        readheader!(reader)
        reader.state.cs = 1
        return reader
    end
end

"""
    VCF.Reader(input::IO)
Create a data reader of the VCF file format.
# Arguments
* `input`: data source
"""
function Reader(input::IO)
    return Reader(BufferedStreams.BufferedInputStream(input))
end

function Base.eltype(::Type{Reader})
    return Record
end

function BioGenerics.IO.stream(reader::Reader)
    return reader.state.stream
end

"""
    header(reader::VCF.Reader)::VCF.Header
Get the header of `reader`.
"""
function header(reader::Reader)
    return reader.header
end

# VCF v4.3
@info "Compiling VCF parser..."
const vcf_metainfo_machine, vcf_record_machine, vcf_header_machine, vcf_body_machine = let
    delim(x, sep) = opt(x * rep(sep * x))

    # The 'fileformat' field is required and must be the first line.
    fileformat = let
        key = onexit!(onenter!(re"fileformat", :mark1), :metainfo_tag)
        version = onexit!(onenter!(re"[!-~]+", :mark2), :metainfo_val)
        onexit!(onenter!("##" * key * '=' * version, :anchor), :metainfo)
    end

    # All kinds of meta-information line after 'fileformat' are handled here.
    metainfo = let
        tag = onexit!(onenter!(re"[0-9A-Za-z_\.\-\+]+", :mark1), :metainfo_tag)
        str = onexit!(onenter!(re"[ -;=-~][ -~]*", :mark2), :metainfo_tag)  # does not starts with '<'

        dict = let
            dictkey = onexit!(onenter!(re"[0-9A-Za-z_\-\+]+", :mark1), :metainfo_dict_key)

            dictval = let
                quoted   = '"' * rep(re"[ !#-[\]-~]" | "\\\\\"" | "\\\\\\") * '"'
                unquoted = rep(re"[ -~]" \ re"[\",>]")
                onexit!(onenter!(quoted | unquoted, :mark1), :metainfo_dict_val)
            end
            onexit!(onenter!('<' * delim(dictkey * '=' * dictval, ',') * '>', :mark2), :metainfo_val)
        end
        onexit!(onenter!("##" * tag * '=' * (str | dict), :anchor), :metainfo)
    end

    # The header line.
    header = let
        sampleID = onexit!(onenter!(re"[ -~]+", :mark1), :header_sampleID)
        onenter!("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO" * opt(re"\tFORMAT" * rep(re"\t" * sampleID)), :anchor)
    end

    # Data lines (fixed fields and variable genotype fields).
    record = let
        chrom = onexit!(onenter!(re"[!-9;-~]+", :mark), :record_chrom)  # no colon
        pos = onexit!(onenter!(re"[0-9]+|\.", :mark), :record_pos)

        id = let
            elm = onexit!(re"[!-:<-~]+" \ '.', :record_id)

            onenter!(delim(elm, ';') | '.', :mark)
        end

        ref = onexit!(re"[!-~]+", :record_ref)

        alt′ = let
            elm = onexit!(re"[!-+--~]+" \ '.', :record_alt)
            onenter!(delim(elm, ',') | '.', :mark)
        end

        qual = onexit!(onenter!(re"[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?|NaN|[-+]Inf|\.", :mark), :record_qual)

        filter = let
            elm = onexit!(re"[!-:<-~]+" \ '.', :record_filter)
            onenter!(delim(elm, ';') | '.', :mark)
        end

        info = let
            key = onexit!(re"[A-Za-z_][0-9A-Za-z_.]*", :record_info_key)
            val = opt(re"=[ -:<-~]+")
            onenter!(delim(key * val, ';') | '.', :mark)
        end

        format = let
            elm = onexit!(re"[A-Za-z_][0-9A-Za-z_.]*", :record_format)
            onenter!(delim(elm, ':') | '.', :mark)
        end

        genotype = let
            elm = onexit!(onenter!(re"[ -9;-~]+", :mark), :record_genotype_elm)  # no colon
            onenter!(delim(elm, ':'), :record_genotype)
        end

            chrom *  '\t' *
            pos *    '\t' *
            id *     '\t' *
            ref *    '\t' *
            alt′ *   '\t' *
            qual *   '\t' *
            filter * '\t' *
            info *
            opt('\t' * format * rep('\t' * genotype))
    end
    onexit!(onenter!(record, :anchor), :record)

    # A newline can be either a CR+LF or a LF.
    newline = let
        lf = onenter!(re"\n", :countline)
        opt(re"\r") * lf
    end

    # The VCF file format (header and body part).
    vcfheader = fileformat * newline *
        rep(metainfo * newline) *
        header * newline
    onfinal!(vcfheader, :vcfheader)

    vcfbody = rep(record * newline)

    map(compile, (metainfo, record, vcfheader, vcfbody))
end

const vcf_metainfo_actions = Dict(
    :metainfo_tag      => :(record.tag = (mark1:p-1) .- offset),
    :metainfo_val      => :(record.val = (mark2:p-1) .- offset; record.dict = data[mark2] == UInt8('<')),
    :metainfo_dict_key => :(push!(record.dictkey, (mark1:p-1) .- offset)),
    :metainfo_dict_val => :(push!(record.dictval, (mark1:p-1) .- offset)),
    :metainfo          => quote
        ReaderHelper.resize_and_copy!(record.data, data, offset+1:p-1)
        record.filled = (offset+1:p-1) .- offset
    end,
    :anchor            => :(),
    :mark1             => :(mark1 = p),
    :mark2             => :(mark2 = p))
eval(
    ReaderHelper.generate_index_function(
        MetaInfo,
        vcf_metainfo_machine,
        :(mark1 = mark2 = offset = 0),
        vcf_metainfo_actions))
eval(
    ReaderHelper.generate_readheader_function(
        Reader,
        MetaInfo,
        vcf_header_machine,
        :(mark1 = mark2 = offset = 0),
        merge(vcf_metainfo_actions, Dict(
            :metainfo => quote
                ReaderHelper.resize_and_copy!(record.data, data, ReaderHelper.upanchor!(stream):p-1)
                record.filled = (offset+1:p-1) .- offset
                @assert isfilled(record)
                push!(reader.header.metainfo, record)
                ReaderHelper.ensure_margin!(stream)
                record = MetaInfo()
            end,
            :header_sampleID => :(push!(reader.header.sampleID, String(data[mark1:p-1]))),
            :vcfheader => :(finish_header = true; @escape),
            :countline => :(linenum += 1),
            :anchor    => :(ReaderHelper.anchor!(stream, p); offset = p - 1)))))

const vcf_record_actions = Dict(
    :record_chrom        => :(record.chrom = (mark:p-1) .- offset),
    :record_pos          => :(record.pos = (mark:p-1) .- offset),
    :record_id           => :(push!(record.id, (mark:p-1) .- offset)),
    :record_ref          => :(record.ref = (mark:p-1) .- offset),
    :record_alt          => :(push!(record.alt, (mark:p-1) .- offset)),
    :record_qual         => :(record.qual = (mark:p-1) .- offset),
    :record_filter       => :(push!(record.filter, (mark:p-1) .- offset)),
    :record_info_key     => :(push!(record.infokey, (mark:p-1) .- offset)),
    :record_format       => :(push!(record.format, (mark:p-1) .- offset)),
    :record_genotype     => :(push!(record.genotype, UnitRange{Int}[])),
    :record_genotype_elm => :(push!(record.genotype[end], (mark:p-1) .- offset)),
    :record              => quote
        ReaderHelper.resize_and_copy!(record.data, data, 1:p-1)
        record.filled = (offset+1:p-1) .- offset
    end,
    :anchor              => :(),
    :mark                => :(mark = p))
eval(
    ReaderHelper.generate_index_function(
        Record,
        vcf_record_machine,
        :(mark = offset = 0),
        vcf_record_actions))
eval(
    ReaderHelper.generate_read_function(
        Reader,
        vcf_body_machine,
        :(mark = offset = 0),
        merge(vcf_record_actions, Dict(
            :record    => quote
                ReaderHelper.resize_and_copy!(record.data, data, ReaderHelper.upanchor!(stream):p-1)
                record.filled = (offset+1:p-1) .- offset
                found_record = true
                @escape
            end,
            :countline => :(linenum += 1),
            :anchor    => :(ReaderHelper.anchor!(stream, p); offset = p - 1)))))

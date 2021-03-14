mutable struct VCFRecord <: AbstractRecord
    # data and filled range
    data::Vector{UInt8}
    filled_::UnitRange{Int}
    # indexes
    chrom_::UnitRange{Int}
    pos_::UnitRange{Int}
    id_::Vector{UnitRange{Int}}
    ref_::UnitRange{Int}
    alt_::Vector{UnitRange{Int}}
    qual_::UnitRange{Int}
    filter_::Vector{UnitRange{Int}}
    infokey_::Vector{UnitRange{Int}}
    format_::Vector{UnitRange{Int}}
    genotype_::Vector{Vector{UnitRange{Int}}}
end

"""
    VCFRecord()
Create an unfilled VCF record.
"""
function VCFRecord()
    return VCFRecord(
        # data and filled
        UInt8[], 1:0,
        # chrom-alt
        1:0, 1:0, UnitRange{Int}[], 1:0, UnitRange{Int}[],
        # qual-genotype
        1:0, UnitRange{Int}[], UnitRange{Int}[], UnitRange{Int}[], UnitRange{Int}[])
end

"""
    VCFRecord(data::Vector{UInt8})
Create a VCF object from `data` containing a VCF record.
This function verifies the format and indexes fields for accessors.
Note that the ownership of `data` is transferred to a new record.
"""
function VCFRecord(data::Vector{UInt8})
    return convert(VCFRecord, data)
end

function Base.convert(::Type{VCFRecord}, data::Vector{UInt8})
    record = VCFRecord(
        # data and filled
        data, 1:0,
        # chrom-alt
        1:0, 1:0, UnitRange{Int}[], 1:0, UnitRange{Int}[],
        # qual-genotype
        1:0, UnitRange{Int}[], UnitRange{Int}[], UnitRange{Int}[], UnitRange{Int}[])
    index!(record)
    return record
end

"""
    VCFRecord(str::AbstractString)
Create a VCF object from `str` containing a VCF record.
This function verifies the format and indexes fields for accessors.
"""
function VCFRecord(str::AbstractString)
    return convert(VCFRecord, str)
end

function Base.convert(::Type{VCFRecord}, str::AbstractString)
    return VCFRecord(Vector{UInt8}(str))
end

function initialize!(record::VCFRecord)
    record.filled_ = 1:0
    record.chrom_ = 1:0
    record.pos_ = 1:0
    empty!(record.id_)
    record.ref_ = 1:0
    empty!(record.alt_)
    record.qual_ = 1:0
    empty!(record.filter_)
    empty!(record.infokey_)
    empty!(record.format_)
    empty!(record.genotype_)
    return record
end

function isfilled(record::VCFRecord)
    return !isempty(record.filled_)
end

function datarange(record::VCFRecord)
    return record.filled_
end

function Base.:(==)(record1::VCFRecord, record2::VCFRecord)
    if isfilled(record1) == isfilled(record2) == true
        r1 = datarange(record1)
        r2 = datarange(record2)
        return length(r1) == length(r2) && memcmp(pointer(record1.data, first(r1)), pointer(record2.data, first(r2)), length(r1)) == 0
    else
        return isfilled(record1) == isfilled(record2) == false
    end
end

function checkfilled(record::VCFRecord)
    if !isfilled(record)
        throw(ArgumentError("unfilled VCF record"))
    end
end

function VCFRecord(base::VCFRecord;
                   chrom=nothing, pos=nothing, id=nothing,
                   ref=nothing, alt=nothing, qual=nothing,
                   filter=nothing, info=nothing, genotype=nothing)
    checkfilled(base)
    buf = IOBuffer()

    if chrom == nothing
        write(buf, base.data[base.chrom_])
    else
        print(buf, string(chrom))
    end

    print(buf, '\t')
    if pos == nothing
        write(buf, base.data[base.pos_])
    else
        print(buf, convert(Int, pos))
    end

    print(buf, '\t')
    if id == nothing
        if isempty(base.id_)
            print(buf, '.')
        else
            for (i, r) in enumerate(base.id_)
                if i != 1
                    print(buf, ';')
                end
                write(buf, base.data[r])
            end
        end
    else
        if !isa(id, Vector)
            id = [id]
        end
        if isempty(id)
            print(buf, '.')
        else
            for (i, x) in enumerate(id)
                if i != 1
                    print(buf, ';')
                end
                print(buf, string(x))
            end
        end
    end

    print(buf, '\t')
    if ref == nothing
        write(buf, base.data[base.ref_])
    else
        print(buf, string(ref))
    end

    print(buf, '\t')
    if alt == nothing
        if isempty(base.alt_)
            print(buf, '.')
        else
            for (i, r) in enumerate(base.alt_)
                if i != 1
                    print(buf, ';')
                end
                write(buf, base.data[r])
            end
        end
    else
        if !isa(alt, Vector)
            alt = [alt]
        end
        if isempty(alt)
            print(buf, '.')
        else
            for (i, x) in enumerate(alt)
                if i != 1
                    print(buf, ';')
                end
                print(buf, string(x))
            end
        end
    end

    print(buf, '\t')
    if qual == nothing
        write(buf, base.data[base.qual_])
    else
        print(buf, convert(Float64, qual))
    end

    print(buf, '\t')
    if filter == nothing
        if isempty(base.filter_)
            print(buf, '.')
        else
            for (i, r) in enumerate(base.filter_)
                if i != 1
                    print(buf, ';')
                end
                write(buf, base.data[r])
            end
        end
    else
        if !isa(filter, Vector)
            filter = [filter]
        end
        if isempty(filter)
            print(buf, '.')
        else
            for (i, x) in enumerate(filter)
                if i != 1
                    print(buf, ';')
                end
                print(buf, string(x))
            end
        end
    end

    print(buf, '\t')
    if info == nothing
        if isempty(base.infokey_)
            print(buf, '.')
        else
            write(buf, base.data[first(base.infokey_[1]):last(infovalrange(base, lastindex(base.infokey_)))])
        end
    else
        if !isa(info, AbstractDict)
            throw(ArgumentError("info must be an AbstractDict"))
        elseif isempty(info)
            print(buf, '.')
        else
            for (i, (key, val)) in enumerate(info)
                if i != 1
                    print(buf, ';')
                end
                print(buf, string(key))
                if val != nothing
                    print(buf, '=', vcfformat(val))
                end
            end
        end
    end

    print(buf, '\t')
    if genotype == nothing
        if isempty(base.format_)
            print(buf, '.')
        else
            write(buf, base.data[first(base.format_[1]):last(base.format_[end])])
        end
        if !isempty(base.genotype_)
            for indiv in base.genotype_
                print(buf, '\t')
                for (i, r) in enumerate(indiv)
                    if i != 1
                        print(buf, ':')
                    end
                    write(buf, base.data[r])
                end
            end
        end
    else
        if !isa(genotype, Vector)
            genotype = [genotype]
        end
        if isempty(genotype)
            print(buf, '.')
        else
            allkeys = String[]
            for indiv in genotype
                if !isa(indiv, AbstractDict)
                    throw(ArgumentError("individual must be anabstract dictionary"))
                end
                append!(allkeys, keys(indiv))
            end
            allkeys = sort!(unique(allkeys))
            if !isempty(allkeys)
                join(buf, allkeys, ':')
                for indiv in genotype
                    print(buf, '\t')
                    for (i, key) in enumerate(allkeys)
                        if i != 1
                            print(buf, ':')
                        end
                        print(buf, vcfformat(get(indiv, key, '.')))
                    end
                end
            end
        end
    end

    return VCFRecord(take!(buf))
end

function vcfformat(val)
    return string(val)
end

function vcfformat(val::Vector)
    return join(map(vcfformat, val), ',')
end

function Base.copy(record::VCFRecord)
    return VCFRecord(
        copy(record.data),
        record.filled_,
        record.chrom_,
        record.pos_,
        copy(record.id_),
        record.ref_,
        copy(record.alt_),
        record.qual_,
        copy(record.filter_),
        copy(record.infokey_),
        copy(record.format_),
        deepcopy(record.genotype_))
end

function Base.write(io::IO, record::VCFRecord)
    checkfilled(record)
    return write(io, record.data)
end


# Accessor functions
# ------------------

"""
    chrom(record::VCFRecord)::String
Get the chromosome name of `record`.
"""
function chrom(record::VCFRecord)::String
    checkfilled(record)
    if ismissing(record, record.chrom_)
        missingerror(:chrom)
    end
    return String(record.data[record.chrom_])
end

function haschrom(record::VCFRecord)
    return isfilled(record) && !ismissing(record, record.chrom_)
end

"""
    pos(record::VCFRecord)::Int
Get the reference position of `record`.
"""
function pos(record::VCFRecord)::Int
    checkfilled(record)
    if ismissing(record, record.pos_)
        missingerror(:pos)
    end
    # TODO: no-copy accessor
    return parse(Int, String(record.data[record.pos_]))
end

function haspos(record::VCFRecord)
    return isfilled(record) && !ismissing(record, record.pos_)
end

"""
    id(record::VCFRecord)::Vector{String}
Get the identifiers of `record`.
"""
function id(record::VCFRecord)::Vector{String}
    checkfilled(record)
    if isempty(record.id_)
        missingerror(:id)
    end
    return [String(record.data[r]) for r in record.id_]
end

function hasid(record::VCFRecord)
    return isfilled(record) && !isempty(record.id_)
end

"""
    ref(record::VCFRecord)::String
Get the reference bases of `record`.
"""
function ref(record::VCFRecord)::String
    checkfilled(record)
    if ismissing(record, record.ref_)
        missingerror(:ref)
    end
    return String(record.data[record.ref_])
end

function hasref(record::VCFRecord)
    return isfilled(record) && !ismissing(record, record.ref_)
end

"""
    alt(record::VCFRecord)::Vector{String}
Get the alternate bases of `record`.
"""
function alt(record::VCFRecord)::Vector{String}
    checkfilled(record)
    if isempty(record.alt_)
        missingerror(:alt)
    end
    return [String(record.data[r]) for r in record.alt_]
end

function hasalt(record::VCFRecord)
    return isfilled(record) && !isempty(record.alt_)
end

"""
    qual(record::VCFRecord)::Float64
Get the quality score of `record`.
"""
function qual(record::VCFRecord)::Float64
    checkfilled(record)
    if ismissing(record, record.qual_)
        missingerror(:qual)
    end
    # TODO: no-copy parse
    return parse(Float64, String(record.data[record.qual_]))
end

function hasqual(record::VCFRecord)
    return isfilled(record) && !ismissing(record, record.qual_)
end

"""
    filter(record::VCFRecord)::Vector{String}
Get the filter status of `record`.
"""
function filter(record::VCFRecord)::Vector{String}
    checkfilled(record)
    if isempty(record.filter_)
        missingerror(:filter)
    end
    return [String(record.data[r]) for r in record.filter_]
end

function hasfilter(record::VCFRecord)
    return isfilled(record) && !isempty(record.filter_)
end

"""
    info(record::VCFRecord)::Vector{Pair{String,String}}
Get the additional information of `record`.
"""
function info(record::VCFRecord)::Vector{Pair{String,String}}
    checkfilled(record)
    if isempty(record.infokey_)
        missingerror(:info) # TODO: deprecate this behavior, it's OK with an empty dict.
    end
    return [ k=>string(v) for (k,v) in record.info ]
end

function hasinfo(record::VCFRecord)
    return isfilled(record) && !isempty(record.infokey_)
end

"""
    info(record::VCFRecord, key::String)::String
Get the additional information of `record` with `key`.
Keys without corresponding values return an empty string.
"""
function info(record::VCFRecord, key::String)::String
    return string(record.info[key])
end

function hasinfo(record::VCFRecord, key::String)
    return haskey(record.info, key)
end

"""
    infokeys(record::VCFRecord)::Vector{String}
Get the keys of the additional information of `record`.
This function returns an empty vector when the INFO field is missing.
"""
function infokeys(record::VCFRecord)::Vector{String}
    collect(keys(record.info))
end

# Returns the data range of the `i`-th value.
function infovalrange(record::VCFRecord, i::Int)
    return infovalrange(infodict(record),i)
end

"""
    format(record::VCFRecord)::Vector{String}
Get the genotype format of `record`.
"""
function format(record::VCFRecord)::Vector{String}
    checkfilled(record)
    if isempty(record.format_)
        missingerror(:format)
    end
    return [String(record.data[r]) for r in record.format_]
end

function hasformat(record::VCFRecord)
    return isfilled(record) && !isempty(record.format_)
end

"""
    genotype(record::VCFRecord)::Vector{Vector{String}}
Get the genotypes of `record`.
"""
function genotype(record::VCFRecord)
    Vector{String}[ record.genotype[i,:] for i in 1:lastindex(record.genotype_)]
end

"""
    genotype(record::VCFRecord, index::Integer)::Vector{String}
Get the genotypes of the `index`-th individual in `record`.
This is effectively equivalent to `genotype(record)[index]` but more efficient.
"""
function genotype(record::VCFRecord, index::Integer)
    return record.genotype[index,:]
end

"""
    genotype(record::VCFRecord, indexes, keys)
Get the genotypes in `record` that match `indexes` and `keys`.
`indexes` and `keys` can be either a scalar or a vector value.
Trailing fields that are dropped are filled with `"."`.
"""
function genotype(record::VCFRecord, index::Integer, key::String)::String
    return record.genotype[index,key]
end

function genotype(record::VCFRecord, index::Integer, keys::AbstractVector{String})::Vector{String}
    return record.genotype[index,keys]
end

function genotype(record::VCFRecord, indexes::AbstractVector{T}, key::String)::Vector{String} where T<:Integer
    return record.genotype[indexes,key]
end

function genotype(record::VCFRecord, indexes::AbstractVector{T}, keys::AbstractVector{String})::Vector{Vector{String}} where T<:Integer
    # keep old (deprecated) behavior returning Vector{Vector{String}}
    g = record.genotype
    ks = findgenokey.(Ref(g),keys)
    [ g[i, ks] for i in indexes ]
end

function genotype(record::VCFRecord, ::Colon, key::String)::Vector{String}
    return record.genotype[:,key]
end

"""
    rlen(record::VCFRecord)::Int
Get the length of `record` projected onto the reference sequence.
"""
function rlen(record::VCFRecord)::Int
    checkfilled(record)
    # TODO: this is incorrect if there are symbolic alleles. (In that case, it should be computed using the END info attribute.)
    return length(record.ref_)
end

"""
    n_allele(record::VCFRecord)::Int
Get the number of alleles for `record`, counting ref and each alt.
"""
function n_allele(record::VCFRecord)
    checkfilled(record)
    return length(record.alt_)
end

"""
    n_info(record::VCFRecord)::Int
Get the number of info entries for `record`.
"""
function n_info(record::VCFRecord)
    checkfilled(record)
    return length(record.infokey_)
end

"""
    n_format(record::VCFRecord)::Int
Get the number of format entries for `record`.
"""
function n_format(record::VCFRecord)
    checkfilled(record)
    return length(record.format_)
end

"""
    n_sample(record::VCFRecord)::Int
Get the number of samples for `record`.
"""
function n_sample(record::VCFRecord)
    checkfilled(record)
    return length(record.genotype_)
end





function Base.show(io::IO, record::VCFRecord)
    print(io, summary(record), ':')
    if isfilled(record)
        println(io)
        println(io, "   chromosome: ", haschrom(record) ? record.chrom : "<missing>")
        println(io, "     position: ", haspos(record) ? record.pos : "<missing>")
        println(io, "   identifier: ", hasid(record) ? join(record.id, " ") : "<missing>")
        println(io, "    reference: ", hasref(record) ? record.ref : "<missing>")
        println(io, "    alternate: ", hasalt(record) ? join(record.alt, " ") : "<missing>")
        println(io, "      quality: ", hasqual(record) ? record.qual : "<missing>")
        println(io, "       filter: ", hasfilter(record) ? join(record.filter, " ") : "<missing>")
          print(io, "  information: ")
        if hasinfo(record)
            for (key, val) in record.info
                print(io, key)
                if !isempty(val)
                    print(io, '=', string(val))
                end
                print(io, ' ')
            end
        else
            print(io, "<missing>")
        end
        println(io)
          print(io, "       format: ", hasformat(record) ? join(record.format, " ") : "<missing>")
        if hasformat(record)
            println(io)
            print(io, "     genotype:")
            for i in 1:n_sample(record)
                print(io, " [$i]")
                for k in 1:n_format(record)
                    print(io, ' ', record.genotype[i,k])
                end
            end
        end
    else
        print(io, " <not filled>")
    end
end

function ismissing(record::VCFRecord, range::UnitRange{Int})
    return length(range) == 1 && record.data[first(range)] == UInt8('.')
end

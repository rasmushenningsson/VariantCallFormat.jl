abstract type AbstractRecord end

const recordpropertynames = (:chrom,
                             :pos,
                             :id,
                             :ref,
                             :alt,
                             :qual,
                             :filter,
                             :info,
                             :format,
                             :genotype,
                             :info,
                             :genotype,
                            )


function Base.propertynames(record::T, private=false) where T<:AbstractRecord
	private || return recordpropertynames
	return (recordpropertynames..., fieldnames(T)...)
end


# TODO: A better solution is probably to use VCFRecord to wrap an internal struct
#       The internal struct works exclusively with standard getfield()
#       But VCFRecord uses only getproperty()


# One possible workaround for getproperty slowness
Base.getproperty(record::AbstractRecord, sym::Symbol) = _getproperty(record, Val(sym))
_getproperty(record::AbstractRecord, ::Val{:chrom}) = chrom(record)
_getproperty(record::AbstractRecord, ::Val{:pos}) = pos(record)
_getproperty(record::AbstractRecord, ::Val{:id}) = id(record)
_getproperty(record::AbstractRecord, ::Val{:ref}) = ref(record)
_getproperty(record::AbstractRecord, ::Val{:alt}) = alt(record)
_getproperty(record::AbstractRecord, ::Val{:qual}) = qual(record)
_getproperty(record::AbstractRecord, ::Val{:filter}) = filter(record)
_getproperty(record::AbstractRecord, ::Val{:info}) = infodict(record)
_getproperty(record::AbstractRecord, ::Val{:format}) = format(record)
_getproperty(record::AbstractRecord, ::Val{:genotype}) = genotypewrapper(record)
_getproperty(record::AbstractRecord, ::Val{sym}) where {sym} = getfield(record,sym)


# Leads to *very* slow compilation
# The reason is most likely that it's time consuming for the compiler to figure out all the getfield calls
# function Base.getproperty(record::AbstractRecord, sym::Symbol)
# 	sym==:chrom && return chrom(record)
# 	sym==:pos && return pos(record)
# 	sym==:id && return id(record)
# 	sym==:ref && return ref(record)
# 	sym==:alt && return alt(record)
# 	sym==:qual && return qual(record)
# 	sym==:filter && return filter(record)
# 	sym==:info && return infodict(record)
# 	sym==:format && return format(record)
# 	sym==:genotype && return genotypewrapper(record)
# 	getfield(record,sym)
# end

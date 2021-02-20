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
                             # :genotype, # TODO: Add
                            )


function Base.propertynames(record::T, private=false) where T<:AbstractRecord
	private || return recordpropertynames
	return (recordpropertynames..., fieldnames(T)...)
end

function Base.getproperty(record::AbstractRecord, sym::Symbol)
	sym==:chrom && return chrom(record)
	sym==:pos && return pos(record)
	sym==:id && return id(record)
	sym==:ref && return ref(record)
	sym==:alt && return alt(record)
	sym==:qual && return qual(record)
	sym==:filter && return filter(record)
	sym==:info && return infodict(record)
	sym==:format && return format(record)
	# sym==:genotype && return GenotypeWrapper(record)
	getfield(record,sym)
end

abstract type AbstractRecord end

const recordpropertynames = (:chrom,:filter) # TODO: add more

function Base.propertynames(record::T, private=false) where T<:AbstractRecord
	private || return recordpropertynames
	return (recordpropertynames..., fieldnames(T)...)
end

function Base.getproperty(record::AbstractRecord, sym::Symbol)
	sym==:chrom && return chrom(record)
	sym==:filter && return filter(record)
	getfield(record,sym)
end

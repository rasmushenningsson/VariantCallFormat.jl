module VariantCallFormat

import Automa
import Automa.RegExp: @re_str
import BioGenerics
import BioGenerics.Exceptions: missingerror, MissingFieldException
import BufferedStreams

export
    VCF,
    BCF,
    header,
    metainfotag,
    metainfoval,
    isfilled,
    MissingFieldException

include("ReaderHelper.jl")

include("record.jl")
include("metainfo.jl")
include("header.jl")
include("reader.jl")
include("writer.jl")

# This module is here for backwards compatibility and to serve as a way to conveniently access unexported names
module VCF
	import VariantCallFormat

	const alt = VariantCallFormat.alt
	const chrom = VariantCallFormat.chrom
	const filter = VariantCallFormat.filter
	const format = VariantCallFormat.format
	const genotype = VariantCallFormat.genotype
	const hasalt = VariantCallFormat.hasalt
	const haschrom = VariantCallFormat.haschrom
	const hasfilter = VariantCallFormat.hasfilter
	const hasformat = VariantCallFormat.hasformat
	const hasid = VariantCallFormat.hasid
	const hasinfo = VariantCallFormat.hasinfo
	const haspos = VariantCallFormat.haspos
	const hasqual = VariantCallFormat.hasqual
	const hasref = VariantCallFormat.hasref
	const Header = VariantCallFormat.Header
	const id = VariantCallFormat.id
	const info = VariantCallFormat.info
	const infokeys = VariantCallFormat.infokeys
	const initialize! = VariantCallFormat.initialize!
	const isfilled = VariantCallFormat.isfilled
	const MetaInfo = VariantCallFormat.MetaInfo
	const pos = VariantCallFormat.pos
	const qual = VariantCallFormat.qual
	const Reader = VariantCallFormat.Reader
	const Record = VariantCallFormat.Record
	const ref = VariantCallFormat.ref
	const Writer = VariantCallFormat.Writer
end

include("bcf/bcf.jl")


end

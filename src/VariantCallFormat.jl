module VariantCallFormat

import Automa
import Automa.RegExp: @re_str
import BioCore
import BioCore: isfilled, metainfotag, metainfoval, header
import BioCore.Exceptions: missingerror
import BufferedStreams
import BGZFStreams

export
    VCF,
    BCF,
    VCFHeader,
    VCFRecord,
    VCFReader,
    VCFWriter,
    BCFRecord,
    BCFReader,
    BCFWriter,
    header,
    metainfo,
    sampleids,
    metainfotag,
    metainfoval,
    isfilled,
    MissingFieldException

include("metainfo.jl")
include("header.jl")

include("abstractrecord.jl")
include("mem.jl")

include("vcf/record.jl")
include("vcf/infodict.jl")
include("vcf/genotypematrix.jl")
include("vcf/reader.jl")
include("vcf/writer.jl")

include("bcf/record.jl")
include("bcf/reader.jl")
include("bcf/writer.jl")

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
	const Header = VariantCallFormat.VCFHeader
	const id = VariantCallFormat.id
	const info = VariantCallFormat.info
	const infokeys = VariantCallFormat.infokeys
	const initialize! = VariantCallFormat.initialize!
	const isfilled = VariantCallFormat.isfilled
	const MetaInfo = VariantCallFormat.MetaInfo
	const pos = VariantCallFormat.pos
	const qual = VariantCallFormat.qual
	const Reader = VariantCallFormat.VCFReader
	const Record = VariantCallFormat.VCFRecord
	const ref = VariantCallFormat.ref
	const Writer = VariantCallFormat.VCFWriter
end

# This module is here for backwards compatibility and to serve as a way to conveniently access unexported names
module BCF
	import VariantCallFormat

	const alt = VariantCallFormat.alt
	const chrom = VariantCallFormat.chrom
	const filter = VariantCallFormat.filter
	const format = VariantCallFormat.format
	const genotype = VariantCallFormat.genotype
	# const hasalt = VariantCallFormat.hasalt
	# const haschrom = VariantCallFormat.haschrom
	# const hasfilter = VariantCallFormat.hasfilter
	# const hasformat = VariantCallFormat.hasformat
	# const hasid = VariantCallFormat.hasid
	# const hasinfo = VariantCallFormat.hasinfo
	# const haspos = VariantCallFormat.haspos
	# const hasqual = VariantCallFormat.hasqual
	# const hasref = VariantCallFormat.hasref
	# const Header = VariantCallFormat.VCFHeader
	const id = VariantCallFormat.id
	const info = VariantCallFormat.info
	const infokeys = VariantCallFormat.infokeys
	const initialize! = VariantCallFormat.initialize!
	const isfilled = VariantCallFormat.isfilled
	const pos = VariantCallFormat.pos
	const qual = VariantCallFormat.qual
	const Reader = VariantCallFormat.BCFReader
	const Record = VariantCallFormat.BCFRecord
	const ref = VariantCallFormat.ref
	const Writer = VariantCallFormat.BCFWriter
	const rlen = VariantCallFormat.rlen
	const n_allele = VariantCallFormat.n_allele
	const n_info = VariantCallFormat.n_info
	const n_format = VariantCallFormat.n_format
	const n_sample = VariantCallFormat.n_sample
	const gt = VariantCallFormat.gt
end


end

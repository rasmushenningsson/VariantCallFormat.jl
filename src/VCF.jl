module VCF

import Automa
import Automa.RegExp: @re_str
# import BioCore: BioCore, isfilled
import BioCore
import BioCore.Exceptions: missingerror
import BufferedStreams


import BioCore:
    isfilled,
    metainfotag,
    metainfoval,
    header

export
    header,
    metainfotag,
    metainfoval,
    isfilled,
    MissingFieldException



include("record.jl")
include("metainfo.jl")
include("header.jl")
include("reader.jl")
include("writer.jl")

end

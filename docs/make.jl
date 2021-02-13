using VCF
using Documenter

makedocs(;
    modules=[VCF],
    authors="Kenta Sato, Ben J. Ward, Rasmus Henningsson, The BioJulia Organisation and other contributors.",
    repo="https://github.com/rasmushenningsson/VCF.jl/blob/{commit}{path}#L{line}",
    sitename="VCF.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rasmushenningsson.github.io/VCF.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "VCF and BCF formatted files" => "vcf-bcf.md",
        "Reference" => "reference.md",
    ],
)

deploydocs(;
    repo="github.com/rasmushenningsson/VCF.jl",
)

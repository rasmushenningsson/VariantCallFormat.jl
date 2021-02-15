using VariantCallFormat
using Documenter

makedocs(;
    modules=[VariantCallFormat],
    authors="Kenta Sato, Ben J. Ward, Rasmus Henningsson, The BioJulia Organisation and other contributors.",
    repo="https://github.com/rasmushenningsson/VariantCallFormat.jl/blob/{commit}{path}#L{line}",
    sitename="VariantCallFormat.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rasmushenningsson.github.io/VariantCallFormat.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "VCF and BCF formatted files" => "vcf-bcf.md",
        "Reference" => "reference.md",
    ],
)

deploydocs(;
    repo="github.com/rasmushenningsson/VariantCallFormat.jl",
    devbranch="main",
)

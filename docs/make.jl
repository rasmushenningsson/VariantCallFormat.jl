using Documenter, VCF

makedocs(
    modules = [VCF],
    format = :html,
    sitename = "VCF.jl",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "VCF and BCF formatted files" => "man/io/vcf-bcf.md"
        ]
    ],
    authors = "Kenta Sato, Ben J. Ward, Rasmus Henningsson, The BioJulia Organisation and other contributors."
)

deploydocs(
    repo = "github.com/rasmushenningsson/VCF.jl.git",
    julia = "1.5",
    osname = "linux",
    target = "build",
    deps = nothing,
    make = nothing
)

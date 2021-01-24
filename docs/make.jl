using EnlilGrids
using Documenter

makedocs(;
    modules=[EnlilGrids],
    authors="Ondrej Winter <ondrej.winter@fs.cvut.cz> and contributors",
    repo="https://github.com/owinter92/EnlilGrids.jl/blob/{commit}{path}#L{line}",
    sitename="EnlilGrids.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://owinter92.github.io/EnlilGrids.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/owinter92/EnlilGrids.jl",
)

using Weave, Fontconfig, Cairo

set_chunk_defaults(Dict{Symbol, Any}(:results => "hidden", :eval => false))

files_to_weave = ["trait_tree.jmd",
                  "snaq_plot.jmd",
                  "bootstrap.jmd"]


for file in files_to_weave
    weave(Pkg.dir("PhyloNetworks","docs","src", "man", "src", file),
        informat = "markdown",
        out_path = Pkg.dir("PhyloNetworks","docs","src", "man"),
        fig_path = "../assets/figures",
        fig_ext  = ".png",
        doctype  = "github")
end

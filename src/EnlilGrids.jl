module EnlilGrids

include("gmsh.jl")
export load_file_line_by_line,
       load_gmsh_file,
       do_physicalnames!,
       do_entities!,
       do_nodes!,
       do_elements!,
       load_gmsh
end

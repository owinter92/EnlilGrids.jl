@testset "load_gmsh_file" begin
    @test_throws ErrorException("File a does not exist.") load_gmsh_file("a")
    @test_throws ErrorException("Gmsh mesh file format saved in binary mode. Please convert to ASCII mode.") load_gmsh_file("data/gmsh/gmsh41_triangles_coarse_only_mesh_bin.msh")
    
    include("data/gmsh/gmsh41_triangles_coarse_only_mesh.jl")
    @test load_gmsh_file("data/gmsh/gmsh41_triangles_coarse_only_mesh.msh") == test_msh

    include("data/gmsh/gmsh41_triangles_coarse.jl")
    @test load_gmsh_file("data/gmsh/gmsh41_triangles_coarse.msh") == test_msh

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    @test load_gmsh_file("data/gmsh/gmsh41_tetrahedrons_coarse.msh") == test_msh
end

@testset "gmsh_do_physicalnames" begin
    include("data/gmsh/gmsh41_triangles_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_triangles_coarse.msh")
    @test gmsh_do_physicalnames(msh.raw_PhysicalNames) == test_physicals

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_tetrahedrons_coarse.msh")
    @test gmsh_do_physicalnames(msh.raw_PhysicalNames) == test_physicals
end

@testset "gmsh_do_entities" begin
    include("data/gmsh/gmsh41_triangles_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_triangles_coarse.msh")
    @test gmsh_do_entities(msh.raw_Entities) == test_entities

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_tetrahedrons_coarse.msh")
    @test gmsh_do_entities(msh.raw_Entities) == test_entities
end

@testset "gmsh_do_nodes" begin
    include("data/gmsh/gmsh41_triangles_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_triangles_coarse.msh")
    @test gmsh_do_nodes(msh.raw_Nodes) == test_nodes

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_tetrahedrons_coarse.msh")
    @test gmsh_do_nodes(msh.raw_Nodes) == test_nodes
end

@testset "gmsh_do_elements" begin
    include("data/gmsh/gmsh41_triangles_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_triangles_coarse.msh")
    @test gmsh_do_elements(msh.raw_Elements) == test_elements

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    msh = load_gmsh_file("data/gmsh/gmsh41_tetrahedrons_coarse.msh")
    @test gmsh_do_elements(msh.raw_Elements) == test_elements
end

@testset "load_gmsh" begin
    include("data/gmsh/gmsh41_triangles_coarse.jl")
    @test load_gmsh("data/gmsh/gmsh41_triangles_coarse.msh") == (physicalTagtoName=test_physicals,
         tagToPhysicalTag=test_entities,
         nodes=test_nodes,
         elements=test_elements)

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    @test load_gmsh("data/gmsh/gmsh41_tetrahedrons_coarse.msh") == (physicalTagtoName=test_physicals,
         tagToPhysicalTag=test_entities,
         nodes=test_nodes,
         elements=test_elements)
end

@testset "import_gmsh" begin
    include("data/gmsh/gmsh41_triangles_coarse.jl")
    ir20 = import_gmsh("data/gmsh/gmsh41_triangles_coarse.msh")

    @test ir20._v == test_ir20._v
    @test ir20.name == test_ir20.name
    
    @test ir20.left.name == test_ir20.left.name
    @test ir20.left.attributes == test_ir20.left.attributes
    @test ir20.left.nshapes == test_ir20.left.nshapes
    @test ir20.left.shapedesc == test_ir20.left.shapedesc

    @test ir20.right.name == test_ir20.right.name
    @test ir20.right.attributes == test_ir20.right.attributes
    @test ir20.right.nshapes == test_ir20.right.nshapes
    @test ir20.right.shapedesc == test_ir20.right.shapedesc

    include("data/gmsh/gmsh41_tetrahedrons_coarse.jl")
    ir30 = import_gmsh("data/gmsh/gmsh41_tetrahedrons_coarse.msh")

    @test ir30._v == test_ir30._v
    @test ir30.name == test_ir30.name
    
    @test ir30.left.name == test_ir30.left.name
    @test ir30.left.attributes == test_ir30.left.attributes
    @test ir30.left.nshapes == test_ir30.left.nshapes
    @test ir30.left.shapedesc == test_ir30.left.shapedesc

    @test ir30.right.name == test_ir30.right.name
    @test ir30.right.attributes == test_ir30.right.attributes
    @test ir30.right.nshapes == test_ir30.right.nshapes
    @test ir30.right.shapedesc == test_ir30.right.shapedesc
end

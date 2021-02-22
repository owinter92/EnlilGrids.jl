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

#@testset "import_gmsh" begin
#    using MeshCore.Exports
#    using StaticArrays
#
#    msh = load_gmsh("data/gmsh_v41_2d_verycoarse.msh")
#    xyz = reshape([msh.nodes.vx; msh.nodes.vy;], length(msh.nodes.vx), 2)
#    N, T = size(xyz, 2), eltype(xyz)
#    locs =  VecAttrib([SVector{N,T}(xyz[i, :]) for i in 1:size(xyz, 1)])
#    vrts = ShapeColl(P1, length(locs), "vertices")
#    vrts.attributes["geom"] = locs
#    shapes = ShapeColl(T3, size(msh.elements.nodeTags2D, 1), "elements")
#    ir20 = IncRel(shapes, vrts, msh.elements.nodeTags2D)
#
#    mesh = import_gmsh("data/gmsh_v41_2d_verycoarse.msh")
#    @test mesh._v == ir20._v && mesh[1] == ir20[1] && mesh[2] == ir20[2] && mesh[3] == ir20[3] && mesh[4] == ir20[4]
#
#    msh = load_gmsh("data/gmsh_v41_3d_verycoarse.msh")
#    xyz = reshape([msh.nodes.vx; msh.nodes.vy; msh.nodes.vz;], length(msh.nodes.vx), 3)
#    N, T = size(xyz, 2), eltype(xyz)
#    locs =  VecAttrib([SVector{N,T}(xyz[i, :]) for i in 1:size(xyz, 1)])
#    vrts = ShapeColl(P1, length(locs), "vertices")
#    vrts.attributes["geom"] = locs
#    shapes = ShapeColl(T4, size(msh.elements.nodeTags3D, 1), "elements")
#    ir30 = IncRel(shapes, vrts, msh.elements.nodeTags3D)
#
#    mesh = import_gmsh("data/gmsh_v41_3d_verycoarse.msh")
#    @test mesh._v == ir30._v && mesh[1] == ir30[1] && mesh[2] == ir30[2] && mesh[3] == ir30[3] && mesh[4] == ir30[4]
#end

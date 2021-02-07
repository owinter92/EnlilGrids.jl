@testset "load_gmsh_file" begin
    @test_throws ErrorException("File a does not exist.") load_gmsh_file("a")
    @test_throws ErrorException("Gmsh mesh file format saved in binary mode. Please convert to ASCII mode.") load_gmsh_file("data/gmsh_v41_1_bin.msh")

    msh=(msh_version = "4.1",
         raw_PhysicalNames = ["5", "1 1 Top", "1 2 Right", "1 3 Bottom", "1 4 Left", "2 5 Fluid"],
         raw_Entities = SubString{String}["4 4 1 0", "0 0 0 0 0 ", "1 1 0 0 0 ", "2 1 1 0 0 ", "3 0 1 0 0 ", "1 0 0 0 1 0 0 1 3 2 0 -1 ", "2 1 0 0 1 1 0 1 2 2 1 -2 ", "3 0 1 0 1 1 0 1 1 2 2 -3 ", "4 0 0 0 0 1 0 1 4 2 3 0 ", "1 0 0 0 1 1 0 1 5 4 4 1 2 3 "],
         raw_Nodes = SubString{String}["9 5 1 5", "0 0 0 1", "1", "0 0 0", "0 1 0 1", "2", "1 0 0", "0 2 0 1", "3", "1 1 0", "0 3 0 1", "4", "0 1 0", "1 1 0 0", "1 2 0 0", "1 3 0 0", "1 4 0 0", "2 1 0 1", "5", "0.5 0.5 0"],
         raw_Elements = SubString{String}["5 8 1 8", "1 1 1 1", "1 1 2 ", "1 2 1 1", "2 2 3 ", "1 3 1 1", "3 3 4 ", "1 4 1 1", "4 4 1 ", "2 1 2 4", "5 1 2 5 ", "6 4 1 5 ", "7 2 3 5 ", "8 3 4 5 "])
    @test load_gmsh_file("data/gmsh_v41_1.msh") == msh
end

@testset "gmsh_do_physicalnames" begin
    msh=load_gmsh_file("data/gmsh_v41_1.msh")
    physicalTagtoName=(physicalTag1DtoName = Dict(4 => "Left",2 => "Right",3 => "Bottom",1 => "Top"), physicalTag2DtoName = Dict(5 => "Fluid"), physicalTag3DtoName = Dict{Int64,String}())
    @test gmsh_do_physicalnames(msh[:raw_PhysicalNames]) == physicalTagtoName
end

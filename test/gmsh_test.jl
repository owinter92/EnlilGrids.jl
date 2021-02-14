@testset "load_gmsh_file" begin
    @test_throws ErrorException("File a does not exist.") load_gmsh_file("a")
    @test_throws ErrorException("Gmsh mesh file format saved in binary mode. Please convert to ASCII mode.") load_gmsh_file("data/gmsh_v41_3d_verycoarse_bin.msh")

    msh = (msh_version = "4.1",
           raw_PhysicalNames = ["27", "0 1 Point0", "0 2 Point1", "0 3 Point2", "0 4 Point3", "0 5 Point4", "0 6 Point5", "0 7 Point6", "0 8 Point7", "1 9 Line1", "1 10 Line2", "1 11 Line3", "1 12 Line4", "1 13 Line5", "1 14 Line6", "1 15 Line7", "1 16 Line8", "1 17 Line9", "1 18 Line10", "1 19 Line11", "1 20 Line12", "2 21 Surface1", "2 22 Surface2", "2 23 Surface3", "2 24 Surface4", "2 25 Surface5", "2 26 Surface6", "3 27 Volume1"],
           raw_Entities = SubString{String}["8 12 6 1", "0 0 0 0 1 0 ", "1 1 0 0 1 2 ", "2 1 1 0 1 3 ", "3 0 1 0 1 4 ", "4 0 0 1 1 5 ", "5 1 0 1 1 6 ", "6 1 1 1 1 7 ", "7 0 1 1 1 8 ", "1 0 0 0 1 0 0 1 9 2 0 -1 ", "2 1 0 0 1 1 0 1 10 2 1 -2 ", "3 0 1 0 1 1 0 1 11 2 2 -3 ", "4 0 0 0 0 1 0 1 12 2 3 0 ", "5 0 0 1 1 0 1 1 13 2 4 -5 ", "6 1 0 1 1 1 1 1 14 2 5 -6 ", "7 0 1 1 1 1 1 1 15 2 6 -7 ", "8 0 0 1 0 1 1 1 16 2 7 -4 ", "9 0 0 0 0 0 1 1 17 2 0 -4 ", "10 1 0 0 1 0 1 1 18 2 1 -5 ", "11 1 1 0 1 1 1 1 19 2 2 -6 ", "12 0 1 0 0 1 1 1 20 2 3 -7 ", "1 0 0 0 1 1 0 1 21 4 1 2 3 4 ", "2 0 0 1 1 1 1 1 22 4 5 6 7 8 ", "3 0 0 0 1 0 1 1 23 4 1 10 -5 -9 ", "4 1 0 0 1 1 1 1 24 4 2 11 -6 -10 ", "5 0 1 0 1 1 1 1 25 4 3 12 -7 -11 ", "6 0 0 0 0 1 1 1 26 4 4 9 -8 -12 ", "1 0 0 0 1 1 1 1 27 6 2 3 1 4 5 6 "],
           raw_Nodes = SubString{String}["27 14 1 14", "0 0 0 1", "1", "0 0 0", "0 1 0 1", "2", "1 0 0", "0 2 0 1", "3", "1 1 0", "0 3 0 1", "4", "0 1 0", "0 4 0 1", "5", "0 0 1", "0 5 0 1", "6", "1 0 1", "0 6 0 1", "7", "1 1 1", "0 7 0 1", "8", "0 1 1", "1 1 0 0", "1 2 0 0", "1 3 0 0", "1 4 0 0", "1 5 0 0", "1 6 0 0", "1 7 0 0", "1 8 0 0", "1 9 0 0", "1 10 0 0", "1 11 0 0", "1 12 0 0", "2 1 0 1", "9", "0.5 0.5 0", "2 2 0 1", "10", "0.5 0.5 1", "2 3 0 1", "11", "0.5 0 0.5", "2 4 0 1", "12", "1 0.5 0.5", "2 5 0 1", "13", "0.5 1 0.5", "2 6 0 1", "14", "0 0.5 0.5", "3 1 0 0"],
           raw_Elements = SubString{String}["27 68 1 68", "0 0 15 1", "1 1 ", "0 1 15 1", "2 2 ", "0 2 15 1", "3 3 ", "0 3 15 1", "4 4 ", "0 4 15 1", "5 5 ", "0 5 15 1", "6 6 ", "0 6 15 1", "7 7 ", "0 7 15 1", "8 8 ", "1 1 1 1", "9 1 2 ", "1 2 1 1", "10 2 3 ", "1 3 1 1", "11 3 4 ", "1 4 1 1", "12 4 1 ", "1 5 1 1", "13 5 6 ", "1 6 1 1", "14 6 7 ", "1 7 1 1", "15 7 8 ", "1 8 1 1", "16 8 5 ", "1 9 1 1", "17 1 5 ", "1 10 1 1", "18 2 6 ", "1 11 1 1", "19 3 7 ", "1 12 1 1", "20 4 8 ", "2 1 2 4", "21 1 2 9 ", "22 4 1 9 ", "23 2 3 9 ", "24 3 4 9 ", "2 2 2 4", "25 5 6 10 ", "26 8 5 10 ", "27 6 7 10 ", "28 7 8 10 ", "2 3 2 4", "29 1 2 11 ", "30 5 1 11 ", "31 2 6 11 ", "32 6 5 11 ", "2 4 2 4", "33 2 3 12 ", "34 6 2 12 ", "35 3 7 12 ", "36 7 6 12 ", "2 5 2 4", "37 3 4 13 ", "38 7 3 13 ", "39 4 8 13 ", "40 8 7 13 ", "2 6 2 4", "41 4 1 14 ", "42 1 5 14 ", "43 8 4 14 ", "44 5 8 14 ", "3 1 4 24", "45 12 9 14 13 ", "46 11 9 14 12 ", "47 14 10 11 12 ", "48 14 10 12 13 ", "49 14 5 1 11 ", "50 11 10 5 6 ", "51 8 5 14 10 ", "52 9 4 1 14 ", "53 14 4 8 13 ", "54 1 9 11 2 ", "55 3 4 9 13 ", "56 6 12 10 7 ", "57 10 8 7 13 ", "58 12 7 3 13 ", "59 11 12 6 2 ", "60 3 12 9 2 ", "61 1 9 14 11 ", "62 5 14 10 11 ", "63 10 14 8 13 ", "64 7 12 10 13 ", "65 9 4 14 13 ", "66 3 9 12 13 ", "67 10 11 12 6 ", "68 12 11 9 2 "])
    @test load_gmsh_file("data/gmsh_v41_3d_verycoarse.msh") == msh
end

@testset "gmsh_do_physicalnames" begin
    msh=load_gmsh_file("data/gmsh_v41_3d_verycoarse.msh")
    physicalTagtoName=(physicalTag1DtoName = Dict(16 => "Line8",11 => "Line3",9 => "Line1",10 => "Line2",19 => "Line11",17 => "Line9",20 => "Line12",13 => "Line5",14 => "Line6",15 => "Line7",12 => "Line4",18 => "Line10"),
                       physicalTag2DtoName = Dict(23 => "Surface3",26 => "Surface6",25 => "Surface5",21 => "Surface1",22 => "Surface2",24 => "Surface4"),
                       physicalTag3DtoName = Dict(27 => "Volume1")) 
    @test gmsh_do_physicalnames(msh[:raw_PhysicalNames]) == physicalTagtoName
end

@testset "gmsh_do_entities" begin
    msh=load_gmsh_file("data/gmsh_v41_3d_verycoarse.msh")
    entityTagtoPhysicalTag=(pointTagtoPhysicalTag = Dict(0 => 0,4 => 5,7 => 8,2 => 3,3 => 4,5 => 6,6 => 7,1 => 2),
                            curveTagtoPhysicalTag = Dict(2 => 10,11 => 19,7 => 15,9 => 17,10 => 18,8 => 16,6 => 14,4 => 12,3 => 11,5 => 13,12 => 20,1 => 9),
                            surfaceTagtoPhysicalTag = Dict(4 => 24,2 => 22,3 => 23,5 => 25,6 => 26,1 => 21),
                            volumeTagtoPhysicalTag = Dict(1 => 27))
    @test gmsh_do_entities(msh[:raw_Entities]) == entityTagtoPhysicalTag
end

@testset "gmsh_do_nodes" begin
    msh=load_gmsh_file("data/gmsh_v41_3d_verycoarse.msh")
    nodes=(nodeTag = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
           vx = [0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.5, 0.5, 0.5, 1.0, 0.5, 0.0],
           vy = [0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0.5, 0.0, 0.5, 1.0, 0.5],
           vz = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.5, 0.5, 0.5, 0.5])
    @test gmsh_do_nodes(msh[:raw_Nodes]) == nodes
end

@testset "gmsh_do_elements" begin
    msh=load_gmsh_file("data/gmsh_v41_3d_verycoarse.msh")
    elements=(entityTag1D = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
              entityTag2D = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6],
              entityTag3D = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
              elementType1D = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
              elementType2D = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
              elementType3D = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
              elementTag1D = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
              elementTag2D = [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44],
              elementTag3D = [45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68],
              nodeTags1D = [[1, 2], [2, 3], [3, 4], [4, 1], [5, 6], [6, 7], [7, 8], [8, 5], [1, 5], [2, 6], [3, 7], [4, 8]],
              nodeTags2D = [[1, 2, 9], [4, 1, 9], [2, 3, 9], [3, 4, 9], [5, 6, 10], [8, 5, 10], [6, 7, 10], [7, 8, 10], [1, 2, 11], [5, 1, 11], [2, 6, 11], [6, 5, 11], [2, 3, 12], [6, 2, 12], [3, 7, 12], [7, 6, 12], [3, 4, 13], [7, 3, 13], [4, 8, 13], [8, 7, 13], [4, 1, 14], [1, 5, 14], [8, 4, 14], [5, 8, 14]],
              nodeTags3D = [[12, 9, 14, 13], [11, 9, 14, 12], [14, 10, 11, 12], [14, 10, 12, 13], [14, 5, 1, 11], [11, 10, 5, 6], [8, 5, 14, 10], [9, 4, 1, 14], [14, 4, 8, 13], [1, 9, 11, 2], [3, 4, 9, 13], [6, 12, 10, 7], [10, 8, 7, 13], [12, 7, 3, 13], [11, 12, 6, 2], [3, 12, 9, 2], [1, 9, 14, 11], [5, 14, 10, 11], [10, 14, 8, 13], [7, 12, 10, 13], [9, 4, 14, 13], [3, 9, 12, 13], [10, 11, 12, 6], [12, 11, 9, 2]])
    @test gmsh_do_elements(msh[:raw_Elements]) == elements
end

@testset "load_gmsh" begin
    msh = (physicalTagtoName = (physicalTag1DtoName = Dict(4 => "Line4",2 => "Line2",3 => "Line3",1 => "Line1"),
           physicalTag2DtoName = Dict(5 => "Surface1"), physicalTag3DtoName = Dict{Int64,String}()),
           tagToPhysicalTag = (pointTagtoPhysicalTag = Dict{Int64,Int64}(),
           curveTagtoPhysicalTag = Dict(4 => 4,2 => 2,3 => 3,1 => 1),
           surfaceTagtoPhysicalTag = Dict(1 => 5),
           volumeTagtoPhysicalTag = Dict{Int64,Int64}()),
           nodes = (nodeTag = [1, 2, 3, 4, 5], vx = [0.0, 1.0, 1.0, 0.0, 0.5], vy = [0.0, 0.0, 1.0, 1.0, 0.5], vz = [0.0, 0.0, 0.0, 0.0, 0.0]),
           elements = (entityTag1D = [1, 2, 3, 4], entityTag2D = [1, 1, 1, 1], entityTag3D = Int64[], elementType1D = [1, 1, 1, 1], elementType2D = [2, 2, 2, 2], elementType3D = Int64[], elementTag1D = [1, 2, 3, 4], elementTag2D = [5, 6, 7, 8], elementTag3D = Int64[], nodeTags1D = [[1, 2], [2, 3], [3, 4], [4, 1]], nodeTags2D = [[1, 2, 5], [4, 1, 5], [2, 3, 5], [3, 4, 5]], nodeTags3D = Array{Int64,1}[]))
    @test load_gmsh("data/gmsh_v41_2d_verycoarse.msh") == msh
end

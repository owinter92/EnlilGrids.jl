"""
    load_gmsh_file(filename::AbstractString) -> NamedTuple

Loads `filename` into separete arrays according to the gmsh file format
style in ASCII mode.

# Arguments
- `filename::AbstractString`: name of the file to be loaded,

# Keywords

# Returns
- `NamedTuple`: gmsh file is separated into the arrays of substring:
    - msh_version - constains infomartion about gmsh file version,
    - msh_PhysicalNames - constains data about physical objects,
    - msh_Entities - constains data about entities,
    - msh_Nodes - constains data about nodes including coordinates,
    - msh_Elements - constains data about elements,

# Throws
- `Error`: file with name `filename` does not exists,
- `Error`: file with name `filename` is saved in binary mode.
"""
function load_gmsh_file(filename::AbstractString)
    if !isfile(filename)
        error("File $(filename) does not exist.")
    end
    msh = load_file_line_by_line(filename)

    iMeshFormat = findfirst(x -> x == "\$MeshFormat", msh)
    iEndMeshFormat = findfirst(x -> x == "\$EndMeshFormat", msh)
    raw_MeshFormat = msh[iMeshFormat + 1]
    msh_version, msh_filetype, msh_datasize = split(raw_MeshFormat)
    if msh_filetype == "1"
        error("Gmsh mesh file format saved in binary mode. Please convert to ASCII mode.")
    end

    iPhysicalNames = findfirst(x -> x == "\$PhysicalNames", msh)
    iEndPhysicalNames = findfirst(x -> x == "\$EndPhysicalNames", msh)
    raw_PhysicalNames = SubString{String}[]
    if iPhysicalNames != nothing
        raw_PhysicalNames = msh[(iPhysicalNames + 1):(iEndPhysicalNames - 1)]
        raw_PhysicalNames = [replace(v, "\"" => "") for v in raw_PhysicalNames]
    end

    iEntities = findfirst(x -> x == "\$Entities", msh)
    iEndEntities = findfirst(x -> x == "\$EndEntities", msh)
    raw_Entities = msh[(iEntities + 1):(iEndEntities - 1)]

    iNodes = findfirst(x -> x == "\$Nodes", msh)
    iEndNodes = findfirst(x -> x == "\$EndNodes", msh)
    raw_Nodes = msh[(iNodes + 1):(iEndNodes - 1)]

    iElements = findfirst(x -> x == "\$Elements", msh)
    iEndElements = findfirst(x -> x == "\$EndElements", msh)
    raw_Elements = msh[(iElements + 1):(iEndElements - 1)]

    return (
        msh_version=msh_version,
        raw_PhysicalNames=raw_PhysicalNames,
        raw_Entities=raw_Entities,
        raw_Nodes=raw_Nodes,
        raw_Elements=raw_Elements,
    )
end

"""
    gmsh_do_physicalnames(raw_PhysicalNames) -> NamedTuple

Split `raw_PhysicalNames` created by [`load_gmsh_file`](@ref) in to one `Dict` for each
dimension.

# Arguments
- `raw_PhysicalNames`: data about physical names in gmsh file,

# Keywords

# Returns
- `NamedTuple`: one `Dict{Int,String}` for each dimension, `physicalTag => Name`:
    - physicalTag1DtoName,
    - physicalTag2DtoName,
    - physicalTag3DtoName.

# Throws
"""
function gmsh_do_physicalnames(raw_PhysicalNames)
    n = parse(Int, raw_PhysicalNames[1])

    physicalTag1DtoName = Dict{Int,String}()
    physicalTag2DtoName = Dict{Int,String}()
    physicalTag3DtoName = Dict{Int,String}()
    for i in 2:length(raw_PhysicalNames)
        s = split(raw_PhysicalNames[i])
        if s[1] == "1"
            physicalTag1DtoName[parse(Int, s[2])] = s[3]
        elseif s[1] == "2"
            physicalTag2DtoName[parse(Int, s[2])] = s[3]
        elseif s[1] == "3"
            physicalTag3DtoName[parse(Int, s[2])] = s[3]
        end
    end

    return (
        physicalTag1DtoName=physicalTag1DtoName,
        physicalTag2DtoName=physicalTag2DtoName,
        physicalTag3DtoName=physicalTag3DtoName,
    )
end

"""
    gmsh_do_entities(raw_Entities) -> NamedTuple

Split `raw_Entities` created by [`load_gmsh_file`](@ref) in to one `Dict` for each type of
entity. Operates with only one physicalTag per entity.

# Arguments
- `raw_Entities`: data about entities in gmsh file,

# Keywords

# Returns
- `NamedTuple`: one `Dict{Int,String}` for each dimension, `entityTag => physicalTag`:
    - pointTagtoPhysicalTag,
    - curveTagtoPhysicalTag,
    - surfaceTagtoPhysicalTag,
    - volumeTagtoPhysicalTag.

# Throws
"""
function gmsh_do_entities(raw_Entities)
    numPoints,
        numCurves,
        numSurfaces,
        numVolumes = (parse(Int, v) for v in split(raw_Entities[1]))

    pointTagtoPhysicalTag = Dict{Int,Int}()
    curveTagtoPhysicalTag = Dict{Int,Int}()
    surfaceTagtoPhysicalTag = Dict{Int,Int}()
    volumeTagtoPhysicalTag = Dict{Int,Int}()

    if numPoints != 0
        for i in 2:(1 + numPoints)
            s = split(raw_Entities[i])
            if parse(Int, s[5]) != 0
                pointTagtoPhysicalTag[parse(Int, s[1])] = parse(Int, s[6])
            end
        end
    end

    if numCurves != 0
        for i in (2 + numPoints):(1 + numPoints + numCurves)
            s = split(raw_Entities[i])
            if parse(Int, s[8]) != 0
                curveTagtoPhysicalTag[parse(Int, s[1])] = parse(Int, s[9])
            end
        end
    end

    if numSurfaces != 0
        for i in (2 + numPoints + numCurves):(1 + numPoints + numCurves + numSurfaces)
            s = split(raw_Entities[i])
            if parse(Int, s[8]) != 0
                surfaceTagtoPhysicalTag[parse(Int, s[1])] = parse(Int, s[9])
            end
        end
    end

    if numVolumes != 0
        i_start = (2 + numPoints + numCurves + numSurfaces)
        i_end = (1 + numPoints + numCurves + numSurfaces + numVolumes)
        for i in i_start:i_end
            s = split(raw_Entities[i])
            if parse(Int, s[8]) != 0
                volumeTagtoPhysicalTag[parse(Int, s[1])] = parse(Int, s[9])
            end
        end
    end

    return (
        pointTagtoPhysicalTag=pointTagtoPhysicalTag,
        curveTagtoPhysicalTag=curveTagtoPhysicalTag,
        surfaceTagtoPhysicalTag=surfaceTagtoPhysicalTag,
        volumeTagtoPhysicalTag=volumeTagtoPhysicalTag,
    )
end

"""
    gmsh_do_nodes(raw_Nodes) -> NamedTuple

Split `raw_Nodes` created by [`load_gmsh_file`](@ref). Operates with only non parametric
curves.

# Arguments
- `raw_Nodes`: data about nodes in gmsh file,

# Keywords

# Returns
- `NamedTuple`: one `Dict{Int,String}` for each dimension, `entityTag => physicalTag`:
    - nodeTag::Array{Int64,1},
    - vx::Array{Float64,1},
    - vy::Array{Float64,1},
    - vz::Array{Float64,1}.

# Throws
"""
function gmsh_do_nodes(raw_Nodes)
    numEntityBlocks,
        numNodes,
        minNodeTag,
        maxNodeTag = (parse(Int, v) for v in split(raw_Nodes[1]))

    nodeTag = Int[]
    sizehint!(nodeTag, length(raw_Nodes))
    vx = Float64[]
    sizehint!(vx, length(raw_Nodes))
    vy = Float64[]
    sizehint!(vy, length(raw_Nodes))
    vz = Float64[]
    sizehint!(vz, length(raw_Nodes))

    i = 2
    while i < length(raw_Nodes)
        entityDim,
            entityTag,
            parametric,
            numNodesInBlock = (parse(Int, v) for v in split(raw_Nodes[i]))
        i += 1

        for j in i:(i + numNodesInBlock - 1)
            push!(nodeTag, parse(Int, raw_Nodes[j]))
        end
        i += numNodesInBlock
        for j in i:(i + numNodesInBlock - 1)
            x, y, z = (parse(Float64, v) for v in split(raw_Nodes[j]))
            push!(vx, x)
            push!(vy, y)
            push!(vz, z)
        end
        i += numNodesInBlock
    end

    return (nodeTag=nodeTag, vx=vx, vy=vy, vz=vz)
end

"""
    gmsh_do_elements(raw_Elements) -> NamedTuple

Split `raw_Elements` created by [`load_gmsh_file`](@ref).

# Arguments
- `raw_Elements`: data about elements in gmsh file,

# Keywords

# Returns
- `NamedTuple`: one `Dict{Int,String}` for each dimension, `entityTag => physicalTag`:
    - entityTag1D   :: Array{Int64,1},
    - entityTag2D   :: Array{Int64,1},
    - entityTag3D   :: Array{Int64,1},
    - elementType1D :: Array{Int64,1},
    - elementType2D :: Array{Int64,1},
    - elementType3D :: Array{Int64,1},
    - elementTag1D  :: Array{Int64,1},
    - elementTag2D  :: Array{Int64,1},
    - elementTag3D  :: Array{Int64,1},
    - nodeTags1D    :: Array{Array{Int64,1},1},
    - nodeTags2D    :: Array{Array{Int64,1},1},
    - nodeTags3D    :: Array{Array{Int64,1},1}.

# Throws
"""
function gmsh_do_elements(raw_Elements)
    numEntityBlocks,
        numElements,
        minElementTag,
        maxElementTag = (parse(Int, v) for v in split(raw_Elements[1]))

    entityTag1D = Int[]
    entityTag2D = Int[]
    entityTag3D = Int[]

    elementType1D = Int[]
    elementType2D = Int[]
    elementType3D = Int[]

    elementTag1D = Int[]
    elementTag2D = Int[]
    elementTag3D = Int[]

    nodeTags1D = Array{Int,1}[]
    nodeTags2D = Array{Int,1}[]
    nodeTags3D = Array{Int,1}[]

    i = 2
    while i < length(raw_Elements)
        entityDim,
            entityTag,
            elementType,
            numElementsInBlock = (parse(Int, v) for v in split(raw_Elements[i]))
        i += 1

        for j in i:(i + numElementsInBlock - 1)
            if entityDim == 1
                push!(entityTag1D, entityTag)
                push!(elementType1D, elementType)
                s = [parse(Int, v) for v in split(raw_Elements[j])]
                push!(elementTag1D, s[1])
                push!(nodeTags1D, s[2:end])
            elseif entityDim == 2
                push!(entityTag2D, entityTag)
                push!(elementType2D, elementType)
                s = [parse(Int, v) for v in split(raw_Elements[j])]
                push!(elementTag2D, s[1])
                push!(nodeTags2D, s[2:end])
            elseif entityDim == 3
                push!(entityTag3D, entityTag)
                push!(elementType3D, elementType)
                s = [parse(Int, v) for v in split(raw_Elements[j])]
                push!(elementTag3D, s[1])
                push!(nodeTags3D, s[2:end])
            end
        end
        i += numElementsInBlock
    end

    return (
        entityTag1D=entityTag1D,
        entityTag2D=entityTag2D,
        entityTag3D=entityTag3D,
        elementType1D=elementType1D,
        elementType2D=elementType2D,
        elementType3D=elementType3D,
        elementTag1D=elementTag1D,
        elementTag2D=elementTag2D,
        elementTag3D=elementTag3D,
        nodeTags1D=nodeTags1D,
        nodeTags2D=nodeTags2D,
        nodeTags3D=nodeTags3D,
    )
end

"""
    load_gmsh(filename::AbstractString) -> NamedTuple

Loads `filename` into separete `Dict`s according to the gmsh file format
style in ASCII mode.

# Arguments
- `filename::AbstractString`: name of the file to be loaded,

# Keywords

# Returns
- `NamedTuple`: gmsh file is separated into the `Dict`s:
    - physicalTagtoName - see [`gmsh_do_physicalnames`](@ref),
    - tagToPhysicalTag - see [`gmsh_do_entities`](@ref),
    - nodes - see [`gmsh_do_nodes`](@ref),
    - elements - see [`gmsh_do_elements`](@ref).

# Throws
"""
function load_gmsh(filename::AbstractString)
    msh = load_gmsh_file(filename)
    physicalTagtoName = gmsh_do_physicalnames(msh[:raw_PhysicalNames])
    tagToPhysicalTag = gmsh_do_entities(msh[:raw_Entities])
    nodes = gmsh_do_nodes(msh[:raw_Nodes])
    elements = gmsh_do_elements(msh[:raw_Elements])

    return (
        physicalTagtoName=physicalTagtoName,
        tagToPhysicalTag=tagToPhysicalTag,
        nodes=nodes,
        elements=elements,
    )
end

"""
    import_gmsh(filename::AbstractString) -> ir(d,0)

Loads `filename` into incidence [`ir(d,0)`](@https://github.com/PetrKryslUCSD/MeshCore.jl).

# Arguments
- `filename::AbstractString`: name of the file to be loaded,

# Keywords

# Returns
- `ir(d,0)`: MeshCore's incidence.

# Throws
"""
function import_gmsh(filename::AbstractString)
    msh = load_gmsh(filename)

    function vertices(nodes)
        idxs = [rand(1:size(nodes.vz, 1)) for i in 1:10]
        if isapprox(sum(nodes.vz[idxs]), 0.0; atol=1e-10)
            xyz = reshape([nodes.vx; nodes.vy], length(nodes.vx), 2)
            return xyz
        else
            xyz = reshape([nodes.vx; nodes.vy; nodes.vz], length(nodes.vx), 3)
            return xyz
        end
    end
    function get_shapes(elements)
        GMSH_DESC = Dict{Int,String}(1 => "L2", 2 => "T3", 3 => "Q4", 4 => "T4", 5 => "Q8")
        if length(elements.elementTag3D) == 0
            shape = SHAPE_DESC[GMSH_DESC[elements.elementType2D[1]]]
            shapes = ShapeColl(shape, size(elements.nodeTags2D, 1), "elements")
            return shapes, elements.nodeTags2D
        else
            shape = SHAPE_DESC[GMSH_DESC[elements.elementType3D[1]]]
            shapes = ShapeColl(shape, size(elements.nodeTags3D, 1), "elements")
            return shapes, elements.nodeTags3D
        end
    end

    xyz = vertices(msh.nodes)
    N, T = size(xyz, 2), eltype(xyz)
    locs = VecAttrib([SVector{N,T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    vrts = ShapeColl(P1, length(locs), "vertices")
    vrts.attributes["geom"] = locs
    shapes, elements = get_shapes(msh.elements)

    return ird0 = IncRel(shapes, vrts, elements)
end

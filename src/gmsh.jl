"""
    load_gmsh_file(filename::AbstractString) -> NamedTuple

Loads the `filename` into separete arrays according to the gmsh file format style in ASCII mode.

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
    msh=load_file_line_by_line(filename)

    iMeshFormat=findfirst(x->x=="\$MeshFormat",msh)
    iEndMeshFormat=findfirst(x->x=="\$EndMeshFormat",msh)
    raw_MeshFormat=msh[iMeshFormat+1]
    msh_version, msh_filetype, msh_datasize = split(raw_MeshFormat)
    if msh_filetype == "1"
        error("Gmsh mesh file format saved in binary mode. Please convert to ASCII mode.")
    end

    iPhysicalNames=findfirst(x->x=="\$PhysicalNames",msh)
    iEndPhysicalNames=findfirst(x->x=="\$EndPhysicalNames",msh) 
    raw_PhysicalNames=msh[iPhysicalNames+1:iEndPhysicalNames-1]
    raw_PhysicalNames = [replace(v,"\""=>"") for v in raw_PhysicalNames]

    iEntities=findfirst(x->x=="\$Entities",msh)
    iEndEntities=findfirst(x->x=="\$EndEntities",msh)
    raw_Entities=msh[iEntities+1:iEndEntities-1]   

    iNodes=findfirst(x->x=="\$Nodes",msh)
    iEndNodes=findfirst(x->x=="\$EndNodes",msh)
    raw_Nodes=msh[iNodes+1:iEndNodes-1]   

    iElements=findfirst(x->x=="\$Elements",msh)
    iEndElements=findfirst(x->x=="\$EndElements",msh)
    raw_Elements=msh[iElements+1:iEndElements-1]

    return (msh_version=msh_version,
            raw_PhysicalNames=raw_PhysicalNames,
            raw_Entities=raw_Entities,
            raw_Nodes=raw_Nodes,
            raw_Elements=raw_Elements)
end

"""
    gmsh_do_physicalnames(raw_PhysicalNames) -> NamedTuple

Split `raw_PhysicalNames` created by [`load_gmsh_file`](@ref) in to one Dict for each dimension.

# Arguments
- `raw_PhysicalNames`: data about physical names in gmsh,

# Keywords

# Returns
- `NamedTuple`: one `Dict{Int,String}` for each dimension, `physicalTag => Name`: 
    - physicalTag1DtoName - maps physicalTag to Name for 1D objects,
    - physicalTag2DtoName - maps physicalTag to Name for 2D objects,
    - physicalTag3DtoName - maps physicalTag to Name for 3D objects,

# Throws
"""
function gmsh_do_physicalnames(raw_PhysicalNames)
    n=parse(Int,raw_PhysicalNames[1])

    physicalTag1DtoName=Dict{Int,String}()
    physicalTag2DtoName=Dict{Int,String}()
    physicalTag3DtoName=Dict{Int,String}()
    for i in 2:length(raw_PhysicalNames)
        s=split(raw_PhysicalNames[i])
        if s[1] == "1"
            physicalTag1DtoName[parse(Int,s[2])]=s[3]
        elseif s[1] == "2"
            physicalTag2DtoName[parse(Int,s[2])]=s[3]
        elseif s[1] == "3"
            physicalTag3DtoName[parse(Int,s[2])]=s[3]
        end
    end
    
    return (physicalTag1DtoName=physicalTag1DtoName,
            physicalTag2DtoName=physicalTag2DtoName,
            physicalTag3DtoName=physicalTag3DtoName)
end

"""
    gmsh_do_entities(raw_Entities) -> NamedTuple

Split `raw_Entities` created by [`load_gmsh_file`](@ref) in to one Dict for each type of entity. Operates with only one physicalTag per entity.

# Arguments
- `raw_Entities`: data about entities in gmsh,

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
    numPoints, numCurves, numSurfaces, numVolumes =
        (parse(Int,v) for v in split(raw_Entities[1]))
    
    pointTagtoPhysicalTag=Dict{Int,Int}()
    curveTagtoPhysicalTag=Dict{Int,Int}()
    surfaceTagtoPhysicalTag=Dict{Int,Int}()
    volumeTagtoPhysicalTag=Dict{Int,Int}()
    
    if numPoints != 0
        for i in 2:1+numPoints
            s=split(raw_Entities[i])
            if parse(Int,s[5]) != 0
                pointTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[6])
            end
        end
    end
    
    if numCurves != 0
        for i in 2+numPoints:1+numPoints+numCurves
            s=split(raw_Entities[i])
            if parse(Int,s[8]) != 0
                curveTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[9])
            end
        end
    end
    
    if numSurfaces != 0
        for i in 2+numPoints+numCurves:1+numPoints+numCurves+numSurfaces
            s=split(raw_Entities[i])
            if parse(Int,s[8]) != 0
                surfaceTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[9])
            end
        end
    end
    
    if numVolumes != 0
        for i in 2+numPoints+numCurves+numSurfaces:1+numPoints+numCurves+numSurfaces+numVolumes
            s=split(msh_Entities[i])
            if parse(Int,s[8]) != 0
                volumeTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[9])
            end
        end
    end
    
    return (pointTagtoPhysicalTag=pointTagtoPhysicalTag,
            curveTagtoPhysicalTag=curveTagtoPhysicalTag,
            surfaceTagtoPhysicalTag=surfaceTagtoPhysicalTag,
            volumeTagtoPhysicalTag=volumeTagtoPhysicalTag)
end

"""
no parametric
"""
function do_nodes!(msh)
    msh_Nodes=msh[:msh_Nodes]
    
    numEntityBlocks, numNodes, minNodeTag, maxNodeTag =
        (parse(Int,v) for v in split(popfirst!(msh_Nodes)))

    nodeTag=Int[]
    sizehint!(nodeTag,length(msh_Nodes))
    vx=Float64[]
    sizehint!(vx,length(msh_Nodes))
    vy=Float64[]
    sizehint!(vy,length(msh_Nodes))
    vz=Float64[]
    sizehint!(vz,length(msh_Nodes))

    i=1
    while i < length(msh_Nodes)
        entityDim, entityTag, parametric, numNodesInBlock =
            (parse(Int,v) for v in split(msh_Nodes[i]))
        i+=1

        for j in i:i+numNodesInBlock-1
            push!(nodeTag,parse(Int,msh_Nodes[j]))
        end
        i+=numNodesInBlock
        for j in i:i+numNodesInBlock-1
            x,y,z = (parse(Float64,v) for v in split(msh_Nodes[i]))
            push!(vx,x)
            push!(vy,y)
            push!(vz,z)
        end
        i+=numNodesInBlock
    end
    
    msh_Nodes=String[]
    
    return (nodeTag=nodeTag,
            vx=vx,
            vy=vy,
            vz=vz)
end

"""
general
"""
function do_elements!(msh)
    msh_Elements=msh[:msh_Elements]
    
    numEntityBlocks, numElements, minElementTag, maxElementTag =
        (parse(Int,v) for v in split(popfirst!(msh_Elements)))

    entityTag1D=Int[]
    entityTag2D=Int[]
    entityTag3D=Int[]
    
    elementType1D=Int[]
    elementType2D=Int[]
    elementType3D=Int[]
    
    elementTag1D=Int[]
    elementTag2D=Int[]
    elementTag3D=Int[]
    
    nodeTags1D=Array{Int,1}[]
    nodeTags2D=Array{Int,1}[]
    nodeTags3D=Array{Int,1}[]
    
    i=1
    while i<length(msh_Elements)
        entityDim, entityTag, elementType, numElementsInBlock =
            (parse(Int,v) for v in split(msh_Elements[i]))
        i+=1

        
        for j in i:i+numElementsInBlock-1
            if entityDim == 1
                push!(entityTag1D,entityTag)
                push!(elementType1D,elementType)
                s=[parse(Int,v) for v in split(msh_Elements[j])]
                push!(elementTag1D,s[1])
                push!(nodeTags1D,s[2:end])
            elseif entityDim == 2
                push!(entityTag2D,entityTag)
                push!(elementType2D,elementType)
                s=[parse(Int,v) for v in split(msh_Elements[j])]
                push!(elementTag2D,s[1])
                push!(nodeTags2D,s[2:end])
            elseif entityDim == 3
                push!(entityTag3D,entityTag)
                push!(elementType3D,elementType)
                s=[parse(Int,v) for v in split(msh_Elements[j])]
                push!(elementTag3D,s[1])
                push!(nodeTags3D,s[2:end])
            end
        end
        i+=numElementsInBlock
    end

    msh_Elements=String[]
    
    return (entityTag1D=entityTag1D,
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
            nodeTags3D=nodeTags3D)
end

"""
v 4.1
"""
function load_gmsh(filename::AbstractString)
    msh=load_gmsh_file(filename)
    physicalTagtoName=do_physicalnames!(msh)
    tagToPhysicalTag=do_entities!(msh)
    nodes=do_nodes!(msh)
    elements=do_elements!(msh)
end

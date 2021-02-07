"""
    load_gmsh_file(filename::AbstractString) -> NamedTuple

Loads the `filename` into separete arrays according to the gmsh file format style in ASCII mode.

# Arguments
- `filename::AbstractString`: name of the file to be loaded,

# Keywords

# Returns
- `NamedTuple`: the index where `val` is located in the `array`

# Throws
- `Error`: file with name `filename` does not exists.
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
            msh_PhysicalNames=raw_PhysicalNames,
            msh_Entities=raw_Entities,
            msh_Nodes=raw_Nodes,
            msh_Elements=raw_Elements)
end

"""
general
"""
function do_physicalnames!(msh)
    msh_PhysicalNames=msh[:msh_PhysicalNames]
    n=parse(Int,popfirst!(msh_PhysicalNames))
    
    physicalTag1DtoName=Dict{Int,String}()
    physicalTag2DtoName=Dict{Int,String}()
    physicalTag3DtoName=Dict{Int,String}()
    for v in msh_PhysicalNames
        s=split(v)
        if s[1] == "1"
            physicalTag1DtoName[parse(Int,s[2])]=s[3]
        elseif s[1] == "2"
            physicalTag2DtoName[parse(Int,s[2])]=s[3]
        elseif s[1] == "3"
            physicalTag3DtoName[parse(Int,s[2])]=s[3]
        end
    end
    
    msh_PhysicalNames=String[]
    
    return (physicalTag1DtoName=physicalTag1DtoName,
            physicalTag2DtoName=physicalTag2DtoName,
            physicalTag3DtoName=physicalTag3DtoName)
end

"""
not general
only one physicaltag per entity
"""
function do_entities!(msh)
    msh_Entities=msh[:msh_Entities]

    numPoints, numCurves, numSurfaces, numVolumes =
        (parse(Int,v) for v in split(popfirst!(msh_Entities)))
    
    
    pointTagtoPhysicalTag=Dict{Int,Int}()
    curveTagtoPhysicalTag=Dict{Int,Int}()
    surfaceTagtoPhysicalTag=Dict{Int,Int}()
    volumeTagtoPhysicalTag=Dict{Int,Int}()
    
    if numPoints != 0
        for i in 1:numPoints
            s=split(msh_Entities[i])
            if parse(Int,s[5]) != 0
                pointTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[6])
            end
        end
        deleteat!(msh_Entities,1:numPoints)
    end
    
    if numCurves != 0
        for i in 1:numCurves
            s=split(msh_Entities[i])
            if parse(Int,s[8]) != 0
                curveTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[9])
            end
        end
        deleteat!(msh_Entities,1:numCurves)
    end
    
    if numSurfaces != 0
        for i in 1:numSurfaces
            s=split(msh_Entities[i])
            if parse(Int,s[8]) != 0
                surfaceTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[9])
            end
        end
        deleteat!(msh_Entities,1:numSurfaces)
    end
    
    if numVolumes != 0
        for i in 1:numVolumes
            s=split(msh_Entities[i])
            if parse(Int,s[8]) != 0
                volumeTagtoPhysicalTag[parse(Int,s[1])]=parse(Int,s[9])
            end
        end
        deleteat!(msh_Entities,1:numVolumes)
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

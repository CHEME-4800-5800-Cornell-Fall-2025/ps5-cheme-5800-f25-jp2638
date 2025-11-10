function _build(modeltype::Type{T}, data::NamedTuple) where T <: AbstractSimpleChoiceProblem
    
    # build an empty model
    model = modeltype();

    # if we have options, add them to the contract model -
    if (isempty(data) == false)
        for key ∈ fieldnames(modeltype)
            
            # check the for the key - if we have it, then grab this value
            value = nothing
            if (haskey(data, key) == true)
                # get the value -
                value = data[key]
            end

            # set -
            setproperty!(model, key, value)
        end
    end
 
    # return -
    return model
end
# --- PRIVATE API ABOVE HERE -------------------------------------------------------------------------------------- #


# --- PUBLIC API BELOW HERE --------------------------------------------------------------------------------------- #

# Wow! That is slick, how does it work?
build(model::Type{MySimpleCobbDouglasChoiceProblem}, data::NamedTuple)::MySimpleCobbDouglasChoiceProblem = _build(model, data);

"""
    build(model::Type{MyMDPProblemModel}, data::NamedTuple) -> MyMDPProblemModel

Builds a `MyMDPProblemModel` from a `NamedTuple`.

### Arguments
- `model::Type{MyMDPProblemModel}`: the model type to build
- `data::NamedTuple`: the data to use to build the model

The `data` `NamedTuple` must contain the following keys:
- `𝒮::Array{Int64,1}`: state space
- `𝒜::Array{Int64,1}`: action space
- `T::Union{Function, Array{Float64,3}}`: transition matrix of function
- `R::Union{Function, Array{Float64,2}}`: reward matrix or function
- `γ::Float64`: discount factor

### Returns
- `MyMDPProblemModel`: the built MDP problem model
"""
function build(model::Type{MyMDPProblemModel}, data::NamedTuple)::MyMDPProblemModel
    
    # build an empty model -
    m = model();

    # get data from the named tuple -
    haskey(data, :𝒮) == false ? m.𝒮 = Array{Int64,1}(undef,1) : m.𝒮 = data[:𝒮];
    haskey(data, :𝒜) == false ? m.𝒜 = Array{Int64,1}(undef,1) : m.𝒜 = data[:𝒜];
    haskey(data, :T) == false ? m.T = Array{Float64,3}(undef,1,1,1) : m.T = data[:T];
    haskey(data, :R) == false ? m.R = Array{Float64,2}(undef,1,1) : m.R = data[:R];
    haskey(data, :γ) == false ? m.γ = 0.1 : m.γ = data[:γ];
    
    # return -
    return m;
end

"""
    build(modeltype::Type{MyRectangularGridWorldModel}, data::NamedTuple) -> MyRectangularGridWorldModel

Builds a `MyRectangularGridWorldModel` from data in a `NamedTuple`.

### Arguments
- `modeltype::Type{MyRectangularGridWorldModel}`: the model type to build
- `data::NamedTuple`: the data to use to build the model

The `data` `NamedTuple` must contain the following keys:
- `nrows::Int`: number of rows in the grid
- `ncols::Int`: number of columns in the grid
- `rewards::Dict{Tuple{Int,Int},Float64}`: dictionary of state to reward mapping
- `defaultreward::Float64`: default reward value (optional)

### Returns
- `MyRectangularGridWorldModel`: a populated rectangular grid world model
"""
function build(modeltype::Type{MyRectangularGridWorldModel}, data::NamedTuple)::MyRectangularGridWorldModel

    # initialize and empty model -
    model = modeltype()

    # get the data -
    nrows = data[:nrows]
    ncols = data[:ncols]
    rewards = data[:rewards]
    defaultreward = haskey(data, :defaultreward) == false ? -1.0 : data[:defaultreward]

    # Initialize storage dictionaries for the grid world
    rewards_dict = Dict{Int,Float64}() # Maps state number to reward value
    coordinates = Dict{Int,Tuple{Int,Int}}() # Maps state number to (x,y) coordinates
    states = Dict{Tuple{Int,Int},Int}() # Maps (x,y) coordinates to state number
    moves = Dict{Int,Tuple{Int,Int}}() # Maps action number to movement vector
    
    # Initialize state counter for numbering grid cells
    state_counter = 1

    # Populate the dictionaries with state mappings
    for i in 1:nrows
        for j in 1:ncols
            # map coordinates to state number and vice versa
            coordinates[state_counter] = (i,j)
            states[(i,j)] = state_counter
            
            # setup rewards
            coord_key = (i,j)
            if haskey(rewards, coord_key)
                rewards_dict[state_counter] = rewards[coord_key]
            else
                rewards_dict[state_counter] = defaultreward
            end
            
            state_counter += 1
        end
    end

        # Define possible movement vectors for each action
    # Action 1: Move up (decrease row)
    # Action 2: Move right (increase column)
    # Action 3: Move down (increase row)
    # Action 4: Move left (decrease column)
    moves[1] = (-1,0)  # up: decrease row
    moves[2] = (0,1)   # right: increase column
    moves[3] = (1,0)   # down: increase row
    moves[4] = (0,-1)  # left: decrease column

    # Populate model with computed data
    model.number_of_rows = nrows
    model.number_of_cols = ncols
    model.coordinates = coordinates
    model.states = states
    model.moves = moves
    model.rewards = rewards_dict

    # return the model
    return model
end

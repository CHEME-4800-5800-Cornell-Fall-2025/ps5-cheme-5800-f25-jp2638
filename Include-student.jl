# setup paths -
const _ROOT = @__DIR__
const _PATH_TO_SRC = joinpath(_ROOT, "src");

# check: do we need to download any packages?
using Pkg
if (isfile(joinpath(_ROOT, "Manifest.toml")) == false) # have manifest file, we are good. Otherwise, we need to instantiate the environment
    Pkg.add(path="https://github.com/varnerlab/VLDataScienceMachineLearningPackage.jl.git")
    Pkg.add("MadNLP")
    Pkg.add("JuMP")
    Pkg.add("Distributions")
    Pkg.add("Plots")
    Pkg.add("Colors")
    Pkg.add("DataFrames")
    Pkg.add("PrettyTables")
    Pkg.activate("."); Pkg.resolve(); Pkg.instantiate(); Pkg.update();
end

# load the required packages -
using MadNLP
using JuMP
using Distributions
using Plots
using Colors
using LinearAlgebra
using Statistics
using DataFrames
using PrettyTables
using Random

# Solution type
mutable struct MyValueIterationSolution
    problem::MyMDPProblemModel
    U::Array{Float64,1}
end

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"));
include(joinpath(_PATH_TO_SRC, "Factory.jl"));
include(joinpath(_PATH_TO_SRC, "Compute.jl"));
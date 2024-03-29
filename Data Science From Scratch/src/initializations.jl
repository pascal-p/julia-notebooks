module Initializations

using Random, Distributions

export init_rand_normal, init_rand_uniform, init_xavier

## ======================================================================
## Initialization of a Layer
## ======================================================================

function init_rand_normal(shape::Tuple; seed=42, DT::DataType=Float64,
                          kwargs...)
  Random.seed!(seed)
  nd = Normal(haskey(kwargs, :μ) ? kwargs[:μ] : 0.,
    haskey(kwargs, :σ) ? kwargs[:σ] : 1.)
  DT == Float64 ? rand(nd, shape) : DT[rand(nd, shape)...]
end


function init_rand_uniform(shape::Tuple; seed=42, DT::DataType=Float64,
                           kwargs...)
  Random.seed!(seed)
  ud = Uniform(0., 1.)
  DT == Float64 ? rand(ud, shape) : DT[rand(ud, shape)...]
end

function init_xavier(shape::Tuple; seed=42, DT::DataType=Float64,
                     kwargs...)
  σ = length(shape) / sum(shape)
  init_rand_normal(shape; σ, seed, DT)
end

const INIT_FNs = [init_rand_normal, init_rand_uniform, init_xavier]

end  ## Module

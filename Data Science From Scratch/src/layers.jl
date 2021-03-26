module Layers

export Linear, Sequential, forward, backward, parms, ∇parms


include("./tensor_dt.jl")
using ..TensorDT: Tensor

include("./abstract_layers.jl")
import ..AbstractLayers: AbstractLayer, AL, forward, backward, parms, ∇parms

include("./initializations.jl")
using ..Initializations: init_xavier, INIT_FNs


## ======================================================================
## Linear (or Dense) Layer
## ======================================================================
struct Linear <: AbstractLayer
  idim::Integer   ## input dim
  odim::Integer   ## output dim
  ## parameters
  w::Tensor
  b::Tensor
  #
  _type::Symbol
  store::Dict # {Any. Any}

  ## Assume type is DT == Float64
  function Linear(idim::Integer, odim::Integer;
      DT=Float64, init_fn=init_xavier, seed=42, kwargs...)
    ##
    @assert 1 ≤ idim
    @assert 1 ≤ odim
    @assert init_fn ∈ INIT_FNs
    ##
    w = init_fn((odim, idim); seed, DT, kwargs...)
    b = zeros(DT, (odim, 1))
    new(idim, odim, w, b, :dense, Dict())
  end
end

# gen_key(self::Linear, prefix::Symbol) = Symbol(prefix, self._id[1])

function forward(self::Linear, input::Tensor)::Tensor
  self.store[:input] = input  ## Storing the input for backward pass
  self.w * input + self.b
end

function backward(self::Linear, ∇p::Tensor)::Tensor
  ## as each bᵢ is added to output oᵢ, ∇b is the same as output ∇
  self.store[:∇b] = ∇p
  self.store[:∇w] = ∇p * self.store[:input]'
  r = sum.(self.w' * ∇p)
  @assert(size(self.w) == size(self.store[:∇w]),
          "w and ∇w should have same shape: $(size(self.w)) == $(size(self.store[:∇w]))")
  @assert(size(self.b) == size(self.store[:∇b]),
          "b and ∇b should have same shape: $(size(self.b)) == $(size(self.store[:∇b]))")
  r
end

parms(self::Linear) = [self.w, self.b]
∇parms(self::Linear) = [self.store[:∇w], self.store[:∇b]]

## ======================================================================
## Neural Network as a sequence of Layers
## ======================================================================
struct Sequential <: AbstractLayer
  layers::Vector{AbstractLayer}
  _type::Symbol

  function Sequential(layers::Vector{AbstractLayer})
    @assert length(layers) > 0
    check_dim_layer(layers)
    #
    new(layers, :sequential)
  end
end

function forward(self::Sequential, input::Tensor)::Tensor
  for (ix, l) ∈ enumerate(self.layers)
    input = forward(l, input)
  end
  input
end

function backward(self::Sequential, ∇p::Tensor)::Tensor
  for (ix, l) ∈ enumerate(reverse(self.layers))
    ∇p = backward(l, ∇p)
  end
  ∇p
end

parms(self::Sequential) = [p for l ∈ self.layers for p ∈ parms(l)]
∇parms(self::Sequential) = [∇p for l ∈ self.layers for ∇p ∈ ∇parms(l)]


##
## Internal helpers
##

function check_dim_layer(layers::Vector{AbstractLayer})
  """
  output of prev. layer == input of curr layer
  """
  pl = layers[1]
  for cl ∈ layers[2:end]
    cl._type ∈ [:activation, :regularization] && continue
    pl.odim ≠ cl.idim && throw(ArgumentError("incompatible shape between pl.odim; $(pl.odim) vs cl.idim: $(cl.idim)"))
    pl = cl
  end
end

end ## Module

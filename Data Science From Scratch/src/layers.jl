module Layers

include("./tensor_dt.jl")
include("./abstract_layers.jl")
include("./initializations.jl")

using .AbstractLayers: AbstractLayer
using .TensorDT: Tensor
using .Initializations: init_xavier, INIT_FNs


## ======================================================================
## Linear (or Dense) Layer
## ======================================================================
struct Linear <: AbstractLayer
  idim::Integer   ## input dim
  odim::Integer   ## output dim

  ## parameters
  w::Tensor
  b::Tensor

  _type::Symbol
  store::Dict # {Any. Any}

  ## Assume type is DT == Float64
  function Linear(idim::Integer, odim::Integer;
      DT=Float64, init_fn=init_xavier, seed=42)
    ##
    ## would also need μ and σ as kwargs for normal init.
    @assert 1 ≤ idim
    @assert 1 ≤ odim
    @assert init_fn ∈ INIT_FNs
    ##
    w = init_fn((odim, idim); seed, DT)
    b = zeros(DT, (odim, 1))
    new(idim, odim, w, b, :dense, Dict())
  end
end

# gen_key(self::Linear, prefix::Symbol) = Symbol(prefix, self._id[1])

function forward(self::Linear, input::Tensor)::Tensor
  self.store[:input] = input  ## Storing the input for backward pass
  self.w * input + self.b
end

function backward(self::Linear, ∇::Tensor)::Tensor
  ## as each bᵢ is added to output oᵢ, ∇b is the same as output ∇
  self.store[:∇b] = ∇
  self.store[:∇w] = ∇ * self.store[:input]'
  r = sum.(self.w' * ∇)
  @assert(size(self.w) == size(self.store[:∇w]),
          "w and ∇w should have same shape: $(size(self.w)) == $(size(self.store[:∇w]))")
  @assert(size(self.b) == size(self.store[:∇b]),
          "b and ∇b should have same shape: $(size(self.b)) == $(size(self.store[:∇b]))")
  r
end

parms(self::Linear) = [self.w, self.b]
∇(self::Linear) = [self.store[:∇w], self.store[:∇b]]

## ======================================================================
## Neural Network as a sequence of Layers
## ======================================================================
struct Sequential <: AbstractLayer
  layers::Vector{AbstractLayer}
  _type::Symbol

  function Sequential(layers::Vector{AbstractLayer})
    ## output of prev. layer == input of curr layer
    @assert length(layers) > 0
    pl = layers[1]
    for cl ∈ layers[2:end]
      cl._type == :activation && continue
      @assert pl.odim == cl.idim
      pl = cl
    end

    new(layers, :sequential)
  end
end

function forward(self::Sequential, input::Tensor)::Tensor
  for (ix, l) ∈ enumerate(self.layers)
    input = forward(l, input)
  end
  input
end

function backward(self::Sequential, ∇::Tensor)::Tensor
  for (ix, l) ∈ enumerate(reverse(self.layers))
    ∇ = backward(l, ∇)
  end
  ∇
end

parms(self::Sequential) = [p for l ∈ self.layers for p ∈ parms(l)]
∇(self::Sequential) = [∇p for l ∈ self.layers for ∇p ∈ ∇(l)]

end

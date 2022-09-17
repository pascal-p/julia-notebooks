const DT = Float64

#
# Store a single scalar value and its gradient
#
mutable struct Value{T <: Real}
  data::T
  _prev::Set
  _op::Symbol
  _backward::Function
  label::String
  grad::T

  function Value{T}(data::T;
                    _children::Tuple=(),
                    _op::Symbol=:_,
                    label::String=""
                    ) where {T <: Real}
    grad = zero(T)
    _backward = () -> nothing # default to Nothing
    new{T}(data, Set(_children), _op, _backward, label, grad)
  end
end

# default constructor for Float64
function YaValue(data::T; _children::Tuple=(), _op::Symbol=:_, label::String="") where {T <: Real}
  Value{T}(data; _children, _op, label)
end

function Base.:+(self::Value{T}, other::Value{T}) where {T <: Real}
  y = YaValue(self.data + other.data; _children=(self, other), _op=:+)

  function _backward_fn()
    self.grad += 1.0 * y.grad
    other.grad += 1.0 * y.grad
  end

  y._backward = _backward_fn
  y
end

function Base.:*(self::Value{T}, other::Value{T}) where {T <: Real}
  y = YaValue(self.data * other.data; _children=(self, other), _op=:*)

  function _backward_fn()
    self.grad += other.data * y.grad
    other.grad += self.data * y.grad
  end

  y._backward = _backward_fn
  y
end

Base.show(io::IO, self::Value) = print(io, "Value(data=$(self.data))")

function Base.tanh(self::Value{T}) where {T <: Real}
  x = exp(2*self.data)
  tanh = (x - 1.) / (x + 1.)
  y = YaValue(tanh; _children=(self, ), _op=:tanh, label="tanh")

  function _backward_fn()
    self.grad += (1. - tanh^2) * y.grad
  end

  y._backward = _backward_fn
  y
end

function Base.exp(self::Value{T}) where {T <: Real}
  x = self.data
  y = YaValue(exp(x); _children=(self, ), _op=:exp, label="exp")

  function _backward_fn()
    self.grad += y.data * y.grad  # because ∂exp/∂x = exp
  end

  y._backward = _backward_fn
  y
end

function backward(self::Value{T}) where {T <: Real}
  topo, visited = [], Set()

  function build_topological_order(v::Value)
    if v ∉ visited
      push!(visited, v)
      for child ∈ v._prev
        build_topological_order(child)
      end
      push!(topo, v)
    end
  end

  self.grad = 1.0
  for cnode ∈ build_topological_order(self) |> reverse
    cnode._backward()
  end
end

# these two allow: promote(xr, r) where xr is Value{Float64} and r is Float64 => Value{Float64}
#                  promote(xi, i) where xi is Value{Int64} and i is Int64 => Value{Int64}
convert(::Type{Value{T}}, x::T) where {T <: Real} = Value{T}(x)
promote_rule(::Type{Value{T}}, ::Type{T}) where {T <: Real} = Value{T}

# Value{Float64} and Float32 => Value{Float64}
convert(::Type{Value{T}}, x::S) where {T <: Real, S <: AbstractFloat} = Value{T}(T(x))
promote_rule(::Type{Value{T}}, ::Type{S}) where {T <: Real, S <: AbstractFloat} = Value{T}

# Value{Float64} and Integer => Value{Float64}
convert(::Type{Value{T}}, x::S) where {T <: Real, S <: Integer} = Value{T}(T(x))
promote_rule(::Type{Value{T}}, ::Type{S}) where {T <: Real, S <: Integer} = Value{T}

convert(::Type{Value{T}}, x::Type{Value{S}}) where {T <: Real, S <: T} = Value{T}(T(x.data))
promote_rule(::Type{Value{T}}, ::Type{Value{S}}) where {T <: Real, S <: T} = Value{promote_type(T, S)}

##
## Extending operator for DataType Value{T}
##
for op ∈ (:+, :*)
  @eval begin
    ## Allowing:
    #   - Value{T} :op T  =>  Value{T}
    #   - T :op Value{T}  =>  Value{T}
    ($op)(self::Value{T}, other::T) where {T <: Real} = ($op)(self, Value{T}(other))
    ($op)(other::T, self::Value{T}) where {T <: Real} = ($op)(self, Value{T}(other))

    # Allowing Value{T} :op S =>  Value{T} where S <: T
    ($op)(self::Value{T}, other::S) where {T <: Real, S <: Integer} =
      ($op)(self, Value{T}(T(other)))
    ($op)(other::S, self::Value{T}) where {T <: Real, S <: Integer} =
      ($op)(self, Value{T}(T(other)))

    # Allowing Value{T} :op Value{S} =>  Value{T} where S <: T
    ($op)(self::Value{T}, other::Value{S}) where {T <: Real, S <: Real} =
      ($op)(self, Value{T}(T(other.data)))

    #($op)(other::Value{S}, self::Value{T}) where {T <: Real, S <: Real} =
    #  ($op)(self, Value{T}(T(other.data)))
  end
end

function Base.:^(self::Value{T}, p::T) where {T <: Real}
  y = YaValue(self.data^p; _children=(self, ), _op=:^, label="^p")
  function _backward_fn()
    self.grad += p * self.data^(p - 1) * y.grad # because ∂x^p/∂x = p x^(p -1 )
  end
  y._backward = _backward_fn
  y
end

# Allow for integer value for power
Base.:^(self::Value{T}, n::S) where {T <: Real, S <: Integer} = Base.:^(self, T(n))

Base.:-(self::Value{T}, other::Value{T}) where {T <: Real} = Base.:+(self, other * -1.)

Base.:-(self::Value{T}, other::S) where {T <: Real, S <: Real} = Base.:+(self, other * -1.)

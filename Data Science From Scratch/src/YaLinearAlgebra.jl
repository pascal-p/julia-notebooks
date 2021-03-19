module YaLinearAlgebra

import Base: +, -, *

export +, -, *, μ, dot, sum_of_square, norm,
  distance, shape, get_row, get_column, get_col, make_matrix

## Vector Portion

function +(v₁::Vector{T}, v₂::Vector{T})::Vector{T} where T <: Number
  """
  Vector Additon is component-wise
  """
  @assert length(v₁) == length(v₂)
  v₁ .+ v₂
end

function +(vc::Vector{Vector{T}})::Vector{T} where T <: Number
  """
  Sum all corresponding components of a collection of vector to return
  one vector
  """
  @assert length(vc) > 0 "expect the collection to have at leat one vector element"
  n = length(vc[1])
  @assert all(v -> length(v) == n, vc) "Expect all vectors to be of he same length"
  v = zeros(T, n)
  for v₀ ∈ vc
    v .+= v₀
  end
  v
end

function -(v₁::Vector{T}, v₂::Vector{T})::Vector{T} where T <: Number
  """
  Vector Additon is component-wise
  """
  @assert length(v₁) == length(v₂)
  v₁ .- v₂
end

*(x::T, v::Vector{T}) where T <: Number = v .* x
*(v::Vector{T}, x::T) where T <: Number = v .* x

function μ(vc::Vector{Vector{T}})::Vector{AbstractFloat} where T <: Number
  """Element-wise mean"""
  @assert length(vc) > 0
  n = length(vc[1])

  @assert all(v -> length(v) == n, vc)
  reduce(+, vc) / length(vc)
end

function dot(v₁::Vector{T}, v₂::Vector{T})::T where T <: Number
  @assert length(v₁) == length(v₂)
  sum(v₁ .* v₂)
end

function sum_of_square(v::Vector{T})::T where T <: Number
  """
  return vᵢ * vᵢ ∀ i ∈ 1:length(v)
  """
  dot(v, v)
end

function norm(v::Vector{T})::AbstractFloat where T <: Number
  √ sum(v .* v)
end

function distance(v₁::Vector{T}, v₂::Vector{T})::AbstractFloat where T <: Number
  """
  (Euclidean) distance(v₁, v₂) ≡ √(Σ (v₁ᵢ - v₂ᵢ)²)
  """
  @assert length(v₁) == length(v₂)
  √ sum((v₁ .- v₂).^2)  # == norm(v₁ .- v₂)
end

## Matrix Portion

function shape(m::Matrix{T})::Tuple{Integer, Integer} where T <: Number
  size(m)
end

function get_row(m::Matrix{T}, r::Integer)::Vector{T}  where T <: Number
  @assert 1 ≤ r ≤ size(m)[1]
  view(m, r, :)  ## no copy!
end

function get_column(m::Matrix{T}, c::Integer)::Vector{T}  where T <: Number
  @assert 1 ≤ c ≤ size(m)[2]
  view(m, :, c)  ## no copy!
end

get_col(m::Matrix{T}, c::Integer) where T <: Number = get_column(m, c)

function make_matrix(nrows::Integer, ncols::Integer, fn::Function;
    DT::DataType=Float64)::Matrix
  @assert 1 ≤ nrows && 1 ≤ ncols

  m = zeros(DT, (nrows, ncols))
  for c ∈ 1:ncols, r ∈ 1:nrows
    m[r, c] = fn(r, c)
  end
  m
end

end  ## YaLinearAlgebra

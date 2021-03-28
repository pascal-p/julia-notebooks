module YaWorkingData

using LinearAlgebra

export de_μ, directional_σ, ∇directional_σ,
  first_principal_component, pca, transform

const DT{T} = Vector{T} where {T <: Real}
const VDT{T} = Vector{DT{T}} where {T <: Real}

"""
Re-center to have mean 0. across all dim

```julia-repl
julia> de_μ([[1., 3., 2., 4.], [1., 3., 2., 4.]])
2-element Vector{Vector{Float64}}:
 [-1.5, 0.5, -0.5, 1.5]
 [-1.5, 0.5, -0.5, 1.5]
```
"""
function de_μ(data::VDT)::VDT
  """
  Re-center to have mean 0. across all dim
  """
  μ₀ = μ.(data)
  map(((d, μ)=t) -> d .- μ, zip(data, μ₀))
end


"""
Returns the variance of data in the direction of v
"""
function directional_σ(data::VDT, v::DT)::Float64
  dir_v = direction(v)
  sum(dot(u, dir_v) .^ 2 for u ∈ data)
end


function ∇directional_σ(data::VDT, v::DT)::DT
  """
  The gradient of directional variance with respect to v
  """
  v_dir = direction(v)
  sum(map(v -> 2 * dot(v, v_dir), data) .* data)
end


function first_principal_component(data::VDT, n::Integer=100, η=0.1)::DT
  # Start with a random guess
  guess = ones(eltype(data[1]), length(data[1]))
  for _ ∈ 1:n
    dσ = directional_σ(data, guess)
    ∇ = ∇directional_σ(data, guess)
    guess .+= ∇ * η
  end
  direction(guess)
end


function pca(data::VDT, ncomp::Integer)::VDT
  comps = VDT{eltype(data[1])}()
  for _ ∈ 1:ncomp
    comp = first_principal_component(data)
    push!(comps, comp)
    data = rm_project(data, comp)
  end
  comps
end


function transform(data::VDT, comps::VDT)::VDT
  transform_vect.(data, Ref(comps))
end


## Internals
"""
```julia-repl
julia> μ([1., 3., 2., 4.])
2.5
```
"""
function μ(data::DT)::Float64
  sum(data) / length(data)
end


function direction(v::DT)::DT
  v ./ norm(v)
end


function project(u::DT, v::DT)::DT
  """return the projection of u onto the direction v"""
  proj_len = dot(u, v)
  proj_len * v
end


function rm_project_from_vect(u::DT, v::DT)::DT
  """projects u onto v and subtracts the result from u"""
  u - project(u, v)
end


function rm_project(data::VDT, v::DT)::VDT
  rm_project_from_vect.(data, Ref(v))
end


function transform_vect(v::DT, comps::VDT)::DT
  dot.(Ref(v), comps)
end

end  # module

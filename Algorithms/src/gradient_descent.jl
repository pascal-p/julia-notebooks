using Statistics
using LinearAlgebra



"""
    ∇_descent(𝒟train, φ, ∇loss; η=0.1, T=100)

Perform stochastic gradient descent on a provided dataset `𝒟train`.
- `𝒟train`: The training dataset (X, y), X the matrix of input, y (a vector) representing the target (ground truth)
- `φ`:       The initial point or starting parameter values
- `∇loss`:   The gradient of the loss function to minimize
- `η`:       The learning rate (default 0.1)
- `N`:       The max number of iterations (default 100)

The function will return the updated values for φ.

Note:
  "𝒟" can be typed by \\scrD<tab>
  "φ" can be typed by \\varphi<tab>
"""
function ∇_descent(𝒟train, φ, ∇loss; η=0.1, N=100) # where T <: Number
  𝐰 = (φ(𝒟train[1][1]) |> length |> rand) # starting from any point in the parameter space
  for _ ∈ 1:N
    𝐰 .-= η * mean(∇loss(X, y, 𝐰, φ) for (X, y) ∈ 𝒟train)
  end
  𝐰
end

# function ∇_descent(𝒟train::AbstractVector{Tuple{T, T}}, φ, ∇loss; η=0.1, N=100) where T <: Number

# function ∇_descent(𝒟train::AbstractVector{Tuple{Vector{T}, T}}, φ, ∇loss; η=0.1, N=100) where T <: Number
#   𝐰 = φ(𝒟train[1][1]) |> length |> rand
#   for _ ∈ 1:N
#     𝐰 .-= η * mean(∇loss(X, y, 𝐰, φ) for (X, y) ∈ 𝒟train)
#   end
#   𝐰
# end


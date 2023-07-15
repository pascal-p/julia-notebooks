using Statistics
using LinearAlgebra
using Test

include("../src/gradient_descent.jl")

@testset "Gradient descent" begin

  mutable struct Decay i end

  Base.:*(δη::Decay, X) = X / √(δη.i += 1)

  # src. AI a modern approach
  loss_squared(X, y, 𝐰, φ) = (𝐰 ⋅ φ(X) - y)^2  # ⋅ == \cdot from Linear Algebra
  ∇loss_squared(X, y, 𝐰, φ) = -2 * (y - 𝐰 ⋅ φ(X)) * X
  μ_loss(𝐰, 𝒟train, φ, loss_fn) = mean(loss_fn(X, y, 𝐰, φ) for (X, y) ∈ 𝒟train)

  idₓ = x -> x

  """
  Single-dimensional training input data.
  """
  function test_gradient_descent()
    𝒟train = [(3, 4), (-1, 3), (-1, 0)]
    𝐰_opt = ∇_descent(𝒟train, idₓ, ∇loss_squared)
    y_opt = μ_loss(𝐰_opt, 𝒟train, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end

  """
         Multi-dimensional training data input.
  """
  function test_gradient_descent_multi()
    𝒟train = [([3., 0.7], 4.), ([-1., 0.3], 3.), ([-1., -3.], 0.)]
    𝐰_opt = ∇_descent(𝒟train, idₓ, ∇loss_squared)
    y_opt = μ_loss(𝐰_opt, 𝒟train, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end

  𝐰, y = test_gradient_descent()
  @test 𝐰 ≈ [0.8181818181818182]
  @test y ≈ 5.878787878787879


  𝐰, y = test_gradient_descent_multi()
  @test 𝐰 ≈ [0.8314306533883896, -0.03036191401505953]
  @test y ≈ 5.876487733786738
end

using Statistics
using LinearAlgebra
using Random
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

  𝒟train₀ = [([3., 0.7], 4.), ([-1., 0.3], 3.), ([-1., -3.], 0.)]

  """
  Single-dimensional training input data.
  """
  function test_∇_descent_basic()
    𝒟train = [(3, 4), (-1, 3), (-1, 0)]
    𝐰_opt = ∇_descent(𝒟train, idₓ, ∇loss_squared)
    y_opt = μ_loss(𝐰_opt, 𝒟train, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end

  """
  Multi-dimensional training data input.
  """
  function test_∇_descent_multi_basic()

    𝐰_opt = ∇_descent(𝒟train₀, idₓ, ∇loss_squared)
    y_opt = μ_loss(𝐰_opt, 𝒟train₀, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end

  """
  (again) Multi-dimensional training data input.
  """
  function test_stochastic_∇_descent_basic()
    𝐰_opt = stochastic_∇_descent(𝒟train₀, idₓ, ∇loss_squared; η=0.01)
    y_opt = μ_loss(𝐰_opt, 𝒟train₀, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end

  function test_stochastic_∇_descent(;η=0.01, N=1_000, seed=70)
    Random.seed!(seed)
    X = randn(100, 5)                                    # Create random dataset with 100 rows and 5 columns
    y = (idₓ.(X) * [5, 3, 1, 2, 4]) .+ randn(100) .* 0.1 # Create corresponding target value by adding random noise

    𝒟train = [(X[ix, :], y[ix]) for ix ∈ 1:size(X, 1)]
    𝐰_opt = stochastic_∇_descent(𝒟train, idₓ, ∇loss_squared; η=η, N=N)
    y_opt = μ_loss(𝐰_opt, 𝒟train, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end

  function test_minibatch_stochastic_∇_descent(;η=0.01, N=1_000, seed=70)
    Random.seed!(seed)
    X = randn(100, 5)                                     # Create random dataset with 100 rows and 5 columns
    y = (idₓ.(X) * [5, 3, 1, 2, 4]) .+ randn(100) .* 0.1  # Create corresponding target value by adding random noise in the dataset

    𝒟train = [(X[ix, :], y[ix]) for ix ∈ 1:size(X, 1)]
    𝐰_opt = minibatch_stochastic_∇_descent(𝒟train, idₓ, ∇loss_squared; η=η, N=N)
    y_opt = μ_loss(𝐰_opt, 𝒟train, idₓ, loss_squared)
    (𝐰_opt, y_opt)
  end


  𝐰, y = test_∇_descent_basic()
  @test 𝐰 ≈ [0.8181818181818182]
  @test y ≈ 5.878787878787879


  𝐰, y = test_∇_descent_multi_basic()
  @test 𝐰 ≈ [0.8314306533883896, -0.03036191401505953]
  @test y ≈ 5.876487733786738


  𝐰, y = test_stochastic_∇_descent_basic()
  @test 𝐰 ≈ [0.8286254042639639, -0.07376670863696766]
  @test y ≈ 5.8829223883616395

  ϵ = 1.e-6
  isapprox(a, b; rtol = ϵ, kwargs...) = Base.isapprox(a, b; rtol=rtol, kwargs...)


  𝐰, y = test_stochastic_∇_descent(N=10_000)
  @test 𝐰 ≈ [4.994195281768873, 2.9888364454480634, 0.9895028912070879, 1.998500451626844, 3.9940672737357628] # rtol = ϵ
  @test y ≈ 0.009403064501924843 # rtol = ϵ


  𝐰, y = test_minibatch_stochastic_∇_descent(N=10_000)
  @test 𝐰 ≈ [4.995754913210971, 2.9854258315124715, 0.9986456733903936, 1.987942491820608, 3.9987465936663265] rtol = ϵ
  @test y ≈0.009306890923146974 rtol = ϵ

end

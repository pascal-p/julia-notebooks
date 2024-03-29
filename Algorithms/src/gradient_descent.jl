using Statistics
using LinearAlgebra



"""
    ∇_descent(𝒟train, φ, ∇loss; η=0.1, T=100)

Perform gradient descent (GD) on a provided dataset `𝒟train`.
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
function ∇_descent(𝒟train, φ, ∇loss; η=0.1, N=100, seed=70)
  Random.seed!(seed)
  𝐰 = (φ(𝒟train[1][1]) |> length |> rand) # starting from any point in the parameter space
  for _ ∈ 1:N
    𝐰 .-= η * mean(∇loss(X, y, 𝐰, φ) for (X, y) ∈ 𝒟train)
  end
  𝐰
end

"""
    stochastic_∇_descent(𝒟train, φ, ∇loss; η=0.1, T=100)

Perform stochastic gradient descent (SGD) on a provided dataset `𝒟train`.
- `𝒟train`: The training dataset (X, y), X the matrix of input, y (a vector) representing the target (ground truth)
- `φ`:       The initial point or starting parameter values
- `∇loss`:   The gradient of the loss function to minimize
- `η`:       The learning rate (default 0.1)
- `N`:       The max number of iterations (default 100)

The function will return the updated values for φ.
"""
function stochastic_∇_descent(𝒟train, φ, ∇loss; η=0.1, N=500, seed=70)
  Random.seed!(seed)
  𝐰 = (φ(𝒟train[1][1]) |> length |> rand) # starting from any point in the parameter space
  for _ ∈ 1:N
    # make an update for each datapoint (the key difference between SGD and GD)
    for (X, y) ∈ 𝒟train
      𝐰 .-= η * ∇loss(X, y, 𝐰, φ)
    end
  end
  𝐰
end

function minibatch_stochastic_∇_descent(𝒟train, φ, ∇loss; η=0.1, N=500, seed=70, batch_size=16)
  Random.seed!(seed)
  𝐰 = (φ(𝒟train[1][1]) |> length |> rand) # starting from any point in the parameter space
  n_batches = size(𝒟train, 1) / batch_size |> x -> ceil(Int, x)

  for _ ∈ 1:N
    # make an update for a batch of datapoints
    for ix ∈ 0:(n_batches-1)
      batch = 𝒟train[(ix * batch_size + 1):min((ix + 1) * batch_size, end)]
      𝐰 .-= η * mean(∇loss(X, y, 𝐰, φ) for (X, y) ∈ batch)
    end
  end
  𝐰
end

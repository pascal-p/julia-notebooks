using MicroGrad
using Test

function forward_one_neuron()
  # 2 inputs
  x₁, x₂ = YaValue(2.0; label="x₁"), YaValue(0.0; label="x₂")
  # 2 weights
  w₁, w₂ = YaValue(-3.0; label="w₁"), YaValue(1.0; label="w₂")
  # bias
  b = YaValue(6.8813735870195432; label="b")

  x₁w₁ = x₁ * w₁; x₁w₁.label = "x₁×w₁"
  x₂w₂ = x₂ * w₂; x₂w₂.label = "x₂×w₂"
  x₁w₁x₂w₂ = x₁w₁ + x₂w₂; x₁w₁x₂w₂.label = "x₁×w₁ + x₂×w₂"
  n = x₁w₁x₂w₂ + b; n.label = "n"
  o = tanh(n); o.label = "output"

  (o, n, x₁w₁x₂w₂, x₁w₁, x₂w₂)
end

function topological_order(o::Value)
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
  build_topological_order(o)
end


@testset "MicroGrad.jl" begin
  @testset "basic" begin
    a = YaValue(2.0; label="a")
    b = YaValue(-3.0; label="b")
    c = YaValue(10.0; label="c")
    d = a * b; d.label = "d"
    e = d + c; e.label = "e"
    f = YaValue(-2.0; label="f")
    L = e * f; L.label="Output"

    @test a.data ≈ 2.0
    @test d.data ≈ a.data * b.data
    @test e.data ≈ d.data + c.data
    @test L.data ≈ e.data * f.data
  end

  @testset "gradient" begin
    ## Prep
    function try_grad()
      h = 0.001
      a = YaValue(2.0; label="a")
      b = YaValue(-3.0; label="b")
      c = YaValue(10.0; label="c")
      f = YaValue(-2.0; label="f")
      # compose
      d = a * b; d.label = "d"
      e = d + c; e.label = "e"
      L = e * f; L.label="Output"
      a₁ = YaValue(a.data; label="a")
      b₁ = YaValue(b.data; label="b")
      c₁ = YaValue(c.data; label="c")
      f₁ = YaValue(f.data; label="f")
      # compose
      d₁ = a₁ * b₁; d₁.label = "d"
      d₁.data += h
      e₁ = d₁ + c₁; e₁.label = "e"
      L₁ = e₁ * f₁; L₁.label="Output"
      # result Δh
      (L₁.data - L.data) / h
    end

    @test try_grad() ≈ -2.0
  end

  @testset "backprop - one neuron, manually"  begin
    # Prep
    (o, n, x₁w₁x₂w₂, x₁w₁, x₂w₂) = forward_one_neuron()

    # and now the backward pass
    o.grad = 1.0
    o._backward()
    n._backward()
    x₁w₁x₂w₂._backward()
    x₁w₁._backward()
    x₂w₂._backward()

    @test o.data ≈ 0.7071067811865476
  end

  @testset "backpop - auto" begin
    # Prep
    (o,) = forward_one_neuron()
    # and now the backward pass, using reverse order of the graph's topological order
    o.grad = 1.0
    for cnode ∈ topological_order(o) |> reverse
      cnode._backward()
    end

    @test o.data ≈ 0.7071067811865476
  end

  @testset "more operators" begin
    z₂ = YaValue(2.0)

    @test (2 * z₂).data ≈ 4.0
    @test (z₂ / YaValue(4.0)).data ≈ 0.5
    @test (z₂ - YaValue(5.0)).data ≈ -3.0
    @test (YaValue(5.0) - 2).data ≈ 3.0
  end
end

using MicroGrad
using Test

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

end

using Test

push!(LOAD_PATH, "./src")
using YaLinearAlgebra

@testset "Vector" begin
  vᵣ = [1.0, -1.0, π, ℯ]
  
  @testset ":+" begin
    @test +([1, 2, 3], [4, 5, 6]) == [5, 7, 9]
    @test [1, 2, 3] + [4, 5, 6] == [5, 7, 9]

    @test vᵣ + [-1.0, 1.0, -π, -ℯ] == zeros(eltype(vᵣ), length(vᵣ))
    @test +([[1, 2], [3, 4], [5, 6], [7, 8]]) == [16, 20]
    @test +([[1, 3, 2] for _ ∈ 1:3]) == [3, 9, 6]
  end

  @testset ":-" begin
    @test -([1, 2, 3], [4, 5, 6]) == [-3, -3, -3]
    @test [1, 2, 3] - [4, 5, 6] == [-3, -3, -3]
    @test vᵣ - [-1.0, 1.0, -π, -ℯ] == [2.0, -2.0, 2π, 2ℯ]
  end

  @testset ":*" begin
    @test *(2, [1, 2, 3]) == [2, 4, 6]
    @test *(2, [1, 2, 3]) == *([1, 2, 3], 2)
    @test 2 * [1, 2, 3] == [1, 2, 3] * 2  ==  [2, 4, 6]
  end

  @testset "μ" begin
    @test  μ([[1, 2], [3, 4], [5, 6]]) == [3., 4.]
    @test  μ([[1, 2, 1, 2], [3, 4, 3, 4], [5, 6, 5, 6]]) == [3., 4., 3., 4.]
  end
  
  @testset "dot, sum, norm, distance" begin
    @test dot([1, 2, 3], [4, 5, 6]) == 32

    @test sum_of_square([1, 2, 3]) == 14
    @test sum_of_square([4, 5, 6]) == 77

    @test norm([3, 4]) == 5
    @test norm([1, 0, 2]) ≈ √5
    
    @test distance([2, 6, 7, 7, 5, 13, 14, 17, 11, 8],

                   [3, 5, 5, 3, 7, 12, 13, 19, 22, 7]) ≈ 12.409673645990857
  end                   
end

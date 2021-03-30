push!(LOAD_PATH, "./src")

using Test
using YaDistances: cosine_similarity

@testset "Basic tests" begin
  @test cosine_similarity([1., 1, 1], [2., 2, 2]) ≈ 1. ## "same direction"
	@test cosine_similarity([-1., -1], [2., 2]) ≈ -1.    ## "opposite direction"
	@test cosine_similarity([1., 0], [0., 1]) ≈ 0.       ## "orthogonal"
end

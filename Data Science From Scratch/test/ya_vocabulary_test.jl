push!(LOAD_PATH, "./src")

using Pkg
Pkg.activate("MLJ_env", shared=true)

using Test
using YaVocabulary

@testset "Basics" begin
  vlst = ["B", "A", "G", "E", "A", "M", "P", "M"]
  vocab = Vocabulary(vlst)

  @test size(vocab) == (length ∘ unique)(vlst)
  @test get_id(vocab, "A") == 2
  @test one_hot_encode(vocab, "B") == [1., 0., 0., 0., 0., 0.]
  @test isnothing(get_id(vocab, "z"))
  @test get_word(vocab, 6) == "P"
  @test isnothing(get_word(vocab, 10))

  add(vocab, "Y")
  @test size(vocab) == (length ∘ unique)(vlst) + 1
  @test one_hot_encode(vocab, "B") == [1., 0., 0., 0., 0., 0., 0.]
  @test one_hot_encode(vocab, "Y") == [0., 0., 0., 0., 0., 0., 1.]
  @test isnothing(one_hot_encode(vocab, "z"))
end

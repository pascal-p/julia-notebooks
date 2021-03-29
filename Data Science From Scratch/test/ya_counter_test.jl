push!(LOAD_PATH, "./src")

using Test
using YaCounter

@testset "Counter of String" begin
  things = ["a", "bb" , "ac", "bb", "a", "b", "c"]
  things_cnt = Counter(things)

  @test things_cnt["a"] == 2
  @test things_cnt["bb"] == 2
  @test things_cnt["b"] == 1
  @test things_cnt["c"] == 1

  @test length(things_cnt) == 5
  @test sort(values(things_cnt)) == [1, 1, 1, 2, 2]

  @test_throws KeyError things_cnt["Zoo"]
end

@testset "Counter of Integers" begin
  things = [1, 2, 2, 2, 3, 4, 1, 2, 1, 4, 5, 1, 1, 0]
  things_cnt = Counter(things)

  @test things_cnt[1] == 5
  @test things_cnt[2] == 4
  @test things_cnt[3] == 1
  @test things_cnt[4] == 2
  @test things_cnt[5] == 1
  @test things_cnt[0] == 1

  @test length(things_cnt) == 6
  @test sort(values(things_cnt)) == [1, 1, 1, 2, 4, 5]

  @test eltype(things_cnt) == Pair{Int64, Integer}

  @test_throws KeyError things_cnt[70]
end

@testset "Counter of Integers / with no key exception" begin
  things = [1, 2, 2, 2, 3, 4, 1, 2, 1, 4, 5, 1, 1, 0]
  things_cnt = Counter(things;
                       nokey_exception=false, defval=-1)

  @test things_cnt[70] == -1  ## that key does not exist
end

@testset "Counter Vector of BitVector" begin
  bv = BitVector[[1, 1, 1, 1], [0, 0, 0, 1, 1], [1, 1, 0, 1, 0]]
  things_cnt = Counter(bv)
  thing_cnt = Counter(bv[1])

  @test length(things_cnt) == 3
  @test eltype(things_cnt) == Pair{BitVector, Integer}

  @test length(thing_cnt) == 1
  @test length(thing_cnt[1]) == 1
end

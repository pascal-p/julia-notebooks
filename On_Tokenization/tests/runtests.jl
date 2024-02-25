using Test

include("../minbpe/basic.jl")

@testset "encode/decode" begin
  test_strings = [
    "", # empty string
    "?", # single character
    "hello world!!!? (こにちは) lol123 😉", # fun small string
    # "FILE:taylorswift.txt", # FILE: is handled as a special string in unpack()
  ]

  tokenizer = BasicTokenizer()
  for str ∈test_strings
    # @test (tokenizer.decode ∘  tokenizer.encode)(str) == str
    @test decode(tokenizer, encode(tokenizer, str)) == str
  end

end

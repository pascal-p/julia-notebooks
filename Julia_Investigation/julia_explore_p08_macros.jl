### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ 2e0f805a-68d3-11eb-35c6-95c237883fcd
using PlutoUI

# ╔═╡ e5eee32e-68de-11eb-3267-33a033f1dab1
begin
  using Printf

  macro timeit(expr)
    quote
      local t₀ = time()         ## avoid poluting client env.
      local res = $(esc(expr))  ## eval. expr
      local dt = time() - t₀
      print("Ellapsed time: ")
      @printf("%.9f\n", dt)

      res                       ## finally return res
    end
  end
end

# ╔═╡ f6867c32-68df-11eb-042e-1bd6b900f6fa
using Test

# ╔═╡ dc528154-68d2-11eb-2f60-f3499c34b532
md"""
## Macros in Julia
"""

# ╔═╡ eb0c80ff-9b03-4391-a2b1-ff56e3e4c8a9
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ f88b338e-68d2-11eb-1fa8-0bf5b252e9b6
md"""
### Example: assert macro
"""

# ╔═╡ 04400be6-68d3-11eb-35b3-79c07b358527
macro assert(expr)
  :($expr ? nothing : error("Assertion failed: ", $(string(expr))))
end

# ╔═╡ 3f24e7a4-68d3-11eb-22b9-f70cbdfa1b76
md"""
### Assert with message
"""

# ╔═╡ 51b16460-68d3-11eb-0b52-1b31d835485a
macro assert(expr, msg)
  quote
    if $expr
      nothing
    else
      local m = length($msg) == 0 ? "Assertion failed: " : string($msg, ' ')
      error(m, $(string(expr)))
    end
  end
end

# ╔═╡ 1148416e-68d3-11eb-24b3-b1a15aa812a0
begin
  @assert 1 == 1.0

  @assert 1 != 42.0
end

# ╔═╡ 282df856-68d3-11eb-3424-23d08b7af6a3
@assert 1 == 0.0

# ╔═╡ 66f4760a-68d3-11eb-1426-871a3354d9dd
@assert 1 == 42.0

# ╔═╡ 736424d0-68d3-11eb-1ada-750f7c8d622c
@assert(1 == 42.0, "How come?")

# ╔═╡ 90ab2322-68d3-11eb-21f0-35e49b201db4
@assert 1 == 42.0 "How come?"   ## no parentheses, no comma

# ╔═╡ ba35d962-68d3-11eb-1e10-05a84354a399
md"""
### Macro timeit
"""

# ╔═╡ db90b314-68df-11eb-02d5-69315dac74ad
function fact(n::Integer)::Integer
  n < 0 && throw(ArgumentError("n should be positive"))
  (n == 0 || n == 1) && return 1
  n * fact(n - 1) # remember no tail recursion!
end

# ╔═╡ fdcc1536-68df-11eb-34e1-55281df41ceb
begin
  @test fact(0) == 1
  @test fact(1) == 1
  @test_throws ArgumentError fact(-2)
  @test fact(2) == 2
  @test fact(3) == 6
  @test fact(4) == 24
end

# ╔═╡ 8237cd88-68e0-11eb-111c-3b0c6245d629
with_terminal() do
  @timeit fact(7)
end

# ╔═╡ c7e510ca-68e0-11eb-3bfe-d338d10081aa
with_terminal() do
  @timeit fact(15)
end

# ╔═╡ 0923f20e-68e1-11eb-37ae-19e4a24f48b4
md"""
### Macro Trace
"""

# ╔═╡ 5b0d1a14-68e1-11eb-2068-b5b4249c0d61
macro trace(expr)
  quote
    local fn_name = $(string(expr.args[1]))
    local args = $(string(expr.args[2]))

    println("Start of exec. function ", string(fn_name), " with args: ", args)
    local res = $(esc(expr))    ## call the actual expr ≡ function
    println("End of exec. function ", string(fn_name))

    res
  end
end

# ╔═╡ e5397084-68e1-11eb-3322-5956fa8fd17a
# let see the content of this macro, using another macro
@macroexpand @trace double_fn(2)

# ╔═╡ 995fe08d-4a7e-4f14-b2a5-4a6a63881fad
@macroexpand

# ╔═╡ 3dab143e-68e2-11eb-100c-016893824ccd
begin
  fn_α = function (α::Integer=2)  ## function builder
    ## this is a closure
    λ(x::Integer) = x * α
  end

  double_fn = fn_α()
  triple = fn_α(3)
end

# ╔═╡ 86936d9a-68e2-11eb-2217-47e57c631638
begin
  expr = :(double_fn(3))

  expr.args
end

# ╔═╡ a60c13b6-68e2-11eb-3fab-f73606ea715d
@test triple(11) == 33

# ╔═╡ b4e68d26-68e2-11eb-3bf9-bbba25301549
with_terminal() do
  @trace triple(11)
end

# ╔═╡ df8b48a8-68e2-11eb-1698-8f414b4a7fc4
md"""
### Macro unless
"""

# ╔═╡ ebe12cb4-68e2-11eb-216e-a3869afd2b1f
macro unless0(cond, body)
  quote
    if !$(esc(cond))
      $(esc(body))
    end
  end
end

# ╔═╡ 2599be12-68e3-11eb-07c4-376988e519d0
with_terminal() do
  x = 2

  @unless0 x < 0 begin
    println("we are done with x: $(x)")
  end
end

# ╔═╡ 6c19c67a-68e3-11eb-1c71-21ffa0892f7d
with_terminal() do
  x = -1

  @unless0 x < 0 begin
    println("we are done with x: $(x)")
  end
end

# Expect nothing

# ╔═╡ 78acc86c-68e3-11eb-2048-0969c36a0f1a
macro unless(cond, body)
  :(!$(esc(cond)) && $(esc(body)))

  # ≡ @eval $expr ? nothing : $body
end

# ╔═╡ a3511828-68e3-11eb-07ec-4de4d1836d95
with_terminal() do
  x = 2

  @unless x < 0 begin
    println("we are done with x: $(x)")
  end
end

# ╔═╡ a5bdc6f6-68e3-11eb-2248-fb359467846d
md"""
### Expression
"""

# ╔═╡ c3b46a5c-68e3-11eb-0edd-9f98a253f055
with_terminal() do
  dump(:(2 + a * b - c))
end

# ╔═╡ dee8a4f0-68e3-11eb-2336-abcb7af27dcf
with_terminal() do
  dump(:(-c + 2 - a * b))
end

# ╔═╡ a87243cb-3c70-4ecd-ad6e-80a876d6d261
html"""
<style>
  main {
    max-width: calc(1050px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "5171492b2c5e3a0bcc9bbae9f40863dd0851022c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─dc528154-68d2-11eb-2f60-f3499c34b532
# ╠═2e0f805a-68d3-11eb-35c6-95c237883fcd
# ╟─eb0c80ff-9b03-4391-a2b1-ff56e3e4c8a9
# ╟─f88b338e-68d2-11eb-1fa8-0bf5b252e9b6
# ╠═04400be6-68d3-11eb-35b3-79c07b358527
# ╠═1148416e-68d3-11eb-24b3-b1a15aa812a0
# ╠═282df856-68d3-11eb-3424-23d08b7af6a3
# ╠═3f24e7a4-68d3-11eb-22b9-f70cbdfa1b76
# ╠═51b16460-68d3-11eb-0b52-1b31d835485a
# ╠═66f4760a-68d3-11eb-1426-871a3354d9dd
# ╠═736424d0-68d3-11eb-1ada-750f7c8d622c
# ╠═90ab2322-68d3-11eb-21f0-35e49b201db4
# ╟─ba35d962-68d3-11eb-1e10-05a84354a399
# ╠═e5eee32e-68de-11eb-3267-33a033f1dab1
# ╠═db90b314-68df-11eb-02d5-69315dac74ad
# ╠═f6867c32-68df-11eb-042e-1bd6b900f6fa
# ╠═fdcc1536-68df-11eb-34e1-55281df41ceb
# ╠═8237cd88-68e0-11eb-111c-3b0c6245d629
# ╠═c7e510ca-68e0-11eb-3bfe-d338d10081aa
# ╟─0923f20e-68e1-11eb-37ae-19e4a24f48b4
# ╠═5b0d1a14-68e1-11eb-2068-b5b4249c0d61
# ╠═e5397084-68e1-11eb-3322-5956fa8fd17a
# ╠═995fe08d-4a7e-4f14-b2a5-4a6a63881fad
# ╠═3dab143e-68e2-11eb-100c-016893824ccd
# ╠═86936d9a-68e2-11eb-2217-47e57c631638
# ╠═a60c13b6-68e2-11eb-3fab-f73606ea715d
# ╠═b4e68d26-68e2-11eb-3bf9-bbba25301549
# ╟─df8b48a8-68e2-11eb-1698-8f414b4a7fc4
# ╠═ebe12cb4-68e2-11eb-216e-a3869afd2b1f
# ╠═2599be12-68e3-11eb-07c4-376988e519d0
# ╠═6c19c67a-68e3-11eb-1c71-21ffa0892f7d
# ╠═78acc86c-68e3-11eb-2048-0969c36a0f1a
# ╠═a3511828-68e3-11eb-07ec-4de4d1836d95
# ╟─a5bdc6f6-68e3-11eb-2248-fb359467846d
# ╠═c3b46a5c-68e3-11eb-0edd-9f98a253f055
# ╠═dee8a4f0-68e3-11eb-2336-abcb7af27dcf
# ╟─a87243cb-3c70-4ecd-ad6e-80a876d6d261
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

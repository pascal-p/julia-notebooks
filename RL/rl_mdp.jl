### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ ae90e446-b83f-4d7c-ae78-e6278eff29d8
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 298c6752-8de1-4675-b6ac-80b8b14be9c2
using POMDPs, POMDPModelTools, QuickPOMDPs

# ╔═╡ 6e320510-cc41-49bb-8e65-ddb5eb5174af
using DiscreteValueIteration # solver

# ╔═╡ d5be6694-c839-11ec-1c14-cd56a09b512d
md"""
## Julia RL - MDP
"""

# ╔═╡ fc5699be-7e93-4ad0-99f8-b581244e6552
md"""
#### Loading the Packages
"""

# ╔═╡ c5dac9ef-b10c-4c4e-a778-4e4f0e4de8e1
md"""
#### What is MDP?
MDP stands for Markov Decision Process.

MDP provides a framework for making decisions under uncertainties.

Mathematically MDP is a tuple (S, A T, R, γ)
where 
  - S is the State space,
  - A is the Action Space,
  - T is the transition function,
  - R is the reward function and
  - γ is the discounted factor (defining ther current and futur weighting of the rewards)
"""

# ╔═╡ 6aaf832b-08b8-4dd1-a5ee-5393b9277d78
md"""
#### Defining the structure
"""

# ╔═╡ 15c1b870-4047-410c-82b8-946e41f0ea50
begin
	struct State
		# to hold the position on the grid (world)
		x::Int
		y::Int
	end

	const NROWS = 3
	const NCOLS = 4

	const NULL_STATE = State(-1, -1) 
end

# ╔═╡ 66f295e6-5719-47c0-b060-25f992dca244
begin
	@enum Action UP DOWN LEFT RIGHT
	Action
end

# ╔═╡ cfc410fb-f19c-4fae-b819-e4a2db946fb4
const STATES = [
	[State(x, y) for x ∈ 1:NCOLS, y ∈ 1:NROWS]...
	NULL_STATE
]

# ╔═╡ 5d9cb0ce-2e0f-4165-9a3f-14756cfdad60
const ACTIONS = [UP, DOWN, LEFT, RIGHT]

# ╔═╡ 1d79ae04-5bc3-4e44-885a-ee54c0d3e1e7
const MOVES = Dict(
	UP => State(0, 1), DOWN => State(0, -1),
	LEFT => State(-1, 0), RIGHT => State(1, 0)
)

# ╔═╡ 7a34d83d-8dd3-4410-ad2d-f9d9fb063179
Base.:+(s₁::State, s₂::State)::State = State(s₁.x + s₂.x, s₁.y + s₂.y)

# ╔═╡ 7df50c0f-cede-45f9-bb16-1387103c7fb0
# Reward function
function reward_fn(s::State, a = missing)
	if s == State(4, 2) # forbidden cell
		return -100 
	elseif s == State(4, 3) # goal
		return 10
	end
	
	0 # default reward
end

# ╔═╡ 4729e989-fd4e-449e-b319-796e53d9b609
function transition_fn(s::State, a::Action)
	reward_fn(s) != 0 && (return Deterministic(NULL_STATE)) # end the game
	
	len_a = length(ACTIONS)
	next_states = Vector{State}(undef, len_a + 1)
	probs = zeros(len_a + 1)
	
	for (ix, aₚ) ∈ enumerate(ACTIONS)
		prob = aₚ == a ? 0.7 : 0.1 # 10% for each of 3 other direction
		dest = s + MOVES[aₚ]
		next_states[ix + 1] = dest
		
		if dest.x == 2 && dest.y == 2
			probs[ix + 1] = 0.
		elseif 1 ≤ dest.x ≤ NCOLS && 1 ≤ dest.y ≤ NROWS
			probs[ix + 1] += prob
		end
	end

	# out-of-bounds transitions
	next_states[1] = s 
	probs[1] = 1. - sum(probs)

	SparseCat(next_states, probs) # from POMDPModelTools
end

# ╔═╡ d028fd18-bcaf-4a7b-bcdc-0d346650ca7a
md"""
#### The MDP
"""

# ╔═╡ 5e860812-d0b5-449d-8eee-56810acef856
begin
	# define MDP
	termination_fn(s::State)::Bool = s == NULL_STATE
	
	γ = 0.95 # discount factor

	abstract type GridWorld <: MDP{State, Action} end
end

# ╔═╡ f8086013-b3c4-4297-935d-33cc7d255176
md"""
Our gridworld:

| | | | |
|-------|-------|-------|-----------|
| (1,3) | (2,3) | (3,3) | (4,3,+10) |
|-------|-------|-------|-----------|
| (1,2) | XXXXX | (3,2) | (4,2,-100)|
|-------|-------|-------|-----------|
| (1,1) | (2,1) | (3,1) |   (4,1)   |

"""

# ╔═╡ 4e382d3e-6251-428f-8978-de0493af91d6
mdp = QuickMDP(GridWorld,
	states=STATES,
	actions=ACTIONS,
	transition=transition_fn,
	reward=reward_fn,
	discount=γ,
	isterminal=termination_fn
)

# ╔═╡ 616b7993-2302-4763-a459-b2f72c577743
begin
	solver = ValueIterationSolver(max_iterations=30)

	# shows the transitions
	policy = solve(solver, mdp) 
end

# ╔═╡ f5e5a133-5ead-40ab-8da2-ccc5a1ea1ab1
# show expected reward
value_view = [STATES policy.util]

# ╔═╡ dcf8d7b3-66a8-4358-89e0-5c4f34e8f12a
md"""
Our gridworld:

| | | | |
|:--:|:--:|:--:|:--:|
| -> | -> | -> |  ^ |
|----|----|----|----|
|  ^ | XX |  ^ |  ^ |
|----|----|----|----|
|  ^ | <- | <- | <- |

"""

# ╔═╡ e99108af-be3d-4598-adf1-4808a01cd5a4
html"""
<style>

  main {
    max-width: calc(900px + 25px + 6px);
  }

  .plutoui-toc.aside {
    background-color: black;
	color: linen;
  }

  h4, h5 {
	background-color: black;
    color: wheat;
	text-decoration: underline overline dotted darkred;
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DiscreteValueIteration = "4b033969-44f6-5439-a48b-c11fa3648068"
POMDPModelTools = "08074719-1b2a-587c-a292-00f91cc44415"
POMDPs = "a93abf59-7444-517b-a68a-c42f96afdd7d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
QuickPOMDPs = "8af83fb2-a731-493c-9049-9e19dbce6165"

[compat]
DiscreteValueIteration = "~0.4.5"
POMDPModelTools = "~0.3.12"
POMDPs = "~0.9.4"
PlutoUI = "~0.7.38"
QuickPOMDPs = "~0.2.13"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BeliefUpdaters]]
deps = ["POMDPModelTools", "POMDPs", "Random", "Statistics", "StatsBase"]
git-tree-sha1 = "7d4f9d57116796ae3fc768d195386b0a42b4a58d"
uuid = "8bb6e9a1-7d73-552c-a44a-e5dc5634aac4"
version = "0.2.2"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9950387274246d08af38f6eef8cb5480862a435f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.14.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonRLInterface]]
deps = ["MacroTools"]
git-tree-sha1 = "21de56ebf28c262651e682f7fe614d44623dc087"
uuid = "d842c3ba-07a1-494f-bbec-f5741b0a3e98"
version = "0.3.1"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b153278a25dd42c65abbf4e62344f9d22e59191b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.43.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiscreteValueIteration]]
deps = ["POMDPLinter", "POMDPModelTools", "POMDPPolicies", "POMDPs", "Printf", "SparseArrays"]
git-tree-sha1 = "7ac002779617a7e1693ccdcc3a534f555b3ea61e"
uuid = "4b033969-44f6-5439-a48b-c11fa3648068"
version = "0.4.5"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "221ff6c6c9ede484e9f8be4974697187c06eb06b"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.55"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "80ced645013a5dbdc52cf70329399c35ce007fae"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.13.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "b5c7fe9cea653443736d264b85466bad8c574f4a"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.9"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LightGraphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "432428df5f360964040ed60418dd5601ecd240b6"
uuid = "093fc24a-ae57-5d10-9952-331d41423f4d"
version = "1.3.5"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "44a7b7bb7dd1afe12bac119df6a7e540fa2c96bc"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.13"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.MarchingCubes]]
deps = ["StaticArrays"]
git-tree-sha1 = "5f768e0a0c3875df386be4c036f78c8bd4b1a9b6"
uuid = "299715c1-40a9-479a-aaf9-4a633d36f717"
version = "0.1.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
git-tree-sha1 = "737a5957f387b17e74d4ad2f440eb330b39a62c5"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.0"

[[deps.NamedTupleTools]]
git-tree-sha1 = "63831dcea5e11db1c0925efe5ef5fc01d528c522"
uuid = "d9ec5142-1e00-5aa0-9d6a-321866360f50"
version = "0.13.7"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "3114946c67ef9925204cc024a73c9e679cebe0d7"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.8"

[[deps.POMDPLinter]]
deps = ["Logging"]
git-tree-sha1 = "cee5817d06f5e1a9054f3e1bbb50cbabae4cd5a5"
uuid = "f3bd98c0-eb40-45e2-9eb1-f2763262d755"
version = "0.1.1"

[[deps.POMDPModelTools]]
deps = ["CommonRLInterface", "Distributions", "LinearAlgebra", "POMDPLinter", "POMDPs", "Random", "SparseArrays", "Statistics", "Tricks", "UnicodePlots"]
git-tree-sha1 = "984ccff441993a2ff2d924c472e24f302a7b380b"
uuid = "08074719-1b2a-587c-a292-00f91cc44415"
version = "0.3.12"

[[deps.POMDPPolicies]]
deps = ["BeliefUpdaters", "Distributions", "LinearAlgebra", "POMDPModelTools", "POMDPs", "Parameters", "Random", "SparseArrays", "StatsBase"]
git-tree-sha1 = "b9b6233a436aaa2829c3fd9dd6d51a9d2695cc30"
uuid = "182e52fb-cfd0-5e46-8c26-fd0667c990f4"
version = "0.4.2"

[[deps.POMDPTesting]]
deps = ["POMDPs", "Random"]
git-tree-sha1 = "6186037fc901d91703c0aa7ab10c145eeb6d0796"
uuid = "92e6a534-49c2-5324-9027-86e3c861ab81"
version = "0.2.5"

[[deps.POMDPs]]
deps = ["Distributions", "LightGraphs", "NamedTupleTools", "POMDPLinter", "Pkg", "Random", "Statistics"]
git-tree-sha1 = "1189c188c2116a303a3673d7f8aa1e17d1b858c3"
uuid = "a93abf59-7444-517b-a68a-c42f96afdd7d"
version = "0.9.4"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.QuickPOMDPs]]
deps = ["BeliefUpdaters", "NamedTupleTools", "POMDPModelTools", "POMDPTesting", "POMDPs", "Random", "Tricks", "UUIDs"]
git-tree-sha1 = "f65b3fdaf87308dd87241f85f391abbdc0361962"
uuid = "8af83fb2-a731-493c-9049-9e19dbce6165"
version = "0.2.13"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "cd56bf18ed715e8b09f06ef8c6b781e6cdc49911"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c82aaa13b44ea00134f8c9c89819477bd3986ecd"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.3.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5950925ff997ed6fb3e985dcce8eb1ba42a0bbe7"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.18"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodePlots]]
deps = ["ColorTypes", "Contour", "Crayons", "Dates", "FileIO", "FreeTypeAbstraction", "LinearAlgebra", "MarchingCubes", "NaNMath", "Printf", "SparseArrays", "StaticArrays", "StatsBase", "Unitful"]
git-tree-sha1 = "30cdd71bd78478ba19835466c6e2a52ad776d800"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.11.1"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "b649200e887a487468b71821e2644382699f1b0f"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─d5be6694-c839-11ec-1c14-cd56a09b512d
# ╟─ae90e446-b83f-4d7c-ae78-e6278eff29d8
# ╟─fc5699be-7e93-4ad0-99f8-b581244e6552
# ╠═298c6752-8de1-4675-b6ac-80b8b14be9c2
# ╠═6e320510-cc41-49bb-8e65-ddb5eb5174af
# ╟─c5dac9ef-b10c-4c4e-a778-4e4f0e4de8e1
# ╟─6aaf832b-08b8-4dd1-a5ee-5393b9277d78
# ╠═15c1b870-4047-410c-82b8-946e41f0ea50
# ╠═66f295e6-5719-47c0-b060-25f992dca244
# ╠═cfc410fb-f19c-4fae-b819-e4a2db946fb4
# ╠═5d9cb0ce-2e0f-4165-9a3f-14756cfdad60
# ╠═1d79ae04-5bc3-4e44-885a-ee54c0d3e1e7
# ╠═7a34d83d-8dd3-4410-ad2d-f9d9fb063179
# ╠═4729e989-fd4e-449e-b319-796e53d9b609
# ╠═7df50c0f-cede-45f9-bb16-1387103c7fb0
# ╟─d028fd18-bcaf-4a7b-bcdc-0d346650ca7a
# ╠═5e860812-d0b5-449d-8eee-56810acef856
# ╟─f8086013-b3c4-4297-935d-33cc7d255176
# ╠═4e382d3e-6251-428f-8978-de0493af91d6
# ╠═616b7993-2302-4763-a459-b2f72c577743
# ╠═f5e5a133-5ead-40ab-8da2-ccc5a1ea1ab1
# ╟─dcf8d7b3-66a8-4358-89e0-5c4f34e8f12a
# ╟─e99108af-be3d-4598-adf1-4808a01cd5a4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

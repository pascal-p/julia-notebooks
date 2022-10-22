### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 93398de2-51dc-11ed-0956-05db5d65935e
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 2bf579ff-1f2a-45fa-ba6b-55e526402574
using TreeView

# ╔═╡ 142767cb-b936-49ad-8136-69f23ed29fa9
md"""
## Manipulating expression trees
"""

# ╔═╡ c389feec-f2df-4fb1-abd0-9814b82aded8
md"""
### Structure of complex expressions

Recall from the previous notebook that we want to know how `Julia` represents a complex expression with more than one operation, e.g.:
"""

# ╔═╡ 1b65256b-79a7-456f-b2ee-95a488dda88d
expr = :(x + y * z)

# ╔═╡ dabfa1ee-fe20-4738-8731-c825d3323b0f
expr |> dump

# ╔═╡ 60915bbf-8b92-4f22-951f-1226915641db
md"""
We see that indeed we have one `Expr` object embedded into another! That is, one of the args of the top-level expression `expr`  is another object of type `Expr`:
"""

# ╔═╡ cc22e497-e5ee-475c-ac51-871c86ab0302
expr.args[3], typeof(expr.args[3])

# ╔═╡ ad951c95-081e-4fa6-89a6-96158b6ae73d
md"""
We can say that the `Expr` type in `Julia` is a recursive data type: an object of type `Expr` can contain other `Expr` objects! This is another good reason why the type of the args field is a vector of `Any`!

This fact has important implications for how we need to work with `Expr` objects.

Another example is an assignment:
"""

# ╔═╡ 93b65d95-c47e-4b9f-ab5d-9c305b014345
:(x = y + z) |> dump

# ╔═╡ dfedafe5-d538-4235-a477-e42ed57a7971
md"""
As we have seen, any piece of code that is more complicated than a single function call has a hierarchical, or nested structure, with Exprs contained inside other Exprs. In this section we will see how to manipulate such structures. It is common to think of them as trees, called abstract syntax trees or ASTs, or computational graphs.

There are several packages that enable us to visualise an expression as a tree, for example the `TreeView.jl` package that I wrote, and `GraphRecipes.jl`.
"""

# ╔═╡ 6d3c5471-664a-45ce-b2f9-958f6dcf1342
@tree x + y * z

# ╔═╡ 0a94aba6-c758-4e82-8a6a-0aca19d07ca2
begin
	expr₁ = quote
    	x += 1
    	y += x
	end

	expr₁ = Base.remove_linenums!(expr₁)

	TreeView.walk_tree(expr₁)
end

# ╔═╡ f38ed24f-f0d6-4914-b643-d94a43e94c77
md"""
### Walking through expression trees

Since complex expressions have a recursive structure, we need to take this into account when we process them. As a simple example, let's try to solve the following problems:

    Given an expression, substitute y for x, i.e. replace each x in the expression with a y.

The easiest way to do this is to modify the expression.

How can we do this? We will need to check each argument to see if it's an `:x`. If it is, we replace it; if not, we move on:
"""

# ╔═╡ 1f5b542e-86cc-4fa7-932b-42de0db7b6b3
md"""
Exercise
  - Write a function `substitute!` that takes an expression and replaces each `:x` with `:y`.

  - Test it on the expression `x + x * y`. Does it work correctly? If not, what is it missing?
"""

# ╔═╡ 2a778bd6-7f05-4c29-bacd-322370cf84d2
function substitute!(expr::Expr; repl_rule=:x => :z)
	args = expr.args

	for ix ∈ 1:length(args)
		if args[ix] == :x
			args[ix] = :y # hard coded replace
		elseif args[ix] isa Expr
			substitute!(args[ix])
		elseif args[ix] isa Symbol
			substitute!(args[ix],repl_rule)
		else
			throw(
				ArgumentError("$(args[ix]) of type $(typeof(args[ix])) not yet supported")
			)
		end
	end
	expr
end

# ╔═╡ b77c82e7-3836-4e94-add1-87b79c770426
substitute!(expr::Symbol, repl_rule=:x => :z) = expr == repl_rule[1] ? repl_rule[2] : expr

# ╔═╡ 567c7ed3-a153-466a-b130-a1e39c108e9f
methods(substitute!)

# ╔═╡ 85fc1bbc-5d8e-4fd5-9611-450a2f3a2a6a
substitute!(:x), substitute!(:y)

# ╔═╡ 31d19d7e-e93f-47ca-9fda-374f0c3c0c6a
substitute!(:(x + y))

# ╔═╡ eb13c36f-1a44-415a-bf67-ffe1bba5bbe4
try
	substitute!(:(x + :x - y))
catch err
	println("Intercpeted error: $(err)")
end

# ╔═╡ 191b1373-4c84-437d-8054-10106b40f488
expr₂ = :(x + x * y)

# ╔═╡ a8e8f14f-66e1-49f1-9f92-302217d50bd0
substitute!(expr₂)

# ╔═╡ ec1409dd-9866-45e5-bea9-406990c8de17
md"""
Now all `x`s were successfully replaced! But note that the original expression has been lost:
"""

# ╔═╡ 1b10af50-d498-4033-8cc0-560a35490147
expr₂

# ╔═╡ 34c1583a-3331-43da-bbf4-203598eccaa1
md"""
Although the code is easier to write using mutation (since otherwise we need to build up a similar expression with the same structure, which is possible but trickier), users probably don't expect or want their expression to be mutated, since you cannot then recover the original expression, which you might need later. It is common to then provide a non-mutating version, by making a copy of the original expression and mutating that.
"""

# ╔═╡ cd971a7a-6e88-4983-b157-5567d2f55bfe
substitute(expr) = deepcopy(expr) |> substitute!

# ╔═╡ 822b2497-7877-477a-9f8f-c88d85b67bb7
expr₃ = :(x + x * y)

# ╔═╡ 435568cf-72a0-4882-9705-30fa4b1741b9
substitute(expr₃), expr₃

# ╔═╡ 88c627be-a10f-4cf0-8bf3-fa3c5502f956
md"""
Note that it would have been tempting to write this by iterating over the arguments using `for arg ∈ expr.args ...`, but that will not work, since you then cannot modify the resulting argument in place within the expression – arg is a copy of the immutable object inside the expression, rather than a reference to it:
"""

# ╔═╡ f3b1dcfd-c431-457a-9e45-5235736523c6
expr₄ = :(x + y)

# ╔═╡ a6f182e8-42c7-4113-af51-ff8f8acf93e4
for arg ∈ expr₄.args
    @show arg, typeof(arg)
    arg = :z
end

# ╔═╡ d791d645-5906-457f-a9d8-231200531094
expr₄

# ╔═╡ 40848d9e-4256-4d0d-b3e9-29a71ea1356a
md"""
Exercise

 - Make the substitute function more general, by specifying what to substitute with what
"""

# ╔═╡ a294c021-c6b8-4a94-9d96-9fdfac8a8440
## done above

# ╔═╡ 1437ecf0-45bd-4740-a380-dda808b99f97
md"""
Exercise

 - Find which variables are used inside an expression

 - For example, the expression `2x + y * x - 1` should return the vector `[x, y]`, removing duplicates.
    _Hint_: This requires returning the vector of variables.
"""

# ╔═╡ 1b3b026f-434a-4213-a920-6ad463676d13
_find_vars(expr::Number, s::Set)::Set = s

# ╔═╡ c3e6af73-3102-44e9-a7e6-33b589e3fbfd
_find_vars(expr::Symbol, s::Set)::Set = match(r"\A[a-zA-Z]+\z", string(expr)) !== nothing ? push!(s, expr) : s

# ╔═╡ fb97a366-ef68-42c8-83c4-30ca6040e8d2
function _find_vars(expr::Expr, s::Set)::Set
    for arg ∈ expr.args
        _find_vars(arg, s)
    end
    s
end

# ╔═╡ 8080a3b2-6d6c-483c-a6df-0f2c3ad156a6
"""
  find_vars find the variable inside the expression
  variable are supposed to be only alphabetical chars upcase/lowcase
"""
function find_vars(expr)
    s = Set{Any}()
    s = _find_vars(expr, s)
    Vector{Any}(collect(s)) |> sort
end

# ╔═╡ 2a030c3b-1126-4866-b848-51dfe5471364
find_vars(:(2x + y * x - 1))

# ╔═╡ b4a031a4-5056-49d9-b533-f108f2843976
find_vars(:(2 + y))

# ╔═╡ e2f07721-ba92-4da0-a2ea-3496ffb713bc
find_vars(:((2 + y) * (x - 3) / (z - x)))

# ╔═╡ 1733c47a-6223-49f4-96e6-74682a0fb38c
find_vars(:(x + x * y))

# ╔═╡ 72d4c5b8-03f7-49a0-9d6e-29521724b523
find_vars(:(2x * y))

# ╔═╡ f2e8a3a5-cdf5-4052-97b2-a801f05c3227
md"""
Remark
But first let's remark that it is usually an anti-pattern to use `isa` in `Julia`! [Recall that `x isa T` tests if the object `x` has type `T`.]

This should usually be replaced by `dispatch!`. We can rewrite the same code as follows:
"""

# ╔═╡ 4290db53-d51a-420e-9995-e49dae5115a2
begin
	find_variables(x::Symbol) = [x]

	find_variables(x::Real) = []

	find_variables(x::Expr) = sort(unique(reduce(vcat, find_variables(arg) for arg ∈ x.args[2:end])))
end

# ╔═╡ d72abcc0-dc71-4459-ae5b-f08072696571
md"""
### Quote blocks

For longer pieces of code it is common to use `quote ... end` instead of `:( ... )`:
"""

# ╔═╡ 85aacbda-51a5-42eb-b916-d8cb3adc348a
expr₅ = quote
    x += 1
    y += x
end

# ╔═╡ 7a8c6806-1059-48f7-be47-83828b02556d
md"""
Note that quote blocks automatically embed line number information telling you where that piece of code was created, for debugging purposes. We can remove that with `Base.remove`
"""

# ╔═╡ 4fd94189-a0e6-4905-a423-46c9e003da5a
Base.remove_linenums!(expr₅)

# ╔═╡ 637c4a79-9f5c-4935-bc76-a66a269120db
Base.remove_linenums!(expr₅) |> dump

# ╔═╡ 3310db01-1245-44fe-ae2d-6ce9a82e39de
md"""
The only new feature here is that a quote block is a new type of `Expr` with head equal to `:block`.
"""

# ╔═╡ 23dde04c-4de5-43fb-81e8-736e5a0d4c4a
md"""
Further exercises
  - Given an expression, wrap all the literal values (numbers) in the expression with a wrapper type.
  - Replace each of `+`, `-`, `*` and `/` with the corresponding checked operation, which checks for overflow. E.g. + should be replaced by `Base.checked_add`.
"""

# ╔═╡ 8302e8d3-9fee-46ba-b68a-71199b97cbf8


# ╔═╡ c633058d-6fb1-4d1e-900b-bba036397e85


# ╔═╡ f1d55d7e-d832-411b-8c32-5f1a255f20e2
html"""
<style>
  main {
    max-width: calc(950px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
TreeView = "39424ebd-4cf3-5550-a685-96706a953f40"

[compat]
PlutoUI = "~0.7.48"
TreeView = "~0.5.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "6055a09bbd21623e6b8ade03d517bc781ef9b23b"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

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

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg"]
git-tree-sha1 = "110897e7db2d6836be22c18bffd9422218ee6284"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.12.0+0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

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

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "76374b6e7f632c130e78100b166e5a48464256f8"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.4.0+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Poppler_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "OpenJpeg_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "e11443687ac151ac6ef6699eb75f964bed8e1faa"
uuid = "9c32591e-4766-534b-9725-b71a8799265b"
version = "0.87.0+2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

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

[[deps.Tectonic]]
deps = ["Pkg"]
git-tree-sha1 = "0b3881685ddb3ab066159b2ce294dc54fcf3b9ee"
uuid = "9ac5f52a-99c6-489f-af81-462ef484790f"
version = "0.8.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TikzGraphs]]
deps = ["Graphs", "LaTeXStrings", "TikzPictures"]
git-tree-sha1 = "e8f41ed9a2cabf6699d9906c195bab1f773d4ca7"
uuid = "b4f28e30-c73f-5eaf-a395-8a9db949a742"
version = "1.4.0"

[[deps.TikzPictures]]
deps = ["LaTeXStrings", "Poppler_jll", "Requires", "Tectonic"]
git-tree-sha1 = "4e75374d207fefb21105074100034236fceed7cb"
uuid = "37f6aa50-8035-52d0-81c2-5a1d08754b2d"
version = "3.4.2"

[[deps.TreeView]]
deps = ["CommonSubexpressions", "Graphs", "MacroTools", "TikzGraphs"]
git-tree-sha1 = "bf5d1389100e559118c9b84b4e7931b142fe03af"
uuid = "39424ebd-4cf3-5550-a685-96706a953f40"
version = "0.5.0"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

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
# ╟─142767cb-b936-49ad-8136-69f23ed29fa9
# ╠═93398de2-51dc-11ed-0956-05db5d65935e
# ╟─c389feec-f2df-4fb1-abd0-9814b82aded8
# ╠═1b65256b-79a7-456f-b2ee-95a488dda88d
# ╠═dabfa1ee-fe20-4738-8731-c825d3323b0f
# ╟─60915bbf-8b92-4f22-951f-1226915641db
# ╠═cc22e497-e5ee-475c-ac51-871c86ab0302
# ╟─ad951c95-081e-4fa6-89a6-96158b6ae73d
# ╠═93b65d95-c47e-4b9f-ab5d-9c305b014345
# ╟─dfedafe5-d538-4235-a477-e42ed57a7971
# ╠═2bf579ff-1f2a-45fa-ba6b-55e526402574
# ╠═6d3c5471-664a-45ce-b2f9-958f6dcf1342
# ╠═0a94aba6-c758-4e82-8a6a-0aca19d07ca2
# ╟─f38ed24f-f0d6-4914-b643-d94a43e94c77
# ╟─1f5b542e-86cc-4fa7-932b-42de0db7b6b3
# ╠═2a778bd6-7f05-4c29-bacd-322370cf84d2
# ╠═b77c82e7-3836-4e94-add1-87b79c770426
# ╠═567c7ed3-a153-466a-b130-a1e39c108e9f
# ╠═85fc1bbc-5d8e-4fd5-9611-450a2f3a2a6a
# ╠═31d19d7e-e93f-47ca-9fda-374f0c3c0c6a
# ╠═eb13c36f-1a44-415a-bf67-ffe1bba5bbe4
# ╠═191b1373-4c84-437d-8054-10106b40f488
# ╠═a8e8f14f-66e1-49f1-9f92-302217d50bd0
# ╟─ec1409dd-9866-45e5-bea9-406990c8de17
# ╠═1b10af50-d498-4033-8cc0-560a35490147
# ╟─34c1583a-3331-43da-bbf4-203598eccaa1
# ╠═cd971a7a-6e88-4983-b157-5567d2f55bfe
# ╠═822b2497-7877-477a-9f8f-c88d85b67bb7
# ╠═435568cf-72a0-4882-9705-30fa4b1741b9
# ╟─88c627be-a10f-4cf0-8bf3-fa3c5502f956
# ╠═f3b1dcfd-c431-457a-9e45-5235736523c6
# ╠═a6f182e8-42c7-4113-af51-ff8f8acf93e4
# ╠═d791d645-5906-457f-a9d8-231200531094
# ╟─40848d9e-4256-4d0d-b3e9-29a71ea1356a
# ╠═a294c021-c6b8-4a94-9d96-9fdfac8a8440
# ╟─1437ecf0-45bd-4740-a380-dda808b99f97
# ╠═8080a3b2-6d6c-483c-a6df-0f2c3ad156a6
# ╠═1b3b026f-434a-4213-a920-6ad463676d13
# ╠═c3e6af73-3102-44e9-a7e6-33b589e3fbfd
# ╠═fb97a366-ef68-42c8-83c4-30ca6040e8d2
# ╠═2a030c3b-1126-4866-b848-51dfe5471364
# ╠═b4a031a4-5056-49d9-b533-f108f2843976
# ╠═e2f07721-ba92-4da0-a2ea-3496ffb713bc
# ╠═1733c47a-6223-49f4-96e6-74682a0fb38c
# ╠═72d4c5b8-03f7-49a0-9d6e-29521724b523
# ╟─f2e8a3a5-cdf5-4052-97b2-a801f05c3227
# ╠═4290db53-d51a-420e-9995-e49dae5115a2
# ╟─d72abcc0-dc71-4459-ae5b-f08072696571
# ╠═85aacbda-51a5-42eb-b916-d8cb3adc348a
# ╟─7a8c6806-1059-48f7-be47-83828b02556d
# ╠═4fd94189-a0e6-4905-a423-46c9e003da5a
# ╠═637c4a79-9f5c-4935-bc76-a66a269120db
# ╟─3310db01-1245-44fe-ae2d-6ce9a82e39de
# ╟─23dde04c-4de5-43fb-81e8-736e5a0d4c4a
# ╟─8302e8d3-9fee-46ba-b68a-71199b97cbf8
# ╟─c633058d-6fb1-4d1e-900b-bba036397e85
# ╟─f1d55d7e-d832-411b-8c32-5f1a255f20e2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

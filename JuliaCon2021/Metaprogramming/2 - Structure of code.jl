### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ e4078697-9871-4cdf-8ead-f5bd9b0dbe77
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ ad4a5fe0-51d7-11ed-0546-972506e604a3
md"""
## The structure of code

One somewhat unusual feature of Julia (originating from its Lisp heritage) is that it allows us to talk about Julia code – from within Julia itself!

That is, we can capture a piece of Julia code into a Julia object, which we can then inspect and modify.

Once we have the modified code, we can then evaluate it.

An easy way to create a piece of code is by parsing a string, i.e. interpreting the string as Julia code and returning a Julia object that represents that piece of code. Nonetheless, in the future we will prefer, when possilbe, to create Julia objects directly, rather than from strings, since strings are "opaque objects" that Julia does not understand.

"""

# ╔═╡ ddc34141-034b-4db6-acce-56214744b929
md"""
Exercise

 1. Define a variable code to be as the result of parsing the string "j = i^2" using the function `Meta.parse`.
 1. What type is the object code? Note that code is just a normal `Julia` variable, of a particular special type.
 1. Use the `dump` function to see what there is inside code. Remembering that code is just a particular kind of `Julia` object, use the `Julia` to play around interactively, seeing how you can extract pieces of the code object.
 1. How is the operation `i^2` represented? What kind of object is that subpiece?
 1. Copy code into a variable `code2`. Modify this to replace the power 2 with a power 3. Make sure that the original code variable is not also modified.
 1. Copy `code2` to a variable `code3`. Replace `i` with `i + 1` in `code3`.
 1. Define a variable `i` with the value 4. Evaluate the different code expressions using the `eval` function and check the value of the variable `j`.
"""

# ╔═╡ af00bb82-ecb8-42c6-a32b-abe8016c43f4
code = Meta.parse("j = i^2")

# ╔═╡ 24c84634-4c90-4f95-b5c3-b93938f2f5d0
typeof(code)

# ╔═╡ 06d7ec5f-bf34-4be8-b6c6-d8eb37091ae1
with_terminal() do 
	dump(code)
end

# ╔═╡ a03a7b71-3f26-4454-b394-d926d129f3be
propertynames(code)

# ╔═╡ 8fc73146-9809-4df8-8a54-39db87ba3f5f
code.args[2], typeof(code.args[2])

# ╔═╡ ad332d54-bfa7-401e-8176-0ea375dde043
code₂ = code |> deepcopy

# ╔═╡ 4b6b5837-4cf3-48d7-af02-a8cb90783db7
code₂.args[2].args[3] = 3

# ╔═╡ bca2fb34-6959-471f-8c58-f9f20624aba8
code, code₂

# ╔═╡ ffb0c8a2-dc07-4d0b-b0e7-4a27309ef7d0
code₃ = code₂ |> deepcopy

# ╔═╡ e9644ec9-3aa6-4e75-bf7b-2b2789ff3c9f
code₃.args[2].args[2] # = :(i + 1)

# ╔═╡ 6bafb1fb-b2d9-4ae9-8049-f1b2712ee191
code₃.args[2].args[2] = :(i + 1)

# ╔═╡ cac4d508-0b3f-4efb-972b-d9f517a88148
code₃

# ╔═╡ db096f4c-f947-464b-a895-b89046035a03
begin
	i = 4
	eval(code₃)  # ≡ (4+1)^3 == 125
end

# ╔═╡ 6eddec64-a590-42a5-abed-48a3f31587e6
md"""
## Symbols
"""

# ╔═╡ 411ab463-a6f9-4fb3-8fc4-74eaee19c560
md"""
Let's think about what code looks like. It's made up of characters joined into words, plus certain types of punctuation, for example

```Julia
function f() 
    ...
end
```

and

```Julia
for 
    ...
end
```

and
```Julia
z = x + y
result = first + second
```

The smallest building blocks, or atoms, of code are variable names like `x` and `first`, and other symbols like `+`. `Julia` calls all of these names symbols.

When you type `+` or `x` in the `REPL`, `Julia` immediately tries to evaluate the result: it treats `+` or `x` as a name or binding that points to an object, and it tries to return the object itself.

For metaprogramming, we instead need a way to talk just about "the unevaluated piece of code consisting of the name x". We write this using a colon, `:`, e.g. `:x` and `:+` :

"""

# ╔═╡ 269b25a8-b151-449f-8410-c9ab9329610a
s = :x

# ╔═╡ d546d02b-faf0-4293-ad8b-0bf84b8a2aae
typeof(s)

# ╔═╡ cc7f1893-5e0f-4ecf-acf4-9205565cf730
md"""
We can think of `:hello`, for example, as a way to talk about a possible variable called `hello`, without evaluating it.
"""

# ╔═╡ 9d087325-432b-40f1-b118-3d54eea42dfa
md"""
## Expression

Anything more complicated than a single symbol is an expression, for example `x + y`, which means "call the function named `+` on the objects named `x` and `y`". (This is equivalent to writing `+(x, y)` in `Julia`)

We can talk about the piece of code "x + y" without evaluating it by quoting it, again using a colon:

`:(x + y)`

Let's give that a name. We will use `expr` for expression:

"""

# ╔═╡ cf7c9eb2-5960-46a5-8cd6-ac5459d1c4e3
expr = :(x + y)

# ╔═╡ b9cec9d6-5400-4d29-9a15-2c836566f368
md"""
In words we are telling `Julia` something like: "Define a new variable, called `expr`, whose value is bound to the unevaluated piece of code `x + y`.

Note that if we just type `x + y` into the REPL, again Julia will immediately try to evaluate this by looking up the values that are bound to the variable names `x` and `y`. But we haven't yet defined variables called `x` and `y`, so this will error.

However, there is no such problem with talking about "the piece of code x + y" – here,`x` and `y` are just symbols.
"""

# ╔═╡ 1dc52b8a-7b7e-4113-b331-f4fcb3e4d19f
try
	x + y
catch e
	println("Intercepted Error ", e)
end

# ╔═╡ 026eeb01-21d7-49e7-8b0b-322daf6767a4
md"""
## The Expr type and the structure of expressions

We now have a `Julia` object with the name `expr` that is referring to an unevaluated piece of `Julia` code, `x + y`. Let's use `Julia`'s great introspection tools to look inside this object and see how it's formed!

Firstly let's look at its type:
"""

# ╔═╡ f2f1334f-26b8-4bdc-98bd-4c9eb255ee6f
typeof(expr)

# ╔═╡ f7a27043-46e2-437a-b630-8870631ab362
md"""
`Expr` is a type representing any `Julia` expression that is more complicated than a single symbol.

How is the sum represented? Let's find out using `dump`:
"""

# ╔═╡ a454344a-c5c7-4f52-b485-ba3dbdae65dd
with_terminal() do
	dump(expr)
end

# ╔═╡ 1a32bdc6-3a8c-44c1-b72b-d7a5b444de36
md"""
Alternatively we can use `expr<TAB>` interactively, or `propertynames(expr)` programatically, to expression object's attributes:
"""

# ╔═╡ 7dccaa0a-b4ea-485c-945b-e5e31a436e49

propertynames(expr)

# ╔═╡ 25eecf00-3839-452d-b780-5f9ef9fbcbcb
md"""
We see that this expression (and, in fact, any expression!) consists of two pieces: 
 - a head and 
 - a collection of `args`, i.e. arguments.
"""

# ╔═╡ 73e4f6f0-1f94-47ef-ac40-8332a0c87ac7
expr.head

# ╔═╡ b3373ab1-4135-421e-8d64-a1c80eada628
md"""
In this case, the head is `:call`, which tells us that this piece of code is a function call.
"""

# ╔═╡ 4053f18d-e75b-4a89-866f-d706794bed73
expr.args

# ╔═╡ 0b35e689-751f-4992-8446-64dcbf59cff5
md"""
The arguments show us the pieces of the function call: the function to be called corresponds to the symbol `:+`, and that function is called on the objects corresponding to the symbols `:x` and `:y`.

Note that the type of args is a vector of `Any`. This is because we can have things other than symbols as an argument, e.g.
"""

# ╔═╡ 49db31f8-6df0-4c66-903d-aaab55767ffa
:(x + 1) |> dump

# ╔═╡ 4668deaf-77f6-4a4a-a459-976ffc67700c
md"""
## Creating code from scratch

Since `Expr` is just a standard `Julia` type, we can create objects of that type in the standard way, namely by calling the constructor function of the type. The constructor for `Expr` just accepts a tuple of its arguments, starting with head and following with a list of arguments, e.g.
"""

# ╔═╡ a895e23c-3475-470e-b590-ed22d79d7974
Expr(:call, :+, :x, :y)

# ╔═╡ bc4e15ba-056d-4d0a-b94c-b0af51c9c49a
md"""
## More complicated expressions

Now let's look at an expression that's a bit more complicated, with two operations:
"""

# ╔═╡ defc6f22-b439-4ad2-86e3-4f2059385449
nexpr = :(x + y * z)

# ╔═╡ c1275e9f-2f69-4d8c-8108-102c3c7e4c13
md"""
How can this expression be represented? 

Firstly `Julia` needs to decide which operation will be done first: does this mean `x + (y * z`), or `(x + y) * z`. This choice is made by having a table of operator precedence; in this particular case, `*` has a higher precedence than `+`, so will be "bound more tightly", or done first, so the expression will be interpreted as `x + (y * z)`. Operator precedence is fixed in the parser and cannot be changed (without modifying and recompiling `Julia`). If you need a different order of operations, use parentheses!

So how does `Julia` represent this expression? It will be a sum of two things, `x` and `y * z`. What is `y * z`? Well, we already know that it's... an expression, an object of type `Expr`!
"""

# ╔═╡ 9b6920d5-de7c-4f54-a4ba-dd2085517b65
with_terminal() do
	:(y * z) |> dump
end

# ╔═╡ 65d6ac47-fabd-4743-94c2-ad531fae6aef
md"""
It has the same overall structure as `:(x + y)`, but the arguments are different.
"""

# ╔═╡ 85856f3a-108b-45b4-882b-c4494b86e9dd
md"""
Exercise

Can you now guess how `:(x + (y * z))` is represented? Try to predict the answer before moving on.
"""

# ╔═╡ 524062d4-c8f1-45f7-a899-53b2a92984b5
## Expr(:call :+ x (:call :* y z))

# ╔═╡ 15ecf19d-1602-4cf4-b5cd-9321dde7577a
:(x + (y * z)) |> dump

# ╔═╡ 37ff0ffa-493b-4467-8fba-63d1ff205eb2
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

[compat]
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "97be6e027681c6ecfa37671630e179d506eb1167"

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
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

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
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

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
# ╠═e4078697-9871-4cdf-8ead-f5bd9b0dbe77
# ╟─ad4a5fe0-51d7-11ed-0546-972506e604a3
# ╟─ddc34141-034b-4db6-acce-56214744b929
# ╠═af00bb82-ecb8-42c6-a32b-abe8016c43f4
# ╠═24c84634-4c90-4f95-b5c3-b93938f2f5d0
# ╠═06d7ec5f-bf34-4be8-b6c6-d8eb37091ae1
# ╠═a03a7b71-3f26-4454-b394-d926d129f3be
# ╠═8fc73146-9809-4df8-8a54-39db87ba3f5f
# ╠═ad332d54-bfa7-401e-8176-0ea375dde043
# ╠═4b6b5837-4cf3-48d7-af02-a8cb90783db7
# ╠═bca2fb34-6959-471f-8c58-f9f20624aba8
# ╠═ffb0c8a2-dc07-4d0b-b0e7-4a27309ef7d0
# ╠═e9644ec9-3aa6-4e75-bf7b-2b2789ff3c9f
# ╠═6bafb1fb-b2d9-4ae9-8049-f1b2712ee191
# ╠═cac4d508-0b3f-4efb-972b-d9f517a88148
# ╠═db096f4c-f947-464b-a895-b89046035a03
# ╟─6eddec64-a590-42a5-abed-48a3f31587e6
# ╟─411ab463-a6f9-4fb3-8fc4-74eaee19c560
# ╠═269b25a8-b151-449f-8410-c9ab9329610a
# ╠═d546d02b-faf0-4293-ad8b-0bf84b8a2aae
# ╟─cc7f1893-5e0f-4ecf-acf4-9205565cf730
# ╟─9d087325-432b-40f1-b118-3d54eea42dfa
# ╠═cf7c9eb2-5960-46a5-8cd6-ac5459d1c4e3
# ╟─b9cec9d6-5400-4d29-9a15-2c836566f368
# ╠═1dc52b8a-7b7e-4113-b331-f4fcb3e4d19f
# ╟─026eeb01-21d7-49e7-8b0b-322daf6767a4
# ╠═f2f1334f-26b8-4bdc-98bd-4c9eb255ee6f
# ╟─f7a27043-46e2-437a-b630-8870631ab362
# ╠═a454344a-c5c7-4f52-b485-ba3dbdae65dd
# ╟─1a32bdc6-3a8c-44c1-b72b-d7a5b444de36
# ╠═7dccaa0a-b4ea-485c-945b-e5e31a436e49
# ╟─25eecf00-3839-452d-b780-5f9ef9fbcbcb
# ╠═73e4f6f0-1f94-47ef-ac40-8332a0c87ac7
# ╟─b3373ab1-4135-421e-8d64-a1c80eada628
# ╠═4053f18d-e75b-4a89-866f-d706794bed73
# ╟─0b35e689-751f-4992-8446-64dcbf59cff5
# ╠═49db31f8-6df0-4c66-903d-aaab55767ffa
# ╟─4668deaf-77f6-4a4a-a459-976ffc67700c
# ╠═a895e23c-3475-470e-b590-ed22d79d7974
# ╟─bc4e15ba-056d-4d0a-b94c-b0af51c9c49a
# ╠═defc6f22-b439-4ad2-86e3-4f2059385449
# ╟─c1275e9f-2f69-4d8c-8108-102c3c7e4c13
# ╠═9b6920d5-de7c-4f54-a4ba-dd2085517b65
# ╟─65d6ac47-fabd-4743-94c2-ad531fae6aef
# ╟─85856f3a-108b-45b4-882b-c4494b86e9dd
# ╠═524062d4-c8f1-45f7-a899-53b2a92984b5
# ╠═15ecf19d-1602-4cf4-b5cd-9321dde7577a
# ╟─37ff0ffa-493b-4467-8fba-63d1ff205eb2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

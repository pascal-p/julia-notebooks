### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 0a6b6042-5279-11ed-36d6-a9322d669fb3
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ b170e5f9-4d3f-4b5c-836f-769c5cc5cf0f
md"""
##  Macros
--- 
"""

# ╔═╡ fe94a73b-d98b-442f-bb96-c8a8f0db9cfc
md"""
So far we have been creating `Julia` expressions ourselves, by hand. Macros are a common method to do this automatically.

Recall that macros begin with `@` and behave like "super-functions", which take in a piece of code and replace it with another piece of code. The effect of a macro call is to splice, or replace, the new piece of code in place of the old code; the new code is what is actually compiled by the `Julia` compiler.

Note that the user does not need to explicitly pass an expression object; `Julia` turns the code that follows the macro call into an expression.

To see this, let's define the simplest macro:
"""

# ╔═╡ e1032ebd-89ad-4d2e-a777-fdc41e661a25
macro yasimple(expr)
	@show expr
    @show typeof(expr)
    nothing   # return nothing for the moment
end

# ╔═╡ 04e3bbd2-675a-4bb0-b7c5-393d1db855f6
@yasimple a = b # NOTE: displaying does work with Pluto (which captures the output of the macro, not its side-effect)
                # check terminal output to see the output of @show ...  

# ╔═╡ 6cdcd7be-1473-44ed-8f37-3220865ada15
Meta.parse("a = b")

# ╔═╡ 7e0b47bc-68d9-442b-8464-baadfc684bb6
md"""
### Structuring a macro

The usual recommendation is that a macro should just act as an interface to the user that captures the user's code, as we saw just above. The resulting expression is then usually passed to a function to do the manipulation. This gives a separation of concerns (capture vs. processing) and makes it easier for the developer to test the processing step.

For example, let's write a macro that replaces a `+` with a `*`:

"""

# ╔═╡ d7aa7bf9-dce1-4646-a3a3-623e0229e3cb
md"""
The function receives an expression and should create the new expression:
"""

# ╔═╡ 39e8b0c6-bebc-4d25-94c7-9087b379309a
function _add_to_mult(expr)
    expr.head == :call && expr.args[1] == :+ && (expr.args[1] = :*)    
    expr
end

# ╔═╡ e2fffa96-2ebd-43e1-ba93-72a55931461d
macro add_to_mult(expr)
	_add_to_mult(expr)
end

# ╔═╡ c433125c-6c1f-4d34-abea-a72cc8053d32
:(a + b) |> _add_to_mult

# ╔═╡ 29c3a980-f200-49da-8074-df9466c66cf4
try
	@add_to_mult a + b   # try to eval this code
catch err
	println("Intercepted error: ", err)
end

# ╔═╡ ac9ca369-66af-4412-8d5a-19935611b741
md"""
What is happening here? The `macro` first replaces the code with `a * b`, and then compiles and tries to execute the code. But the variable `a` does not yet exist, so this errors. Defining `a` and `b` behaves as we expect:
"""

# ╔═╡ f5d803d2-c949-4056-b7c0-65c820c91401
begin
	x = 2
	y = 3
end

# ╔═╡ 560f9a7a-fa64-4bcf-a0e6-b026642ff7e1
@add_to_mult x + y

# ╔═╡ 51ed60d5-e666-4c1b-831e-74c67b5ccf6b
md"""
We indeed get the result of multiplying `x` and `y`, not adding them.

This is a good example of why debugging macros is best done via an intermediate function that does the expression manipulation.

Recall that we can use `@macroexpand` to see what the macro is doing:
"""

# ╔═╡ c72772de-5fae-4d1d-b1c0-c87e52a7757d
@macroexpand @add_to_mult x + y

# ╔═╡ ffc97d2c-e4e7-4515-9063-f2bbd4a769cb
md"""
### Macro hygiene

Macro "hygiene" refers to the fact that macros do some modification of the code that they receive, in order to be "hygienic" (clean): they try not to touch user code.
"""

# ╔═╡ 47d0d0fd-951a-41d7-93ca-6c80f40c4781
md"""
Exercise
1. Define a macro `@yasimple2` that returns the expression that was passed to it.
1. What happens when you call `@yasimple2 yy = xx^2`?
1. Define a variable `xx` with the value 3. Does the macro work now?
1. Does the variable `yy` now exist?
1. To see what's happening, use @macroexpand.
"""

# ╔═╡ 9a6113e1-0d31-49c5-8a9b-37c65c0feb12
macro yasimple2(expr)
    expr   # just return the expr as is
end

# ╔═╡ 3d64393c-b620-41d6-bb6c-754a964fe879
try
	@yasimple2 yy = xx^2
catch err
	println("Intercepted error: ", err)
end

# ╔═╡ b2eedd22-030e-4d9c-9ccf-aa9e3882338f
md"""
problem is that `xx` is not yet defined! So let's define it (as we are in Pluto reactive notebook - we need to use another var), let's call it y₀:
"""

# ╔═╡ bc021caa-c80b-4e58-accd-630d0154f33f
y₀ = 3

# ╔═╡ 083c737c-0e4f-46fb-8c71-c074ff99e4a5
@yasimple2 yy = y₀^2

# ╔═╡ 08c844c9-c760-4e4b-9433-61293495b368
@macroexpand @yasimple2 yy = y₀^2

# ╔═╡ 8faa7a5a-9b6f-4975-8a19-5af914498d45
md"""
You should find that the variable `yy` does not exist, even though it seems like it should, since the code `yy = y₀^2` was evaluated. However, macros by default do not "touch" variables in the context from where they are called, since this may have unintended consequences. We refer to this as _macro hygiene_: the macro is hygienic, i.e. clean, meaning that it does not "infect" the user's code.

Nonetheless, often we may want a macro to be able to modify a variable in the context from which the macro is called. In which case we can "escape" from this hygiene, making a non-hygienic macro, using `esc` ("escape"):
"""

# ╔═╡ 1ebf1ac9-6994-49b9-bece-d2b640c688da
macro yasimple3(expr)
    ex = esc(expr)
    :($ex)
end

# ╔═╡ 2b3cf4a1-667a-43c6-958e-c8be929a18d9
@yasimple3 yy = y₀^2    ## now modifying yy

# ╔═╡ 36ab7ba6-b470-4468-8e3b-3a35c512d2e0
try
	yy
catch err
	println("Intercepted error: ", err)
end

# ╔═╡ e10f7df1-61f1-4523-9856-c045f590a356
yy

# ╔═╡ d03ac7a0-9f2c-4fb6-a5c6-156265a2387c
@macroexpand @yasimple3 yy = y₀^2

# ╔═╡ 6299caf7-17cc-462b-8611-9136f1d8319d
md"""
Note that once again the macro must return an expression.

For code clarity it is possible to define a new variable that is the escaped version:
"""

# ╔═╡ dbe10afe-0b9b-4fe0-a8a6-674335e50edd
macro yasimple4(expr)
    ex = esc(expr)
    :($ex)
end

# ╔═╡ bb220040-3454-4f56-848b-467d95e46ad8
@macroexpand @yasimple4 yy = y₀^2

# ╔═╡ a13f5707-32ad-4d72-a619-6e75f614e535
begin
	x₁ = 5
	@yasimple4 yy₁ = 2^x₁
end

# ╔═╡ f54138f0-e879-4cfe-85d3-fdd793a400bf
yy₁

# ╔═╡ 1a461482-7a06-4a59-a553-f0f6d792c831
md"""
Exercise

Define a `@yashow` macro that reproduces the behaviour of `@show`.
"""

# ╔═╡ 705699d6-08af-419e-8d92-0c6ff3b94be1
macro yashow(expr)
    # :(println(stdout, $(QuoteNode(expr)), " = ", $(esc(expr))))  
    local var = QuoteNode(expr)
    local val = esc(expr)
    :(println(stdout, $var, " => ", $(val)))  
end

# ╔═╡ 21cacdf8-b85a-4898-a6e7-8b57a6969eef
@yashow z = 3

# ╔═╡ c8767d86-0fed-41a4-b023-700e75c44717
md"""
### Macros for domain-specific languages

Let's see some simple examples of how we can start to approach domain-specific languages for scientific applications.

Let's suppose we want to reproduce the `@variables` macro from `Symbolics.jl`. The idea is that there is a Variable object representing a symbolic variable:
"""

# ╔═╡ c9d0ec27-5a30-449b-affa-292423718481
struct Variable
    name::Symbol
end
# Base.show(io::IO, v::Variable) = print(io, v.name)

# ╔═╡ 83e3c7bf-d0e6-4f2f-8af1-a7f112d408e3
md"""
We can create such a variable as:
"""

# ╔═╡ 51d62377-6ab5-4747-b46e-9289e046f417
Variable(:x)

# ╔═╡ 3bc41db4-d8ba-4e6c-863a-e5d8039bbd26
md"""
To define a `Julia` variable called `x` that is bound to the Variable object, we must do:
"""

# ╔═╡ 407ec6da-9f69-4464-8936-87832fa34dd3
t = Variable(:t)

# ╔═╡ bacaecdd-1d62-47e2-bc68-d8a413622db7
md"""
The situation is similar to the `@show` macro: we would ideally like to be able to write `@var x`, which expands to `x = Variable(:x)`.
"""

# ╔═╡ d43366ca-2b90-43b8-b8b5-b132acffdcd8
md"""
Exercise

Try to write the `@var` macro. You will probably get stuck! Where is the sticking point?
"""

# ╔═╡ f6d29b8e-3369-46f8-860b-e6c7cc58e538
function _varfn(expr)
    :($(esc(expr)) = Variable($(QuoteNode(expr))))
end

# ╔═╡ af5f1308-5cb9-4a2d-983f-46a7d346bb80
macro var(expr)
    _varfn(expr)
end

# ╔═╡ bba6570e-5a37-4f4d-a9a5-e4c61c3bc3a9
@var u

# ╔═╡ 835605ed-3268-4495-834a-75ead5730a3b
u

# ╔═╡ e83672ab-4992-4a96-b3a1-b8d3202ca273
md"""
in more details:
"""

# ╔═╡ 6560b4f3-7484-419f-b044-22b243d1aa0c
function _varfn_in_details(expr)
    esc_expr = esc(expr)
    println("=> esc_expr: $(esc_expr)")
	
	quoted_expr = QuoteNode(expr)
    println("=> quoted_expr: $(quoted_expr)")
	
	# assign and return 
    :(
        $(esc_expr) = Variable($(quoted_expr))
    )
end

# ╔═╡ 47b0fec6-4e99-4e7a-94c9-bd8b9f117a86
_varfn_in_details(:x)

# ╔═╡ 1f27af1a-2585-4c27-964a-a26e35649a1f
@macroexpand @var u₁

# ╔═╡ 02afe09c-efa8-4956-ba36-6c17ee2b8e61
@var u₁

# ╔═╡ 71a081a5-36b8-478a-a99e-ee9ac7555470
u₁

# ╔═╡ 0c503f9b-8619-4e34-af5a-0bdac2af884a
md"""
### Several variables

Now suppose we want to expand our macro to handle not only single variables, but also multiple variables, e.g. `@var x y`

In general we could have an arbitrary number of arguments; we should pass each through to the `_var` function:
"""

# ╔═╡ a8435942-dfd9-4904-9b9c-a5a236f6933b
macro vars_(exprs...)
	all_code = [_varfn(expr) for expr ∈ exprs]
	@show all_code
	all_code
end

# ╔═╡ 197ea941-a16e-4ff9-abf2-fccdbbaaf393
@vars_ x₃ y₃

# ╔═╡ d4dfb670-9d3f-43f8-970a-a16c38b32dcf
# x₃, y₃

# ╔═╡ b7a49c05-7bcc-406f-95ff-4ccfbd406da3
md"""
Now we need to combine that code into a single code block:
"""

# ╔═╡ c0c8b6cd-351f-4cd6-975e-28af24d09fef
macro vars(exprs...)
	all_code = quote end  # empty block
	all_code.args = reduce(vcat, _varfn(expr) for expr ∈ exprs)
	all_code
end

# ╔═╡ 9653067f-2b1d-4043-ab25-2514e0c7b574
@vars x₄ y₄ z₄

# ╔═╡ 3df1d2e8-3d97-4a49-a66e-5ee9167c65c0
x₄, y₄, z₄

# ╔═╡ c6c75262-f719-4c73-b9c1-4396c6c9b445
# rest not weorking in Pluto

# ╔═╡ 0ecb02d7-12a7-4913-818b-3728f125a274
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
# ╟─b170e5f9-4d3f-4b5c-836f-769c5cc5cf0f
# ╠═0a6b6042-5279-11ed-36d6-a9322d669fb3
# ╟─fe94a73b-d98b-442f-bb96-c8a8f0db9cfc
# ╠═e1032ebd-89ad-4d2e-a777-fdc41e661a25
# ╠═04e3bbd2-675a-4bb0-b7c5-393d1db855f6
# ╠═6cdcd7be-1473-44ed-8f37-3220865ada15
# ╟─7e0b47bc-68d9-442b-8464-baadfc684bb6
# ╠═e2fffa96-2ebd-43e1-ba93-72a55931461d
# ╟─d7aa7bf9-dce1-4646-a3a3-623e0229e3cb
# ╠═39e8b0c6-bebc-4d25-94c7-9087b379309a
# ╠═c433125c-6c1f-4d34-abea-a72cc8053d32
# ╠═29c3a980-f200-49da-8074-df9466c66cf4
# ╟─ac9ca369-66af-4412-8d5a-19935611b741
# ╠═f5d803d2-c949-4056-b7c0-65c820c91401
# ╠═560f9a7a-fa64-4bcf-a0e6-b026642ff7e1
# ╟─51ed60d5-e666-4c1b-831e-74c67b5ccf6b
# ╠═c72772de-5fae-4d1d-b1c0-c87e52a7757d
# ╟─ffc97d2c-e4e7-4515-9063-f2bbd4a769cb
# ╟─47d0d0fd-951a-41d7-93ca-6c80f40c4781
# ╠═9a6113e1-0d31-49c5-8a9b-37c65c0feb12
# ╠═3d64393c-b620-41d6-bb6c-754a964fe879
# ╟─b2eedd22-030e-4d9c-9ccf-aa9e3882338f
# ╠═bc021caa-c80b-4e58-accd-630d0154f33f
# ╠═083c737c-0e4f-46fb-8c71-c074ff99e4a5
# ╠═36ab7ba6-b470-4468-8e3b-3a35c512d2e0
# ╠═08c844c9-c760-4e4b-9433-61293495b368
# ╟─8faa7a5a-9b6f-4975-8a19-5af914498d45
# ╠═1ebf1ac9-6994-49b9-bece-d2b640c688da
# ╠═2b3cf4a1-667a-43c6-958e-c8be929a18d9
# ╠═e10f7df1-61f1-4523-9856-c045f590a356
# ╠═d03ac7a0-9f2c-4fb6-a5c6-156265a2387c
# ╟─6299caf7-17cc-462b-8611-9136f1d8319d
# ╠═dbe10afe-0b9b-4fe0-a8a6-674335e50edd
# ╠═bb220040-3454-4f56-848b-467d95e46ad8
# ╠═a13f5707-32ad-4d72-a619-6e75f614e535
# ╠═f54138f0-e879-4cfe-85d3-fdd793a400bf
# ╟─1a461482-7a06-4a59-a553-f0f6d792c831
# ╠═705699d6-08af-419e-8d92-0c6ff3b94be1
# ╠═21cacdf8-b85a-4898-a6e7-8b57a6969eef
# ╟─c8767d86-0fed-41a4-b023-700e75c44717
# ╠═c9d0ec27-5a30-449b-affa-292423718481
# ╟─83e3c7bf-d0e6-4f2f-8af1-a7f112d408e3
# ╠═51d62377-6ab5-4747-b46e-9289e046f417
# ╟─3bc41db4-d8ba-4e6c-863a-e5d8039bbd26
# ╠═407ec6da-9f69-4464-8936-87832fa34dd3
# ╟─bacaecdd-1d62-47e2-bc68-d8a413622db7
# ╟─d43366ca-2b90-43b8-b8b5-b132acffdcd8
# ╠═af5f1308-5cb9-4a2d-983f-46a7d346bb80
# ╠═f6d29b8e-3369-46f8-860b-e6c7cc58e538
# ╠═bba6570e-5a37-4f4d-a9a5-e4c61c3bc3a9
# ╠═835605ed-3268-4495-834a-75ead5730a3b
# ╟─e83672ab-4992-4a96-b3a1-b8d3202ca273
# ╠═6560b4f3-7484-419f-b044-22b243d1aa0c
# ╠═47b0fec6-4e99-4e7a-94c9-bd8b9f117a86
# ╠═1f27af1a-2585-4c27-964a-a26e35649a1f
# ╠═02afe09c-efa8-4956-ba36-6c17ee2b8e61
# ╠═71a081a5-36b8-478a-a99e-ee9ac7555470
# ╟─0c503f9b-8619-4e34-af5a-0bdac2af884a
# ╠═a8435942-dfd9-4904-9b9c-a5a236f6933b
# ╠═197ea941-a16e-4ff9-abf2-fccdbbaaf393
# ╠═d4dfb670-9d3f-43f8-970a-a16c38b32dcf
# ╟─b7a49c05-7bcc-406f-95ff-4ccfbd406da3
# ╠═c0c8b6cd-351f-4cd6-975e-28af24d09fef
# ╠═9653067f-2b1d-4043-ab25-2514e0c7b574
# ╠═3df1d2e8-3d97-4a49-a66e-5ee9167c65c0
# ╠═c6c75262-f719-4c73-b9c1-4396c6c9b445
# ╟─0ecb02d7-12a7-4913-818b-3728f125a274
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

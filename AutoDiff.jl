### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9947a66a-7fe5-11eb-0955-87881a67fbea
begin
	using PlutoUI
	using Plots
	
	# plotly()
end

# ╔═╡ 9872b1a8-7fe7-11eb-0b3b-cb6181515182
using SymPy

# ╔═╡ 84fc02d6-7fef-11eb-2e21-cb577c3974f0
# Pkg.add("ForwardDiff)
using ForwardDiff

# ╔═╡ e529f550-7fe3-11eb-06f8-6beaa1506e66
md"""
## AutoDiff - Exploration

Status:
 - ref. 2019-10-26 - ref. [Automatic Differentiation in 10 minutes with Julia](https://www.youtube.com/watch?v=vAp6nUMrKYg)
 - 2021-03-08 moved to `Pluto.jl`

"""

# ╔═╡ 28aa4e9c-7fe4-11eb-3d87-c5a10540c2c1
md"""
Let's start with a simple example, the computation of $\sqrt(x)$ where how autodiff works comes as both a mathematical surprise, and a computing wonder.  
The example is the Babylonian algorithm, known to mankind for millenia, to compute $\sqrt(x)$:


repeat  

   $~~~~t \leftarrow \frac{(t + \frac{x}{t})}{2}$      

until t converges to $\sqrt(x)$   


Each iteration has one add and two divides.  
For illustration purposes, 10 iterations suffice
"""

# ╔═╡ 1ecd40bc-7fe6-11eb-0a2f-cb9964fc5dbf
md"""
### And now the derivative, almost by magic

In a few lines of code. No mention of $\frac{1}{2}$ over  $\sqrt(x)$. We will use the "dual number" denoted as $D$ in what follows, those where invented by the famous algebraist Clifford in 1873.
"""

# ╔═╡ 4ac7200c-7fe6-11eb-259a-8d881d2f7e3e
struct D <: Number # D is a <function, derivative> pair (a pair of floats)
    f::Tuple{Float64, Float64}
end

# ╔═╡ 54f29be2-7fe6-11eb-38c5-d163b159730a
md"""
- Sum Rule: $(x + y)' = x' + y'$
- Quotient Rule: $(\frac{x}{y})' = \frac{yx' - xy'}{y^2}$
"""

# ╔═╡ 6e7efe02-7fe6-11eb-19a7-8b72c0836c8b
begin
	import Base: +, /, -, *, convert, promote_rule

	## overload: 
	+(x::D, y::D) = D(x.f .+ y.f)
	/(x::D, y::D) = D((x.f[1] / y.f[1], 
			(y.f[1] * x.f[2] - x.f[1] * y.f[2]) / y.f[1]^2))
	-(x::D, y::D) = D(x.f .- y.f)
	*(x::D, y::D) = D((x.f[1] * y.f[1], (y.f[1] * x.f[2] + x.f[1] * y.f[2])))

	## convert ordinary number to Dual number, intro. 0 for derivative
	convert(::Type{D}, x::Real) = D((x, zero(x))) 
	
	## then promote...
	promote_rule(::Type{D}, ::Type{<:Number}) = D 
end

# ╔═╡ 7a9389a2-7fe5-11eb-06b8-c52b073c876a
function babylonian(x; n = 10)
    t = (1. + x) / 2.
    for i ∈ 2:n
        t = (t + x/t) / 2.
    end
    t
end

# ╔═╡ 9091553e-7fe5-11eb-2131-9b1b1097c932
begin
	α = π
	babylonian(α), √α
end

# ╔═╡ b9ccd308-7fe5-11eb-0b0c-efa652660cd5
with_terminal() do
	for α ∈ 2:3
   		println(babylonian(α), " ", √α)
	end
end

# ╔═╡ ff570916-7fe5-11eb-35ab-e915308e7bfc
## WARN: first plots require to load package which takes time

begin
	ix = 0:.01:49

	plot([x -> babylonian(x, n=i) for i ∈ 1:5], 
    	ix, 
    	label=["Iteration $jx" for _ ∈ 1:1, jx ∈ 1:5])

	plot!(sqrt, 
    	ix, 
    	c="darkslateblue", 
    	label="sqrt", 
    	title = "Those Babylonian really knew about √")
end

# ╔═╡ 732679da-7ff0-11eb-1145-3750276a9601
begin
	using LinearAlgebra

	n = 4
	Strang = SymTridiagonal(2 * ones(n), - ones(n-1))
end

# ╔═╡ 6e64c064-7fe6-11eb-1e6d-3dfeebace21b
md"""
The same algorithm with no rewrite at all computes properly the derivative as the check shows:
"""

# ╔═╡ 6e487e0e-7fe6-11eb-23a2-35a3a2ed7015
x₁ = 49; babylonian(D((x₁, 1))), (√x₁, .5 / √x₁)

# ╔═╡ a362fc86-7fe6-11eb-1b7a-03cd0549e790
x₂ = π; babylonian(D((x₂, 1))), (√x₂, .5 / √x₂)

# ╔═╡ a348cb0e-7fe6-11eb-1c9d-4b4278a367aa
md"""
#### It just works!

How does this work?
We will explain in a moment. Right now marvel that it does. Note we did not import any autodiff package. Everything is just basic Julia.


#### The assembler

Most folks don't read assembler, but one can see that it is short (minus comments). The shortness is a clue that suggests speed!

"""

# ╔═╡ a32df540-7fe6-11eb-073f-1b34489aa4a0
with_terminal() do
	@show @inline function babylonian_(x; n = 10)
    	 t = (1 + x) / 2.
     	for i = 2:n; t = (t + x/t) / 2. end
     	t
 	end
end

# ╔═╡ a312dfda-7fe6-11eb-0bae-37587f221888
with_terminal() do
	@code_native babylonian(D((2, 1)))
end

# ╔═╡ 37574936-7fe7-11eb-132a-2df44bf8d6bb
md"""
### Symbolically

We haven't yet explained how it works, but it may be of some value to understand that the below is mathematically equivalent, though not what the computation is doing.
Notice in the below that babylonian works on SymPy Symbols.

Note: Python and Julia are very good friends.It's not a competition! Watch how nicely we can use the same code now in SymPy.

"""

# ╔═╡ 98544e52-7fe7-11eb-1094-9382f7126ce4
with_terminal()do
	x = symbols("x")
	
	println("Iterations as a function of x")
	for k ∈ 1:5
    	println(simplify(babylonian(x, n=k)))
	end
end

# ╔═╡ 98399af8-7fe7-11eb-1276-13c05fa36ed9
with_terminal() do
	x = symbols("x")
	
	println("Derivatives as a function of x")
	
	for k ∈ 1:5
    	println(simplify(diff(simplify(babylonian(x, n=k)), x)))
	end
end

# ╔═╡ 981ea264-7fe7-11eb-06ef-97ee66d5619b
md"""
Let's by hand take the "derivative" of the babylonian iteration with respect to x.

Specifically $t' = \frac{dt}{dx}$. This is the old fashioned way of a human writing code.  
"""

# ╔═╡ d05af69e-7feb-11eb-3874-d1b05fb6434a
function dbabylonian(x; n = 10)
    t = (1. + x) / 2.
    dt = 1. / 2.
    
    for i ∈ 2:n 
        t = (t + x/t) / 2.
        dt = (dt + (t - x * dt) / t^2) / 2.
    end
    dt
end

# ╔═╡ d0310bf4-7feb-11eb-2d05-c9531128eb4a
md"""

Note: 
  -  $t = \frac{1}{2} \times (t + \frac{x}{t})$  

  - then $(\frac{dt}{dx})' = \frac{1}{2} \times (t' + \frac{x' \times t - x \times t'}{t^2})$, as $x' = 1$, we get:  

$(\frac{dt}{dx})' = \frac{1}{2} \times (\frac{t' + (t - x \times t')}{t^2})$
"""

# ╔═╡ d01a58be-7feb-11eb-1f29-6d23db7914da
x= π; dbabylonian(x), .5 / √x

# ╔═╡ cffee818-7feb-11eb-079b-a7dbfdd8cdd6
md"""
What just happened?  

Answer: we created an iteration by hand for t' given our iteration for t, Then we ran the iteration alongside the iteration for t.
"""

# ╔═╡ d0ca45ac-7fec-11eb-202b-87ae22b66616
babylonian(D((x, 1)))

# ╔═╡ d0addd04-7fec-11eb-0213-53ef5d729159
md"""

How did this work?

It created the same derivative iteration that we did by hand, using very general rules that are set once and need not be written by hand (and multiple dispatch).

Important: the derivative is substituted before the JIT compiler, and thus efficient compiled code is executed.
"""

# ╔═╡ d092a21e-7fec-11eb-0cc1-d1515675f521
md"""
### Dual Number Notation

Instead of $D(a, b)$ we can write: $a + b \epsilon$ where $\epsilon$ satisfies $\epsilon^2 = 0$. Some people like to recall imaginary numbers where an $i$ is introduced with $i^2 = -1$. Others like to think of how engineers just fdrop the $O(\epsilon^2)$ terms.  

The four rules are:  
  - 1 & 2. $(a + b\epsilon) \pm (c + d\epsilon) = (a + c) \pm (b + d)\epsilon$
  - 3.$(a + b\epsilon) \times (c + d\epsilon) = (ac) + (bc + ad)\epsilon$
  - 4.$\frac{(a + b\epsilon)}{(c + d\epsilon)} = (\frac{a}{c}) + \frac{(bc - ad)}{d^2}\epsilon$

"""

# ╔═╡ 1818fb9c-7fed-11eb-0bd3-21411f08fcdf
Base.show(io::IO, x::D) = print(io, x.f[1], " + ", x.f[2], " ϵ")

# ╔═╡ 14125e9c-7fef-11eb-3dc4-a75f84383d5d
D((1, 0))

# ╔═╡ 13e452cc-7fef-11eb-2e1d-a5e3b9936a4c
D((0, 2))^2 # should be zero!

# ╔═╡ 13ab59ea-7fef-11eb-2078-6d8ee11d1c90
D((2, 1))^2

# ╔═╡ 2886e6c4-7fef-11eb-0fff-9b3033e4f943
begin
	ϵ = D((0, 1))
	with_terminal() do
		@code_native(ϵ^2)
	end
end

# ╔═╡ 3f1f4bba-7fef-11eb-2f39-cf906aec10ae
ϵ * ϵ

# ╔═╡ 3f037186-7fef-11eb-200f-3579d0ab8e1f
ϵ^2

# ╔═╡ 3eea0d36-7fef-11eb-3ede-c7d54243194c
(1 + ϵ)^5 # note it just works (we did not train powers)

# ╔═╡ 3ece19f8-7fef-11eb-3b91-ff25fd3ca8f4
md"""
### Generalization to arbitrary roots
"""

# ╔═╡ 3eb0843a-7fef-11eb-2c67-9ba2e4d1eefc
function nth_root(x, n=2; t=1, p=10)
    for i = 1:p
        t += (x / t^(n-1) - t) / n
    end
    t
end

# ╔═╡ 5c9fbbc6-7fef-11eb-32ad-b986ca56aa9b
nth_root(2, 3), ∛2  # copied from https://www.alt-codes.net/root-symbols

# ╔═╡ 5c84a84c-7fef-11eb-3117-01f1842890f5
nth_root(2 + ϵ, 3)

# ╔═╡ 5c665cd4-7fef-11eb-2c89-e153a973b30e
nth_root(7, 12), 7^(1/12)

# ╔═╡ 5c4f64ac-7fef-11eb-1864-13f293e85fc4
let x = 2.0
	nth_root( x + ϵ), ∛x, 1/x*(2/3)/3
end

# ╔═╡ 5c33d6ce-7fef-11eb-12c1-29396395358d
md"""
### Forward Diff

Now that you understand it, you can use the official package.
"""

# ╔═╡ 84ddd280-7fef-11eb-29cb-3fc8c8547134
ForwardDiff.derivative(sqrt, 2)

# ╔═╡ 916346b8-7fef-11eb-0d53-29bd11c34510
ForwardDiff.derivative(babylonian, 2)

# ╔═╡ 99672fe6-7fef-11eb-305e-d98ce4bc8dc1
with_terminal() do
	println(@which ForwardDiff.derivative(√, 2))
end

# ╔═╡ be076e8a-7fef-11eb-0741-79beea838677
md"""
### Close Look at Convergence with big floats

the $-log10$ gives the number of correct digits. Watch the quadratic convergence right before your eyes.
"""

# ╔═╡ d5b96cac-7fef-11eb-0772-551e4d96efb2
with_terminal() do
	setprecision(3000)

	# round.(Float64.(log10.([babylonian(BigFloat(2), n=k) for k=1:10] - √BigFloat(2))), 3)
	println(round.(Float64.(log10.([babylonian(BigFloat(2), n=k) - √BigFloat(2.) for k=1:10])), sigdigits=6))
end

# ╔═╡ d59d0508-7fef-11eb-20a3-3f108b859670
struct D1{T} <: Number # D is a <function, derivative> pair
    f::Tuple{T, T}
end

# ╔═╡ d57e75ac-7fef-11eb-1cc7-db506a7e4e2f
begin
	z = D((2., 1.))
	z₁ = D1((BigFloat(2.), BigFloat(1.)))
end

# ╔═╡ fbb04502-7fef-11eb-28fd-414c2f982855
# begin
# 	#import Base: +, /, convert, promote_rule
	
# 	## overload: 
# 	+(x::D1, y::D1) = D1(x.f .+ y.f)
# 	/(x::D1, y::D1) = D1((x.f[1] / y.f[1], (y.f[1] * x.f[2] - x.f[1] * y.f[2]) / y.f[1]^2))

# 	convert(::Type{D1{T}}, x::Real) where {T} = D1((convert(T, x), zero(T))) 
# 	promote_rule(::Type{D1{T}}, ::Type{S}) where {T, S <: Number} = D1{promote_type(T, S)} 
# end

# ╔═╡ 3e2da118-7ff0-11eb-36ca-e32af03b2a0c
A = randn(3, 3)

# ╔═╡ 3e0a484e-7ff0-11eb-17be-e9e7aa66fb2c
x₃= randn(3)

# ╔═╡ 3dd5c57e-7ff0-11eb-3330-cf7d02b5c632
ForwardDiff.gradient(x -> x'A*x, x₃)

# ╔═╡ Cell order:
# ╟─e529f550-7fe3-11eb-06f8-6beaa1506e66
# ╠═9947a66a-7fe5-11eb-0955-87881a67fbea
# ╟─28aa4e9c-7fe4-11eb-3d87-c5a10540c2c1
# ╠═7a9389a2-7fe5-11eb-06b8-c52b073c876a
# ╠═9091553e-7fe5-11eb-2131-9b1b1097c932
# ╠═b9ccd308-7fe5-11eb-0b0c-efa652660cd5
# ╠═ff570916-7fe5-11eb-35ab-e915308e7bfc
# ╟─1ecd40bc-7fe6-11eb-0a2f-cb9964fc5dbf
# ╠═4ac7200c-7fe6-11eb-259a-8d881d2f7e3e
# ╟─54f29be2-7fe6-11eb-38c5-d163b159730a
# ╠═6e7efe02-7fe6-11eb-19a7-8b72c0836c8b
# ╟─6e64c064-7fe6-11eb-1e6d-3dfeebace21b
# ╠═6e487e0e-7fe6-11eb-23a2-35a3a2ed7015
# ╠═a362fc86-7fe6-11eb-1b7a-03cd0549e790
# ╟─a348cb0e-7fe6-11eb-1c9d-4b4278a367aa
# ╠═a32df540-7fe6-11eb-073f-1b34489aa4a0
# ╠═a312dfda-7fe6-11eb-0bae-37587f221888
# ╟─37574936-7fe7-11eb-132a-2df44bf8d6bb
# ╠═9872b1a8-7fe7-11eb-0b3b-cb6181515182
# ╠═98544e52-7fe7-11eb-1094-9382f7126ce4
# ╠═98399af8-7fe7-11eb-1276-13c05fa36ed9
# ╟─981ea264-7fe7-11eb-06ef-97ee66d5619b
# ╠═d05af69e-7feb-11eb-3874-d1b05fb6434a
# ╟─d0310bf4-7feb-11eb-2d05-c9531128eb4a
# ╠═d01a58be-7feb-11eb-1f29-6d23db7914da
# ╟─cffee818-7feb-11eb-079b-a7dbfdd8cdd6
# ╠═d0ca45ac-7fec-11eb-202b-87ae22b66616
# ╟─d0addd04-7fec-11eb-0213-53ef5d729159
# ╟─d092a21e-7fec-11eb-0cc1-d1515675f521
# ╠═1818fb9c-7fed-11eb-0bd3-21411f08fcdf
# ╠═14125e9c-7fef-11eb-3dc4-a75f84383d5d
# ╠═13e452cc-7fef-11eb-2e1d-a5e3b9936a4c
# ╠═13ab59ea-7fef-11eb-2078-6d8ee11d1c90
# ╠═2886e6c4-7fef-11eb-0fff-9b3033e4f943
# ╠═3f1f4bba-7fef-11eb-2f39-cf906aec10ae
# ╠═3f037186-7fef-11eb-200f-3579d0ab8e1f
# ╠═3eea0d36-7fef-11eb-3ede-c7d54243194c
# ╟─3ece19f8-7fef-11eb-3b91-ff25fd3ca8f4
# ╠═3eb0843a-7fef-11eb-2c67-9ba2e4d1eefc
# ╠═5c9fbbc6-7fef-11eb-32ad-b986ca56aa9b
# ╠═5c84a84c-7fef-11eb-3117-01f1842890f5
# ╠═5c665cd4-7fef-11eb-2c89-e153a973b30e
# ╠═5c4f64ac-7fef-11eb-1864-13f293e85fc4
# ╟─5c33d6ce-7fef-11eb-12c1-29396395358d
# ╠═84fc02d6-7fef-11eb-2e21-cb577c3974f0
# ╠═84ddd280-7fef-11eb-29cb-3fc8c8547134
# ╠═916346b8-7fef-11eb-0d53-29bd11c34510
# ╠═99672fe6-7fef-11eb-305e-d98ce4bc8dc1
# ╟─be076e8a-7fef-11eb-0741-79beea838677
# ╠═d5b96cac-7fef-11eb-0772-551e4d96efb2
# ╠═d59d0508-7fef-11eb-20a3-3f108b859670
# ╠═d57e75ac-7fef-11eb-1cc7-db506a7e4e2f
# ╠═fbb04502-7fef-11eb-28fd-414c2f982855
# ╠═3e2da118-7ff0-11eb-36ca-e32af03b2a0c
# ╠═3e0a484e-7ff0-11eb-17be-e9e7aa66fb2c
# ╠═3dd5c57e-7ff0-11eb-3330-cf7d02b5c632
# ╠═732679da-7ff0-11eb-1145-3750276a9601

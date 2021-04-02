### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
begin
	using Pkg
	
	try
		using UnicodePlots
		
	catch ArgumentError
		Pkg.add("UnicodePlots")
		using UnicodePlots
	end
	
	using Test
	using PlutoUI
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Functional Programming

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)
"""

# ╔═╡ 6d80a12a-9649-4438-9a12-36003a57bf86
function deriv(f::Function)::Function
	h = √eps()
	df(x) = (f(x + h) - f(x)) / h
	df
end

# ╔═╡ 5e5c6b37-f3ee-42b1-94cc-686d54171833
md"""
Let us test the `deriv` function. We will use the `UnicodePlots.jl` package to plot a $2×x×x + 5×x - 4$ function and its derivative. 
"""

# ╔═╡ b3faae61-dcdc-473d-9a06-cc890ae74bd7
begin
	f(x) = 2x*x + 5x - 4
	x = -5.:3.;
end

# ╔═╡ 75442ce9-cf92-4800-b1aa-bfdd4229224c
begin
	plot = lineplot(x, f.(x), width=45, height=15, canvas=DotCanvas, name="f(x)");
	plot = lineplot!(plot, x, deriv(f).(x), name="f'(x)")
end

# ╔═╡ a2db212a-02f8-493c-a1f2-43c0e63c31fa
md"""
Next, we can construct a function that solves any quadratic equation in the form

$$ax^2 + bx +c = 0$$
"""

# ╔═╡ 415677ce-d5d6-4808-8789-f5fa66d7f7df
function q_solve(f)
	c = f(0.)
	f1 = deriv(f)
	b = f1(0.) 
	a = f(1,) - b - c
	d = √(b * b - 4 * a * c)
	((-b - d) / 2a, -(-b + d) / 2a)
end

# ╔═╡ bd8d4613-c666-41e3-b877-e9ed6882fe04
@test q_solve(x -> (x - 1) * (x + 7)) == (-7., -1.)

# ╔═╡ b3ee6944-32c7-4dca-ab51-9f1dc0accd91
@test_throws DomainError q_solve(x -> x * x + 1)  ## no solution in the real domain

# ╔═╡ 6486f3b7-9a29-41d1-8d80-514a9212a174
with_terminal() do
	println(q_solve(x -> x * x + 1 + 0im)) 
	## (-7.450580707946e-9 - 1.0000000074505im, 7.450580707946e-9 - 1.0000000074505im)
end

# ╔═╡ 75a80d9a-953e-41c0-9569-2f1c08ca16cd
md"""
Our quadratic solver function takes any quadratic function as its argument. Such functions can be presented as $f(x) = a×x^2 + b×x + c$, and we calculate $f(0)$ to get the $c$ value. 
Next, we calculate `deriv(f)(0)`, which is $(2×a×x + b)(0)$, and hence obtain a numerical approximation of the value of b. 
Finally, we calculate a, and now we can calculate root values of the `f` function. 

Since we did not specify types, our function works not only for real numbers but also for complex numbers. 
This can be observed when comparing the calls `q_solve(x -> x*x + 1)` and 
`q_solve(x -> x*x + 1 + 0im)`. 
The first one fails because `x × x + 1` does not have a solution in the real domain. On the other hand - the second one - using complex numbers, works.
"""

# ╔═╡ Cell order:
# ╟─45d72214-919c-11eb-2e69-23c0786baacb
# ╠═15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
# ╠═6d80a12a-9649-4438-9a12-36003a57bf86
# ╟─5e5c6b37-f3ee-42b1-94cc-686d54171833
# ╠═b3faae61-dcdc-473d-9a06-cc890ae74bd7
# ╠═75442ce9-cf92-4800-b1aa-bfdd4229224c
# ╟─a2db212a-02f8-493c-a1f2-43c0e63c31fa
# ╠═415677ce-d5d6-4808-8789-f5fa66d7f7df
# ╠═bd8d4613-c666-41e3-b877-e9ed6882fe04
# ╠═b3ee6944-32c7-4dca-ab51-9f1dc0accd91
# ╠═6486f3b7-9a29-41d1-8d80-514a9212a174
# ╟─75a80d9a-953e-41c0-9569-2f1c08ca16cd

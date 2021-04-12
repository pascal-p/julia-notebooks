### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 12333bc8-68ca-11eb-2e89-ab9b76b0595b
begin
	using Plots
	using PlutoUI
end

# ╔═╡ f61ae738-68c9-11eb-03c1-efb38291b3ae
md"""
### Plots
"""

# ╔═╡ 27b37bc0-68ca-11eb-0c16-914e5a5ec540
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 2c7cfabe-68ca-11eb-1bee-338af63e7e37
begin
	f(x) = 3 * x^2 + 6 * x - 9

	with_terminal() do
		for x = -5:5    
  			println("(",x, ", ", f(x), ")")
		end
	end
end

# ╔═╡ e63cdbe2-68cb-11eb-20db-4dd54383d017
# pluto interaction

@bind vx html"<input type='range' min='1' max='50' step='0.5' />"

# ╔═╡ 4807bf12-68ca-11eb-37e6-81504bbf1eae
begin
	gr()                  ## Activate the GR backend for use with Plots
	plot(f, -vx, vx)      ## plot f over [-4,3]

	plot!(zero, -vx, vx)  ## horizontal line at y = 0
end

# ╔═╡ 7109711c-68ca-11eb-2c1e-5d0feb06d4cd
with_terminal() do
	println("f(-3), is a root: $(f(-3))")
	println("f(1), is the other root: $(f(1))")
end

# ╔═╡ a2dc225c-68ca-11eb-14b9-3be05028c029
with_terminal() do
	println("f(-1), is the min: $(f(-1))")
end

# ╔═╡ b652dc2c-68ca-11eb-1388-4bff4ac93f75
data = [1.6800483  -1.641695388; 
        0.501309281 -0.977697538; 
        1.528012113 0.52771122;
        1.70012253 1.711524991; 
        1.992493625 1.891000015;
        2.706075824 -0.463427794;
        2.994931927 -0.443566619;
        3.491852811 -1.275179133;
        3.501191722 -0.690499597;
        4.459924502 -5.516130799;
        4.936965851 -6.001703074;
        5.023289852 -8.36416901;
        5.04233698 -7.924477517;
        5.50739285 -10.77482371;
        5.568665171 -10.9171878]

# ╔═╡ c21d59ec-68ca-11eb-04e6-d3453387da46
begin
	gr()           # Activate the GR backend for use with Plots

	x, y = data[:, 1], data[:, 2]
	plot(x, y, linetype=:scatter, leg=false) 
	# scatter(x, y) # this is an alternative method, but does make a legend
end

# ╔═╡ d8bb398a-68ca-11eb-2cb7-c799ea584ad5
begin
	gr()           # Activate the GR backend for use with Plots

	# x, y = data[:, 1], data[:, 2]
	scatter(x, y)  # this is an alternative method, but does make a legend
end

# ╔═╡ fd1df772-68ca-11eb-3d84-2306e2f8b2ff
begin
	n = size(data, 1)
	view(data, n-3:n, :)  # displays 4 last lines
	#                     # no copy made, contrary to data[end-3:end, :]
end

# ╔═╡ 5bb58dae-68cb-11eb-0f14-15a9b6a27a93
begin
	m = 20
	nx = sort(rand(m)); ny = rand(m)

	Plots.scatter(nx, ny)
end

# ╔═╡ 84c33e12-68cb-11eb-2c3f-91955e670357
plot!(nx, ny, leg=false, title="A sample plot")

# ╔═╡ 903feeaa-68cb-11eb-1544-c18b07df0652
plot(nx, ny, leg=false, title="Another sample plot")

# ╔═╡ 223e2023-c974-45ac-920a-489e20bfc3f3
html"""
<style>
  main {
        max-width: calc(800px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background: linen;
  }
  h3, h4 {
        background: wheat;
  }
</style>
"""

# ╔═╡ Cell order:
# ╟─f61ae738-68c9-11eb-03c1-efb38291b3ae
# ╠═12333bc8-68ca-11eb-2e89-ab9b76b0595b
# ╠═27b37bc0-68ca-11eb-0c16-914e5a5ec540
# ╠═2c7cfabe-68ca-11eb-1bee-338af63e7e37
# ╠═e63cdbe2-68cb-11eb-20db-4dd54383d017
# ╠═4807bf12-68ca-11eb-37e6-81504bbf1eae
# ╠═7109711c-68ca-11eb-2c1e-5d0feb06d4cd
# ╠═a2dc225c-68ca-11eb-14b9-3be05028c029
# ╠═b652dc2c-68ca-11eb-1388-4bff4ac93f75
# ╠═c21d59ec-68ca-11eb-04e6-d3453387da46
# ╠═d8bb398a-68ca-11eb-2cb7-c799ea584ad5
# ╠═fd1df772-68ca-11eb-3d84-2306e2f8b2ff
# ╠═5bb58dae-68cb-11eb-0f14-15a9b6a27a93
# ╠═84c33e12-68cb-11eb-2c3f-91955e670357
# ╠═903feeaa-68cb-11eb-1544-c18b07df0652
# ╟─223e2023-c974-45ac-920a-489e20bfc3f3

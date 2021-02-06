### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 6764c13e-681b-11eb-3527-77caf9d74f5b
using PlutoUI

# ╔═╡ 63a5111a-6817-11eb-2151-fb825d7879ba
using Test

# ╔═╡ d24d5ea0-6816-11eb-17d8-b5509f40beca
md"""
### Common Denominator


**Common denominators**

You will have a list of rationals in the form:  
 [ ($numer_1$, $denom_1$) , ... ($numer_n$, $denom_n$) ] 

where all numbers are positive integers.

You have to produce a result in the form
 ($n_1$, $d$) ... ($n_n$, $d$), in which $d$ is as small as possible and
         $\frac{n_1}{d} \equiv \frac{numer_1}{denom_1}$ ... $\frac{n_n}{d} \equiv \frac{numer_n}{denom_n}$.

Example:

`convert_fracs([(1, 2), (1, 3), (1, 4)]) should be [(6, 12), (4, 12), (3, 12)]`

Note:

- Due to the fact that first translations were written long ago - more than 4 years - these translations have only irreducible fractions.
- Newer translations have some reducible fractions. To be on the safe side it is better to do a bit more work by simplifying fractions even if they don't have to be.
"""

# ╔═╡ 69309f32-6817-11eb-0e36-2788da6513af
const VT{T} = Vector{Tuple{T, T}} where T

# ╔═╡ 7bdcddec-6817-11eb-09a5-53e299b8771f
begin
	
function convert_fracs(frac_lst::VT{T})::VT{T} where T <: Integer
    @assert size(frac_lst, 1) > 0
    
    ## 1 - simplify all fractions if possible 
    frac_lst = map(t -> _simplify(t...), frac_lst)
    
    size(frac_lst, 1) == 1 && return frac_lst
    
    ## 2 - determine common denominator
    den_prod = find_common_den(frac_lst)
    
    ## 3 - build new fractions
	[(num * (den_prod / den), den_prod) for (num, den) in frac_lst]
end

function _simplify(num::T, den::T)::Tuple{T, T} where T <: Integer
	gcd = _gcd(num, den)
	(num ÷ gcd, den ÷ gcd)
end

"""
greatest common divisor
 
ex. 
    a=24, b=36 => 12
    a=2, b=8 => 2
    a=3, b=2 => 1
    a=9, b=6 => 3
"""
function _gcd(a::T, b::T)::T where T <: Integer
	a, b =  a > b ? (a, b) : (b, a)
	while true
        r = a % b
		r == 0 && (return b)
		r == 1 && (return r)
		a, b = (b, r)
    end
end

"""
lowest common multiple

ex. 
    a=4, b=3 => 12
    a=2, b=8 => 8
    a=9 (3*3), b=6 (2*3) => 18
"""
function _lcm(a::T, b::T)::T where T <: Integer
    (a * b) ÷ _gcd(a, b)
end

function find_common_den(frac_lst::VT{T})::T where T <: Integer
    den_ary = [den for (_, den) in frac_lst]
    com_den = _lcm(den_ary[1], den_ary[2])
	
    if size(frac_lst, 1) > 2
		com_den = foldl((com_den, cur_den) -> _lcm(com_den, cur_den), 
			den_ary[3:end];
			init=com_den
		)
    end
    return com_den
end

end

# ╔═╡ 07856cdc-681b-11eb-28d3-3b7d32a3afd1
begin
	@test _gcd(3, 4) == 1
	@test _gcd(4, 3) == 1
	@test _gcd(24, 36) == 12
	@test _gcd(8, 2) == 2
	@test _gcd(3, 2) == 1
	@test _gcd(9, 6) == 3
end

# ╔═╡ 1e4f2bce-681b-11eb-00cb-1baae1e5d600
begin
	@test _lcm(3, 4) == 12
	@test _lcm(4, 3) == 12

 	@test _lcm(1, 6) == 6
 	@test _lcm(6, 1) == 6

	@test _lcm(6, 3) == 6
	@test _lcm(3, 5) == 15
	@test _lcm(5, 3) == 15

 	@test _lcm(2, 7) == 14
 	@test _lcm(7, 2) == 14

 	@test _lcm(2*3, 2*2) == 12
end

# ╔═╡ 4c877dc8-681b-11eb-2f8d-bb469d56f840
with_terminal() do
	println(convert_fracs([(1, 2), (1, 3), (1, 4)]))
end

# ╔═╡ 952b7954-681c-11eb-0d11-b7ba99db8b64
begin
	@test convert_fracs([(2, 4)]) == [(1, 2)]
	@test convert_fracs([(1, 2), (1, 3), (1, 4)]) == [(6, 12), (4, 12), (3, 12)]
	@test convert_fracs([(2, 4), (2, 6), (2, 8)]) == [(6, 12), (4, 12), (3, 12)]

	@test convert_fracs([(1, 2), (1, 3)]) == [(3, 6), (2, 6)]

	@test convert_fracs([(1, 3), (1, 2)]) == [(2, 6), (3, 6)]
end

# ╔═╡ Cell order:
# ╟─d24d5ea0-6816-11eb-17d8-b5509f40beca
# ╠═6764c13e-681b-11eb-3527-77caf9d74f5b
# ╠═63a5111a-6817-11eb-2151-fb825d7879ba
# ╠═69309f32-6817-11eb-0e36-2788da6513af
# ╠═7bdcddec-6817-11eb-09a5-53e299b8771f
# ╠═07856cdc-681b-11eb-28d3-3b7d32a3afd1
# ╠═1e4f2bce-681b-11eb-00cb-1baae1e5d600
# ╠═4c877dc8-681b-11eb-2f8d-bb469d56f840
# ╠═952b7954-681c-11eb-0d11-b7ba99db8b64

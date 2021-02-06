### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ b141a11c-6857-11eb-00c9-0d2d762cd167
begin
	using Test
	using BenchmarkTools
	using PlutoUI
end

# ╔═╡ 9b574d24-6855-11eb-1af8-d1c2ccf2f3b0
md"""
### Alphametcis aka CryptArithmetics 


[Alphametics](https://en.wikipedia.org/wiki/Verbal_arithmetic) is a type of cryptarithm (or  cryptarithmetic) in which a set of words is written down in the form of a long addition sum or some other mathematical problem. The objective is to replace the letters of the alphabet with decimal digits to make a valid arithmetic sum.  

For this kata, your objective is to write a function that accepts an alphametic equation in the form of a single-line string and returns a valid arithmetic equation in the form of a single-line string.

"""

# ╔═╡ e420b680-6855-11eb-2464-8b09ef6b45ae
md"""
**Test Examples**

INPUT: `"SEND + MORE = MONEY"`  
SOLUT: `"9567 + 1085 = 10652"`  
```
  S E N D
+ M O R E
---------
M O N E Y
```

INPUT: `"ELEVEN + NINE + FIVE + FIVE = THIRTY"`  
SOLUT: `"797275 + 5057 + 4027 + 4027 = 810386"`  
```
  E L E V E N 
+     N I N E 
+     F I V E
+     F I V E
-------------
  T H I R T Y
```

Some puzzles may have multiple valid solutions; your function only needs to return one:  
BIG + CAT = LION  
403 + 679 = 1082  
326 + 954 = 1280  
304 + 758 = 1062  
...etc.


Technical Details
- All alphabetic letters in the input will be uppercase
- Each unique letter may only be assigned to one unique digit (bijective mapping)
- As a corollary to the above, there will be a maximum of 10 unique letters in any given test
- No leading zeroes
- The equations will only deal with addition with multiple summands on the left side
(summands are LHS, ex: SEND, MORE ...) and one term on the right side
- The number of summands will range between 2 and 7, inclusive
- The length of each summand will range from 2 to 8 characters, inclusive
- All test cases will be valid and will have one or more possible solutions
- Optimize your code -- a naive, brute-force algorithm may time out before the first test completes
"""

# ╔═╡ 93fbf81c-6856-11eb-0a43-bfaa709a504a
md"""
**Resolution** 

```
  S E N D
+ M O R E
---------
M O N E Y
```

*  $M is 1$, obviously (it cannot be 0)
*  $D + E = Y + 10.c_1$ 
*  $c_1 + N + R = E + 10.c_2$
*  $c_2 + E + O = N + 10.c_3$
*  $c_3 + S + M = O + 10.c_4$
*  $c_4 = M  \equiv 1 = M$ 

Hence $\color{blue}{M = 1}$
    
System can be rewritten as follows:
* (i) $\space D + E = Y + 10.c_1$ 
* (ii) $\space c_1 + N + R = E + 10.c_2$
* (iii) $\space c_2 + E + O = N + 10.c_3$
* (iv) $\space c_3 + S + 1 = O + 10 \equiv c_3 + S = O + 9$

From (iv): 
$\space c_3 + S = O + 9 \Rightarrow (c_3=0 \land S=9, O=0) \lor (c_3=1 \Rightarrow S = O + 8 \Rightarrow S \ge 8, O \lt 2) => O=1 \Rightarrow \varnothing$ ($M=1$ already).  

Hence $\color{blue}{O = 0}$   

From (iii) $r_2 + E + 0 = N + 10.r_3 \Rightarrow r_2 + E = N + 10.r_3$  
$r_2 + E = N + 10.r_3$, if $r_3 = 1 \Rightarrow r_2 + E = N + 10$, 2 cases:
*  $r_2 = 0, \space 0 + E = N + 10 \equiv E = N + 10$, this is impossible
*  $r_2 = 1, \space 1 + E = N + 10 \equiv E = N + 9 => N=0 \land E=9$, this is impossible, because $O=0$

Hence $r_3 = 0 \land \color{blue}{S=9}$  

From (iii): $r_2 + E = N$, 2 cases:
*  $r_2 = 0, \space E = N \space \Rightarrow impossible$
*  $r_2 = 1, \space 1 + E = N$

Hence $r_2 = 1$

From (ii): $r_1 + N + R = E + 10 \equiv r_1 + N + R = N - 1 + 10 \equiv r_1 + R = 9$, given $S = 9$:  
$r_1 = 1 \land \color{blue}{R = 8}$

From (i), $D + E = Y + 10$ and $1 + E = N$:
* we have $Y \ge 1$
* we know maximum $D + E = 13$ (as 9, 8 are already taken, so D, E would be (6, 7) or (7, 6).
* But $E = 7 \Rightarrow N = 8$, impossible
* And $E = 6 \Rightarrow N = 7 \land D = 7$, impossible

Thus:
* E is 5, 4, ~3, 2, 1~ and  
* N is 6, 5, ~4, 3, 2~ and  
* D 7, 6 and  
* Y = (7 + 5 - 10 =) 2, ~(6 + 4 -10) 0~  

Hence $\color{blue}{Y = 2}$ (only possibility) $\Rightarrow \color{blue}{E =5} \land \color{blue}{N=6}$

"""

# ╔═╡ 9c4e7976-6857-11eb-3197-7da4e0930506
md"""
Some more examples:  
* `  D A Y S  +     T O O =   S H O R T`
* `    T W O  +   D A Y S =     M O R E`
* `  W A I T  +     A L L =   G I F T S`
* `  N I N E  +   F I V E =   W I V E S`
* `  E V E R  + S I N C E = D A R W I N` 
* `    U S A  +   U S S R =   P E A C E`
* `P O I N T  +   Z E R O = E N E R G Y`
* `      G O  +       T O =       O U T`

* ` E A T  +  E A T  +  E A T = B E E T`
"""

# ╔═╡ bce4f3cc-6857-11eb-19f4-dd998acaeafe
begin
	const ALL_DIGITS = [d for d in 0:9]

	_input = "SEND + MORE = MONEY"
	_s, _result = map(strip, split(_input, '='))
end

# ╔═╡ bee7b3f8-6857-11eb-2ccd-e7202568155d
_summands = map(strip, split(_s, "+"))

# ╔═╡ bfcee1b0-6857-11eb-36b6-e1bb043a08e8
function words_result(str::String)
    s, res = map(strip, split(str, '='))
    summands = map(strip, split(s, "+"))
	
    (result=split(res, ""), summands=map(s -> split(s, ""), summands))
end

# ╔═╡ c14aade4-6857-11eb-21ea-51b53292b1af
with_terminal() do
	println(words_result("SEND + MORE = MONEY"))
end

# ╔═╡ c1f15cf0-6857-11eb-2fb8-d95ee8623319
function wr_tuple_rev(wr_tuple)
    """
    ```jldoctest
    julia> wr_tuple = (result = ["M", "O", "N", "E", "Y"], summands = [["S", "E", "N", "D"], ["M", "O", "R", "E"]])
    julia> wr_tuple_rev(wr_tuple)
    (result = ["Y", "E", "N", "O", "M"], summands = [["D", "N", "E", "S"], ["E", "R", "O", "M"])
    ```
    """
    res = reverse(wr_tuple.result)
    sums = map(reverse, wr_tuple.summands)
    
	(result=res, summands=sums)
end

# ╔═╡ c20ce150-6857-11eb-0c50-bdb013339921
with_terminal() do
	wr_tuple = (result = ["M", "O", "N", "E", "Y"], 
		summands = [["S", "E", "N", "D"], ["M", "O", "R", "E"]])

	println(wr_tuple_rev(wr_tuple))
end

# ╔═╡ 48cb2262-6858-11eb-3dc4-fbfb36ff2ab3
begin
	wr_tuple1 = (result = ["M", "O", "N", "E", "Y"], 
		summands = [["S", "E", "N", "D"], ["M", "O", "R", "E"]])
	@test wr_tuple_rev(wr_tuple1) == (result = ["Y", "E", "N", "O", "M"], 
		summands = [["D", "N", "E", "S"], ["E", "R", "O", "M"]])

	wr_tuple2 = (result = ["T", "H", "I", "R", "T", "Y"], 
		summands = [["E", "L", "E", "V", "E", "N"], ["N", "I", "N", "E"], ["F", "I", "V", "E"], ["F", "I", "V", "E"]])
	
	@test wr_tuple_rev(wr_tuple2) == (result = ["Y", "T", "R", "I", "H", "T"], 
		summands = [["N", "E", "V", "E", "L", "E"], ["E", "N", "I", "N"], ["E", "V", "I", "F"], ["E", "V", "I", "F"]])

end


# ╔═╡ 8d0d5940-6858-11eb-1155-dbe742a87729
function all_letters(str::String)
    split(replace(str, ['+', ' ', '='] => ""),
		"") |> 
		sort |>
		unique
end

# ╔═╡ e2b38092-6858-11eb-1305-115e60d9ce26
with_terminal() do
	println(all_letters("SEND + MORE = MONEY"))
end

# ╔═╡ 123426e4-6859-11eb-1857-150829245eca
begin
	@test all_letters("SEND + MORE = MONEY") == [
		"D", "E", "M", "N", "O", "R", "S", "Y"
	]

	@test all_letters("ELEVEN + NINE + FIVE + FIVE = THIRTY") == [
		"E", "F", "H", "I", "L", "N", "R", "T", "V", "Y"
	]
end

# ╔═╡ 3882e254-6859-11eb-19d4-bfb9921902f2
mutable struct AExpr
    lhs::String
    rhs::String
end

# ╔═╡ 3f8cfd78-6859-11eb-07c2-8f02f60fc0a3
Base.show(io::IO, aexpr::AExpr) = print(io, "lhs: $(aexpr.lhs) = rhs: $(aexpr.rhs)")

# ╔═╡ 45a9e11c-6859-11eb-3266-cb2f4081e7de
function gen_constraints(wr_tuple_rev)::Tuple{Array{AExpr, 1}, Array{String, 1}}
    len_res = length(wr_tuple_rev.result)
    constraints = []
    ix, aexpr = 1, AExpr("", "") 
    symbols = Vector{String}([])
    
    while true  
        ## lhs
        for ary in wr_tuple_rev.summands
            if ix ≤ length(ary)
                ary[ix] ∈ symbols || push!(symbols, ary[ix])
                aexpr.lhs = isempty(aexpr.lhs) ? "$(ary[ix])" : "$(aexpr.lhs) + $(ary[ix])"
            end
        end
        
        ## rhs
        wr_tuple_rev.result[ix] ∈ symbols || push!(symbols, wr_tuple_rev.result[ix])
        aexpr.rhs = ix == length(wr_tuple_rev.result) ? "$(wr_tuple_rev.result[ix])" :
        	"$(wr_tuple_rev.result[ix]) + 10 * c_$(ix)"
        push!(constraints, aexpr)
        
        ## next 
        ix += 1
        ix > len_res && break
        
        ## next carry
        aexpr = AExpr("c_$(ix - 1)", "")
        push!(symbols, "c_$(ix - 1)")
    end
    
    (constraints, symbols)
end

# ╔═╡ 10d6c6a2-685a-11eb-269d-3f92f1a94fe1
begin
	wr_tuple_rev1 = wr_tuple_rev(wr_tuple1)
	
	constraint_ary, symbol_ary = gen_constraints(wr_tuple_rev1)
	with_terminal() do
		println("constraints: $(constraint_ary)")
		println("symbols: $(symbol_ary)")
	end
end

# ╔═╡ 8b681600-685a-11eb-0bfd-bbaf19e1a22b
md"""
Remarks:  
-  $\forall i, c_i ∈ [0, 1]$  
-  $S \neq 0 \land M \neq 0$
"""

# ╔═╡ b8855382-685a-11eb-2bd4-7f7d3557d836
begin
	const ETYPES = (:carry, :var)  # Symbol Expression type either :carry or :var

	with_terminal() do
		println(typeof(ETYPES))
	end
end

# ╔═╡ e2e282da-685a-11eb-32b2-116fce22d9d3
mutable struct Elem
    symbol::String
    value::Union{Nothing, Int}
    pvalues::Set{Int}
    etype::Symbol
end

# ╔═╡ e71d56b8-685a-11eb-367c-c37ad541bdf4
begin
	hsymbols = Dict{String, Elem}()

	for k ∈ symbol_ary
    	cond = match(r"\Ac_\d+", k) != nothing
    	hsymbols[k] = Elem(
        	k, 
        	nothing, 
        	cond ? Set([0, 1]) : Set(collect(0:9)),
        	cond ? ETYPES[1] : ETYPES[2] # ETYPES][1] == :carry, ETYPES][2] == :var
    	)
end

	with_terminal() do
		println(hsymbols)
	end
end

# ╔═╡ 0f3277dc-685b-11eb-2bc5-d7cadea01388
begin
const NT{T} = NamedTuple{(:lhs, :rhs), T} where T <: Tuple
	
function gen_constraints_as_expr(ary::Vector{AExpr})::Vector{NT}
	map(aexpr -> (lhs=Meta.parse(aexpr.lhs), rhs=Meta.parse(aexpr.rhs)), 
			ary)
end
	
end

# ╔═╡ 9fb53268-685b-11eb-18cc-5d103022febf
const AEXPR_LST = gen_constraints_as_expr(constraint_ary)

# ╔═╡ 0c9579e2-685c-11eb-0985-b323f500064c
md"""
#### Evaluation
"""

# ╔═╡ 1816ffd4-685c-11eb-218c-3985c1e8fd40
function eval_aexpr(aexpr_lst::Array{NamedTuple{(:lhs, :rhs),T} where T<:Tuple,1}, d_env)
    # set the env
    [@eval $(Symbol("$(k)")) = ($v) for (k, v) in d_env]
    
    for aexpr in aexpr_lst
      try
      	lhs = eval(aexpr.lhs)
        rhs = eval(aexpr.rhs)
        
        if (lhs != rhs) 
          println("eval: $(aexpr.lhs)[==$(lhs)] != $(aexpr.rhs)[==$(rhs)] - false / stop")
          return false
        else
          println("eval: $(aexpr.lhs)[==$(lhs)] == $(aexpr.rhs)[==$(rhs)] - true / continue")
        end
            
      catch ex
      	println("[!] lhs: $(aexpr.lhs) / rhs: $(aexpr.rhs) - not eval-uable")
        continue
      end
    end
    
    true
end

# ╔═╡ 686aed92-685c-11eb-295b-81d603e5eedc
with_terminal() do
	eval_aexpr(AEXPR_LST, 
		merge(hsymbols, Dict("D" => 9, "E" => 2, "Y" => 3, "c_1" => 0)))
end

# ╔═╡ 9a573124-685c-11eb-107a-05702bbfc2f2
with_terminal() do
	eval_aexpr(AEXPR_LST, 
		merge(hsymbols, Dict("c_4" => 1, "M" => 1)))
end

# ╔═╡ a0855ff0-685c-11eb-3b70-b7c6d257b1bf
with_terminal() do
	eval_aexpr(AEXPR_LST, 
		merge(hsymbols, Dict("c_4" => 1, "M" => 2, "D" => 3, "E" => 1, "Y" => 5, "c_1" => 0)))
end

# ╔═╡ bd6bf02a-685c-11eb-1b01-d9dfda6e8f91
with_terminal() do
	eval_aexpr(AEXPR_LST, 
		merge(hsymbols, Dict("c_4" => 1, "M" => 2, "D" => 4, "E" => 1, "Y" => 5, "c_1" => 0)))
end

# ╔═╡ db3fe086-685c-11eb-0a28-e7529365d7b8
with_terminal() do
	eval_aexpr(AEXPR_LST, 
		merge(hsymbols, Dict("c_4" => 1, "M" => 1, "D" => 5, "E" => 2, "Y" => 7, "c_1" => 0)))
end

# ╔═╡ f288a028-685c-11eb-07f2-3de80f49b384
md"""
#### System

Possible Strategy:
* Start with equation with less constraints (in term of length and number of constraints
* LHS (1 symb) = RHS (1 symb) and LHS $\neq$ RHS $\Rightarrow$ solution = LHS $\cap$ RHS 

Constraints:
* Leftmost symbols cannot be 0
* All Symbols have different values

"""

# ╔═╡ ff22edf2-685c-11eb-226e-c9470f8902e9
with_terminal() do
	println(AEXPR_LST)
end

# ╔═╡ 2304a31e-685d-11eb-2c68-037fefdb684f
with_terminal() do
	t = AEXPR_LST[1]
	
	println(cat(t.lhs.args[2:end], t.rhs.args[2:end]; dims=1))
end

# ╔═╡ 38b95e48-685d-11eb-3c4a-8fd1e28d00a6
with_terminal() do
	t = AEXPR_LST[1]
	
	println(vcat(t.lhs.args[2:end], t.rhs.args[2:end]))
end

# ╔═╡ 659a12a2-685d-11eb-1c32-6b53b431ac9a
function find_eqn_with_less_contraints(aexpr_lst)
    """
    Find equation in given aexpr_lst, which has the less element(s)
    returns first equation if all equations have same number of elements (or members) 
    """
    ary, nmin = fill(0, 3), 10_000_000
    
    for (ix, t) in enumerate(aexpr_lst)
        _ary = fill(ix, 3)
        for (jx, ths) in enumerate(t)
            _ary[jx + 1] = if typeof(ths) == Expr
				length(ths.args[2:end])
			elseif typeof(ths) == Symbol
				1
			end
        end    
        n = _ary[2] + _ary[end]
        if n < nmin
            nmin = n
            for i in 1:3
                ary[i] = _ary[i]
            end
        end
    end
    ary
end

# ╔═╡ b3775770-685d-11eb-3090-dbbc1689f1d0
with_terminal() do
	ary = find_eqn_with_less_contraints(AEXPR_LST) 
	println(ary)
end

# ╔═╡ e5ae84de-685d-11eb-2377-918cd4b53af4
function non_leading_0!(hsymbols, wr_tuple)
    sym = wr_tuple.result[1]
    hsymbols[sym].pvalues = Set(collect(1:9))
    
    for s in wr_tuple.summands
        hsymbols[s[1]].pvalues = Set(collect(1:9))
    end
    
    hsymbols
end

# ╔═╡ f2fb7c8c-685d-11eb-0def-01b7643c6547
with_terminal() do
	wr_tuple = (result = ["M", "O", "N", "E", "Y"], 
		summands = [["S", "E", "N", "D"], ["M", "O", "R", "E"]])
	
	println(non_leading_0!(hsymbols, wr_tuple))
end

# ╔═╡ 4ced4446-685e-11eb-3431-c3de701b63a6
function lhs_rhs_singleton!(hsymb, aexpr_lst)
    ix, n_l, n_r = find_eqn_with_less_contraints(aexpr_lst)
    
    if n_l == n_r && n_r == 1 
		## we have 1 equation with singleton element on both side, simplify! 
        lhs_sym = aexpr_lst[ix].lhs
        rhs_sym = aexpr_lst[ix].rhs
        set_ = intersect(
			hsymb[String(lhs_sym)].pvalues, 
			hsymb[String(rhs_sym)].pvalues
		)
        hsym[String(lhs_sym)].pvalues = set_
        hsym[String(rhs_sym)].pvalues = set_
        
        if length(set_) == 1
            hsymb[String(lhs_sym)].value = first(set_)
            hsymb[String(rhs_sym)].value = first(set_)            
            
			## this value needs to be remove from all pvalues of all 
			## remaining variables
            for sym ∈ keys(hsymb)
                hsymb[sym].etype == :carry && continue # ignore carries
                hsymb[sym].pvalues = setdiff(hsymb[sym].pvalues, set)
            end
        end
    end
end

# ╔═╡ dcc9489e-685e-11eb-315e-e34875afae1e
with_terminal() do
	println(eval_aexpr(AEXPR_LST, 
		Dict(k => hsymbols[k].value for k in keys(hsymbols))
	))
end

# ╔═╡ fb37bad6-685e-11eb-0314-73160a66b806
md"""
*TBC...*
"""

# ╔═╡ Cell order:
# ╟─9b574d24-6855-11eb-1af8-d1c2ccf2f3b0
# ╟─e420b680-6855-11eb-2464-8b09ef6b45ae
# ╠═93fbf81c-6856-11eb-0a43-bfaa709a504a
# ╟─9c4e7976-6857-11eb-3197-7da4e0930506
# ╠═b141a11c-6857-11eb-00c9-0d2d762cd167
# ╠═bce4f3cc-6857-11eb-19f4-dd998acaeafe
# ╠═bee7b3f8-6857-11eb-2ccd-e7202568155d
# ╠═bfcee1b0-6857-11eb-36b6-e1bb043a08e8
# ╠═c14aade4-6857-11eb-21ea-51b53292b1af
# ╠═c1f15cf0-6857-11eb-2fb8-d95ee8623319
# ╠═c20ce150-6857-11eb-0c50-bdb013339921
# ╠═48cb2262-6858-11eb-3dc4-fbfb36ff2ab3
# ╠═8d0d5940-6858-11eb-1155-dbe742a87729
# ╠═e2b38092-6858-11eb-1305-115e60d9ce26
# ╠═123426e4-6859-11eb-1857-150829245eca
# ╠═3882e254-6859-11eb-19d4-bfb9921902f2
# ╠═3f8cfd78-6859-11eb-07c2-8f02f60fc0a3
# ╠═45a9e11c-6859-11eb-3266-cb2f4081e7de
# ╠═10d6c6a2-685a-11eb-269d-3f92f1a94fe1
# ╟─8b681600-685a-11eb-0bfd-bbaf19e1a22b
# ╠═b8855382-685a-11eb-2bd4-7f7d3557d836
# ╠═e2e282da-685a-11eb-32b2-116fce22d9d3
# ╠═e71d56b8-685a-11eb-367c-c37ad541bdf4
# ╠═0f3277dc-685b-11eb-2bc5-d7cadea01388
# ╠═9fb53268-685b-11eb-18cc-5d103022febf
# ╟─0c9579e2-685c-11eb-0985-b323f500064c
# ╠═1816ffd4-685c-11eb-218c-3985c1e8fd40
# ╠═686aed92-685c-11eb-295b-81d603e5eedc
# ╠═9a573124-685c-11eb-107a-05702bbfc2f2
# ╠═a0855ff0-685c-11eb-3b70-b7c6d257b1bf
# ╠═bd6bf02a-685c-11eb-1b01-d9dfda6e8f91
# ╠═db3fe086-685c-11eb-0a28-e7529365d7b8
# ╟─f288a028-685c-11eb-07f2-3de80f49b384
# ╠═ff22edf2-685c-11eb-226e-c9470f8902e9
# ╠═2304a31e-685d-11eb-2c68-037fefdb684f
# ╠═38b95e48-685d-11eb-3c4a-8fd1e28d00a6
# ╠═659a12a2-685d-11eb-1c32-6b53b431ac9a
# ╠═b3775770-685d-11eb-3090-dbbc1689f1d0
# ╠═e5ae84de-685d-11eb-2377-918cd4b53af4
# ╠═f2fb7c8c-685d-11eb-0def-01b7643c6547
# ╠═4ced4446-685e-11eb-3431-c3de701b63a6
# ╠═dcc9489e-685e-11eb-315e-e34875afae1e
# ╟─fb37bad6-685e-11eb-0314-73160a66b806

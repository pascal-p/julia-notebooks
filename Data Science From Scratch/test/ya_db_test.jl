push!(LOAD_PATH, "./src")

using Test
using YaDB


function feed_db()
  Users = Table([:name => String, :num_friends => Int])

  insert(Users, [[0, "Hero", 0],
      [1, "Dunn", 2],
      [2, "Sue", 3],
      [3, "Chi", 3],
      [4, "Thor", 3],
      [5, "Clive", 2],
      [6, "Hicks", 3],
      [7, "Devin", 2],
      [8, "Kate", 2]
  ])
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  insert(Users, [:name => "PasMas", :num_friends => 5])

  Users
end

function feed_db_nv()  ## With null values
  Users = Table([:name => U_SN, :num_friends => U_IN])

  insert(Users, [[0, "Hero", 0],
      [1, "Dunn", 2],
      [2, "Sue", 3],
      [3, "Chi", 3],
      [4, "Thor", nothing],
      [5, "Clive", 2],
      [6, "Hicks", 3],
      [7, "Devin", nothing],
      [8, "Kate", 2]
  ])
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  insert(Users, [:name => "PasMas", :num_friends => 5])

  Users
end

# ======================================================================

# using Pkg; Pkg.activate("MLJ_env", shared=true); push!(LOAD_PATH, "./src"); using YaDB;
# Users = Table([:name => U_SN, :num_friends => U_IN]; pkey=(:user_id => Int))

# insert(Users, Dict(:name => "Ayumi", :num_friends => 5))

# # OK insert/1
# insert(Users, [:name => "PasMas", :num_friends => 3, id(Users) => 3])
# insert(Users, [id(Users) => 17, :name => "Foo", :num_friends => nothing])
# insert(Users, [id(Users) => 77, :name => "FooFoo", :num_friends => nothing])


# # The type below is ambiguous, no way to tell that num_friends is Int or Nothing
# insert(Users, [:name => "FooBar", :num_friends => nothing])
# ======================================================================

@testset "Create Table/1" begin
  Users = Table([:name => String, :num_friends => Int]; pkey=(:user_id => Int))

  @test length(Users) == 0
  @test sort(Users.columns) == [:name, :num_friends, :user_id]
  @test id(Users) == :user_id
end

@testset "Create Table - default pkey" begin
  Users = Table([:name => String, :num_friends => Int])

  @test length(Users) == 0
  @test sort(Users.columns) == [:id, :name, :num_friends]
  @test id(Users) == :id
end

@testset "Insert rows" begin
  Users = Table([:name => String, :num_friends => Int]; pkey=(:user_id => Int))

  ## using Dict + pkey value
  insert(Users, [id(Users) => 1, :name => "Dunn", :num_friends => 2])
  @test length(Users) == 1
  @test Users.rows[1][:name] == "Dunn"

  ## using only Dict => pkey value auto. gen.
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  @assert length(Users) == 2

  ## re-insert (with same pkey) is a NO-OP
  insert(Users, [id(Users) => 1, :name => "Dunn", :num_friends => 2])
  @assert length(Users) == 2

  ## mass insertion
  insert_v = [
     [5, "Chi", 3],
     [6, "Thor", 3],
     [7, "Clive", 2],
     [8, "Devin", 2],
     [9, "Kate", 2 ]
  ]
  insert(Users, insert_v)
  @test length(Users) == 2 + length(insert_v)
end

@testset "Insert rows / NULL value as nothing" begin
  Users = Table([:name => U_SN, :num_friends => U_IN]; pkey=(:user_id => Int))

  ## using Dict + pkey value
  insert(Users, [id(Users) => 1, :name => "Dunn", :num_friends => 2])
  @test length(Users) == 1
  @test Users.rows[1][:name] == "Dunn"

  ## using only Dict => pkey value auto. gen.
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  @assert length(Users) == 2

  ## re-insert (with same pkey) is a NO-OP
  insert(Users, [id(Users) => 1, :name => "Dunn", :num_friends => 2])
  @assert length(Users) == 2

  ## insert with 'null' value => encoded as nothing, with pkey
  insert(Users, [id(Users) => 17, :name => "Foo", :num_friends => nothing])
  @assert length(Users) == 3

  ## insert with 'null' value => encoded as nothing, with pkey
  insert(Users, [:name => "Bar", :num_friends => nothing])
  @assert length(Users) == 4

  ## mass insertion
  insert_v = [
     [5, "Chi", 3],
     [6, "Thor", 3],
     [7, "Clive", 2],
     [8, "Devin", 2],
     [9, "Kate", 2 ],
     [10, "Tom", nothing]
  ]
  insert(Users, insert_v)
  @test length(Users) == 4 + length(insert_v)
end


@testset "Update rows" begin
  Users = Table([:name => String, :num_friends => Int]; pkey=(:id => Int))
  insert(Users, [:id => 1, :name => "Dunn", :num_friends => 2])
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  @test length(Users) == 2

  update(Users, Dict{Symbol, Any}(:num_friends => 7), row -> row[:name] == "Ayumi")
  @test length(Users) == 2
  @test Users.rows[2][:num_friends] == 7 && Users.rows[2][:name] == "Ayumi"

  ## several updates: users with 3 friends have now 4 friends
  insert_v = [
     [5, "Chi", 3],
     [6, "Thor", 3],
     [7, "Clive", 2],
     [8, "Devin", 2],
     [9, "Kate", 2 ]
  ]
  insert(Users, insert_v)
  @test filter(r -> r[:num_friends] == 3, Users.rows) |> length == 2

  update(Users, Dict{Symbol, Any}(:num_friends => 4), row -> row[:num_friends] == 3)
  @test filter(r -> r[:num_friends] == 3, Users.rows) |> length == 0
  @test filter(r -> r[:num_friends] == 4, Users.rows) |> length == 2
end

@testset "Update rows / NULL value as nothing" begin
  Users = Table([:name => U_SN, :num_friends => U_IN]; pkey=(:user_id => Int))

  insert(Users, [id(Users) => 1, :name => "Dunn", :num_friends => 2])
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  @test length(Users) == 2

  update(Users, Dict{Symbol, Any}(:num_friends => 7), row -> row[:name] == "Ayumi")
  @test length(Users) == 2
  @test Users.rows[2][:num_friends] == 7 && Users.rows[2][:name] == "Ayumi"

  ## several updates: users with 3 friends have now 4 friends
  insert_v = [
     [5, "Chi", 3],
     [6, "Thor", 3],
     [7, "Clive", 2],
     [8, "Devin", nothing],
     [9, "Kate", nothing ]
  ]
  insert(Users, insert_v)
  @test filter(r -> r[:num_friends] == 3, Users.rows) |> length == 2

  update(Users, Dict{Symbol, Any}(:num_friends => 4), row -> row[:num_friends] == 3)
  @test filter(r -> r[:num_friends] == 3, Users.rows) |> length == 0
  @test filter(r -> r[:num_friends] == 4, Users.rows) |> length == 2

  update(Users, Dict{Symbol, Any}(:num_friends => 1), row -> row[:num_friends] === nothing)
  @test filter(r -> r[:num_friends] === nothing, Users.rows) |> length == 0
  @test filter(r -> r[:num_friends] == 1, Users.rows) |> length == 2
end

@testset "Delete rows" begin
  Users = Table([:name => String, :num_friends => Int]; pkey=(:id => Int))
  insert_v = [
     [5, "Chi", 3],
     [6, "Thor", 3],
     [7, "Clive", 2],
     [8, "Devin", 2],
     [9, "Kate", 2 ]
  ]
  insert(Users, insert_v)
  @test length(Users) == length(insert_v)

  delete(Users, row -> row[:num_friends] == 3)
  @test length(Users) == length(insert_v) - 2

  delete(Users)
  @test length(Users) == 0
end

@testset "Delete rows / NULL value as nothing" begin
  Users = Table([:name => U_SN, :num_friends => U_IN]; pkey=(:user_id => Int))
  insert_v = [
     [5, "Chi", 3],
     [6, "Thor", nothing],
     [7, "Clive", 2],
     [8, "Devin", nothing],
     [9, "Kate", 2 ]
  ]
  insert(Users, insert_v)
  @test length(Users) == length(insert_v)

  delete(Users, row -> row[:num_friends] === nothing)
  @test length(Users) == length(insert_v) - 2

  delete(Users)
  @test length(Users) == 0
end


@testset "Select / where / limit" begin
  Users = feed_db()
  n = length(Users)
  user_names = select(Users, keep_cols=[:name])

  @test length(user_names) == n
  @test user_names.columns == [:name]

  dunn_ids = where(Users, row -> row[:name] == "Dunn") |>
    u -> select(u, keep_cols=[:id])
  @test length(dunn_ids) == 1
  @test dunn_ids.rows[1][:id] == 1

  amp_name_ids = where(Users, row -> row[:name][1] ∈ ['A', 'P']) |>
    u -> select(u, keep_cols=[:id, :name])
  @test length(amp_name_ids) == 2
  @test amp_name_ids.rows[1][:name] ∈ ["Ayumi", "PasMas"]
  @test amp_name_ids.rows[2][:name] ∈ ["Ayumi", "PasMas"]

  ext_user = name_lengths₂ = select(Users;
    add_cols=Dict{Symbol, Function}(
      :name_ini => row -> string(row[:name][1]),
      :len_name => row -> length(row)
    )
  )
  @test sort(ext_user.columns) == Symbol[:id, :len_name, :name, :name_ini, :num_friends]
end

@testset "Select / where / limit / NULL value as nothing" begin
  Users = feed_db_nv()
  n = length(Users)
  user_names = select(Users, keep_cols=[:name])

  @test length(user_names) == n
  @test user_names.columns == [:name]

  dunn_ids = where(Users, row -> row[:name] == "Dunn") |>
    u -> select(u, keep_cols=[:id])
  @test length(dunn_ids) == 1
  @test dunn_ids.rows[1][:id] == 1

  amp_name_ids = where(Users, row -> row[:name][1] ∈ ['A', 'P']) |>
    u -> select(u, keep_cols=[:id, :name])
  @test length(amp_name_ids) == 2
  @test amp_name_ids.rows[1][:name] ∈ ["Ayumi", "PasMas"]
  @test amp_name_ids.rows[2][:name] ∈ ["Ayumi", "PasMas"]

  ext_user = name_lengths₂ = select(Users;
    add_cols=Dict{Symbol, Function}(
      :name_ini => row -> string(row[:name][1]),
      :len_name => row -> length(row)
    )
  )
  @test sort(ext_user.columns) == Symbol[:id, :len_name, :name, :name_ini, :num_friends]
end


@testset "Group by/1" begin
  Users = feed_db()

  """
  -- find number of users and smallest user_id for each possible name length:
  SELECT LENGTH(name) as name_length, MIN(user_id) AS min_user_id,
    COUNT(*) AS num_users
  FROM users
  GROUP BY LENGTH(name);
    """
  name_len_fn = row -> length(row[:name])
  min_user_id = rows -> minimum(row[:id] for row ∈ rows)
  num_rows = rows -> length(rows)

  stats_by_len = select(Users, add_cols=D_SF(:name_length => name_len_fn)) |>
    u -> group_by(u,
        group_by_cols=[:name_length],
        agg=D_SF(:min_user_id => min_user_id, :num_users => num_rows))

  @test sort(stats_by_len.columns) == [:min_user_id, :name_length, :num_users]
  @test length(stats_by_len.rows) == 4
end

@testset "Group by/1 / NULL value as nothing " begin
  Users = feed_db_nv()

  """
  -- find number of users and smallest user_id for each possible name length:
  SELECT LENGTH(name) as name_length, MIN(user_id) AS min_user_id,
    COUNT(*) AS num_users
  FROM users
  GROUP BY LENGTH(name);
    """
  name_len_fn = row -> length(row[:name])
  min_user_id = rows -> minimum(row[:id] for row ∈ rows)
  num_rows = rows -> length(rows)

  stats_by_len = select(Users, add_cols=D_SF(:name_length => name_len_fn)) |>
    u -> group_by(u,
        group_by_cols=[:name_length],
        agg=D_SF(:min_user_id => min_user_id, :num_users => num_rows))

  @test sort(stats_by_len.columns) == [:min_user_id, :name_length, :num_users]
  @test length(stats_by_len.rows) == 4
end


@testset "Group by/2" begin
  Users = feed_db()

  """
  -- average number of friends for users whose names start with specific letters
  -- but see only the results for letters whose corresponding average is greater
  -- than 1
  SELECT SUBSTR(name, 1, 1) AS first_letter,
    AVG(num_friends) AS avg_num_friends
  FROM users
  GROUP BY SUBSTR(name, 1, 1)
  HAVING AVG(num_friends) > 1;
  """
  first_letter_fn = row -> row[:name] !== nothing ? string(row[:name][1]) : ""
  avg_num_friends_fn =
    rows -> sum([row[:num_friends] for row in rows]) / length(rows)
  enough_friends_fn = rows -> avg_num_friends_fn(rows) > 1.

  avg_friends_by_letter =
    select(Users, add_cols=D_SF(:first_letter => first_letter_fn)) |>
    u -> group_by(u, group_by_cols=[:first_letter],
        agg=D_SF(:avg_num_friends => avg_num_friends_fn),
                  having=enough_friends_fn)

  @test sort(avg_friends_by_letter.columns) == [:avg_num_friends, :first_letter]
  @test length(avg_friends_by_letter.rows) == 8
end


@testset "Order by" begin
  Users = feed_db()
  first_letter_fn = row -> row[:name] !== nothing ? string(row[:name][1]) : ""
  avg_num_friends_fn =
    rows -> sum([row[:num_friends] for row in rows]) / length(rows)
  enough_friends_fn = rows -> avg_num_friends_fn(rows) > 1.

  avg_friends_by_letter =
    select(Users, add_cols=D_SF(:first_letter => first_letter_fn)) |>
    u -> group_by(u, group_by_cols=[:first_letter],
        agg=D_SF(:avg_num_friends => avg_num_friends_fn),
                  having=enough_friends_fn)
  #
  friendliest_letters₂ = avg_friends_by_letter |>
    u -> order_by(u, row -> -row[:avg_num_friends]) |>
    u -> limit(u, 3)
  #

  @test sort(friendliest_letters₂.columns) == [:avg_num_friends, :first_letter]
  @test friendliest_letters₂.rows[1][:first_letter] == "A"
  @test length(friendliest_letters₂.rows) == 3
end


# => MethodError: no method matching zero(::Type{Any})
# @testset "Order by / NULL value as nothing" begin
#   Users = feed_db_nv()

#   first_letter_fn = row -> row[:name] !== nothing ? string(row[:name][1]) : ""

#   avg_num_friends_fn =
#     rows -> sum([row[:num_friends] for row in rows if row[:num_friends] !== nothing]) / length(rows)
#   # nothing is like 0

#   enough_friends_fn = rows -> avg_num_friends_fn(rows) > 1.

#   avg_friends_by_letter =
#     select(Users, add_cols=D_SF(:first_letter => first_letter_fn)) |>
#     u -> group_by(u, group_by_cols=[:first_letter],
#         agg=D_SF(:avg_num_friends => avg_num_friends_fn)),
#                   having=enough_friends_fn)

#   friendliest_letters₂ = avg_friends_by_letter |>
#     u -> order_by(u, row -> -row[:avg_num_friends]) |>
#     u -> limit(u, 3)
#   #

#   @test sort(friendliest_letters₂.columns) == [:avg_num_friends, :first_letter]
#   @test friendliest_letters₂.rows[1][:first_letter] == "A"
#   @test length(friendliest_letters₂.rows) == 3
# end

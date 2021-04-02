push!(LOAD_PATH, "./src")

using Test
using YaDB

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
  Users = Table([:name => String, :num_friends => Int]; pkey=(:id => Int))

  ## using Dict + pkey value
  insert(Users, [:id => 1, :name => "Dunn", :num_friends => 2])
  @test length(Users) == 1
  @test Users.rows[1][:name] == "Dunn"

  ## using only Dict => pkey value auto. gen.
  insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
  @assert length(Users) == 2

  ## re-insert (with same pkey) is a NO-OP
  insert(Users, [:id => 1, :name => "Dunn", :num_friends => 2])
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

@testset "Select / where / limit" begin
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

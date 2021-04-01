push!(LOAD_PATH, "./src")

using Test
using YaDB

@testset "Create Table" begin
  Users = Table([:name => String, :num_friends => Int]; pkey=(:user_id => Int))

  @test length(Users) == 0
  @test sort(Users.columns) == [:name, :num_friends, :user_id]
  @test Users.pkey == :user_id
  @test id(Users) == :user_id
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

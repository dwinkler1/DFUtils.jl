using DFUtils
using Test
using DataFrames

@testset "DFUtils.jl" begin
    df = DataFrame(g1 = [1,2,1], g2 = ["a", "a", "b"], v = [1, 2, 3])
    @test isequal(complete(df, :g1, :g2).v, [1,2,3,missing])
    @test complete(df, :g1, :g2; replace_missing = 4).v == [1,2,3,4] 

    @test toReal([1, 1., 0]) isa Array{Int}
    @test toReal(["1", "1.0", "1."]) isa Array{Int}
    @test toReal([1, "1", "1.0"]) isa Array{Int}
    @test toReal(["1", 1, "", 1.0]) isa Array{Union{Missing, Int}}
    @test toReal(["1.1", 1, 1]) isa Array{Float64}
    @test toReal(["1", 1, "", 1.1]) isa Array{Union{Missing, Float64}}
    @test toReal([missing, 1,1]) isa Array{Union{Missing, Int}}
    @test toReal(["abc", 1,1]) isa Array{Union{Missing, Int}}
    @test toReal([string(typemax(Int) + BigInt(1)), 1, 1., 1.]) isa Array{BigInt}
    @test toReal([string(typemax(Int) + BigInt(1)), 1, 1.1, 1.]) isa Array{BigFloat}
end

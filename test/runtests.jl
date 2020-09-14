using DFUtils
using Test
using DataFrames

@testset "DFUtils.jl" begin
    df = DataFrame(g1 = [1,2,1], g2 = ["a", "a", "b"], v = [1, 2, 3])
    @test isequal(complete(df, :g1, :g2).v, [1,2,3,missing])
    @test complete(df, :g1, :g2; replace_missing = 4).v == [1,2,3,4] 
    @test
end

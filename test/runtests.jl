using WIOD_brexit
using Test

@testset "WIOD_brexit.jl" begin
    # Write your tests here.

    @test round(raw_long.value[1]) == 12924.0



end

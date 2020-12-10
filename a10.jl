adapters = sort(parse.(Int, readlines("a10.txt")))

diffs = adapters[2:end] .- adapters[1:end-1]

diffcounts = reduce(function (a,v) a[v] += 1; a end, diffs; init = zeros(Int, 3))
diffcounts[adapters[1]] += 1
diffcounts[3] += 1

part1 = diffcounts[1] * diffcounts[3]
println("$part1")

configurations = zeros(Int, adapters[end] + 3)
configurations[end] = 1
for adapter in reverse(adapters)
  configurations[adapter] = sum(configurations[adapter+1:adapter+3])
end

part2 = sum(configurations[1:3])
println("$part2")

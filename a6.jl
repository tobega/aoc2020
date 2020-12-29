groups = split(read("a6.txt", String), "\n\n")

# union and intersect seem to work on collections of characters (i.e. strings)
part1 = sum(g -> length(union(split(g)...)), groups)
println("$part1")

part2 = sum(g -> length(intersect(split(g)...)), groups)
println("$part2")

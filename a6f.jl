groups = [split(group, "\n"; keepempty=false) for group in split(
  open("a6.txt") do file
    read(file, String)
  end, "\n\n")]

part1 = sum([length(union([Set(collect(s)) for s in group]...)) for group in groups])
println("$part1")

part2 = sum([length(intersect([Set(collect(s)) for s in group]...)) for group in groups])
println("$part2")

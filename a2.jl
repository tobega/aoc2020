line_pattern = r"(\d+)-(\d+) (\w): (\w+)"

input = []
open("a2.txt") do file
  for line in eachline(file)
    m = match(line_pattern, line)
    c = m.captures
    push!(input, c)
  end
end

part1 = count(map((rule) ->
  parse(Int16, rule[1]) <= count((c) -> c in rule[3], collect(rule[4])) <= parse(Int16, rule[2]),
  input))
print("$part1\n")
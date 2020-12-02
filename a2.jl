line_pattern = r"(\d+)-(\d+) (\w): (\w+)"

input = []
open("a2.txt") do file
  for line in eachline(file)
    m = match(line_pattern, line)
    (first, last, required, word) = m.captures
    push!(input, (parse(Int16, first), parse(Int16, last), required[1], word))
  end
end

part1 = count(((min, max, required, word),) ->
  min <= count((c) -> c == required, collect(word)) <= max,
  input)
print("$part1\n")

part2 = count(((first, last, required, word),) ->
  1 == count((c) -> c == required, collect(word)[[first, last]]),
  input)
print("$part2\n")

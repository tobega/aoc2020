line_pattern = r"(\d+)-(\d+) (\w): (\w+)"

input = map(eachline("a2.txt")) do line
    m = match(line_pattern, line)
    first, last, required, word = m.captures
    parse(Int16, first), parse(Int16, last), required[1], collect(word)
end

part1 = count(input) do (min, max, required, word)
  min <= count(==(required), word) <= max
end
print("$part1\n")

part2 = count(input) do (first, last, required, word)
  (word[first] == required) ⊻ (word[last] == required)
end
print("$part2\n")

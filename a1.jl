numbers = Set()

open("a1.txt") do file
  for line in eachline(file)
    n = parse(Int32, line)
    push!(numbers, n)
  end
end

function find_2020_complement()
  for n in numbers
    c = 2020 - n 
    if in(c, numbers)
      return (n,c)
    end
  end
end

part1 = find_2020_complement()
show(part1)
show(part1[1]*part1[2])
print("\n")

ascending = sort(collect(numbers))

function find_2020_triple()
  for i in 1:length(ascending)
    for j in i+1:length(ascending)
      c = 2020 - ascending[i] - ascending[j]
      if c < ascending[1]
        break
      end
      if in(c, numbers)
        return (ascending[i], ascending[j], c)
      end
    end
  end
end

part2 = find_2020_triple()
show(part2)
show(part2[1]*part2[2]*part2[3])

using BenchmarkTools: @btime

input = open("a1.txt") do file
  [parse(Int32, line) for line in eachline(file)]
end

ascending = @btime sort(input)
numbers = @btime Set(ascending)

function find_2020_complement()
  for (i,n) in enumerate(ascending)
    c = 2020 - n
    if c <= n && ascending[i+1] != c
      break
    end
    if in(c, numbers)
      return (n,c)
    end
  end
end

part1 = @btime find_2020_complement()
show(part1)
show(part1[1]*part1[2])
print("\n")

function find_2020_triple()
  for (i,n) in enumerate(ascending)
    for j in i+1:length(ascending)
      c = 2020 - n - ascending[j]
      if c <= ascending[j] && ascending[j+1] != c
        break
      end
      if in(c, numbers)
        return (n, ascending[j], c)
      end
    end
  end
end

part2 = @btime find_2020_triple()
show(part2)
show(part2[1]*part2[2]*part2[3])

function find_2020_triple_brute()
  for i in 1:length(ascending)
    for j in i+1:length(ascending)
      for k in j+1:length(ascending)
        ascending[i] + ascending[j] + ascending[k] == 2020 && return (ascending[i], ascending[j], ascending[k])
      end
    end
  end
end

@btime find_2020_triple_brute()

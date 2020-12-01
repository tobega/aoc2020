numbers = Set()

open("a1.txt") do file
  for line in eachline(file)
    n = parse(Int16, line)
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

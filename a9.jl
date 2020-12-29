mutable struct Preamble
  ins::Int
  preceding::Array{Int,1}
  Preamble(i,p) = 1 <= i <= length(p) ? new(i,p) : error("Bad insert index")
end

function Base.push!(preamble::Preamble, value::Int)
  preamble.preceding[preamble.ins] = value
  preamble.ins = preamble.ins % length(preamble.preceding) + 1
  preamble
end

function follows(next::Int, preamble::Preamble)
  for i in 1:length(preamble.preceding), j in i+1:length(preamble.preceding)
      if preamble.preceding[i] + preamble.preceding[j] == next
        return true
      end
  end
  false
end

input = parse.(Int, readlines("a9.txt"))

function findnonfollowing()
  buffer = Preamble(1, input[1:25])
  for value in input[26:end]
    if !follows(value, buffer)
      return value
    end
    push!(buffer, value)
  end
end

part1 = findnonfollowing()
println("$part1")

function findcontinuoussum(target)
  first = 1
  last = 2
  cs = input[first] + input[last]
  while cs != target && (first < last || last < length(input))
    while cs < target
      last += 1
      cs += input[last]
    end
    while cs > target
      cs -= input[first]
      first += 1
    end
  end
  cs == target && sum(extrema(input[first:last]))
end

part2 = findcontinuoussum(part1)
println("$part2")

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
  for i in 1:length(preamble.preceding)
    for j in i+1:length(preamble.preceding)
      if preamble.preceding[i] + preamble.preceding[j] == next
        return true
      end
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
  for i in 1:length(input)
    j = 1
    while sum(input[i:i+j]) < target
      j += 1
    end
    if sum(input[i:i+j]) == target
      return min(input[i:i+j]...) + max(input[i:i+j]...)
    end
  end
end

part2 = findcontinuoussum(part1)
println("$part2")

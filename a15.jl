using BenchmarkTools: @btime

function memory(start, target)
  numbers = zeros(Int, target)
  for (i,n) in enumerate(start[1:end-1])
    numbers[n+1]=i
  end
  turn = length(start)
  number = start[end]
  while turn < target
    next = numbers[number+1] == 0 ? 0 : turn - numbers[number+1]
    numbers[number+1] = turn
    number = next
    turn += 1
  end
  number
end

input = [0,5,4,1,10,14,7]
part1 = memory(input, 2020)
println("$part1")

part2 = @btime memory(input, 30000000)
println("$part2")

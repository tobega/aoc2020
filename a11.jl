# 2D arrays are confusing, wonder if I can do this better?
room = open("a11.txt") do file
  hcat([collect(line) for line in eachline(file)]...)
end

cartesian = CartesianIndices(room)
linear = LinearIndices(room)
Ifirst = first(cartesian)
Ilast = last(cartesian)
I1 = CartesianIndex(1,1)

seats = linear[findall((c) -> c == 'L', room)]

function simulate(affecting, tolerance)
  occupied = BitSet()
  while true
    change = BitSet() 
    for seat in seats
      neighbours = length(intersect(affecting[seat], occupied))
      if in(seat, occupied)
        neighbours >= tolerance && push!(change, seat)
      else
        neighbours == 0 && push!(change, seat)
      end
    end
    length(change) == 0 && break
    symdiff!(occupied, change)
  end
  length(occupied)
end

function part1()
  adjacent = fill(BitSet(), axes(room))
  for I in cartesian
    if room[I] != 'L'
      continue
    end
    adjacent[I] = BitSet([linear[J] for J in max(Ifirst, I-I1):min(Ilast, I+I1) if I != J && room[J] == 'L'])
  end
  simulate(adjacent, 4)
end

using BenchmarkTools: @btime
ans1 = @btime part1()
println("$ans1")

function part2()
  visible = fill(BitSet(), axes(room))
  directions = [
    CartesianIndex(x,y) for x in -1:1 for y in -1:1 if (x,y) != (0,0)
  ]
  for I in cartesian
    if room[I] != 'L'
      continue
    end
    visibles = []
    for D in directions
      J = I
      while true
        J += D
        checkbounds(Bool, room, J) || break
        room[J] == 'L' || continue
        push!(visibles, linear[J])
        break
      end
    end
    visible[I] = BitSet(visibles)
  end
  simulate(visible, 5)
end

ans2 = @btime part2()
println("$ans2")

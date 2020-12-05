const SEATCODES = Dict('F' => 0, 'B' => 1, 'L' => 0, 'R' => 1)

function seatid(line)
  parse(Int, join(map(c -> SEATCODES[c], collect(line))); base=2)
end

seatids = open("a5.txt") do file
  BitSet([seatid(line) for line in eachline(file)])
end

maxseatid = maximum(seatids)
#part1
println("$maxseatid")

#part2
println("$(maximum(setdiff(BitSet(1:maxseatid), seatids)))")

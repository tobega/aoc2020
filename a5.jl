const SEATCODES = Dict('F' => '0', 'B' => '1', 'L' => '0', 'R' => '1')

function seatid(line)
  parse(Int, map(c -> SEATCODES[c], line); base=2)
end

seatids = BitSet(seatid.(eachline("a5.txt")))

maxseatid = maximum(seatids)
#part1
println("$maxseatid")

#part2
println("$(maximum(setdiff(BitSet(1:maxseatid), seatids)))")

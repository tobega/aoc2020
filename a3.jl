trees = open("a3.txt") do file
  hcat([map((t) -> t == '#' ? 1 : 0, collect(line)) for line in eachline(file)]...)
end
height = last(axes(trees, 2))
width = last(axes(trees, 1))

function slope(h, v)
  Iterators.zip(
    Iterators.accumulate((x, i) -> (x+i-1)%width+1, Iterators.repeated(h); init=1-h),
    1:v:height
  )
end

function ride(h,v)
  sum(trees[CartesianIndex.(slope(h, v))])
end

#part1
println("$(ride(3,1))")

part2 = ride(1, 1) * ride(3, 1) * ride(5, 1) * ride(7, 1) * ride(1, 2)
println("$part2")
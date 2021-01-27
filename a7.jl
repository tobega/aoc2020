rules = Dict(
  [match(r"(\w+ \w+) bags contain", line).captures[1] => Dict(
    [m.captures[2] => parse(Int, m.captures[1])
      for m in eachmatch(r"(\d+) (\w+ \w+)", line)
    ])
    for line in eachline("a7.txt")
  ])

function addcontainersof!(containers, bag)
  for (colour, contents) in rules
    if !in(containers, colour) && haskey(contents, bag)
      push!(containers, colour)
      addcontainersof!(containers, colour)
    end
  end
  containers
end

length(addcontainersof!(Set(), "shiny gold")) |> println

function contains(bag, multiplier)::Int
  multiplier * (1 + sum([contains(colour, count) for (colour, count) in rules[bag]]))
end

contains("shiny gold", 1) - 1 |> println

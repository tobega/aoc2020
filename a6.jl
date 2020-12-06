groups = open("a6.txt") do file
  result = []
  group = []
  for line in eachline(file)
    if isempty(line)
      push!(result, group)
      group = []
    else
      push!(group, line)
    end
  end
  push!(result, group)
  result
end

part1 = 0
for group in groups
  questions = Set()
  for questionnaire in group
    for question in questionnaire
      push!(questions, question)
    end
  end
  global part1 += length(questions)
end
println("$part1")

part2 = 0
for group in groups
  questions = intersect([Set(collect(s)) for s in group]...)
  global part2 += length(questions)
end
println("$part2")
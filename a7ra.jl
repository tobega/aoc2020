import Pkg; Pkg.add(url = "https://github.com/tobega/RelationalData")
using RelationalData

rules = Relation((container = String, contained = String, amount = Int64),
  [(container = match(r"(\w+ \w+) bags contain", line).captures[1],
    contained = m.captures[2],
    amount =  parse(Int64, m.captures[1]))
    for line in eachline("a7.txt")
      for m in eachmatch(r"(\d+) (\w+ \w+)", line)
        ])

function containers(b)
  isempty(b) && return b
  # c = rename(project(rules ⨝ b, :container), :container => :contained)
  c = rules ⨝ b |> r -> project(r, :container) |> r -> rename(r, :container => :contained)
  return c ∪ containers(c)
end

length(containers(Relation((contained = "shiny gold",)))) |> println

#part 2
function contents(b)
  isempty(b) && return b
  c = (project(b, :amount, :contained) |> r -> rename(r, :amount => :multiplier, :contained => :container)
    ⨝ rules) |>
    r -> extend(r, :tally, t -> t.amount * t.multiplier) |>
    r -> project(r, :container, :contained, :tally) |>
    r -> rename(r, :tally => :amount)
  return c ∪ contents(c)
end

sum(t -> t.amount, contents(Relation((container="x", contained="shiny gold", amount=1)))) |> println

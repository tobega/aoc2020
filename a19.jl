rules = Dict(r[1]=>strip(r[2], [' ', '"']) for r in split.(Iterators.takewhile(!isempty, eachline("a19.txt")), ':'))
messages = [m for m in Iterators.dropwhile(!isempty, eachline("a19.txt")) if !isempty(m)]

function rulesasregexes(rules::Dict)
  regexes = Dict()
  function resolve(n)
    if (haskey(regexes, n))
      return regexes[n]
    end
    s = rules[n];
    if !isnothing(match(r"\d+", s))
      for m in eachmatch(r"\d+", s)
        s = replace(s, m.match=>resolve(m.match); count=1)
      end
      s = "(" * s * ")"
    end
    regexes[n] = replace(s, " "=>"")
  end
  for (n,s) in rules
    resolve(n)
  end
  regexes
end

regexes = rulesasregexes(rules)

function matchescompletely(r, s)
  findfirst(r, s) == 1:length(s)
end

#part 1
println("$(count(m -> matchescompletely(Regex(regexes["0"]), m), messages))")

#part2
#assume rule 31 does not depend on 8

function backwardsregex(r)
  function parenswitch(c)
    if c == ')'
      '('
    elseif c == '('
      ')'
    else
      c
    end
  end
  join(parenswitch.(c for c in reverse(r)))
end

thirtyone = backwardsregex(regexes["31"])
fourtytwo = backwardsregex(regexes["42"])

function matchesnewrulezero(m)
  count = 0
  m = reverse(m)
  r = findfirst(Regex(thirtyone), m)
  while !isnothing(r) && first(r) == 1
    m = SubString(m, last(r)+1)
    count += 1
    r = findfirst(Regex(thirtyone), m)
  end
  count != 0 && matchescompletely(Regex(fourtytwo * "{$count}" * fourtytwo * "+"), m)
end

println("$(count(matchesnewrulezero, messages))")

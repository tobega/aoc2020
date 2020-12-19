sourcecode = readlines("a18.txt")

function shuntyard(line, prio)
  ops = ['(']
  out = []
  function shunt(op)
    op == ' ' && return
    while op != '(' && first(ops) != '(' && (op == ')' || prio(ops[1]) <= prio(op))
      pushfirst!(out, Expr(:call, Symbol(popfirst!(ops)), popfirst!(out), popfirst!(out)))
    end
    if (op == ')')
      popfirst!(ops)
    else
      pushfirst!(ops, op)
    end
  end
  numberat = findfirst(r"\d+", line)
  while !isnothing(numberat)
    if first(numberat) != 1
      shunt.(SubString(line, 1, first(numberat)-1) |> collect)
    end
    pushfirst!(out, parse(Int, SubString(line, first(numberat), last(numberat))))
    line = SubString(line, last(numberat)+1)
    numberat = findfirst(r"\d+", line)
  end
  shunt.(line |> collect)
  shunt(')')
  out[1]
end

function equalprio(op)
  1
end

#part 1
println("$(sum(eval.(shuntyard.(sourcecode, equalprio))))")

function plusfirst(op)
  if op == '+'
    1
  elseif op == '*'
    2
  end
end

#part 2
println("$(sum(eval.(shuntyard.(sourcecode, plusfirst))))")

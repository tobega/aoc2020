struct State
  pc
  acc
end

macro acc(increment)
  return function(state) State(state.pc+1, state.acc+increment) end
end

macro nop(ignored)
  return function(state) State(state.pc+1, state.acc) end
end

macro jmp(offset)
  return function(state) State(state.pc+offset, state.acc) end
end

sourcecode = readlines("a8.txt")

function getprogram(tochange)
  program = []
  for (id,line) in enumerate(sourcecode)
    if id == tochange
      if startswith(line, "jmp")
        line = replace(line, "jmp"=>"nop")
      elseif startswith(line, "nop")
        line = replace(line, "nop"=>"jmp")
      end
    end
    push!(program, eval(Meta.parse("@" * line)))
  end
  program
end

function detectLoop(program)
  seen = BitSet()
  state = State(1,0)
  while state.pc <= length(program) && !in(state.pc, seen)
    push!(seen, state.pc)
    state = program[state.pc](state)
  end
  state
end

part1 = detectLoop(getprogram(0))
println("$(part1.acc)")

function findModification()
  for tochange in 1:length(sourcecode)
    state = detectLoop(getprogram(tochange))
    if state.pc > length(sourcecode)
      return state.acc
    end
  end
  nothing
end

part2 = findModification()
println("$part2")

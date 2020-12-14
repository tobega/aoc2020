import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.LongStream;

public class A14 {
  public A14(List<Instruction> program) {
    this.program = program;
  }
  final List<Instruction> program;

  long part1() {
    Cpu cpu = new Cpu();
    program.forEach(i -> i.apply(cpu));
    return cpu.getSum();
  }

  long part2() {
    Cpu cpu = new Cpu();
    program.forEach(i -> i.apply2(cpu));
    return cpu.getSum();
  }

  interface Instruction {
    void apply(Cpu cpu);
    void apply2(Cpu cpu);
  }

  static class Mask implements Instruction {
    private final long set;
    private final long clear;

    private Mask(long set, long clear) {
      this.set = set;
      this.clear = clear;
    }

    @Override
    public void apply(Cpu cpu) {
      cpu.setMask(set, clear);
    }

    @Override
    public void apply2(Cpu cpu) {
      apply(cpu);
    }

    public static Instruction parse(String line) {
      long set = 0;
      long clear = -1;
      String mask = line.substring(7);
      for (int i = 0; i < mask.length(); i++) {
        set = set << 1;
        clear = clear << 1;
        if (mask.charAt(i) == '1') set = set | 1;
        if (mask.charAt(i) != '0') clear = clear | 1;
      }
      return new Mask(set, clear);
    }
  }

  static class Mem implements Instruction {
    private final long address;
    private final long value;

    public Mem(long address, long value) {
      this.address = address;
      this.value = value;
    }

    @Override
    public void apply(Cpu cpu) {
      long transformed = (value & cpu.clear) | cpu.set;
      cpu.setMem(address, transformed);
    }

    @Override
    public void apply2(Cpu cpu) {
      LongStream addresses = LongStream.of(address | cpu.set);
      long floating = (cpu.set ^ cpu.clear) & 0xfffffffffL;
      for (int i = 0; i < 36; i++) {
        long bit = 1L << i;
        if ((floating & bit) != 0) {
          addresses = addresses.flatMap(a -> LongStream.of(a | bit, a & ~bit));
        }
      }
      addresses.forEach(a -> cpu.setMem(a, value));
    }

    private static final Pattern MEMLINE = Pattern.compile("mem\\[(\\d+)] = (\\d+)");
    public static Instruction parse(String line) {
      Matcher matcher = MEMLINE.matcher(line);
      if (!matcher.matches()) throw new IllegalArgumentException(line);
      return new Mem(Long.parseLong(matcher.group(1)), Long.parseLong(matcher.group(2)));
    }
  }

  static class Cpu {
    private long set = 0;
    private long clear = -1;
    private Map<Long, Long> mem = new HashMap<>();

    public void setMask(long set, long clear) {
      this.set = set;
      this.clear = clear;
    }

    public void setMem(long address, long transformed) {
      mem.put(address, transformed);
    }

    public long getSum() {
      return mem.values().stream().mapToLong(i -> i).sum();
    }
  }

  private static Instruction parseLine(String line) {
    if (line.startsWith("mask = ")) {
      return Mask.parse(line);
    } else {
      return Mem.parse(line);
    }
  }

  public static void main(String[] args) throws IOException {
    A14 solution = new A14(Files.lines(Path.of("a14.txt")).map(A14::parseLine).collect(Collectors.toList()));
    System.out.println(solution.part1());
    System.out.println(solution.part2());
  }
}

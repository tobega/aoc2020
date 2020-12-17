import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class A2 {

  private final List<Password> passwords;

  public A2(List<Password> passwords) {
    this.passwords = passwords;
  }

  static class Password {
    private static final Pattern PASSWORD_POLICY_PATTERN =
        Pattern.compile("(?<first>\\d+)-(?<last>\\d+) (?<requiredChar>\\w): (?<password>\\w+)");
    private final int first;
    private final int last;
    private final char requiredChar;
    private final String password;

    Password(int first, int last, char requiredChar, String password) {
      this.first = first;
      this.last = last;
      this.requiredChar = requiredChar;
      this.password = password;
    }

    public static Password fromLine(String line) {
      Matcher m = PASSWORD_POLICY_PATTERN.matcher(line);
      if (!m.matches()) throw new IllegalArgumentException("Bad input line " + line);
      return new Password(
          Integer.parseInt(m.group("first")),
          Integer.parseInt(m.group("last")),
          m.group("requiredChar").charAt(0),
          m.group("password"));
    }
  }

  private int part1() {
    return (int) passwords.stream().filter(p -> {
      int count = p.password.replaceAll("[^" + p.requiredChar + "]", "").length();
      return count >= p.first && count <= p.last;
    }).count();
  }

  private int part2() {
    return (int) passwords.stream()
        .filter(p -> p.password.charAt(p.first-1) == p.requiredChar
            ^ (p.last-1 < p.password.length() && p.password.charAt(p.last-1) == p.requiredChar))
        .count();
  }

  public static void main(String[] args) throws IOException {
    A2 solution = new A2(Files.lines(Paths.get("a2.txt")).map(Password::fromLine).collect(Collectors.toList()));
    System.out.println(solution.part1());
    System.out.println(solution.part2());
  }
}

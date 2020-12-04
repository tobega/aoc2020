import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class A4 {
  private final List<Passport> passports;

  public A4(List<Passport> passports) {
    this.passports = passports;
  }

  public long part1() {
    return passports.stream().filter(Passport::hasRequiredFields).count();
  }

  public long part2() {
    return passports.stream().filter(Passport::isValid).count();
  }

  public static class Passport {
    private static final EnumSet<Field> REQUIRED = EnumSet.allOf(Field.class);

    static {
      REQUIRED.remove(Field.cid);
    }

    private final EnumMap<Field, String> fields;

    public Passport(EnumMap<Field, String> fields) {
      this.fields = fields;
    }

    public boolean hasRequiredFields() {
      return fields.keySet().containsAll(REQUIRED);
    }

    public boolean isValid() {
      return hasRequiredFields()
          && fields.entrySet().stream().allMatch(entry -> entry.getKey().isValid(entry.getValue()));
    }

    public static Passport fromRecord(String record) {
      EnumMap<Field, String> fields = new EnumMap<>(Field.class);
      for (String field : record.trim().split("[ \\n]")) {
        String[] kv = field.split(":");
        fields.put(Field.valueOf(kv[0]), kv[1]);
      }
      return new Passport(fields);
    }

    /**
     * @see "http://tobega.blogspot.com/2018/07/java-enums-are-not-constants.html"
     */
    private enum Field {
      byr() {
        @Override
        boolean isValid(String value) {
          return isYearBetween(value, 1920, 2002);
        }
      },
      iyr() {
        @Override
        boolean isValid(String value) {
          return isYearBetween(value, 2010, 2020);
        }
      },
      eyr() {
        @Override
        boolean isValid(String value) {
          return isYearBetween(value, 2020, 2030);
        }
      },
      hgt() {
        @Override
        boolean isValid(String value) {
          if (value.endsWith("cm")) {
            return isNumberBetween(value.substring(0, value.length() - 2), 150, 193);
          }
          if (value.endsWith("in")) {
            return isNumberBetween(value.substring(0, value.length() - 2), 59, 76);
          }
          return false;
        }
      },
      hcl() {
        @Override
        boolean isValid(String value) {
          return HAIR_COLOR.matcher(value).matches();
        }
      },
      ecl() {
        @Override
        boolean isValid(String value) {
          return EYE_COLORS.contains(value);
        }
      },
      pid() {
        @Override
        boolean isValid(String value) {
          return PID.matcher(value).matches();
        }
      },
      cid() {
        @Override
        boolean isValid(String value) {
          return true;
        }
      };

      private static final Set<String> EYE_COLORS =
          Set.of("amb", "blu", "brn", "gry", "grn", "hzl", "oth");
      private static final Pattern YEAR = Pattern.compile("\\d{4}");
      private static final Pattern HAIR_COLOR = Pattern.compile("#[0-9a-f]{6}");
      private static final Pattern PID = Pattern.compile("\\d{9}");

      abstract boolean isValid(String value);

      private static boolean isYearBetween(String value, int start, int end) {
        if (!YEAR.matcher(value).matches()) return false;
        return isNumberBetween(value, start, end);
      }

      private static boolean isNumberBetween(String value, int start, int end) {
        try {
          int number = Integer.parseInt(value);
          return number >= start && number <= end;
        } catch (NumberFormatException e) {
          return false;
        }
      }
    }
  }

  public static void main(String[] args) throws IOException {
    String input = Files.readString(Path.of("a4.txt"));
    List<Passport> passports =
        Arrays.stream(input.split("\\n\\n")).map(Passport::fromRecord).collect(Collectors.toList());
    A4 solution = new A4(passports);
    System.out.println(solution.part1());
    System.out.println(solution.part2());
  }
}

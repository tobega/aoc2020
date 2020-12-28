import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

/**
 * This is a copy of the Tailspin implementation in the file a20.tt. It is probably not how I would
 * have coded it in Java, but attempts to be an illustration of how a different language makes you
 * think differently.
 */
public class A20 {
  static final Pattern TILE_HEADER = Pattern.compile("Tile (\\d+):");

  static List<Map.Entry<Integer, String[][]>> parseTileData(List<String> lines) {
    List<Map.Entry<Integer, String[][]>> tiles = new ArrayList<>();
    Integer id = null;
    List<String[]> tile = new ArrayList<>();
    for (String line : lines) {
      Matcher header = TILE_HEADER.matcher(line);
      if (header.matches()) {
        if (id != null) {
          tiles.add(Map.entry(id, tile.toArray(new String[tile.size()][])));
          tile = new ArrayList<>();
        }
        id = Integer.parseInt(header.group(1));
        continue;
      }
      if (!line.isEmpty()) tile.add(line.split(""));
    }
    if (id != null) tiles.add(Map.entry(id, tile.toArray(new String[tile.size()][])));
    return tiles;
  }

  static Map<Integer, String[][]> input;

  static {
    try {
      input =
          parseTileData(Files.readAllLines(Path.of("a20.txt"))).stream()
              .collect(Collectors.toMap(Entry::getKey, Entry::getValue));
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  static record Tile(int id, String[][] chars) {}

  static record Edge(String side, Tile tile) {}

  // Some utilities to mimic Tailspin's array selectors
  static <T> Stream<T> first(T[] array) {
    return Stream.of(array[0]);
  }

  static <T> Stream<T> last(T[] array) {
    return Stream.of(array[array.length - 1]);
  }

  static <T> Stream<T> all(T[] array) {
    return Arrays.stream(array);
  }

  static <T> Stream<T> allReversed(T[] array) {
    T[] copy = Arrays.copyOf(array, array.length);
    for (int i = 0; i < array.length / 2; i++) {
      T tmp = copy[i];
      copy[i] = copy[array.length - i - 1];
      copy[array.length - i - 1] = tmp;
    }
    return Arrays.stream(copy);
  }

  static List<Edge> mergeMatches(List<Edge> matches, List<Edge> match) {
    List<Edge> result = new ArrayList<>(matches);
    result.addAll(match);
    return result;
  }

  static Map<Integer, List<Edge>> findNeighbours(Map<Integer, String[][]> tiles) {
    Map<String, Tile> edges = new HashMap<>();
    Map<Integer, List<Edge>> neighbours = new HashMap<>();
    tiles.entrySet().stream()
        .map(e -> new Tile(e.getKey(), e.getValue()))
        .flatMap(
            t ->
                Stream.of(
                    new Edge(all(t.chars()).flatMap(A20::first).collect(Collectors.joining()), t),
                    new Edge(last(t.chars()).flatMap(A20::all).collect(Collectors.joining()), t),
                    new Edge(all(t.chars()).flatMap(A20::last).collect(Collectors.joining()), t),
                    new Edge(first(t.chars()).flatMap(A20::all).collect(Collectors.joining()), t),
                    new Edge(
                        allReversed(t.chars()).flatMap(A20::first).collect(Collectors.joining()),
                        t),
                    new Edge(
                        last(t.chars()).flatMap(A20::allReversed).collect(Collectors.joining()), t),
                    new Edge(
                        allReversed(t.chars()).flatMap(A20::last).collect(Collectors.joining()), t),
                    new Edge(
                        first(t.chars()).flatMap(A20::allReversed).collect(Collectors.joining()),
                        t)))
        .forEach(
            edge -> {
              Tile match;
              if ((match = edges.put(edge.side(), edge.tile())) != null) {
                neighbours.merge(match.id, List.of(edge), A20::mergeMatches);
                neighbours.merge(
                    edge.tile().id(), List.of(new Edge(edge.side(), match)), A20::mergeMatches);
              }
            });
    return neighbours;
  }

  static Map<Integer, List<Edge>> neighbours = findNeighbours(input);

  // Note: each tile matches twice, flipped and not flipped
  static List<Integer> corners =
      neighbours.entrySet().stream()
          .filter(e -> e.getValue().size() == 4)
          .map(Entry::getKey)
          .collect(Collectors.toList());

  // part1 output in main

  static String[][] transpose(String[][] chars) {
    String[][] transposed = new String[chars[0].length][chars.length];
    for (int i = 0; i < chars.length; i++)
      for (int j = 0; j < chars[0].length; j++) transposed[j][i] = chars[i][j];
    return transposed;
  }

  static Stream<String[][]> allFlips(String[][] chars) {
    return Stream.of(
        chars,
        all(chars).map(c -> allReversed(c).toArray(String[]::new)).toArray(String[][]::new),
        allReversed(chars).map(c -> allReversed(c).toArray(String[]::new)).toArray(String[][]::new),
        allReversed(chars).toArray(String[][]::new));
  }

  static Stream<Tile> extendLine(Tile tile) {
    String border = all(tile.chars()).flatMap(A20::last).collect(Collectors.joining());
    return neighbours.get(tile.id()).stream()
        .filter(e -> e.side().equals(border))
        .map(e -> e.tile)
        .map(
            t ->
                Stream.concat(allFlips(t.chars()), allFlips(transpose(t.chars())))
                    .filter(
                        c ->
                            all(c).flatMap(A20::first).collect(Collectors.joining()).equals(border))
                    .map(c -> new Tile(t.id(), c))
                    .findFirst()
                    .orElseThrow())
        .flatMap(t -> Stream.concat(Stream.of(t), extendLine(t)));
  }

  static Stream<List<Tile>> appendLines(Tile tile) {
    return extendLine(new Tile(tile.id(), transpose(tile.chars())))
        .map(
            t -> {
              Tile edge = new Tile(t.id(), transpose(t.chars()));
              return Stream.concat(Stream.of(edge), extendLine(edge)).collect(Collectors.toList());
            });
  }

  static String[][] assembleImage() {
    int firstCorner = corners.get(0);
    return allFlips(input.get(firstCorner))
        .map(c -> new Tile(firstCorner, c))
        .map(
            t ->
                Stream.concat(
                        Stream.of(
                            Stream.concat(Stream.of(t), extendLine(t))
                                .collect(Collectors.toList())),
                        appendLines(t))
                    .collect(Collectors.toList()))
        .filter(a -> a.size() >= 2 && a.get(0).size() >= 2)
        .map(
            ai ->
                ai.stream()
                    .map(
                        aj ->
                            aj.stream()
                                .map(
                                    t -> {
                                      String[][] result =
                                          new String[t.chars().length - 2][t.chars()[0].length - 2];
                                      for (int i = 0; i < result.length; i++)
                                        System.arraycopy(
                                            t.chars()[i + 1], 1, result[i], 0, result[i].length);
                                      return result;
                                    })
                                .collect(Collectors.toList()))
                    .collect(Collectors.toList()))
        .map(
            ai ->
                ai.stream()
                    .flatMap(
                        tiles ->
                            IntStream.iterate(0, i -> i < tiles.get(0).length, i -> i + 1)
                                .mapToObj(
                                    i ->
                                        tiles.stream()
                                            .map(c -> c[i])
                                            .flatMap(Arrays::stream)
                                            .toArray(String[]::new)))
                    .toArray(String[][]::new))
        .findFirst()
        .orElseThrow();
  }

  static String[][] baseImage = assembleImage();

  static List<String> seamonster =
      List.of("                  # ", "#    ##    ##    ###", " #  #  #  #  #  #   ");

  static int seamonsterWidth = seamonster.get(0).length();

  static List<List<Integer>> seamonsterSelectors =
      seamonster.stream()
          .map(
              s ->
                  IntStream.iterate(0, i -> i < s.length(), i -> i + 1)
                      .filter(i -> s.charAt(i) == '#')
                      .boxed()
                      .collect(Collectors.toList()))
          .collect(Collectors.toList());

  static Stream<String[][]> detectSeamonsters(String[][] image) {
    AtomicInteger monsters = new AtomicInteger();
    IntStream.iterate(0, i -> i < image.length - 2, i -> i + 1)
        .forEach(
            startRow ->
                IntStream.iterate(seamonsterWidth, i -> i < image[0].length, i -> i + 1)
                    .map(i -> i - seamonsterWidth)
                    .forEach(
                        offset -> {
                          if (IntStream.iterate(0, i -> i < seamonsterSelectors.size(), i -> i + 1)
                              .boxed()
                              .flatMap(
                                  i ->
                                      seamonsterSelectors.get(i).stream()
                                          .map(j -> image[i + startRow][j + offset]))
                              .noneMatch("."::equals)) {
                            monsters.incrementAndGet();
                            IntStream.iterate(0, i -> i < seamonsterSelectors.size(), i -> i + 1)
                                .forEach(
                                    i ->
                                        seamonsterSelectors
                                            .get(i)
                                            .forEach(j -> image[i + startRow][j + offset] = "O"));
                          }
                        }));
    // Odd that Stream.of(image) didn't work
    return monsters.get() > 0 ? Optional.of(image).stream() : Stream.empty();
  }

  public static void main(String[] args) {
    // part1
    System.out.println(
        corners.stream().mapToLong(Integer::longValue).reduce((a, b) -> a * b).orElseThrow());

    // part2
    Stream.concat(allFlips(baseImage), allFlips(transpose(baseImage)))
        .flatMap(A20::detectSeamonsters)
        .map(
            image -> {
              Arrays.stream(image).forEach(line -> System.out.println(String.join("", line)));
              return Arrays.stream(image).flatMap(Arrays::stream).filter("#"::equals).count();
            })
        .forEach(System.out::println);
  }
}

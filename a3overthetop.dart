import 'dart:io';

class A3 {
  List<List<int>> trees;
  A3(this.trees);

  Iterable<int> slope(int horizontal, int vertical) sync* {
    int width = trees[0].length;
    int h = 0;
    int v = 0;
    do {
      yield trees[v][h];
      h = (h + horizontal) % width;
      v += vertical;
    } while (v < trees.length);
  }

  int ride(int horizontal, int vertical) {
    return slope(horizontal, vertical).sum();
  }

  int part1() {
    return ride(3, 1);
  }

  int part2() {
    return ride(1, 1) * ride(3, 1) * ride(5, 1) * ride(7, 1) * ride(1, 2);
  }
}

extension Sum on Iterable<int> {
  int sum() {
    return this.reduce((a, b) => a + b);
  }
}

void main(List<String> args) {
  var input = new File('a3.txt');

  var trees = input
      .readAsLinesSync()
      .map((l) => l.split('').map((t) => t == '#' ? 1 : 0).toList())
      .toList();
  var solver = new A3(trees);
  stdout.writeln(solver.part1());
  stdout.writeln(solver.part2());
}

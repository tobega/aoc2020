import 'dart:io';

class Ride {
  int horizontal;
  int vertical;
  Ride(this.horizontal, this.vertical);

  int go(List<List<int>> trees) {
    int width = trees[0].length;
    int hit = 0;
    int h = 0;
    int v = 0;
    do {
      hit += trees[v][h];
      h = (h + horizontal) % width;
      v += vertical;
    } while (v < trees.length);
    return hit;
  }
}

class A3 {
  List<List<int>> trees;
  A3(this.trees);

  int part1() {
    return new Ride(3, 1).go(trees);
  }

  int part2() {
    return new Ride(1, 1).go(trees) *
        new Ride(3, 1).go(trees) *
        new Ride(5, 1).go(trees) *
        new Ride(7, 1).go(trees) *
        new Ride(1, 2).go(trees);
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

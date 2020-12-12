import 'dart:io';

// This should really be replaced by the Point class from dart:math
// but I wanted to play with operator overloading
class Vector {
  int x;
  int y;

  Vector(this.x, this.y);

  void adjust(int dx, int dy) {
    x += dx;
    y += dy;
  }

  void swivel(int degreesRight) {
    while (degreesRight < 0) degreesRight += 360;
    while (degreesRight > 0) {
      var tmp = x;
      x = -y;
      y = tmp;
      degreesRight -= 90;
    }
  }

  int manhattanLength() {
    return x.abs() + y.abs();
  }

  // It feels bad to mutate here, but just to try. How bad is it? returns null
  operator +(Vector other) {
    this.x += other.x;
    this.y += other.y;
  }

  Vector operator *(int scale) {
    return Vector(scale * x, scale * y);
  }
}

class Navigation {
  Vector direction;
  Vector position = Vector(0, 0);
  bool waypoint = false;

  Navigation.standard() {
    direction = Vector(1, 0);
  }

  Navigation.waypoint() {
    direction = Vector(10, -1);
    waypoint = true;
  }

  Vector _vectorToAdjust() {
    return waypoint ? direction : position;
  }

  void adjust(int dx, int dy) {
    _vectorToAdjust().adjust(dx, dy);
  }

  void move(int time) {
    position + (direction * time);
  }

  void turn(int degreesRight) {
    direction.swivel(degreesRight);
  }

  int manhattanDistance() {
    return position.manhattanLength();
  }
}

// This is a little overkill as well, but really brings out Single Responsibility
abstract class Action implements Function {
  void call(Navigation navigation);
}

class Adjust extends Action {
  int dx;
  int dy;
  Adjust(this.dx, this.dy);

  @override
  void call(Navigation navigation) {
    navigation.adjust(dx, dy);
  }
}

class Move extends Action {
  int time;
  Move(this.time);

  @override
  void call(Navigation navigation) {
    navigation.move(time);
  }
}

class Turn extends Action {
  int degreesRight;
  Turn(this.degreesRight);

  @override
  void call(Navigation navigation) {
    navigation.turn(degreesRight);
  }
}

Action toAction(String line) {
  int value = int.parse(line.substring(1));
  switch (line[0]) {
    case 'N':
      return Adjust(0, -value);
    case 'S':
      return Adjust(0, value);
    case 'E':
      return Adjust(value, 0);
    case 'W':
      return Adjust(-value, 0);
    case 'F':
      return Move(value);
    case 'L':
      return Turn(-value);
    case 'R':
      return Turn(value);
    default:
      throw 'Unknown command ' + line;
  }
}

void main(List<String> args) {
  var input = new File('a12.txt');
  var actions = input.readAsLinesSync().map(toAction).toList();

  var part1 = Navigation.standard();
  actions.forEach((a) => a(part1));
  stdout.writeln(part1.manhattanDistance());

  var part2 = Navigation.waypoint();
  actions.forEach((a) => a(part2));
  stdout.writeln(part2.manhattanDistance());
}

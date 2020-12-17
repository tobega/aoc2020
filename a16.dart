import 'dart:io';

var RULE_PATTERN = RegExp(r"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)");

class Range {
  int from;
  int to;
  Range(this.from, this.to);

  bool contains(int field) {
    return field >= from && field <= to;
  }
}

class Rule {
  String name;
  Range low;
  Range high;

  Rule.fromLine(String line) {
    var match = RULE_PATTERN.firstMatch(line);
    name = match.group(1);
    low = Range(int.parse(match.group(2)), int.parse(match.group(3)));
    high = Range(int.parse(match.group(4)), int.parse(match.group(5)));
  }

  isValid(int field) {
    return low.contains(field) || high.contains(field);
  }

  @override
  String toString() {
    return name;
  }
}

class Ticket {
  List<int> fields;

  Ticket.fromLine(String line) {
    fields = line.split(',').map(int.parse).toList();
  }

  sumOfInvalidFields(List<Rule> rules) {
    var sum = 0;
    for (var field in fields) {
      if (!rules.any((r) => r.isValid(field))) {
        sum += field;
      }
    }
    return sum;
  }
}

void main(List<String> args) {
  var input = new File('a16.txt');
  var lines = input.readAsLinesSync();
  List<Rule> rules = List();
  List<Ticket> nearbyTickets = List();
  Ticket myTicket;
  int i = 0;
  while (lines[i] != '') {
    rules.add(Rule.fromLine(lines[i]));
    i++;
  }
  i += 2;
  myTicket = Ticket.fromLine(lines[i]);
  i += 3;
  while (i < lines.length && lines[i] != '') {
    nearbyTickets.add(Ticket.fromLine(lines[i]));
    i++;
  }

  A16 solution = A16(rules, myTicket, nearbyTickets);
  stdout.writeln(solution.part1());
  stdout.writeln(solution.part2());
}

class A16 {
  List<Rule> rules;
  Ticket myTicket;
  List<Ticket> nearbyTickets;
  List<Ticket> validTickets;

  A16(this.rules, this.myTicket, this.nearbyTickets);

  int part1() {
    return nearbyTickets
        .map((t) => t.sumOfInvalidFields(rules))
        .reduce((a, b) => a + b);
  }

  int part2() {
    validTickets =
        nearbyTickets.where((t) => t.sumOfInvalidFields(rules) == 0).toList();

    List<List<Rule>> rulePositions = List();
    for (int i = 0; i < myTicket.fields.length; i++) {
      rulePositions.add(rules
          .where((r) => validTickets.every((t) => r.isValid(t.fields[i])))
          .toList());
    }

    List<Rule> decidedPositions =
        decidePositions(rulePositions, List.filled(rulePositions.length, null));
    int product = 1;
    for (int i = 0; i < decidedPositions.length; i++) {
      if (decidedPositions[i].name.startsWith('departure')) {
        product *= myTicket.fields[i];
      }
    }
    return product;
  }

  List<Rule> decidePositions(
      List<List<Rule>> rulePositions, List<Rule> decided) {
    var shortestLength = rulePositions.length;
    var shortestIndex = -1;
    for (int i = 0; i < rulePositions.length; i++) {
      if (decided[i] != null) continue;
      if (rulePositions[i].length <= shortestLength) {
        shortestIndex = i;
        shortestLength = rulePositions[i].length;
      }
    }
    if (shortestIndex == -1) return decided;
    if (shortestLength == 0) return null;
    for (Rule rule in rulePositions[shortestIndex]) {
      var nextDecided = decided.toList();
      nextDecided[shortestIndex] = rule;
      var result = decidePositions(
          rulePositions
              .map((rules) =>
                  rules.where((element) => element.name != rule.name).toList())
              .toList(),
          nextDecided);
      if (result != null) return result;
    }
    return null;
  }
}

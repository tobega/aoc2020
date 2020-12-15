import 'dart:io';

void main(List<String> args) {
  var input = new File('a1.txt');
  var expenses = input.readAsLinesSync().map(int.parse).toList();
  expenses.sort();
  var part1 = find2020Pair(expenses);
  stdout.writeln("$part1");
  var part2 = find2020Triple(expenses);
  stdout.writeln("$part2");
}

find2020Pair(List<int> expenses) {
  var i = 0;
  var j = expenses.length - 1;
  while (i != j && expenses[i] + expenses[j] != 2020) {
    if (expenses[i] + expenses[j] < 2020)
      i++;
    else
      j--;
  }
  if (i == j) throw 'not found';
  return expenses[i] * expenses[j];
}

find2020Triple(List<int> expenses) {
  for (int k = expenses.length - 1; k >= 0; k--) {
    var target = 2020 - expenses[k];
    var i = 0;
    var j = k - 1;
    while (i < j && expenses[i] + expenses[j] != target) {
      if (expenses[i] + expenses[j] < target)
        i++;
      else
        j--;
    }
    if (i < j) return expenses[i] * expenses[j] * expenses[k];
  }
  throw 'not found';
}

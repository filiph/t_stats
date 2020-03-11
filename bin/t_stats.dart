import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:t_stats/t_stats.dart';

Future<Null> main(List<String> args) async {
  final pretty = args.contains("--pretty");
  final lineSplitter = LineSplitter();
  var hintGiven = false;

  final lines = await stdin
      .timeout(const Duration(milliseconds: 100), onTimeout: (sink) {
        if (hintGiven) return;
        stdout.writeln("Please provide a POSIX pipe or write one number "
            "per line, then hit Ctrl-D when done.");
        hintGiven = true;
      })
      .map((bytes) {
        final string = utf8.decode(bytes);
        final lines = lineSplitter.convert(string);
        return lines;
      })
      .expand((list) => list)
      .toList();

  final numbers = lines
      .map((s) => num.tryParse(s))
      .where((n) => n != null)
      .toList(growable: false);

  if (numbers.isEmpty) {
    stderr.writeln(_help);
    exitCode = 2;
    return;
  }

  if (numbers.length == 1) {
    stderr.writeln("Only one input number was parsed. Cannot "
        "compute meaningful statistics from a single number.");
    exitCode = 2;
    return;
  }

  final stats = Statistic.from(numbers);
  stdout.writeln(pretty ? stats.toString() : stats.toTSV());
}

const _help = r"""
Please provide a list of numbers via a POSIX pipe. For example:

    $ t_stats < numbers.txt

Only lines containing a single valid number will be used, the rest is ignored.
""";

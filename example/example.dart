// Copyright (c) 2016, Filip Hracek. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE
// file.

import 'dart:math';

import 'package:t_stats/t_stats.dart';

main() {
  var stats =
      new Statistic.from([1, 1, 1, 10, 1, 5, 1, 100], name: "My scores");
  print(stats);

  var stats2 =
      new Statistic.from([24, 14, 20, 24, 21, 21, 19, 29], name: "Your scores");
  print(stats2);

  var stats3 =
      new Statistic.from(new Iterable.generate(2000, (n) => n).toList());
  print(stats3);

  var random = new Random();
  var stats4 = new Statistic.from(
      new Iterable.generate(2000, (_) => random.nextInt(100)).toList());
  print(stats4);

  print(stats.isDifferentFrom(stats2));
  print(stats.isDifferentFrom(stats4));
}

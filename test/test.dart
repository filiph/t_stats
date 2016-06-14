// Copyright (c) 2016, Filip Hracek. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE
// file.

import 'dart:math';

import 'package:t_stats/t_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Initializing', () {
    test('null fails', () {
      expect(() => new Statistic.from(null), throwsArgumentError);
    });
    test('empty fails', () {
      expect(() => new Statistic.from([]), throwsArgumentError);
    });
    test('single fails', () {
      expect(() => new Statistic.from([1]), throwsArgumentError);
    });
    test('two measurements succeed', () {
      expect(() => new Statistic.from([1, 2]), returnsNormally);
    });
    test('10.000 measurements succeed', () {
      var huge =
          new Iterable.generate(10000, (n) => n * n).toList(growable: false);
      expect(() => new Statistic.from(huge), returnsNormally);
    });
  });

  group('Computes from precomputed', () {
    test('wikipedia sample', () {
      // https://en.wikipedia.org/wiki/Confidence_interval
      var stat = new Statistic(25, 250.2, 230, 270, 2.5);
      expect(stat.stdError, closeTo(0.5, 0.01));
      expect(stat.lowerBound, closeTo(249.22, 0.1));
      expect(stat.upperBound, closeTo(251.18, 0.1));
    });
  });

  group('Computes', () {
    final Random rand = new Random(1);
    final linear = new Iterable.generate(500, (n) => n).toList(growable: false);
    final exponential =
        new Iterable.generate(500, (n) => n * n).toList(growable: false);
    final random1 = new Iterable.generate(500, (n) => rand.nextInt(500))
        .toList(growable: false);
    final random2 = new Iterable.generate(500, (n) => rand.nextInt(100))
        .toList(growable: false);

    Statistic linearStat, exponentialStat, random1Stat, random2Stat;

    setUp(() {
      linearStat = new Statistic.from(linear);
      exponentialStat = new Statistic.from(exponential);
      random1Stat = new Statistic.from(random1);
      random2Stat = new Statistic.from(random2);
    });

    test('correct means', () {
      expect(linearStat.mean, closeTo(250, 1));
      expect(exponentialStat.mean, closeTo(83000, 1000));
      expect(random1Stat.mean, closeTo(250, 5));
      expect(random2Stat.mean, closeTo(50, 2));
    });

    test('differences', () {
      expect(linearStat.isDifferentFrom(exponentialStat), isTrue);
      expect(random1Stat.isDifferentFrom(random2Stat), isTrue);
      expect(random1Stat.isDifferentFrom(random1Stat), isFalse);
    });
  });
}

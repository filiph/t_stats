// Copyright (c) 2016, Filip Hracek. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE
// file.

import 'dart:math';

import 'package:t_stats/src/distributions.dart';
import 'package:t_stats/src/factorial.dart';
import 'package:t_stats/t_stats.dart';
import 'package:test/test.dart';

void main() {
  group('Initializing', () {
    test('empty fails', () {
      expect(() => Statistic.from([]), throwsArgumentError);
    });
    test('single fails', () {
      expect(() => Statistic.from([1]), throwsArgumentError);
    });
    test('two measurements succeed', () {
      expect(() => Statistic.from([1, 2]), returnsNormally);
    });
    test('10.000 measurements succeed', () {
      final huge = Iterable.generate(
        10000,
        (n) => n * n,
      ).toList(growable: false);
      expect(() => Statistic.from(huge), returnsNormally);
    });
  });

  group('Computes from precomputed', () {
    test('wikipedia sample', () {
      // https://en.wikipedia.org/wiki/Confidence_interval
      final stat = Statistic(
        25,
        250.2,
        250.2,
        250,
        230,
        270,
        2.5,
        240,
        260,
        p01: 0,
        p1: 0,
        p10: 0,
        p25: 0,
        p75: 0,
        p90: 0,
        p99: 0,
        p999: 0,
      );
      expect(stat.stdError, closeTo(0.5, 0.01));
      expect(stat.lowerBound, closeTo(249.22, 0.1));
      expect(stat.upperBound, closeTo(251.18, 0.1));
    });
  });

  group('Factorial', () {
    test('rejects wrong input', () {
      expect(() => factorial(-1), throwsArgumentError);
    });

    test('computes correct factorials for n=<0,52>', () {
      final correctResults = <int, String>{
        0: '1',
        1: '1',
        2: '2',
        3: '6',
        4: '24',
        5: '120',
        6: '720',
        7: '5040',
        8: '40320',
        9: '362880',
        10: '3628800',
        11: '39916800',
        12: '479001600',
        13: '6227020800',
        14: '87178291200',
        15: '1307674368000',
        16: '20922789888000',
        17: '355687428096000',
        18: '6402373705728000',
        19: '121645100408832000',
        20: '2432902008176640000',
        21: '51090942171709440000',
        22: '1124000727777607680000',
        23: '25852016738884976640000',
        24: '620448401733239439360000',
        25: '15511210043330985984000000',
        26: '403291461126605635584000000',
        27: '10888869450418352160768000000',
        28: '304888344611713860501504000000',
        29: '8841761993739701954543616000000',
        30: '265252859812191058636308480000000',
        31: '8222838654177922817725562880000000',
        32: '263130836933693530167218012160000000',
        33: '8683317618811886495518194401280000000',
        34: '295232799039604140847618609643520000000',
        35: '10333147966386144929666651337523200000000',
        36: '371993326789901217467999448150835200000000',
        37: '13763753091226345046315979581580902400000000',
        38: '523022617466601111760007224100074291200000000',
        39: '20397882081197443358640281739902897356800000000',
        40: '815915283247897734345611269596115894272000000000',
        41: '33452526613163807108170062053440751665152000000000',
        42: '1405006117752879898543142606244511569936384000000000',
        43: '60415263063373835637355132068513997507264512000000000',
        44: '2658271574788448768043625811014615890319638528000000000',
        45: '119622220865480194561963161495657715064383733760000000000',
        46: '5502622159812088949850305428800254892961651752960000000000',
        47: '258623241511168180642964355153611979969197632389120000000000',
        48: '12413915592536072670862289047373375038521486354677760000000000',
        49: '608281864034267560872252163321295376887552831379210240000000000',
        50: '30414093201713378043612608166064768844377641568960512000000000000',
        51: '1551118753287382280224243016469303211063259720016986112000000000000',
        52:
            '80658175170943878571660636856403766975289505440883277824000000000000',
      };

      for (var n in correctResults.keys) {
        expect(factorial(n), BigInt.parse(correctResults[n]!));
      }
    });
  });

  group('Computes', () {
    final rand = Random(1);
    final linear = Iterable.generate(500, (n) => n).toList(growable: false);
    final exponential = Iterable.generate(
      500,
      (n) => n * n,
    ).toList(growable: false);
    final random1 = Iterable.generate(
      500,
      (n) => rand.nextInt(500),
    ).toList(growable: false);
    final random2 = Iterable.generate(
      500,
      (n) => rand.nextInt(100),
    ).toList(growable: false);
    final onlyTwo = [1, 2];

    late Statistic linearStat,
        exponentialStat,
        random1Stat,
        random2Stat,
        onlyTwoStat;

    setUp(() {
      linearStat = Statistic.from(linear);
      exponentialStat = Statistic.from(exponential);
      random1Stat = Statistic.from(random1);
      random2Stat = Statistic.from(random2);
      onlyTwoStat = Statistic.from(onlyTwo);
    });

    test('correct means', () {
      expect(linearStat.mean, closeTo(250, 1));
      expect(exponentialStat.mean, closeTo(83000, 1000));
      expect(random1Stat.mean, closeTo(250, 5));
      expect(random2Stat.mean, closeTo(50, 2));
      expect(onlyTwoStat.mean, closeTo(1.5, 0.01));
    });

    test('correct medians', () {
      expect(linearStat.median, closeTo(250, 1));
      expect(exponentialStat.median, closeTo(62500, 1000));
      expect(random1Stat.median, closeTo(250, 5));
      expect(random2Stat.median, closeTo(50, 2));
      expect(onlyTwoStat.median, closeTo(1.5, 0));
    });

    test('correct median from UCL', () {
      // Example from here:
      // https://www.ucl.ac.uk/ich/short-courses-events/about-stats-courses/stats-rm/Chapter_8_Content/confidence_interval_single_median

      final stat = Statistic.from([
        -1.4,
        -0.6,
        -0.2,
        -0.9,
        -3.2,
        -2.4,
        -0.7,
        -5.5,
        0.1,
        -0.1,
        -0.3,
      ]);
      expect(stat.median, closeTo(-0.7, 0.001));
      expect(stat.medianLowerBound, closeTo(-3.2, 0.001));
      expect(stat.medianUpperBound, closeTo(-0.2, 0.001));
    });

    test('correct median from PSU', () {
      // Example from here:
      // https://onlinecourses.science.psu.edu/stat414/node/316

      final stat = Statistic.from([
        2.10,
        2.35,
        2.35,
        3.10,
        3.10,
        3.15,
        3.90,
        3.90,
        4.00,
        4.80,
        5.00,
        5.00,
        5.15,
        5.35,
        5.50,
        6.00,
        6.00,
        6.25,
        6.45,
      ]);
      expect(stat.median, closeTo(4.80, 0.001));
      expect(stat.medianLowerBound, closeTo(3.10, 0.001));
      expect(stat.medianUpperBound, closeTo(5.35, 0.001));
    });

    test('median from two values is tweened', () {
      final stat = Statistic.from([1, 2]);
      expect(stat.median, closeTo(1.5, 0.0001));
    });

    test('quartiles', () {
      final stat = Statistic.from([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(stat.p25, closeTo(2.5, 0.0001));
      expect(stat.median, closeTo(5, 0.0001));
      expect(stat.p75, closeTo(7.5, 0.0001));
    });

    test('percentiles', () {
      final stat = Statistic.from([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(stat.p01, closeTo(0.01, 0.0001));
      expect(stat.p1, closeTo(0.1, 0.0001));
      expect(stat.p10, closeTo(1, 0.0001));
      expect(stat.p90, closeTo(9, 0.0001));
      expect(stat.p99, closeTo(9.9, 0.0001));
      expect(stat.p999, closeTo(9.99, 0.0001));
    });

    test('higher bounds for more random data', () {
      final consistentStat = Statistic.from(
        Iterable.generate(1000, (_) => 100 + rand.nextInt(5)),
      );
      final inconsistentStat = Statistic.from(
        Iterable.generate(1000, (_) => 100 + rand.nextInt(50)),
      );
      expect(
        inconsistentStat.medianUpperBound,
        greaterThan(consistentStat.medianUpperBound),
      );
    });

    test('infinite bounds for small sample sizes', () {
      final smallStat = Statistic.from([1, 2, 1, 2]);
      expect(smallStat.medianLowerBound, double.negativeInfinity);
      expect(smallStat.medianUpperBound, double.infinity);
    });

    test('small sample size doesn\'t show difference', () {
      final smallStat = Statistic.from([1, 2, 1, 2]);
      final hugeStat = Statistic.from(Iterable.generate(1000, (_) => 100));

      expect(smallStat.isDifferentFrom(hugeStat), isFalse);
    });

    test('differences', () {
      expect(linearStat.isDifferentFrom(exponentialStat), isTrue);
      expect(random1Stat.isDifferentFrom(random2Stat), isTrue);
      expect(random1Stat.isDifferentFrom(random1Stat), isFalse);
    });
  });

  group('Shapiro-Wilk', () {
    test('computes normality (w)', () {
      final w = [
        0.2,
        0.2,
        0.2,
        0.2,
        0.2,
        0.4,
        0.3,
        0.2,
        0.2,
        0.1,
        0.2,
        0.2,
        0.1,
        0.1,
        0.2,
        0.4,
        0.4,
        0.3,
        0.3,
        0.3,
        0.2,
        0.4,
        0.2,
        0.5,
        0.2,
        0.2,
        0.4,
        0.2,
        0.2,
        0.2,
        0.2,
        0.4,
        0.1,
        0.2,
        0.2,
        0.2,
        0.2,
        0.1,
        0.2,
        0.2,
        0.3,
        0.3,
        0.2,
        0.6,
        0.4,
        0.3,
        0.2,
        0.2,
        0.2,
        0.2,
        1.4,
        1.5,
        1.5,
        1.3,
        1.5,
        1.3,
        1.6,
        1.0,
        1.3,
        1.4,
        1.0,
        1.5,
        1.0,
        1.4,
        1.3,
        1.4,
        1.5,
        1.0,
        1.5,
        1.1,
        1.8,
        1.3,
        1.5,
        1.2,
        1.3,
        1.4,
        1.4,
        1.7,
        1.5,
        1.0,
        1.1,
        1.0,
        1.2,
        1.6,
        1.5,
        1.6,
        1.5,
        1.3,
        1.3,
        1.3,
        1.2,
        1.4,
        1.2,
        1.0,
        1.3,
        1.2,
        1.3,
        1.3,
        1.1,
        1.3,
        2.5,
        1.9,
        2.1,
        1.8,
        2.2,
        2.1,
        1.7,
        1.8,
        1.8,
        2.5,
        2.0,
        1.9,
        2.1,
        2.0,
        2.4,
        2.3,
        1.8,
        2.2,
        2.3,
        1.5,
        2.3,
        2.0,
        2.0,
        1.8,
        2.1,
        1.8,
        1.8,
        1.8,
        2.1,
        1.6,
        1.9,
        2.0,
        2.2,
        1.5,
        1.4,
        2.3,
        2.4,
        1.8,
        1.8,
        2.1,
        2.4,
        2.3,
        1.9,
        2.3,
        2.5,
        2.3,
        1.9,
        2.0,
        2.3,
        1.8,
      ];
      final result = ShapiroWilk.from(w);
      expect(result.w, closeTo(0.9018, 0.0001));
      expect(result.pValue, closeTo(0.000000017, 0.000000001));
      print(result.describe());
    });

    test('computes normality (c)', () {
      final c = <double>[1, 2, 3, 4];
      final result = ShapiroWilk.from(c);
      expect(result.w, closeTo(0.9929, 0.0001));
      expect(result.pValue, closeTo(0.9719, 0.0001));
      print(result.describe());
    });

    test('computes normality (b)', () {
      final b = <double>[
        36.58,
        36.73,
        36.93,
        37.15,
        37.23,
        37.24,
        37.24,
        36.9,
        36.95,
        36.89,
        36.95,
        37,
        36.9,
        36.99,
        36.99,
        37.01,
        37.04,
        37.04,
        37.14,
        37.07,
        36.98,
        37.01,
        36.97,
        36.97,
        37.12,
        37.13,
        37.14,
        37.15,
        37.17,
        37.12,
        37.12,
        37.17,
        37.28,
        37.28,
        37.44,
        37.51,
        37.64,
        37.51,
        37.98,
        38.02,
        38,
        38.24,
        38.1,
        38.24,
        38.11,
        38.02,
        38.11,
        38.01,
        37.91,
        37.96,
        38.03,
        38.17,
        38.19,
        38.18,
        38.15,
        38.04,
        37.96,
        37.84,
        37.83,
        37.84,
        37.74,
        37.76,
        37.76,
        37.64,
        37.63,
        38.06,
        38.19,
        38.35,
        38.25,
        37.86,
        37.95,
        37.95,
        37.76,
        37.6,
        37.89,
        37.86,
        37.71,
        37.78,
        37.82,
        37.76,
        37.81,
        37.84,
        38.01,
        38.1,
        38.15,
        37.92,
        37.64,
        37.7,
        37.46,
        37.41,
        37.46,
        37.56,
        37.55,
        37.75,
        37.76,
        37.73,
        37.77,
        38.01,
        38.04,
        38.07,
      ];
      final result = ShapiroWilk.from(b);
      expect(result.w, closeTo(0.9334, 0.0001));
      expect(result.pValue, closeTo(0.000078, 0.000001));
      print(result.describe());
    });

    test('erf works', () {
      expect(erf(0.001), closeTo(0.001128379, 0.000000001));
      expect(erf(0.1), closeTo(0.112462916, 0.000000001));
      expect(erf(0.5), closeTo(0.520499878, 0.000000001));
      expect(erf(1), closeTo(0.842700793, 0.000000001));
      expect(erf(3), closeTo(0.999977910, 0.000000001));
      expect(erf(-3), closeTo(-0.999977910, 0.000000001));
    });
  });

  group('Mann-Whitney', () {
    test('Wikipedia Aesop example', () {
      // https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test#Illustration_of_calculation_methods
      final tortoiseScore = <double>[12, 6, 5, 4, 3, 2];
      final hareScore = <double>[11, 10, 9, 8, 7, 1];

      final mannWhitney = MannWhitney.from(tortoiseScore, hareScore);

      expect(mannWhitney.u1, 11);
      expect(mannWhitney.u2, 25);
      expect(mannWhitney.effectSize, lessThan(0.5));
    });

    test('complete win', () {
      final winners = <double>[12, 12, 10, 7];
      final losers = <double>[1, 2, 3, 4, 5, 5, 5];

      final mannWhitney = MannWhitney.from(winners, losers);

      expect(mannWhitney.u2, 0);
      expect(mannWhitney.effectSize, 1.0);
    });

    test('complete loss', () {
      final winners = <double>[12, 12, 10, 7];
      final losers = <double>[1, 2, 3, 4, 5, 5, 5];

      final mannWhitney = MannWhitney.from(losers, winners);

      expect(mannWhitney.u1, 0);
      expect(mannWhitney.effectSize, 0.0);
    });

    test('lots of identical values', () {
      final winners = <double>[12, 10, 10, 10, 10, 10, 10];
      final losers = <double>[10, 10, 10, 10, 9];

      final mannWhitney = MannWhitney.from(winners, losers);

      expect(mannWhitney.u1, greaterThan(mannWhitney.u2));
      expect(mannWhitney.effectSize, greaterThan(0.5));
    });

    test('complete draw', () {
      final a = <double>[1, 2, 3, 4, 5];
      final b = <double>[2, 2, 3, 4, 4];

      final mannWhitney = MannWhitney.from(a, b);

      expect(mannWhitney.u1, equals(mannWhitney.u2));
      expect(mannWhitney.effectSize, 0.5);
    });
  });
}

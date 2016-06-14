// Copyright (c) 2016, Filip Hracek. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE
// file.

/// Support for simple t-statistics on lists of numbers.
library t_stats;

import 'dart:math' as math;

part 'src/t_distribution.dart';

/// Statistic information about a measurement.
class Statistic {
  /// Sample size.
  final int n;

  /// Geometric mean (average).
  ///
  /// https://en.wikipedia.org/wiki/Expected_value
  final num mean;

  // TODO: final num median;

  /// Maximum observed number.
  final num max;

  /// Minimum observed number.
  final num min;

  /// Standard deviation.
  ///
  /// https://en.wikipedia.org/wiki/Standard_deviation
  final num stdDeviation;

  /// Standard error.
  ///
  /// https://en.wikipedia.org/wiki/Standard_error
  final num stdError;

  /// Name or description of the measurement.
  final String name;

  /// Number of significant fraction digits.
  final int precision;

  // TODO: suggested precision - precision where mean - stdErr and mean + stdErr only differ by at most one number
  //  can be negative when we have precision in the tens, for example
  //  need to figure out what to do with input like [1], though

  /// Direct constructor of a Statistic instance.
  ///
  /// You probably want to use [Statistic.from] instead. But this constructor
  /// exists in case you know the statistics (like when you computed them
  /// ahead of time) and want to compare them to others.
  Statistic(int n, this.mean, this.min, this.max, num stdDeviation,
      {this.name, this.precision: 2})
      : n = n,
        stdDeviation = stdDeviation,
        stdError = stdDeviation / math.sqrt(n);

  /// Takes [values] and creates the Statistic instance with its stats.
  factory Statistic.from(List<num> values, {String name}) {
    if (values == null) throw new ArgumentError.notNull("values");
    if (values.length == 0) {
      throw new ArgumentError("Cannot make stats from empty list of values");
    }
    if (values.length == 1) {
      throw new ArgumentError("Cannot make stats from one value");
    }
    double total = 0.0;
    num max = double.NEGATIVE_INFINITY;
    num min = double.INFINITY;
    for (num value in values) {
      total += value;
      max = math.max(value, max);
      min = math.min(value, min);
    }

    double mean = total / values.length;

    double deltaSquaredSum = 0.0;
    for (num value in values) {
      double delta = value - mean;
      deltaSquaredSum += delta * delta;
    }
    double variance = deltaSquaredSum / (values.length - 1);
    double stdDeviation = math.sqrt(variance);
    return new Statistic(values.length, mean, min, max, stdDeviation,
        name: name);
  }

  /// 95% confidence interval lower bound.
  num get lowerBound => mean - marginOfError;

  /// The margin of error.
  ///
  /// https://en.wikipedia.org/wiki/Margin_of_error
  num get marginOfError => _computeTDistribution(n) * stdError;

  /// 95% confidence interval upper bound.
  num get upperBound => mean + marginOfError;

  /// Returns `true` if statistic is significantly different from [other].
  ///
  /// This assumes normal distribution or very large samples. It is implemented
  /// by simply computing whether confidence intervals at given [confidence]
  /// level don't overlap.
  ///
  /// The confidence interval is at 95% confidence level.
  bool isDifferentFrom(Statistic other) =>
      (other.lowerBound < lowerBound && other.upperBound < lowerBound) ||
      (other.lowerBound > upperBound && other.upperBound > upperBound);

  toString() => "${_fmt(mean).padLeft(8)} ± ${_fmt(marginOfError).padLeft(6)}"
      "    ${name ?? ''}";

  String _fmt(num value, {int precision}) {
    precision ??= this.precision;
    return value.toStringAsFixed(precision);
  }
}

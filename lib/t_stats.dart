// Copyright (c) 2016, Filip Hracek. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE
// file.

/// Support for simple t-statistics on lists of numbers.
library t_stats;

import 'dart:math' as math;

import 'package:t_stats/src/median_confidence.dart';

part 'src/t_distribution.dart';

/// Statistic information about a measurement.
class Statistic {
  /// Sample size.
  final int n;

  /// Geometric mean (average).
  ///
  /// https://en.wikipedia.org/wiki/Expected_value
  final num mean;

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

  /// Median value.
  final num median;

  /// The lower bound of the 95% confidence interval of the population median.
  final num medianLowerBound;

  /// The upper bound of the 95% confidence interval of the population median.
  final num medianUpperBound;

  /// Direct constructor of a Statistic instance.
  ///
  /// You probably want to use [Statistic.from] instead. But this constructor
  /// exists in case you know the statistics (like when you computed them
  /// ahead of time) and want to compare them to others.
  Statistic(int n, this.mean, this.median, this.min, this.max, num stdDeviation,
      this.medianLowerBound, this.medianUpperBound,
      {this.name, this.precision = 2})
      : n = n,
        stdDeviation = stdDeviation,
        stdError = stdDeviation / math.sqrt(n);

  // TODO: suggested precision - precision where mean - stdErr and mean + stdErr only differ by at most one number
  //  can be negative when we have precision in the tens, for example
  //  need to figure out what to do with input like [1], though

  /// Takes [values] and creates the Statistic instance with its stats.
  factory Statistic.from(Iterable<num> values, {String name}) {
    if (values == null) throw ArgumentError.notNull("values");

    final orderedValues = List<num>.from(values, growable: false)
      ..sort();
    final n = orderedValues.length;
    if (n == 0) {
      throw ArgumentError("Cannot make stats from empty list of values");
    }
    if (n == 1) {
      throw ArgumentError("Cannot make stats from one value");
    }

    final min = orderedValues.first;
    final max = orderedValues.last;

    var total = 0.0;
    for (var value in orderedValues) {
      total += value;
    }

    final mean = total / n;

    var deltaSquaredSum = 0.0;
    for (var value in orderedValues) {
      final double delta = value - mean;
      deltaSquaredSum += delta * delta;
    }
    final variance = deltaSquaredSum / (n - 1);
    final stdDeviation = math.sqrt(variance);

    num median;
    if (n.isOdd) {
      median = orderedValues[n ~/ 2];
    } else {
      final index = n ~/ 2 - 1;
      median = (orderedValues[index] + orderedValues[index + 1]) / 2;
    }
    final interval = computeMedianConfidence(n);
    final lower = interval.isInvalid
        ? double.negativeInfinity
        : orderedValues[interval.a - 1];
    final upper =
        interval.isInvalid ? double.infinity : orderedValues[interval.b - 1];

    return Statistic(orderedValues.length, mean, median, min, max, stdDeviation,
        lower, upper,
        name: name);
  }

  /// 95% confidence interval lower bound of the [mean].
  num get lowerBound => mean - marginOfError;

  /// The [mean]'s margin of error for 95% confidence.
  ///
  /// https://en.wikipedia.org/wiki/Margin_of_error
  num get marginOfError => _computeTDistribution(n) * stdError;

  /// 95% confidence interval upper bound of the [mean].
  num get upperBound => mean + marginOfError;

  /// Returns `true` if statistic is significantly different from [other].
  ///
  /// This assumes normal distribution or very large samples. It is implemented
  /// by simply computing whether confidence intervals at given confidence
  /// level don't overlap.
  ///
  /// Note that when two statistics _do_ overlap, we cannot say anything with
  /// statistical significance (i.e. it doesn't mean 'there is no statistical
  /// difference' -- there very well may be). See link below for more info.
  /// http://www.graphpad.com/support/faqid/1362/
  ///
  /// The confidence interval is at 95% confidence level.
  bool isDifferentFrom(Statistic other) =>
      (other.medianLowerBound < medianLowerBound &&
          other.medianUpperBound < medianLowerBound) ||
      (other.medianLowerBound > medianUpperBound &&
          other.medianUpperBound > medianUpperBound);

  /// Serialize [Statistic] as a [Map].
  Map<String, Object> toMap() => <String, Object>{
        "name": name,
        "n": n,
        "mean": mean,
        "max": max,
        "min": min,
        "stdDeviation": stdDeviation,
        "stdError": stdError,
        "lowerBound": lowerBound,
        "marginOfError": marginOfError,
        "upperBound": upperBound
      };

  /// Output [Statistic] as a string.
  ///
  /// This will output something like the following:
  ///
  ///        15.00  ±  28.78 MoE /  34.50 SD    Name of statistic
  ///
  /// The first number is the geometric [mean], the second is the
  /// [marginOfError] and the third is the [stdDeviation]. If [name]
  /// is specified, it will trail the line.
  ///
  /// The line is formatted for easy use in tables, such as when outputting
  /// and comparing many statistics in the terminal.
  @override
  String toString() => "${_fmt(mean).padLeft(8)}  "
      "± ${_fmt(marginOfError).padLeft(6)} MoE / "
      "${_fmt(stdDeviation).padLeft(6)} SD    "
      "${name ?? ''}";

  /// Returns a tab separated value (TSV) string of [name], [mean],
  /// [lowerBound], [upperBound], [marginOfError], [stdDeviation], [stdError],
  /// [min], [max], [n].
  ///
  /// This is useful for copy-pasting to graphing programs and spreadsheets.
  String toTSV() => [
        name ?? "",
        mean,
        lowerBound,
        upperBound,
        marginOfError,
        stdDeviation,
        stdError,
        min,
        max,
        n
      ].join("\t");

  String _fmt(num value, {int precision}) {
    precision ??= this.precision;
    return value.toStringAsFixed(precision);
  }
}

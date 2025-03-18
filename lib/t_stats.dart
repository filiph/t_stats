// Copyright (c) 2016, Filip Hracek. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE
// file.

import 'dart:math' as math;

import 'package:t_stats/src/median_confidence.dart';

export 'package:t_stats/src/mann_whitney.dart';
export 'package:t_stats/src/shapiro_wilk.dart';

part 'src/t_distribution.dart';

/// Statistic information about a measurement.
class Statistic {
  /// Sample size.
  final int n;

  /// Arithmetic mean (a.k.a. [average]).
  ///
  /// https://en.wikipedia.org/wiki/Expected_value
  final num mean;

  /// Geometric mean.
  final num meanGeometric;

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

  /// Coefficient of variation. Unlike [stdError], this scales with
  /// the measurement magnitudes. It's a better representation of
  /// the variability of data when comparing statistics with different mean.
  ///
  /// https://en.wikipedia.org/wiki/Coefficient_of_variation
  final num coefficientOfVariation;

  /// The lower bound of the 95% confidence interval of the population median.
  final num medianLowerBound;

  /// The upper bound of the 95% confidence interval of the population median.
  final num medianUpperBound;

  /// The 0.1 percentile value, a.k.a the first permil.
  final num p01;

  /// The 1st percentile value.
  final num p1;

  /// The 10th percentile value, a.k.a. the first decile.
  final num p10;

  /// The 25th percentile value, a.k.a. the first quartile.
  final num p25;

  /// The 75th percentile value, a.k.a. the third quartile.
  final num p75;

  /// The 90th percentile value, a.k.a. the ninth decile.
  final num p90;

  /// The 99th percentile value.
  final num p99;

  /// The 99.9 percentile value, a.k.a. the 999th permil.
  final num p999;

  /// Direct constructor of a Statistic instance.
  ///
  /// You probably want to use [Statistic.from] instead. But this constructor
  /// exists in case you know the statistics (like when you computed them
  /// ahead of time) and want to compare them to others.
  Statistic(
    this.n,
    this.mean,
    this.meanGeometric,
    this.median,
    this.min,
    this.max,
    this.stdDeviation,
    this.medianLowerBound,
    this.medianUpperBound, {
    this.name = '',
    this.precision = 2,
    required this.p01,
    required this.p1,
    required this.p10,
    required this.p25,
    required this.p75,
    required this.p90,
    required this.p99,
    required this.p999,
  }) : stdError = stdDeviation / math.sqrt(n),
       coefficientOfVariation = stdDeviation / mean;

  /// Takes [values] and creates the Statistic instance with its stats.
  factory Statistic.from(Iterable<num> values, {String name = ''}) {
    final orderedValues = List<num>.from(values, growable: false)..sort();
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
    var logTotal = 0.0;
    for (var value in orderedValues) {
      total += value;
      logTotal += math.log(value);
    }

    final mean = total / n;
    final logMean = logTotal / n;
    final meanGeometric = math.exp(logMean);

    var deltaSquaredSum = 0.0;
    for (var value in orderedValues) {
      final delta = value - mean;
      deltaSquaredSum += delta * delta;
    }
    final variance = deltaSquaredSum / (n - 1);
    final stdDeviation = math.sqrt(variance);

    num median = _calculatePercentile(orderedValues, 0.5);
    final interval = computeMedianConfidence(n);
    final lower =
        interval.isInvalid
            ? double.negativeInfinity
            : orderedValues[interval.a - 1];
    final upper =
        interval.isInvalid ? double.infinity : orderedValues[interval.b - 1];

    final p01 = _calculatePercentile(orderedValues, 0.001);
    final p1 = _calculatePercentile(orderedValues, 0.01);
    final p10 = _calculatePercentile(orderedValues, 0.1);
    final q1 = _calculatePercentile(orderedValues, 0.25);
    final q3 = _calculatePercentile(orderedValues, 0.75);
    final p90 = _calculatePercentile(orderedValues, 0.9);
    final p99 = _calculatePercentile(orderedValues, 0.99);
    final p999 = _calculatePercentile(orderedValues, 0.999);

    return Statistic(
      orderedValues.length,
      mean,
      meanGeometric,
      median,
      min,
      max,
      stdDeviation,
      lower,
      upper,
      name: name,
      p01: p01,
      p1: p1,
      p10: p10,
      p25: q1,
      p75: q3,
      p90: p90,
      p99: p99,
      p999: p999,
    );
  }

  // TODO: suggested precision - precision where mean - stdErr and mean + stdErr only differ by at most one number
  //  can be negative when we have precision in the tens, for example
  //  need to figure out what to do with input like [1], though

  /// Alias for [mean].
  num get average => mean;

  /// 95% confidence interval lower bound of the [mean].
  num get lowerBound => mean - marginOfError;

  /// The [mean]'s margin of error for 95% confidence.
  ///
  /// https://en.wikipedia.org/wiki/Margin_of_error
  num get marginOfError => _computeTDistribution(n) * stdError;

  num get p50 => median;

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
    "upperBound": upperBound,
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
  String toString() =>
      "${_fmt(mean).padLeft(8)}  "
      "± ${_fmt(marginOfError).padLeft(6)} MoE / "
      "${_fmt(stdDeviation).padLeft(6)} SD    "
      "$name";

  /// Returns the tabulated string of five-number summary.
  ///
  /// https://en.wikipedia.org/wiki/Five-number_summary
  String toFiveNumberSummary() =>
      "${_fmt(min).padLeft(8)}  "
      "${_fmt(p25).padLeft(8)}  "
      "${_fmt(median).padLeft(8)}  "
      "${_fmt(p75).padLeft(8)}  "
      "${_fmt(max).padLeft(8)}";

  /// Returns a tab separated value (TSV) string of [name], [mean],
  /// [lowerBound], [upperBound], [marginOfError], [stdDeviation], [stdError],
  /// [min], [max], [n].
  ///
  /// This is useful for copy-pasting to graphing programs and spreadsheets.
  String toTSV() => [
    name,
    mean,
    lowerBound,
    upperBound,
    marginOfError,
    stdDeviation,
    stdError,
    min,
    max,
    n,
  ].join("\t");

  String _fmt(num value) {
    return value.toStringAsFixed(precision);
  }

  static num _calculatePercentile(List<num> orderedValues, double percentile) {
    if (percentile < 0 || percentile > 1) {
      throw ArgumentError('Percentile must be between 0 and 1');
    }

    assert(orderedValues.isNotEmpty);
    if (orderedValues.length == 1) {
      return orderedValues[0];
    }

    double position = percentile * (orderedValues.length - 1);

    if (position.floor() == position) {
      return orderedValues[position.toInt()];
    }

    int lowerIndex = position.floor();
    int upperIndex = position.ceil();
    num lowerValue = orderedValues[lowerIndex];
    num upperValue = orderedValues[upperIndex];

    double fraction = position - lowerIndex;
    return lowerValue + fraction * (upperValue - lowerValue);
  }
}

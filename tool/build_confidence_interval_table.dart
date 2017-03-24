import 'dart:math' as math;

import 'package:bignum/bignum.dart';
import 'package:t_stats/src/factorial.dart';
import 'package:t_stats/src/pair.dart';

/// Inspired by
/// https://onlinecourses.science.psu.edu/stat414/node/316

void main() {
  for (int n = 2; n <= 300; n++) {
    Pair best;
    double bestConfidence;
    double bestDeltaFrom95 = double.INFINITY;
    for (var bracket in _generateGrowingBracket(n)) {
      final confidence = computeConfidenceCoefficient(n, bracket.a, bracket.b);
      final delta = (confidence - 0.95).abs();
      if (confidence >= 0.95 && delta < bestDeltaFrom95) {
        best = bracket;
        bestConfidence = confidence;
        bestDeltaFrom95 = delta;
      }
    }
    if (best == null) {
      print("$n cannot have 95%+ confidence");
      continue;
    }
    final asPercentiles = "${(best.a / n * 100).toStringAsFixed(2)}"
        ",${(best.b / n * 100).toStringAsFixed(2)}";
    print("$n,${best.a},${best.b},$asPercentiles,$bestConfidence");
  }
}

/// Computes the binomial coefficient of n over k.
///
/// See:
/// http://mathworld.wolfram.com/BinomialCoefficient.html
BigInteger computeBinomialCoefficient(int n, int k) {
  final BigInteger nFactorial = factorial(n);
  final BigInteger kFactorial = factorial(k);
  final BigInteger nMinusKFactorial = factorial(n - k);
  final result = (nFactorial) / (kFactorial * nMinusKFactorial);
  return result;
}

/// Computes the confidence coefficient for sample of size [n] and bracket
/// value positions.
double computeConfidenceCoefficient(
    int n, int lowerPosition, int higherPosition) {
  // P(Y1 < m < Y5) = P(W = 1) + P(W = 2) + P(W = 3) + P(W = 4)
  double result = 0.0;
  for (int k = lowerPosition; k < higherPosition; k++) {
    // P(W) = (n over k) * ((0.5) ** k) * ((0.5) ** (n - k))
//    print("computing P(W = $k)");
    final BigInteger nOverK = computeBinomialCoefficient(n, k);
    final double powers = math.pow(0.5, k) * math.pow(0.5, n - k);
    final double P = _multiply(nOverK, powers);
    result += P;
  }
  return result;
}

Iterable<Pair> _generateGrowingBracket(int n) sync* {
  final int medianPosition = n ~/ 2;
  int lower = medianPosition;
  int higher = medianPosition + 1;
  while (lower > 0 || higher < n) {
    yield new Pair(lower, higher);
    if (lower - 1 >= 0) yield new Pair(lower - 1, higher);
    if (higher + 1 <= n) yield new Pair(lower, higher + 1);
    lower = math.max(0, lower - 1);
    higher = math.min(n, higher + 1);
  }
}

/// Multiplies [BigInteger] number by a [double] and returns a double.
///
/// It is expected that the result will be <0,1>.
double _multiply(BigInteger integer, double powers) {
  BigInteger divided = integer.clone();
  double multiplied = powers;
  final billion = 1000000000;
  final billionInteger = new BigInteger(1000000000);
  while (divided.bitCount() > 32) {
    divided = divided.divide(billionInteger);
    multiplied *= billion;
  }
  return divided.intValue() * multiplied;
}

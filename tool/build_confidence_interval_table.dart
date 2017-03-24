import 'dart:math' as math;

import 'package:bignum/bignum.dart';

import 'package:t_stats/src/factorial.dart';

/// Inspired by
/// https://onlinecourses.science.psu.edu/stat414/node/316

void main() {
//  print(computeConfidenceCoefficient(5, 1, 5));
//  print(computeConfidenceCoefficient(6, 1, 6));
//  print(computeConfidenceCoefficient(19, 6, 14));
//  print(computeConfidenceCoefficient(20, 6, 15));
//  _generateGrowingBracket(20).forEach(print);
  for (int n = 5; n <= 20; n++) {
    print("== n = $n ==");
    _Pair best;
    double bestDeltaFrom95 = double.INFINITY;
    for (var bracket in _generateGrowingBracket(n)) {
      final confidence = computeConfidenceCoefficient(n, bracket.a, bracket.b);
      print("$bracket\t$confidence");
      final delta = (confidence - 0.935).abs();
      if (delta < bestDeltaFrom95) {
        best = bracket;
        bestDeltaFrom95 = delta;
      }
    }
    print("Best for ($n) == $best");
  }
}

class _Pair {
  final int a, b;
  const _Pair(this.a, this.b);
  @override
  String toString() => "($a,$b)";
  @override
  int get hashCode => 100000 * a + b;
  @override
  bool operator==(Object other) => other is _Pair && other.hashCode == hashCode;
}

Iterable<_Pair> _generateGrowingBracket(int n) sync* {
  final int medianPosition = n ~/ 2;
  int lower = medianPosition;
  int higher = medianPosition + 1;
  while (lower > 0 || higher < n) {
    yield new _Pair(lower, higher);
    if (lower - 1 >= 0) yield new _Pair(lower - 1, higher);
    if (higher + 1 <= n) yield new _Pair(lower, higher + 1);
    lower = math.max(0, lower - 1);
    higher = math.min(n, higher + 1);
  }
}

/// Computes the confidence coefficient for sample of size [n] and bracket
/// value positions.
double computeConfidenceCoefficient(
    int n, int lowerPosition, int higherPosition) {
  // P(Y1 < m < Y5) = P(W = 1) + P(W = 2) + P(W = 3) + P(W = 4)
  double result = 0.0;
  final int medianPosition = n ~/ 2;
  for (int k = lowerPosition; k < higherPosition; k++) {
    // P(W) = (n over k) * ((0.5) ** k) * ((0.5) ** (n - k))
//    print("computing P(W = $k)");
    final int nOverK = computeBinomialCoefficient(n, k);
    final double P = nOverK * math.pow(0.5, k) * math.pow(0.5, n - k);
    result += P;
  }
  return result;
}

/// Computes the binomial coefficient of n over k.
///
/// See:
/// http://mathworld.wolfram.com/BinomialCoefficient.html
int computeBinomialCoefficient(int n, int k) {
  final BigInteger nFactorial = factorial(n);
  final BigInteger kFactorial = factorial(k);
  final BigInteger nMinusKFactorial = factorial(n - k);
  final result = (nFactorial) / (kFactorial * nMinusKFactorial);
  return result.intValue();
}

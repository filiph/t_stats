import 'dart:math' as math;

import 'package:meta/meta.dart';

/// Error function.
@visibleForTesting
double erf(double z) {
  double term;
  double sum = 0;
  int n = 0;
  do {
    term =
        math.pow(-1, n) *
        math.pow(z, 2 * n + 1) /
        _fac(n.toDouble()) /
        (2 * n + 1);
    sum = sum + term;
    n++;
  } while (term.abs() > 0.000000000001);
  return sum * 2 / math.sqrt(math.pi);
}

/// Factorial.
///
/// Uses [double] instead of int because these computations can go so high
/// that [int] overflows.
double _fac(double n) {
  var result = 1.0;
  for (var i = 2; i <= n; i++) {
    result = result * i;
  }
  return result;
}

class StandardNormal extends _Normal {
  StandardNormal() : super(0, 1);
}

/// This is adapted from
/// https://github.com/pieterprovoost/jerzy/blob/master/lib/distributions.js.
/// But only what's absolutely needed is implemented.
class _Normal {
  final double mean;
  final double variance;

  _Normal(this.mean, this.variance);

  double distr(double arg) {
    return _di(arg);
  }

  double inverse(double x) {
    var a1 = -3.969683028665376e+1;
    var a2 = 2.209460984245205e+2;
    var a3 = -2.759285104469687e+2;
    var a4 = 1.383577518672690e+2;
    var a5 = -3.066479806614716e+1;
    var a6 = 2.506628277459239e+0;

    var b1 = -5.447609879822406e+1;
    var b2 = 1.615858368580409e+2;
    var b3 = -1.556989798598866e+2;
    var b4 = 6.680131188771972e+1;
    var b5 = -1.328068155288572e+1;

    var c1 = -7.784894002430293e-3;
    var c2 = -3.223964580411365e-1;
    var c3 = -2.400758277161838e+0;
    var c4 = -2.549732539343734e+0;
    var c5 = 4.374664141464968e+0;
    var c6 = 2.938163982698783e+0;

    var d1 = 7.784695709041462e-3;
    var d2 = 3.224671290700398e-1;
    var d3 = 2.445134137142996e+0;
    var d4 = 3.754408661907416e+0;

    double q;
    double r;
    double y;

    if (x < 0.02425) {
      q = math.sqrt(-2 * math.log(x));
      y =
          (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /
          ((((d1 * q + d2) * q + d3) * q + d4) * q + 1);
    } else if (x < 1 - 0.02425) {
      q = x - 0.5;
      r = q * q;
      y =
          (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) *
          q /
          (((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1);
    } else {
      q = math.sqrt(-2 * math.log(1 - x));
      y =
          -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /
          ((((d1 * q + d2) * q + d3) * q + d4) * q + 1);
    }

    return y * variance + mean;
  }

  double _di(double x) =>
      0.5 * (1 + erf((x - mean) / (math.sqrt(variance) * math.sqrt(2))));
}

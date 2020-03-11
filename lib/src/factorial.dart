import 'dart:math' as math;

/// Computes factorial of [n].
///
/// Uses the efficient FactorialSplit algorithm:
/// https://github.com/PeterLuschny/Fast-Factorial-Functions/blob/master/JavaFactorial/src/de/luschny/math/factorial/FactorialSplit.java
BigInt factorial(int n) {
  if (n < 0) {
    throw ArgumentError("Factorial of $n is undefined.");
  }

  if (n < 2) return BigInt.one;

  var p = BigInt.one;
  var r = BigInt.one;
  var N = 1;

  BigInt product(int n) {
    final m = n ~/ 2;
    if (m == 0) {
      return BigInt.from(N += 2);
    }
    if (n == 2) {
      return BigInt.from((N += 2) * (N += 2));
    }
    return product(n - m) * product(m);
  }

  var h = 0;
  var shift = 0;
  var high = 1;
  var log2n = (math.log(n) / math.ln2).floor();

  while (h != n) {
    shift += h;
    h = n >> log2n;
    log2n -= 1;
    var len = high;
    high = (h - 1) | 1;
    len = (high - len) ~/ 2;

    if (len > 0) {
      p *= product(len);
      r *= p;
    }
  }

  return r << shift;
}

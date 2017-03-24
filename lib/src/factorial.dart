import 'dart:math' as math;

import 'package:bignum/bignum.dart';

/// Computes factorial of [n].
///
/// Uses the efficient FactorialSplit algorithm:
/// https://github.com/PeterLuschny/Fast-Factorial-Functions/blob/master/JavaFactorial/src/de/luschny/math/factorial/FactorialSplit.java
BigInteger factorial(int n) {
  if (n < 0) {
    throw new ArgumentError("Factorial of $n is undefined.");
  }

  if (n < 2) return new BigInteger(1);

  BigInteger p = BigInteger.ONE;
  BigInteger r = BigInteger.ONE;
  int N = 1;

  BigInteger product(int n) {
    final int m = n ~/ 2;
    if (m == 0) {
      return new BigInteger(N += 2);
    }
    if (n == 2) {
      return new BigInteger((N += 2) * (N += 2));
    }
    return product(n - m).multiply(product(m));
  }

  int h = 0;
  int shift = 0;
  int high = 1;
  int log2n = (math.log(n) / math.LN2).floor();

  while (h != n) {
    shift += h;
    h = n >> log2n;
    log2n -= 1;
    int len = high;
    high = (h - 1) | 1;
    len = (high - len) ~/ 2;

    if (len > 0) {
      p *= product(len);
      r *= p;
    }
  }

  return r << shift;
}
import 'dart:math';

import 'package:t_stats/src/pair.dart';

const Map<int, Pair> _precomputedIntervals = const {
  6: const Pair(1, 6), // 96.87% confidence
  7: const Pair(1, 7), // 98.43% confidence
  8: const Pair(1, 7), // 96.09% confidence
  9: const Pair(2, 8), // 96.09% confidence
  10: const Pair(2, 9), // 97.85% confidence
  11: const Pair(2, 9), // 96.14% confidence
  12: const Pair(3, 10), // 96.14% confidence
  13: const Pair(2, 10), // 95.21% confidence
  14: const Pair(3, 11), // 96.48% confidence
  15: const Pair(4, 12), // 96.48% confidence
  16: const Pair(4, 12), // 95.09% confidence
  17: const Pair(5, 13), // 95.09% confidence
  18: const Pair(5, 14), // 96.91% confidence
  19: const Pair(5, 14), // 95.86% confidence
  20: const Pair(6, 15), // 95.86% confidence
  21: const Pair(5, 15), // 95.72% confidence
  22: const Pair(6, 16), // 96.53% confidence
  23: const Pair(7, 17), // 96.53% confidence
  24: const Pair(7, 17), // 95.67% confidence
  25: const Pair(8, 18), // 95.67% confidence
  26: const Pair(8, 19), // 97.10% confidence
  27: const Pair(8, 19), // 96.43% confidence
  28: const Pair(9, 20), // 96.43% confidence
  29: const Pair(9, 20), // 95.72% confidence
  30: const Pair(10, 21), // 95.72% confidence
  31: const Pair(9, 21), // 95.92% confidence
  32: const Pair(10, 22), // 96.49% confidence
  33: const Pair(10, 22), // 95.31% confidence
  34: const Pair(11, 23), // 95.90% confidence
  35: const Pair(12, 24), // 95.90% confidence
  36: const Pair(12, 24), // 95.29% confidence
  37: const Pair(13, 25), // 95.29% confidence
  38: const Pair(13, 26), // 96.64% confidence
  39: const Pair(13, 26), // 96.15% confidence
  40: const Pair(14, 27), // 96.15% confidence
  41: const Pair(14, 27), // 95.64% confidence
  42: const Pair(15, 28), // 95.64% confidence
  43: const Pair(15, 28), // 95.12% confidence
  44: const Pair(16, 29), // 95.12% confidence
  45: const Pair(15, 29), // 95.57% confidence
  46: const Pair(16, 30), // 96.00% confidence
  47: const Pair(16, 30), // 95.12% confidence
  48: const Pair(17, 31), // 95.56% confidence
  49: const Pair(18, 32), // 95.56% confidence
  50: const Pair(18, 32), // 95.11% confidence
  51: const Pair(19, 33), // 95.11% confidence
  52: const Pair(19, 34), // 96.35% confidence
  53: const Pair(19, 34), // 95.97% confidence
  54: const Pair(20, 35), // 95.97% confidence
  55: const Pair(20, 35), // 95.59% confidence
  56: const Pair(21, 36), // 95.59% confidence
  57: const Pair(21, 36), // 95.20% confidence
  58: const Pair(22, 37), // 95.20% confidence
  59: const Pair(21, 37), // 95.71% confidence
  60: const Pair(22, 38), // 96.03% confidence
  61: const Pair(22, 38), // 95.37% confidence
  62: const Pair(23, 39), // 95.70% confidence
  63: const Pair(23, 39), // 95.02% confidence
  64: const Pair(24, 40), // 95.36% confidence
  65: const Pair(25, 41), // 95.36% confidence
  66: const Pair(26, 42), // 95.01% confidence
  67: const Pair(26, 42), // 95.01% confidence
  68: const Pair(26, 43), // 96.15% confidence
  69: const Pair(26, 43), // 95.86% confidence
  70: const Pair(27, 44), // 95.86% confidence
  71: const Pair(27, 44), // 95.56% confidence
  72: const Pair(28, 45), // 95.56% confidence
  73: const Pair(28, 45), // 95.26% confidence
  74: const Pair(29, 46), // 95.26% confidence
  75: const Pair(28, 46), // 95.78% confidence
  76: const Pair(29, 47), // 96.04% confidence
  77: const Pair(29, 47), // 95.52% confidence
  78: const Pair(30, 48), // 95.78% confidence
  79: const Pair(30, 48), // 95.25% confidence
  80: const Pair(31, 49), // 95.51% confidence
  81: const Pair(32, 50), // 95.51% confidence
  82: const Pair(32, 50), // 95.24% confidence
  83: const Pair(33, 51), // 95.24% confidence
  84: const Pair(33, 52), // 96.24% confidence
  85: const Pair(33, 52), // 96.01% confidence
  86: const Pair(34, 53), // 96.01% confidence
  87: const Pair(34, 53), // 95.77% confidence
  88: const Pair(35, 54), // 95.77% confidence
  89: const Pair(35, 54), // 95.54% confidence
  90: const Pair(36, 55), // 95.54% confidence
  91: const Pair(36, 55), // 95.29% confidence
  92: const Pair(37, 56), // 95.29% confidence
  93: const Pair(37, 56), // 95.05% confidence
  94: const Pair(38, 57), // 95.05% confidence
  95: const Pair(37, 57), // 95.61% confidence
  96: const Pair(38, 58), // 95.82% confidence
  97: const Pair(38, 58), // 95.39% confidence
  98: const Pair(39, 59), // 95.61% confidence
  99: const Pair(39, 59), // 95.17% confidence
  100: const Pair(40, 60), // 95.39% confidence
};

/// Returns the lower and the upper ranked value position for 95% confidence
/// level.
///
/// Returning -1 for both values means [n] is two low to provide a median-based
/// confidence interval.
Pair computeMedianConfidence(int n) {
  if (n <= 5) {
    // Even the interval from 0th to 100th percentile will give confidence
    // below 95%.
    return const Pair.invalid();
  }

  if (n > 100) {
    // Use the classic formula.
    final double sqrtN = sqrt(n);
    final int lower = (n / 2 - 1.96 * sqrtN / 2).ceil();
    final int upper = (1 + n / 2 + 1.96 * sqrtN / 2).floor();
    return new Pair(lower, upper);
  }

  // We should use our hand-crafted intervals (provided by
  // `tool/build_confidence_interval_table.dart`).
  return _precomputedIntervals[n];
}

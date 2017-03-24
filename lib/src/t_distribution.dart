part of t_stats;

/// Computes t-distribution critical values for given sample size [n].
///
/// Stolen from https://github.com/dart-lang/ton80/blob/master/bin/ton80.dart.
double _computeTDistribution(int n) {
  const List<double> table = const [
    double.NAN,
    double.NAN,
    12.71,
    4.30,
    3.18,
    2.78,
    2.57,
    2.45,
    2.36,
    2.31,
    2.26,
    2.23,
    2.20,
    2.18,
    2.16,
    2.14,
    2.13,
    2.12,
    2.11,
    2.10,
    2.09,
    2.09,
    2.08,
    2.07,
    2.07,
    2.06,
    2.06,
    2.06,
    2.05,
    2.05,
    2.05,
    2.04,
    2.04,
    2.04,
    2.03,
    2.03,
    2.03,
    2.03,
    2.03,
    2.02,
    2.02,
    2.02,
    2.02,
    2.02,
    2.02,
    2.02,
    2.01,
    2.01,
    2.01,
    2.01,
    2.01,
    2.01,
    2.01,
    2.01,
    2.01,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    2.00,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99,
    1.99
  ];
  if (n >= 474)
    return 1.96;
  else if (n >= 160)
    return 1.97;
  else if (n >= table.length)
    return 1.98;
  else
    return table[n];
}

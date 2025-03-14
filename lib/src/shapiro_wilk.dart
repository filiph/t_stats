import 'dart:math' as math;

import 'distributions.dart';

/// An implementation of the Shapiro-Wilk test of normality.
///
/// https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test
class ShapiroWilk {
  /// The W statistic.
  final double w;

  /// The p-value.
  final double pValue;

  const ShapiroWilk(this.w, this.pValue);

  factory ShapiroWilk.from(Iterable<num> x) {
    // Adapted from
    // https://github.com/pieterprovoost/jerzy/blob/master/lib/normality.js.
    // TODO: optimize

    var xx = _Vector(
      x.map((n) => n.toDouble()).toList(growable: false)..sort(),
    );
    // var mean = Statistic.from(xx.elements).mean;
    var n = xx.elements.length;
    var u = 1 / math.sqrt(n);

    // m

    var sn = StandardNormal();
    var m = _Vector([]);
    for (var i = 1; i <= n; i++) {
      m.push(sn.inverse((i - 3 / 8) / (n + 1 / 4)));
    }

    // c

    var md = m.dot(m);
    var c = m.multiply(1 / math.sqrt(md));

    // a

    var an =
        -2.706056 * math.pow(u, 5) +
        4.434685 * math.pow(u, 4) -
        2.071190 * math.pow(u, 3) -
        0.147981 * math.pow(u, 2) +
        0.221157 * u +
        c.elements[n - 1];
    var ann =
        -3.582633 * math.pow(u, 5) +
        5.682633 * math.pow(u, 4) -
        1.752461 * math.pow(u, 3) -
        0.293762 * math.pow(u, 2) +
        0.042981 * u +
        c.elements[n - 2];

    double phi;

    if (n > 5) {
      phi =
          (md -
              2 * math.pow(m.elements[n - 1], 2) -
              2 * math.pow(m.elements[n - 2], 2)) /
          (1 - 2 * math.pow(an, 2) - 2 * math.pow(ann, 2));
    } else {
      phi =
          (md - 2 * math.pow(m.elements[n - 1], 2)) / (1 - 2 * math.pow(an, 2));
    }

    var a = _Vector([]);
    if (n > 5) {
      a.push(-an);
      a.push(-ann);
      for (var i = 2; i < n - 2; i++) {
        a.push(m.elements[i] * math.pow(phi, -1 / 2));
      }
      a.push(ann);
      a.push(an);
    } else {
      a.push(-an);
      for (var i = 1; i < n - 1; i++) {
        a.push(m.elements[i] * math.pow(phi, -1 / 2));
      }
      a.push(an);
    }

    // w

    final w = math.pow(a.multiplyVector(xx).sum(), 2) / xx.ss();

    // p

    double g, mu, sigma;

    if (n < 12) {
      var gamma = 0.459 * n - 2.273;
      g = -math.log(gamma - math.log(1 - w));
      mu =
          -0.0006714 * math.pow(n, 3) +
          0.025054 * math.pow(n, 2) -
          0.39978 * n +
          0.5440;
      sigma = math.exp(
        -0.0020322 * math.pow(n, 3) +
            0.062767 * math.pow(n, 2) -
            0.77857 * n +
            1.3822,
      );
    } else {
      var u = math.log(n);
      g = math.log(1 - w);
      mu =
          0.0038915 * math.pow(u, 3) -
          0.083751 * math.pow(u, 2) -
          0.31082 * u -
          1.5851;
      sigma = math.exp(0.0030302 * math.pow(u, 2) - 0.082676 * u - 0.4803);
    }

    var z = (g - mu) / sigma;
    var norm = StandardNormal();
    final p = 1 - norm.distr(z);

    return ShapiroWilk(w, p);
  }

  String describe() {
    String normalityStatus =
        pValue > 0.05 ? "Fail to reject normality" : "Reject normality";

    String wInterpretation = "";
    if (w > 0.98) {
      wInterpretation = "very close to normal";
    } else if (w > 0.95) {
      wInterpretation = "reasonably normal";
    } else if (w > 0.90) {
      wInterpretation = "approximately normal";
    } else if (w > 0.80) {
      wInterpretation = "moderately non-normal";
    } else {
      wInterpretation = "substantially non-normal";
    }

    return "$normalityStatus (p = ${pValue.toStringAsFixed(4)}, "
        "W = ${w.toStringAsFixed(4)}). "
        "Data appears $wInterpretation.";
  }

  bool isNormal({double significance = 0.05}) {
    return pValue > significance;
  }
}

class _Vector {
  final List<double> elements;

  _Vector(this.elements);

  double dot(_Vector other) {
    var result = 0.0;
    for (var i = 0; i < elements.length; i++) {
      result = result + elements[i] * other.elements[i];
    }
    return result;
  }

  double mean() {
    var sum = 0.0;
    for (var i = 0, n = elements.length; i < n; ++i) {
      sum += elements[i];
    }
    return sum / elements.length;
  }

  _Vector multiply(double factor) {
    final result = _Vector(elements.toList(growable: false));
    for (var i = 0, n = result.elements.length; i < n; ++i) {
      result.elements[i] = result.elements[i] * factor;
    }
    return result;
  }

  _Vector multiplyVector(_Vector factor) {
    final result = _Vector(elements.toList(growable: false));
    for (var i = 0, n = result.elements.length; i < n; ++i) {
      result.elements[i] = result.elements[i] * factor.elements[i];
    }
    return result;
  }

  void push(double value) => elements.add(value);

  /// Total sum of squares.
  double ss() {
    var m = mean();
    var sum = 0.0;
    for (var i = 0, n = elements.length; i < n; ++i) {
      sum += math.pow(elements[i] - m, 2);
    }
    return sum;
  }

  double sum() {
    double sum = 0;
    for (var i = 0, n = elements.length; i < n; ++i) {
      sum += elements[i];
    }
    return sum;
  }
}

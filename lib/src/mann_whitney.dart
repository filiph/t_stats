/// Implements Mann-Whitney U test, also known as Wilcoxon rank-sum test.
///
/// https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
class MannWhitney {
  /// The U value for the first sample given.
  final double u1;

  /// The U value for the second sample given.
  final double u2;

  /// The number of measurements in the first sample.
  final int n1;

  /// The number of measurements in the second sample.
  final int n2;

  /// Compute the Mann-Whitney U test from the given two samples.
  factory MannWhitney.from(Iterable<double> sample1, Iterable<double> sample2) {
    if (sample1.isEmpty) {
      throw ArgumentError.value(sample1, 'sample1');
    }

    if (sample2.isEmpty) {
      throw ArgumentError.value(sample2, 'sample2');
    }

    // Adapted from
    // https://commons.apache.org/proper/commons-math/javadocs/api-3.6.1/src-html/org/apache/commons/math3/stat/inference/MannWhitneyUTest.html

    final z = sample1.followedBy(sample2).toList(growable: false);
    final ranks = _NaturalRanking.rank(z);

    double sumRankX = 0;

    // The ranks for x is in the first x.length entries in ranks because x
    // is in the first x.length entries in z
    for (int i = 0; i < sample1.length; ++i) {
      sumRankX += ranks[i];
    }

    // U1 = R1 - (n1 * (n1 + 1)) / 2 where R1 is sum of ranks for sample 1,
    // e.g. x, n1 is the number of observations in sample 1.
    final double u1 = sumRankX - (sample1.length * (sample1.length + 1)) / 2;

    // It can be shown that U1 + U2 = n1 * n2
    final double u2 = sample1.length * sample2.length - u1;

    return MannWhitney._(u1, u2, sample1.length, sample2.length);
  }

  MannWhitney._(this.u1, this.u2, this.n1, this.n2);

  /// The common language effect size.
  ///
  /// From Wikipedia:
  ///
  /// > Computed by forming all possible pairs between the two groups,
  /// > then finding the proportion of pairs that support a direction
  /// > (say, that items from group 1 are larger than items from group 2).
  /// > To illustrate, in a study with a sample of ten hares and ten tortoises,
  /// > the total number of ordered pairs is ten times ten or 100 pairs of hares
  /// > and tortoises. Suppose the results show that the hare ran faster
  /// > than the tortoise in 90 of the 100 sample pairs; in that case,
  /// > the sample common language effect size is 90%.
  ///
  /// https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
  ///
  /// In practice, this will be 0.5 if the two distributions are equivalent,
  /// 0.0 if the second distribution dominates, and 1.0 if the first
  /// distribution dominates.
  double get effectSize => u1 / (n1 * n2);
}

class _IntDoublePair {
  final double value;
  final int position;

  const _IntDoublePair(this.value, this.position);
}

class _NaturalRanking {
  /// Adapted from:
  /// https://commons.apache.org/proper/commons-math/javadocs/api-3.6.1/src-html/org/apache/commons/math3/stat/ranking/NaturalRanking.html
  static List<double> rank(List<double> data) {
    // Array recording initial positions of data to be ranked
    final List<_IntDoublePair> ranks = List.generate(
      data.length,
      (i) => _IntDoublePair(data[i], i),
    );

    assert(data.every((n) => n.isFinite));

    ranks.sort((a, b) => a.value.compareTo(b.value));

    final out = List<double>.filled(data.length, 0);
    var pos = 1;
    out[ranks[0].position] = pos.toDouble();
    final tiesTrace = <int>[];
    tiesTrace.add(ranks[0].position);
    for (var i = 1; i < ranks.length; ++i) {
      if (ranks[i].value.compareTo(ranks[i - 1].value) > 0) {
        // tie sequence has ended (or had length 1)
        pos = i + 1;
        if (tiesTrace.length > 1) {
          // if seq is nontrivial, resolve
          _resolveTie(out, tiesTrace);
        }
        tiesTrace.clear();
        tiesTrace.add(ranks[i].position);
      } else {
        // tie sequence continues
        tiesTrace.add(ranks[i].position);
      }
      out[ranks[i].position] = pos.toDouble();
    }
    if (tiesTrace.length > 1) {
      // handle tie sequence at end
      _resolveTie(out, tiesTrace);
    }
    return out;
  }

  static void _resolveTie(List<double> ranks, List<int> tiesTrace) {
    // constant value of ranks over tiesTrace
    final c = ranks[tiesTrace[0]];

    // length of sequence of tied ranks
    final length = tiesTrace.length;

    final average = (2 * c + length - 1) / 2;
    for (final index in tiesTrace) {
      ranks[index] = average;
    }
  }
}

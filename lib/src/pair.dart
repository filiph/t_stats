/// A simple pair of integers.
class Pair {
  /// The numbers.
  final int a, b;

  final bool _invalid;

  /// Constructs a pair of integers, [a] and [b].
  const Pair(this.a, this.b) : _invalid = false;

  /// Constructs a pair that should be considered invalid.
  const Pair.invalid() : a = -1, b = -1, _invalid = true;

  @override
  int get hashCode => Object.hash(a, b);

  /// Signifies invalid interval.
  bool get isInvalid => _invalid;

  @override
  bool operator ==(Object other) => other is Pair && other.hashCode == hashCode;

  @override
  String toString() => "($a,$b)";
}

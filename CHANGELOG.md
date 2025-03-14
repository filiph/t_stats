## 4.0.0

- Add Shapiro-Wilk test of normality
- Add geometric mean and multiplicative interval bounds 
  (for log-normal distributions)

## 3.1.0

- Upgrade to Dart 3.7.0
- Remove dependency on `pkg:quiver`

## 3.0.0

- Migrate to null safety

## 2.1.1+1

- Apply `dartfmt`

## 2.1.1

- Minor lint fixes (use `package:pedantic`)

## 2.1.0

- Update Dart SDK constraints to `>=2.0.0` (end of support for Dart 1)
- Fix formatting (e.g. remove optional `new` and `const`)

## 2.0.0

- Upgrade to Dart 2
- Use BigInt (found in `dart:core`) instead of `package:bignum`. This
  affects return values as well (factorial) so we're bumping major semver
  of this package to 2.0.

## 1.1.2

- Upgrade to latest
- Make the dependency to `bignum` a runtime dependency (instead of
  a dev dependency) 

## 0.0.1

- Initial version, created by Stagehand

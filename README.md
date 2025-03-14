# t_stats

This package provides class `Statistic` which computes things like standard
deviation and margin of error. It should be useful whenever you have a list 
of numerical values, and you want to:

* show simple stats like _mean_, _min_ and _max_, or
* find out the confidence interval (at the standard 95% confidence level), or
* confirm relationship to other measurements.

Since version 4.0.0, the package also includes:

* [Shapiro-Wilk test](https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test)
  of normality
* [Mann–Whitney U test](https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test),
  a non-parametric statistical test for comparing two distributions

## Library usage

A simple usage example:

    var myStat = Statistic.from(myMeasurements, name: "My scores");
    // Prints the most basic stats.
    print(myStat);
    
    var otherStat = Statistic.from(otherMeasurements);
    // Prints true only if stats are different with statistical significance.
    print(myStat.isDifferentFrom(otherStat));

## Executable usage

You can install the simple binary by running the following in the command line:

    pub global activate t_stats

Now you can use t_stats as a command line tool. Assuming there's a `numbers.txt`
file that contains a line-delimited list of numbers, you can run:

    $ t_stats --pretty < numbers.txt
        2.11  ±   2.48 MoE /   3.22 SD

This takes full advantage of POSIX pipes, so you can have things like:

    $ <some_complicated_unix_command> | t_stats --pretty
        9.88  ±  12.21 MoE /  23.75 SD

If you don't provide the `--pretty` argument, the tool will print out
the output of `Statistic.toTSV()` (less human-readable, but much more
useful for comparing multiple sets of measurements).

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/filiph/t_stats/issues

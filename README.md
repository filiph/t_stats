# t_stats

This package provides a single class which computes things like standard
deviation and margin of error. It should be useful whenever you have a list 
of numerical values and you want to:

* show simple stats like _mean_, _min_ and _max_, or
* find out the confidence interval (at the standard 95% confidence level), or
* confirm relationship to other measurements. 

## Usage

A simple usage example:

    var myStat = new Statistic.from(myMeasurements, name: "My scores");
    // Prints the most basic stats.
    print(myStat);
    
    var otherStat = new Statistic.from(otherMeasurements);
    // Prints true only if stats are different with statistical significance.
    print(myStat.isDifferentFrom(otherStat));

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/filiph/t_stats/issues

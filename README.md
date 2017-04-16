**Foreword - if you need help**: please [ask your question with tag kiba-etl on StackOverflow](http://stackoverflow.com/questions/ask?tags=kiba-etl) so that other can benefit from your contribution! I monitor this specific tag and will reply to you.

Writing reliable, concise, well-tested & maintainable data-processing code is tricky.

Kiba lets you define and run such high-quality ETL ([Extract-Transform-Load](http://en.wikipedia.org/wiki/Extract,_transform,_load)) jobs, using Ruby (see [supported versions](#supported-ruby-versions)).

Learn more on the [Kiba blog](http://thibautbarrere.com) and on [StackOverflow](http://stackoverflow.com/questions/tagged/kiba-etl):

* [Live Coding Session - Processing data with Kiba ETL](http://thibautbarrere.com/2015/11/09/video-processing-data-with-kiba-etl/)
* [Rubyists - are you doing ETL unknowningly?](http://thibautbarrere.com/2015/03/25/rubyists-are-you-doing-etl-unknowingly/)
* [How to write solid data processing code](http://thibautbarrere.com/2015/04/05/how-to-write-solid-data-processing-code/)
* [How to reformat CSV files with Kiba](http://thibautbarrere.com/2015/06/04/how-to-reformat-csv-files-with-kiba/) (in-depth, hands-on tutorial)
* [How to explode multivalued attributes with Kiba ETL?](http://thibautbarrere.com/2015/06/25/how-to-explode-multivalued-attributes-with-kiba/)
* [Common techniques to compute aggregates with Kiba](https://stackoverflow.com/questions/31145715/how-to-do-a-aggregation-transformation-in-a-kiba-etl-script-kiba-gem)
* [How to run Kiba in a Rails environment?](http://thibautbarrere.com/2015/09/26/how-to-run-kiba-in-a-rails-environment/)
* [How to pass parameters to the Kiba command line?](http://stackoverflow.com/questions/32959692/how-to-pass-parameters-into-your-etl-job)

**Consulting services**: if your organization needs to leverage data processing to solve a given business problem, I'm available to help you out via consulting sessions. [More information](http://thibautbarrere.com/hire-me/).

**Kiba Pro**: for more features & goodies, check out Kiba Pro ([Changelog & contact info](Pro-Changes.md)).

**Kiba Common**: I'm starting to add commonly used reusable helpers in a separate gem called [kiba-common](https://github.com/thbar/kiba-common), check it out (work-in-progress).

[![Gem Version](https://badge.fury.io/rb/kiba.svg)](http://badge.fury.io/rb/kiba)
[![Build Status](https://travis-ci.org/thbar/kiba.svg?branch=master)](https://travis-ci.org/thbar/kiba) [![Build status](https://ci.appveyor.com/api/projects/status/v05jcyhpp1mueq9i?svg=true)](https://ci.appveyor.com/project/thbar/kiba) [![Code Climate](https://codeclimate.com/github/thbar/kiba/badges/gpa.svg)](https://codeclimate.com/github/thbar/kiba) [![Dependency Status](https://gemnasium.com/thbar/kiba.svg)](https://gemnasium.com/thbar/kiba)

## How do you define ETL jobs with Kiba?

See wiki page: [How do you define ETL jobs with Kiba?](https://github.com/thbar/kiba/wiki/How-do-you-define-ETL-jobs-with-Kiba%3F)

## How do you run your ETL jobs?

See wiki page: [How do you run your ETL jobs?](https://github.com/thbar/kiba/wiki/How-do-you-run-your-ETL-jobs%3F)

## Implementing ETL sources

See wiki page: [Implementing ETL sources](https://github.com/thbar/kiba/wiki/Implementing-ETL-sources).

## Implementing ETL transforms

See wiki page: [Implementing ETL transforms](https://github.com/thbar/kiba/wiki/Implementing-ETL-transforms).

## Implementing ETL destinations

See wiki page: [Implementing ETL destinations](https://github.com/thbar/kiba/wiki/Implementing-ETL-destinations).

## Implementing pre and post-processors

See wiki page: [Implementing pre and post-processors](https://github.com/thbar/kiba/wiki/Implementing-pre-and-post-processors).

## Composability, reusability, testability of Kiba components

The way Kiba works makes it easy to create reusable, well-tested ETL components and jobs.

The main reason for this is that a Kiba ETL script can `require` shared Ruby code, which allows to:
- create well-tested, reusable sources & destinations
- create macro-transforms as methods, to be reused across sister scripts
- substitute a component by another (e.g.: try a variant of a destination)
- use a centralized place for configuration (credentials, IP addresses, etc.)

The fact that the DSL evaluation "runs" the script also allows for simple meta-programming techniques, like pre-reading a source file to extract field names, to be used in transform definitions.

The ability to support that DSL, but also check command line arguments, environment variables and tweak behaviour as needed, or call other/faster specialized tools make Ruby an asset to implement ETL jobs.

Make sure to subscribe to my [Ruby ETL blog](http://thibautbarrere.com) where I'll demonstrate such techniques over time!

## Supported Ruby versions

Kiba currently supports Ruby 2.0+ and JRuby (with its default 1.9 syntax). See [test matrix](https://travis-ci.org/thbar/kiba).

## History & Credits

Wow, you're still there? Nice to meet you. I'm [Thibaut](http://thibautbarrere.com), author of Kiba.

I first met the idea of row-based syntax when I started using [Anthony Eden](https://github.com/aeden)'s [Activewarehouse-ETL](https://github.com/activewarehouse/activewarehouse-etl), first published around 2006 (I think), in which Anthony applied the core principles defined by Ralph Kimball in [The Data Warehouse ETL Toolkit](http://www.amazon.com/gp/product/0764567578).

I've been writing and maintaining a number of production ETL systems using Activewarehouse-ETL, then later with an ancestor of Kiba which was named TinyTL.

I took over the maintenance of Activewarehouse-ETL circa 2009/2010, but over time, I could not properly update & document it, given the gradual failure of a large number of dependencies and components. Ultimately in 2014 I had to stop maintaining it, after an already long hiatus.

That said using Activewarehouse-ETL for so long made me realize the row-based processing syntax was great and provided some great assets for maintainability on long time-spans.

Kiba is a completely fresh & minimalistic-on-purpose implementation of that row-based processing pattern.

It is minimalistic to make it more likely that I will be able to maintain it over time.

It makes strong simplicity assumptions (like letting you define the sources, transforms & destinations). MiniTest is an inspiration.

As I developed Kiba, I realize how much this simplicity opens the road for interesting developments such as multi-threaded & multi-processes processing.

Last word: Kiba is 100% sponsored by my company LoGeek SARL (also provider of [WiseCash, a lightweight cash-flow forecasting app](https://www.wisecashhq.com)).

## License

Copyright (c) LoGeek SARL.

Kiba is an Open Source project licensed under the terms of
the LGPLv3 license.  Please see <http://www.gnu.org/licenses/lgpl-3.0.html>
for license text.

## Contributing & Legal

Until the API is more stable, I can only accept documentation Pull Requests.

(agreement below borrowed from [Sidekiq Legal](https://github.com/mperham/sidekiq/blob/master/Contributing.md))

By submitting a Pull Request, you disavow any rights or claims to any changes submitted to the Kiba project and assign the copyright of those changes to LoGeek SARL.

If you cannot or do not want to reassign those rights (your employment contract for your employer may not allow this), you should not submit a PR. Open an issue and someone else can do the work.

This is a legal way of saying "If you submit a PR to us, that code becomes ours". 99.9% of the time that's what you intend anyways; we hope it doesn't scare you away from contributing.

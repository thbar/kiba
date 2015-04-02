Writing reliable, concise, well-tested & maintainable data-processing code is tricky.

Kiba lets you define and run such high-quality ETL jobs, using Ruby.

**Note: this is EARLY WORK - the API/syntax may change at any time.**

[![Build Status](https://travis-ci.org/thbar/kiba.svg?branch=master)](https://travis-ci.org/thbar/kiba) [![Code Climate](https://codeclimate.com/github/thbar/kiba/badges/gpa.svg)](https://codeclimate.com/github/thbar/kiba) [![Dependency Status](https://gemnasium.com/thbar/kiba.svg)](https://gemnasium.com/thbar/kiba)

## How do you define ETL jobs with Kiba?

Kiba provides you with a DSL to define ETL jobs:

```ruby
# declare a ruby method here, for quick reusable logic
def parse_french_date(date)
  Date.strptime(date, '%d/%m/%Y')
end

# or better, include a ruby file which loads reusable assets
# eg: commonly used sources / destinations / transforms, under unit-test
require 'common.rb'

# declare a source where to take data from (you implement it - see notes below)
source MyCsvSource, 'input.csv'

# declare a row transform to process a given field
transform do |row|
  row[:birth_date] = parse_french_date(row[:birth_date])
  # return to keep in the pipeline
  row
end

# declare another row transform, dismissing rows conditionally by returning nil
transform do |row|
  row[:birth_date].year < 2000 ? row : nil
end

# before declaring a definition, maybe you'll want to retrieve credentials
config = YAML.load(IO.read('config.yml'))

# declare a destination - like source, you implement it (see below)
destination MyDatabaseDestination, config['my_database']
```

The combination of sources, transforms and destinations defines the data processing pipeline.

## How do you parse then run an ETL job definition?

Define your ETL jobs as standalone Ruby files, to be parsed then run with the Kiba API:

```
require 'kiba'
job_definition = Kiba.parse(IO.read('my-etl-job.rb'))
Kiba.run(job_definition)
```

`Kiba.parse` evaluates your ETL Ruby code to register sources, transforms and destinations in a job definition. It is important to understand that you can use Ruby logic at the DSL parsing time. This means that such code is possible, provided the csv files are available at parsing time:

```ruby
Dir['to_be_processed/*.csv'].each do |f|
  source MyCsvSource, file
end
```

Once the job definition is loaded, `Kiba.run` will use that information to do the actual row-by-row processing. It currently uses a simple row-by-row, single-threaded processing that will stop at the first error encountered.

## Implementing ETL sources

In Kiba, you are responsible for implementing the sources that do the extraction of data.

Sources are classes implementing:
- a constructor (to which Kiba will pass the provided arguments in the DSL)
- the `each` method (which should yield rows one by one)

Rows are usually `Hash` instances, but could be other structures as long as the rest of your pipeline is expecting it.

Since sources are classes, you can (and are encouraged to) unit test them and reuse them.

Here is a simple CSV source:

```ruby
require 'csv'

class MyCsvSource
  def initialize(input_file)
    @csv = CSV.open(input_file, headers: true, header_converters: :symbol)
  end

  def each
    @csv.each do |row|
      yield(row.to_hash)
    end
    @csv.close
  end
end
```

## Implementing row transforms

Row transforms are blocks (although classes will likely be supported later) which accept a row parameter:

```ruby
transform do |row|
  row[:this_field] = row[:that_field] * 10
  # make sure to return the row to keep it in the pipeline
  row
end
```

To dismiss a row from the pipeline, simply return nil from a transform:

```ruby
transform { |row| row[:index] % 2 == 0 ? row : nil }
```

## Implementing ETL destinations

Like sources, destinations are classes that you are providing. Destinations must implement:
- a constructor (to which Kiba will pass the provided arguments in the DSL)
- a `write(row)` method that will be called for each non-dismissed row
- a `close` method that will be called at the end of the processing

Here is an example destination:

```ruby
require 'csv'

# simple destination assuming all rows have the same fields
class MyCsvDestination
  def initialize(output_file)
    @csv = CSV.open(output_file, 'w')
  end

  def write(row)
    unless @headers_written
      @headers_written = true
      @csv << row.keys
    end
    @csv << row.values
  end

  def close
    @csv.close
  end
end
```

## Composability, reusability, testability of Kiba components

The way Kiba works makes it easy to create reusable, well-tested ETL components and jobs.

The main reason for this is that a Kiba ETL script can `require` shared Ruby code, which allows to:
- create well-tested, reusable sources & destinations
- create macro-transforms as methods, to be reused across sister scripts
- substitute a component by another (eg: try a variant of a destination)
- use a centralized place for configuration (credentials, IP addresses etc)

The fact that the DSL evaluation "runs" the script also allows for simple meta-programming techniques, like pre-reading a source file to extract field names, to be used in transform definitions.

The ability to support that DSL, but also check command line arguments, environment variables and tweak behaviour as needed, or call other/faster specialized tools make Ruby an asset to implement ETL jobs.

Make sure to subscribe to my [Ruby ETL blog](http://thibautbarrere.com) where I'll demonstrate such techniques over time!

## History & Credits

Wow, you're still there? Nice to meet you. I'm [Thibaut](http://thibautbarrere.com), author of Kiba.

I first met the idea of row-based syntax when I started using [Anthony Eden](https://github.com/aeden)'s [Activewarehouse-ETL](https://github.com/activewarehouse/activewarehouse-etl), first published around 2006 (I think), in which Anthony applied the core principles defined by Ralph Kimball in [The Data Warehouse ETL Toolkit](http://www.amazon.com/gp/product/0764567578).

I've been writing and maintaining a number of production ETL systems using Activewarehouse-ETL, then later with an ancestor of Kiba which was named TinyTL.

I took over the maintenance of Activewarehouse-ETL circa 2009/2010, but over time, I could not properly update & document it, given the gradual failure of a large number of dependencies and components. Ultimately in 2014 I had to stop maintaining it, after an already long yiatus.

That said using Activewarehouse-ETL for so long made me realize the row-based processing syntax was great and provided some great assets for maintainability on long timespans.

Kiba is a completely fresh & minimalistic-on-purpose implementation of that row-based processing pattern.

It is minimalistic to make it more likely that I will be able to maintain it over time.

It makes strong simplicity assumptions (like letting you define the sources, transforms & destinations). MiniTest is an inspiration.

As I developed Kiba, I realize how much this simplicity opens the road for interesting developments such as multi-threaded & multi-processes processing.

Last word: Kiba is 100% sponsored by my company LoGeek SARL (also provider of [WiseCash, a lightweight cash-flow forecasting app](https://www.wisecashhq.com)).

## License

Copyright (c) LoGeek SARL.

LoGeek is an Open Source project licensed under the terms of
the LGPLv3 license.  Please see <http://www.gnu.org/licenses/lgpl-3.0.html>
for license text.

## Contributing & Legal

Until the API is more stable, I can only accept documentation Pull Requests.

(agreement below borrowed from [Sidekiq Legal](https://github.com/mperham/sidekiq/blob/master/Contributing.md))

By submitting a Pull Request, you disavow any rights or claims to any changes submitted to the Kiba project and assign the copyright of those changes to LoGeek SARL.

If you cannot or do not want to reassign those rights (your employment contract for your employer may not allow this), you should not submit a PR. Open an issue and someone else can do the work.

This is a legal way of saying "If you submit a PR to us, that code becomes ours". 99.9% of the time that's what you intend anyways; we hope it doesn't scare you away from contributing.

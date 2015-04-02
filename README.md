Writing reliable, concise, well-tested & maintainable data-processing code is tricky.

Kiba lets you define and run such high-quality ETL jobs, using Ruby.

**Note: this is EARLY WORK - the API/syntax may change at any time.**

[![Build Status](https://travis-ci.org/thbar/kiba.svg?branch=master)](https://travis-ci.org/thbar/kiba) [![Code Climate](https://codeclimate.com/github/thbar/kiba/badges/gpa.svg)](https://codeclimate.com/github/thbar/kiba) [![Dependency Status](https://gemnasium.com/thbar/kiba.svg)](https://gemnasium.com/thbar/kiba)

# How do you define ETL jobs with Kiba?

Kiba provides you with a DSL to define ETL jobs:

```ruby
# declare a ruby method here, for quick reusable logic
def parse_french_date(date)
  Date.strptime('27/02/1979', '%d/%m/%Y')
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

# declare another row transform, dismissing rows conditionally
transform do |row|
  row[:birth_date].year < 2000 ? row : nil
end

# before declaring a definition, maybe you'll want to retrieve credentials
config = YAML.load(IO.read('config.yml'))

# declare a destination - like source, you implement it (see below)
destination MyDatabaseDestination, config['my_database']
```

The combination of sources, transforms and destinations defines the data processing pipeline.

# How do you parse then run an ETL job definition?

You define ETL job in standalone Ruby files, which you parse and run using the Kiba API:

```
require 'kiba'
job_definition = Kiba.parse(IO.read('my-etl-job.rb'))
Kiba.run(job_definition)
```

`Kiba.parse` evaluates your ETL Ruby code to register sources, transforms and destinations in a job definition.

It is important to understand that you can use Ruby logic at the DSL parsing time. This means such code is possible:

```ruby
Dir['to_be_processed/*.csv'].each do |f|
  source MyCsvSource, file
end
```

Once the job definition is loaded, `Kiba.run` will use that information to do the actual row-by-row processing.

# Implementing sources

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

# Implementing row tranforms

Row transforms are blocks (although classes will likely be supported later) which accept a row parameter:

```ruby
transform do |row|
  row[:this_field] = row[:that_field] * 10
  # always return the row at the end
  row
end
```

To dismiss a row from the pipeline, simply return nil from a transform:

```ruby
transform { |row| row[:index] % 2 == 0 ? row : nil }
```

# Implementing destinations

Like sources, destinations are classes that you are providing.

Destinations must implement:
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

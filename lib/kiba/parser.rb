# NOTE: using the "Kiba::Parser" declaration, as I discovered,
# provides increased isolation to the declared ETL script, compared
# to 2 nested modules.
# Before that, a user creating entities named Control, Context
# or DSLExtensions would see a conflict with Kiba own classes,
# as by default instance_eval will resolve references by adding
# the module containing the parser class (initially "Kiba").
# Now, the classes appear to be further hidden from the user,
# as Kiba::Parser is its own module.
# This allows the user to create a Parser, Context, Control class
# without it being interpreted as reopening Kiba::Parser, Kiba::Context,
# etc.
# See test in test_cli.rb (test_namespace_conflict)
module Kiba::Parser
  def parse(source_as_string = nil, source_file = nil, &source_as_block)
    control = Kiba::Control.new
    context = Kiba::Context.new(control)
    if source_as_string
      # this somewhat weird construct allows to remove a nil source_file
      context.instance_eval(*[source_as_string, source_file].compact)
    else
      context.block_self = eval('self', source_as_block.binding, __FILE__, __LINE__)
      context.instance_eval(&source_as_block)
    end
    control
  end
end

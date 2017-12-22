module SharedTests
  def shared_tests_for(desc, &block)
    @@shared_tests ||= {}
    @@shared_tests[desc] = block
  end

  def shared_tests(desc, *args)
    self.class_exec(*args, &@@shared_tests.fetch(desc))
  end
end

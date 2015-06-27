class SourceThatReadsAtInstantionTime
  def initialize(file)
    IO.read(file)
  end

  def each
  end
end

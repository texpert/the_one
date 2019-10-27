# frozen_string_literal: true

class BaseCoherser
  def self.run(data_input)
    new(data_input).run
  end

  def initialize(data_input)
    @data = data_input
  end

  def run
    raise RuntimeError, 'This is an abstract base class method, which should be implemented in each inheriting class'
  end
end

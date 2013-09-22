module Sequence
  
  class SequenceError < StandardError
  end
  
  class DuplicateSequenceError < SequenceError
    def initialize(phrase)
      super("A sequence with phrase '#{phrase}' already exists.")
    end
  end

  class UnknownSequenceError < SequenceError
    def initialize(phrase)
      super("Unknown sequence step with phrase: '#{phrase}'.")
    end
  end

  class EmptyParameterError < SequenceError
    def initialize(text)
      super("An empty or blank parameter occurred in '#{text}'.")
    end
  end

  class InvalidElementError < SequenceError
    def initialize(tag, invalid_element)
      msg = "The invalid element '#{invalid_element}' occurs in the parameter '#{tag}'."
      super(msg)
    end
  end

  class UselessPhraseParameter < SequenceError
    def initialize(param)
      super("The phrase parameter '#{param}' does not appear in any step.")
    end
  end

  class DataTableNotFound < SequenceError
    def initialize(phrase)
      msg = "The step with phrase [#{phrase}]: requires a data table."
      super(msg)
    end
  end

  class UnknownParameterError < SequenceError
    def initialize(name)
      super("Unknown sequence step parameter '#{name}'.")
    end
  end

  class AmbiguousParameterValue < SequenceError
    def initialize(name, phrase, table)
      msg = "The sequence parameter '#{name}' has value '#{phrase}' and '#{table}'."
      super(msg)
    end
  end

  class UnreachableStepParameter < SequenceError
    def initialize(param)
      msg = "The step parameter '#{param}' does not appear in the phrase."
      super(msg)
    end
  end
  
end
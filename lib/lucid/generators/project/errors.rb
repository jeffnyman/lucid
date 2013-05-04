class InvalidDataConditionError < StandardError
end

class NecessaryDataNotAvailableError < StandardError
end

class NecessaryDataAlreadyAvailableError < StandardError
end

class NotSpecificEnoughDataError < StandardError
end

class PossibleDataContextError < StandardError
end

class ContextCannotBeFulfilledError < StandardError
end

class DataValidationError < StandardError
end

class UnexpectedDataFoundError < StandardError
end

class TestDataNotFoundError < StandardError
end

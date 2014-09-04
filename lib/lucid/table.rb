module Lucid
  class Table
    def initialize(repr)
      @repr = repr
    end

    def headers
      @repr.first
    end

    def rows
      @repr.drop(1)
    end

    def hashes
      rows.map { |row| Hash[headers.zip(row)] }
    end
  end
end

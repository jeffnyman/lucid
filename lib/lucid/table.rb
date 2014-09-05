module Lucid
  class Table
    include Enumerable

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

    def each
      @repr.each { |row| yield(row) }
    end
  end
end

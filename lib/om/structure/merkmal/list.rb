require 'csv'
module Structure::Merkmal
  class List

    def initialize(file)
      @file = file
    end

    def csv
      @csv ||= CSV.parse(@file.read, headers: true, converters: converters)
    end

    def rows
      @rows ||= csv.each_with_index.collect { |row, idx| Row.new(row, index(idx)) }.compact
    end

    def find(role, list = rows)
      list.find { |row| row.match?(role) }
    end

    def build(role)
      matching_row = find(role, valid)
      matching_row ? Builder.new(matching_row, role).build : role
    end

    def valid
      @valid ||= rows.select(&:valid?)
    end

    def invalid
      @invalid ||= rows.select(&:invalid?).sort_by(&:index)
    end

    def print_invalid_rows
      @@printed ||= false
      return if invalid.empty? || @@printed

      puts "Got #{invalid.count} invalid rows"
      invalid.each do |row|
        puts "#{row.index}: (#{row.group} -> #{row.target_group}) (#{row.count}, #{row.merkmal}, #{row.target_role})"
        @@printed = true
      end
      nil
    end

    private

    def index(idx, offset = 2)
      idx + offset
    end

    def converters
      [->(v) { v&.strip }]
    end
  end
end

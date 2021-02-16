module Structure
  class Groups::Flat

    def initialize(group_ids: nil, depth: nil, skip: nil)
      @depth = depth
      @group_ids = group_ids
      @skip = skip
    end

    def build
      list.collect do |rows|
        rows.each_with_index.collect do |row, i|
          next if @skip && i < @skip

          block_given? ? yield(row) : row.label
        end.compact.join(' > ')
      end.reject(&:blank?).sort
    end

    def build_with_types
      build do |row|
        label = "#{row.label} #{row.type}"
        block_given? ? yield(row, label) : label
      end
    end

    def run(format_role = nil)
      puts build_with_types
    end

    def rows
      @rows ||= Groups.new(group_ids: @group_ids, depth: @depth).build
    end

    def list
      parent_ids = rows.collect { |row| row.parent&.id }.uniq
      rows.each_with_object([]) do |row, list|
        next if parent_ids.include?(row.id) # no parents

        ancestors = []
        loop do
          ancestors << row
          row = row.parent
          break unless row
        end

        list << ancestors.reverse
      end
    end

  end
end


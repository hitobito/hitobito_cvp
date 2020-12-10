module Structure::Steps
  class GroupCreate < Base

    def run
      @rows.collect do |row|
        mapping = find(row)
        next row unless mapping && missing?(row.children, mapping)

        [row, build(row, mapping)]
      end.flatten
    end

    def build(parent, mapping)
      Structure::GroupRow.new(next_id, mapping[:child], parent.id, parent).tap do |row|
        row.type = "#{parent.type}#{mapping[:child]}"
      end
    end

    def missing?(children, mapping)
      children.none? { |child| child.type.ends_with?(mapping[:child]) }
    end

    def find(row)
      @config.dig(:groups, :create).find { |c| c[:parent] == row.type }
    end

    def next_id
      @next_id ||= Verband.maximum(:lft) || 20_000
      @next_id += 1
    end

  end
end

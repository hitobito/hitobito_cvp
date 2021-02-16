module Structure::Steps
  class Delete < Base

    def run
      @rows.collect do |row|
        if deleted_map.key?(row.id) || ignored.any? { |r| r.match?(row.label) }
          next
        end
        if deleted_map.key?(row.parent_id)
          row.parent_id = deleted_map[row.parent_id]
        end
        row
      end.compact
    end

    def deleted_map
      @deleted_map ||= deleted.to_h
    end

    def deleted
      @config.dig(:groups, :deleted)
    end

    def ignored
      @config.dig(:groups, :ignored)
    end
  end
end

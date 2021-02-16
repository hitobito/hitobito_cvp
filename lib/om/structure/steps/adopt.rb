module Structure::Steps
  class Adopt < Base

    def run
      @rows.collect do |row|
        seen[row.id] = row
        row.parent = seen[row.parent_id]
        row
      end
    end

    def seen
      @seen ||= {}
    end
  end
end

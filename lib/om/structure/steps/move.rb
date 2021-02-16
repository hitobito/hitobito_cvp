module Structure::Steps
  class Move < Base

    def run
      moved = move_by(:parent_id, @rows)
      move_by(:id, moved)
    end

    def move_by(key, rows)
      map = @config.dig(:groups, :moves, "by_#{key}".to_sym).to_h
      rows.collect do |row|
        value = row.send(key)
        next row unless map.key?(value)

        row.parent_id = map[value]
        row
      end
    end
  end
end

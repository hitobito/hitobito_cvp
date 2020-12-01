
module Structure::Steps
  class MoveUp < Base


    def run
      @rows.each do |row|
        if row.parent&.label == 'Partei'
          row.parent_id = row.parent.parent_id
          row.parent = row.parent.parent
        end
      end
    end

  end
end


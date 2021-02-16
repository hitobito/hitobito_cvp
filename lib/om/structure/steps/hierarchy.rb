module Structure::Steps
  class Hierarchy < Base

    def run
      set_children
      build_depth_first(root, [])
    end

    def set_children
      @rows.each do |row|
        row.children = children(row).sort
      end
    end

    def build_depth_first(row, list)
      list << row
      row.children.each do |child|
        build_depth_first(child, list)
      end
      list
    end

    def root
      @rows.find(&:root?)
    end

    def children(parent_row)
      @rows.select { |row| row.parent_id == parent_row.id }
    end

  end
end

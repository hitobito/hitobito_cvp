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

    def children(row)
      by_children.fetch(row.id, [])
    end

    def by_children
      @by_children ||= @rows.each_with_object(Hash.new { |h, k| h[k] = [] }) do |row, memo|
        memo[row.parent_id] << row
      end
    end

  end
end

module Structure::Steps::Group
  class Create < Structure::Steps::Base

    def run
      @rows.collect do |row|
        children = find(row)
        groups = children.collect do |child|
          next unless child && missing?(row.children, child)
          build(row, child)
        end

        [row, groups.compact]
      end.flatten
    end

    def build(parent, child)
      group = Structure::GroupRow.new(next_id, child, parent.id, parent)
      group.type = "#{parent.type}#{child}"
      parent.children += [group]
      group
    end

    def missing?(children, child)
      children.none? { |c| c.type.ends_with?(child) }
    end

    def find(row)
      @config.dig(:groups, :create).fetch(row.type.to_sym, [])
    end

    def next_id
      @next_id ||= Verband.maximum(:verbandstruktur_id)
      @next_id += 1
    end

  end
end

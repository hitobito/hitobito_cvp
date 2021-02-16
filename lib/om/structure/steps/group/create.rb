module Structure::Steps::Group
  class Create < Structure::Steps::Base

    def run
      @rows.collect do |row|
        children = find(row)
        groups = children.collect do |definition|
          type, label = definition.split(':')
          label ||= type
          next unless missing?(row.children, type, label)

          build(row, type, label)
        end

        [row, groups.compact]
      end.flatten
    end

    def build(parent, type, label)
      group = Structure::GroupRow.new(next_id, label, parent.id, parent)
      group.type = "#{parent.type}#{type}"
      parent.children += [group]
      group
    end

    def missing?(children, type, label)
      children.none? { |c| c.type.ends_with?(type) && c.label == label }
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

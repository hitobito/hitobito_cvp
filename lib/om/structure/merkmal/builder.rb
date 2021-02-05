
module Structure::Merkmal
  class Builder
    attr_reader :row, :role

    def initialize(row, role)
      @row = row
      @role = role
    end

    def build
      if row.same_group?
        change_type
      elsif row.same_layer?
        change_group(:in_layer)
      elsif row.above_layer?
        change_group(:above)
      elsif row.below_layer?
        change_group(:below, 'Mitglied')
      end
    end

    def change_type
      role.type = target_role
    end

    def change_group(where, role_type = target_role)
      new_group = send("find_group_#{where}")
      if new_group
        group.roles -= [role]
        role.type = role_type
        role.group = new_group
        role.group.roles << role
        role
      end
    end

    def find_group_below(group = role.group)
      layer = find_layer(group)
      layer.children.find { |child| child.type.ends_with?('Arbeitsgruppe') && child.label == role.label }
    end

    def find_group_above(group = role.group)
      layer = find_layer(group)
      return unless layer

      candidate_groups = layer.children.select { |child| child.type == target_group }
      if candidate_groups.present?
        find_group(candidate_groups, layer)
      else
        find_group_above(layer.parent)
      end
    end

    def find_group_in_layer
      layer = find_layer(group)
      candidate_groups = find_layer.children.select { |child| child.type == target_group }
      find_group(candidate_groups, layer)
    end

    def find_group(groups, layer)
      return groups.first if groups.one?
      find_group_for_role_group_by_label(groups) || find_default_group_for_type(groups, layer)
    end

    def find_group_for_role_group_by_label(groups)
      groups.find do |group|
        target_role.match(group.label) || group.label.match(row.merkmal)
      end
    end

    def find_default_group_for_type(groups, layer)
      label = target_group.gsub(layer.type, '')
      groups.find { |group| group.label == label }
    end

    def find_layer(group = role.group)
      return unless group
      group.layer? ? group : find_layer(group.parent)
    end

    def target_group
      row.target_group.gsub('Group::', '')
    end

    def target_role
      row.target_role.split('::').last
    end

    def group
      role.group
    end
  end
end

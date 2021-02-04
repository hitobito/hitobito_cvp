require 'csv'
module Structure::Merkmal
  class Row
    attr_reader :group, :merkmal, :target_group, :count, :index
    def initialize(row, index = nil)
      @index = index
      @merkmal = row['Merkmal']
      @group = row['Gruppen']
      @count = row['Anzahl'].to_i
      @target_group = row['Neue Gruppe'] || @group
      @target_role = row['Rolle']
    end

    def valid?
      types_defined? && valid_role_for_group?
    end

    def invalid?
      !valid?
    end

    def layer(group)
      layers.find { |layer| group.starts_with?(layer.to_s) }
    end

    def same_group?
      group == target_group
    end

    def same_layer?
      layer(group) == layer(target_group)
    end

    def above_layer?
      layers.index(layer(target_group)) < layers.index(layer(group))
    end

    def below_layer?
      layers.index(layer(target_group)) > layers.index(layer(group))
    end

    def match?(role)
      group == "Group::#{role.group.type}" && merkmal == role.label
    end

    def types_defined?
      [target_group, target_role].all?(&:safe_constantize)
    end

    def valid_role_for_group?
      target_group.constantize.role_types.include?(target_role.constantize)
    end

    def layers
      Group.all_types.select(&:layer?)
    end

    def target_role
      case @target_role
      when 'Group::BundExterneKontakte::Kontakte'
        'Group::BundExterneKontakte::Kontakt'
      when 'Group::KantonDelegierte::DelegiertevonAmtesWegen'
        'Group::KantonDelegierte::DelegierteVonAmtesWegen'
      when 'Group::KantonDelegierte::DelegiertevonAmtesWegen'
        'Group::KantonDelegierte::DelegierteVonAmtesWegen'
      else @target_role
      end
    end

  end
end

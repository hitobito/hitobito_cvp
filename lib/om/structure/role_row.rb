module Structure
  class RoleRow
    attr_reader :label, :kunden_id, :group
    attr_accessor :type

    def initialize(group, kunden_id, label)
      @group = group
      @kunden_id = kunden_id
      @label = label
    end

    def constraint
      @group.label
    end

    def group_type
      @group.type
    end

    def type_or_default
      type || 'Merkmal'
    end

    def to_s(format = nil)
      if format == :full
        type_string = type.starts_with?('tbd') ? :tbd : type
        [type_string, @label].uniq.join(':')
      else
        type || @label
      end
    end
  end

end

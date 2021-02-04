module Structure
  class RoleRow
    attr_reader :label, :kunden_id, :group, :timestamps
    attr_accessor :type, :group

    def initialize(group, kunden_id, label, timestamps = {})
      @group = group
      @kunden_id = kunden_id
      @label = label
      @timestamps = timestamps
    end

    def constraint
      @group.label
    end

    def group_type
      @group.type
    end

    def tbd?
      type.starts_with?('tbd')
    end

    def to_s(format = nil)
      if format == :full
        type_string = tbd? ? :tbd : type
        [type_string, @label].uniq.join(':')
      else
        type || @label
      end
    end
  end

end

module Structure
  class RoleRow
    attr_reader :label, :kunden_id, :group, :timestamps, :mitgliedschafts_nummer
    attr_accessor :type, :group

    def initialize(group, kunden_id, label, timestamps = {}, mitgliedschafts_nummer = nil)
      @group = group
      @kunden_id = kunden_id
      @label = label
      @timestamps = timestamps
      @mitgliedschafts_nummer = mitgliedschafts_nummer
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

    def eql?(other)
      group == other.group && kunden_id == other.kunden_id && type == other.type &&
        timestamps == other.timestamps && label == other.label
    end

    def hash
      [group, kunden_id, type, label, timestamps].hash
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

module Structure
  class GroupRow
    include Comparable

    attr_reader :id, :label
    attr_writer :parent_id
    attr_accessor :type, :parent
    attr_accessor :roles, :children

    def initialize(id, label, parent_id, parent = nil)
      @id = id
      @label = label || 'Unbekannt'
      @parent_id = parent_id
      @parent = parent
      @roles = []
      @children = []
    end

    def blank?
      !present?
    end

    def present?
      @present ||= children? || roles.present? || mitgliedschaft?
    end

    def attrs
      {
        id: id,
        parent_id: @parent_id,
        type: sti_name,
        name: label,
        layer_group_id: layer_group_id,
        created_at: Time.zone.now
      }
    end

    def layer_group_id
      sti_name.constantize.layer? ? id : parent.layer_group_id
    end

    def sti_name
      "Group::#{type}"
    end

    def depth
      if parent
        parent.depth + 1
      else
        0
      end
    end

    def parent_type
      parent&.type || 'Bund'
    end

    def parent_ids
      return [] unless parent

      parent.parent_ids + [parent.id]
    end

    def root?
      parent_id.zero?
    end

    def parent_id
      @parent_id || 0
    end

    def mitgliedschaft?
      type&.ends_with?('Mitglieder')
    end

    def children?
      children.any?(&:present?) || children.any?(&:mitgliedschaft?)
    end

    def <=>(other)
      return unless other.is_a?(GroupRow)

      if [layer?, other.layer?].uniq.size == 1
        if type == other.type
          label <=> other.label
        else
          type <=> other.type
        end
      elsif layer?
        1
      elsif other.layer?
        -1
      end
    end

    def layer?
      %w(Bund Kanton Region Ort).include?(type)
    end

    def to_s(with_role = nil)
      if with_role
        role_labels = @roles.collect { |r| r.to_s(with_role) }
        "<#{@type} #{@label}#{roles_string(role_labels)}, id:#{@id}, #{parent_id}>".indent(depth)
      else
        "<#{@type} id=#{@id}, label=#{@label}, parent_id=#{@parent_id}>".indent(depth)
      end
    end

    def roles_string(labels)
      string = labels.uniq.sort.collect do |string|
        "#{string} #{labels.count(string)}"
      end.join(', ')
      " [#{string}]" if string.present?
    end

    def custom_inspect
      to_s(:detail)
    end

    alias :inspect :custom_inspect
  end
end

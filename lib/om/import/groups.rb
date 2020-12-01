module Import
  class Groups
    MinimalGroup = Struct.new(:id, :type, :parent_id, :name)
    MinimalMerkmal = Struct.new(:id, :name)

    def self.instance
      @instance ||= new
    end

    def groups
      @groups ||= ::Group.pluck(:id, :type, :parent_id, :name).collect do |args|
        MinimalGroup.new(*args)
      end
    end

    def by_id
      @by_id ||= groups.index_by(&:id)
    end

    def get(id)
      by_id.fetch(id)
    end

    def children(id)
      groups.select { |g| g.parent_id == id }
    end

    def siblings(id)
      children(get(id).parent_id) - [get(id)]
    end

    def leaf?(id)
      @parent_ids ||= groups.collect(&:parent_id)
      !@parent_ids.include?(id)
    end

    def role_types
      @role_types ||= ::Group.pluck('distinct type').collect do |group_type|
        role_types = group_type.constantize.role_types.collect { |type| type.sti_name.demodulize }
        [group_type, role_types]
      end.to_h
    end

    def verbindungen
      @verbindungen ||=
        begin
          scope = Verbindung.joins(:merkmal).group(:struktur_id, :merkmal_id, :merkmal_bezeichnung_d)
          scope = scope.where(struktur_id: by_id.keys).count
          scope.keys.inject({}) do |memo, (group_id, merkmal_id, label)|
            memo[group_id] ||= []
            memo[group_id] << merkmale.fetch(merkmal_id) do
              merkmale[merkmal_id] = MinimalMerkmal.new(merkmal_id, label)
            end
            memo
          end
        end
    end

    def merkmale
      @merkmale ||= {}
    end
  end
end

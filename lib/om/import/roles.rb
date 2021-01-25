module Import
  class Roles < Base
    def run
      roles.each_slice(1000).collect do |slice|
        rows = slice.collect do |role|
          attrs(role)
        end
        upsert(Role, rows)
      end
      validate_sti(Role)
    end

    def attrs(role)
      role.timestamps.merge(
        group_id: role.group.id,
        person_id: fetch_person_id(role.kunden_id),
        type: type_or_default(role),
        label: role.label
      )
    end

    def type_or_default(role)
      type = role.tbd? ? 'Merkmal' : role.type
      "#{role.group.sti_name}::#{type}"
    end

    def roles
      groups.flat_map(&:roles)
    end
  end
end

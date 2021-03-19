
module Import
  class FamilienRoleSync

    def initialize(families)
      @families = families.select(&:stale?)
      @stale_ids = families.collect(&:stale_id).compact
      @people_ids = families.flat_map(&:other_ids)
    end

    def stale
      @stale ||= build_role_memo(family_scope(@stale_ids))
    end

    def people
      @people ||= build_role_memo(role_scope(@people_ids))
    end

    def run
      attrs = build
      attrs.each_slice(1000) do |slice|
        Role.upsert_all(slice)
      end
    end

    private

    def build
      @families.flat_map do |family|
        stale.fetch(family.stale_id, []).collect do |role|
          build_missing(family, role)
        end.flatten
      end.compact
    end

    def build_missing(family, role)
      family.other_ids.collect do |other_id|
        existing = find(role, other_id)
        if existing
          existing.attributes.symbolize_keys.merge(label: role.label)
        else
          role.attributes.symbolize_keys.merge(id: nil, person_id: other_id, label: role.label)
        end
      end
    end

    def find(role, other_id)
      people.fetch(other_id, []).find { |r| r.type == role.type && r.group_id == role.group_id }
    end

    def build_role_memo(scope)
      scope.each_with_object({}) do |role, memo|
        memo[role.person_id] ||= []
        memo[role.person_id] << role
      end
    end

    def role_scope(ids)
      Role.where("type LIKE '%Mitglieder::Mitglied'").where(person_id: ids)
    end

    def family_scope(ids)
      role_scope(ids).where("lower(label) LIKE '%fam%'").where.not("lower(label) LIKE '%emp%'")
    end
  end
end

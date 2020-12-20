
module Import
  class PrimaryGroups < Base

    def run
      upsert(::Person, rows)
      without_roles = ::Person.where(primary_group_id: nil)
      if without_roles.present?
        puts " WARN #{without_roles.count} people without roles"
        without_roles.update_all(primary_group_id: 1)
      end
    end

    def rows
      with_counts.collect do |person_id, group_id_with_count|
        { id: person_id, primary_group_id: group_id_with_count.first }
      end
    end

    def with_counts
      counts.each_with_object({}) do |list, obj|
        person_id, group_id, count = list.flatten
        obj[person_id] ||= [group_id, count]
        if obj[person_id].second < count
          obj[person_id] = [group_id, count]
        end
      end
    end

    def counts
      Role.group(:person_id, :group_id).count
    end
  end

end


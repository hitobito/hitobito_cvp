
module Import
  class PrimaryGroups < Base

    def run
      upsert(::Person, rows)
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


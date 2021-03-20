module Target
  class FamilienList

    class Family
      delegate :address, to: '@members.first'

      def initialize(key, members)
        @key = key
        @members = members
      end

      def first_names
        @members.collect(&:first_name).select(&:present?).sort.join('-').truncate(60)
      end

      def last_names
        @members.collect(&:last_name).select(&:present?).sort.uniq.join(', ')
      end

      def to_s
        format("%-40s %-60s %-30s" % [last_names, first_names, address])
      end
    end

    def initialize(limit = nil)
      @limit = limit
    end

    def to_s
      puts families
      puts
      puts roles
      puts
      puts households_summary
      puts families.size
    end

    def roles
      scope = Role.joins(:person).where(people: { household_key: household_keys })
        .where("type LIKE '%::%Mitglieder::Mitglied'").group(:type, :label)
      scope.count.sort_by(&:first).reverse.collect do |(type, label), count|
        format("%-40s %-40s %-30d" % [type, label, count])
      end
    end

    def families
      people_grouped.collect do |key, members|
        Family.new(key, members)
      end.sort_by { |f| [f.last_names, f.first_names] }
    end

    def households_summary
      values = households_counted.values
      values.uniq.sort.collect { |val| [val, values.count(val)] }.sort_by(&:first).to_h
    end

    def people_grouped
      Person.where(household_key: household_keys).order(:address).group_by(&:household_key)
    end

    def household_keys
      households_counted.keys
    end

    def households_counted
      Person.where.not(household_key: nil).limit(@limit).group(:household_key).count
    end
  end
end

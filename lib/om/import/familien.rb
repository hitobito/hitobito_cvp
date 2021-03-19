module Import
  class Familien < Base

    ADDRESS_ATTRS = ::Person::ADDRESS_ATTRS - [:country]

    PERSON_ATTRS = [:kundennummer, :kunden_id, :kontaktnummer, :id, :first_name, :last_name, :gender] + ADDRESS_ATTRS


    Member = Struct.new(*PERSON_ATTRS - [:kundennummer]) do
      def address_attrs
        attrs = to_h.stringify_keys.slice(*ADDRESS_ATTRS.collect(&:to_s))
        attrs.transform_values { |val| val.blank? ? nil : val }
      end

      # scheint zuverlässiger als kontaktnummer == 0
      def stale?
        gender.nil? || first_name =~ /\set|und\s/
      end

      def canonical_last_name
        last_name.downcase.gsub(/-|&/, " ").gsub("von", "").split(" ").sort.join("-")
      end

      def to_s
        "#{kontaktnummer} - #{first_name} #{last_name}, stale: #{stale?}"
      end
    end

    # By kundennummer, 0 familie
    Family = Struct.new(:nr, :members) do
      def attrs
        return {} unless valid?

        members.collect do |member|
          { id: member.id, household_key: members.first.kunden_id }
        end
      end

      def update_household
        household_key = members.first.kunden_id
        ::Person.where(kundennummer: nr)
          .update_all(household_key: household_key)
      end

      def valid?
        same_addresses? && non_stale_members.size > 1 && name_valid?
      end

      def name_valid?
        same_name? || similar_name?(:last_name) || similar_name?(:canonical_last_name)
      end

      def same_addresses?
        first_address = members.first.address_attrs
        members.all? { |member| member.address_attrs == first_address }
      end

      def same_name?
        if non_stale_members.present?
          first_last_name = non_stale_members.first.last_name
          non_stale_members.all? { |member| member.last_name == first_last_name }
        end
      end

      # für Doppelnamen, zb. 'Maier' && 'Müller-Maier'
      def similar_name?(name = :last_name)
        last_names = non_stale_members.collect { |member| member.send(name) }
        shortest_last_name = last_names.min_by(&:length)
        last_names.all? { |name| name.include?(shortest_last_name) }
      end

      def non_stale_members
        members.reject(&:stale?)
      end

      def stale_id
        members.find(&:stale?)&.id
      end

      def other_ids
        members.reject(&:stale?).collect(&:id)
      end

      def stale?
        members.select(&:stale?).one?
      end

      def size
        members.size
      end

      def to_s
        string = "#{nr}(#{valid?}): #{same_addresses?},  #{name_valid?}, #{non_stale_members.size}\n"
        members.sort_by(&:kontaktnummer).each do |person|
          string << " " << person.to_s << "\n"
        end  << "\n"
        string
      end
    end

    def run
      update_households
      update_people_memo
      update_roles
      delete_stale
    end

    def update_roles
      Import::FamilienRoleSync.new(families).run
    end

    def roles(person_ids)
      Role.where(person_id: person_ids).where("type LIKE '%Mitglied'")
    end

    def update_households
      households.group_by(&:size).transform_values(&:size).each do |size, count|
        puts " Updating #{count} households of size #{size}"
      end
      ::Person.upsert_all(households.collect(&:attrs).compact.flatten)
    end

    def update_people_memo
      fetch_person_id  '1cf7f88d-b3d9-4215-95a3-1a4073b8e970' # initialze memo
      families.select(&:valid?).select(&:stale?).each do |family|
        stale_person = family.members.find(&:stale?)
        substitute_id = family.members.reject(&:stale?).first&.id
        @@people[stale_person.kunden_id] = substitute_id
      end
    end

    def delete_stale
      stale_ids = households.collect(&:stale_id).compact
      delete_all(::Person.where(id: stale_ids))
      delete_all(::Role.where(person_id: stale_ids))
      delete_all(::PhoneNumber.where(contactable_id: stale_ids, contactable_type: 'Person'))
      kept = ::Person.where(kundennummer: families.collect(&:nr)).group(:kundennummer).count.keys
      puts " Deleted #{families.size - kept} families" if kept.size != families.size
    end

    def households
      @households ||= families.select(&:valid?)
    end

    def delete_all(scope)
      count = scope.delete_all
      puts " Deleted #{count} #{scope.model}"
    end

    def families
      scope.pluck(*PERSON_ATTRS).each_with_object({}) do |row, memo|
        nr = row.shift
        family = memo.fetch(nr) { memo[nr] = Family.new(nr, []) }
        family.members << Member.new(*row)
      end.to_h.values
    end

    def scope
      people.where(kundennummer: counts.keys)
    end

    def mitgliedschaften
      ::Person.where.not(company: true).where(kundennummer: counts.keys)
    end

    def people
      ::Person.where.not(company: true)
    end

    def counts
      @counts ||= people.group(:kundennummer).having('count(kundennummer) > 1').count
    end
  end
end

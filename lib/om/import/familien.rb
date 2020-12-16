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
        gender.nil?
      end
    end

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
        same_addresses? && same_name?
      end

      def same_addresses?
        first_address = members.first.address_attrs
        members.all? { |member| member.address_attrs == first_address }
      end

      def same_name?
        first_last_name = members.first.last_name
        members.all? { |member| member.last_name == first_last_name }
      end

      def stale_id
        members.find(&:stale?)&.id
      end

      def size
        members.size
      end
    end

    def run
      update_households
      delete_stale
    end

    def update_households
      households = families.select(&:valid?)
      households.group_by(&:size).transform_values(&:size).each do |size, count|
        puts " Updating #{count} households of size #{size}"
      end
      ::Person.upsert_all(households.collect(&:attrs).compact.flatten)
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
      @households ||= families.select(&:same_addresses?)
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
      ::Person.where.not(company: true).where(kundennummer: counts.keys)
    end

    def counts
      @counts ||= ::Person.group(:kundennummer).having('count(kundennummer) > 1').count
    end
  end
end

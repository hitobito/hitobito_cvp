module Import
  class FamilienImportMissing

    def initialize(families)
      @families = families.select(&:candidate?).reject(&:complete?)
    end

    def run
      populate
      puts "Inserting #{missing.count} people, #{missing.select(&:stale?).count} marked as stale"
      attrs = missing.collect { |s| s.to_h.merge(additional_information: "wip-familien") }
      attrs.each_slice(1000) do |slice|
        ::Person.insert_all(slice)
      end
    end

    def missing
      @missing ||= @families.flat_map(&:members).select(&:missing?)
    end

    def populate
      @families.each do |family|
        family.missing_keys.each do |key|
          next unless people.key?(key)

          values = people.fetch(key).values
          family.members << Import::Familien::Member.new(*values)
        end
      end
    end

    def people
      @people ||= kontakts_scope.collect do |kontakt|
        key = [kontakt.kundennummer, kontakt.kontaktnummer].join('_')
        [key, kontakt.prepare.merge(id: nil).slice(*Import::Familien::PERSON_ATTRS)]
      end.to_h
    end

    def without_duplicate_email(attrs)
      @emails ||= ::Person.where.not(email: nil).pluck(:email)
      @emails.include?(attrs[:email]) ? attrs.merge(email: nil) : attrs
    end

    def kontakts_scope
      ::Kontakt.where(kundennummer: @families.collect(&:nr))
    end
  end
end

module Import
  class Telfonnummer < Base
    def run
      scope.find_in_batches.each do |batch|
        rows = batch.collect do |kontakt|
          row = kontakt.prepare
          email = row[:email]
          next row if uniq?(email)
          next row.merge(email: nil) if duplicate?(email)
          row.tap { duplicate_emails[email] = :seen }
        end
        upsert(::Person, rows)
      end
      ensure_all_imported
    end
    end

    def scope
      ::Kontakt.where(kunden_id: Person.pluck(:kunden_id)).minimal
    end
  end
end

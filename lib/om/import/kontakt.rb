module Import
  class PhoneNumbers < Base
    def track(kontakt)
      phone_numbers = kontakt.phone_numbers
      numbers[kontakt.kunden_id] = phone_numbers if phone_numbers.present?
    end

    def run # rubocop:disable Metrics/MethodLength
      numbers.each_slice(1000) do |batch|
        rows = batch.flat_map do |kunden_id, values|
          values.collect do |value|
            parsed = Phonelib.parse(value[:number])
            next unless parsed.valid?

            value[:number] = parsed.international if parsed.valid?
            value[:label] = 'Mobil' if value[:label] == 'Natel'
            value.merge(
              contactable_id: people[kunden_id],
              contactable_type: 'Person',
            )
          end
        end
        upsert(PhoneNumber, rows.compact)
      end
    end

    def label(number)
      'Mobil' if /\+41\s7[56789]/.match(number)
    end

    def numbers
      @numbers ||= {}
    end

    def people
      @people ||= ::Person.where(kunden_id: numbers.keys).pluck(:kunden_id, :id).to_h
    end
  end

  class Kontakt < Base
    def run
      scope.find_in_batches.each do |batch|
        rows = batch.collect do |kontakt|
          row = kontakt.prepare
          phone_numbers.track(kontakt)
          handle_email(row)
          row
        end
        upsert(::Person, rows)
      end
      ensure_all_imported
      phone_numbers.run
    end

    def handle_email(row)
      email = row[:email].to_s.delete('()')
      if email =~ /@/
        row[:email] = nil if duplicate?(email)
        duplicate_emails[email] = :seen
      else
        row[:email] = nil
      end
    end

    def phone_numbers
      @phone_numbers ||= PhoneNumbers.new
    end

    def ensure_all_imported
      fail " expected #{@total} Person, got #{::Person.count}" unless @total == (::Person.count - 1)
    end

    def duplicate?(email)
      duplicate_emails[email] == :seen
    end

    def duplicate_emails
      @duplicate_emails ||= ::Kontakt.with_email.group(:email).having('count(email) > 1').count
    end

    def scope
      ::Kontakt.where(kunden_id: kunden_ids.uniq).order(Arel.sql(order_clause)).tap do |scope|
        @total = scope.unscope(:select).count
      end
    end

    def order_clause
      <<~SQL
      CASE WHEN email IS NOT NULL AND name IS NOT NULL AND vorname IS NOT NULL then 1
      ELSE 0
      END
      SQL
    end
  end
end

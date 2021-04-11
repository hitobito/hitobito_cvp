require 'csv'
require 'fuzzystringmatch'

module MissingEmails
  class Exporter
    def run
      puts "Duplicate emails: #{duplicates.count}"
      puts "People: #{people.count}"
      puts "Households: #{households.count}"
      puts "Other: #{others.count}"


      CSV.open("#{ENV['HOME']}/tmp/missing_emails.csv", "wb") do |csv|
        csv << %w(person_id email)
        write(csv, households)
        # write(csv, others.pluck('distinct(kundennummer)'))
      end
      nil
    end

    def write(csv, scope)
      scope.each do |number|
        email = duplicates[number]
        puts "#{number} #{email}"
        next if Person.where(kundennummer: number, email: email).exists?
        # next unless Truemail.valid?(email)
        #
        person_id = closest_match(number, email) do |name, distance, person|
          puts " #{distance} #{name} #{person.email}"
        end
        puts
        csv << [person_id, email, number]
      end
      nil
    end

    def closest_match(number, email)
      name_part = email.split("@").first

      matches = Person.where(kundennummer: number).collect do |person|
        name = "#{person.first_name} #{person.last_name}"
        distance = jarow.getDistance(name, name_part)
        yield name, distance, person  if block_given?

        [person.id, name, distance]
      end

      matches.sort_by(&:last).reverse.first.first
    end

    def match_people(number, email)
      name_part = email.split("@").first
      Person.where(kundennummer: number).collect do |person|
        name = "#{person.first_name} #{person.last_name}"
        [person, jarow.getDistance(name, name_part).round(6)]
      end
    end

    def jarow
      @jarow ||= FuzzyStringMatch::JaroWinkler.create( :native )
    end

    def print(number)
      Person.where(kundennummer: number).find_each do |p|
        puts " #{p.kontaktnummer} #{p.first_name} #{p.last_name} #{p.email}"
      end
    end

    def households
      @household ||= people.household.pluck('kundennummer').uniq
    end

    def people
      numbers, _ = duplicates.to_a.transpose
      Person.where(kundennummer: numbers).where(email: ["",nil])
    end

    def others
      people.where(household_key: nil)
    end

    def duplicates
      @duplicates ||=
        Kontakt.group(:kundennummer, :email).having('count(email) > 1').pluck(:kundennummer, :email).to_h
    end
  end
end

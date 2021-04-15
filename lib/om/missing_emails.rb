require 'csv'
require 'fuzzystringmatch'

module MissingEmails

  class Import

    def initialize
      @file = "#{ENV['HOME']}/tmp/missing_emails.csv"
    end

    def run
      CSV.open(@file, headers: true).each_with_index do |row, index|
        person = Person.find_by(id: row['person_id'], kundennummer: row['kundennummer'])
        person.update(email: row['email']) unless person.email?
      end
    end
  end

  class Exporter

    def initialize
      @exists = []
      @invalid = []
    end

    def run
      CSV.open("#{ENV['HOME']}/tmp/missing_emails.csv", "wb") do |csv|
        csv << %w(ebene person_id email kundennummer)
        write(csv, households)
        write(csv, others.pluck('distinct(kundennummer)'))
      end

      puts "Duplicate emails: #{duplicates.count}"
      puts "People: #{people.count}"
      puts "Households: #{households.count}"
      puts "Other: #{others.count}"

      puts "Invalid emails: #{@invalid.size}"
      puts "Existing emails: #{@exists.size}"
      nil
    end

    def write(csv, scope)
      scope.each do |number|
        email = duplicates[number]
        next if invalid?(email)
        next if exists?(number, email)
        puts "#{number} #{email}"

        person = closest_match(number, email) do |name, distance, person|
          puts " #{distance} #{name} #{person.email}"
        end
        puts
        csv << [layer(person.layer_group)&.name, person.id, email, number]
      end
      nil
    end

    def layer(group)
      if [Group::Ort, Group::Region].any? { |c| group.is_a?(c) }
        layer(group.parent.layer_group)
      else
        group
      end
    end

    def exists?(number, email)
      Person.where(kundennummer: number, email: email).exists?.tap do |exists|
        @exists << number if exists
      end
    end

    def invalid?(email)
      invalid = !Truemail.valid?(email)
      invalid.tap do |invalid|
        @invalid << email if invalid
      end
    end

    def closest_match(number, email)
      name_part = email.split("@").first

      matches = Person.where(kundennummer: number).collect do |person|
        name = "#{person.first_name} #{person.last_name}"
        distance = jarow.getDistance(name, name_part)
        yield name, distance, person  if block_given?

        [person, name, distance]
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

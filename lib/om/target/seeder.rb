require "csv"
module Target
  class Seeder
    def self.run
      new("#{ENV['HOME']}/Documents/hitobito/CVP/Kantone_Vereinigungen_Hitobito.csv").run
    end

    def initialize(file)
      @file = file
    end

    def run
      CSV.read(@file, headers: true).each do |row|
        group = find_or_create_group(row)
        person = find_or_create_person(row)
        find_or_create_role(row, group, person)
      end

      PaperTrail::Version.delete_all
      puts "Current password: #{password}"
    end

    def find_or_create_group(row)
      layer = Group.find_by(name: row['Ebene'])
      type = [layer.class.sti_name, row['Gruppe']].join
      groups = Group.where(type: type, parent: layer)

      if groups.empty?
        Group.create!(parent: layer, type: type, name: row['Gruppe'])
      elsif groups.one?
        groups.first
      elsif groups.find { |g| g.name == row['Gruppe'] }
        groups.find { |g| g.name == row['Gruppe'] }
      else
        puts "found multiple(#{layer}, #{type}), #{groups.map(&:name)}), using first"
        groups.first
      end
    end

    def find_or_create_person(row)
      Person.find_or_create_by(email: row['EMail']) do |p|
        p.first_name = row['Vorname']
        p.last_name = row['Name']
        p.correspondence_language = language(row['Sprache'])
      end.tap do |person|
        person.update!(password: password)
      end
    end

    def find_or_create_role(row, group, person)
      role_type = group.class.role_types.find { |t| t.to_s.ends_with?(row["Rolle"]) }
      Role.find_or_create_by!(person: person, group: group, type: role_type)
    end

    def password
      file = Rails.root.join('tmp/password.txt')
      file.write(SecureRandom.hex(10)) unless file.exist?
      file.read.strip
    end

    def language(val)
      case val
      when /Deutsch/ then :de
      when /Französisch/ then :fr
      when /Italienisch/ then :it
      end
    end
  end
end

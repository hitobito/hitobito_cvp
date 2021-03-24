require "csv"
module Target
  class Seeder

    FILE_OLD = "#{ENV['HOME']}/Documents/hitobito/CVP/Kantone_Vereinigungen_Hitobito.csv"
    FILE_NEW = "#{ENV['HOME']}/Documents/hitobito/CVP/Logins_Hitobito.csv"

    ActiveSupport::Deprecation.silenced = true

    def self.run(file = FILE_NEW)
      new(file).run
    end

    class Finder
      attr_reader :row
      SEQUENCE = %w[Kanton Region Ort].freeze

      def initialize(row)
        @row = row
      end

      def valid?
        parent && group && role_type
      end

      def error
        if !parent
          :no_parent
        elsif !group
          :no_group
        elsif !role_type
          :no_role
        end
      end

      def group
        @group ||= find_or_create_group
      end

      def parent
        @parent ||= find_parent
      end

      def role_type
        group.class.role_types.find { |t| t.to_s.ends_with?(row['Rolle']) }
      end

      def find_parent
        if parent_type
          Group.find_by(type: "Group::#{parent_type}", name: row[parent_type].strip)
        else
          Group.find_by(name: row['Ebene'].strip)
        end
      end

      def find_or_create_group
        groups = Group.where(type: group_type, parent: parent)

        if groups.empty?
          Group.create!(parent: parent, type: group_type, name: row['Gruppe'])
        elsif groups.one?
          groups.first
        elsif groups.select { |g| g.name == group_name }.one?
          groups.find { |g| g.name == group_name }
        else
          puts "found multiple(#{parent}, #{group_type}), #{groups.map(&:name)}), using first"
          groups.first
        end
      end

      def parent_type
        SEQUENCE.reverse.find { |header| row[header].present? }
      end

      def group_type
        [parent.class.sti_name, group_name].join
      end

      def group_name
        row['Gruppe']
      end
    end

    def initialize(file)
      @file = file
    end

    def run
      puts "Seeding total of #{csv.size} rows"
      csv.collect.each_with_index do |row, index|
        next if row['Rolle'].blank?
        seed(row, index)
      end
    end

    def csv
      @csv ||= CSV.read(@file, headers: true, converters: ->(f) { f&.strip } )
    end

    def seed(row, index)
      finder = Finder.new(row)
      if finder.valid?
        person = find_or_create_person(row)
        find_or_create_role(person, finder.group, finder.role_type)
      else
        puts("%-3d %-5s %s" % [index, finder.error, row])
      end
    rescue => e
      puts("%-3d %-5s %s" % [index, e.message, row])
    end

    def find_or_create_person(row)
      Person.find_or_create_by(email: row['Email']) do |p|
        p.first_name = row['Vorname']
        p.last_name = row['Name']
        p.correspondence_language = language(row['Sprache'])
      end.tap do |person|
        person.update!(password: password)
      end
    end

    def find_or_create_role(person, group, role_type)
      role_type.find_or_create_by!(person: person, group: group)
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
      else :de
      end
    end
  end
end

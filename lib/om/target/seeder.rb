module Target
  class Seeder
    def self.run
      new("#{ENV['HOME']}/Downloads/cvp/sekretaere.yaml").run
    end

    def initialize(file)
      @file = file
    end

    def run
      config.each do |group_name, people|
        parent = Group.find_by(name: group_name)
        next unless parent
        group, role_types = group_and_role_types(parent)
        next unless group

        people.each do |name, email|
          first_name, last_name = name.split
          person = Person.find_or_create_by(email: email) do |p|
            p.first_name = first_name
            p.last_name = last_name
          end
          person.update!(password: password)
          role_types.each do |type|
            type.find_or_create_by!(person: person, group: group)
          end
        end
      end
      PaperTrail::Version.delete_all
      puts "Current password: #{password}"
    end

    def group_and_role_types(parent)
      type = parent.is_a?(Group::Bund) ? Group::BundSekretariat : Group::KantonSekretariat
      group = Group.find_or_create_by!(type: type, parent: parent) do |group|
        group.name = 'Sekretariat'
      end
      [group, role_types(group)]
    end

    def role_types(group)
      if group.is_a?(Group::BundSekretariat)
        [Group::BundSekretariat::Mitarbeiter, Group::BundSekretariat::Kassier, Group::BundSekretariat::ItSupport]
      else
        [Group::KantonSekretariat::Mitarbeiter]
      end
    end

    def password
      file = Rails.root.join('tmp/password.txt')
      file.write(SecureRandom.hex(10)) unless file.exist?
      file.read.strip
    end

    def config
      YAML.load_file(@file)
    end
  end
end

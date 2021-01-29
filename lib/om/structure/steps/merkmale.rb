module Structure::Steps
  class Merkmale < Base
    def run
      roles.select(&:tbd?).each do |role|
        binding.pry if role.label == 'Bundesrichter'
        merkmale.build(role)
      end
    end

    def roles
      @rows.flat_map(&:roles)
    end

    def merkmale
      @merkmale ||= Structure::Merkmal::List.new(merkmale_csv).tap do |list|
        list.print_invalid_rows
      end
    end

    def merkmale_csv
      Pathname.new(Dir.home).join(@config.dig(:roles_new, :merkmale))
    end
  end
end


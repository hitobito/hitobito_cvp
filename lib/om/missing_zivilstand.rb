require 'csv'

module MissingZivilstand

  FILE = "#{ENV['HOME']}/missing_zivilstand.yaml"


  MAPPING = {
    geschieden: :divorced,
    Konkubinat: :registered_partnership,
    verheiratet: :married,
    verwitwet: :widowed
  }

  class Import

    def run
      data = YAML.safe_load(File.read(FILE))
      data.each do |key, ids|
        value = MAPPING[key.to_sym]
        count = Person.where(civil_status: :single, kunden_id: ids).update_all(civil_status: value)
        puts "Updated #{count} singles to #{value}"
        nil
      end
    end
  end

  class Exporter
    def run
      data = Kontakt.where(zivilstand: MAPPING.keys).pluck(:zivilstand, :kunden_id).group_by(&:shift)
      transformed = data.to_h.transform_values(&:flatten)
      File.write(FILE, transformed.to_yaml)
    end
  end
end

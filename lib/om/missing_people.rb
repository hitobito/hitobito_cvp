require "csv"
module MissingPeople

  class Import
    # 1. Create missing people
    # 2. Create group (maybe)
    # 3. Create role (maybe)

  end

  # Sind komisch verhängt, als mitgliedschaften
  # Gibt noch mehrere untergruppen in dem Publikations Merkmal
  # ["Stadt Bern Info",
  #  "CVP SG Info",
  #  "Die Politik",
  #  "7 Tage",
  #  "Geschäftsbericht",
  #  "Hintergrundinfos",
  #  "NL: Communiqués",
  #  "NL: Pressedienst/7 Tage",
  #  "online community",
  #  "Palladium",
  #  "CVP BL Zeitung",
  #  "CVP BE Inform",
  #  "CVP LU Info",
  #  "CVP AG PIZ",
  #  "CVP SO Persönlich",
  #  "CVP BS Zeitung",
  #  "CVP ZH Abonnent",
  #  "Abonnement VS Romand",
  #  "Popolo e Libertà"]

  class Exporter
    # 0. discuss other potentially missing people
    #
    # 1. identify missing people
    # 2. identify group / role (Stefan)
    # 3. Export person attrs (as in normal import (gender / email fixes ..))
    #   -> Integrate zivilstand fix
    # 4. Generate CSV with person attrs, role, parent group
    #
    def self.generate
      new.generate
      new(scope: :without_deleted).generate
    end


    def initialize(merkmal = Merkmal.cvp_lu_info, scope:  nil)
      @merkmal = merkmal
      @scope = scope ? Mitgliedschaft.send(scope) : Mitgliedschaft
      @label = [@merkmal.merkmal_bezeichnung_d,scope].compact.join(' ').parameterize
      @file = "missing-people-#{@label}.csv"
    end


    def info
      puts "Total: #{kontakte.count}"
      puts "Existing: #{existing.count}"
      puts "Missing: #{missing.count}"
    end

    def generate
      CSV.open(@file, "wb") do |csv|
        csv << missing.first.prepare.keys
        missing.each do |kontakt|
          kontakt.email = nil if existing_emails.include?(kontakt.email)
          csv << kontakt.prepare.values
        end
      end
      puts "Generated #{@file}"
    end

    def existing_emails
      @existing_emails ||= Person.where.not(email: "").pluck(:email)
    end

    def existing
      @existing ||= Person.where(kunden_id: kontakte.pluck(:kunden_id))
    end

    def missing
      @missing ||= Kontakt.where(kunden_id: kontakte.pluck(:kunden_id) - existing.pluck(:kunden_id))
    end

    def kontakte
      Kontakt.joins(:mitgliedschaften).merge(mitgliedschaften).distinct
    end

    def mitgliedschaften
      @scope.joins(:merkmale).merge(@merkmal.mitgliedschafts_merkmale)
    end
  end

end

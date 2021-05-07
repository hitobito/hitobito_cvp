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

    def info
      puts "Total: #{kontakte.count}"
      existing = Person.where(kunden_id: kontakte.pluck(:kunden_id))
      puts "Existing: #{existing.count}"
      puts "Missing: #{kontakte.count - existing.count}"
    end

    def kontakte
      Kontakt.joins(:mitgliedschaften).merge(mitgliedschaften)
    end

    def mitgliedschaften
      Mitgliedschaft.joins(:merkmale).merge(Merkmal.cvp_lu_info.mitgliedschafts_merkmale)
    end
  end

end

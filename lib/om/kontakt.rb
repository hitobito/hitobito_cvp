class Kontakt < SourceModel
  self.primary_key = 'kunden_id'

  self.attrs = %w(
    kunden_id
    kundennummer
    kontaktnummer
    anrede_code
    sprache
    vorname
    name
    geschlecht
    titel_vor_name1
    titel_vor_name2
    titel_nach_name1
    titel_nach_name2
    telefonart1
    telefonart2
    telefonart3
    telefonart4
    telefonart5
    telefon1
    telefon2
    telefon3
    telefon4
    telefon5
    firma
    email
    jahr_geburt
    monat_geburt
    tag_geburt
    strasse
    hausnummer
    hausnummer_zusatz
    postleitzahl
    ortschaft
    land
  )

  has_one :verband, foreign_key: :kunden_id
  has_many :addresses, foreign_key: :kunden_id
  has_many :mitgliedschaften, foreign_key: :kunden_id, class_name: 'Mitgliedschaft'
  has_many :verbindungen, -> { active }, foreign_key: :kunden_id_1, class_name: 'Verbindung'
  has_many :merkmal, class_name: 'Merkmal', through: :verbindungen
  has_many :spenden, foreign_key: :kunden_id, class_name: 'Spende'

  ## Fachlich
  scope :deleted, -> { where.not(loeschflag: nil) }
  scope :without_deleted,-> { where(loeschflag: nil) }
  scope :verbaende, -> { joins(:verband) }
  scope :without_verbaenden, -> { left_outer_joins(:verband).where(verbandstruktur: { verbandstruktur_id: nil }) }
  scope :with_email, -> { where.not(email: nil) }

  ## Personen
  scope :violas, -> { where(vorname: 'Viola', name: 'Amherd') }
  scope :gerhards, -> { where(vorname: 'Gerhard', name: 'Pfister') }
  scope :nicolos, -> { where(vorname: 'Nicolo', name: 'Paganini') }
  scope :luca, -> { where(vorname: 'Luca', name: 'Strebel') }

  scope :stefans, -> { where(vorname: 'Stefan', name: 'Züger') }
  scope :stefan_bund, -> { find_by(vorname: 'Stefan', name: 'Züger', kundennummer: 112_199) }
  scope :stefan_jcvp, -> { find_by(vorname: 'Stefan', name: 'Züger', kundennummer: 3_085_951) }
  scope :stefan_anderer, -> { find_by(vorname: 'Stefan', name: 'Züger', kundennummer: 138_465) }

  scope :pius, -> { find_by(kundennummer: 3116293, kontaktnummer: 1) }
  scope :pius_firma, -> { find_by(kundennummer: 254369, kontaktnummer: 9) }
  scope :marianne, -> { find_by(kundennummer: 3000668, kontaktnummer: 1) }


  ## Familen (und Gruppnen?)
  scope :familien, -> { Kontakt.group(:kundennummer).having('count(kundennummer)> 1') }
  scope :familie_a, -> { Kontakt.where(kundennummer: 3041508) }

  ## Verbände
  # 586 Verbände habe diese KundenId
  scope :generalsekretariat, -> { find_by(kunden_id: '{22A68C32-A498-4021-8A81-B00FD5317141}') }

  # 196 Verbände habe diese KundenId
  scope :cvp_st_gallen, -> { find_by(kunden_id: '{130EE606-B789-42E2-8C67-20C43843B744}') }

  # 144 Verbände habe diese KundenId
  scope :cvp_luzern, -> { find_by(kunden_id: '{4DCFC4DA-E8D2-4C01-A29E-8F86664AC33E}') }

  # 77 Verbände habe diese KundenId
  scope :cvp_schwyz, -> { find_by(kunden_id: '{8FE2F51D-878C-41DA-A9D2-5B7F3E4A58C4}') }

  # 65 Verbände habe diese KundenId
  scope :cvp_region_st_gallen_gossau, -> { find_by(kunden_id: '{E2E5CE5F-E9BA-4DDA-A45B-CB6B7BD7A619}') }

  def self.familien_by_size
    familien.count.sort_by(&:second).reverse
  end

  def prepare
    name_attrs
      .merge(address_attrs)
      .merge(salutation_attrs)
      .merge(
        birthday: birthday,
        gender: gender,
        email: email.presence,
        title: title,
        kunden_id: kunden_id,
        kundennummer: kundennummer,
        kontaktnummer: kontaktnummer
      )
  end

  def attrs
    prepare.except(:erfassungs_benutzer, :kunden_id)
  end

  def ident_attrs
    attrs.slice(:first_name, :last_name, :birthday)
  end

  def salutation_attrs
    gender ? { salutation: "sehr_geehrter_titel_nachname" } : { salutation: nil }
  end

  def title
    [
      :titel_vor_name1, :titel_vor_name2,
      :titel_nach_name1, :titel_nach_name2,
    ].collect { |field| send(field) }.compact.select(&:present?).join(' ').presence
  end

  def address_attrs
    address = [strasse, hausnummer, hausnummer_zusatz].reject(&:blank?).compact
    address_string = address.join(' ') if address.present?

    {
      address: address_string,
      zip_code: postleitzahl,
      town: ortschaft,
      country: land
    }
  end

  def name_attrs
    attrs = {
      first_name: vorname,
      last_name: firma? ? nil : name,
      company_name: firma? ? firma : nil,
      company: firma?
    }

    attrs.merge!(last_name: firma) if name.blank? && firma.present?
    attrs
  end

  def firma?
    firma.present? && anrede_code == 5
  end

  def gender
    case geschlecht
    when 'männlich' then :m
    when 'weiblich' then :w
    end
  end

  def birthday
    if [jahr_geburt, monat_geburt, tag_geburt].all?(&:positive?)
      Date.new(jahr_geburt, monat_geburt, tag_geburt)
    end
  rescue ArgumentError => e
    nil
  end

  def to_s
    [vorname, name, firma, email, birthday].compact.join(' ')
  end

  def phone_numbers
    labels = ["Telefon privat", "Telefon Geschäft", "Fax privat", "Fax Geschäft", "Natel"]
    1.upto(5).collect do |i|
      number = send("telefon#{i}")
      next if number.blank?

      {
        label: send("telefonart#{i}") || labels[i-1],
        number: number
      }

    end.compact
  end
end


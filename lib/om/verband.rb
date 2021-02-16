class Verband < SourceModel
  self.table_name = :verbandstruktur
  self.primary_key = :verbandstruktur_id

  acts_as_nested_set primary_column: :verbandstruktur_id, parent_column: :ref_verbandstruktur_id, depth_column: :depth

  belongs_to :verband, foreign_key: :ref_verbandstruktur_id
  belongs_to :kontakt, optional: true, foreign_key: :kunden_id
  belongs_to :merkmal, optional: true, foreign_key: :hc_funktion, primary_key: :group_id
  belongs_to :funktion, class_name: 'Merkmal', optional: true, foreign_key: :hc_funktion, primary_key: :group_id
  belongs_to :addressode, class_name: 'Merkmal', optional: true, foreign_key: :hc_addresscode, primary_key: :group_id

  has_many :mitgliedschaften, class_name: 'Mitgliedschaft', foreign_key: :struktur_id
  has_many :dokumente, -> { minimal }, class_name: 'Dokument', foreign_key: :struktur_id
  has_many :verbindungen, class_name: 'Verbindung', foreign_key: :struktur_id

  scope :list, -> { order(:verbandstruktur_id) }

  scope :kantonalsektionen, -> { where(bezeichnung_d: 'Kantonalsektionen') }
  scope :mitgliedschaften, -> { where(bezeichnung_d: 'Mitgliedschaften') }

  scope :with_mitglieder, -> { where.not(kunden_id: nil) }
  scope :with_group, -> { where(verbandstruktur_id: Group.pluck(:id)).order(:verbandstruktur_id) }
  scope :without_deleted, -> { joins(:kontakt).where(kontakt_daten: { loeschflag: nil }) }

  #  later clean this up to pass some sort of structure
  attr_accessor :parent_attrs

  self.attrs = %w(
    verbandstruktur_id
    ref_verbandstruktur_id
    bezeichnung_d
    kunden_id
  )

  def to_s
    "#{bezeichnung_d} (#{verbandstruktur_id})"
  end

  def attrs
    { kunden_id: kunden_id }
  end

  # Works directly as colums
  def kontakt_attrs
    kontakt_with_null_check.address_attrs.merge(email: kontakt&.email)
  end

  # Requires separate insert statements
  def phone_numbers
    kontakt_with_null_check.phone_numbers.collect do |number|
      number.merge(contactable_type: type, contactable_id: verbandstruktur_id)
    end
  end

  def kontakt_with_null_check
    @kontakt ||= self.kontakt || Kontakt.new
  end

  def self.set_depth!
    self.update_all("#{depth_column_name} = ((select count(*) from #{self.quoted_table_name} t where t.lft <= #{self.quoted_table_name}.lft and t.rgt >= #{self.quoted_table_name}.rgt) - 1)")
  end
end

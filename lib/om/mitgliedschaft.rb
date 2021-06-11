class Mitgliedschaft < SourceModel
  self.primary_key = 'mitgliedschafts_nummer'

  belongs_to :kontakt, foreign_key: :kunden_id
  belongs_to :verband, foreign_key: :struktur_id

  has_many :merkmale, foreign_key: :mitgliedschaftsnummer, class_name: 'MitgliedschaftsMerkmal'

  EINZEL = 'einzel|ehren|jugend|jeune|indi|senior'.freeze
  FAMILIE = 'fam'.freeze
  SYMPATHISANT = 'sym'.freeze

  self.attrs = %w(
    kunden_id
    struktur_id
    mitgliedschafts_bezeichnung
    mitgliedschafts_nummer
    created_at
    deleted_at
  )

  scope :einzel, -> { where("mitgliedschafts_bezeichnung ~* '#{EINZEL}'") }
  scope :familie, -> { where("mitgliedschafts_bezeichnung ~* '#{FAMILIE}'") }
  scope :sympathisant, -> { where("mitgliedschafts_bezeichnung ~* '#{SYMPATHISANT}'") }
  scope :mitglieder, -> { einzel.or(familie).or(sympathisant) }
  scope :other, -> { where.not(mitgliedschafts_nummer: mitglieder.select(:mitgliedschafts_nummer)) }
  scope :without_deleted, -> { where.not(deleted_at: nil) }

  def timestamps
    {
      created_at: created_at || deleted_at,
      updated_at: Time.zone.now,
      deleted_at: deleted_at
    }
  end

  def label
    mitgliedschafts_bezeichnung
  end
end

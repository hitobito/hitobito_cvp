# Wie ist verhängt
#   - Auftraggeber ist ein Kontakt
#   - Wie komm ich vom Kontakt zur Gruppe?
#   - Wie komm ich vom von der Kampagne zu den Mitgliedern?
#
class Kampagne < SourceModel
  self.table_name = :kampagnenstamm
  self.primary_key = :kampagnen_nummer
  belongs_to :kontakt, foreign_key: :auftraggeber_kunden_id
  has_many :segmente, class_name: 'KampagneSegment', foreign_key: :kampagnen_nummer
  has_many :spenden, class_name: 'Spende', foreign_key: :kampagnen_nummer

  scope :list, -> { order(postaufgabe_am: :desc) }
  scope :all_year, -> { where(postaufgabe_am: Date.today.all_year) }

  self.attrs = %w(
    kampagnen_nummer
    bezeichnung
  )

  def self.counts
    self.all_year.group(:auftraggeber_kunden_id).count.sort_by(&:second)
  end

  def self.counts_with_highest_group
    self.counts.collect do |id, counts|
      verband = Verband.where(kunden_id: id).order(depth: :desc).first || 'none'
      [verband.to_s, counts]
    end
  end

  def self.counts_with_kontakts
    counts.sort_by(&:second).collect do |id, count|
      p [Kontakt.find_by(kunden_id: id).to_s, count]
    end
  end

  def prepare
    { id: kampagnen_nummer, title: bezeichnung, created_at: aufbereitet_am, updated_at: aufbereitet_am }
  end

  def to_s
    "#{id} - #{bezeichnung} #{auftraggeber_name}"
  end
end


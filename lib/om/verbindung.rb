class Verbindung < SourceModel
  self.primary_key = :verbindungsnummer

  belongs_to :kontakt1, foreign_key: :kunden_id_1, class_name: 'Kontakt'
  belongs_to :kontakt2, foreign_key: :kunden_id_2, class_name: 'Kontakt'
  belongs_to :verband, foreign_key: :struktur_id
  belongs_to :merkmal

  self.attrs = %w(
    kunden_id_1
    datum_von
    datum_bis
    verbindungsnummer
    merkmal_id
    struktur_id
    bemerkungen
  )

  scope :active, -> { where(datum_bis: nil).or(where('datum_bis > ?', Date.today)) }

  def attrs
    { created_at: datum_von || Time.zone.now, deleted_at: datum_bis, label: bemerkungen }
  end

  def to_s
    [verbindungsnummer, verband, merkmal, datum_von, datum_bis, bemerkungen].join(' - ')
  end

end

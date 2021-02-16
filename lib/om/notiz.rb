class Notiz < SourceModel
  self.table_name = :notizen
  self.primary_key = :notiznummer
  belongs_to :kontakt, foreign_key: :kunden_id

  scope :kampagne, -> { where(protokollart: 'Kampagne') }
  scope :neutral, -> { where(protokollart: 'Neutral') }

  self.attrs = %w(
    protokollart
    aufgabennummer
    notiznummer
    kunden_id
    bezeichnung
    text
    erfassungs_datum
  )
end


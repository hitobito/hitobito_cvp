class DokumentEmpfaenger < SourceModel
  self.table_name = :dokumente_empfдnger

  belongs_to :kontakt, foreign_key: :empfänger_id
  # Das würde ich erwarte, hier steht aber ein Datum und keine dokumente nummer
  # belongs_to :dokument, foreign_key: :nummer

  scope :absender, -> { where(art: 'Absender') }
  scope :empfaenger, -> { where(art: %w(An CC Hauptempfänger)) }
end

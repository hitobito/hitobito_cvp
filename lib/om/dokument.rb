class Dokument < SourceModel
  self.table_name = :dokumente
  self.primary_key = :nummer
  belongs_to :verband, foreign_key: :struktur_id
  #
  # scope :kampagne, -> { where(protokollart: 'Kampagne') }
  # scope :neutral, -> { where(protokollart: 'Neutral') }
  #
  self.attrs = %w(
    nummer
    art
    struktur_id
    bezeichnung
    dateiname
    status
    action
    dokument_status
    erfasst_datum
    mutiert_datum
    created_on
    )
end


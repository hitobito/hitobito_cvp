# Muss importiert werden
#  - eventuell als Rechnung
#  - ist eine Kampagne zuordenbar
class Spende < SourceModel
  self.table_name = :spenden_history
  self.primary_key = :spenden_nummer

  belongs_to :kontakt, foreign_key: :kunden_id
  belongs_to :kampagne, foreign_key: :kampagnen_nummer

  belongs_to :konto, foreign_key: :kostentraeger_id

  self.attrs = %w(
    spenden_nummer
    kunden_id
    kampagnen_nummer
    esr_zahlung
    spenden_datum
    betrag
  )

  def prepare
    {

      id: spenden_nummer,
      total: betrag,
      sent_at: spenden_datum,
      recipient_address: '',
      created_at: spenden_datum,
      updated_at: spenden_datum
    }
  end

  def to_s
    "#{kampagne.to_s} - #{kontakt.to_s} #{betrag} CHF"
  end
end


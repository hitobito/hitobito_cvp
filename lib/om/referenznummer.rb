class Referenznummer < SourceModel
  self.table_name = :referenznummern

  belongs_to :kontakt, foreign_key: :kunden_id
  belongs_to :kampagne, foreign_key: :mailingsnummer
end

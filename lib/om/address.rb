class Address < SourceModel
  self.table_name = :adresscodes
  self.primary_key = 'kunden_id'

  belongs_to :kontakt, foreign_key: :kunden_id

  belongs_to :merkmal_ob, ->(a) { where(merkmal_gruppe: a.merkmal_gruppe) }, foreign_key: :merkmal, primary_key: :merkmal
end


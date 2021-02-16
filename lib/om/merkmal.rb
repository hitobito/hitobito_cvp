class Merkmal < SourceModel
  self.table_name = :merkmal_stamm
  has_one :verbindung

  def to_s
    [merkmal_gruppe_bezeichnung_d, merkmal_bezeichnung_d].join(' ')
  end
end

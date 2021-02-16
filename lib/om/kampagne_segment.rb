class KampagneSegment < SourceModel
  self.table_name = :kampagnen_segmente
  self.primary_key = 'kampagnen_nummer'

  belongs_to :kampagne, foreign_key: :kampagnen_nummer

  scope :list, -> { order(aufbereitet_am: :desc)  }

  def to_s
    "#{bezeichnung} #{auftraggeber_name}"
  end
end


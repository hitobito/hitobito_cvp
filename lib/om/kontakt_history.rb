class KontaktHistory < SourceModel
  self.table_name = :kontakt_history

  belongs_to :kontakt, foreign_key: :kunden_id
  belongs_to :kampagne, foreign_key: :kampagnen_nummer
  belongs_to :segment, class_name: 'KampagnenSegment', foreign_key: :segment_nummer
  def to_s
    "#{bezeichnung} #{auftraggeber_name}"
  end
end


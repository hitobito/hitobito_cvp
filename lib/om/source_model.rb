class SourceModel < ActiveRecord::Base
  establish_connection(adapter: :postgresql)

  class_attribute :attrs

  self.abstract_class = true

  scope :minimal, -> { select(attrs.collect { |a| "#{table_name}.#{a}" }.join(',')) }

  private

  def parse(date)
    yy, mm, dd = date.scan(/([1|2]\d{3})(\d{2})(\d{2})/).first&.collect(&:to_i)
    Date.new(yy, mm, dd) if yy
  end

end

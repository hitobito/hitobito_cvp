module Import
  class Verband < Base

    def initialize(rows)
      @rows = rows
    end

    def run
      upsert(Group, @rows.collect(&:attrs))
      upsert(InvoiceConfig, invoice_configs)
      validate_sti(Group)
    end

    def invoice_configs
      Group.where('layer_group_id = id').pluck(:id).collect do |group_id|
        { group_id: group_id, sequence_number: 1, due_days: 30, currency: 'CHF' }
      end
    end
  end
end

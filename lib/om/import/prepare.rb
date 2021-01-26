module Import
  class Prepare
    attr_reader :models

    def initialize(models)
      @models = models
    end

    def run
      prepare_general
      prepare_nested_set
      truncate_imported_tables
      seed_root_data
    end

    def prepare_general
      ActiveSupport::Deprecation.debug = true
      ActiveSupport::Deprecation.silenced = true
      ActiveRecord::Base.logger.level = 1
      Group.all_types.each { |type| type.default_children = [] }
    end

    def prepare_nested_set
      ::Verband.rebuild! unless ::Verband.where(lft: nil).empty?
      ::Verband.set_depth! unless ::Verband.where(depth: 0).one?
    end

    def seed_root_data
      load 'db/seeds/root.rb' # mainly custom contents
    end

    def truncate_imported_tables
      models.each do |model|
        truncate(model)
      end
    end

    # Models with fk (subscription, subscription_tags) cannot be truncated
    def truncate(model)
      ActiveRecord::Base.connection.truncate(model.table_name)
    rescue
      model.delete_all
    end

  end
end

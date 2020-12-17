module Import
  class Runner < Base

    SUBTREES = {
      all: [1],
      cvp: [1, 29],
      cvp_be_muri: [1, 29, 154, 376],
      cvp_ag_lu_sg: [1, 29, [151, 163, 167]],
      cvp_ag: [1, 29, 151],
      cvp_lu: [1, 29, 163, 34110, 1422],
      cvp_sg: [1, 29, 167],
      cvp_ag_aarau: [1, 29, 151, [336]],
      cvp_ag_baden: [1, 29, 151, [337]],
      cvp_ag_zurzach: [1, 29, 151, [346]],
      cvp_sg_rheintal: [1, 29, 167, [537]],
      cvp_sg_gossau: [1, 29, 167, [541]],
    }

    def self.run(tree = nil, depth = nil)
      new(tree, depth).run
    end

    def initialize(tree, depth)
      @tree = tree
      @depth = depth
    end

    def prepare
      ActiveSupport::Deprecation.debug = true
      ActiveSupport::Deprecation.silenced = true
      ActiveRecord::Base.logger.level = 1
      ActiveRecord::Base.logger = nil
      Group.all_types.each { |type| type.default_children = [] }

      models.each do |model|
        ActiveRecord::Base.connection.truncate(model.table_name)
      end
    end

    def groups
      @groups ||= measured "Reading #{@tree || 'all'}" do
        group_ids = Structure::Groups::MAPPINGS.merge(SUBTREES).fetch(@tree, [1])
        Structure::Groups.new(group_ids: group_ids, depth: @depth).build
      end
    end

    def models
      [
        ::Person,
        Role,
        Group,
        PhoneNumber,
        InvoiceConfig,
        Invoice
      ].tap do |list|
        list << InvoiceList if defined?(InvoiceList)
      end

    end

    def run
      prepare
      with_disabled_indices do
        import_groups
        import_people
        import_roles

        if defined?(InvoiceList)
          import_kampagnen
          import_spenden
        end
        consolidate_families
        rebuild_groups
        update_primary_groups
      end
      set_primary_group_id_on_person
    end

    # saves about 10%
    def with_disabled_indices
      models.each do |model|
        model.connection.execute "ALTER TABLE #{model.table_name} DISABLE KEYS;"
      end

      yield

      models.each do |model|
        model.connection.execute "ALTER TABLE #{model.table_name} ENABLE KEYS;"
      end
    end

    def rebuild_groups
      measured "Rebuilding groups, seeding data" do
        Group.rebuild!
        Target::Seeder.run
      end
    end

    def import_kampagnen
      Import::Kampagnen.run
    end

    def import_spenden
      Import::Spenden.run(groups)
    end

    def consolidate_families
      Import::Familien.run
    end

    def import_groups
      Import::Verband.run(groups)
    end

    def import_people
      Import::Kontakt.run(groups)
    end

    def import_roles
      Import::Roles.run(groups)
    end

    def update_primary_groups
      Import::PrimaryGroups.run
    end

    def kunden_ids
      groups.flat_map { |g| g.roles.collect(&:kunden_id) }
    end
  end
end

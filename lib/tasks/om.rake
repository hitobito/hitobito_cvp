namespace :om do

  desc "Import to postgres and then to mysql"
  task :import do
    Rake::Task['om:source:run'].invoke
    Rake::Task['om:target:publish'].invoke
  end

  namespace :source do
    desc 'Runs all steps necessary'
    task :run, [:file] do |_t, args|
      Source::Importer.new(args[:file]).run
    end

    desc 'Extracts csv files to tmp/migration'
    task :extract, [:file] do |_t, args|
      Source::Importer.new(args[:file]).extract
    end

    desc 'Prepares csv files for import'
    task :convert, [:file] do |_t, args|
      Source::Importer.new(args[:file]).convert
    end

    desc 'Import cvs files in database, expects CVS files in tmp/migration'
    task :import, [:file] do |_t, args|
      Source::Importer.new(args[:file]).import
    end
  end

  namespace :target do
    desc 'Import into local database'
    task :import, [:validate, :tree] do |_t, args|
      tree = args[:tree]&.to_sym
      Import::Runner.run(tree: tree, validate: true)
    end

    desc 'Publish import to production'
    task :publish do
      Target::Publisher.new.run
    end
  end

  namespace :structure do
    desc 'Render Groups and Roles for (tree_ids)'
    task :render, [:key] do |_t, args|
      selected ||= Structure::Groups::MAPPINGS.stringify_keys.slice(args[:key]).presence ||
        Structure::Groups::MAPPINGS

      selected = selected.merge(all: [1]) if args[:key].blank?

      selected.each do |key, group_ids|
        dir = File.join(File.dirname(__FILE__), '../../generated')
        renderer = Structure::Render::Hierarchy.new(group_ids: group_ids)
        puts "Rendering #{key} - #{renderer.rows.size}"
        File.write("#{dir}/groups/#{key}.txt", renderer.formatted.join("\n"))
        File.write("#{dir}/roles/#{key}.txt", renderer.formatted(:detail).join("\n"))
      end
    end

    desc 'Render Undefined Roles as CSV'
    task :merkmale do |_t, args|
      groups = Structure::Groups.new(group_ids: [1]).build
      roles = groups.flat_map { |g| g.roles }.compact.select(&:tbd?)
      simple = roles.collect { |role| [role.type.gsub('tbd:', ''), "Group::#{role.group.type}"] }
      rows = simple.uniq.collect { |row| row + [simple.count(row)] }.sort_by(&:first)
      CSV.open('merkmale.csv', 'wb') do |csv|
        csv << %w(Merkmal Gruppen Anzahl)
        rows.each { |row| csv << row }
      end
    end
  end

  namespace :groups do
    def write(label, args)
      depth = args[:depth]&.to_i
      tree = args[:tree]&.to_sym
      tree = nil if tree == :all
      skip = args.fetch(:skip, 1).to_i

      h = Verband::Hierarchy.new(tree: tree, skip: skip, depth: depth)
      name = %W[groups_#{label} #{tree}].reject(&:blank?).join('_') << ".txt"
      File.write(name, h.send("build_#{label}").join("\n"))
      puts name
    end

    desc "Write groups_with_types file (tree,depth,skip)"
    task :with_types, [:tree, :depth, :skip] do |_t, args|
      write(:with_types, args)
    end

    desc "Write groups_with_roles file (tree,skip,depth)"
    task :with_roles, [:tree, :depth, :skip] do |_t, args|
      write(:with_roles, args)
    end
  end

  namespace :roles do
    task :tbd, [:tree, :group_type] do |_t, args|
      tree = args.fetch(:tree)
      file = "groups_with_roles_#{tree}.txt"
      Rake::Task['om:groups:with_roles'].invoke(tree) unless File.exist?(file)

      group_type = args.fetch(:group_type)
      rows = File.readlines(file)
      rows_with_group = rows.select { |row| row =~ /#{group_type}/ }
      raise "#{group_type} not found" if rows_with_group.empty?

      regexp = /tbd:(.*?)[,|\)]/
      tbds = rows_with_group.collect { |row| row.scan(regexp) }.flatten.sort
      tbd_counts = tbds.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
      tbd_counts.sort_by(&:second).reverse.each do |label, count|
        puts "#{label} #{count}"
      end
    end
  end

  namespace :merkmale do
    def print_groups(group_ids)
      verbindungen = Verbindung.where(struktur_id: group_ids)
      merkmale = verbindungen.group(:merkmal_id).count.sort_by(&:second).reverse
      merkmale.each do |id, count|
        merkmal = Merkmal.find(id)
        p [merkmal.to_s, id, count]
        groups = Group.where(id: verbindungen.where(merkmal_id: id).pluck(:struktur_id))
        groups.group(:type).count.each do |type, count|
          roles = type.constantize.roles.collect { |r| r.sti_name.demodulize }
          puts " #{type}, #{count} #{roles.join(',')}"
          yield type if block_given?
        end
        puts
      end
    end

    def generate(file, group_ids = Group.pluck(:id))
      require 'csv'
      verbindungen = Verbindung.where(struktur_id: group_ids)
      merkmale = verbindungen.group(:merkmal_id).count.sort_by(&:second).reverse

      rows = merkmale.flat_map do |id, count|
        merkmal = Merkmal.find(id)
        merkmal_columns = [id, merkmal.merkmal_bezeichnung_d, count]

        groups = Group.where(id: verbindungen.where(merkmal_id: id).pluck('distinct struktur_id'))
        groups.group(:type).count.sort_by(&:second).reverse.collect do |group_type, count|
          roles = group_type.constantize.roles.collect { |r| r.sti_name.demodulize }
          group_names = groups.where(type: group_type).pluck('distinct name').sort
          merkmal_columns + [group_type, count, group_names.count, roles.join(' '), group_names.join(' ')]
        end
      end.prepend([:merkmal_id, :merkmal_name, :merkmal_count, :group_type, :group_count, :group_names_count, :role_types, :group_names ])
      CSV.open("#{file}.csv", "wb") do |csv|
        rows.each { |row| csv << row }
      end
    end

    desc "List Merkmale for groups"
    task :groups, [:tree] do |_t, args|
      tree = args.fetch(:tree, :cvp_ag_lu_sg)
      # [Role, Person, Group].each(&:delete_all)
      # Import::Verband.new(tree: tree.to_sym).run
      generate(tree, Group.pluck(:id))
    end

    desc "List Merkmale for layers"
    task :non_layers do
      print_groups(Group.where('id != layer_group_id').pluck(:id))
    end

    desc "List Merkmale for layers"
    task :layers do
      print_groups(Group.where('id = layer_group_id').pluck(:id))
    end

    desc "List all Merkmale ascending order"
    task :all do
      merkmale = Verbindung.group(:merkmal_id).count.sort_by(&:first)
      CSV.open("alle_merkmale.csv", "wb") do |csv|
        csv << [:id, :name, :anzahl]
        merkmale.each do |id, count|
          csv << [id, Merkmal.find(id).to_s, count]
        end
      end
    end

    desc "List all Merkmale pro kanton"
    task :kantons do
      Verband.find(29).children.find_each do |verband|
        ids = verband.descendants.pluck(:verbandstruktur_id)
        merkmale = Verbindung.group(:merkmal_id).where(struktur_id: ids).count.sort_by(&:first)
        file = "alle_merkmale_#{verband.bezeichnung_d.parameterize.underscore}.csv"
        puts file
        CSV.open(file, "wb") do |csv|
          csv << [:id, :name, :anzahl]
          merkmale.each do |id, count|
            csv << [id, Merkmal.find(id).to_s, count]
          end
        end
      end
    end

    desc "List alle Personen mit Merkmalen"
    task :personen, [:merkmal] do |_, args|
      merkmal = Merkmal.find_by(merkmal_bezeichnung_d: args.fetch(:merkmal))
      verbindungen = Verbindung.where(merkmal_id: merkmal.id).includes(:kontakt1)
      CSV.open("personen_#{merkmal.merkmal_bezeichnung_d.downcase}.csv", "wb") do |csv|
        csv << [:kunden_id, :first_name, :last_name, :datum_von, :datum_bis]
        verbindungen.each do |v|
          csv << [v.kontakt1.kunden_id, v.kontakt1.vorname, v.kontakt1.name, v.datum_von, v.datum_bis]
        end
      end
    end
  end

  task :addresses, [:file] do |_t, args|
    strassen = Kontakt.where(land: 'CH').pluck(:strasse).compact.uniq.sort
    streets = Address.pluck(:street_short, :street_short_old, :street_long, :street_long_old).flatten.uniq.compact.sort

    missing = strassen - streets

    puts "missing: #{missing.count}"
    file = Rails.root.join('tmp/post/Post_Adressdaten20201006.csv')
    res = missing.collect do |strasse|
      cmd =  "grep -c -i \"#{strasse}\" #{file}"
      matches = `#{cmd}`
      [strasse, matches]
    end
  end

end

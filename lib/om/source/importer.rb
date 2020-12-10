class Source::Importer
  attr_reader :zip, :database, :files, :config
  include Rake::DSL

  def initialize(files = nil)
    @zip = "~/Downloads/cvp/DatenExport.zip"
    @config = YAML.load_file(File.expand_path('config.yml', __dir__))
    @files = files ? Array(files) : config['files']
  end

  def run
    extract
    convert
    import
    rebuild_verband
  end

  def extract
    excluded = (config['files'] - files).collect { |file| "#{file}.csv" }
    sh "unzip #{zip} -d ./tmp/migration -x #{excluded.join(' ')}"
  end

  def convert # rubocop:disable Metrics/MethodLength
    each_migration_file do |file, _details, table|
      sh "csvclean -e latin1 -u 1 -d '|' #{file}.csv"
      line = File.open("#{file}_out.csv") { |f| f.readline }
      File.write("#{file}-copy.csv", line.split('|').collect(&:underscore).join('|'))
      cmd = "tail -n +2 #{file}_out.csv"
      cmd = "#{cmd} | sed '/^\"renggli-held/d'" if file =~ /01_KontaktDaten/
      sh "#{cmd} | csvformat -S >> #{file}-copy.csv"
      sh "head -n 100 #{file}-copy.csv > #{file}-brief.csv"

      # This takes forever as it checks all rows for all values to ensure we have th correct type
      unless File.exist?("#{file}-create.sql")
        sh "csvsql -I --tables #{table} #{file}-copy.csv > #{file}-create.sql"
      end
    end
  end

  # Besere Performance
  # 1) create
  # 2) alter
  # 3) copy
  # 4) update
  # 5) view
  def import
    each_migration_file do |file, details, table|
      sh "echo 'DROP TABLE IF EXISTS #{table} CASCADE' | psql"
      sh "cat #{file}-create.sql | psql"
      sh "echo '\\COPY #{table} FROM #{file}-copy.csv CSV HEADER' | psql"
      sh "echo \"#{details['alter']}\" | psql" if details['alter']
    end
  end

  private

  def each_migration_file
    cd 'tmp/migration' do
      config['migrate'].slice(*files).each do |file, details|
        table = file.split('_').last.underscore
        yield file, details || {}, table
      end
    end
  end

  # Not needed for copy anymore
  def rebuild_verband
    if Verband.where(lft: nil, rgt: nil).count > 1
      puts "Rebuilding Verband Struktur"
      Verband.rebuild!
      Verband.set_depth!
    end
  end
end

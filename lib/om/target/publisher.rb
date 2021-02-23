module Target
  class Publisher
    include Rake::DSL

    def self.run
      new.run
    end

    def run
      dump_tables
      copy_to_production
      import_data
    end

    def dump_tables
      `mysqldump #{::Person.connection.current_database} | gzip > #{file}`
    end

    def copy_to_production
      sh 'oc project htbt-die-mitte-prod'
      sh "oc exec #{pod} -t -- bash -c \"rm -rf /tmp/dump/#{file.basename}\" "
      sh "oc rsync #{file.dirname} #{pod}:/tmp"
    end

    def import_data
      sh "oc exec #{pod} -t -- bash -c \"#{write_credentials}\""
      sh "oc exec #{pod} -t -- bash -c \"zcat /tmp/dump/#{file.basename} | " \
        "mysql --defaults-extra-file=~/.mysql_credentials database\""
    end

    def write_credentials
      <<~SCRIPT
      echo '[client]' > ~/.mysql_credentials;
      echo "user=\\${MYSQL_USER:-root}" >> ~/.mysql_credentials;
      echo "password=\\${MYSQL_PASSWORD}" >> ~/.mysql_credentials;
      SCRIPT
    end

    def pod
      @pod ||= `oc get pods -oname -lapp=mysql`.strip
    end

    def file
      @file ||= Rails.root.join("tmp/dump/dump.sql.gz").tap do |f|
        FileUtils.mkdir_p f.dirname
      end
    end
  end

end

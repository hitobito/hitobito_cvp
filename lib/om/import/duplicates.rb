module Import
  class Duplicates < Base

    def run
      mark
      merge
    end

    def mark
      People::DuplicateLocator.new.run
    end

    def merge
      FileUtils.rm_rf(logfile)
      PersonDuplicate.find_each do |duplicate|
        process(duplicate)
      end
    end

    def process(duplicate)
      People::Merger.new(duplicate.person_1_id, duplicate.person_2_id, actor).merge! do
        logger.info "Merging #{duplicate.person_1} (#{duplicate.person_1_id})"
      end
    rescue => e
      logger.warn "#{e.message}: #{duplicate.person_1} (#{duplicate.person_1_id})"
    end

    def logger
      @logger ||= Logger.new(logfile).tap { |l| l.level = Logger::INFO }
    end

    def logfile
      Rails.root.join('duplicates.txt')
    end

    def actor
      @actor ||= ::Person.find_by(email: Settings.root_email)
    end

    def counts
      Role.group(:person_id, :group_id).count
    end
  end
end

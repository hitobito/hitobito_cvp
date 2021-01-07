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
      PersonDuplicate.includes(:person_1, :person_2).find_each do |duplicate|
        if email?(duplicate)
          process(duplicate)
        else
          logger.warn "No email for #{details(duplicate)}"
        end
      end
    end

    def process(duplicate)
      source, target = *sorted(duplicate)
      People::Merger.new(source, target, actor).merge! do
        logger.info "Merging #{details(duplicate)}"
      end
    rescue => e
      logger.warn "#{e.message}: #{details(duplicate)}"
    end

    def email?(duplicate)
      [duplicate.person_1, duplicate.person_2].any?(&:email?)
    end

    # returns duplicate without email first
    def sorted(duplicate)
      [duplicate.person_2, duplicate.person_1].sort_by {|x| x.email.to_s }.reverse
    end

    def details(duplicate)
      [duplicate.person_1, duplicate.person_2].collect do |person|
        infos = [person.zip_code, person.birthday, person.email]
        "#{person}(#{person.id}) #{infos}"
      end.join(' - ')
    end

    def logger
      @logger ||= Logger.new(logfile).tap { |l| l.level = Logger::INFO }
    end

    def logfile
      @logfile ||= Rails.root.join('duplicates.txt').tap do |file|
        FileUtils.rm_rf(file)
      end
    end

    def actor
      @actor ||= ::Person.find_by(email: Settings.root_email)
    end

    def counts
      Role.group(:person_id, :group_id).count
    end
  end
end

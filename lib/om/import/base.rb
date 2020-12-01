module Import
  class Base
    def self.run(*args)
      obj = new(*args)
      obj.measured { obj.run }
    end

    def measured(label = self.class.name)
      @start_time = Time.zone.now
      puts "Starting #{label}"
      res = yield
      puts "Finished #{label} - duration: #{duration}"
      res
    end

    def upsert(model, rows)
      puts " Inserted #{rows.size} #{model}"
      model.upsert_all(rows)
    end

    def time_diff(start_time, end_time)
      seconds_diff = (start_time - end_time).abs
      Time.at(seconds_diff).utc.strftime '%H:%M:%S'
    end

    def duration
      time_diff(@start_time, Time.zone.now)
    end

    def validate_sti(model_class)
      model_class.pluck(Arel.sql('distinct type')).each(&:constantize)
    rescue => e
      puts "Invalid type for #{model_class} - #{e}"
    end

    def group_ids
      Groups.instance.by_id.keys
    end

    def group_type(id)
      Groups.instance.get(id).type
    end

    def group_name(id)
      Groups.instance.get(id).name
    end

    def fetch_person_id(uuid)
      @people ||= ::Person.pluck(:kunden_id, :id).to_h
      @people.fetch(uuid)
    end
  end
end

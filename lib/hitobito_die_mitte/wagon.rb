# frozen_string_literal: true

#  Copyright (c) 2021, Die Mitte. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

module HitobitoDieMitte
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[ #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                                 #{config.root}/lib/om]

    config.to_prepare do
      # extend application classes here
      Group.send        :include, DieMitte::Group
      Role.send         :include, DieMitte::Role
      Person.send       :include, DieMitte::Person

      RoleDecorator.send :prepend, DieMitte::RoleDecorator
      GroupDecorator.send :prepend, DieMitte::GroupDecorator
      # rubocop:enable SingleSpaceBeforeFirstArg
      Event.role_types -= [Event::Role::Cook]

      PeopleController.send :prepend, DieMitte::PeopleController
      FilterNavigation::People.send :prepend, DieMitte::FilterNavigation::People

      Export::Pdf::Messages::Letter::Content.placeholders << :salutation
      Export::Pdf::Messages::Letter::Content.send :prepend,
                                                  DieMitte::Export::Pdf::Messages::Letter::Content
    end

    initializer 'die_mitte.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'die_mitte.add_inflections' do |_app|
      ActiveSupport::Inflector.inflections do |inflect|
        # inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end

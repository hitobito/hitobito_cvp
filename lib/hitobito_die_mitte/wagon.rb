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
                                 #{config.root}/app/jobs ]

    config.to_prepare do
      # extend application classes here
      Group.include DieMitte::Group
      Role.include DieMitte::Role
      Role.extend DieMitte::NormalizedLabels
      Person.include DieMitte::Person

      Person::FILTER_ATTRS << :correspondence_language << :email

      RoleDecorator.prepend DieMitte::RoleDecorator
      GroupDecorator.prepend DieMitte::GroupDecorator

      Event.role_types -= [Event::Role::Cook]

      MailingListsController.permitted_attrs << :correspondence_language

      PeopleController.prepend DieMitte::PeopleController
      FilterNavigation::People.prepend DieMitte::FilterNavigation::People

      PersonSerializer.include DieMitte::PersonSerializer

      Person::Filter::Attributes.prepend DieMitte::Person::Filter::Attributes

      Export::Tabular::People::PersonRow.include DieMitte::Export::Tabular::People::PersonRow

      MailingList::Subscribers.prepend DieMitte::MailingList::Subscribers
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

    initializer 'die_mitte.configure_devise' do |_app|
      Devise.reset_password_within = 2.weeks
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end

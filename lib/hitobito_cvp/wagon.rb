# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.


module HitobitoCvp
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
      Group.include Cvp::Group
      Role.include Cvp::Role

      RoleDecorator.prepend Cvp::RoleDecorator

      Event.role_types -= [Event::Role::Cook]

      PeopleController.prepend Cvp::PeopleController
      FilterNavigation::People.prepend Cvp::FilterNavigation::People

      # CVP LU 163 > Group::Region(5) Wahlkreis Willisau 34710 > TBD(2) Newsletter 38774",
      class ::Group::RegionExterneKontakte < Group; end
      ::Group::Region.possible_children += [::Group::RegionExterneKontakte]

      #  CVP AG 151 > Group::Region(5) Bezirk Bremgarten 338 > Group::Ort(5) Villmergen 800 > Group::OrtArbeitsgruppe(2) Partei 2487 > TBD(2) Vorstand 4508",
      class Group::OrtDelegierte < Group; end
      ::Group::Ort.possible_children += [::Group::OrtDelegierte]

      # CVP Schweiz 1 > Group::Vereinigung(5) 60+ 4 > TBD(2) Vorstand 36625
      class ::Group::VereinigungDelegierte < Group; end
      ::Group::Vereinigung.possible_children += [::Group::VereinigungDelegierte]

      # hat keine Mitglieder aber verbindungen
      # CVP Schweiz 1 > Group::Vereinigung(5) AWG 5 > TBD(1) Mitgliedschaften 36294
      class ::Group::VereinigungMitglieder < Group; end
      ::Group::Vereinigung.possible_children += [::Group::VereinigungMitglieder]

      ## Customizations for migration
      Group.all_types.each do |type|
        merkmal = Class.new(Role)
        type.const_set('Merkmal', merkmal)
        type.role_types += [merkmal]
      end
    end

    initializer 'cvp.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'cvp.add_inflections' do |_app|
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

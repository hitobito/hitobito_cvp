# frozen_string_literal: true

#  Copyright (c) 2021, Die Mitte. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.



# encoding: utf-8

class Group::Region < Group

  self.layer = true

  children Group::RegionParteigremium,
           Group::RegionPraesidium,
           Group::RegionSekretariat,
           Group::RegionArbeitsgruppe,
           Group::RegionDelegierte,
           Group::RegionMitglieder,
           Group::RegionSympathisanten,
           Group::RegionExterneKontakte,

           Group::Ort

  self.default_children = [
    Group::RegionSekretariat
  ]

end


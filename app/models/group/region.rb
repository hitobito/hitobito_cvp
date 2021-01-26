# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.



# encoding: utf-8

class Group::Region < Group

  self.layer = true

  children Group::RegionGewaehlte,
           Group::RegionParteigremium,
           Group::RegionPraesidium,
           Group::RegionSekretariat,
           Group::RegionArbeitsgruppe,
           Group::RegionDelegierte,
           Group::RegionMitglieder,
           Group::RegionSympathisanten,
           Group::RegionExterneKontakte,

           Group::Ort

  self.default_children = [
    Group::RegionSekretariat,
    Group::RegionGewaehlte
  ]

end


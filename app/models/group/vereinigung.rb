# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.


class Group::Vereinigung < Group

  self.layer = true


  children Group::VereinigungGewaehlte,
           Group::VereinigungParteigremium,
           Group::VereinigungPraesidium,
           Group::VereinigungSekretariat,
           Group::VereinigungKommission,
           Group::VereinigungArbeitsgruppe,
           Group::VereinigungExterneKontakte,
           Group::VereinigungMitglieder,
           Group::VereinigungSympathisanten,
           Group::VereinigungDelegierte,

           Group::Kanton

  ### ROLES
  #
  self.default_children = [
    Group::VereinigungGewaehlte,
    Group::VereinigungSekretariat
  ]

end

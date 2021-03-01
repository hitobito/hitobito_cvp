# frozen_string_literal: true

#  Copyright (c) 2021, Die Mitte. This file is part of
#  hitobito_die_mitte and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_die_mitte.

class Group::Vereinigung < Group

  self.layer = true


  children Group::VereinigungParteigremium,
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
    Group::VereinigungSekretariat
  ]

end

# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.

class Group::Ort < Group

  self.layer = true

  children Group::OrtGewaehlte,
           Group::OrtParteigremium,
           Group::OrtPraesidium,
           Group::OrtSekretariat,
           Group::OrtArbeitsgruppe,
           Group::OrtExterneKontakte,
           Group::OrtMitglieder,
           Group::OrtSympathisanten

  self.default_children = [
    Group::OrtGewaehlte,
    Group::OrtSekretariat,
    Group::OrtMitglieder
  ]

end


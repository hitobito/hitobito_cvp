# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.

class Group::VereinigungSekretariat < Group

  class Leitung < Role
    self.permissions = [:layer_and_below_full, :contact_data, :finance]
  end

  class Mitarbeiter < Role
    self.permissions = [:layer_and_below_full]
  end

  class Webadministrator < Role; end

  roles Leitung, Mitarbeiter, Webadministrator
end

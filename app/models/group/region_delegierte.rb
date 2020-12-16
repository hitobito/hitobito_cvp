# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.

class Group::RegionDelegierte < Group

  class Delegierte < Role
    self.permissions = []
  end

  class Ersatzdelegierte < Role
    self.permissions = []
  end

  roles Delegierte, Ersatzdelegierte

  children Group::RegionDelegierte
end

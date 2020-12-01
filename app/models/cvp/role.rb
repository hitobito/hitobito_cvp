# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.


module Cvp::Role
  extend ActiveSupport::Concern

  included do
    before_validation :assert_consistent_roles_within_mitglieder_group
  end

  class_methods do
    def label
      sti_name.ends_with?('Merkmal') ? 'Merkmal' : model_name.human
    end
  end

  def assert_consistent_roles_within_mitglieder_group
    if is_a?(Role::Mitglied) && group.roles.exists? && group.roles.first.type != type
      errors.add(:type, :inclusion)
    end
  end
end


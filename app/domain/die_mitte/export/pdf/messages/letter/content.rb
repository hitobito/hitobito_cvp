# frozen_string_literal: true

#  Copyright (c) 2021, Die Mitte. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.

module DieMitte::Export::Pdf
  module Messages::Letter
    module Content

      def salutation(recipient)
        recipient.salutation_value
      end

    end
  end
end

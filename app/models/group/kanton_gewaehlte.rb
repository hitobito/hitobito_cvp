# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.


class Group::KantonGewaehlte < Group
  class KantonaleExekutive < Role; end
  class KantonaleLegislative < Role; end
  class MitgliedKantonalesGerichtErsteInstanz < Role; end
  class MitgliedKantonalesGerichtZweiteInstanz < Role; end
  class Staatsanwaltschaft < Role; end
  class ParlamentarischeGeschaeftsfuehrung < Role; end
  class Fraktionschef < Role; end
  class WeitereMandate < Role; end

  roles KantonaleExekutive,
        KantonaleLegislative,
        MitgliedKantonalesGerichtErsteInstanz,
        MitgliedKantonalesGerichtZweiteInstanz,
        Staatsanwaltschaft,
        ParlamentarischeGeschaeftsfuehrung,
        Fraktionschef,
        WeitereMandate

  children Group::KantonGewaehlte
end

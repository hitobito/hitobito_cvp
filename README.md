# Hitobito Cvp

This hitobito wagon defines the organization hierarchy with groups and roles
of Cvp.

[![Build
Status](https://travis-ci.org/hitobito/hitobito_cvp.svg)](https://travis-ci.org/hitobito/hitobito_cvp)


## Organization Hierarchy

    * Schweiz
      * Gewählte
        * Bundesrat: []
        * Ständerat: []
        * Nationalrat: []
        * Bundesrichter (Vollamt): []
        * Bundesrichter (Nebenamt): []
        * Bundesverwaltungsrichter: []
        * Bundespatentrichter: []
        * Bundesstrafrichter: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Praesidium
        * Präsident: []
        * Vizepräsident: []
        * Mitglied: []
        * Gast: []
      * Sekretariat
        * Generalsekretär: [:layer_and_below_full, :contact_data, :admin]
        * Mitarbeiter: [:layer_and_below_full, :contact_data, :admin]
        * It-Support: [:impersonation]
        * Kassier: [:finance]
      * Kommission
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
      * Mitglieder
        * Mitglied: []
      * Sympathisanten
        * Sympathisant: []
    * Kanton
      * Gewählte
        * Kantonale Exekutive: []
        * Kantonale Legislative: []
        * Mitglied kantonales Gericht erste Instanz: []
        * Mitglied kantonales Gericht zweite Instanz: []
        * Staatsanwaltschaft: []
        * Parlamentarische Geschaeftsfuehrung: []
        * Fraktionschef: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Praesidium
        * Präsident: [:contact_data]
        * Vizepräsident: []
        * Mitglied: []
        * Gast: []
      * Sekretariat
        * Leitung: [:layer_and_below_full, :finance, :contact_data]
        * Mitarbeiter: [:layer_and_below_full]
      * Kommission
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
      * Mitglieder
        * Mitglied: []
      * Sympathisanten
        * Sympathisant: []
      * Spender
        * Rolle: []
        * Mitglied: []
    * Region
      * Gewählte
        * Fraktionschef: []
        * Region Exekutive: []
        * Region Legislative: []
        * Rolle: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Praesidium
        * Präsident: []
        * Vizepräsident: []
        * Kassier: [:finance]
        * Mitglied: []
      * Sekretariat
        * Leitung: [:layer_and_below_full]
        * Mitarbeiter: [:layer_and_below_full]
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
      * Mitglieder
        * Mitglieder: []
      * Sympathisanten
        * Sympathisant: []
    * Ortspartei
      * Gewählte
        * Fraktionschef: []
        * Kommunale Exekutive: []
        * Kommunale Legislative: []
        * Schulpflege/- kommission: []
        * Rechnungsprüfungskommission: []
        * Mitglied weitere Gemeindekommissionen: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Praesidium
        * Präsident: [:contact_data]
        * Vizepräsident: []
        * Kassier: [:finance]
        * Mitglied: []
        * Adressverwalter: [:layer_and_below_full]
        * Gast: []
      * Sekretariat
        * Leitung: [:layer_full]
        * Mitarbeiter: [:layer_full]
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
      * Mitglieder
        * Mitglied: []
      * Sympathisanten
        * Sympathisant: []
      * Spender
        * Rolle: []
        * Mitglied: []
    * Vereinigung
      * Gewählte
        * Fraktionschef: []
        * Vereinigung Exekutive: []
        * Vereinigung Legislative: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Praesidium
        * Präsident: [:contact_data]
        * Vizepräsident: []
        * Kassier: [:finance]
        * Mitglied: []
      * Sekretariat
        * Leitung: [:layer_and_below_full, :contact_data, :finance]
        * Mitarbeiter: [:layer_and_below_full]
      * Kommission
        * Präsident: []
        * Mitglied: []
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
      * Mitglieder
        * Mitglieder: []
      * Sympathisanten
        * Sympathisant: []

# Hitobito Cvp

This hitobito wagon defines the organization hierarchy with groups and roles
of Cvp.

[![Build
Status](https://travis-ci.org/hitobito/hitobito_cvp.svg)](https://travis-ci.org/hitobito/hitobito_cvp)


## Organization Hierarchy

    * Schweiz
      * Schweiz
        * Merkmal: []
      * Gewählte
        * Bundesrat: []
        * Bundeskanzler: []
        * Ständerat: []
        * Nationalrat: []
        * Bundesrichter (Vollamt): []
        * Bundesrichter (Nebenamt): []
        * Bundesverwaltungsrichter: []
        * Bundespatentrichter: []
        * Bundesstrafrichter: []
        * Merkmal: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Praesidium
        * Präsident: []
        * Vizepräsident: []
        * Mitglied: []
        * Gast: []
        * Merkmal: []
      * Sekretariat
        * Leitung: [:layer_and_below_full, :contact_data, :admin]
        * Mitarbeiter: [:layer_and_below_full, :contact_data, :admin]
        * It-Support: [:impersonation]
        * Kassier: [:finance]
        * Webadministrator: []
        * Merkmal: []
      * Kommission
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Merkmal: []
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
        * Merkmal: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
        * Delegierte von Amtes wegen: []
        * Merkmal: []
      * Mitglieder
        * Mitglied: []
        * Merkmal: []
      * Sympathisanten
        * Sympathisant: []
        * Merkmal: []
    * Kanton
      * Kanton
        * Merkmal: []
      * Gewählte
        * Kantonale Exekutive: []
        * Kantonale Legislative: []
        * Mitglied kantonales Gericht erste Instanz: []
        * Mitglied kantonales Gericht zweite Instanz: []
        * Staatsanwaltschaft: []
        * Parlamentarische Geschaeftsfuehrung: []
        * Fraktionschef: []
        * Weitere Mandate: []
        * Merkmal: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Praesidium
        * Präsident: [:contact_data]
        * Vizepräsident: []
        * Mitglied: []
        * Gast: []
        * Kassier: [:finance]
        * Merkmal: []
      * Sekretariat
        * Leitung: [:layer_and_below_full, :finance, :contact_data]
        * Mitarbeiter: [:layer_and_below_full]
        * Webadministrator: []
        * Merkmal: []
      * Kommission
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Merkmal: []
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
        * Merkmal: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
        * Delegierte von Amtes wegen: []
        * Merkmal: []
      * Mitglieder
        * Mitglied: []
        * Merkmal: []
      * Sympathisanten
        * Sympathisant: []
        * Merkmal: []
    * Region
      * Region
        * Merkmal: []
      * Gewählte
        * Fraktionschef: []
        * Region Exekutive: []
        * Region Legislative: []
        * Region Judikative: []
        * Merkmal: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Praesidium
        * Präsident: []
        * Vizepräsident: []
        * Kassier: [:finance]
        * Mitglied: []
        * Merkmal: []
      * Sekretariat
        * Leitung: [:layer_and_below_full]
        * Mitarbeiter: [:layer_and_below_full]
        * Webadministrator: []
        * Merkmal: []
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
        * Merkmal: []
      * Mitglieder
        * Mitglieder: []
        * Merkmal: []
      * Sympathisanten
        * Sympathisant: []
        * Merkmal: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
        * Merkmal: []
    * Ortspartei
      * Ortspartei
        * Merkmal: []
      * Gewählte
        * Fraktionschef: []
        * Kommunale Exekutive: []
        * Kommunale Legislative: []
        * Schulpflege/- kommission: []
        * Rechnungsprüfungskommission: []
        * Mitglied weitere Gemeindekommissionen: []
        * Merkmal: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Praesidium
        * Präsident: [:contact_data]
        * Vizepräsident: []
        * Kassier: [:finance]
        * Mitglied: []
        * Adressverwalter: [:layer_and_below_full]
        * Gast: []
        * Merkmal: []
      * Sekretariat
        * Leitung: [:layer_full]
        * Mitarbeiter: [:layer_full]
        * Webadministrator: []
        * Merkmal: []
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
        * Merkmal: []
      * Mitglieder
        * Mitglied: []
        * Merkmal: []
      * Sympathisanten
        * Sympathisant: []
        * Merkmal: []
    * Vereinigung
      * Vereinigung
        * Merkmal: []
      * Gewählte
        * Fraktionschef: []
        * Vereinigung Exekutive: []
        * Vereinigung Legislative: []
        * Merkmal: []
      * Parteigremium
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Praesidium
        * Präsident: [:contact_data]
        * Vizepräsident: []
        * Kassier: [:finance]
        * Mitglied: []
        * Merkmal: []
      * Sekretariat
        * Leitung: [:layer_and_below_full, :contact_data, :finance]
        * Mitarbeiter: [:layer_and_below_full]
        * Webadministrator: []
        * Merkmal: []
      * Kommission
        * Präsident: []
        * Mitglied: []
        * Merkmal: []
      * Arbeitsgruppe
        * Präsident: []
        * Leitung: [:group_full]
        * Mitglied: [:group_read]
        * Gast: []
        * Merkmal: []
      * Externe Kontakte
        * Medien: []
        * Spender: []
        * Kontakt: []
        * Merkmal: []
      * Mitglieder
        * Mitglieder: []
        * Merkmal: []
      * Sympathisanten
        * Sympathisant: []
        * Merkmal: []
      * Delegierte
        * Delegierte: []
        * Ersatzdelegierte: []
        * Delegierte von Amtes wegen: []
        * Merkmal: []

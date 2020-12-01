# Kantonalverbände

### Adressverwalter auf Ebene Region (ag, sg)
- <RegionPraesidium Partei [Praesident 3, tbd:Zuzüger 7], id:755, 336>

$ > grep Region structure/*detail* | grep Zuz

### Delegierte im Ort
$> grep Ort structure/*detail* | grep DV
structure/be_detail.txt:   <OrtArbeitsgruppe DV Bezirk [tbd:Delegierter 1], id:2637, 363>
structure/be_detail.txt:   <OrtArbeitsgruppe DV Bezirk [tbd:Delegierter 1], id:2635, 361>
structure/lu_detail.txt:   <KantonArbeitsgruppe DV Kt. Luzern [tbd:Delegierter Ortspartei 589, tbd:Delegierter Vereinigung 70, tbd:Delegierter von Amtes wegen 332], id:1494, 502>

### Mitglieder in der Region (Solothurn)

 {migrate-data} hitobito_cvp$ grep Mitgliedschaften structure/so.txt  | grep
Region
   <RegionArbeitsgruppe id=34743, label=Mitgliedschaften, parent_id=552>
   <RegionArbeitsgruppe id=1695, label=Mitgliedschaften, parent_id=553>
   <RegionArbeitsgruppe id=1711, label=Mitgliedschaften, parent_id=554>
   <RegionArbeitsgruppe id=34742, label=Mitgliedschaften, parent_id=555>
   <RegionArbeitsgruppe id=1739, label=Mitgliedschaften, parent_id=556>


## Vereinigungen

### Delegierte in Vereinigung

<Bund CVP Schweiz, id:1, 0>
  <VereinigungArbeitsgruppe Delegiertenversammlung [tbd:Delegierter 2], id:234, 2>

<Bund CVP Schweiz, id:1, 0>
 <Vereinigung CVP Frauen, id:3, 1>
  <VereinigungArbeitsgruppe Delegierte CVP Frauen Schweiz, id:39714, 3>
   <VereinigungArbeitsgruppe BL [tbd:Delegierte 1], id:39780, 39714>


### Rollen im Layer (Vereinigung JCVP)

<Bund CVP Schweiz, id:1, 0>
 <Vereinigung JCVP, id:2, 1>
  <VereinigungArbeitsgruppe Delegiertenversammlung [tbd:Delegierter 2], id:234, 2>
  <Kanton JCVP AI [tbd:Kontakt 1], id:237, 2>

 <Vereinigung CVP Frauen, id:3, 1>
  <Kanton AI [tbd:Präsident 1], id:14609, 3>







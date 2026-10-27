# Étude d'architecture

À utiliser en arrivant sur un repo inconnu, ou avant un ticket non trivial, pour poser une carte du
système **à partir du code réel** avant d'entrer dans `start-ticket`. Plan tiré de deux études
réalisées ainsi sur des services réels (une API de recherche, un service de classification par LLM) —
les sections qui ont servi ensuite à chaque ticket, pas un modèle théorique.

```
Réalise une étude d'architecture de ce dépôt, à partir d'une lecture du code source (pas de
la doc seule : la doc peut avoir dérivé, le code fait foi). Dépose-la dans <chemin, ex.
.claude/architecture.md — local, non versionné> . Ne modifie aucun autre fichier.

Plan :
1. Vue d'ensemble — rôle du service, pour qui, tableau des endpoints/points d'entrée et de la
   nature du traitement derrière chacun.
2. Stack technique — langage, framework, dépendances structurantes, avec leur version quand
   elle contraint quelque chose.
3. Découpage du code — arborescence commentée (une ligne par dossier/fichier clé), composition
   root / wiring, cycle de vie (démarrage, arrêt, tâches planifiées).
4. Modèle de données — tables/collections, clés, ce qui est en lecture seule.
5. Flux critique de bout en bout — un exemple réel, appel par appel (fichier.fonction), avec un
   diagramme de séquence Mermaid si le flux traverse plus de 3 composants.
6. Configuration et environnements — variables, profils, ce qui diffère entre local et déployé.
7. Points d'attention / dette — tableau Sujet | Constat (avec fichier:ligne) | Impact. Distinguer
   ce qui est vérifié de ce qui est supposé ("à confirmer avec <qui>").
8. Hors périmètre — ce que ce dépôt ne fait pas et où ça vit, pour ne pas le chercher ici.
9. Synthèse — quelques lignes : style d'architecture, choix bien pensés, zones de vigilance.

Termine par un "Journal de session" daté : demande, ce qui a été lu, ce qui a été créé/modifié.
Lecture ciblée : arrête d'explorer une zone dès que la section correspondante peut être écrite.
```

## Pourquoi

- **Code plutôt que doc** : une étude recopiée du README hérite de ses dérives ; une étude lue dans
  le code les révèle (OpenAPI maintenue à la main qui ne colle plus aux routes, intégration
  déclarée mais commentée, endpoint "privé" sans authentification visible).
- **`fichier:ligne` dans les points d'attention** : un constat vérifiable se transforme en ticket,
  un constat vague ("la gestion des sessions semble fragile") non.
- **"Hors périmètre"** évite de chercher dans ce repo ce qui vit dans un autre — la question revient
  à chaque ticket transverse.
- **Journal de session** : l'étude s'enrichit au fil des sessions (ajout d'un schéma, d'une section)
  sans perdre la trace de ce qui a été vérifié quand.
- **Local, non versionné par défaut** : l'étude contient des jugements ("dette", "fragile") qui
  n'ont pas forcément leur place dans le repo partagé. Ce qui mérite d'être partagé est promu
  ensuite dans `docs/architecture/overview.md` (voir [`../rules/docs-structure.md`](../rules/docs-structure.md)).

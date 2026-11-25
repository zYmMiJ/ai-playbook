# Conventions générales

Principes indépendants d'une stack, à piocher pour amorcer le `CLAUDE.md`/`.cursorrules`/etc. d'un
projet. Ce qui est spécifique à un framework va dans le repo du projet, pas ici.

## Style

- Le code généré doit lire comme le code existant autour : même densité de commentaires, mêmes
  conventions de nommage, même idiome. Ne pas imposer un style "par défaut" de l'IA sur un repo qui
  en a déjà un.
- Un commentaire explique le **pourquoi** (contrainte, décision, piège évité), pas le **quoi** —
  le code dit déjà le quoi.

## CSS

- Le choix d'une unité CSS (`rem`, `px`, `%`, `fr`, `vh`/`vw`, `em`, variable CSS) n'est pas une
  question de style : chaque unité répond à "relatif à quoi ?" (zoom texte, parent, viewport…).
  Détail et cas d'usage : [`css-units.md`](css-units.md).
- Ne convertir que les valeurs touchées par la tâche en cours, pas tout le fichier/composant au
  passage — même logique que "ne pas élargir le scope d'une demande" ci-dessous.

## Changements

- Ne pas élargir le scope d'une demande sans le dire. Une correction ponctuelle reste ponctuelle
  sauf accord explicite pour un refactor plus large.
- Sur un refactor multi-fichiers, poser un critère de succès vérifiable avant d'éditer (voir
  [`../prompts/refactor-review.md`](../prompts/refactor-review.md)).
- Ne jamais committer/pousser sans demande explicite pour ce tour précis — une autorisation donnée
  une fois ne vaut pas pour la suite de la session. Pour que ce soit garanti et pas seulement
  suivi : règle `ask`/`deny` dans les settings (voir [`permissions.md`](permissions.md)).
- Sur un traitement par lot (migration, génération, comparaison sur N entités), le lancer d'abord
  sur **un seul élément** et vérifier le résultat contre un chiffre déjà connu avant de relancer
  sur tout le lot — un changement correct en théorie (clé mal normalisée, collation insensible à la
  casse) produit des écarts silencieux qui ne se voient qu'à la comparaison.

## Qui possède quoi

Écrire dans le `CLAUDE.md` du projet, pour chaque fichier/dossier qui n'est pas du code ordinaire :

- **Généré** (par quel script) → ne jamais l'éditer à la main, modifier le générateur — sinon
  perdu au prochain run.
- **Rempli par l'utilisateur** (ex. une colonne de statut dans un registre) → jamais par un script
  ni par l'IA, même "pour aider".
- **Archive figée** (ancienne implémentation gardée comme filet de rollback) → ne pas la modifier ;
  un besoin qui semble la concerner concerne en fait son remplaçant.

Sans cette carte, une session corrige au plus court : le fichier sous les yeux, pas sa source.

## Revue

- Un travail est fini quand un check exécutable passe et que sa sortie a été montrée, pas quand il
  en a l'air (voir [`verification.md`](verification.md)).
- Un `lint` qui passe ne veut pas dire "sans defaut" — vérifier ce que le linter du projet ignore
  explicitement (règles désactivées) avant de s'y fier.
- Un test qui passe ne prouve la correction que de ce qu'il couvre — vérifier la couverture réelle
  avant de présumer qu'un changement est testé.
- Dire explicitement ce qui **n'a pas été vérifié** — surtout quand rien n'est testable localement
  (config de production, déploiement, infra) : préciser ce qui a été validé (ex. syntaxe seule via
  `docker compose config`, `sh -n`) et ce qui reste à vérifier en conditions réelles, plutôt que
  laisser croire à un changement "testé".

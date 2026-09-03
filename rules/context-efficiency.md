# Efficacité de contexte

Principes pour limiter la consommation de tokens (input comme output) d'une session Claude
Code, indépendants d'une stack — comme [`general-coding.md`](general-coding.md), à piocher pour
amorcer un `CLAUDE.md`. Le contexte est une ressource finie et partagée sur toute la session : ce
qui est lu/produit en trop sur une tâche réduit la marge disponible pour la suite, pas seulement
le coût de la requête en cours.

## Lecture de fichiers

- Ne pas lire un fichier entier "au cas où" — localiser d'abord avec `Grep` (qui donne les numéros
  de ligne), puis ne lire que la portion utile (`offset`/`limit`) plutôt que le fichier complet.
- Ne pas relire un fichier qu'on vient soi-même d'éditer pour vérifier le résultat — un échec
  d'édition remonte déjà comme erreur ; relire "pour être sûr" consomme des tokens sans nouvelle
  information.
- Sur un doute de contenu (fichier binaire, généré, très volumineux), vérifier sa taille/nature
  avant de le lire en entier plutôt que découvrir le problème après coup.

## Recherche

- Outils de recherche dédiés (`Grep`/`Glob`) plutôt qu'une commande shell générique
  (`find` + `grep -r` sur tout le repo) — plus rapide et surtout, sortie déjà filtrée au lieu d'un
  flot brut à trier après lecture.
- Cibler la recherche (dossier, extension, motif précis) dès que la zone concernée est connue,
  plutôt que scanner tout le repo par défaut.
- **Exploration minimale** : s'arrêter dès qu'il y a assez d'éléments pour agir — ne pas
  cartographier tout un module/repo "pour être complet" quand la tâche ne touche qu'un
  fichier/une fonction. Une inconnue précise se résout par une recherche ciblée le moment venu,
  pas par une exploration préalable exhaustive "au cas où".

## Sous-agents

- Ne pas déléguer à un agent ce qui peut se faire directement dans la conversation en cours : un
  nouvel agent démarre à froid et doit re-dériver un contexte déjà disponible ici, ce qui coûte
  plus de tokens au total, pas moins.
- Réserver un sous-agent à un vrai besoin (parallélisation de recherches indépendantes, isolation
  d'un travail volumineux/risqué, ou demande explicite de l'utilisateur) — pas comme raccourci par
  défaut pour "déporter" une tâche.
- Un fork hérite de tout le contexte de la conversation courante : utile pour continuer en
  parallèle sans le reconstruire, mais aussi coûteux à l'ouverture qu'une longue conversation déjà
  en cours.

## Tests

- **Tests ciblés avant tests complets** : après une modification, lancer d'abord les tests qui
  couvrent les fichiers touchés (nom du test/module, filtre `-k`/équivalent selon l'outil) — pas
  la suite complète à chaque itération. Réserver la suite complète à la validation finale, avant
  de considérer le travail terminé.

## Découpage de session

- Sur une tâche longue à plusieurs étapes (ex. un ticket : analyse → implémentation → review),
  faire un `/clear` entre chaque étape plutôt que de laisser une seule conversation accumuler le
  contexte des trois. Ce qui doit survivre au `/clear` passe par un artefact écrit (plan, notes de
  ticket), pas par l'historique de conversation — voir par exemple le skill
  [`start-ticket`](../skills/start-ticket/SKILL.md), dont `tickets/<ID>/plan.md` sert justement de
  relais entre phases.

## Outils shell

- Éviter `cat`/`head`/`tail`/`sed`/`echo` en `Bash` quand `Read`/`Edit`/`Grep` couvrent le besoin —
  sortie brute non filtrée, sans les garde-fous (numérotation, plage de lignes, correspondance
  exacte) des outils dédiés.
- Grouper dans un seul message les appels d'outils indépendants (pas de dépendance entre eux)
  plutôt que les envoyer un par un — évite les allers-retours superflus.

## Web

- `WebFetch`/recherche web ciblés sur la question posée, pas une page entière récupérée "pour
  contexte" si un extrait suffit ; éviter les requêtes répétées sur la même ressource dans une
  même session.

## Mémoire et documentation projet

- `CLAUDE.md` et les rules qu'il référence doivent rester courts et actionnables — chargés au
  début de chaque session, leur taille pèse sur toute la conversation qui suit. Un point détaillé
  va dans un fichier séparé, lié depuis `CLAUDE.md`, pas recopié dedans (voir
  [`docs-structure.md`](docs-structure.md)).
- Ne pas dupliquer dans la mémoire ce que le repo ou l'historique Git retracent déjà (voir
  `MEMORY.md` du profil) — une info reconstructible à la demande n'a pas besoin d'être stockée.

## Sortie

- Réponses concises : ne pas reciter un diff, un plan ou un fichier déjà visible à l'écran juste
  après l'avoir produit.
- Pas de sous-titres/tableaux récapitulatifs pour une réponse courte à question simple — la
  structuration a un coût, à réserver à ce qui la justifie (revue multi-fichiers, plan à
  plusieurs étapes).

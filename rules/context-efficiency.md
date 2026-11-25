# Efficacité de contexte

Principes pour limiter la consommation de tokens (input comme output) d'une session Claude
Code, indépendants d'une stack — comme [`general-coding.md`](general-coding.md), à piocher pour
amorcer un `CLAUDE.md`. Avec une fenêtre d'1M de tokens et une compaction automatique, manquer de
place est devenu rare ; ce qui reste vrai, c'est que **chaque tour renvoie toute la conversation**
(ce qui est lu/produit en trop est repayé à chaque requête suivante) et qu'un contexte focalisé
donne de meilleures réponses. Quand ouvrir/vider/reprendre une session :
[`session-management.md`](session-management.md).

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

- **Le critère, c'est le volume lu, pas le coût de démarrage** : un sous-agent se justifie quand la
  tâche ferait entrer dans le contexte principal beaucoup de contenu qui ne resservira pas —
  exploration large (des dizaines de fichiers lus pour une conclusion de dix lignes), suite de
  tests ou logs verbeux. Lui demander un résumé court en retour, sinon le gain disparaît.
- À l'inverse, lire directement quelques fichiers qu'on va éditer ensuite : un nouvel agent
  démarre à froid, re-dérive un contexte déjà disponible ici, et coûte plus de tokens (parfois plus
  de temps) au total.
- Les recherches larges partent déjà d'elles-mêmes dans l'agent intégré `Explore` : inutile de le
  demander. Un sous-agent ne donne pas une meilleure réponse (même modèle, même tâche) — seuls un
  relecteur qui n'a pas vu l'écriture du code (voir [`verification.md`](verification.md)), la
  parallélisation de travaux indépendants ou un jeu d'outils restreint apportent quelque chose.
- Un fork hérite de tout le contexte de la conversation courante : utile pour continuer en
  parallèle sans le reconstruire, mais aussi coûteux à l'ouverture qu'une longue conversation déjà
  en cours.

## Tests

- **Tests ciblés avant tests complets** : après une modification, lancer d'abord les tests qui
  couvrent les fichiers touchés (nom du test/module, filtre `-k`/équivalent selon l'outil) — pas
  la suite complète à chaque itération. Les lancer en arrière-plan : la session continue, et seule
  la sortie utile (échecs) revient dans le contexte. Réserver la suite complète à la validation finale, avant
  de considérer le travail terminé.

## Découpage de session

- `/clear` entre tâches sans rapport et entre étapes d'une tâche longue, relais par un artefact
  écrit : détail dans [`session-management.md`](session-management.md).

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
  [`docs-structure.md`](docs-structure.md)). Viser moins de 200 lignes.
- Test pour chaque ligne : *Claude le trouverait-il en lisant le code, et irait-il vraiment
  voir ?* Si oui aux deux, la ligne sort. Une procédure (release, runbook) va dans un skill, chargé
  seulement quand la tâche l'appelle ; une règle sans exception va dans un hook ou une deny rule
  (voir [`hooks.md`](hooks.md), [`permissions.md`](permissions.md)).
- Pas d'emphase (`IMPORTANT`, majuscules) pour une ligne ignorée : soit le fichier est trop long et
  la ligne s'y perd, soit c'est une règle sans exception qui relève d'un hook — l'emphase pousse
  surtout à sur-appliquer la règle.
- `/doctor` propose des coupes (ce que Claude peut déduire du code) ; `/doctor prompt-audit`
  (v2.1.283+) signale les consignes contradictoires, écrites pour d'anciens modèles ou pointant
  vers des fichiers disparus ; `/context all` confirme ce qui a été chargé (doc officielle
  `best-practices`, vérifiée le 2026-11-26).
- Ne pas dupliquer dans la mémoire ce que le repo ou l'historique Git retracent déjà (voir
  `MEMORY.md` du profil) — une info reconstructible à la demande n'a pas besoin d'être stockée.

## Ce que le modèle voit

- La qualité du résultat dépend davantage de ce qui est dans le contexte que de la formulation du
  prompt. Deux familles : **déterministe** (hooks, deny rules, managed settings — appliqués par le
  harness, toujours) et **indicatif** (prompt, `CLAUDE.md`, skills — Claude peut juger qu'une
  consigne ne s'applique pas). Ce qui ne doit jamais plier va dans la première.
- Un contexte abîmé se nettoie, il ne se corrige pas. Quatre façons dont il se dégrade (taxonomie
  externe, non officielle Claude Code : [« How Long Contexts Fail »](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html),
  Drew Breunig, 2025), avec la parade Claude Code de chacune :

  | Défaillance | Ce qui se passe | Parade |
  |---|---|---|
  | **Poisoning** (empoisonnement) | Une erreur ou une hallucination entre dans le contexte et y est reprise ensuite comme un fait. | `/rewind` avant l'erreur, ou `/clear` + meilleur prompt après deux corrections ratées. |
  | **Distraction** | Le contexte devient si long que le modèle s'appuie sur l'historique plutôt que sur ce qu'il sait faire, et répète ce qu'il a déjà tenté. | `/clear` entre tâches, sous-agent pour ce qui est volumineux, `/compact <focus>`. |
  | **Confusion** | Du contenu superflu (outils inutiles, consignes hors sujet) influence la réponse. | Désactiver les serveurs MCP inutiles (voir [`mcp.md`](mcp.md)), `CLAUDE.md` court, rules scopées par `paths:`. |
  | **Clash** (conflit) | Deux parties du contexte se contredisent (consigne vs rule, tentative ancienne vs nouvelle info). | `/doctor prompt-audit` pour les consignes, nouvelle session à partir d'un `SPEC.md` pour un historique contradictoire. |

## Sortie

- Réponses concises : ne pas reciter un diff, un plan ou un fichier déjà visible à l'écran juste
  après l'avoir produit.
- Pas de sous-titres/tableaux récapitulatifs pour une réponse courte à question simple — la
  structuration a un coût, à réserver à ce qui la justifie (revue multi-fichiers, plan à
  plusieurs étapes).

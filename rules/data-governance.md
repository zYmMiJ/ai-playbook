# Gouvernance des données réelles

À piocher pour le `CLAUDE.md` d'un projet qui a accès à des **données réelles** (dump de base de
production, base legacy en lecture, export métier) : personnes, entreprises, adresses, identifiants
officiels. Règle retrouvée à l'identique sur plusieurs projets réels (outil de vérification de
migration, outil de rapprochement, analyse d'une base legacy) — à écrire explicitement, une
session ne la devine pas : par défaut, Claude affiche volontiers "quelques lignes pour voir".

## Le principe

**Agrégats par défaut, jamais de valeurs individuelles** — sauf demande explicite de l'utilisateur
*pour la tâche en cours* (une autorisation donnée une fois ne vaut pas pour la suite de la session,
même logique que pour un commit, voir [`general-coding.md`](general-coding.md)).

Toujours autorisé, sans demande :

- le schéma/la structure (DDL, colonnes, index, vues, `information_schema`) ;
- les comptages, taux, volumétries, distributions (`COUNT`, `GROUP BY`) ;
- les données synthétiques des tests ;
- les sorties déjà agrégées produites par l'outil lui-même (rapport, profilage).

Interdit sans demande explicite : `SELECT *` ou "exemples de lignes pour voir", lecture/affichage
du contenu d'un dump, d'un CSV de résultats ou d'un fichier livrable contenant des valeurs réelles.

## Là où ça fuit sans qu'on y pense

- **Les outils de contrôle qui échantillonnent par défaut** — ex. un check de qualité de données
  qui affiche les lignes en échec : forcer l'option qui désactive l'échantillon (ex.
  `samples limit: 0` sur Soda) et dire dans le `CLAUDE.md` de **ne pas la retirer** en générant un
  nouveau check.
- **Les artifacts/pages publiés** — jamais d'artifact (ou de doc partagée, de capture, de PR)
  contenant une valeur réelle (identifiant officiel, adresse, nom, enseigne). Un artifact se partage
  et se met en cache, une sortie de terminal non.
- **Les messages d'erreur et logs de test** — une assertion qui échoue sur une vraie ligne affiche
  la vraie ligne.
- **Les requêtes et commentaires écrits pour l'occasion** — sans référence à un cas réel identifiable
  (ni valeur, ni numéro de ticket qui le désigne).

## Le faire appliquer

- Un agent dédié à l'exploration de la base tourne **en lecture seule** (`permissionMode: plan`) :
  il propose les requêtes et le plan de rapport, l'écriture se fait après validation — gabarit :
  [`../agents/database-analyst.md`](../agents/database-analyst.md).
- Les rapports produits (même agrégés) atterrissent dans un dossier **jamais commité** (exclu via
  `.git/info/exclude` ou `.gitignore`), convenu une fois avec l'utilisateur et écrit dans le
  `CLAUDE.md`.
- La règle complète (qui a autorisé quoi, pour quel périmètre) peut vivre dans un document de
  gouvernance du projet (ex. `docs/gouvernance/`) — le `CLAUDE.md` n'en garde que le résumé
  ci-dessus et le lien.

---
name: generate-release-note
description: >
  Génère les notes de release entre deux tags/commits, groupées par type conventionnel avec
  référence de ticket, et les écrit dans un fichier local. Se déclenche pour "génère les notes de
  release", "écris le changelog de la version X", "notes de release depuis le dernier tag" — après
  qu'une release taguée a été validée en environnement, jamais avant.
---

# Générer les notes de release

> **À adapter par projet** en copiant ce skill : l'emplacement du fichier de sortie (`docs/`,
> `CHANGELOG.md`, GitHub Releases...), le fait que cet emplacement soit trackée par Git ou non, et
> la convention de préfixe de commit (`type(scope): résumé`, `type: résumé`, sans convention...)
> sont spécifiques à chaque repo. Un exemple concret d'instanciation est donné en bas de fichier.

Complète le skill [`release`](../release/SKILL.md) : à lancer seulement une fois qu'une release
taguée a été **validée en environnement** par l'utilisateur (pas juste taguée/pushée) — pas avant,
pas automatiquement à la suite d'un tag.

## Portée par défaut : fichier local, rien de publié

Sauf demande explicite contraire, ce skill se limite à **écrire un fichier**, jamais à le diffuser.
Ne jamais enchaîner de soi-même sur `gh release create`, un post Slack, un e-mail, ou toute autre
publication — uniquement écrire le fichier (et un éventuel tableau récapitulatif s'il existe déjà
sur le repo), puis donner le résultat à relire à l'utilisateur. Étendre à une publication
partagée/automatique est un changement de périmètre à valider explicitement avec l'utilisateur, pas
à déduire de cette étape.

Si l'emplacement de sortie n'est pas trackée par Git sur ce repo (`.gitignore`/
`.git/info/exclude`), le signaler explicitement : le fichier reste local à ce poste, pas partagé
avec l'équipe, même une fois écrit.

## Démarche

### 1. Lister les commits depuis le dernier tag

```bash
git log <dernier-tag>..<hash-cible> --no-merges --oneline   # ex: git log 1.4.0..a1b2c3d --no-merges --oneline
```

`<hash-cible>` = le commit qui vient d'être taggé (voir skill `release`, étape 1).

### 2. Filtrer et grouper

Filtrer les commits de bump de version pur (souvent marqués `[no ci]` ou équivalent — aucun intérêt
en changelog), puis regrouper le reste par type conventionnel (`feat`, `fix`, `refactor`, `build`,
`chore`, `docs`, `test`...) si le repo suit déjà ce genre de préfixe (vérifier `git log --oneline
-20` plutôt que de le supposer) :

```markdown
## X.Y.Z — <date du jour>

### Fonctionnalités
- (<TICKET-ID>) résumé du commit `feat(<TICKET-ID>): ...`

### Corrections
- (<TICKET-ID>) résumé du commit `fix(<TICKET-ID>): ...`

### Autres
- résumé des `refactor`/`build`/`chore`/... restants
```

Si le repo n'a pas de convention de préfixe de commit exploitable, regrouper par ordre chronologique
avec le message de commit tel quel plutôt que d'inventer une catégorisation.

Le `scope` du commit (ex. `<TICKET-ID>` entre parenthèses) donne le numéro de ticket à citer — c'est
un changelog, pas un commentaire de code, donc une éventuelle règle projet "pas de référence à un
ticket dans les commentaires" ne s'y applique pas.

### 3. Écrire le résultat

Écrire dans le fichier de sortie du projet, et mettre à jour un éventuel tableau récapitulatif
(version, date, résumé en une phrase) s'il existe déjà. **Ne pas inventer d'entrée** : un commit
sans préfixe conventionnel clair va dans "Autres" (ou en liste brute, cf. ci-dessus) tel quel plutôt
que d'être reformulé à la devinette.

## Règles

- Jamais avant que l'utilisateur ait confirmé la release validée en environnement.
- Jamais de publication (release GitHub/GitLab, post, e-mail) sans demande explicite — uniquement le
  fichier local, sauf portée élargie validée par l'utilisateur.
- Pas de commit sans demande explicite pour ce tour (même règle générale que le reste du repo, voir
  [`../../rules/general-coding.md`](../../rules/general-coding.md)).

---

## Exemple d'instanciation

Exemple générique d'adaptation : sortie dans `docs/releases/X.Y.Z.md` + ligne ajoutée à
`docs/releases/README.md`. Si `docs/` n'est pas trackée par Git sur le repo concerné (à vérifier via
`.gitignore`/`.git/info/exclude`), le fichier reste local au poste même une fois écrit, pas partagé
avec l'équipe tant que ça n'a pas été explicitement changé.

# Unités CSS/SCSS : quand utiliser quoi

Chaque unité CSS répond à une question différente ("relatif à quoi ?"). Le choix n'est pas une
question de style, c'est une question de ce à quoi la valeur doit réagir (zoom texte, taille du
parent, taille de la fenêtre…).

> Avant d'appliquer ce qui suit à un projet donné, vérifier deux points sur ce projet précis
> (grep rapide) plutôt que de supposer :
> 1. Est-ce que `font-size` est redéfini sur `html`/`body` dans les styles globaux ? Sinon, la base
>    est celle du navigateur (`1rem = 16px` par défaut) — c'est cette base qui sert de référence
>    pour toute conversion `px → rem`.
> 2. Comment les breakpoints de media query sont déjà définis (`px` ou `em`) — s'aligner sur
>    l'existant plutôt que d'imposer un choix différent composant par composant.

## Vue d'ensemble

| Unité | Relatif à | Cas d'usage typique |
|---|---|---|
| `rem` | `font-size` de `<html>` (fixe, sauf zoom navigateur) | `font-size`, `padding`/`margin`/`gap`, dimensions de contenu (icônes, cartes) — le défaut pour le texte et l'espacement |
| `px` | rien (unité physique fixe) | bordures fines, valeurs arbitraires, breakpoints (si convention déjà en place) |
| `%` | dimension du parent | largeur/hauteur fluide dans un conteneur flex/grid |
| `fr` | espace disponible dans une grille | `grid-template-columns`/`rows` |
| `vh` / `vw` | dimension du viewport | conteneur plein écran (structure de page racine) |
| unitless (`line-height: 1.5`) | `font-size` de l'élément lui-même, propagé en ratio | interlignage |
| `em` | `font-size` de l'élément (cascade avec les enfants) | scaling local délibéré (ex. padding d'icône suivant la police du bouton parent) — à utiliser avec prudence |
| variable CSS (`var(--x)`) | valeur définie sur `:root` ou un ancêtre | tokens partagés (largeurs de champ, padding de modale) |

## `rem` — la valeur par défaut pour le texte et l'espacement

- Relatif à la `font-size` de `<html>`, donc au réglage d'accessibilité du navigateur/OS de
  l'utilisateur. Un `padding`/`font-size` en `rem` s'agrandit avec ce réglage ; en `px`, il reste
  figé.
- À utiliser par défaut pour : `font-size`, `padding`, `margin`, `gap`, largeurs/hauteurs de
  contenu (icônes, cartes, avatars), `min-width`/`max-width`.
- Conversion : `rem = px / 16` **si** la base `html` n'est pas redéfinie sur le projet (voir
  vérification en tête de document) — sinon utiliser la vraie base.
- C'est pour ça qu'un retour de review du type *« convertir les px en rem pour une question de
  responsive »* est fondé : ce n'est pas une question de style, c'est une question
  d'accessibilité/adaptabilité réelle.

## `px` — pour ce qui ne doit pas suivre le zoom texte

Garder `px` n'est pas une erreur dans ces cas précis — c'est même la bonne pratique :

1. **Bordures fines (`1px`, `2px`)** — une bordure de séparation visuelle n'a pas vocation à
   grossir avec le texte ; en `rem`, un `1px` peut devenir flou (rendu sub-pixel) selon le zoom.
2. **Valeurs arbitraires "assez grandes pour X", sans rapport avec une mesure réelle** — ex.
   `border-radius: 999px` pour forcer une forme en pilule/cercle quelle que soit la taille de
   l'élément. Ce n'est pas une mesure, donc la convertir en `rem` n'apporte rien
   (`999px → 62.4375rem` n'a aucun sens).
3. **`box-shadow` / `outline-offset`** — décalages d'ombre ou de contour, effets visuels fins, pas
   du texte ni de l'espacement de mise en page.
4. **Breakpoints de media query** — si le projet définit déjà ses breakpoints en `px`, rester
   cohérent dans les `@media (max-width: …)` plutôt que de mélanger les unités composant par
   composant.
   > Note : certains guides recommandent `em` pour les breakpoints (bug de zoom historique sur
   > Safari avec `rem`). C'est un choix à faire une fois pour tout le projet (fichier de variables
   > de breakpoints), pas à rouvrir localement dans un composant.

## `%` — dimension fluide relative au parent

Utile pour qu'un élément remplisse son conteneur flex/grid (`width: 100%`) ou pour un token
partagé.

- Adapté pour : largeur/hauteur qui doit suivre la taille du parent, pas une mesure fixe.
- Piège : un `%` sur `padding`/`margin` se calcule par rapport à la **largeur** du parent (même
  pour `padding-top`/`bottom`) — surprenant si on s'attend à un rapport avec la hauteur. Éviter
  `%` pour l'espacement ; `rem`/`px` couvrent déjà ce besoin (voir plus haut).

## `fr` — répartition d'espace dans une grille CSS

`1fr` = "une part de l'espace restant après les tracks de taille fixe". Toujours combiner avec
`minmax(0, 1fr)` plutôt que `1fr` seul dans une grille avec du contenu qui peut déborder (texte
long, tableau) — `minmax(0, …)` évite qu'une colonne grid force la grille entière à s'élargir
au-delà de son conteneur.

## `vh` / `vw` — dimension relative au viewport

Usage légitime : dimensionner un conteneur plein écran (structure de page racine, genre
`min-height: 100vh` sur un shell) — mais à réserver à ce genre de cas, pas à des composants
internes (un `vh` dans un composant imbriqué ne veut plus dire grand-chose et casse dès qu'il est
réutilisé ailleurs dans la page).

> Piège connu : sur mobile, `100vh` inclut la barre d'adresse rétractable de certains navigateurs,
> ce qui peut faire déborder le contenu de l'écran visible. `100dvh` (dynamic viewport height)
> corrige ça mais nécessite de vérifier le support navigateur ciblé par le projet avant de
> l'introduire.

## `line-height` sans unité — la bonne pratique

Une valeur sans unité (`line-height: 1.5`) est un **ratio** de la `font-size` de l'élément
lui-même, qui se recalcule correctement si un enfant a une `font-size` différente. Une valeur en
`px`/`em` sur `line-height` se propage telle quelle aux enfants et peut donner un interlignage
incohérent si un enfant a une police plus grande/petite que le parent.

## `em` — à utiliser avec prudence, pas la valeur par défaut

`em` est relatif à la `font-size` de l'élément **courant**, et se cumule à travers les
imbrications (`padding: 1em` sur un élément avec `font-size: 1.2em` en hérite déjà, donc le
padding réel est `1em × 1.2 × …` en remontant l'arbre). Utile uniquement quand on veut
*délibérément* qu'une valeur scale avec la taille locale d'un composant (ex. un padding d'icône
qui doit suivre la taille de police du bouton qui la contient) — pas un remplacement générique de
`rem`. En cas de doute, utiliser `rem`.

## Variables CSS (`var(--x)`) — tokens partagés

Pour une valeur réutilisée à plusieurs endroits (pas une valeur locale à un seul composant),
préférer une variable existante définie sur `:root` (ou en ajouter une) plutôt que de dupliquer la
valeur brute dans chaque fichier de styles.

## Ce qu'il ne faut pas faire

- Ne pas convertir "bêtement" toutes les valeurs `px` en `rem` sans réfléchir aux bordures/valeurs
  arbitraires.
- Ne pas mélanger les unités pour la même propriété au sein d'un même composant sans raison (ex.
  deux `padding` d'un même bloc, l'un en `px`, l'autre en `rem`).
- Ne pas utiliser `%`/`vh`/`vw` pour de l'espacement (`padding`/`margin`) quand `rem` suffit — ces
  unités répondent à "relatif à quoi ?", pas "petit ou grand ?".
- Ne pas introduire `em` par réflexe : sans besoin explicite de cascade locale, `rem` évite l'effet
  de cumul.

## Exemple concret (avant / après)

```scss
// Avant
:host {
  padding: 24px;
}
.card__icon {
  width: 48px;
  height: 48px;
}
.chip {
  border: 1px solid $border-color; // ✅ reste en px : bordure fine
  border-radius: 999px;            // ✅ reste en px : valeur arbitraire
  padding: 6px 16px;
  font-size: 13px;
}

// Après
:host {
  padding: 1.5rem;
}
.card__icon {
  width: 3rem;
  height: 3rem;
}
.chip {
  border: 1px solid $border-color;
  border-radius: 999px;
  padding: 0.375rem 1rem;
  font-size: 0.8125rem;
}
```

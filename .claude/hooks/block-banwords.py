#!/usr/bin/env python3
"""PreToolUse (Write|Edit) : bloque l'écriture d'un ban word (client/projet réel, ou tout autre
terme listé) dans ce repo.

Applique la règle "Écrire dans ce repo" du README.md ("pas de nom de client/projet réel — exemple
générique à la place") de façon garantie, y compris sur demande explicite de l'utilisateur — un
hook s'exécute toujours, contrairement à une règle suivie "en général" (voir rules/hooks.md).

La liste elle-même (banwords.local.txt) contient potentiellement de vrais noms de client/projet et
n'est donc jamais commitée (voir .gitignore) : ce script ne fonctionne qu'avec un fichier local
propre au poste, alimenté au fil de l'eau.
"""
import json
import os
import re
import sys


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    tool_input = data.get("tool_input") or {}
    file_path = (tool_input.get("file_path") or "").replace(os.sep, "/")

    if "/.claude/" in f"/{file_path}" or "/.git/" in f"/{file_path}":
        return 0

    content = tool_input.get("content") or tool_input.get("new_string") or ""
    if not content:
        return 0

    blocklist_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "banwords.local.txt")
    try:
        with open(blocklist_path, encoding="utf-8") as f:
            patterns = [line.strip() for line in f if line.strip() and not line.strip().startswith("#")]
    except FileNotFoundError:
        sys.stderr.write(
            "Note : .claude/hooks/banwords.local.txt absent, aucun ban word vérifié pour cette "
            "écriture (fichier local, jamais commité — voir .gitignore).\n"
        )
        return 0

    hits = [p for p in patterns if re.search(rf"\b{re.escape(p)}\b", content, re.IGNORECASE)]
    if not hits:
        return 0

    sys.stderr.write(
        f"Écriture bloquée dans {file_path} : ban word détecté ({', '.join(hits)}).\n"
        "Règle du repo (README.md > \"Écrire dans ce repo\") : pas de nom de client/projet réel ni "
        "de ban word générique, même sur demande explicite — généraliser l'exemple à la place.\n"
        "Pour étendre volontairement la liste elle-même : éditer "
        ".claude/hooks/banwords.local.txt (hors périmètre de ce contrôle).\n"
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())

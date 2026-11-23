#!/usr/bin/env bash
# Находит Deployment/StatefulSet/DaemonSet, у которых есть поды с sidecar не новой ревизии Istio,
# и перезапускает их по одному с ожиданием rollout.
# Старой считается любая ревизия в sidecar.istio.io/status, кроме <new-revision>.
# Без --apply только показывает список.
set -euo pipefail

usage() {
  echo "usage: ${0##*/} <new-revision> [--apply]   например: ${0##*/} 1-32-0 --apply" >&2
  exit 2
}

[[ $# -ge 1 && $# -le 2 && $1 != -* ]] || usage
NEW_REV=$1
APPLY=false
case ${2:-} in
  "") ;;
  --apply) APPLY=true ;;
  *) usage ;;
esac

# Вывод: <namespace> TAB <kind/name> TAB <старые ревизии через запятую> TAB <istio.io/rev namespace>
# Ревизия "-": в аннотации нет поля revision; "?": аннотация не разбирается как JSON.
list() {
  { kubectl get namespaces -o json; kubectl get replicasets -A -o json; kubectl get pods -A -o json; } |
    jq -rs --arg new "$NEW_REV" '
      (.[0].items | map({key: .metadata.name, value: (.metadata.labels["istio.io/rev"] // "-")}) | from_entries) as $nsrev
      | (.[1].items | map({key: "\(.metadata.namespace)/\(.metadata.name)",
                            value: (.metadata.ownerReferences[]? | select(.kind == "Deployment") | .name)})
                    | from_entries) as $rs2dep
      | [ .[2].items[]
          | .metadata.annotations["sidecar.istio.io/status"] as $status
          | select($status != null)
          | ($status | try (fromjson | .revision // "-") catch "?") as $rev
          | select($rev != $new)
          | .metadata.namespace as $ns
          | .metadata.ownerReferences[]?
          | if .kind == "ReplicaSet" then ($rs2dep["\($ns)/\(.name)"] // empty | "deployment/\(.)")
            elif .kind == "StatefulSet" or .kind == "DaemonSet" then "\(.kind | ascii_downcase)/\(.name)"
            else empty end
          | {ns: $ns, obj: ., rev: $rev} ]
      | group_by([.ns, .obj])[]
      | "\(.[0].ns)\t\(.[0].obj)\t\(map(.rev) | unique | join(","))\t\($nsrev[.[0].ns] // "-")"'
}

list | while IFS=$'\t' read -r ns obj revs nsrev; do
  if [[ $nsrev != "$NEW_REV" ]]; then
    echo "SKIP    $ns $obj ($revs): у namespace istio.io/rev=$nsrev, перезапуск не переведёт на $NEW_REV" >&2
    continue
  fi
  if $APPLY; then
    echo "RESTART $ns $obj ($revs -> $NEW_REV)"
    kubectl -n "$ns" rollout restart "$obj" </dev/null
    kubectl -n "$ns" rollout status "$obj" --timeout=10m </dev/null
  else
    echo "PLAN    $ns $obj ($revs -> $NEW_REV)"
  fi
done

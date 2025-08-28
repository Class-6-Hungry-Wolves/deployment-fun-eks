for s in app-1 app-2 app-3; do
  host=$(kubectl -n apps get svc $s -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  echo "$s -> http://$host"
done

#!/bin/bash
while [ "$(kubectl get pods -l=app.kubernetes.io/name='vault' -o jsonpath='{.items[*].status.containerStatuses[0].ready}')" != "true" ]; do 
    sleep 5 
    echo "Waiting for deployment to be ready." 
done
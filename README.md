# anton-basic-eks-updated
change backend for yours
# commands
terraform init
terraform plan
terraform apply
./scripts/build_and_push_ecr.sh (docker must be runnig for this!)
kubectl apply -f k8s/apps.yaml (Make sure the image matches for your aws account ecr)
./get_endpoints.sh
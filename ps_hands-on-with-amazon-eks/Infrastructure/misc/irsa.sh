
# Create IAM Policies of Bookstore Microservices
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/clients-api/infra/cloudformation && ./create-iam-policy.sh ) & \
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/resource-api/infra/cloudformation && ./create-iam-policy.sh ) & \
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/inventory-api/infra/cloudformation && ./create-iam-policy.sh ) & \
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/renting-api/infra/cloudformation && ./create-iam-policy.sh ) &

    wait

# Getting NodeGroup IAM Role from Kubernetes Cluster
    nodegroup_iam_role=$(aws cloudformation list-exports --query "Exports[?contains(Name, 'nodegroup-eks-node-group::InstanceRoleARN')].Value" --output text | xargs | cut -d "/" -f 2)

# Removing DynamoDB Permissions to the node
    aws iam detach-role-policy --role-name ${nodegroup_iam_role} --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess

# Create IAM Service Accounts
    resource_iam_policy=$(aws cloudformation describe-stacks --stack development-iam-policy-resource-api --query "Stacks[0].Outputs[0]" | jq .OutputValue | tr -d '"')
    renting_iam_policy=$(aws cloudformation describe-stacks --stack development-iam-policy-renting-api --query "Stacks[0].Outputs[0]" | jq .OutputValue | tr -d '"')
    inventory_iam_policy=$(aws cloudformation describe-stacks --stack development-iam-policy-inventory-api --query "Stacks[0].Outputs[0]" | jq .OutputValue | tr -d '"')
    clients_iam_policy=$(aws cloudformation describe-stacks --stack development-iam-policy-clients-api --query "Stacks[0].Outputs[0]" | jq .OutputValue | tr -d '"')
    eksctl create iamserviceaccount --name resources-api-iam-service-account \
        --namespace development \
        --cluster eks-acg \
        --attach-policy-arn ${resource_iam_policy} --approve & \
    eksctl create iamserviceaccount --name renting-api-iam-service-account \
        --namespace development \
        --cluster eks-acg \
        --attach-policy-arn ${renting_iam_policy} --approve & \
    eksctl create iamserviceaccount --name inventory-api-iam-service-account \
        --namespace development \
        --cluster eks-acg \
        --attach-policy-arn ${inventory_iam_policy} --approve & \
    eksctl create iamserviceaccount --name clients-api-iam-service-account \
        --namespace development \
        --cluster eks-acg \
        --attach-policy-arn ${clients_iam_policy} --approve &

    wait

# Upgrading the applications
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/resource-api/infra/helm-v2 && ./create.sh ) & \
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/clients-api/infra/helm-v2 && ./create.sh ) & \
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/inventory-api/infra/helm-v2 && ./create.sh ) & \
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/renting-api/infra/helm-v2 && ./create.sh ) &

    wait


# Updating IRSA for AWS Load Balancer Controller
    
    helm del -n kube-system aws-load-balancer-controller # Uninstall first
    aws_load_balancer_iam_policy=$(aws cloudformation describe-stacks --stack aws-load-balancer-iam-policy --query "Stacks[0].Outputs[0]" | jq .OutputValue | tr -d '"')
    aws iam detach-role-policy --role-name ${nodegroup_iam_role} --policy-arn ${aws_load_balancer_iam_policy}
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/Infrastructure/k8s-tooling/load-balancer-controller && ./create-irsa.sh )

# Updating IRSA for External DNS
    
    helm del external-dns # Uninstall first
    external_dns_iam_policy="arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
    aws iam detach-role-policy --role-name ${nodegroup_iam_role} --policy-arn ${external_dns_iam_policy}
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/Infrastructure/k8s-tooling/external-dns && ./create-irsa.sh )


# Updating IRSA for VPC CNI
    vpc_cni_iam_policy="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    aws iam detach-role-policy --role-name ${nodegroup_iam_role} --policy-arn ${vpc_cni_iam_policy}
    ( cd ~/amazon-eks/ps_hands-on-with-amazon-eks/Infrastructure/k8s-tooling/cni && ./setup-irsa.sh )

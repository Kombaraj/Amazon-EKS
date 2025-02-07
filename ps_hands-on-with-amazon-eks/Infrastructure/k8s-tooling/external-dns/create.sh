helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm upgrade --install external-dns external-dns/external-dns --set policy="sync"

# aws_r53_policy=$(aws cloudformation describe-stacks --stack-name aws-load-balancer-iam-policy --query "Stacks[*].Outputs[?OutputKey=='IamPolicyArn'].OutputValue" --output text | xargs)

aws_r53_policy=$(aws iam create-policy --policy-name allow-externaldns-r53-iam-policy --policy-document file://AllowExternalDNS-R53.json --query "Stacks[*].Outputs[?OutputKey=='IamPolicyArn'].OutputValue" --output text | xargs)

# Replaced name, namespace, cluster, IAM Policy arn 
eksctl create iamserviceaccount \
    --name external-dns \
    --namespace default \
    --cluster eks-acg \
    --attach-policy-arn ${aws_r53_policy} \
    --approve \
    --override-existing-serviceaccounts
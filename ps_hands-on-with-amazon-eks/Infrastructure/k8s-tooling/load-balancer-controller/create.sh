# AWS Loadbalancer Github Repo: https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main

helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install \
  -n kube-system \
  --set clusterName=eks-acg \
  --set serviceAccount.create=true \
  aws-load-balancer-controller eks/aws-load-balancer-controller

#aws cloudformation deploy \
#    --stack-name aws-load-balancer-iam-policy \
#    --template-file iam-policy.yaml \
#    --capabilities CAPABILITY_IAM

# Download IAM Policy
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name aws-load-balancer-iam-policy \
    --policy-document file://iam_policy_latest.json
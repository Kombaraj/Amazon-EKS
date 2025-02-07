# Download latest IAM Policy and Create
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy --policy-name aws-load-balancer-iam-policy --policy-document file://iam_policy_latest.json

# Getting NodeGroup IAM Role from Kubernetes Cluster
nodegroup_iam_role=$(aws cloudformation list-exports --query "Exports[?contains(Name, 'nodegroup-eks-node-group::InstanceRoleARN')].Value" --output text | xargs | cut -d "/" -f 2)
aws_lb_controller_policy=$(aws iam list-policies --query 'Policies[?PolicyName==`aws-load-balancer-iam-policy`].Arn --output text')
aws iam attach-role-policy --role-name ${nodegroup_iam_role} --policy-arn ${aws_lb_controller_policy}

echo "IAM Policy mapped to NodeGroup Instance Role to get access to ALB Loadbalancer..."
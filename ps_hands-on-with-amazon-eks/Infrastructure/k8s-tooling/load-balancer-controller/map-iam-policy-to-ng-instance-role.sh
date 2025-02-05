aws iam attach-role-policy \
    --policy-arn $1 \
    --role-name $2

echo "IAM Policy mapped to NodeGroup Instance Role to get access to ALB Loadbalancer..."
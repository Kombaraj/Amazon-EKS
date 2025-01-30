aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess \
    --role-name <<ROLE>>

echo "IAM Policy mapped to NodeGroup Instance Role ro get access to Route53..."
aws iam attach-role-policy \
    --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess \
    --role-name <<ROLE>>

echo "IAM Policy mapped to NodeGroup Instance Role to get access to DynamoDB..."
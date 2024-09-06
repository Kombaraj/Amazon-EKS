# Hands-On I : cover prerequisites
## IAM user and permissions
To be able to run through this course your IAM user needs to have certain privileges to e.g. create all the required resources and objects.  According AWS Best Practices you should *never* use your root account for working with AWS services. E.g. to demonstrate the Hands-On lectures, the user _eks-course_ has been used.

There are 2 attempts to follow:
1. Create user "eks-course" and provide Programmatic access and Console access. Provide full admin access.  
login with an admin of your AWS account
go to "IAM" => "users" => click on your user => "Permissions" => "Add permission" => then search for _AdministratorAccess_ and attach this policy  
Basically your user just requires *one* policy being attached
  - AdministratorAccess  

(OR)

1. provide a dedicated list of privileges/policies  
to cover all the required privileges, first you have to create additional policies  
EKS-Admin-policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        }
    ]
}
```
CloudFormation-Admin-policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
            ],
            "Resource": "*"
        }
    ]
}
```
finally, assign the following policies to your IAM user you are going to use throughout the course:
  - AmazonEC2FullAccess
  - IAMFullAccess
  - AmazonVPCFullAccess
  - CloudFormation-Admin-policy
  - EKS-Admin-policy  
where the last 2 policies are the ones you created above

### create API Access key/-secret
* create key+secret via AWS console
  AWS-console => IAM => Users => "eks-course" => tab *Security credentials* => button *Create access key*

### create IAM role
* open ```https://console.aws.amazon.com/iam/``` and choose _Roles_ => _create role_  
* choose _EKS_ service followed by _Allows Amazon EKS to manage your clusters on your behalf_  
* choose _Next: Permissions_ (Policy "AmazonEKSServiceRolePolicy")
* click _Next: Review_
* enter a *unique* Role name, _AWSServiceRoleForAmazonEKS_ and click *_Create Role_*

### create keypair

* open EC2 dashboard ```https://console.aws.amazon.com/ec2```
* click _KeyPairs_ in left navigation bar under section "Network&Security"
* click _Create Key Pair_
* provide name for keypair, _eks-course_ and click *_Create_*
* !! the keypair will be downloaded immediately => file *eks-course.pem* !!

# use eksctl to create EKS cluster

display available options and properties:

```bash
eksctl create cluster --help
```

## creation

create cluster by using yaml config file:

```bash
eksctl create cluster -f eks-course.yaml
```

## post-install check

# EKS config file has been generated ~/.kube/config

```
ls -ltr ~/.kube

# Refer the config file attached
kubectl get nodes
```

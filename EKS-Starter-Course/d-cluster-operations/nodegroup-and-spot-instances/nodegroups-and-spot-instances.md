# maintain nodegroups and add spot instances

## Scale a nodegroup

```bash
eksctl get cluster
eksctl get nodegroup --cluster EKS-course-cluster
eksctl scale nodegroup \
  --cluster EKS-course-cluster \
  --nodes 5 \
  --nodes-max 5 \
  --name ng-1
```

## add a nodegroup

extend the yaml file by adding a second nodegroup, consisting of a mix of _ondemand_- and _spot_-instances

```bash
eksctl create nodegroup --config-file=eks-course.yaml --include='ng-mixed'
```

## scaling a nodegroup

to scale the nodegroup _ng-1_ from 5 to 3 nodes, execute:

```bash
eksctl scale nodegroup \
  --cluster EKS-course-cluster \
  --nodes 3 \
  --nodes-max 3 \
  --name ng-1

eksctl get nodegroup --cluster EKS-course-cluster  
```

## delete a nodegroup

```bash
eksctl delete nodegroup --cluster=EKS-course-cluster --name=ng-mixed
```

or

```bash
eksctl delete nodegroup --config-file=eks-course.yaml --include=ng-mixed --approve
```

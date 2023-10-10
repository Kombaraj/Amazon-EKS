## eksctl commands

```bash
$ eksctl get cluster
  NAME                    REGION          EKSCTL CREATED
  EKS-course-cluster      us-east-1       True

$ eksctl get nodegroup --cluster EKS-course-cluster
CLUSTER                 NODEGROUP       STATUS          CREATED                 MIN SIZE        MAX SIZE        DESIRED CAPACITY        INSTANCE TYPE   IMAGE ID                ASG NAME                            TYPE
EKS-course-cluster      ng-1            CREATE_COMPLETE 2023-09-29T07:49:17Z    3               3               3                       t2.small        ami-0dfcfee2c5797c24a   eksctl-EKS-course-cluster-nodegroup-ng-1-NodeGroup-E7G8UZOW3DIJ      unmanaged

```


# maintain nodegroups and add spot instances

## scaling a nodegroup

to scale the nodegroup _ng-1_ from 3 to 5 nodes, execute:

```bash
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

## delete a nodegroup

```bash
eksctl delete nodegroup --cluster=EKS-course-cluster --name=ng-mixed
```

or

```bash
eksctl delete nodegroup --config-file=eks-course.yaml --include=ng-mixed --approve
```

## delete EKS cluster

```bash
eksctl delete cluster EKS-course-cluster \
  --region us-east-1

```

# Activate Cluster autoscaler

The cluster autoscaler automatically launches additional worker nodes if more resources are needed, and shutdown worker nodes if they are underutilized. The autoscaling works within a nodegroup, hence create a nodegroup first which has this feature enabled.

## create nodegroup with autoscaler enabled

```bash
eksctl create nodegroup --config-file=eks-course-2.yaml

# Delete Node group 'ng-1'
eksctl delete nodegroup --cluster=EKS-course-cluster --name=ng-1
```

## deploy the autoscaler

the autoscaler itself:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

put required annotation to the deployment:

```bash
# Go through annotation parameters
kubectl get deployment.apps/cluster-autoscaler -n kube-system -o yaml 

kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

# Go through annotation parameters again
kubectl get deployment.apps/cluster-autoscaler -n kube-system -o yaml 
```

get the autoscaler image version:  
open https://github.com/kubernetes/autoscaler/releases and get the latest release version matching your Kubernetes version, e.g. Kubernetes 1.14 => check for 1.14.n where "n" is the latest release version

edit deployment and set your EKS cluster name:

```bash
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

* set the image version at property ```image=k8s.gcr.io/cluster-autoscaler:vx.yy.z```  
* set your EKS cluster name at the end of property ```- --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<<EKS cluster name>>```

## view cluster autoscaler logs

```bash
kubectl -n kube-system logs deployment.apps/cluster-autoscaler
```

## test the autoscaler

### create a deployment of nginx

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods -o wide
kubectl get node -o wide -l instance-type=spot
```

### scale up the deployment

```bash
kubectl scale --replicas=4 deployment/test-autoscaler
```

### check pods

```bash
kubectl get pods -o wide --watch
```

### check nodes 

```bash
$ kubectl get node -o wide -l instance-type=spot
NAME                            STATUS   ROLES    AGE     VERSION                INTERNAL-IP     EXTERNAL-IP     OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-192-168-1-23.ec2.internal    Ready    <none>   2m12s   v1.25.13-eks-43840fb   192.168.1.23    54.205.14.148   Amazon Linux 2   5.10.192-183.736.amzn2.x86_64   containerd://1.6.19
ip-192-168-40-50.ec2.internal   Ready    <none>   29m     v1.25.13-eks-43840fb   192.168.40.50   3.230.143.93    Amazon Linux 2   5.10.192-183.736.amzn2.x86_64   containerd://1.6.19

koarumug@INLEN8520040198 MINGW64 /c/Kombaraj/Amazon-EKS/EKS - Starter - Course/Section 4 - AWS EKS Operations (master)
$ kubectl get node -o wide 
NAME                             STATUS   ROLES    AGE     VERSION                INTERNAL-IP      EXTERNAL-IP     OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-192-168-1-23.ec2.internal     Ready    <none>   2m25s   v1.25.13-eks-43840fb   192.168.1.23     54.205.14.148   Amazon Linux 2   5.10.192-183.736.amzn2.x86_64   containerd://1.6.19
ip-192-168-27-102.ec2.internal   Ready    <none>   30m     v1.25.13-eks-43840fb   192.168.27.102   3.83.24.26      Amazon Linux 2   5.10.192-183.736.amzn2.x86_64   containerd://1.6.19
ip-192-168-40-50.ec2.internal    Ready    <none>   29m     v1.25.13-eks-43840fb   192.168.40.50    3.230.143.93    Amazon Linux 2   5.10.192-183.736.amzn2.x86_64   containerd://1.6.19
ip-192-168-47-46.ec2.internal    Ready    <none>   30m     v1.25.13-eks-43840fb   192.168.47.46    34.204.203.43   Amazon Linux 2   5.10.192-183.736.amzn2.x86_64   containerd://1.6.19
```

### view cluster autoscaler logs

```bash
kubectl -n kube-system logs deployment.apps/cluster-autoscaler | grep -A5 "Expanding Node Group"


```

### scale down the deployment

```bash
kubectl scale --replicas=1 deployment/test-autoscaler

kubectl -n kube-system logs deployment.apps/cluster-autoscaler | grep -A5 "removing node"
```

# Cloudwatch logging of an EKS cluster

## enable e.g. via yaml config file

```bash
eksctl utils update-cluster-logging --config-file eks-course-3.yaml --approve
```

## disable via plain commandline call

```bash
eksctl utils update-cluster-logging --cluster=EKS-course-cluster --disable-types
all --approve
```

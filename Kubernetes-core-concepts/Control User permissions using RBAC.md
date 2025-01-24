Control User permissions using RBAC

There is existing Namespace applications .

    User smoke should be allowed to create and delete Pods, Deployments and StatefulSets in Namespace applications.
    User smoke should have view permissions (like the permissions of the default ClusterRole named view ) in all Namespaces but not in kube-system .
    Verify everything using kubectl auth can-i .


RBAC Info

Let's talk a little about RBAC resources:

A ClusterRole|Role defines a set of permissions and where it is available, in the whole cluster or just a single Namespace.

A ClusterRoleBinding|RoleBinding connects a set of permissions with an account and defines where it is applied, in the whole cluster or just a single Namespace.

Because of this there are 4 different RBAC combinations and 3 valid ones:

    Role + RoleBinding (available in single Namespace, applied in single Namespace)
    ClusterRole + ClusterRoleBinding (available cluster-wide, applied cluster-wide)
    ClusterRole + RoleBinding (available cluster-wide, applied in single Namespace)
    Role + ClusterRoleBinding (NOT POSSIBLE: available in single Namespace, applied cluster-wide)


Tip


Solution

⁣1) RBAC for Namespace applications

k -n applications create role smoke --verb create,delete --resource pods,deployments,sts
k -n applications create rolebinding smoke --role smoke --user smoke


⁣2) view permission in all Namespaces but not kube-system

As of now it’s not possible to create deny-RBAC in K8s

So we allow for all other Namespaces

k get ns # get all namespaces
k -n applications create rolebinding smoke-view --clusterrole view --user smoke
k -n default create rolebinding smoke-view --clusterrole view --user smoke
k -n kube-node-lease create rolebinding smoke-view --clusterrole view --user smoke
k -n kube-public create rolebinding smoke-view --clusterrole view --user smoke



Verify

# applications
k auth can-i create deployments --as smoke -n applications # YES
k auth can-i delete deployments --as smoke -n applications # YES
k auth can-i delete pods --as smoke -n applications # YES
k auth can-i delete sts --as smoke -n applications # YES
k auth can-i delete secrets --as smoke -n applications # NO
k auth can-i list deployments --as smoke -n applications # YES
k auth can-i list secrets --as smoke -n applications # NO
k auth can-i get secrets --as smoke -n applications # NO

# view in all namespaces but not kube-system
k auth can-i list pods --as smoke -n default # YES
k auth can-i list pods --as smoke -n applications # YES
k auth can-i list pods --as smoke -n kube-public # YES
k auth can-i list pods --as smoke -n kube-node-lease # YES
k auth can-i list pods --as smoke -n kube-system # NO


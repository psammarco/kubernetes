Application Misconfigured 1
Deployment is not coming up, find the error and fix it

There is a Deployment in Namespace application1 which seems to have issues and is not getting ready.

Fix it by only editing the Deployment itself and no other resources.

Tip

k -n application1 get deploy

k -n application1 logs deploy/api

k -n application1 describe deploy api

k -n application1 get cm


Solution

It looks like a wrong ConfigMap name was used, let's change it

k -n application1 edit deploy api


spec:
  template:
    spec:
      containers:
      - env:
        - name: CATEGORY
          valueFrom:
            configMapKeyRef:
              key: category
              name: configmap-category


After waiting a bit we should see all replicas being ready

k -n application1 get deploy api


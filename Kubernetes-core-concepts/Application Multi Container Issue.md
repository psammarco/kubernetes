Application Multi Container Issue
Gather logs

There is a multi-container Deployment in Namespace management which seems to have issues and is not getting ready.

Write the logs of all containers to /root/logs.log .

Can you see the reason for failure?

Tip

kubectl -n management get deploy

kubectl -n management logs -h


Solution

kubectl -n management logs deploy/collect-data -c nginx >> /root/logs.log

kubectl -n management logs deploy/collect-data -c httpd >> /root/logs.log


Or:

kubectl -n management logs --all-containers deploy/collect-data > /root/logs.log


The issue seems that both containers have processes that want to listen on port 80. Depending on container creation order and speed, the first will succeed, the other will fail.

#!/usr/bin/env bash
#export KUBECONFIG=./k8s.conf
# wordir=$(pwd)
# KUBECONFIG=$wordir/inventory/my-cluster/artifacts/admin.conf
#curl -L -O https://raw.githubusercontent.com/elastic/beats/7.10/deploy/kubernetes/filebeat-kubernetes.yaml
#####
#Helm Version: 3.3.4+
#Kubernetes Version: 1.19.0
####


elk(){
 export ELK_VERSION=7.9.2
 helm repo add elastic https://helm.elastic.co
 helm repo update
 _elastic
 _kibana
 _filebeart
}

_elastic(){
  #check https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/
   helm install elasticsearch  elastic/elasticsearch --namespace default  --set imageTag=$ELK_VERSION --set replicas=1 --set esMajorVersion=7 --set resources.requests.memory=1Gi --set volumeClaimTemplate.storageClassName=hostpath --set volumeClaimTemplate.resources.requests.storage=10Gi
}

_kibana(){
   helm install kibana elastic/kibana --namespace default  --set imageTag=$ELK_VERSION,elasticsearch.hosts=http://elasticsearch-master.default.svc.cluster.local:9200
}

_filebeart(){
  kubectl apply -f filebeat-kubernetes.yaml 
}



prometeus(){
   ################ISSUE https://github.com/prometheus-operator/kube-prometheus/issues/561 #########
   kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/release-0.43/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
   
   ################
   
   
  cd kube-prometheus
  kubectl create ns monitoring
  kubectl get servicemonitors
  kubectl create -f manifests/setup
  kubectl create -f manifests/
}

case "$1" in
  prepare-cluster)  shift; prepare-cluster "$@" ;;
  prometeus)  shift; prometeus "$@" ;;
  elk)  shift; elk "$@" ;;
  *) print_help; exit 1
esac

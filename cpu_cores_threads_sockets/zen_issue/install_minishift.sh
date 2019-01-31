#!/bin/bash

export KUBEVIRT_VERSION='v0.13.2'
#export KUBEVIRT_VERSION="v0.13.0"
export CDI_VERSION='v1.4.1'
export ramG='10'
export cores='12'


waiting_pod()
{

echo "run waiting func"

while  $(kubectl get pods --all-namespaces | awk '{print $4}' | grep -v STATUS | grep -v Running >/dev/null); do
        sleep 1
        echo "waiting pods creation..."
        kubectl get pods --all-namespaces
done

while  $(kubectl get pods --all-namespaces | grep -v STATUS | awk '{print $3}' | grep -v '1/1' >/dev/null); do
        sleep 1
        echo "waiting pods running..."
        kubectl get pods --all-namespaces
done


}


minishift_clean(){
minishift delete
rm -rf ~/.minishift/*
}


echo "minishift_clean"

minishift_clean

echo "end clean"

MINISHIFT_ENABLE_EXPERIMENTAL=y minishift start --extra-clusterup-flags "--enable=router,sample-templates,cni" --cpus ${cores} --memory ${ramG}g --disk-size 20g
RES=$?
if [ $RES -eq 1 ]; then
	exit 1;
fi
eval $(minishift oc-env)
oc login -u system:admin
oc adm policy add-scc-to-user privileged -n kubevirt-system -z kubevirt-privileged
oc adm policy add-scc-to-user privileged -n kubevirt-system -z kubevirt-controller
oc adm policy add-scc-to-user privileged -n kubevirt-system -z kubevirt-apiserver
waiting_pod

oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-privileged
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-controller
oc adm policy add-scc-to-user privileged -n kube-system -z kubevirt-apiserver

waiting_pod

oc adm policy add-scc-to-user privileged -n kubevirt -z kubevirt-privileged
oc adm policy add-scc-to-user privileged -n kubevirt -z kubevirt-controller
oc adm policy add-scc-to-user privileged -n kubevirt -z kubevirt-apiserver

waiting_pod


echo "_____________________________"
kubectl create configmap -n kubevirt-system kubevirt-config --from-literal debug.useEmulation=true
kubectl create configmap -n kubevirt kubevirt-config --from-literal debug.useEmulation=true
kubectl create configmap -n kube-system kubevirt-config --from-literal debug.useEmulation=true
kubectl create configmap -n kubevirt kubevirt-config --from-literal debug.useEmulation=true
echo "_____________________________"


waiting_pod

#oc create -f dv-featuregate.yaml
#echo "kubectl get pods --all-namespaces"
#read
oc adm policy add-scc-to-user privileged -z cdi-sa
oc create -f https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-controller.yaml

waiting_pod

kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt.yaml

waiting_pod



oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:kubevirt-web-ui:default
oc new-project kubevirt-web-ui
oc project kubevirt-demo 
oc new-project kubevirt-demo
oc project kubevirt-demo 
oc apply -f https://raw.githubusercontent.com/sHaggYcaT/kubevirt_tools_and_scripts/master/cpu_cores_threads_sockets/zen_issue/kubevirt-web-ui.yaml

waiting_pod

oc get route -n kubevirt-web-ui -o custom-columns="KUBEVIRT UI URL":.spec.host

oc create user test_admin 
oc adm policy add-cluster-role-to-user cluster-admin test_admin

kubectl create configmap -n kubevirt-system kubevirt-config --from-literal debug.useEmulation=true
kubectl create configmap -n kubevirt kubevirt-config --from-literal debug.useEmulation=true
kubectl create configmap -n kube-system kubevirt-config --from-literal debug.useEmulation=true


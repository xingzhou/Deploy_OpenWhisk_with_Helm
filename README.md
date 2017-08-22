## Overview

[Apache OpenWhisk](http://www.openwhisk.org) is a popular container-native serverless platform. 
This chart targets to deploy an OpenWhisk cluster over Kubernetes cluster.

This chart is designed to deploy the following 6 kinds of containers on a running Kubernetes cluster:

- `zookeeper`: deployed in Kubernetes as a `Service`(backended by a `Deployment`). Provides `zookeeper` service for `kafka` node.
- `kafka`: deployed in Kubernetes as a `StatefulSet`. Depends on `zookeeper` service and provides message service for `controller` node and `invoker` node.
- `couchdb`: deployed in Kubernetes as a `Service`(backended by a `Deployment`). Provides database service for `controller` node and `invoker` node.
- `controller`: OpenWhisk controller component, deployed as a `StatefulSet`.
- `invoker`: OpenWhisk invoker component, deployed as a `StatefulSet`.
- `nginx`: deployed in Kubernetes as a combination of a `Service`(of type `NodePort`, backended by a `Deployment`), a `ConfigMap` and a `Secret`. Provides public access endpoint for end user to visit OpenWhisk.

By default, deploying this chart will result in deploying 6 containers in a Kubernetes cluster, which forms a minimum deployment of a workable OpenWhisk environment. Please modify `values.yaml` and corresponding template files to deploy a bigger customized OpenWhisk cluster.

## Deployment Steps

Please follow the following steps in this section to use [Helm](https://github.com/kubernetes/helm) to deploy this chart.

### Step 1. Prepare Docker Images

The first step is to prepare docker images used by this chart on your Kubernetes node. Here is a summary of the images needed:

- `zookeeper`: uses `zookeeper:3.4` at present, no need to make a customized zookeeper image in advance.
- `kafka`: uses `solsson/kafka:0.11.0.0`, no need to make a customized kafka image in advance.
- `couchdb`: uses a pre-built image based on `couchdb-1.6`. User can build this image at `docker/counchdb` by using `docker build` command or use a pre-built image `tomxing/openwhisk_couchdb` at docker hub.
- `controller`: uses OpenWhisk official `openwhisk/controller` image, no need to make a customized controller image in advance.
- `invoker`: uses OpenWhisk official `openwhisk/invoker` image, no need to make a customized invoker image in advance.
- `nginx`: uses a pre-built image based on `nginx:1.11`. User can build this image at `docker/nginx` by using `docker build` command or use a pre-built image `tomxing/openwhisk_nginx` at docker hub.

This chart provides default images for all of the above containers, so you can try deploy without building any images in advance.

This chart will also automatically pull the following action images for `invoker` once deployment is finished:

- openwhisk/nodejsactionbase 
- openwhisk/nodejs6action
- openwhisk/dockerskeleton
- openwhisk/python2action
- openwhisk/python3action
- openwhisk/action-swift-v3.1.1
- openwhisk/swift3action
- openwhisk/java8action

### Step 2. Prepare Kubernetes and Helm

Make sure that you have a running Kubernetes cluster and a `kubectl` client connected to this cluster.

Then please install [Helm](https://github.com/kubernetes/helm) and run the following command to init `Helm Tiller`:
```shell
helm init

```

Please check with the following command to make sure `Helm` is up and running:
```shell
kubectl get pods -n kube-system

```

Then grant corresponding cluster role to `Helm` users:
```shell
kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

Finally, create a new namespace named `openwhisk`:
```shell
kubectl create namespace openwhisk
```

Now, you should have an available environment to deploy OpenWhisk!

### Deploy Charts

Deployment can be done by using the following single command:
```shell
helm install . --namespace=openwhisk --name=your_release_name
```

After a while, if you can see all the pods listed by the following command are in `Running` state, congratulations, you have finished OpenWhisk deployment:
```shell
kubectl get pods -n openwhisk
```

### Test Deployment

Install an [OpenWhisk client](https://github.com/apache/incubator-openwhisk/tree/master/docs) to test the deployed OpenWhisk environment.

Run the following command to get the `nginx` service port:
```shell
kubectl describe service nginx -n openwhisk
```

From the output, please find out the port used for api endpoint. Combine this port with node IP on which nginx pod is deployed, and run the following OpenWhisk client configuration:
```shell
wsk property set --apihost http://<nginx_node_IP>:<nginx_api_port>
wsk property set --auth https://github.com/apache/incubator-openwhisk/tree/master/docs
```

Prepare a small js function like the following and save it to `greeting.js`:
```js
/**
 * Return a simple greeting message for someone.
 *
 * @param name A person's name.
 * @param place Where the person is from.
 */
function main(params) {
    var name = params.name || params.payload || 'stranger';
    var place = params.place || 'somewhere';
    return {payload:  'Hello, ' + name + ' from ' + place + '!'};
}
```

Create an OpenWhisk action by:
```shell
wsk action create hello ./greeting.js
```

And try this action:
```shell
wsk action invoke hello -b
```

If the action is invoked and message is returned without error, congratulations, you have a running OpenWhisk cluster on Kubernetes, enjoy it!

## Cleanup

Use the following command to remove the deployment:
```shell
helm delete <release_name>
```

## References
Part of this chart is based on the project [OpenWhisk Deployment for Kubernetes](https://github.com/apache/incubator-openwhisk-deploy-kube).
This is a project using [ansible](https://www.ansible.com) to deploy OpenWhisk on Kubernetes. Please visit the project on github to get more details.
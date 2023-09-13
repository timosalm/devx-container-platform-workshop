The ability to efficiently provision and manage backing services, such as databases, queues, and caches, is critical for modern applications.

[Crossplane](https://crossplane.io) is a powerful open-source project designed to streamline the **dynamic provisioning of these essential services**. 
It acts as a bridge between your infrastructure and the services your applications depend on, enabling developers and operators to define, provision, and manage these services with ease. 

Crossplane **connects your Kubernetes cluster to external, non-Kubernetes resources**, and allows platform teams to build **custom Kubernetes APIs to consume those resources**. It creates Kubernetes Custom Resource Definitions (CRDs) to represent the external resources as native Kubernetes objects.

Crossplane introduces **multiple building blocks that enable you to provision, compose, and consume infrastructure** using the Kubernetes API. These individual concepts work together to allow for powerful separation of concern between different personas in an organization, meaning that each member of a team interacts with Crossplane at an appropriate level of abstraction.

- **Packages** allow Crossplane to be extended to include new functionality. This typically looks like bundling a set of Kubernetes CRDs and controllers that represent and manage external infrastructure (i.e. a provider)
- **Providers** are packages that enable Crossplane to provision infrastructure on an external service. They bring CRDs (i.e. managed resources) that map one-to-one to external infrastructure resources, as well as controllers to manage the life-cycle of those resources.
  ```terminal:execute
  command: kubectl get providers
  clear: true
  ```
- **Managed Resources** are Kubernetes custom resources that represent infrastructure primitives. 
  ```terminal:execute
  command: kubectl get crds releases.helm.crossplane.io -o yaml | less
  clear: true
  ```
- A **composite resource (XR)** is a special kind of custom resource that is defined by a `CompositeResourceDefinition`. It composes one or more managed resources into a higher level infrastructure unit. 
  ```terminal:execute
  command: kubectl get xrd xpostgresqlinstances.bitnami.database.tanzu.vmware.com -o yaml
  clear: true
  ```
  The `Composition` template defines how to create resources.
  ```terminal:execute
  command: kubectl get composition xpostgresqlinstances.bitnami.database.tanzu.vmware.com -o yaml | less
  clear: true
  ```

In our cluster, there are several backing services available to be consumed based on [Bitnami](https://bitnami.com) Helm charts.

Let's provision a PostgreSQL database for our application.
```editor:append-lines-to-file
file: ~/inclusion-db.yaml
description: Create PostgreSQL database resource configuration
text: |
  apiVersion: bitnami.database.tanzu.vmware.com/v1alpha1
  kind: XPostgreSQLInstance
  metadata:
    name: inclusion-db-{{ session_namespace }}
  spec:
    storageGB: 1
    writeConnectionSecretToRef:
      name: inclusion-db-{{ session_namespace }}
      namespace: {{ session_namespace }}
```
```terminal:execute
command: kubectl apply -f ~/inclusion-db.yaml
clear: true
```
```terminal:execute
command: kubectl get XPostgreSQLInstance inclusion-db-{{ session_namespace }} -o yaml
clear: true
```
```terminal:execute
command: kubectl eksporter secret inclusion-db-{{ session_namespace }} -n inclusion-db-{{ session_namespace }}
clear: true
```

#### Consuming of provisioned services
The [Service Binding Specification](https://github.com/k8s-service-bindings/spec) for Kubernetes and its [reference implementation](https://github.com/servicebinding/runtime) makes it as easy as possible to consume those dynamically provisioned backing services, **by automatically injecting credentials that are required for the connection to the backing service** into the containers of the running application.

```editor:append-lines-to-file
file: ~/service-binding.yaml
description: Create Service Binding configuration
text: |
  apiVersion: servicebinding.io/v1beta1
  kind: ServiceBinding
  metadata:
    name: inclusion-db-binding
  spec:
    name: db
    service:
      apiVersion: v1
      kind: Secret
      name: inclusion-db-{{ session_namespace }}
    workload:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: inclusion-wkld
```
```terminal:execute
command: kubectl apply -f ~/service-binding.yaml
clear: true
```

```terminal:execute
command: kn service describe inclusion-wkld -o url
clear: true
```
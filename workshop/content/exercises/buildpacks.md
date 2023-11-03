To be able to get all the benefits for our application Kubernetes provides, we have to containerize it.

The most obvious way to do this is to write a Dockerfile, run `docker build`, and push it to the container registry of our choice via `docker push`.

![](../images/dockerfile.png)

As you can see, in general, it is relatively easy and requires little effort to containerize an application, but whether you should go into production with it is another question because it is hard to create an optimized and secure container image (or Dockerfile).

![](../images/simple-vs-optimized-dockerfile.png)

To improve container image creation, **Buildpacks** were conceived by Heroku in 2011. Since then, they have been adopted by Cloud Foundry and other PaaS.
The new generation of buildpacks, the [Cloud Native Buildpacks](https://buildpacks.io), is an incubating project in the CNCF, which was initiated by Pivotal (now part of VMware) and Heroku in 2018.

Cloud Native Buildpacks (CNBs) detect what is needed to compile and run an application based on the application's source code. 
The application is then compiled and packaged in a container image with best practices in mind by the appropriate buildpack.

The biggest benefits of CNBs are increased security, minimized risk, and increased developer productivity because they don't need to care much about the details of how to build a container.

With all the benefits of Cloud Native Buildpacks, one of the **biggest challenges with container images still is to keep the operating system, used libraries, etc. up-to-date** in order to minimize attack vectors by CVEs.

With [kpack](https://github.com/buildpacks-community/kpack), it's possible to **automatically recreate and push an updated container image to the target registry if there is a new version of the buildpack or the base operating system available** (e.g. due to a CVE).

With the [kp CLI](https://github.com/buildpacks-community/kpack-cli) it's possible to interact with kpack in a human-friendly way. 

**Image** resources provide a configuration for kpack to build and maintain a Docker image utilizing Cloud Native Buildpacks.
Kpack will monitor the inputs to the image resource to rebuild the image when the underlying source or buildpacks have changed.
```terminal:execute
command: kp image --help
clear: true
```
```terminal:execute
command: kp image create --help
clear: true
```

Let's now create an Image resource for our demo application by specifying the Git repository containing the source code and the container image tag.
```terminal:execute
command: |
  kp image create inclusion --git https://github.com/timosalm/emoji-inclusion --tag {{ registry_host }}/inclusion --env BP_JVM_VERSION=17
clear: false
```

If we have a look at the resource created by the kp CLI command, we can see that it specifies a **Builder**.
```terminal:execute
command: kubectl eksporter image.kpack.io inclusion
clear: true
```
A **Builder** uses a **Store**, which provides a collection of buildpacks, and a **Stack**, which provides the base images.
```terminal:execute
command: kp clusterbuilder list
clear: true
```
```terminal:execute
command: kp clusterbuilder status default
clear: true
```
In addition to the cluster-scoped Builder resource, there is also a namespace-scoped equivalent available.

Let's have a closer look at our image build.
```terminal:execute
command: kp build list inclusion
clear: true
```
```terminal:execute
command: kp build logs inclusion
clear: true
```

After the containerization of our application, it's now time to deploy it in a Kubernetes cluster.
# Kabanero Foundation

The Kabanero Foundation Instance is a deployment of a Kabanero collection in a specific Kubernetes cluster.  The Kabanero operator is leveraged to install and operate the various curated infrastructure and artifacts as defined by the Kabanero collection.

## Kabanero Foundation in a Kubernetes Cluster Prerequisites 

### Software Installation

- [OKD](https://www.okd.io/) v3.11.0+
- [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager/releases) 0.10.0+ (Optional)


### Cluster Hardware Capacity

The full suite of Kabanero foundation components include: 
  - Istio
  - Knative 
    - Eventing
    - Serving
  - Tekton 
    - Dashboard
    - Pipelines

The default configuration for the Kabanero foundation components require a scheduling capacity of approximately:
  - 6 CPU cores
  - 16GB of memory

Optional Recommended Openshift Components include:

  - [openshift-logging](https://docs.openshift.com/container-platform/3.11/install_config/aggregate_logging.html)
  - [openshift-metrics](https://docs.openshift.com/container-platform/3.11/install_config/cluster_metrics.html)
  - [openshift-monitoring](https://docs.openshift.com/container-platform/3.11/install_config/prometheus_cluster_monitoring.html)

The default configuration for the optional recommended Openshift components with defined resource requests and limits has an upper bound requiring approximately:
  - 3.5 + ( 0.25 * #nodes ) CPU Cores
  - 26GB + ( 1GB * #nodes ) Memory
    - Notably elasticsearch requires a large memory node to schedule on

The following [table](prereq-details.md) illustrates the default container resource requests and limits in a 3 node cluster.

# appsody Application Requirements

## appsody Hardware Capacity

appsody currently includes 5 different stacks:
  - java-microprofile (249 MB)
  - java-spring-boot2 (269 MB)
  - nodejs (397 MB)
  - nodejs-express (401 MB)
  - swift (472 MB)
  
 Estimated required capactiy for running 10 appsody applications (Assuming roughly 16MB per application):
  - java-microprofile: **2650 MB**
  - java-spring-boot2: **2850 MB**
  - nodejs: **4130 MB**
  - nodejs-express: **4170 MB**
  - swift: **4880 MB**
 
 # Kabanero Restrictions

  - The Kabanero Collection has a single Java-MicroProfile Appsody Stack. 
  - The Kabanero Operator automatically activates the example featured collection and only in the `kabanero` namespace.
  - Kabanero only supports the example featured collection.
  - The Kabanero Operator requires `cluster-admin` privileges.
 

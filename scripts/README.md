# Kabanero Foundation scripted install

## Prerequisites

* openshift_master_default_subdomain is configured in your Openshift Ansible inventory file
  * See more about [Configuring Your Inventory File](https://docs.okd.io/3.11/install/configuring_inventory_file.html)
  * Example Openshift Ansible inventory file configuration:
 ```
 [OSEv3:vars]
 openshift_master_default_subdomain=<my.openshift.master.default.subdomain>
 ```
  
* Wildcard DNS is available for your subdomain
  * See more about [Wildcard DNS](https://docs.openshift.com/container-platform/3.11/install/prerequisites.html#wildcard-dns-prereq)
  * alternatively, nip.io can be used
  
* The Internal Registry is configured in your Openshift Ansible inventory file
  * See more about the [Internal Registry](https://docs.okd.io/3.11/install_config/registry/index.html)
  * Example Openshift Ansible inventory file configuration:
```
[OSEv3:vars]
openshift_hosted_registry_storage_kind=nfs
openshift_hosted_registry_storage_access_modes=['ReadWriteMany']
openshift_hosted_registry_storage_nfs_directory=/exports
openshift_hosted_registry_storage_nfs_options='*(rw,root_squash)'
openshift_hosted_registry_storage_volume_name=registry
openshift_hosted_registry_storage_volume_size=10Gi
openshift_hosted_registry_storage_host=n.n.n.n
```

## Installation

View [Installing Kabanero Foundation](https://kabanero.io/docs/ref/general/installing-kabanero-foundation.html) on Kabanero.io

## Upgrade

To upgrade from release to release, use the `upgrade-kabanero-foundation.sh`
script.  Set environment variable KABANERO_BRANCH to be the release that you
want to upgrade to.  If you obtained the `kabanero-foundation` repository from
a tagged release, this variable will default to the correct value.  The
script will update the Kabanero operator to the desired release.  For example:
```
KABANERO_BRANCH=0.2.0 ./upgrade-kabanero-foundation.sh
```
After the script completes successfully, you should update your Kabanero CR
instances to use the new version.  If you are using the default collection set,
consider updating it to the new version as well.  For an example, see
[default.yaml](https://raw.githubusercontent.com/kabanero-io/kabanero-operator/master/config/samples/default.yaml), which sets the version, and uses the
default collection set.

## Sample Appsody project with manual Tekton pipeline run

Create a Persistent Volume for the pipeline to use. A sample hostPath `pv.yaml` is provided.
```
oc apply -f pv.yaml
```

Create the pipeline and execute the example manual pipeline run
```
APP_REPO=https://github.com/dacleyra/appsody-hello-world/ ./appsody-tekton-example-manual-run.sh
```

By default, the application container image will be built and pushed to the Internal Registry, and then deployed as a Knative Service.

View manual pipeline logs
```
oc logs $(oc get pods -l tekton.dev/pipelineRun=appsody-manual-pipeline-run --output=jsonpath={.items[0].metadata.name}) --all-containers
```

Access Tekton dashboard at `http://tekton-dashboard.my.openshift.master.default.subdomain`

Access application at `http://appsody-hello-world.kabanero.my.openshift.master.default.subdomain`


## Sample Appsody project with webhook driven Tekton pipeline run

Use appsody to create a sample project

1. Download [appsody](https://github.com/appsody/appsody/releases)
2. Add the kabanero collection repository to appsody `appsody repo add kabanero https://github.com/kabanero-io/collections/releases/download/v0.1.2/kabanero-index.yaml`
3. Initialize a java microprofile project `appsody init kabanero/java-microprofile`
4. Push the project to your github repository

Create a Persistent Volume for the tekton pipeline to use. A sample hostPath `pv.yaml` is provided.
```
oc apply -f pv.yaml
```

Create a priveleged service account to run the pipeline
```
oc -n kabanero create sa appsody-sa
oc adm policy add-cluster-role-to-user cluster-admin -z appsody-sa -n kabanero
oc adm policy add-scc-to-user hostmount-anyuid -z appsody-sa -n kabanero
```

Login to the Tekton dashboard using openshift credentials `http://tekton-dashboard.my.openshift.master.default.subdomain`

If your github repository is private, create a secret with your github credentials. Associate the secret with the service account that the pipeline will run as. 

![](secret.png)

Create a webhook using the dashboard, providing the necessary information. Provide the access token for creating a webhook.

![](webhook.png)

![](cats.png)

Once the webhook is created, the dashboard generates a webhook in github. Verify the webhook is created by accessing.

https://github.com/YOURORG/appsody-hello-world/settings/hooks/

If the webhook payload was not successfully delivered, this may be due to a timeout of the webhook sink not starting in a timely manner. If so, select the failed webhook delivery in github, and redeliver it.

Trigger the pipeline.

Make a simple change to the application repository, such as updating the README.

In the Tekton dashboard, you should observe a new PipelineRun execute as a result of the commit and webhook.

## Uninstallation Scripts

A sample uninstall script is provided.  The script will perform the reverse of the install script.  Before running the uninstall script, consider removing any resources created outside of the install script (for example, webhooks, Knative services or Appsody applications).  Retrieve the [uninstallation scripts from our documentation repository](https://github.com/kabanero-io/kabanero-foundation/tree/master/scripts)

The sample uninstall script will completely remove all dependencies from the cluster, including Knative, Tekton and Istio.  The script can be modified if a different behavior is required.

## Uninstallation

As a `cluster-admin`, execute the sample uninstallation script:
```
./uninstall-kabanero-foundation.sh
```


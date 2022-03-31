# kube-change
Bash script to change Kubernetes contexts and namespaces.

## Installation
  Save this script somewhere on your system such as the /bin directory. Make sure it is executable. Then save it as an alias with an easy command such as `kch`.

### Arguments
  -n **:** specify that you are changing the namespace. To be used if you are not
       touching the context.

### Examples
#### Display Contexts and Namespaces
    kch
#### Switch context and namespace
    kch my-context my-namespace
#### Switch only context
    kch my-context
#### Switch only namespace
    kch -n my-namespace

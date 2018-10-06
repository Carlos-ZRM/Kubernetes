# Instalación de Kubernetes
## Prerequisistos

Previo a la instalación de Kubernetes es importante verificar que se cumplen los siguientes aspectos:

* Contar con un sistema Operativo tipo: 
	* Ubuntu 16.04+
	* Debian 9
	* CentOS 7
	* RHEL 7
	* Fedora 25/26
* Minimo 2 GB en memoria RAM
* Minimo 2 Cores en cada máquina
* Tener desactivada la memoria swap
	* Para desactivar la memoria swap basta con ejecutar el siguiente comando:
	```bash
	sudo swapoff -a
	```
* Tener abiertos los siguientes puertos en los nodos **Master**

| Protocolo | Puerto   | Propósito              | Usado por           |
|-----------|----------|------------------------|---------------------|
| TCP       | 6443     | Kubernetes API Server  | Todos               |
| TCP       | 2379-2380| etcd server client API | kube-apiserver, etcd|
| TCP       | 10250    | Kubelet API            | Self, Control pane  |
| TCP       | 10251    | kube-scheduler         | Self                |
| TCP       | 10252    | kube-controller-manager| Self                |

* Tener abiertos los siguientes puertos en los nodos **Workers**

| Protocolo | Puerto        | Propósito              | Usado por           |
|-----------|---------------|------------------------|---------------------|
| TCP       | 10250         | Kubelet API            | Self, Control Pane  |
| TCP       | 30000 - 32767 | NodePort Services      | Todos               |

* Tener instalado **Docker** en todas las máquinas que conforman el cluster. 
	* **NOTA**: La instalación de Docker varia conforme la virtualización.

* Colocar a **SELinux** en modo permisivo
	* Para colocar a SELinux en modo permisivo basta con ejecutar el comando:
	```bash
	sudo setenforce 0
	```
* Para usuarios RHEL/CentOS 7 asegurarse que **net.bridge.bridge-nf-call-iptables** este en **1**:
	* Para colocar **net.bridge.bridge-nf-call-iptables** en **1** basta con ejecutar el comando:
	```bash
	sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
	net.bridge.bridge-nf-call-ip6tables = 1
	net.bridge.bridge-nf-call-iptables = 1
	EOF
	sysctl --system
	```

## Configuración de las máquinas

Ademas de deshabilitar la memoria swap y colocar a SELinux en modo permisivo, es necesario instalar los paquetes correspondientes a Kubernetes en cada de una de las máquinas, los paquetes a instalar son los siguientes:
* **kubeadm**: Comando para administración del cluster
* **kubelet**: Componente encargado de correr en todas las máquinas el cual permite que los pods y los contenedores inicien correctamente.
* **kubectl**: Linea de comandos que permite la interacción con el cluster ya montado.

**NOTA**: La version de _kubelet_ nunca debe superar la version de _kubeadm_.

Para la instalación de los paquetes anteriormente mencionados, basta con ejecutar los siguientes comandos:
```bash
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable kubelet && systemctl start kubelet
```
Cuando se utiliza **Docker**, Kubernetes por defecto detecta el cgroup, pero en el caso donde se utilice una herramienta diferente, es necesario configurar el cgroup manualmente ubicado en el archivo **/etc/default/kubelet** cambiando la siguiente línea:
```bash
KUBELET_KUBEADM_EXTRA_ARGS=--cgroup-driver = < cgroup-nuevo >
```
Y posterior ejecutar los comandos:
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```
## Creación de nodo Master

El nodo Master es la máquina del cluster encargada de llevar el control de todos los componentes que corren, incluyendo el **etcd** ( la base de datos del cluster) y el API server.
Para crear el nodo master es necesario ejecutar el comando
```bash
sudo kubeadm init
```
**NOTA**: kubeadm utiliza la interfaz de red a la cual esta asociada por defecto la máquina, sin embargo si se tiene otra interfaz, por la cual el mastr sabe como llegar a los workers, es necesario especificarla a tráves de la bandera **--apiserver-advertise-address** la cual recibe como parámetro la IP asociada en esa interfaz. De tal manera que el comando se reescribiría de la siguiente forma:
```bash
sudo kubeadm init --apiserver-advertise-address = < ip-address >
```
Una vez finalizada la ejecución del comando anterior, podremos observar una salida similar a la siguiente:
```bash
[init] Using Kubernetes version: vX.Y.Z
[preflight] Running pre-flight checks
[kubeadm] WARNING: starting in 1.8, tokens expire after 24 hours by default (if you require a non-expiring token use --token-ttl 0)
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [kubeadm-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.138.0.4]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated sa key and public key.
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "scheduler.conf"
[controlplane] Wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] Wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] Wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] Waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests"
[init] This often takes around a minute; or longer if the control plane images have to be pulled.
[apiclient] All control plane components are healthy after 39.511972 seconds
[uploadconfig] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[markmaster] Will mark node master as master by adding a label and a taint
[markmaster] Master master tainted and labelled with key/value: node-role.kubernetes.io/master=""
[bootstraptoken] Using token: <token>
[bootstraptoken] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run (as a regular user):

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the addon options listed at:
  http://kubernetes.io/docs/admin/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token < token > < master-ip >: < master-port > --discovery-token-ca-cert-hash sha256: < hash >
```
Después de dicha salida, para poder hacer uso del cluster es necesario ejecutar los siguientes comandos:
**En caso de ser un usuario regular**
```bash
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**En caso de ser el usuario root**
```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
```
### Instalación de Pod Network

Después de haber creado el nodo master, es necesario instalar la red de pods, la cual permitirá que el master conozca a los nodos workers que componen a dicho cluster. Existen diferentes pod network que pueden ser instalados, para este caso se instalará **Weave Net**.
La instalación de Weave Net consiste en la ejecución del siguiente comando:
```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
**NOTA**: Si se desea instalar algun otro pod network como **Calico** o **Flanel** es necesario verificar que el las IP's del segmento de red no se encuentren ocupadas, de lo contrario esto generará problemas respecto a que ya hay IP's ocupadas.

### Agregar los Workers al Cluster

Para añadir un nodo al cluster basta con dentro del nodo, el comando:
```bash
sudo kubeadm join --token < token > < master-ip >: < master-port > --discovery-token-ca-cert-hash sha256: < hash >
```
El cual se obtiene tras la ejecución del comando **kubeadm init**.
Es importante señalar que el **token** tiene un tiempo de vida, por lo tanto si dicho token expira el nodo no podrá ser añadido, para corregir este inconveniente basta con generar un nuevo token.
Si deseamos verificar el status del token lo hacemos a tráves de (en el nodo Master):
```bash
kubeadm token list
```
En caso de necesitar un nuevo token, el comando correspondiente es el siguiente:
```bash
kubeadm token create --print-join-command
```
A la salida tendremos el comando a ejecutar en los nodos workers.

Para verificar que el nodo se ha añadido correctamente al cluster ejecutamos el comando:
```bash
kubectl get nodes
```
# Posibles Issues
* Verificar que el nodo Master sepa como llegar a cada Worker, ya sea por el DNS al que apunta el Master o bien a traves de la configuración en el archivo **/etc/hosts**, asi como configurar las variables de no proxy.
* En caso de ser necesario exportar las variables de proxy, para tener salida internet.

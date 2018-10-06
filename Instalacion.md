# Instalación de Kubernetes
## Prerequisistos
Previo a la instalación de Kubernetes es importante verificar que se cuentan son los siguientes aspectos:
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
* Tener habilitados los siguientes puertos en los nodos **Master**

| Protocolo | Puerto   | Propósito              | Usado por           |
|-----------|----------|------------------------|---------------------|
| TCP       | 6443     | Kubernetes API Server  | Todos               |
| TCP       | 2379-2380| etcd server client API | kube-apiserver, etcd|
| TCP       | 10250    | Kubelet API            | Self, Control pane  |
| TCP       | 10251    | kube-scheduler         | Self                |
| TCP       | 10252    | kube-controller-manager| Self                |

* Tener habilitados los siguientes puertos en los nodos **Workers**

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
## Configuración de las máquinas
Ademas de deshabilitar la memoria swap y colocar a SELinux en modo permisivo, es necesario instalar los paquetes correspondientes a Kubernetes en cada de una de las máquinas, los paquetes a instalar son los siguientes:
* **kubeadm**: Comando para administración del cluster
* **kubelet**: Componente encargado de correr en todas las máquinas el cual permite que los pods y los contenedores inicien correctamente.
* **kubectl**: Linea de comandos que permite la interacción con el cluster ya montado.

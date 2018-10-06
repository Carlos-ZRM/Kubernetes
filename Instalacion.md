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
* Tener habilitados los siguientes puertos
| Protocolo | Puerto | Propósito | Usado por |
|-----------|--------|-----------|-----------|
| TCP        | 6443    | Kubernetes API Server | Todos|
| TCP        | 2379-2380| etcd server client API | kube-apiserver, etcd|

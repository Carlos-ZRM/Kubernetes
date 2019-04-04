# Cri-o en Kubernetes
![Cri-o](https://kubic.opensuse.org/assets/images/criologo.svg)
## Conocimientos previos

En las capas más bajas de un nodo de Kubernetes se encuentra el software que, entre otras cosas, inicia y detiene los contenedores. Llamamos a esto el **"Tiempo de ejecución del contenedor".** El tiempo de ejecución de contenedores más conocido es *Docker*.

## ¿Qué es Cri-o?

CRI-O es una implementación de Kubernetes CRI (Interfaz de tiempo de ejecución de contenedor) para permitir el uso de tiempos de ejecución compatibles con OCI (Open Container Initiative). Es una alternativa ligera a utilizar Docker como el tiempo de ejecución para kubernetes. Permite a Kubernetes utilizar cualquier tiempo de ejecución compatible con OCI como tiempo de ejecución de contenedor para ejecutar pods. Hoy en día, es compatible con runc y Kata Containers como tiempo de ejecución del contenedor, pero cualquier tiempo de ejecución compatible con OCI se puede conectar en principio.

CRI-O admite imágenes de contenedor OCI y puede extraer de cualquier registro de contenedor. Es una alternativa ligera a usar Docker, Moby o rkt como tiempo de ejecución para Kubernetes.

## Instalación de Kubernetes con el uso de Kubespray

### Prerequisitos

* Ansible v2.6 o mayor
* Jinja 2.9 (Para uso de Ansible Playbooks)

### Instalación de Ansible

Para llevar a cabo la instalación de **Ansible** ejecutamos el comando
```bash
sudo yum install ansible
```
**NOTA**: La instalación de *ansible* puede ser en más de un servidor.

Una vez finalizada la instalación podemos observar que el inventario creado por defecto esta ubicado en **/etc/ansible/hosts**.

#### Creación de llave
Seguido de la instalación de Ansible, es necesario crear una llave para su posterior conexión vía ssh con los demas servidores.

Primero creamos un usuario llamado **ansible** con el siguiente comando:
```bash
sudo useradd ansible
```
Enseguida nos logeamos como el usuario previamente creado:
```bash
sudo su ansible
```
Una vez logueados generamos la llave con el siguiente comando:
```bash
ssh-keygen -t rsa -b 4096
```
Sin escribir nada, damos enter en cada una de las opciones para obtener al final dos archivos llamados *id_rsa* e *id_rsa.pub* ubicados en el directorio **/home/ansible/.ssh**.
Con esto la llave habra sido creada.

Posterior a la creación de la llave es preciso evaluarla y añadirla, dichas operaciones las hacemos con los siguientes comandos:
```bash
sudo su -
eval $(ssh-agent -s)
ssh-add /home/ansible/.ssh/id_rsa
```
**NOTA**: Los comandos anteriores siempre hay que ejecutarlos antes de utilizar ansible.

#### Alta de Ansible en los servidores
Para dar de alta al usuario ansible en todos los servidores, ejecutamos en cada uno, los comandos siguientes:
```bash
useradd -m -g operaciones ansible 
mkdir -p /home/ansible/.ssh/ 
touch /home/ansible/.ssh/authorized_keys
chmod 700 /home/ansible/.ssh/
chmod 600 /home/ansible/.ssh/authorized_keys 
echo ' < llave publica >' > /home/ansible/.ssh/authorized_keys
chown ansible:operaciones /home/ansible/ -R 
echo 'ansible  ALL=(ALL)      NOPASSWD: ALL' >> /etc/sudoers
```
Donde:
* **< llave publica >**: Es el contenido que tiene el archivo *id_rsa.pub* creado en pasos anteriores.

**NOTA**: Para el ejemplo anterior es necesario tener creado el grupo llamado **operaciones**.

#### Prueba de Ansible
Para probar que ansible corre perfectamente, nos ubicamos en el servidor donde fue instalado Ansible y ejecutamos el comando:
```bash
ansible [grupo] -m ping
```
**NOTA**: En [grupo] colocamos el nombre del grupo creado en el archivo **/etc/ansible/hosts**
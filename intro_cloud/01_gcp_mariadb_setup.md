# GCP Project and MariaDB Setup

This guide provides instructions on how to create a GCP project, set up a Virtual Machine (VM) instance named `maria-db`, and install/configure MariaDB.

## 1. Create a GCP Project in the Console

1.  Go to the [GCP Console](https://console.cloud.google.com/).
2.  Click on the project dropdown list at the top of the page.
3.  Click **New Project**.
4.  Enter a **Project Name** (e.g., `Big Data Project`).
5.  (Optional) Edit the **Project ID**.
6.  Click **Create**.

## 2. Create a VM Instance

### Via GCP Console
1.  Navigate to **Compute Engine** > **VM instances**.
2.  Click **Create Instance**.
3.  **Name**: `maria-db`
4.  **Region/Zone**: Choose your preferred location (e.g., `us-central1 (Iowa)` / `us-central1-a`).
5.  **Machine configuration**: Default (`e2-medium` is recommended).
6.  **Boot disk**: Click **Change** and select:
    *   **Operating System**: `Debian`
    *   **Version**: `Debian GNU/Linux 12 (bookworm)`
7.  **Firewall**: 
    *   Allow HTTP traffic (Optional).
    *   Allow HTTPS traffic (Optional).
    *   *Note: For MariaDB external access, you will need to create a firewall rule for port 3306 later.*
8.  Click **Create**.

### Via gcloud Command
To create the VM with default values (using Debian 12):

```bash
gcloud compute instances create maria-db \
    --project=[YOUR_PROJECT_ID] \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-project=debian-cloud \
    --image-family=debian-12 \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --boot-disk-device-name=maria-db
```

## 3. Access the VM Using SSH

Once the instance is running, you can connect to it using the following command:

```bash
gcloud compute ssh maria-db --zone=us-central1-a
```

Alternatively, click the **SSH** button next to the instance in the GCP Console.

## 4. Install and Configure MariaDB

Follow these steps once connected to your VM:

### Update and Install MariaDB
```bash
sudo apt-get update
sudo apt install mariadb-server -y
```

### Verify Installation
Confirm that MariaDB is running with status **ACTIVE**:
```bash
sudo systemctl status mariadb
# Press ctrl+c to exit the status view
```

### Secure MariaDB Installation
Run the security script to remove insecure defaults and set the root password:
```bash
# Accept everything (Y) and create a new password for the root user.
# Since it is the first time, just press Enter for the current password.
sudo mysql_secure_installation
```

### Test Connection
Test the connection with the root user (replace `example123` with your password):
```bash
sudo mysql -uroot -pexample123
```

### Create User and Grant Privileges
In the MariaDB prompt, run the following SQL commands:
```sql
CREATE USER 'big_data_user'@'%' IDENTIFIED BY 'example123';
GRANT ALL PRIVILEGES ON *.* TO 'big_data_user';
FLUSH PRIVILEGES;
EXIT;
```

### Allow External Connections
Edit the configuration file to allow ingress:
1.  Open `/etc/mysql/my.cnf` (or `/etc/mysql/mariadb.conf.d/50-server.cnf` on some systems):
    ```bash
    sudo nano /etc/mysql/my.cnf
    ```
2.  Add the following lines at the bottom (or under the `[mysqld]` section):
    ```ini
    [mysqld]
    skip-networking=0
    skip-bind-address
    ```
    *   `skip-networking=0`: Tells MariaDB to use TCP/IP.
    *   `skip-bind-address`: Allows connections from any IP instead of just the loopback (localhost).

### Restart MariaDB
```bash
sudo systemctl restart mariadb
```

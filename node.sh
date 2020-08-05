#!/usr/bin/env bash
cd ~
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
cd ~
tar xvf node_exporter-0.17.0.linux-amd64.tar.gz
sudo cp node_exporter-0.17.0.linux-amd64/node_exporter /usr/local/bin
#sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
#sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
touch /etc/systemd/system/node_exporter.service
sudo cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
echo  node_exporter.service file is created
sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter
echo  Starting node exporter...
sudo systemctl status node_exporter

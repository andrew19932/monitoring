#!/usr/bin/env bash
cd ~
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
cd ~
tar xvf node_exporter-0.17.0.linux-amd64.tar.gz
sudo cp node_exporter-0.17.0.linux-amd64/node_exporter /usr/local/bin
sudo rm node_exporter-0.17.0.linux-amd64.tar.gz
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

#INSTALL PROMTAIL
#auto define local ip of latest instance 
INSTANCE_IP=$( curl http://169.254.169.254/latest/meta-data/local-ipv4 );

sudo apt install unzip
cd ~
sudo curl -O -L https://github.com/grafana/loki/releases/download/v1.4.1/promtail-linux-amd64.zip
cd ~
sudo unzip promtail-linux-amd64.zip
sudo cp promtail-linux-amd64 /usr/local/bin
sudo rm promtail-linux-amd64.zip
touch /etc/systemd/system/promtail.service
sudo touch /usr/local/bin/config-promtail.yml
sudo cat << EOF > /etc/systemd/system/promtail.service
[Unit]
Description=Promtail service
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/promtail-linux-amd64 -config.file=/usr/local/bin/config-promtail.yml
[Install]
WantedBy=multi-user.target
EOF
sudo cat << EOF > /usr/local/bin/config-promtail.yml
server:
  http_listen_port: 9080
  grpc_listen_port: 0
positions:
  filename: /tmp/positions.yaml
#modify ip to ip of your loki instal
clients:
  - url: http://172.30.4.222:3100/loki/api/v1/push
#modify host of your job and job name on which promtail will be installed
scrape_configs:
  - job_name: syslog
    entry_parser: raw
    static_configs:
    - targets:
        - localhost
      labels:
        job: syslog
        host: $INSTANCE_IP
        __path__: /var/log/syslog
#  - job_name: canvas
#    entry_parser: raw
#    static_configs:
#    - targets:
#        - localhost
#      labels:
#        job: canvas
#        host: $INSTANCE_IP
#        __path__: /var/www/canvas/log/production.log

EOF
echo  node_exporter.service file is created
sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter
echo  Starting node exporter...
sudo systemctl status node_exporter
echo  promtail.service file is created
sudo systemctl daemon-reload
sudo systemctl enable promtail.service
sudo systemctl start promtail
echo  Starting node exporter...
sudo systemctl status promtail

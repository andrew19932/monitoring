#!/usr/bin/env bash
sudo apt install unzip
cd ~
sudo curl -O -L https://github.com/grafana/loki/releases/download/v1.4.1/promtail-linux-amd64.zip
cd ~
sudo unzip promtail-linux-amd64.zip
sudo cp promtail-linux-amd64 /usr/local/bin
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
  - url: http://52.213.64.97:3100/loki/api/v1/push
#modify host of your job and job name on which promtail will be installed
scrape_configs:
  - job_name: apache
    entry_parser: raw
    static_configs:
    - targets:
        - localhost
      labels:
        job: nginx
        host: 54.76.147.254
        __path__: /var/log/apache2/*log
  - job_name: canvas
    entry_parser: raw
    static_configs:
    - targets:
        - localhost
      labels:
        job: canvas
        host: 54.76.147.254
        __path__: /var/www/canvas/log/production.log
EOF
echo  promtail.service file is created
sudo systemctl daemon-reload
sudo systemctl enable promtail.service
sudo systemctl start promtail
echo  Starting node exporter...
sudo systemctl status promtail

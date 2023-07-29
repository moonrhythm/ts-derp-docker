# Tailscale DERP Docker

## Setup

1. (**IMPORTANT**) Prepare firewall

    | Port | Protocol | Description |
    | ---- | -------- | ----------- |
    | 80   | TCP      | HTTP        |
    | 443  | TCP      | HTTPS       |
    | 3478 | UDP      | STUN        |

1. Prepare tailscale key and hostname

    ```
    export TS_KEY=tskey-xxxxxxxxxxxxxxxxxxxxxxxx
    export TS_HOSTNAME=xxxx
    ```

1. Install tailscale

    ```sh
    curl -fsSL https://tailscale.com/install.sh | sh
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
    tailscale up --authkey=$TS_KEY
    ```

1. Install docker

    ```sh
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

1. Run the container

    ```sh
    cat <<EOF > derp.sh
    #!/bin/bash
    NAME=derp
    IMAGE=gcr.io/moonrhythm-containers/ts-derp
    TAG=latest

    docker pull \$IMAGE:\$TAG
    docker stop \$NAME
    docker rm \$NAME
    docker run -d --restart=always --name=\$NAME --net=host \\
        -v /var/run/tailscale:/var/run/tailscale \\
        \$IMAGE:\$TAG \\
        --hostname=$TS_HOSTNAME --verify-clients
    EOF
    chmod +x derp.sh
    ./derp.sh
    ```

## How to run the private network.
[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/new/?editor=code#https://github.com/ethpandaops/ethereum-package)
1. [Install Docker & start the Docker Daemon if you haven't done so already][docker-installation]
2. [Install the Kurtosis CLI, or upgrade it to the latest version if it's already installed][kurtosis-cli-installation]
3. Run the package with default configurations from the command line:

### Install Docker

### Install Kurtosis
```bash
echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
sudo apt update
sudo apt install kurtosis-cli=0.88.16 -V
```

### Run Interstate devnet
```bash
git clone --single-branch --branch feat/helix-relay https://github.com/eqx-labs/ethereum-package.git
cd ethereum-package
kurtosis run --enclave interstate-devnet ./ --args-file kurtosis_config.yaml
```
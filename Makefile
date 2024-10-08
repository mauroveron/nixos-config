.DEFAULT_GOAL:=help

include make-env

NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= maurov
NIXNAME ?= vm-aarch64-utm
DEVICE ?= sda

SSH_OPTIONS=-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

UNAME := $(shell uname)

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z0-9\._-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Bootstrapping

vm.bootstrap0: ## First bootstrap step
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@${NIXADDR} " \
		parted /dev/${DEVICE} -- mklabel gpt; \
		parted /dev/${DEVICE} -- mkpart primary 512MB -8GB; \
		parted /dev/${DEVICE} -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/${DEVICE} -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/${DEVICE} -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/${DEVICE}1; \
		mkswap -L swap /dev/${DEVICE}2; \
		mkfs.fat -F 32 -n boot /dev/${DEVICE}3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
  			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

vm.bootstrap: ## Second bootstrap step
	NIXUSER=root $(MAKE) vm.copy
	NIXUSER=root $(MAKE) vm.switch
	#$(MAKE) vm.secrets
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

vm.copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='iso/' \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

vm.secrets:
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# See https://github.com/NixOS/nixpkgs/issues/169693
# need to add --install-bootloader, otherwise install fails when my config tries
# to downgrade the bootloader. Not sure why the bootloader gets downgraded though
vm.switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"

vm: vm.copy vm.switch

##@ SSH

ssh.root: ## SSH as root
	ssh ${SSH_OPTIONS} root@${NIXADDR}

ssh.user: ## SSH as your regular user
	ssh ${SSH_OPTIONS} ${NIXUSER}@${NIXADDR}

code-rsync: ## Rsync code directory [p]
	rsync -avP ${HOME}/code/${p} $(NIXUSER)@$(NIXADDR):~/code/

##@ Dev

switch: ## rebuild OS and reload new config
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

test: ## test configuration
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild test --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIXNAME)"
endif



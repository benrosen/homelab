# `homelab`

Run containers on old Mac Minis.

## Architecture

Kubernetes runs on Mac Minis. Containers run on Kubernetes. Applications run in containers.

## Workflow

Developers use Git. Merges trigger deployments.

## Onboarding a New (Old) Mac Mini

### Ingredients

- 1 Mac Mini (Intel AMD64)
- 1 Other Mac
- 1 USB Drive
- 1 USB Keyboard
- 1 USB Mouse
- 1 HDMI Cable
- 1 HDMI Monitor/TV
- 1 Ethernet Cable

### Steps

1. Flash an AMD64 Debian ISO onto the USB drive from the other Mac.
2. Connect the Mac Mini to your network via ethernet.
3. Turn on the Mac Mini, holding OPTION to enter the boot menu
4. Choose to boot from the USB drive
5. Configure the installation using the OS Config

```text
hostname        e.g. mini-0, mini-1, etc.
domain          home.arpa
root password   <leave blank>
username        ben
password        <contact ben for password>
partition mthd  guided - use entire disk
partition schm  all files in one parition
mirror          deb.debian.org
http proxy      <leave blank>
software        only ssh server & system utils
```

6. Remove the USB drive
7. Log in to the Mac Mini
8. Get the IP address with `hostname -I`
9. Confirm ssh is active with `systemctl is-active ssh`
10. Confirm that you can log in with `ssh ben@<ip>`
11. Generate a key named `/Users/<username>/.ssh/id_ed25519_homelab` using `ssh-keygen -t ed25519` ONLY if you don't already have one
12. Copy the public key to the Mac Mini using `ssh-copy-id -i ~/.ssh/id_ed25519_homelab.pub ben@<ip>`
13. Verify you can connect with `ssh -i ~/.ssh/id_ed25519_homelab ben@<ip>`
14. Using `nano ~/.ssh/config`, update your ssh config to include:

```text
Host mini-<id>
    HostName <ip>
    User ben
    IdentityFile ~/.ssh/id_ed25519_homelab
    IdentitiesOnly yes
```

15. Verify your ssh config has the right permissions with `chmod 600 ~/.ssh/config`
16. Verify you can connect with `ssh mini-<id>`
17. Inside your ssh session, run:

```text
ip route
ip -br link
```

18. Open the router IP in your browser
19. Locate `mini-<n>` using its MAC address
20. Allocate IP `192.168.1.100 + <n>` to it, e.g. `192.168.1.109` for `mini-9` or `192.168.1.110` for `mini-10`
21. Run `sudo reboot` in your ssh session
22. Update your ssh config with the new IP
23. Verify you can still connect with `ssh mini-<n>`
24. Install git

```text
sudo apt update
sudo apt install git
```

25. Clone the repo

```text
git clone <repository-url>
cd homelab
```

26. Add the Mac Mini to Kubernetes with `./initialize-node.sh`

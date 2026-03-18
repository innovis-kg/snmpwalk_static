# snmpwalk-static

A statically linked `snmpwalk` binary with DES support for SNMPv1/v2c authentication.

## Features

- Fully statically linked (no external dependencies)
- DES encryption for SNMPv3 Privacy
- IPv6 support
- Minimal Docker image (~16MB)

## Version

net-snmp 5.9.5.2

## Docker

### Build

```bash
# Default version (v5.9.5.2)
docker build -t snmpwalk-static .

# Custom version
docker build --build-arg NET_SNMP_VERSION=v5.9.4 -t snmpwalk-static .
```

### Extract Binary

```bash
docker run --rm --entrypoint /bin/cat snmpwalk-static /snmpwalk > ./snmpwalk
chmod +x ./snmpwalk
```

### Run as Container

```bash
# SNMPv2c
docker run --rm snmpwalk-static -v 2c -c public localhost system

# SNMPv3 with DES Privacy
docker run --rm snmpwalk-static -v 3 -u user -a SHA -A authpass -x DES -X privpass localhost system
```

## GitHub Actions

The project includes a GitHub Actions workflow that automatically builds the binary on every tag push.

### Workflow

The workflow in `.github/workflows/build.yml` performs the following steps:

1. Checkout code
2. Set up Docker Buildx
3. Build Docker image
4. Extract binary
5. Upload as artifact
6. Create GitHub Release on tagged versions

### Triggers

- **Tag Push**: Creates a release with the binary
- **Manual Workflow Dispatch**: Build without release

## License

GNU General Public License v2 or higher (as per net-snmp)

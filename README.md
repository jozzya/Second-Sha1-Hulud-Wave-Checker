# Second Sha1 Hulud WaveChecker

A shell script to check your npm project for vulnerabilities related to the **Second Sha1-Hulud Wave** supply chain attack.

The script scans your `package-lock.json` and compares your package versions against a known list of vulnerable packages.

Vulnerable package list: [Wiz Blog – Sha1-Hulud 2.0](https://www.wiz.io/blog/shai-hulud-2-0-ongoing-supply-chain-attack)

---

## Usage

1. Copy the script into your repository.
2. Run the scanner:

```bash
./scanner.sh

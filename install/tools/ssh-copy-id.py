import argparse
import getpass
import re
import subprocess
import sys
parser = argparse.ArgumentParser(description='Copy SSH keys to a remote server.')
parser.add_argument('--machine', type=str, default='all', help='The machine to copy keys to (default: all)')
parser.add_argument('--user', type=str, default='mint', help='SSH username (default: mint)')
args = parser.parse_args()

def parse_machine_arg(machine_arg):
    """Parse machine argument into a list of IPs.
    Supports: 'all', 'v5 v6 v7', 'v6-v11', 'v2 v6-v11', '5 6-11', etc.
    """
    if machine_arg == 'all':
        return [f"10.204.100.1{i:02d}" for i in range(1, 25)]

    nums = []
    for token in machine_arg.split():
        m = re.fullmatch(r'v?(\d+)-v?(\d+)', token)
        if m:
            start, end = int(m.group(1)), int(m.group(2))
            if start > end:
                print(f"Invalid range: {token}", file=sys.stderr)
                sys.exit(1)
            nums.extend(range(start, end + 1))
        elif re.fullmatch(r'v?(\d+)', token):
            nums.append(int(re.fullmatch(r'v?(\d+)', token).group(1)))
        else:
            print(f"Invalid machine value: {token}", file=sys.stderr)
            sys.exit(1)

    return [f"10.204.100.1{n:02d}" for n in nums]

if __name__ == "__main__":
    machines = parse_machine_arg(args.machine)

    print(f"🖥️  Machines: {machines}")
    password = getpass.getpass(f"🔑 Password for {args.user}@machines: ")

    for machine in machines:
        print(f"\n🔄 [{machine}] Copying SSH keys...")

        # Quick ping check (1 packet, 2s timeout)
        ping = subprocess.run(
            ['ping', '-c', '1', '-W', '2', machine],
            capture_output=True,
        )
        if ping.returncode != 0:
            print(f"  ⛔ Skipping {machine} (unreachable)", file=sys.stderr)
            continue

        try:
            result = subprocess.run(
                ['sshpass', '-p', password, 'ssh-copy-id',
                 '-o', 'StrictHostKeyChecking=no',
                 '-o', 'ConnectTimeout=10',
                 f'{args.user}@{machine}'],
                capture_output=True, text=True,
                timeout=30,
            )
        except subprocess.TimeoutExpired:
            print(f"  ⏳ Skipping {machine} (ssh timed out)", file=sys.stderr)
            continue

        if result.returncode != 0:
            print(f"  ❌ Error copying keys to {machine}: {result.stderr}", file=sys.stderr)
        else:
            print(f"  ✅ Successfully copied keys to {machine}.")
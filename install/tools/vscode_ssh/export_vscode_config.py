import os, sys, argparse
parser = argparse.ArgumentParser(description='Export VSCode SSH config for machines')
parser.add_argument('--IdentityFile', type=str, default='C:\\Users\\punta\\.ssh\\id_ed25519', help='Path to SSH private key (default: C:\\Users\\punta\\.ssh\\id_ed25519)')
args = parser.parse_args()

def export_vscode_config():
    with open('vscode_ssh_config.txt', 'w') as f:
        for i in range(1, 25):
            pattern = f"Host 10.204.100.1{i:02d}\n"
            pattern += "    User mint\n"
            pattern += f"    IdentityFile {args.IdentityFile}\n"
            f.write(pattern)
    f.close()
    print("✅ Exported VSCode SSH config to vscode_ssh_config.txt")
    
if __name__ == "__main__":  
    print("🔄 Exporting VSCode SSH config...")
    print(f"🔑 Using IdentityFile: {args.IdentityFile}")
    export_vscode_config()
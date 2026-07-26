#!/usr/bin/env python3

# script version 2.0
import os
import re
import subprocess
import argparse
import getpass

def echo_singularity_cmd(args):
    """
    Pretty-print the full command by inserting a backslash-newline
    before each long-form flag.
    """
    full_cmd = ' '.join(args)
    # Insert " \\\n    " before each " --flag"
    formatted = re.sub(r' (-(?:-[^\s]+))', r' \\\n    \1', full_cmd)
    print(formatted)

def main():
    user = getpass.getuser()

    # parse arguments
    parser = argparse.ArgumentParser(description='Launch Singularity with custom binds/options.')
    parser.add_argument('--root',      action='store_true', help='Use sudo + writable')
    parser.add_argument('--internet',  action='store_true', help='Enable SOCKS5 proxy via SSH tunnel')
    parser.add_argument('--here',      action='store_true', help='Map current host cwd to container cwd under /host')
    parser.add_argument('--cmd',       metavar='CMD',      help='Command string to run inside singularity')
    parser.add_argument('--base',      default=None, help='Base path for projects and conda environments')
    # parser.add_argument('--tmp',       default=f"/home/{user}/tmp", help='/tmp location')
    parser.add_argument('--tmp',       default=None, help='/tmp location')
    parser.add_argument('--sand',      action='store_true', help='use sand/')
    parser.add_argument('--cuda',      action='store_true', help='bind cuda toolkit')
    parser.add_argument('--ssh',       action='store_true', default=False, help='bind .ssh folder inside Singularity')
    # Mint's
    parser.add_argument('--project_dir', default=None, help='Base path for project directory')
    parser.add_argument('--conda_dir', default=None, help='Base path for conda_envs directory')
    args = parser.parse_args()

    # determine directories
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parts = script_dir.split(os.sep)

    # top_level is usually /ist or /ist-nas depending on where this script is run
    top_level = f"/{parts[1]}" if len(parts) > 1 else script_dir

    if args.base is None:
        args.base = f'{top_level}/users/{user}'
    print("Base: ", args.base)

    ssh_auth_sock = os.getenv("SSH_AUTH_SOCK", "")
    # common bind/env options
    opts = [
        '--containall',
        '--home', f'/home/{user}',
        '--env',  f'HF_HUB_CACHE=/host{top_level}/ist-share/vision/huggingface_hub',
        '--env',  f'SSH_CONNECTION={os.environ.get("SSH_CONNECTION", "")}',
        # '--env',  f'SSH_AUTH_SOCK=/home/{user}/ssh-agent.sock',
        '--bind', f'{script_dir}/home:/home/{user}',
        # '--bind', f'{ssh_auth_sock}:/home/{user}/ssh-agent.sock',
        # '--bind', '/usr/lib/x86_64-linux-gnu/libEGL.so.1:/usr/lib/x86_64-linux-gnu/libEGL.so.1',
    ]
    if args.tmp is None:
        opts += ['--bind', f'/tmp:/tmp']
    else:
        if not os.path.exists(args.tmp):
            os.makedirs(args.tmp, exist_ok=True)
            print(f"Created temporary directory: {args.tmp}")
        os.chmod(args.tmp, 0o700)
        opts += ['--bind', f'{args.tmp}:/tmp']

    command = ['singularity', 'exec']
    # build prefix
    if args.root:
        opts += ["--writable"]
        command = ['sudo'] + command
    else:
        opts += [
            '--nv',
            '--bind', '/:/host',
        ]
        # Binding projects and conda_envs
        for pp in ['projects', 'conda_envs']:
            if os.path.exists(f'{args.base}'):
                opts += ['--bind', f'{args.base}/{pp}:/{pp}']

        if args.cuda:
            opts += ['--bind', '/usr/local/cuda:/usr/local/cuda']
            opts += ['--env', 'APPEND_PATH=/usr/local/cuda/bin']
            opts += ['--env', 'CUDA_HOME=/usr/local/cuda']
            
            # nvidia_pkg = '/usr/local/lib/python3.10/dist-packages/nvidia'
            # cudnn_lib = '/usr/local/lib/python3.10/dist-packages/nvidia/cudnn/lib'
            # opts += ['--bind', f'{nvidia_pkg}:{nvidia_pkg}']
            # opts += ['--env', f'LD_LIBRARY_PATH={cudnn_lib}:$LD_LIBRARY_PATH']

    # Binding projects and conda_envs
    if args.project_dir is not None and os.path.exists(args.project_dir):
      opts += ['--bind', f'{args.project_dir}:/projects']
    if args.conda_dir is not None and os.path.exists(args.conda_dir):
      opts += ['--bind', f'{args.conda_dir}:/conda_envs']
    if args.ssh:
      opts += ['--bind', f'/home/{user}/.ssh:/home/{user}/.ssh']

    sing_command = []
    # choose inner command
    if args.internet:
        sing_command += [f'ssh -D 11080 -N -f {user}@ist-frontend-001', "; "]
        opts += [
            '--env', 'HTTP_PROXY=socks5h://localhost:11080',
            '--env', 'HTTPS_PROXY=socks5h://localhost:11080'
        ]
    if args.here:
        sing_command += [f'cd /host{os.getcwd()}']

    if args.cmd is not None:
        sing_command += [args.cmd, "; "]

    final = [*command, *opts, f'{script_dir}/sand{"" if args.sand else ".sif"}', '/usr/bin/zsh', '-is', 'eval', "".join(sing_command)]

    echo_singularity_cmd(final)
    subprocess.run(final)

if __name__ == '__main__':
    main()

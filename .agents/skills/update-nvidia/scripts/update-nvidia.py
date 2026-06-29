#!/usr/bin/env python3
import urllib.request
import re
import subprocess
import sys
import os
import argparse

# Config
CONFIG_PATH = "hosts/nix-desktop/configuration.nix"

def get_latest_nvidia_version(branch="production"):
    url = "https://www.nvidia.com/object/unix.html"
    try:
        req = urllib.request.Request(
            url, 
            headers={'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'}
        )
        with urllib.request.urlopen(req) as response:
            html = response.read().decode('utf-8')
    except Exception as e:
        print(f"Error fetching NVIDIA page: {e}", file=sys.stderr)
        sys.exit(1)
        
    if branch == "production":
        match = re.search(r'Latest Production Branch Version:.*?<a[^>]*>([0-9.]+)</a>', html, re.DOTALL | re.IGNORECASE)
    else:
        match = re.search(r'Latest New Feature Branch Version:.*?<a[^>]*>([0-9.]+)</a>', html, re.DOTALL | re.IGNORECASE)
        
    if not match:
        print(f"Error: Could not find NVIDIA {branch} version on the Unix Drivers page.", file=sys.stderr)
        sys.exit(1)
        
    return match.group(1)

def get_current_version(config_file):
    if not os.path.exists(config_file):
        print(f"Error: Configuration file {config_file} not found.", file=sys.stderr)
        sys.exit(1)
        
    with open(config_file, 'r') as f:
        content = f.read()
        
    # Ищем version = "..." внутри блока mkDriver
    mkdriver_match = re.search(r'mkDriver\s*\{[^}]*version\s*=\s*"([^"]+)"', content, re.DOTALL)
    if not mkdriver_match:
        print("Error: Could not find current driver version inside mkDriver block in configuration.", file=sys.stderr)
        sys.exit(1)
        
    return mkdriver_match.group(1)

def prefetch_url(name, url, unpack=False):
    print(f"Prefetching {name} ({url})...")
    cmd = ["nix-prefetch-url"]
    if unpack:
        cmd.append("--unpack")
    cmd.append(url)
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        sha256_base32 = res.stdout.strip()
        
        # Convert to SRI
        sri_res = subprocess.run(
            ["nix", "hash", "convert", "--to", "sri", "--hash-algo", "sha256", sha256_base32],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True
        )
        sri_hash = sri_res.stdout.strip()
        print(f"  Result: {sri_hash}")
        return sri_hash
    except subprocess.CalledProcessError as e:
        print(f"  Error prefetching: {e.stderr.strip() or e.stdout.strip()}", file=sys.stderr)
        return None

def update_config_file(filepath, version, hashes):
    with open(filepath, 'r') as f:
        content = f.read()

    # Найдем блок mkDriver
    mkdriver_pattern = re.compile(
        r'(mkDriver\s*\{)(.*?)(\})', 
        re.DOTALL
    )
    
    match = mkdriver_pattern.search(content)
    if not match:
        print("Could not find mkDriver block in configuration file!", file=sys.stderr)
        return False
        
    block_start = match.group(1)
    block_content = match.group(2)
    block_end = match.group(3)
    
    # Делаем замены внутри блока
    new_block_content = block_content
    
    # Заменяем версию
    new_block_content = re.sub(
        r'(version\s*=\s*")[^"]+(";)',
        rf'\g<1>{version}\g<2>',
        new_block_content
    )
    
    # Заменяем хеши
    for key, val in hashes.items():
        hash_pattern = re.compile(rf'({key}\s*=\s*)([^;]+)(;)')
        new_block_content = hash_pattern.sub(
            rf'\g<1>"{val}"\g<3>',
            new_block_content
        )
        
    # Заменяем старый блок на новый в общем контенте
    new_content = content[:match.start()] + block_start + new_block_content + block_end + content[match.end():]
    
    with open(filepath, 'w') as f:
        f.write(new_content)
        
    return True

def run_test_build():
    print("Running dry-run nix build to verify configuration (does not require sudo)...")
    # Собираем конфигурацию системы (только в nix store, без симлинка в result)
    cmd = ["nix", "build", ".#nixosConfigurations.nix-desktop.config.system.build.toplevel", "--no-link"]
    try:
        subprocess.run(cmd, check=True)
        print("\n[SUCCESS] Dry-run build succeeded! Configuration is valid and compiles fine.")
        return True
    except subprocess.CalledProcessError:
        print("\n[ERROR] Test build failed! Check errors above.", file=sys.stderr)
        return False

def main():
    parser = argparse.ArgumentParser(description="Update NVIDIA driver in NixOS configuration.")
    parser.add_argument("--branch", choices=["production", "latest"], default="production",
                        help="NVIDIA driver branch to check: production (default) or latest (new feature branch)")
    parser.add_argument("--force", action="store_true", help="Force prefetch and update even if versions match")
    parser.add_argument("--skip-build", action="store_true", help="Skip running the nix test build after update")
    args = parser.parse_args()

    # Переходим в корень репозитория, где лежит скрипт (если запущен из другого места)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", ".."))
    os.chdir(repo_root)
    
    print(f"Checking for latest NVIDIA {args.branch} driver...")
    latest_version = get_latest_nvidia_version(args.branch)
    current_version = get_current_version(CONFIG_PATH)
    
    print(f"Current version in config: {current_version}")
    print(f"Latest version on website: {latest_version}")
    
    if latest_version == current_version and not args.force:
        print("Driver is already up to date. Nothing to do. Use --force to force update.")
        return

    print(f"\nUpdating NVIDIA driver to {latest_version}...")
    
    # Собираем хеши
    urls = {
        "sha256_64bit": f"https://download.nvidia.com/XFree86/Linux-x86_64/{latest_version}/NVIDIA-Linux-x86_64-{latest_version}.run",
        "sha256_aarch64": f"https://download.nvidia.com/XFree86/Linux-aarch64/{latest_version}/NVIDIA-Linux-aarch64-{latest_version}.run",
        "openSha256": f"https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/{latest_version}.tar.gz",
        "settingsSha256": f"https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/{latest_version}.tar.gz",
        "persistencedSha256": f"https://github.com/NVIDIA/nvidia-persistenced/archive/refs/tags/{latest_version}.tar.gz"
    }
    
    hashes = {}
    for name, url in urls.items():
        is_unpack = (name not in ["sha256_64bit", "sha256_aarch64"])
        h = prefetch_url(name, url, unpack=is_unpack)
        if not h:
            print(f"Fatal error prefetching {name}. Aborting.", file=sys.stderr)
            sys.exit(1)
        hashes[name] = h
        
    print("\nAll hashes prefetched successfully. Updating configuration.nix...")
    if update_config_file(CONFIG_PATH, latest_version, hashes):
        print(f"Successfully updated {CONFIG_PATH}!")
    else:
        sys.exit(1)
        
    if not args.skip_build:
        if run_test_build():
            print("\nYou can now apply the configuration by running:")
            print("  nh os switch")
        else:
            sys.exit(1)
    else:
        print("\nUpdate complete. Skipped verification build. Run:")
        print("  nh os switch")

if __name__ == "__main__":
    main()

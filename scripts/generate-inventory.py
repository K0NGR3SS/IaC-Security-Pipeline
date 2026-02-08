"""Convert Terraform outputs to Ansible inventory"""
import json
import argparse
import os

def generate_inventory(tf_output_path, output_path):
    """Convert Terraform output JSON to Ansible INI inventory"""
    
    with open(tf_output_path) as f:
        data = json.load(f)
    
    instances = data['instance_ips']['value']
    
    # Build inventory groups
    web_servers = []
    all_hosts = {}
    
    for instance in instances:
        name = instance['name']
        public_ip = instance['public_ip']
        private_ip = instance['private_ip']
        instance_id = instance['id']
        tags = instance.get('tags', {})
        
        # Group by role
        role = tags.get('Role', 'unknown')
        if role == 'web':
            web_servers.append(name)
        
        # Store host vars
        all_hosts[name] = {
            'ansible_host': public_ip,
            'private_ip': private_ip,
            'instance_id': instance_id,
            'environment': tags.get('Environment', 'unknown')
        }
    
    # Write INI format
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w') as f:
        # Web servers group
        f.write("[web_servers]\n")
        for host in web_servers:
            host_vars = all_hosts[host]
            f.write(f"{host} ansible_host={host_vars['ansible_host']} ")
            f.write(f"private_ip={host_vars['private_ip']} ")
            f.write(f"instance_id={host_vars['instance_id']}\n")
        
        # Group vars
        f.write("\n[all:vars]\n")
        f.write("ansible_user=ubuntu\n")
        f.write("ansible_python_interpreter=/usr/bin/python3\n")
        f.write("ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n")
    
    print(f"   Inventory written to {output_path}")
    print(f"   Total hosts: {len(all_hosts)}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate Ansible inventory from Terraform outputs')
    parser.add_argument('--tf-output', required=True, help='Path to terraform output JSON')
    parser.add_argument('--output', required=True, help='Output inventory file path')
    args = parser.parse_args()
    
    generate_inventory(args.tf_output, args.output)
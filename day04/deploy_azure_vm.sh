#!/bin/bash
set -euo pipefail

# === Check if Azure CLI is installed ===
check_azurecli() {
    if ! command -v az &> /dev/null; then
        echo "Azure CLI is not installed. Installing it now..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    else
        echo "✅ Azure CLI is already installed."
    fi
}

# === Login to Azure ===
azure_login() {
    echo "🔐 Logging in to Azure..."
    az login --use-device-code
}

# === Create Resource Group ===
create_resource_group() {
    local rg_name="$1"
    local location="$2"

    echo "📦 Creating Resource Group: $rg_name in $location..."
    az group create --name "$rg_name" --location "$location" --output table
}

# === Create Azure VM ===
create_vm() {
    local rg_name="$1"
    local vm_name="$2"
    local location="$3"
    local username="$4"
    local password="$5"
    local image="$6"
    local size="$7"

    echo "🚀 Creating Azure VM: $vm_name..."
    az vm create \
        --resource-group "$rg_name" \
        --name "$vm_name" \
        --image "$image" \
        --admin-username "$username" \
        --admin-password "$password" \
        --size "$size" \
        --authentication-type password \
        --public-ip-sku Standard \
        --output table

    echo "✅ VM creation started..."
}

# === Wait until VM is running ===
wait_for_vm() {
    local rg_name="$1"
    local vm_name="$2"

    echo "⏳ Waiting for VM $vm_name to be running..."
    while true; do
        state=$(az vm get-instance-view \
            --resource-group "$rg_name" \
            --name "$vm_name" \
            --query "instanceView.statuses[1].displayStatus" \
            -o tsv)
        if [[ "$state" == "VM running" ]]; then
            echo "✅ VM $vm_name is now running."
            break
        fi
        sleep 10
    done
}

# === Open required ports (22 for SSH, 8000 for Django, etc.) ===
open_ports() {
    local rg_name="$1"
    local vm_name="$2"

    echo "🌐 Opening ports 22 (SSH) and 8000 (Web)..."
    az vm open-port --resource-group "$rg_name" --name "$vm_name" --port 22 --priority 1001
    az vm open-port --resource-group "$rg_name" --name "$vm_name" --port 8000 --priority 1002
}

# === Get Public IP of VM ===
get_public_ip() {
    local rg_name="$1"
    local vm_name="$2"

    ip=$(az vm show -d -g "$rg_name" -n "$vm_name" --query publicIps -o tsv)
    echo "🌍 Public IP of your VM: $ip"
}

# === MAIN ===
main() {
    check_azurecli
    azure_login

    echo "🛠️ Starting Azure VM deployment..."

    # Modify these as needed
    RESOURCE_GROUP="ShellScript-RG"
    LOCATION="eastus"
    VM_NAME="shell-vm"
    USERNAME="azureuser"
    PASSWORD="YourSecurePassword123!"  # Must meet Azure password policy
    IMAGE="Ubuntu2404"
    SIZE="Standard_B1s"

    create_resource_group "$RESOURCE_GROUP" "$LOCATION"
    create_vm "$RESOURCE_GROUP" "$VM_NAME" "$LOCATION" "$USERNAME" "$PASSWORD" "$IMAGE" "$SIZE"
    wait_for_vm "$RESOURCE_GROUP" "$VM_NAME"
    open_ports "$RESOURCE_GROUP" "$VM_NAME"
    get_public_ip "$RESOURCE_GROUP" "$VM_NAME"

    echo "🎉 Azure VM deployment completed successfully!"
}

main "$@"


#!/bin/bash

# Enhanced k3d cluster creation script
# Usage: ./k3d.sh [memory_gb] [cpu_count] [cluster_name] [namespace]
# Example: ./k3d.sh 4 2 demo database

set -e

# Default values
DEFAULT_MEMORY="4"
DEFAULT_CPU="2"
DEFAULT_CLUSTER="demo"
DEFAULT_NAMESPACE="database"

# Parse arguments
MEMORY_GB=${1:-$DEFAULT_MEMORY}
CPU_COUNT=${2:-$DEFAULT_CPU}
CLUSTER_NAME=${3:-$DEFAULT_CLUSTER}
NAMESPACE=${4:-$DEFAULT_NAMESPACE}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Get k3d version
get_k3d_version() {
    K3D_VERSION=$(k3d version | grep "k3d version" | cut -d' ' -f3 | cut -d'v' -f2)
    log_info "Detected k3d version: $K3D_VERSION"
}

# Validate inputs
validate_inputs() {
    if ! [[ "$MEMORY_GB" =~ ^[0-9]+$ ]] || [ "$MEMORY_GB" -lt 1 ]; then
        log_error "Memory must be a positive integer (GB)"
        exit 1
    fi
    
    if ! [[ "$CPU_COUNT" =~ ^[0-9]+$ ]] || [ "$CPU_COUNT" -lt 1 ]; then
        log_error "CPU count must be a positive integer"
        exit 1
    fi
    
    if [[ ! "$CLUSTER_NAME" =~ ^[a-zA-Z0-9-]+$ ]]; then
        log_error "Cluster name must contain only alphanumeric characters and hyphens"
        exit 1
    fi
}

# Check if k3d is installed
check_k3d() {
    if ! command -v k3d &> /dev/null; then
        log_error "k3d is not installed. Please install k3d first."
        log_info "Install with: curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"
        exit 1
    fi
    log_success "k3d is installed"
    get_k3d_version
}

# Check if cluster already exists
check_existing_cluster() {
    if k3d cluster list | grep -q "^$CLUSTER_NAME"; then
        log_warning "Cluster '$CLUSTER_NAME' already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deleting existing cluster '$CLUSTER_NAME'..."
            k3d cluster delete "$CLUSTER_NAME"
            log_success "Cluster '$CLUSTER_NAME' deleted"
        else
            log_info "Exiting without changes"
            exit 0
        fi
    fi
}

# Create k3d cluster with version-appropriate flags
create_cluster() {
    log_info "Creating k3d cluster with the following configuration:"
    echo "  📊 Memory: ${MEMORY_GB}GB"
    echo "  🖥️  CPU: ${CPU_COUNT} cores"
    echo "  🏷️  Name: ${CLUSTER_NAME}"
    echo "  🌐 Nodes: 3 agents + 1 server"
    echo "  📁 Namespace: ${NAMESPACE}"
    echo ""
    
    log_info "Starting cluster creation..."
    
    # Create cluster with simplified configuration
    k3d cluster create "$CLUSTER_NAME" \
        --servers 1 \
        --agents 3 \
        --port "8080:80@loadbalancer" \
        --port "8443:443@loadbalancer" \
        --wait
        
    log_success "Cluster '$CLUSTER_NAME' created successfully!"
}

# Configure kubectl context
configure_kubectl() {
    log_info "Configuring kubectl context..."
    
    # Update kubeconfig
    k3d kubeconfig merge "$CLUSTER_NAME" --kubeconfig-switch-context
    
    # Verify cluster is accessible
    if kubectl cluster-info &> /dev/null; then
        log_success "kubectl configured successfully"
        
        # Display cluster info
        echo ""
        log_info "Cluster Information:"
        kubectl cluster-info
        echo ""
        
        log_info "Node Information:"
        kubectl get nodes -o wide
        echo ""
        
    else
        log_error "Failed to configure kubectl"
        exit 1
    fi
}

# Create namespace
create_namespace() {
    log_info "Creating namespace '$NAMESPACE'..."
    
    # Create namespace
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Add useful labels
    kubectl label namespace "$NAMESPACE" \
        environment=demo \
        cluster="$CLUSTER_NAME" \
        created-by=k3d-script \
        purpose=database \
        --overwrite
    
    log_success "Namespace '$NAMESPACE' created and labeled"
}

# Install essential components
install_components() {
    log_info "Installing essential cluster components..."
    
    # Install metrics-server for resource monitoring
    log_info "Installing metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patch metrics-server for k3d
    kubectl patch deployment metrics-server -n kube-system --type='json' \
        -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
    
    log_success "Essential components installed"
}

# Display usage information
show_usage() {
    echo "🚀 k3d Cluster Creation Script"
    echo ""
    echo "Usage: $0 [memory_gb] [cpu_count] [cluster_name] [namespace]"
    echo ""
    echo "Parameters:"
    echo "  memory_gb     Memory allocation in GB (default: $DEFAULT_MEMORY)"
    echo "  cpu_count     Number of CPU cores (default: $DEFAULT_CPU)"
    echo "  cluster_name  Name of the cluster (default: $DEFAULT_CLUSTER)"
    echo "  namespace     Default namespace to create (default: $DEFAULT_NAMESPACE)"
    echo ""
    echo "Examples:"
    echo "  $0                          # Create cluster with defaults"
    echo "  $0 8 4 production database  # Create cluster with 8GB RAM, 4 CPUs"
    echo "  $0 2 1 small apps           # Create small cluster with 'apps' namespace"
    echo ""
}

# Main execution
main() {
    # Show usage if help requested
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    log_info "🚀 Starting k3d cluster creation process..."
    
    # Validate inputs
    validate_inputs
    
    # Check prerequisites
    check_k3d
    
    # Check for existing cluster
    check_existing_cluster
    
    # Create cluster
    create_cluster
    
    # Configure kubectl
    configure_kubectl
    
    # Create namespace
    create_namespace
    
    # Install components
    install_components
    
    echo ""
    log_success "🎉 Cluster setup completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. 📊 Check cluster status: kubectl get nodes"
    echo "  2. 📁 Check namespace: kubectl get namespaces"
    echo "  3. 🚀 Deploy applications: kubectl apply -k postgres/"
    echo "  4. 🌐 Set default namespace: kubectl config set-context --current --namespace=$NAMESPACE"
    echo ""
    log_info "To delete this cluster: k3d cluster delete $CLUSTER_NAME"
}

# Run main function
main "$@"
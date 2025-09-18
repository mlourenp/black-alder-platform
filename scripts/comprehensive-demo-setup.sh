#!/bin/bash

# Black Alder Platform - Comprehensive Technical Demo Setup
# This script sets up the complete demo environment for technical presentations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_section "Checking Prerequisites"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check terraform
    if ! command -v terraform &> /dev/null; then
        log_error "terraform is not installed. Please install terraform first."
        exit 1
    fi
    
    # Check helm
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed. Please install helm first."
        exit 1
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster. Please configure kubectl."
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Setup demo configuration
setup_demo_config() {
    log_section "Setting up Demo Configuration"
    
    # Create demo terraform variables
    cat > terraform.tfvars << EOF
# Demo Configuration
environment = "demo"
cluster_name = "black-alder-demo"
cloud_provider = "aws"
region = "us-east-1"

# Enable all demo features
enable_crossplane = true
enable_service_mesh = true
enable_observability_stack = true
enable_ebpf_observability = true
enable_pixie = false  # Optional - requires registration
enable_cost_estimation = true
enable_cell_deployment = true

# Demo-specific settings
observability_retention_days = 7
observability_storage_size = "20Gi"
telemetry_privacy_level = "standard"

# Demo tags
common_tags = {
  Platform = "black-alder-platform"
  Environment = "demo"
  Purpose = "technical-demonstration"
  ManagedBy = "terraform"
}
EOF
    
    log_success "Demo configuration created"
}

# Deploy platform foundation
deploy_platform_foundation() {
    log_section "Deploying Platform Foundation"
    
    log_info "Initializing Terraform..."
    terraform init -upgrade
    
    log_info "Planning platform deployment..."
    terraform plan -out=demo.tfplan
    
    log_info "Applying platform configuration..."
    terraform apply demo.tfplan
    
    log_success "Platform foundation deployed"
}

# Deploy grove cells
deploy_grove_cells() {
    log_section "Deploying Grove Cell Architecture"
    
    log_info "Deploying comprehensive sample cells..."
    ./deploy-sample-cells.sh
    
    # Wait for cells to be ready
    log_info "Waiting for cells to become ready..."
    sleep 30
    
    # Check cell status
    log_info "Cell deployment status:"
    kubectl get namespaces -l "black-alder.io/cell-type"
    
    log_success "Grove cell architecture deployed"
}

# Setup monitoring dashboards
setup_monitoring() {
    log_section "Setting up Monitoring and Dashboards"
    
    log_info "Configuring Grafana dashboards..."
    
    # Import custom dashboards
    kubectl apply -f ../platform/definitions/kubernetes/observability/
    
    # Wait for Grafana to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus-grafana -n black-alder-observability || true
    
    log_info "Grafana Dashboard URLs:"
    echo "  - Grafana: kubectl port-forward -n black-alder-observability svc/prometheus-grafana 3000:80"
    echo "  - Prometheus: kubectl port-forward -n black-alder-observability svc/prometheus 9090:9090"
    echo "  - Jaeger: kubectl port-forward -n black-alder-observability svc/jaeger-query 16686:16686"
    
    log_success "Monitoring dashboards configured"
}

# Setup demo data
setup_demo_data() {
    log_section "Setting up Demo Data and Scenarios"
    
    log_info "Generating sample metrics and traffic..."
    
    # Create demo data generator
    cat > /tmp/demo-data-generator.py << 'EOF'
#!/usr/bin/env python3
import requests
import random
import time
import json
from concurrent.futures import ThreadPoolExecutor

def generate_cell_traffic():
    """Generate traffic between cells for demonstration"""
    cells = ['channel-cell', 'logic-cell', 'data-cell', 'security-cell']
    
    for _ in range(100):  # Generate 100 requests
        source = random.choice(cells)
        target = random.choice([c for c in cells if c != source])
        
        # Simulate API call (replace with actual endpoints when available)
        print(f"Simulating {source} -> {target} communication")
        time.sleep(random.uniform(0.1, 1.0))

if __name__ == "__main__":
    print("Generating demo traffic between cells...")
    generate_cell_traffic()
    print("Demo traffic generation complete")
EOF
    
    python3 /tmp/demo-data-generator.py &
    
    log_success "Demo data generation started"
}

# Validate deployment
validate_deployment() {
    log_section "Validating Demo Deployment"
    
    log_info "Checking platform components..."
    
    # Check namespaces
    if kubectl get namespace black-alder-system &> /dev/null; then
        log_success "✓ Management plane namespace created"
    else
        log_warning "✗ Management plane namespace missing"
    fi
    
    if kubectl get namespace black-alder-observability &> /dev/null; then
        log_success "✓ Observability namespace created"
    else
        log_warning "✗ Observability namespace missing"
    fi
    
    # Check cell deployments
    CELL_TYPES=("channel" "logic" "data" "security" "external" "integration" "legacy" "observability")
    for cell_type in "${CELL_TYPES[@]}"; do
        if kubectl get namespace "${cell_type}-cell" &> /dev/null; then
            log_success "✓ ${cell_type} cell deployed"
        else
            log_warning "✗ ${cell_type} cell missing"
        fi
    done
    
    # Check key services
    if kubectl get deployment prometheus-grafana -n black-alder-observability &> /dev/null; then
        log_success "✓ Grafana deployed"
    else
        log_warning "✗ Grafana missing"
    fi
    
    if kubectl get deployment prometheus -n black-alder-observability &> /dev/null; then
        log_success "✓ Prometheus deployed"
    else
        log_warning "✗ Prometheus missing"
    fi
    
    log_info "Demo validation complete"
}

# Create demo guide
create_demo_guide() {
    log_section "Creating Demo Execution Guide"
    
    cat > DEMO_EXECUTION_GUIDE.md << 'EOF'
# 🌳 Black Alder Platform Demo Execution Guide

## Quick Start Commands

### 1. Access Monitoring Dashboards
```bash
# Grafana (recommended for live demo)
kubectl port-forward -n black-alder-observability svc/prometheus-grafana 3000:80
# Open: http://localhost:3000 (admin/admin)

# Prometheus (for metrics exploration)
kubectl port-forward -n black-alder-observability svc/prometheus 9090:9090
# Open: http://localhost:9090

# Jaeger (if tracing enabled)
kubectl port-forward -n black-alder-observability svc/jaeger-query 16686:16686
# Open: http://localhost:16686
```

### 2. Demo Scenarios

#### Scenario A: Grove Architecture Overview (5 minutes)
```bash
# Show all cell types
kubectl get namespaces -l "black-alder.io/cell-type"

# Show inter-cell communication
kubectl get networkpolicies --all-namespaces

# Show resource allocation
kubectl top pods --all-namespaces
```

#### Scenario B: Multi-Cloud Capabilities (5 minutes)  
```bash
# Show Crossplane providers
kubectl get providers

# Show compositions
kubectl get compositions

# Show claims
kubectl get claims --all-namespaces
```

#### Scenario C: Observability Deep-dive (10 minutes)
- Navigate to Grafana dashboard
- Show "Black Alder Grove Overview" dashboard
- Demonstrate cell health monitoring
- Show inter-cell communication flows
- Highlight cost and performance metrics

### 3. Interactive Commands

#### Generate Load for Demo
```bash
# Generate traffic between cells
./scripts/generate-cell-traffic.sh

# Scale a cell to show auto-scaling
kubectl scale deployment business-logic --replicas=5 -n logic-cell
```

#### Show Platform Features
```bash
# Show feature toggles
terraform output enabled_features

# Show platform info
terraform output platform_info

# Show access instructions
terraform output access_instructions
```

## Demo Talking Points

### Opening (2 minutes)
- "Like the black alder tree, our platform has three layers..."
- "Deep roots (purpose cells), strong trunk (domain cells), clear canopy (management)"
- "Built for multi-cloud, multi-domain cell architectures"

### Technical Deep-dive (15 minutes)
- Grove-based architecture with 8 specialized cell types
- Multi-cloud orchestration via Crossplane
- "Flip of a switch" observability with eBPF
- Symbiotic optimization partnership capability

### Q&A and Wrap-up (8 minutes)
- Address technical questions
- Provide learning resources
- Schedule follow-up sessions

## Troubleshooting

### If Grafana is not accessible:
```bash
kubectl get pods -n black-alder-observability
kubectl logs -n black-alder-observability deployment/prometheus-grafana
```

### If cells are not ready:
```bash
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
kubectl describe pod <pod-name> -n <namespace>
```
EOF
    
    log_success "Demo execution guide created"
}

# Main execution flow
main() {
    echo "🌳 Black Alder Platform - Comprehensive Technical Demo Setup"
    echo "=========================================================="
    
    check_prerequisites
    setup_demo_config
    deploy_platform_foundation
    deploy_grove_cells  
    setup_monitoring
    setup_demo_data
    validate_deployment
    create_demo_guide
    
    echo
    echo "🎉 Demo setup complete!"
    echo
    echo "Next Steps:"
    echo "1. Access Grafana: kubectl port-forward -n black-alder-observability svc/prometheus-grafana 3000:80"
    echo "2. Open http://localhost:3000 (admin/admin)"
    echo "3. Follow the DEMO_EXECUTION_GUIDE.md for presentation flow"
    echo
    echo "Happy demoing! 🚀"
}

# Execute main function
main "$@"

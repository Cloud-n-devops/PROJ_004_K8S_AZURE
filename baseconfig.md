# See sensitive data
terraform output -raw mysql_generated_password
echo -n $(terraform output -raw mysql_generated_password) | base64

# See Public IP assigned to Ingress
az aks get-credentials --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster
kubectl config current-context
kubectl get nodes
kubectl get ingress gradestar-ingress

kubectl get svc ingress-nginx-controller -n default
kubectl get certificate,order,challenge -n default

<!-- az mysql flexible-server parameter set \
  --resource-group rg-aks-laravel-prod \
  --server-name db-gradestar-prod \
  --name sql_generate_invisible_primary_key \
  --value OFF -->


# pause cluster:
az aks stop --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster

# Reactivate cluster after pause
az aks start --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster

For WSSL:
# Tell Ubuntu to read the config directly from your Windows path
echo 'export KUBECONFIG=/mnt/c/Users/kevoh/.kube/config' >> ~/.bashrc
# Reload your terminal configuration
source ~/.bashrc


# Create a secure directory for system package keys if it doesn't exist
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download the Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/keyrings/kubernetes.list

sudo mv /etc/apt/keyrings/kubernetes.list /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

kubectl version --client --output=yaml


az aks show --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster --query nodeResourceGroup -o tsv

# Paste the MC_ group name you found above into --resource-group
az network nsg list --resource-group MC_rg-aks-laravel-prod_gradestar-aks-cluster_westeurope --query "[].securityRules[].{Name:name, Port:destinationPortRange, Protocol:protocol, Action:action, Priority:priority}" -o table

az network nsg rule create \
  --resource-group MC_rg-aks-laravel-prod_gradestar-aks-cluster_westeurope \
  --nsg-name aks-agentpool-15318537-nsg \
  --name AllowHTTPInbound \
  --priority 100 \
  --destination-port-ranges 80 443 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound



  # see traffic on public IP:
  az monitor metrics list \
  --resource /subscriptions/5dc8f4d2-5cd1-4322-867f-6dacae1cfea0/resourceGroups/MC_rg-aks-laravel-prod_gradestar-aks-cluster_westeurope/providers/Microsoft.Network/publicIPAddresses/kubernetes-a2f7a6c0a20274209af08dcf10e76344 \
  --metrics "BytesReceived" --interval PT1M --aggregation Total

  # change health probe protocol:
  az network lb probe update \
  --resource-group MC_rg-aks-laravel-prod_gradestar-aks-cluster_westeurope \
  --lb-name kubernetes \
  --name ab44eb0840c774bad9c9a8ca9e40a2cc-TCP-80 \
  --protocol Tcp \
  --path ""

  az network lb probe update \
  --resource-group MC_rg-aks-laravel-prod_gradestar-aks-cluster_westeurope \
  --lb-name kubernetes \
  --name ab44eb0840c774bad9c9a8ca9e40a2cc-TCP-443 \
  --protocol Tcp \
  --path ""

# register azure resource provider
az provider register --namespace Microsoft.Dashboard
az provider show --namespace Microsoft.Dashboard --query "registrationState"

# Monitoring stack for kube prometheus stack:
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get ingress -n monitoring
kubectl get certificate -n monitoring

# KQL
ContainerLog
// | where ContainerName == "ingress-nginx-controller"
| where LogEntry has "GET" or LogEntry has "POST"
| project TimeGenerated, ContainerID, LogEntry
| order by TimeGenerated desc
| take 100

ContainerLog
| where LogEntry has "/patient"
| where LogEntry has "GET" or LogEntry has "POST"
| summarize RequestCount = count() by bin(TimeGenerated, 1h)
| order by TimeGenerated desc

# Grafana querry (Analytic Workspace)
ContainerLog
| where LogEntry has "/patient"
| where LogEntry has "GET" or LogEntry has "POST"
// Split the string log row by spaces into an array
| extend LogParts = split(LogEntry, " ")
// Extract the exact index positions for Method, Path, and Status Code
| extend Method = replace_string(tostring(LogParts[5]), "\"", ""),
         Path = tostring(LogParts[6]),
         StatusCode = toint(LogParts[8])
| where Path has "/patient"
| project TimeGenerated, Method, Path, StatusCode


ContainerLog
| where LogEntry has "/patient"
| where LogEntry has "GET" or LogEntry has "POST"
| parse LogEntry with * "\"" Method " " Path " " * "\"" StatusCode " " Remainder
| where Path has "/patient"
| summarize Count = count() by Method, StatusCode, Path
| order by Count desc

# See Previous logs: 
kubectl logs -n monitoring monitoring-grafana-765d49cc88-k9wds -c grafana --previous

# Stop azure resouces for cost saving
az mysql flexible-server stop --resource-group rg-aks-laravel-prod --name db-gradestar-prod
kubectl scale deployment ingress-nginx-controller --replicas=0 -n default
az aks stop --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster

kubectl delete pvc gradestar-assets-pvc

terraform destroy -target=module.observability

# Reinstate
az mysql flexible-server start --resource-group rg-aks-laravel-prod --name db-gradestar-prod
az aks start --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster
kubectl scale deployment ingress-nginx-controller --replicas=1 -n default
terraform apply --auto-approve





# To Resume Your Troubleshooting Environment
az aks start --resource-group rg-aks-laravel-prod --name gradestar-aks-cluster

# Check pod (nginx-ingress-controller) exposed ports
kubectl get pod -n default ingress-nginx-controller-f7fd76cbb-p6c8l -o jsonpath='{.spec.containers[0].ports}'


  # Create user:
  kubectl exec -it deployment/gradestar-app -c php -- php artisan tinker
  \App\Models\User::create([
      'name' => 'kevoh',
      'email' => 'kevohmwach@gmail.com',
      'password' => Hash::make('@Kevoh123'),
      'role' => 3
  ]);

$user = \App\Models\User::where('email', 'kevohmwach@gmail.com')->first();
$user->role = 3; // upgrading to Admin
$user->save();


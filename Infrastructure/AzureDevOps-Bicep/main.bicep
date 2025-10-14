// ========================================
// 🔹 Global Parameters
// ========================================
param location string = resourceGroup().location
param microserviceName string
param environment string

@allowed([ 'single', 'multi' ])
param databaseType string

@allowed([ 'CosmosDB', 'MongoDB' ])
param eventStorageType string

@allowed([ 'PostgreSQL', 'MariaDB', 'MySQL', 'SQLServer', 'Oracle' ])
param entityStorageType string

@allowed([ 'Kafka', 'RabbitMQ', 'Both' ])
param messagingType string

param kafkaNamespaceName string = '${microserviceName}-${environment}-kafka'
param rabbitmqNamespaceName string = '${microserviceName}-${environment}-rabbit'

param tags object = {}

@secure()
param adminPassword string
param adminUser string = 'dbadmin'

// ========================================
// 🔹 AKS Orchestration Parameters
// ========================================
@allowed([ 'none', 'aks' ])
param containerOrchestrator string = 'aks'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.29.2'

@description('Enable advanced AKS features (Workload Identity, Azure Policy, Key Vault CSI)')
param enableAdvancedAksFeatures bool = true

@description('VNet subnet ID for AKS node pools')
param vnetSubnetId string = ''

@description('Log Analytics workspace ID (optional)')
param logAnalyticsId string = ''

@description('Azure Container Registry resource ID (optional)')
param acrId string = ''

// ========================================
// 🔹 Messaging Modules
// ========================================

// Kafka
module kafkaModule './modules/kafka/kafka.bicep' = if (messagingType == 'Kafka' || messagingType == 'Both') {
  name: 'kafkaDeployment'
  params: {
    location: location
    kafkaNamespaceName: kafkaNamespaceName
    microserviceName: microserviceName
    environment: environment
    tags: tags
  }
}

// RabbitMQ
module rabbitmqModule './modules/rabbitmq/rabbitmq.bicep' = if (messagingType == 'RabbitMQ' || messagingType == 'Both') {
  name: 'rabbitmqDeployment'
  params: {
    location: location
    rabbitmqName: rabbitmqNamespaceName
    microserviceName: microserviceName
    environment: environment
    tags: tags
  }
}

// ========================================
// 🔹 Database Modules
// ========================================

// Multi-DB
module multiDbModule './modules/Multi/multi-db.bicep' = if (databaseType == 'multi') {
  name: 'multiDbDeployment'
  params: {
    location: location
    eventStorageType: eventStorageType
    entityStorageType: entityStorageType
    microserviceName: microserviceName
    environment: environment
    tags: tags
    adminUser: adminUser
    adminPassword: adminPassword
  }
}

// Single-DB
module singleDbModule './modules/Single/single-db.bicep' = if (databaseType == 'single') {
  name: 'singleDbDeployment'
  params: {
    location: location
    entityStorageType: entityStorageType
    microserviceName: microserviceName
    environment: environment
    tags: tags
    adminUser: adminUser
    adminPassword: adminPassword
  }
}

// ========================================
// 🔹 Key Vault
// ========================================
module keyVaultModule './modules/keyvault/keyvault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    location: location
    microserviceName: microserviceName
    environment: environment
    tags: tags
  }
}

// ========================================
// 🔹 Optional AKS Cluster
// ========================================
module aksModule './modules/aks/aksCluster.bicep' = if (containerOrchestrator == 'aks') {
  name: 'aksDeployment'
  params: {
    name: '${microserviceName}-${environment}-aks'
    location: location
    vnetSubnetId: vnetSubnetId
    logAnalyticsId: logAnalyticsId
    acrId: acrId
    kubernetesVersion: kubernetesVersion
    enableUptimeSla: true
    enableAzurePolicy: enableAdvancedAksFeatures
    enableWorkloadId: enableAdvancedAksFeatures
  }
}

// ========================================
// 🔹 Outputs (safe for CI/CD + GitOps)
// ========================================

output messagingTypeOut string = messagingType
output databaseTypeOut string = databaseType

output kafkaResourceId string = contains(['Kafka','Both'], messagingType)
  ? kafkaModule.outputs.kafkaNamespaceId
  : ''

output rabbitmqResourceId string = contains(['RabbitMQ','Both'], messagingType)
  ? rabbitmqModule.outputs.rabbitmqId
  : ''

output eventStorageResourceId string = databaseType == 'multi'
  ? multiDbModule.outputs.eventStorageResourceId
  : ''

output entityStorageResourceId string = databaseType == 'multi'
  ? multiDbModule.outputs.entityStorageResourceId
  : singleDbModule.outputs.entityStorageResourceId

output keyVaultId string = keyVaultModule.outputs.keyVaultId
output keyVaultUri string = keyVaultModule.outputs.keyVaultUri

// ---- AKS / GitOps Outputs ----
// Use `contains()` check instead of direct module access to avoid compile errors
output aksClusterId string = containerOrchestrator == 'aks'
  ? any(aksModule.outputs.clusterId)
  : ''

output aksKubeUser string = containerOrchestrator == 'aks'
  ? any(aksModule.outputs.kubeUser)
  : ''

output aksOidcIssuer string = containerOrchestrator == 'aks'
  ? any(aksModule.outputs.oidcIssuerUrl)
  : ''

output aksPrincipalId string = containerOrchestrator == 'aks'
  ? any(aksModule.outputs.principalId)
  : ''

output aksAcrLoginServer string = containerOrchestrator == 'aks'
  ? any(aksModule.outputs.acrLoginServer)
  : ''

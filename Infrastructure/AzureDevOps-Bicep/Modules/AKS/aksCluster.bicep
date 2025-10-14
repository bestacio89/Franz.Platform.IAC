@description('AKS cluster name')
param name string

@description('Resource group location')
param location string = resourceGroup().location

@description('Kubernetes version')
param kubernetesVersion string = '1.29.2'

@description('Subnet ID for AKS node pool')
param vnetSubnetId string

@description('Log Analytics workspace ID')
param logAnalyticsId string

@description('Azure Container Registry resource ID')
param acrId string

@description('Enable Uptime SLA (Paid Tier)')
param enableUptimeSla bool = true

@description('Enable Azure Policy for AKS')
param enableAzurePolicy bool = true

@description('Enable OIDC issuer & workload identity')
param enableWorkloadId bool = true

// -----------------------------------------------------------------------------
// EXISTING RESOURCE REFERENCES
// -----------------------------------------------------------------------------
@description('Reference to the existing ACR')
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01' existing = {
  scope: resourceGroup()
  name: last(split(acrId, '/'))
}

// -----------------------------------------------------------------------------
// AKS CLUSTER DEFINITION
// -----------------------------------------------------------------------------
resource mc 'Microsoft.ContainerService/managedClusters@2024-04-01' = {
  name: name
  location: location
  identity: { type: 'SystemAssigned' }
  sku: {
    name: enableUptimeSla ? 'UptimeSLA' : 'Base'
    tier: enableUptimeSla ? 'Paid' : 'Free'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${name}-dns'
    enableRBAC: true

    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'calico'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
      podCidr: ''
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
    }

    apiServerAccessProfile: {
      enablePrivateCluster: false
    }

    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }

    oidcIssuerProfile: {
      enabled: enableWorkloadId
    }

    workloadIdentityProfile: {
      enabled: enableWorkloadId
    }

    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsId
        }
      }
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          usePodIdentity: 'false'
          enableSecretRotation: 'true'
        }
      }
    }

    sku: {
      name: enableUptimeSla ? 'UptimeSLA' : 'Basic'
      tier: enableUptimeSla ? 'Paid' : 'Free'
    }
  }
}

// -----------------------------------------------------------------------------
// ROLE ASSIGNMENT FOR ACR PULL
// -----------------------------------------------------------------------------
@description('Assign AcrPull role to the AKS managed identity')
resource acrRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(mc.id, acr.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull
    )
    principalId: mc.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// -----------------------------------------------------------------------------
// OUTPUTS FOR GITOPS / CI-CD INTEGRATION
// -----------------------------------------------------------------------------
output kubeAdmin string = mc.listClusterAdminCredential().kubeconfigs[0].value
output kubeUser string = mc.listClusterUserCredential().kubeconfigs[0].value
output oidcIssuerUrl string = enableWorkloadId ? mc.properties.oidcIssuerProfile.issuerURL : ''
output clusterId string = mc.id
output principalId string = mc.identity.principalId
output acrLoginServer string = acr.properties.loginServer

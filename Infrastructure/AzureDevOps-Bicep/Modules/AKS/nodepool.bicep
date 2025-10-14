param clusterName string
param poolName    string
param vmSize      string
param count       int    = 3
param mode        string = 'User' // or 'System'
param zones       array  = [ '1','2','3' ]
param taints      array  = []
param maxPods     int    = 30
param enableSpot  bool   = false

resource pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-04-01' = {
  name: '${clusterName}/${poolName}'
  properties: {
    mode: mode
    vmSize: vmSize
    count: count
    availabilityZones: zones
    enableAutoScaling: true
    minCount: 2
    maxCount: 10
    nodeTaints: enableSpot ? union(taints, ['kubernetes.azure.com/scalesetpriority=spot:NoSchedule']) : taints
    maxPods: maxPods
    scaleSetPriority: enableSpot ? 'Spot' : 'Regular'
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    orchestratorVersion: ''
    upgradeSettings: { maxSurge: '33%' }
  }
}

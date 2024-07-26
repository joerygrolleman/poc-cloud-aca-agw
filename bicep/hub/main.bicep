import {region, sharedTags} from '../shared/sharedVariables.bicep'	

module vnetHub 'br/public:avm/res/network/virtual-network:0.1.8' = {
  name: 'vnetHubDeployment'
  params: {
    // Required parameters
    addressPrefixes: [
      '10.0.0.0/20'
    ]
    name: 'vnet-poc-1-hub'
    // Non-required parameters
    // diagnosticSettings: [
    //   {
    //     eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    //     eventHubName: '<eventHubName>'
    //     metricCategories: [
    //       {
    //         category: 'AllMetrics'
    //       }
    //     ]
    //     name: 'customSetting'
    //     storageAccountResourceId: '<storageAccountResourceId>'
    //     workspaceResourceId: '<workspaceResourceId>'
    //   }
    // ]
    location: region
    tags: sharedTags
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.0.0.0/24'
      }
    ]
    // lock: {
    //   kind: 'ReadOnly'
    //   name: 'HubVnetReadonlyLock'
    // }
  }
}

module publicIpAddress 'br/public:avm/res/network/public-ip-address:0.4.2' = {
  name: 'agwPublicIpAddressDeployment'
  params: {
    name: 'pip-agw-poc-1'
    location: region

    skuName: 'Standard'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'

    roleAssignments: [
      // TODO!!
    ]
    // Do we want a DNS record for the public ip for the Hub?
    // dnsSettings: {

    // }

  }
}

module applicationGateway 'br/public:avm/res/network/application-gateway:0.1.0' = {
  name: 'appGateway'
  params: {
    name: 'agw-arcady'
    frontendIPConfigurations: [
      {
        name: 'agw-fip-poc-1'
        properties:  {
          publicIPAddress: {
            id: publicIpAddress.outputs.resourceId
          }
        }
      }
    ]
    backendAddressPools:[
      {
        name: 'temp_1'
        properties: {
          backendAddresses: [
            {
              fqdn: 'google.nl'
            }
          ]
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'agw-gip-poc-1'
        properties: {
          subnet: {
            id: vnetHub.outputs.subnetResourceIds[0]
          }
        }
      }
    ]
    // httpListeners: [
      
    // ]
    probes: [
      {
        name: 'bp-settings-arcady'
        properties: {
          protocol: 'Http'
          interval: 30
          timeout: 30
          path: '/'
          match: {
            statusCodes: [
              '200'
              '401'
            ]
          }
          minServers: 0
          pickHostNameFromBackendHttpSettings: true
        }
      }
    ]
    enableHttp2: true
  }
}

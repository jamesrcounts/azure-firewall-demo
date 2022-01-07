# Azure Firewall Premium Demo
* [Docs](https://docs.microsoft.com/en-us/azure/firewall/premium-deploy)
* https://azure.microsoft.com/en-us/blog/azure-firewall-premium-now-in-preview-2/
* https://journeyofthegeek.com/2021/07/05/azure-firewall-and-tls-inspection/
* https://docs.microsoft.com/en-us/azure/architecture/example-scenario/gateway/firewall-application-gateway
* https://docs.microsoft.com/en-us/azure/architecture/example-scenario/gateway/application-gateway-before-azure-firewall
* WATCH: https://github.com/Azure/AKS/issues/2259
  * Microsoft is working an a way to add trusted CA certs to AKS nodes
  * Until this happens we are probably not going to be able to inspect outbound node traffic with application rules, network rules can still be used to restrict egress without deep packet inspection.
  * In the meantime containers could still be configured wtih trusted certs and thier traffic could be inspected.
  * Alternative (can have some issues with provisioning/may not work with terraform): http://hypernephelist.com/2021/03/23/kubernetes-containerd-certificate.html
* 
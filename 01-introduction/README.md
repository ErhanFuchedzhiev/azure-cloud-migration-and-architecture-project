# Module 1: Azure Infrastructure, Migration, and Architecture Design

## 1.In this project, I design and implement a complete Azure cloud architecture for a global medical research company migrating from on-premises infrastructure to Microsoft Azure.
My goal is to demonstrate how I approach real-world cloud architecture — from planning and governance to migration, cost optimization, security, and automation.
Through this case study, I show how I design, build, and document end-to-end Azure solutions that align with business requirements and follow architectural best practices. I work across multiple tools and languages, including Azure CLI, PowerShell, Bash, Bicep, and Python, to automate deployments, enforce consistency, and optimize the environment.


## 2.Project Scope and Structure

This project covers the full lifecycle of designing, building, and migrating workloads into Azure:

1.Plan and Create Virtual Machines
I planned the migration of on-premises servers and deployed Azure Virtual Machines configured for secure access, availability, and performance. I applied best practices for compute sizing, storage, and network security.

2.Azure Cost Optimization
I implemented cost optimization strategies by right-sizing VMs, enabling Azure Hybrid Benefit, configuring auto-shutdown, and setting up budget and alert policies to control spending and improve cost visibility.

3.Networking Overview
I built a robust network architecture using Virtual Networks (VNets), subnets, and Network Security Groups (NSGs). Each NSG follows least-privilege principles, restricting access to trusted IPs only. I verified configurations using automation scripts and effective NSG rule analysis.

4.Identity, Governance, and Monitoring
I enforced governance and security through RBAC, Azure Policy, and resource tagging. I configured Azure Monitor, Log Analytics, and Defender for Cloud for real-time visibility, alerting, and compliance.

5.Data Platform, Integration, and Application Services
I built a data platform in Azure by deploying SQL Server, implementing backup and recovery policies, and exploring event-driven integration using Azure Event Grid. I also containerized selected applications with Docker, improving modularity, scalability, and manageability.

6.Automation and Scripting
I automated environment provisioning using PowerShell, Azure CLI, Bash, and Bicep templates. Automation ensures repeatable, consistent deployments across environments and reduces configuration drift.

## 3.Repository Structure
| Module                                                    | Description                                               |
| --------------------------------------------------------- | --------------------------------------------------------- |
| **01-introduction**                                       | Overview of the project and objectives                    |
| **02-plan-and-create-vms**                                | VM planning, configuration, and deployment                |
| **03-azure-cost-optimization**                            | Cost control strategies and automation                    |
| **04-networking-overview**                                | VNet, subnet, and NSG configuration                       |
| **05-identity-governance-monitoring**                     | RBAC, policies, tagging, and monitoring                   |
| **06-data-platform-integration-and-application-overview** | SQL Server, Docker, Event Grid, and integration           |
| **/docs**                                                 | Supporting documentation and diagrams                     |
| **/images**                                               | Screenshots and architecture visuals                      |
| **/scripts**                                              | Automation scripts (Bash, PowerShell, Bicep, CLI, Python) |

## 4.Skills and Tools I Use

- Cloud Architecture: Azure landing zones, hybrid migration, governance
- Networking: VNets, Subnets, NSGs, Bastion, IP restrictions
- Security & Governance: RBAC, Azure Policy, tagging, Defender for Cloud
- Cost Optimization: Azure Hybrid Benefit, auto-shutdown, budgets & alerts
- Data Platform: SQL Server in Azure, backup and recovery, Event Grid integration
- Automation: PowerShell, Bash, Azure CLI, Python, Bicep
- Containers: Docker for modular, lightweight application deployments
- Monitoring: Azure Monitor, Log Analytics, and custom alerts

## 5.Business Impact

By completing this project, I demonstrate how I can design a secure, cost-efficient, and governed Azure environment that meets both business and technical goals.
The architecture supports global collaboration, improves performance, and enables flexible scaling while maintaining strong governance and operational visibility.



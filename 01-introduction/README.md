# Module 1: Azure Infrastructure, Migration, and Architecture Design

## 1.In this project, I design and implement a complete Azure cloud architecture for a global medical research company that is migrating from on-premises infrastructure to Microsoft Azure.
My goal is to demonstrate how I approach real-world cloud architecture — from planning and governance to migration, cost optimization, security, and automation.
Through this case study, I showcase my ability to design, build, and document end-to-end Azure solutions using industry best practices and multiple tools, including Azure CLI, PowerShell, Bash, Bicep, and Python.


## 2.Project Scope and Structure

This project covers the entire lifecycle of designing and migrating an environment into Azure:

1.Plan and Create Virtual Machines
I planned the migration of on-premises servers and created Azure Virtual Machines configured for secure remote access, availability, and performance.

2.Azure Cost Optimization
I optimized VM sizing, applied Azure Hybrid Benefit, enabled auto-shutdown, and implemented budget and alert policies to control spend.

3.Networking Overview
I built a network design with Virtual Networks (VNets), subnets, and Network Security Groups (NSGs) that restrict access to trusted sources. I verified security using effective NSG rules and automation scripts.

4.Identity, Governance, and Monitoring
I enforced access control through RBAC, Azure Policy, and resource tagging. I integrated Azure Monitor, Log Analytics, and Defender for Cloud to centralize monitoring and strengthen security posture.

5.Data Platform, Integration, and Application Services
I deployed a SQL Server instance, implemented backup and recovery, and experimented with event-driven integration using Azure Event Grid. I also containerized selected components using Docker for modularity and scalability.

6.Automation and Scripting
I automated many configuration steps with PowerShell, Azure CLI, Bash, and Bicep templates, ensuring my environment could be rebuilt quickly and reliably.

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
- Networking: VNet, Subnet, NSG, Bastion, IP restrictions
- Security & Governance: RBAC, Azure Policy, tagging, Defender for Cloud
- Cost Optimization: Azure Hybrid Benefit, auto-shutdown, budgets & alerts
- Data Platform: SQL Server in Azure, backup and recovery, Event Grid integration
- Automation: PowerShell, Bash, Azure CLI, Python, Bicep
- Containers: Docker for lightweight app deployments and testing
- Monitoring: Azure Monitor, Log Analytics, custom alerts

## 5.Learning Outcome

By completing this project, I demonstrate my ability to:

- Translate business needs into cloud architecture.
- Design secure, cost-effective, and governed Azure environments.
- Automate deployments for consistency and scalability.
- Deliver clear documentation and visual architecture like a real-world Azure Architect.

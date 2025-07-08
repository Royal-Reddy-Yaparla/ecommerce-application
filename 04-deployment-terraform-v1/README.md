
# Application Deployment Automation using Terraform & Ansible

This repository automates the infrastructure and partial application deployment of a microservices-based architecture using **Terraform** (for AWS provisioning) and **Ansible** (for configuration management).

---

## Version 1  (Completed)

- Modular Terraform structure for reusability
- Secure, scalable, and highly available environment
- Basic automation of app components via Ansible

---

## Project Folder Structure

```
infrastructure-dev
    .
    ├── 00-vpc/               # VPC, subnets, and networking
    ├── 01-sg/                # Security groups for app tiers
    ├── 02-bastion/           # Bastion host for secure SSH access
    ├── 03-vpn/               # VPN Gateway or client configuration (if applicable)
    ├── 04-iam/               # IAM roles, instance profiles
    ├── 05-databases/         # MongoDB, MySQL DB provisioning
    ├── 06-backend-alb/       # Internal ALB for backend services
    ├── 07-catalogue/         # Catalogue service deployment (Terraform + Ansible)
    ├── 08-acm/               # AWS ACM SSL certificate provisioning
    ├── 09-frontend-alb/      # Public ALB for frontend with HTTPS
    └── 10-frontend/          # Frontend deployment and configuration
modules

```

---

## Tools Used

| Tool       | Purpose                                 |
|------------|-----------------------------------------|
| **Terraform** | Infrastructure as Code (IaC)            |
| **Ansible**   | Provisioning and App Configuration     |
| **AWS**       | Cloud Provider                         |
| **ALB**       | Load Balancing (Internal + External)   |
| **ACM**       | TLS Certificates                       |
| **Auto Scaling** | Scalable backend instances         |


---

## Completed Components

| Component        | Description                                |
|------------------|---------------------------------------------|
| **VPC**          | Multi-AZ VPC with public, private subnets   |
| **Security Groups** | Fine-grained SGs for app layers         |
| **Bastion Host** | SSH access to private instances             |
| **Databases**    | MongoDB & MySQL with user data              |
| **Catalogue Service** | Automated with Ansible, behind ALB    |
| **Frontend**     | Public app served via ALB with ACM cert     |
| **ACM**          | SSL for frontend ALB (HTTPS termination)    |
| **Auto Scaling** | Backend service scalability (AMI-based)     |
|**AWS Secrets Manager**    | secrets management        |
|**Route53**    |- Automate DNS mapping (Route53) per service    |


---

## Notes

- **Catalogue** service is fully automated using Terraform + Ansible
- **Frontend** served over HTTPS with Route53 + ACM + ALB
- ALBs are configured for both frontend (public) and backend (internal)
- Databases are deployed and configured securely
- IAM roles created for EC2 and service access

---

## Next Steps (Version 2)

- Create **custom Terraform module** for all backend services (like user, cart, payment, shipping)

---

##  How to Use

```bash
# Navigate into each folder and apply Terraform configs
cd 00-vpc && terraform apply
cd ../01-sg && terraform apply
# ...
```

> Note: Ensure Terraform backend and AWS CLI credentials are configured.

---

## Author

**Royal Reddy Yaparla**  
📧 iamroyareddy@gmail.com  
🔗 [GitHub](https://github.com/Royal-Reddy-Yaparla) | [LinkedIn](https://linkedin.com/in/royalreddy/)

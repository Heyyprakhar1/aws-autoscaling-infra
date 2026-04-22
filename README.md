# 🚀 AWS Auto Scaling Infra — Terraform IaC

A production-grade, modular Terraform project that provisions a fully functional auto-scaling web application infrastructure on AWS. Built to demonstrate real-world DevOps skills — not just "terraform apply and pray."

> ✅ **Status: Live** — 28 resources successfully provisioned on AWS (`ap-south-1`)

---

## 📌 What This Project Does

This project spins up a complete, highly available web application backend on AWS using Infrastructure as Code. Every resource is provisioned through Terraform — no manual clicking in the console.

Here's what gets created:

- A custom **VPC** with public and private subnets across 2 Availability Zones (`ap-south-1a` + `ap-south-1b`)
- An **Application Load Balancer (ALB)** in the public subnet to distribute traffic
- An **Auto Scaling Group (ASG)** with a Launch Template that boots EC2 instances automatically
- An **RDS MySQL instance** sitting safely in a private subnet — not exposed to the internet
- **Security Groups** with least-privilege rules (ALB → EC2 → RDS, nothing more)
- **CloudWatch Alarms** that trigger scale-up/scale-down based on CPU usage
- Local state currently — **remote state (S3 + DynamoDB)** setup planned

---

## 🏗️ Architecture

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │     ALB      │  (Public Subnets)
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │      Auto Scaling       │
              │    Group (EC2 fleet)    │  (Private Subnets)
              └────────────┬────────────┘
                           │
                    ┌──────▼──────┐
                    │  RDS MySQL  │  (Private Subnets)
                    └─────────────┘

CloudWatch Alarms ──► Scaling Policies ──► ASG
```

---

## 📁 Project Structure

```
aws-autoscaling-infra/
├── main.tf                  # Root module — wires all child modules together
├── variables.tf             # All input variables declared here
├── outputs.tf               # Useful outputs: ALB DNS, RDS endpoint, VPC ID
├── terraform.tfvars         # Actual values — DO NOT push to Git
├── backend.tf               # Backend config (local state currently)
├── provider.tf              # AWS provider + region
│
└── modules/
    ├── vpc/                 # VPC, subnets, IGW, NAT Gateway, route tables
    ├── security_groups/     # SGs for ALB, EC2, and RDS
    ├── alb/                 # ALB + target group + listener
    ├── asg/                 # Launch Template + ASG + scaling policy
    ├── rds/                 # RDS instance + DB subnet group
    └── cloudwatch/          # CPU alarms → ASG scaling (in progress)
```

Each module follows the same pattern:
```
module/
├── main.tf        # Resources
├── variables.tf   # Inputs
└── outputs.tf     # Exported values
```

---

## ⚙️ Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform CLI | >= 1.5.0 | Infrastructure provisioning |
| AWS CLI | v2 | Auth + profile management |
| An AWS Account | — | Where infra gets deployed |

### AWS Setup

1. Create a dedicated IAM user — never use root credentials with Terraform
2. Attach `AdministratorAccess` policy (scope it down in production)
3. Configure locally:

```bash
aws configure
```

### Key Pair Setup

Create a key pair before running apply:

```bash
aws ec2 create-key-pair \
  --key-name autoscaling-infra-key \
  --query 'KeyMaterial' \
  --output text \
  --region ap-south-1 > autoscaling-infra-key.pem

chmod 400 autoscaling-infra-key.pem
```

---

## 🔧 Configuration

Create a `terraform.tfvars` file with your values (this file is gitignored):

```hcl
aws_region   = "ap-south-1"
project_name = "autoscaling-infra"
environment  = "dev"

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

# EC2 / ASG
instance_type    = "t3.micro"
image_id         = "ami-xxxxxxxxxxxxxxxxx"   # Amazon Linux 2 — ap-south-1
key_name         = "autoscaling-infra-key"
min_size         = 1
max_size         = 4
desired_capacity = 2

# RDS
db_instance_class = "db.t3.micro"
db_name           = "mydatabase"
db_username       = "admin"
db_password       = "yourpassword"   # Use AWS Secrets Manager in production
```

To find the latest Amazon Linux 2 AMI for `ap-south-1`:

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query "Images[0].ImageId" \
  --output text \
  --region ap-south-1
```

---

## 🚀 How to Run

```bash
# Step 1 — Initialize Terraform
terraform init

# Step 2 — Validate config
terraform validate

# Step 3 — Preview changes
terraform plan

# Step 4 — Apply
terraform apply

# Step 5 — Destroy when done (avoid AWS bills)
terraform destroy
```

---

## 📤 Outputs

After `terraform apply` completes:

| Output | Description |
|--------|-------------|
| `alb_dns_name` | ALB DNS — hit this in the browser to verify |
| `rds_endpoint` | RDS connection endpoint (port 3306) |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `alb_sg_id` | ALB Security Group ID |
| `target_group_arn` | ALB Target Group ARN |

---

## 🔐 Security Decisions

| Decision | Why |
|----------|-----|
| RDS in private subnet | Not reachable from the internet — only from EC2 SG |
| ALB SG allows `0.0.0.0/0` on 80/443 | It's a public load balancer — intentional |
| EC2 SG only allows traffic from ALB SG | Instances not directly exposed |
| RDS SG only allows traffic from EC2 SG | DB accessible only from app layer |
| No credentials in `.tf` files | Secrets go in `terraform.tfvars` (gitignored) |
| `sensitive = true` on `db_password` | Password masked in `terraform output` |

---

## 📈 How Auto Scaling Works

1. CloudWatch monitors **CPU utilization** across ASG instances
2. CPU > **70%** for 2 minutes → alarm triggers → ASG adds 1 instance
3. CPU < **30%** for 5 minutes → alarm triggers → ASG removes 1 instance
4. ALB automatically routes traffic to healthy instances only

To test scaling manually:

```bash
# SSH into an EC2 instance, then:
sudo yum install stress -y
stress --cpu 4 --timeout 300
```

Watch the ASG in AWS Console — new instances should appear within ~2 minutes.

---

## 🧠 Key Learnings

- How Terraform modules pass data via `outputs` and `variables` — and why root `outputs.tf` and module `outputs.tf` are different files with different purposes
- Why `var.vpc_id` is used inside a module, never `module.vpc.vpc_id`
- How Security Groups chain together (ALB → EC2 → RDS) — SG IDs as sources, not CIDR blocks
- Why `eu-west-1` in AWS CLI config while using `ap-south-1a` AZs will silently pass `plan` but fail on `apply`
- Why `.terraform.lock.hcl` should be committed — it locks provider versions across environments

---

## 📝 .gitignore

```
.terraform/
*.tfstate
*.tfstate.backup
*.tfplan
terraform.tfvars
*.pem
```

> Note: `.terraform.lock.hcl` is intentionally **NOT** gitignored — it locks provider versions and should be committed.

---

## 🗺️ Roadmap

- [X] CloudWatch alarms module
- [ ] Remote state backend (S3 + DynamoDB)
- [ ] HTTPS support — ACM cert + ALB HTTPS listener
- [ ] Ansible branch — configuration management on top of this infra

---

## 🙋 Author

**Prakhar Srivastava**
DevOps Engineer | AWS | Terraform | Kubernetes

- GitHub: [github.com/Heyyprakhar1](https://github.com/Heyyprakhar1)
- Blog: [heyyprakhar01.hashnode.dev](https://heyyprakhar01.hashnode.dev)
- Portfolio: [prakharsrivastavadevops.netlify.app](https://prakharsrivastavadevops.netlify.app)
- LinkedIn: [linkedin.com/in/heyyprakhar1](https://linkedin.com/in/heyyprakhar1)

---

> ⚠️ This project is for learning and portfolio purposes. Before production use: replace hardcoded secrets with AWS Secrets Manager, restrict IAM permissions to least privilege, enable VPC Flow Logs, and add HTTPS via ACM.

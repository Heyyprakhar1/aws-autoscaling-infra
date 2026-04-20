# 🚀 AWS Auto Scaling Infra — Terraform IaC

A production-grade, modular Terraform project that provisions a fully functional auto-scaling web application infrastructure on AWS. Built to demonstrate real-world DevOps skills — not just "terraform apply and pray."

---

## 📌 What This Project Does

This project spins up a complete, highly available web application backend on AWS using Infrastructure as Code. Every resource is provisioned through Terraform — no manual clicking in the console.

Here's what gets created:

- A custom **VPC** with public and private subnets across multiple Availability Zones
- An **Application Load Balancer (ALB)** in the public subnet to distribute traffic
- An **Auto Scaling Group (ASG)** with a Launch Template that boots EC2 instances automatically
- An **RDS MySQL instance** sitting safely in a private subnet — not exposed to the internet
- **Security Groups** with least-privilege rules (ALB → EC2 → RDS, nothing more)
- **CloudWatch Alarms** that trigger scale-up/scale-down based on CPU usage
- **Remote state** stored in S3 with DynamoDB locking — so state never gets corrupted

---

## 🏗️ Architecture Diagram

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
├── outputs.tf               # Useful outputs: ALB DNS, ASG name, RDS endpoint
├── terraform.tfvars         # Actual values — DO NOT push to Git
├── backend.tf               # Remote state: S3 bucket + DynamoDB lock table
├── provider.tf              # AWS provider configuration
│
└── modules/
    ├── vpc/                 # VPC, subnets, IGW, NAT, route tables
    ├── security_groups/     # SGs for ALB, EC2, and RDS
    ├── alb/                 # Application Load Balancer + target group + listener
    ├── asg/                 # Launch Template + Auto Scaling Group + scaling policies
    ├── rds/                 # RDS instance + DB subnet group
    └── cloudwatch/          # CPU alarms tied to ASG scaling policies
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

Make sure you have the following installed and configured before running this project.

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform CLI | >= 1.5.0 | Infrastructure provisioning |
| AWS CLI | v2 | Auth + profile management |
| An AWS Account | — | Where infra gets deployed |

### AWS Setup

1. Create a dedicated IAM user called `terraform-admin` (never use root)
2. Attach `AdministratorAccess` policy (scope it down later in production)
3. Generate access keys and configure locally:

```bash
aws configure --profile terraform-admin
```

### Remote Backend Setup (do this once manually)

Before running `terraform init`, create the S3 bucket and DynamoDB table for state:

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket your-tf-state-bucket \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket your-tf-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

---

## 🔧 Configuration

Copy the example vars file and fill in your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Key variables to configure in `terraform.tfvars`:

```hcl
aws_region         = "ap-south-1"
project_name       = "autoscaling-infra"
environment        = "dev"

vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["ap-south-1a", "ap-south-1b"]

instance_type      = "t3.micro"
ami_id             = "ami-xxxxxxxxxxxxxxxxx"   # Amazon Linux 2
min_size           = 1
max_size           = 4
desired_capacity   = 2

db_instance_class  = "db.t3.micro"
db_name            = "appdb"
db_username        = "admin"
db_password        = "changeme123"             # Use AWS Secrets Manager in production
```

---

## 🚀 How to Run

```bash
# Step 1 — Initialize Terraform (downloads providers, sets up backend)
terraform init

# Step 2 — Validate your config (catch syntax errors early)
terraform validate

# Step 3 — Preview what will be created
terraform plan -var-file="terraform.tfvars"

# Step 4 — Apply and provision everything
terraform apply -var-file="terraform.tfvars"

# Step 5 — Destroy when done (avoid surprise AWS bills)
terraform destroy -var-file="terraform.tfvars"
```

---

## 📤 Outputs

After a successful `terraform apply`, you'll see:

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Hit this URL in the browser to verify the app |
| `asg_name` | Name of the Auto Scaling Group |
| `rds_endpoint` | Endpoint for your app to connect to the database |
| `vpc_id` | VPC ID for reference |

---

## 🔐 Security Decisions

| Decision | Why |
|----------|-----|
| RDS in private subnet | Not reachable from the internet, only from EC2 SG |
| ALB SG allows 0.0.0.0/0 on 80/443 | It's a public load balancer — that's expected |
| EC2 SG only allows traffic from ALB SG | Not exposed directly; traffic must go through ALB |
| RDS SG only allows traffic from EC2 SG | Database only accessible from app layer |
| No hardcoded credentials in `.tf` files | Secrets go in `terraform.tfvars` (gitignored) |

---

## 📈 How Auto Scaling Works Here

1. CloudWatch monitors **CPU utilization** of the ASG instances
2. If average CPU > **70%** for 2 minutes → alarm triggers → ASG adds 1 instance
3. If average CPU < **30%** for 5 minutes → alarm triggers → ASG removes 1 instance
4. ALB automatically routes traffic to healthy instances; unhealthy ones get replaced

You can test this by SSH-ing into an instance and running a CPU stress test:
```bash
sudo yum install stress -y
stress --cpu 4 --timeout 300
```
Then watch the ASG scale up in the AWS console.

---

## 🧠 Key Learnings From This Project

- How Terraform modules pass data to each other via `outputs` and `variables`
- Why remote state with locking matters in team environments
- How Security Groups work in layers (ALB → EC2 → RDS) — not flat rules
- The difference between a Launch Template and a Launch Configuration
- How CloudWatch alarms wire into ASG scaling policies

---

## 📝 .gitignore

```
.terraform/
*.tfstate
*.tfstate.backup
*.tfplan
terraform.tfvars
.terraform.lock.hcl
```

---

## 🙋 Author

**Prakhar Srivastava**
DevOps Engineer | AWS | Terraform | Kubernetes

- GitHub: [github.com/Heyyprakhar1](https://github.com/Heyyprakhar1)
- Blog: [hashnode.com/@heyyprakhar01](https://hashnode.com/@heyyprakhar01)
- Portfolio: [prakharsrivastavadevops.netlify.app](https://prakharsrivastavadevops.netlify.app)

---

> ⚠️ **Note:** This project is for learning and portfolio purposes. Before using in production, replace hardcoded secrets with AWS Secrets Manager, restrict IAM permissions, and enable VPC Flow Logs.

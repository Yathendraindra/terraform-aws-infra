# 🌩️ Terraform AWS Infrastructure — `terraform-aws-infra`

Provision **VPC, EC2, RDS, S3, and Application Load Balancer (ALB)** using Terraform.

This project demonstrates an end-to-end AWS infrastructure setup following modular, phase-wise automation.

---

## 🧱 Architecture Overview


The setup includes:

⦁	Multi-AZ public and private subnets

⦁	Internet Gateway and NAT Gateway for secure access

⦁	EC2 in a public subnet, RDS in private subnets

⦁	S3 bucket for artifact storage

⦁	Application Load Balancer distributing traffic to EC2

---


📁 Project Structure

terraform-aws-infra/

├── main.tf

├── outputs.tf

├── variables.tf

├── provider.tf

├── .gitignore

└── README.md


---

🚀 Deployment Instructions

1️⃣ Initialize Terraform  - $ terraform init

Downloads necessary provider plugins and initializes the backend.

2️⃣ Validate Configuration  -  $ terraform validate


Ensures syntax and references are correct.

3️⃣ Review the Plan  - $ terraform plan


Displays the list of resources that Terraform will create or modify.

4️⃣ Apply Infrastructure -  $ terraform apply

Creates all AWS resources defined in main.tf.

---


📦 Key Outputs

After apply, Terraform displays the following outputs:

vpc_id	    

public_subnet_id	 

private_subnet_ids	   

internet_gateway_id	 

nat_gateway_id	  

ec2_public_ip	 

alb_dns_name	

rds_endpoint	 

rds_port	     

s3_bucket_name	       


To view them anytime:  Use  $ terraform output

---


🧹 Cleanup — Destroy Infrastructure

To avoid ongoing AWS charges:  -  $ terraform destroy -auto-approve

This command removes all created AWS resources safely.


---

🧠 Optional Enhancements:

⦁	Add a variables.tf file for parameterized region, instance type, and credentials

⦁	Store remote state using S3 + DynamoDB for team collaboration

⦁	Add user_data to bootstrap your web app on EC2 automatically

⦁	Integrate Terraform with GitHub Actions or Terraform Cloud for CI/CD automation


---

✅ Summary

This project provisions a complete, secure AWS environment using Terraform:

⦁	VPC, Subnets, and Route Tables

⦁	Internet Gateway and NAT Gateway

⦁	EC2 and RDS (MySQL)

⦁	S3 bucket with versioning

⦁	Application Load Balancer with EC2 target attachment


All resources are verified via successful terraform apply and are fully functional.

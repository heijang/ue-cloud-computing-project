# Building a Highly Available, Scalable Web Application

## Overview and Objectives

This project challenges you to build a solution on AWS without step-by-step guidance, using AWS services to host a student records web application as a Proof of Concept (POC) for Example University.

### Learning Objectives

By the end of this project, you should be able to:

- Create an architectural diagram depicting AWS services and their interactions
- Estimate costs using the AWS Pricing Calculator
- Deploy a functional web application on a single VM backed by a relational database
- Architect a web application separating layers (web server / database)
- Create a virtual network configured to host a publicly accessible, secure web application
- Deploy a web application with load distributed across multiple web servers
- Configure appropriate network security settings for web servers and database
- Implement high availability and scalability in the deployed solution
- Configure access permissions between AWS services

---

## Scenario

**Example University** admissions department has complaints that their student records web application is slow or unavailable during peak admissions periods due to high inquiry volume.

**Your role:** Cloud engineer building infrastructure for a POC that hosts the student records web application in the AWS Cloud, following AWS Well-Architected Framework best practices. During peak admissions, the application must support **thousands of users** and be:

- Highly available
- Scalable
- Load balanced
- Secure
- High performing

**Application features:** Users can view, add, delete, and modify student records.

---

## Solution Requirements

| Requirement | Description |
|---|---|
| **Functional** | View, add, delete, or modify student records without perceivable delay |
| **Load balanced** | Properly balance user traffic to avoid overloaded/underutilized resources |
| **Scalable** | Designed to scale to meet demands placed on the application |
| **Highly available** | Limited downtime when a web server becomes unavailable |
| **Cost optimized** | Designed to keep costs low |
| **High performing** | Routine operations performed without perceivable delay under normal, variable, and peak loads |

### Security Requirements

- Database is secured and **cannot be accessed directly from public networks**
- Web servers and database accessible only over **appropriate ports**
- Web application is accessible over the internet
- Database credentials are **NOT hardcoded** into the web application

---

## Assumptions / Constraints

- Application deployed in **a single AWS Region** (no multi-Region required)
- Website does **NOT** need HTTPS or a custom domain
- Solution deployed on **Ubuntu** machines using the provided JavaScript code
- Use the JavaScript code **as written** unless instructions explicitly direct changes
- Solution uses services within the restrictions of the lab environment
- Database is hosted in a **single Availability Zone**
- Website is publicly accessible **without authentication**
- Cost estimation is approximate

---

## Phase 1: Planning the Design and Estimating Cost

### Task 1: Architectural Diagram
Create an architectural diagram illustrating the planned solution. Consider how each requirement will be accomplished.

**References:** AWS Architecture Icons, AWS Reference Architecture Diagrams

### Task 2: Cost Estimate
Develop a cost estimate to run the solution in **us-east-1** Region for **12 months** using the AWS Pricing Calculator.

---

## Phase 2: Creating a Basic Functional Web Application

Goal: A functional web application that works on a single virtual machine in a virtual network.

### Task 1: Create a Virtual Network
Create a VPC and subnets to host the web application.

### Task 2: Create a Virtual Machine
- Use Amazon EC2
- Use the latest **Ubuntu AMI**
- Install web app + database using the provided JavaScript code (**SolutionCodePOC**)

### Task 3: Test the Deployment
Verify the web application is accessible from the internet using the **IPv4 address** of the VM. Perform view/add/delete/modify operations.

---

## Phase 3: Decoupling the Application Components

Goal: Separate the database and web server infrastructure so they run independently. Web app on a separate VM, database on managed service infrastructure.

### Task 1: Change the VPC Configuration
Update or recreate the VPC to support hosting the database separately.

> **Required:** Private subnets in a **minimum of two Availability Zones**.

### Task 2: Create and Configure Amazon RDS Database
- Create an **Amazon RDS** database running the **MySQL** engine (provisioned or serverless)
- **Only the web application** can access the database
- **Do NOT enable enhanced monitoring**

### Task 3: Configure Development Environment
Provision an **AWS Cloud9** environment to run AWS CLI commands:
- Use a **t3.micro** instance
- Connect via **SSH**

### Task 4: Provision Secrets Manager
Use **AWS Secrets Manager** to store database credentials. Configure the web application to use Secrets Manager.

- Use **Script-1** from `cloud9-scripts.yml` (AWS Cloud9 Scripts) to create the secret via AWS CLI

### Task 5: Provision a New Instance for the Web Server
- Create a new EC2 VM to host the web application
- Install web app using the JavaScript code (**Solution Code for the App Server**)
- Attach the existing **LabInstanceProfile** IAM profile (which uses **LabRole**) to enable secure secret fetching

### Task 6: Migrate the Database
Migrate data from the original EC2 database to the new Amazon RDS database using **Script-3** from `cloud9-scripts.yml`.

### Task 7: Test the Application
Access the app and perform view/add/delete/modify operations.

---

## Phase 4: Implementing High Availability and Scalability

Goal: Build a scalable and highly available architecture using earlier components.

### Task 1: Create an Application Load Balancer (ALB)
- The ALB endpoint will be used to access the web application
- Use a **minimum of two Availability Zones**

### Task 2: Implement Amazon EC2 Auto Scaling
- Create a new **launch template**
- Create an **Auto Scaling group** to launch EC2 web app instances
- Create an AMI from a running instance (or new AMI with required packages/code)
- Configure the ASG to use the load balancer

**Tips:**
- Use a **Target tracking** policy
- Set ASG size based on estimated requirements
- Start with defaults (group size, CPU utilization), adjust later

### Task 3: Access the Application
Test via the ALB URL. Perform view/add/delete/modify operations.

### Task 4: Load Test the Application
Perform a load test to monitor scaling:
- Use **Script-2** from `cloud9-scripts.yml`
- Access via the load balancer URL from a browser
- Run load tests from AWS Cloud9 against the load balancer

**Reference:** `loadtest` Tool Repository on GitHub

---

## Key AWS Services Used

| Service | Purpose |
|---|---|
| Amazon VPC + Subnets | Virtual network (public + private subnets across 2+ AZs) |
| Amazon EC2 | Web server hosts (Ubuntu) |
| Amazon RDS (MySQL) | Managed relational database |
| Application Load Balancer | Distribute traffic across web servers |
| EC2 Auto Scaling | Scale web tier based on load |
| AWS Secrets Manager | Store DB credentials securely |
| IAM (LabRole / LabInstanceProfile) | Permissions for EC2 to access Secrets Manager |
| AWS Cloud9 | Dev environment for AWS CLI / load testing |

---

## Important Notes on Lab Environment

- Long-lived environment; resources persist across sessions until budget exhausted or course end date
- **Monitor lab budget** — exceeding it disables the account and loses all progress
- AWS service access is restricted to services needed for the lab
- Choosing **End Lab** does NOT delete resources; resources persist for the next session

---

## Disclaimer

A security best practice would be to restrict access to the website via the university network and require authentication. These are out of scope for the POC but encouraged as enhancements.

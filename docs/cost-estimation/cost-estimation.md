# Cost Estimation — Guide

This document explains how to produce the monthly cost estimate for this POC using
the **AWS Pricing Calculator**, based on the resources **actually running in AWS**.
It lists the billable resources, the step-by-step calculator workflow, and how to
lay out the final cost table for the report.

---

## Scope

- Region: **us-east-1** only.
- Estimate **only** the resources actually deployed in the AWS account — no
  extra/assumed services.
- Use the **architecture already running** (this is not a re-design).

---

## 1. Billable resources

Most networking/IAM objects are **free**; cost is driven by a handful of resources.

### Resources that cost money

| # | Service | What it is | Config | Cost driver |
|---|---|---|---|---|
| 1 | **EC2 (web tier)** | Web servers behind the ALB | **t3.micro**, **2** running (auto-scales **2 → 4**) | Per-instance hour × instance count |
| 2 | **EBS** | Root volume of each EC2 | gp3/gp2, ~8 GB each | GB-month × instance count |
| 3 | **Application Load Balancer** | 1 ALB, HTTP:80 | internet-facing | ALB-hour + LCU-hour |
| 4 | **RDS (MySQL)** | Managed database | **db.t3.micro**, **20 GB** (autoscale→100), **Multi-AZ** | Instance-hour (×2 for Multi-AZ) + storage GB-month |
| 5 | **Secrets Manager** | DB credentials store | 1 secret | $/secret-month + per-10k API calls |
| 6 | **Data transfer out** | Internet egress from ALB/EC2 | — | GB-month over free tier |

> **Note on RDS Multi-AZ:** the database runs as **Multi-AZ** — the standard
> high-availability choice. Multi-AZ roughly **doubles** the RDS instance cost vs
> Single-AZ; this is intentional (HA is prioritized over cost for this workload).
> Estimate RDS as **Multi-AZ** so the figure matches what is running.

### Resources that are FREE (list as $0 for completeness)

VPC, subnets, route tables, Internet Gateway, security groups, target group, Auto
Scaling group/policy, IAM role + instance profile, key pair. **No NAT Gateway**
(web tier is in public subnets) and **no Elastic IP** — both would otherwise be
significant costs, so call out that they are intentionally absent.

---

## 2. How to estimate — AWS Pricing Calculator

The calculator needs **no login** and does not touch your account.

### Steps

1. Go to **https://calculator.aws** → **Create estimate**.
2. For each billable service: **Add service** → search the service name → **Configure**.
3. Always set **Region = US East (N. Virginia) / us-east-1**.
4. Configure each service with the values from the table above:

   | Service to add | Key inputs to enter |
   |---|---|
   | **Amazon EC2** | t3.micro; **Quantity = 2** (baseline) — optionally add a second line at Quantity 4 for the peak/scaled-out case; On-Demand, Linux; usage 730 hrs/mo; add ~8 GB gp3 EBS per instance |
   | **Elastic Load Balancing** | Application Load Balancer; 1 ALB; estimate LCUs from expected traffic (a low value is fine for a POC) |
   | **Amazon RDS for MySQL** | db.t3.micro; **Multi-AZ**; 730 hrs/mo; 20 GB gp2/gp3 storage |
   | **AWS Secrets Manager** | 1 secret; a small number of API calls/month |
   | **Data Transfer** | a modest GB/month of outbound (POC-level) |

5. Each service shows a **monthly** and **upfront** cost. Use **monthly**.
6. Click **Save and add service** to accumulate, then view the **estimate summary**
   for the grand total.
7. **Export** the estimate: use **Share** (public link) and/or **Export → CSV/PDF**
   for the report appendix.

> Tip: model two scenarios — **baseline (2 EC2)** and **peak (4 EC2)** — so the
> report shows the cost range across the Auto Scaling band.

---

## 3. How to build the cost table (for the report / slides)

Keep one summary table. Suggested columns:

| Service | Configuration | Qty | Unit basis | Monthly (USD) |
|---|---|---|---|---|
| EC2 (web tier) | t3.micro, Linux, On-Demand | 2 | 730 hrs/instance | _from calc_ |
| EBS root volumes | gp3, ~8 GB | 2 | GB-month | _from calc_ |
| Application Load Balancer | 1 ALB, HTTP | 1 | ALB-hr + LCU | _from calc_ |
| RDS MySQL | db.t3.micro, Multi-AZ | 1 | 730 hrs + 20 GB | _from calc_ |
| Secrets Manager | 1 secret | 1 | secret-month | _from calc_ |
| Data transfer out | egress | — | GB-month | _from calc_ |
| Networking (VPC/subnets/IGW/SG/ASG/IAM) | — | — | free | $0.00 |
| **Total (baseline)** | | | | **$X / mo** |
| **Total (peak, 4× EC2)** | | | | **$Y / mo** |

### Single-slide layout

Everything fits on **one slide**. Suggested structure, top to bottom:

1. **Title + scope line (1 line):** e.g. *"Monthly cost estimate — resources
   running in AWS, region us-east-1, On-Demand."*
2. **Cost table (center):** the summary table above. Keep the rows compact; the
   **Total (baseline)** and **Total (peak, 4× EC2)** rows are the headline.
3. **Assumptions footnote (small text, 1–2 lines):** t3.micro / db.t3.micro,
   730 hrs/mo, RDS **Multi-AZ**, **no NAT/EIP**, On-Demand; + the saved AWS
   Pricing Calculator link.

> Keep it to one slide: lead with the **baseline vs peak total**, let the table
> support it, and push all caveats into a small footnote rather than extra slides.

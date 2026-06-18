# Performance / Load Testing — Procedure

This document describes how to satisfy **Task 4: Load Test the Application** from
`docs/requirments.md`: drive load against the ALB and observe the Auto Scaling
Group scale **out** under load and scale **in** after the load stops.

> Korean version: [load-testing-kr.md](load-testing-kr.md)

---

## Goal

The requirement is **not** "run one specific tool" — it is to *prove the web tier
auto-scales*. Concretely you must show, with evidence (CloudWatch + ASG activity):

1. **Scale-out** — CPU rises above target → ASG adds instances.
2. **Steady state** — instances stay added while load continues.
3. **Scale-in** — load stops → CPU falls → ASG removes instances.

---

## What the infrastructure does (from `src/modules/compute`)

| Setting | Value | Effect on the test |
|---|---|---|
| ASG min / desired / max | **2 / 2 / 4** | Starts at 2, can grow to **4** instances max |
| Instance type | **t3.micro** | Small CPU → easy to push past target with load |
| Scaling policy | **Target tracking, `ASGAverageCPUUtilization`** | Adjusts capacity to hold average CPU near target |
| Target value | **50%** | Above 50% avg CPU → scale-out; well below → scale-in |
| ALB listener | **HTTP : 80** | Load target is `http://<ALB DNS>` (no HTTPS in this POC) |

**Timing characteristics of target tracking** (AWS defaults, not configured here):

- **Scale-out** is fast: the high-CPU alarm needs ~**3 consecutive 1-min datapoints** (~3 min), then capacity is added.
- **Scale-in** is deliberately slow: the low-CPU alarm needs ~**15 datapoints over ~15 min** of low CPU before capacity is removed.

So plan for **~3–5 min to see scale-out** and **~10–15 min to see scale-in** after you stop the load.

---

## Where to run the load — from inside AWS (not your laptop)

The spec says to *"Use AWS Cloud9 to run the load testing scripts against the load
balancer."* The reason is to drive load from an instance **in the same region
(us-east-1)** as the ALB — a stable, high-bandwidth path with no home-network
bottleneck, and with tooling (`npm`, AWS CLI) available.

> ⚠️ **AWS Cloud9 is closed to new customers since 2024-07-25.** A fresh lab
> account may not be able to create a Cloud9 environment. Cloud9 is **not**
> required — any load generator running inside us-east-1 works. Pick whichever is
> available:

| Option | When to use | Notes |
|---|---|---|
| **AWS Cloud9** | Only if the lab account already has Cloud9 access (existing customer) | Original spec path; Script-2 runs as-is |
| **Small EC2 instance** (recommended) | Default when Cloud9 is unavailable | Launch a `t3.micro` in the **public subnet** of this VPC, SSH in, install `loadtest`/k6, run against the ALB. Same-region, same effect as Cloud9 |
| **AWS CloudShell** | Quick test, no instance to manage | Free, browser-based, in-region; limited CPU/RAM so it may not sustain very high load |
| **Local machine** | Last resort | Works but home network/NAT may bottleneck before the web tier; least representative |

Whatever the host, the load command itself is **Script-2** in
`scripts/cloud9-scripts.yml`.

---

## Procedure

### 1. Get the ALB DNS name

From the machine where Terraform state lives:

```bash
cd src
terraform output -raw alb_dns_name
```

Confirm the app is reachable in a browser first: `http://<ALB DNS>` — perform a
view/add/delete/modify on a student record (Task 3) so you know the app is healthy
before loading it.

### 2. Open a CloudWatch / ASG monitoring view (before starting load)

Keep these open so you can watch the cycle happen:

- **EC2 → Auto Scaling Groups → `<env>-web-asg` → Activity** — records every launch/terminate with a reason.
- **EC2 → Auto Scaling Groups → Monitoring** (or CloudWatch) — **Group CPU utilization** vs the 50% target.
- **EC2 → Target Groups → Targets** — count of *healthy* hosts behind the ALB.
- **EC2 → Instances** — live instance count.

Note the **starting instance count = 2**.

### 3. Install the load tool on the load host (Script-2, first half)

```bash
npm install -g loadtest
```

### 4. Generate load (Script-2, second half)

```bash
# Use the ALB DNS from step 1. Port 80 / http (this POC has no HTTPS).
loadtest --rps 1000 -c 500 -k http://<ALB DNS>
```

- `--rps 1000` — target 1000 requests/sec
- `-c 500` — 500 concurrent connections
- `-k` — keep-alive
- The command runs **until you press Ctrl+C** — it does not stop on its own.

> Tip: if a single Cloud9 instance can't push CPU past 50% (client-side CPU /
> network is the bottleneck before the web tier is), raise the load or run a
> second Cloud9 terminal/instance in parallel. You can also temporarily lower the
> target or use a larger Cloud9 instance for the demo.

### 5. Observe SCALE-OUT (~3–5 min, keep load running)

- Group CPU climbs above **50%**.
- After the high-CPU alarm fires (~3 min), the ASG **Activity** tab logs new
  launches with reason *"…CPUUtilization … above the threshold …"*.
- Instance count grows 2 → 3 → up to the **max of 4**.
- Let it hold at the scaled-out count for a few minutes to demonstrate **steady state**.

### 6. Stop the load → observe SCALE-IN (~10–15 min)

```
Ctrl + C        # in the loadtest terminal
```

- Group CPU drops back well below 50%.
- After the slow low-CPU alarm clears (~15 min of low CPU), the ASG **Activity**
  tab logs terminations and instance count shrinks back toward the **min of 2**.

### 7. Capture evidence

For the report, capture:

- ASG **Activity history** showing launch (scale-out) **and** terminate (scale-in) events with their reasons.
- CloudWatch **CPU graph** crossing 50% up, then back down.
- Target group **healthy host count** rising then falling.

---

## Alternative tool (k6) — optional

`loadtest` is the spec's documented path and the safest for grading. If you
instead use the `performance/load_test.js` (k6) script, it only satisfies the
requirement if you:

1. Point it at the **ALB** (`http://<ALB DNS>`), not an external site.
2. Generate **enough** load to exceed the 50% CPU target (raise `vus`, e.g.
   200–500; remove/shorten `sleep`; run for several minutes).
3. Run it from an **AWS instance in us-east-1** (e.g. Cloud9), for the same
   reasons as above — not from a laptop.

The scale-out / steady / scale-in observation steps (5–7) are identical regardless
of which client tool generates the load.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| CPU never reaches 50% | Client (Cloud9) is the bottleneck, not the web tier | Raise `--rps`/`-c`, add a second load source, or use a bigger Cloud9 instance |
| No scale-out after 5+ min | Load not reaching ALB, or wrong URL/port | Verify `http://<ALB DNS>` opens in a browser; confirm listener is :80 |
| Scale-in "not happening" | It is slow by design (~15 min low CPU) | Wait longer after Ctrl+C; check the ASG Activity tab |
| Instances never exceed 2 then 4 | min=2, max=4 by config | Expected — 4 is the configured ceiling (`asg_max`) |

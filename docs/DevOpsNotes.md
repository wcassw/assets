## AWS Services 

```
Service                Pri DevOps Role
EC2                    Compute, autoscaling, AMIs
VPC                    Networking, isolation, security
EBS                    Stateful block storage
S3                     Artifacts, logs, backups
IAM                    Identity & access control
CloudWatch             Monitoring & observability 
Lambda                 Event-driven automation
CodeBuild              CI build runner
AWS Config             Compliance & drift detection
Billing & Cost         FinOps & optimization
KMS                    Encryption & key management
CloudTrail             Audit & governance
EKS                    Kubernetes orchestration
Fargate                Serverless containers
ELK / OpenSearch       Log analytics & search
```

## Daily / Weekly DevOps Checklist

- Security audits (IAM, S3, SGs)
- Backups & snapshots
- Dashboard reviews
- Cost anomaly checks
- Compliance & drift review


## Linux Essentials
### Basic Commands
```
ls -la                  # List all files with permissions
cd /var/log             # Change directory
pwd                     # Show current path
mkdir app && cd app     # Create & enter directory
rm -rf tmp/             # Delete directory forcefully
cp file1 file2          # Copy file
mv old new              # Rename / move file
touch app.log           # Create empty file
```

### Permissions & Ownership
```
chmod 755 script.sh     # rwxr-xr-x
chown user:group file   # Change owner
```

### System Information
```
uname -a                # Kernel & OS
hostnamectl             # Host details
free -h                 # Memory usage
df -h                   # Disk usage
uptime                  # Load average
```

### Logs
```
ls /var/log/
journalctl -xe          # System errors
tail -f /var/log/syslog # Follow logs
```

### Services
```
systemctl status nginx
systemctl restart nginx
systemctl enable nginx
systemctl stop nginx
```


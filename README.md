# Linux Desktop System Setup on EC2

![Labs](https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png)

## Compute

Choose the best compute for your workstation usage : [read this page](https://aws.amazon.com/fr/ec2/instance-types/).  
Take a look on pricing : [how does it cost ?](https://aws.amazon.com/fr/ec2/pricing/on-demand/)
Possible option (Processeur Intel Xeon Platinum fmax=3,1 GHz) :

- t3.xlarge (4vCPU, 16G)
- t3.xlarge (8vCPU, 32G)

You can list and filter instance type to find out the appropriate solution eg :

```bash
aws ec2 describe-instance-types --filters Name=hibernation-supported,Values=true --query InstanceTypes[].InstanceType --region eu-north-1
```

## LXDE and XRDP

Transform your ec2 in a rdp reachable Desktop environment. Sometimes it is usefull to dedicate a workstation to use cases. Here we simply instanciate an instance, install LXDE and XRDP...

LXDE

- Specially designed for cloud-based servers.
- Lightweight GUI for Linux
- Better interface
- Multi-language support
- Supports standard keyboard shortcuts
- Fast performance

## Command

We use user data to script installation of graphical layer.

```bash
sudo apt-get update -y
sudo apt-get install lxde -y
sudo apt-get install xrdp -y
```

You can setup a complete environment such as the example provided : init-talend.sh

## Enforce your user credentials

Automate the creation of a specific account or manually modify ec2 ubuntu user :

```bash
sudo passwd ubuntu
```

## Allow inbound RDP connections (TCP/3389)

Allow inbound RDP connections (TCP/3389) for the security group associated in AWS to the instance. On our example the security group associated to the instance is launch-wizard-3 so we will add a rule to allow TCP/3389 from our IP address only.

## Challenge #1 : Talend Open Studio installation

Follow installation guide : [here](https://help.talend.com/r/fr-FR/8.0/studio-getting-started-guide-open-studio-for-data-integration/introduction)

The package installer is stored in a s3 Bucket. If you don't want to use aws console, use cli :

```bash
aws s3api put-object --bucket a-materials-rch --key dir-1/big-video-file.mp4 --body e:\media\videos\f-sharp-3-data-services.mp4
```

URI :

```
https://a-materials-rch.s3.eu-north-1.amazonaws.com/install-packages/TOS_DI-20211109_1610-V8.0.1.zip (No access because private)
s3://a-materials-rch/install-packages/TOS_DI-20211109_1610-V8.0.1.zip
```

## Keep control on your cloud resources

| ![Labs](https://learn.hashicorp.com/_next/static/images/color-c0fe8380afabc1c58f5601c1662a2e2d.svg) | This demo shows you how to automate your architecture implementation in a **Cloud DevOps** approach with [Terraform](https://www.terraform.io/). |
| :-------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| **terraform**                                                                                       | Terraform >= 1.1.9 (an alias tf is create for terraform cli)                                                                                     |
| **aws**                                                                                             | aws cli v2 (WARNING : you are responsible of your access key, don't forget to deactivate or suppress it in your aws account !)                   |

## First check

Please check that everything is alright. Open a terminal in your sandbox and test environment

### Open a terminal and check terraform cli

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ terraform version
Terraform v1.1.9
on linux_amd64
```

### Check aws cli

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ aws --version
aws-cli/2.6.1 Python/3.9.11 Linux/5.13.0-40-generic exe/x86_64.debian.10 prompt/off
```

You need to configure your AWS access key. **Don't forget to delete or deactivate your access key in IAM, once you have finished this demo !**

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXxxxxxxxxxxxxxxxxxXXXxxxxxxxxxXXxxxxxxx
Default region name [None]: eu-north-1
Default output format [None]:
```

### Doc as code

Generate html page from Readme.md to show in integrated browser (CodeSandbox)

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ node md2html.js
```

## Terraform backend

All terraform state files are stored and shared in a dedicated S3 bucket. Create if needed your own bucket.

```bash
aws s3api create-bucket --bucket a-tfstate-rch --create-bucket-configuration LocationConstraint=eu-north-1 --region eu-north-1
aws s3api put-bucket-tagging --bucket a-tfstate-rch --tagging 'TagSet=[{Key=Owner,Value=raphael.chir@couchbase.com},{Key=Name,Value=terraform state set}]'
```

Refer your bucket in your terraform backend configuration.
**Specify a key for your project !**

```bash
terraform {
  backend "s3" {
    region  = "eu-north-1"
    key     = "myproject-tfstate"
    bucket  = "a-tfstate-rch"
  }
}
```

## Tag tag tag, ..

More than a best practice, it is essential for inventory resources, cost explorer, etc .. Open terraform.tfvars and update these values

```bash
resource_tags = {
  project     = "myproject"
  environment = "staging-rch"
  owner       = "raphael.chir@couchbase.com"
}
```

## SSH Keys

### Generate

We need to generate key pair in order to ssh into instances. Create a .ssh folder in tf-playground.
[SSH Academy](https://www.ssh.com/academy/ssh/keygen#creating-an-ssh-key-pair-for-user-authentication)

Open a terminal and paste this default command

```bash
ssh-keygen -q -t rsa -b 4096 -f /sandbox/tf-playground/.ssh/zkey -N ''
```

Change if needed ssh_keys_path variable in terraform.tvars  
Run this command, if necessary, to ensure your key is not publicly viewable.

```bash
chmod 400 zkey
```

### Choosing an Algorithm and Key Size

SSH supports several public key algorithms for authentication keys. These include:

**rsa** - an old algorithm based on the difficulty of factoring large numbers. A key size of at least 2048 bits is recommended for RSA; 4096 bits is better. RSA is getting old and significant advances are being made in factoring. Choosing a different algorithm may be advisable. It is quite possible the RSA algorithm will become practically breakable in the foreseeable future. All SSH clients support this algorithm.

**dsa** - an old US government Digital Signature Algorithm. It is based on the difficulty of computing discrete logarithms. A key size of 1024 would normally be used with it. DSA in its original form is no longer recommended.

**ecdsa** - a new Digital Signature Algorithm standarized by the US government, using elliptic curves. This is probably a good algorithm for current applications. Only three key sizes are supported: 256, 384, and 521 (sic!) bits. We would recommend always using it with 521 bits, since the keys are still small and probably more secure than the smaller keys (even though they should be safe as well). Most SSH clients now support this algorithm.

**ed25519** - this is a new algorithm added in OpenSSH. Support for it in clients is not yet universal. Thus its use in general purpose applications may not yet be advisable.

The algorithm is selected using the -t option and key size using the -b option. The following commands illustrate:

```bash
ssh-keygen -t rsa -b 4096
ssh-keygen -t dsa
ssh-keygen -t ecdsa -b 521
ssh-keygen -t ed25519
```

## How to choose your OS AMI

### From AWS console

You can just copy from aws console the **ami-id** needed.  
e.g : '_Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20_' is **ami-01ded35841bc93d7f**

### Advanced search

For specific search based on filters you can also use this command.
Based on this metadata structure below or see
[aws ec2 describe-images details](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-images.html)  
[Another link](https://docs.aws.amazon.com/sdkfornet1/latest/apidocs/html/P_Amazon_EC2_Model_DescribeImagesRequest_Filter.htm)

```bash
[
    {
        "Architecture": "x86_64",
        "CreationDate": "2022-04-21T14:55:48.000Z",
        "ImageId": "ami-01ded35841bc93d7f",
        "ImageLocation": "099720109477/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420",
        "ImageType": "machine",
        "Public": true,
        "OwnerId": "099720109477",
        "PlatformDetails": "Linux/UNIX",
        "UsageOperation": "RunInstances",
        "State": "available",
        "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/sda1",
                "Ebs": {
                    "DeleteOnTermination": true,
                    "SnapshotId": "snap-0bc2203755d33f5f6",
                    "VolumeSize": 8,
                    "VolumeType": "gp2",
                    "Encrypted": false
                }
            },
            {
                "DeviceName": "/dev/sdc",
                "VirtualName": "ephemeral1"
            },
            {
                "DeviceName": "/dev/sdb",
                "VirtualName": "ephemeral0"
            }
        ],
        "Description": "Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20",
        "EnaSupport": true,
        "Hypervisor": "xen",
        "Name": "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420",
        "RootDeviceName": "/dev/sda1",
        "RootDeviceType": "ebs",
        "SriovNetSupport": "simple",
        "VirtualizationType": "hvm",
        "DeprecationTime": "2024-04-21T14:55:48.000Z"
    }
]
```

You can find specific ami with this command

```bash
aws ec2 describe-images --region eu-north-1 --query "Images[*].[Description,ImageId]" --filters"Name=name,Values=ubuntu*" "Name=creation-date,Values=2022*" "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" "Name=block-device-mapping.volume-type,Values=gp2" "Name=image-type,Values=machine" "Name=state,Values=available" "Name=description,Values=*Ubuntu*22.04*"
```

Or write it into a file

```bash
echo $(aws ec2 describe-images --region eu-north-1 --query "Images[*].[Description,ImageId]" --filters "Name=name,Values=ubuntu*" "Name=creation-date,Values=2022*" "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" "Name=block-device-mapping.volume-type,Values=gp2" "Name=image-type,Values=machine" "Name=state,Values=available" "Name=description,Values=*Ubuntu*22.04*")>ami.json
```

Use list to see all namespaces

```bash
aws ssm get-parameters-by-path \
--path /aws/service/ami-amazon-linux-latest \
--query 'Parameters[].Name' --region eu-north-1
```

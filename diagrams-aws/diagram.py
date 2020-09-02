from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import ElastiCache
from diagrams.aws.network import ELB
from diagrams.aws.network import Route53

# Diagram as Code

# Commented paid approaches for free-tier
with Diagram("TiendaNube Test", show=False):
    # dns = Route53("dns")
    with Cluster("ALB SG"):
        alb = ELB("alb")

    with Cluster("web-servers-vpc"):
        with Cluster("web-servers-subnet"):
            with Cluster("web-servers-sg"):
                ec2_group = [EC2("nginx"),
                            EC2("apache")]

    # memcached = ElastiCache("memcached")

    alb >> ec2_group
    # dns >> alb >> ec2_group
    # ec2_group >> memcached

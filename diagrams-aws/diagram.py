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
        with Cluster("web-servers-subnet-1"):
            with Cluster("web-servers-sg-1"):
                web_servers_1 = [EC2("nginx"),
                                EC2("apache")]        
        with Cluster("web-servers-subnet-2"):
            with Cluster("web-servers-sg-2"):
                web_servers_2 = [EC2("nginx"),
                                EC2("apache")]
    alb >> web_servers_1
    alb >> web_servers_2


provider "aws" {
    region ="ap-south-1"
    profile = "profile3"
  
}

 resource "aws_security_group" "allow_tls11" {
  name        = "allow_tls11"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-371a065f"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls1"
  }
}

resource "aws_ebs_volume" "MyVol1" {
  availability_zone = "${aws_instance.myin3.availability_zone}"
  size = 1
  tags = {
    Name = "MyVolume"
  }
}

resource "aws_instance" "myin3" {
    ami = "ami-0447a12f28fddb066"
    instance_type = "t2.micro"
    key_name = "key2"
    security_groups = [ "allow_tls11"  ]
    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("C:/Users/AKASH EDARA/Downloads/key2.pem")
        host = aws_instance.myin3.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo yum install httpd  php git -y",
            "sudo systemctl restart httpd",
            "sudo systemctl enable httpd",
        ]
    }

    tags = {
        Name = "akash"
    }
}


resource "aws_s3_bucket" "dxj" {
    bucket = "a8019225772"
    acl    = "public-read"
    tags = {
      Name = "spider"
      Environment = "Dev" 
    }
     versioning {
       enabled = true
     }

}

resource "aws_s3_bucket_object" "object" {
  bucket = "a8019225772"
  key    = "spiderman.jpg"
  source = "spiderman.jpg"
  content_type = "image or jpg"
  acl = "public-read"
  depends_on = [
       aws_s3_bucket.dxj

   ]
}

resource "aws_cloudfront_distribution" "myCloudfront" {
    origin {
        domain_name = "a8019225772.s3.amazonaws.com"
        origin_id   = "S3-a8019225772" 

        custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
        }
    }
       
    enabled = true

    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-a8019225772"

        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }
    
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }

    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
resource "null_resource" "nullremote4"  {

depends_on = [
    aws_volume_attachment.AttachVol,
]

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:/Users/AKASH EDARA/Downloads/key2.pem")
    host = aws_instance.myin3.public_ip
}
provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/akashedara/cloudcomputing.git  /var/www/html/"
    ]
  }
}

 resource "aws_volume_attachment" "AttachVol" {
   device_name = "/dev/sdh"
   volume_id   =  "${aws_ebs_volume.MyVol1.id}"
   instance_id = "${aws_instance.myin3.id}"
   depends_on = [
       aws_ebs_volume.MyVol1,
       aws_instance.myin3
   ]
 }




















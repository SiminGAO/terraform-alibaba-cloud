# Self tuto AlibabaCloud products with Terraform

This repo aims to keep track of all the tutos realised during the learning process.


## basic
Basic version shows how to initates the ECS instance with VPC, VSwitch, Security groups.

## ECS instances within different VPCs connected by CEN
This sample shows:
- create the vpcs, the vswitches and the security groups
- create the ecs instances
- create the CEN which connect the two vpcs

It at the same time shows also:
- seperate the variable parts with the ressource parts
- some basic functions to annotate & manipulate the different formats of vars

[Link to the codes](./ecs-samples/cen-connect-multi-vpcs-with-ecs)

`TODO: update this version refleting on the best practices of CEN`
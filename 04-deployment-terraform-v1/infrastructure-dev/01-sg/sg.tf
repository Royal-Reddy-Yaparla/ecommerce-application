module "sg" {
  source         = "../../modules/sg"
  sg_name        = var.sg_name
  sg_description = var.sg_description
  vpc_id         = data.aws_ssm_parameter.vpc.value
  project        = var.project
  environment    = var.environment
}


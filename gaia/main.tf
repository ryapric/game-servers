module "ec2" {
  # source = "github.com/opensourcecorp/gaia//providers/aws/ec2_instance"
  source = "../../../opensourcecorp/gaia/providers/aws/ec2_instance"

  app_name              = "ryapric-game-servers"
  instance_profile_name = aws_iam_instance_profile.main.name
  instance_type         = "t3a.medium"
  keypair_name          = var.keypair_name
  name_tag              = "ryapric/game-servers"
  source_address        = "https://github.com/ryapric/game-servers.git"
  source_ami_filter     = "*aether*"
  user_data_filepath    = "../scripts/salt-init.sh"
  use_static_ip         = true

  sg_rules_maplist = local.game_ports
}

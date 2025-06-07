default:
  @just --list

clear_tf_state:
  rm -rf terraform.tfstate
  rm -rf terraform.tfstate.backup
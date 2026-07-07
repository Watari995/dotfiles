{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    awscli2
    git
    ssm-session-manager-plugin
  ];
}

{
  hostname,
  username,
  ...
}:
{
  imports = [
    ../darwin
  ];

  networking.hostName = hostname;
  networking.localHostName = hostname;

  users.users.${username} = {
    home = "/Users/${username}";
  };
}

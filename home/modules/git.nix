let
  userName = "xsen";
  email = "evgeny.leshchenko@gmail.com";
in
{
  programs.git = {
    enable = true;
    userName = userName;
    userEmail = email;
  };
}

let
  userName = "Evgeny Leshchenko";
  email = "evgeny.leshchenko@gmail.com";
in
{
    programs.git = {
        enable = true;
        userName = userName;
        userEmail = email;
    };
}

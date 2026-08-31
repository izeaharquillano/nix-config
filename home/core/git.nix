{ myvars, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = myvars.userfullname;
        email = myvars.useremail;
      };
    };
  };
}

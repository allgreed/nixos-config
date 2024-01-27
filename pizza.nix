{ pkgs }: 
{
  # because it's non-free, got it? ^^ 
  allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "rambox"

    "google-chrome"

    # my home printer drivers... maybe
    #"brgenml1lpr"

    # for zoom, although I'm not using Zoom as of lately
    #"zoom-us"
    #"zoom"
    #"faac"
  ];
}

{
  outputs = { self, ... }: {
    templates = {
      swift = { path = ./swift; description = "Swift project starter"; };
    };
  };
}

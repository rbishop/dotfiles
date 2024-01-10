{ pkgs, home-manager, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window.startup_mode = "Maximized";
      scrolling.history = 10000;
      live_config_reload = true;

      env = {
        TERM = "xterm-256color";
      };

      font = {
        size = 12.0;

        normal = {
          family = "Roboto Mono";
          style = "regular";
        };

        bold = {
          family = "Roboto Mono";
          style = "regular";
        };

        italic = {
          family = "Roboto Mono";
          style = "regular";
        };

        bold_italic = {
          family = "Roboto Mono";
          style = "regular";
        };
      };

      shell = "zsh";

      keyboard.bindings = [
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "PageUp"; action = "ScrollPageUp"; }
        { key = "PageDown"; action = "ScrollPageDown"; }
        { key = "Home"; action = "ScrollToTop"; }
        { key = "End"; action = "ScrollToBottom"; }
      ];
    };
  };
}

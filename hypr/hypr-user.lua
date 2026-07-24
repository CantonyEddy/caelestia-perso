-- ~/.config/caelestia/hypr-user.lua
-- Point d'entrée de TES overrides Hyprland. Caelestia fait require("hypr-user")
-- en tout dernier (après ses propres hyprland.*), donc tes réglages gagnent.
--
-- Ici c'est du VRAI Lua Hyprland : hl.config{}, hl.bind(), etc.
-- On charge la sous-arbo user/ via require(). Le dossier ~/.config/caelestia/
-- est dans package.path, donc require("user.input") -> user/input.lua.
--
-- IMPORTANT : on ne référence QUE les fichiers réellement remplis.
-- Pour activer un thème, décommente sa ligne (le fichier doit exister et être
-- valide, sinon require() lève une erreur). Ordre = dernier chargé gagne.

require("user.input")
-- require("user.env")
-- require("user.general")
-- require("user.misc")
-- require("user.animations")
-- require("user.decoration")
-- require("user.group")
-- require("user.execs")
require("user.rules")
-- require("user.gestures")
require("user.keybinds")
-- require("user.scrolling")

-- user/keybinds.lua — mes raccourcis perso (migré depuis l'ancien keybinds.conf)
--
-- Notes de migration :
--  * app2unit a été supprimé par Caelestia -> on lance via "uwsm app -- <cmd>".
--  * Ce fichier est chargé APRÈS les binds de Caelestia (require hypr-user en
--    dernier), donc un hl.bind sur une touche déjà prise l'ÉCRASE (dernier gagne).
--    C'est ainsi qu'on réassigne Super+M / Super+D sans "unbind".
--  * $kbCommunication / $kbMusic (anciennes variables) = Super+D / Super+M chez
--    Caelestia. On les réassigne directement à nos apps.

-- Lancement d'apps (remplace app2unit -- <app>)
hl.bind("SUPER + G", hl.dsp.exec_cmd("uwsm app -- steam"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("uwsm app -- obsidian"))

-- Override des toggles Caelestia : musique (Super+M) et communication (Super+D)
hl.bind("SUPER + D", hl.dsp.exec_cmd("uwsm app -- vesktop")) -- ex-$kbCommunication
hl.bind("SUPER + M", hl.dsp.exec_cmd("uwsm app -- spotify")) -- ex-$kbMusic

-- Sélecteur d'emoji : tue une instance existante de fuzzel sinon lance caelestia emoji
hl.bind("SUPER + semicolon", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

return true

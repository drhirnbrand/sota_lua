#!/bin/sh -e

tgt="/drives/c/Users/Ingo Brunkhorst/AppData/Roaming/Portalarium/Shroud of the Avatar/Lua"

for dir in drh_sota_assets drh_sota_healthbar drh_sota_alarm; do
  echo "Creating Directory ${dir} -> ${tgt}/${dir}"
  test -d "${tgt}"/${dir} || mkdir "${tgt}"/${dir}
done

echo "Copying assets..."
cp drh_sota_assets/* "${tgt}/drh_sota_assets"

echo "Copying configurations..."
cp drh_sota_healthbar/drh_sota_healthbar/* "${tgt}/drh_sota_healthbar"
cp drh_sota_alarm/drh_sota_alarm/* "${tgt}/drh_sota_alarm"

for script in drh_sota_healthbar/drh_sota_healthbar.lua drh_sota_alarm/drh_sota_healthbar_audio_companion.lua; do
echo "Adapting script ${script} -> ${tgt}/$(basename ${script})"
  cat ${script} | sed s@%%%VERSION%%%@0.0.0@ > "${tgt}"/"$(basename ${script})"
done

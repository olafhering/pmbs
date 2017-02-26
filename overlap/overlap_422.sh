#!/bin/bash
t=`mktemp --tmpdir=/dev/shm`
test -z "${t}" && exit 1
trap "rm -fv $t" EXIT

obs_prjs="
openSUSE:Leap:42.2
"
pbs_prjs="
Essentials
Extra
Multimedia
Games
"
for obs_prj in $obs_prjs
do
	for pbs_prj in $pbs_prjs
	do
		for pkg in `pbs ls ${pbs_prj}`
		do
			case "${pbs_prj}/${pkg}" in
				Essentials/A_*) continue ;;

				Essentials/build-compare) continue ;;
				Essentials/k3b) continue ;;
				Essentials/vlc) continue ;;

				Extra/Coin) continue ;;
				Extra/FreeCAD) continue ;;
				Extra/blender) continue ;;
				Extra/oce) continue ;;
				Extra/yate) continue ;;

				Multimedia/QMPlay2) continue ;;
				Multimedia/QtAV) continue ;;
				Multimedia/aegisub) continue ;;
				Multimedia/audacity) continue ;;
				Multimedia/conky) continue ;;
				Multimedia/kaffeine) continue ;;
				Multimedia/libhdhomerun) continue ;;
				Multimedia/moc) continue ;;
				Multimedia/qmmp) continue ;;
				Multimedia/qtractor) continue ;;
				Multimedia/smtube) continue ;;
				Multimedia/stk) continue ;;
				Multimedia/xine-ui) continue ;;
				Multimedia/xmms2) continue ;;
				Multimedia/youtube-dl) continue ;;

				Games/love) continue ;;
				Games/scummvm) continue ;;
			esac

			if obs ls ${obs_prj} ${pkg} &> /dev/null
			then
				if pbs r -r openSUSE_Leap_42.2 -a x86_64 ${pbs_prj} ${pkg} | grep -wq disabled
				then
					if pbs cat -u ${pbs_prj} ${pkg} _link > "$t" 2>/dev/null
					then
						if grep -q openSUSE.org:openSUSE: "${t}"
						then
							: nothing todo, ${pbs_prj}/${pkg} links to Factory
						else
							echo "${pbs_prj}/${pkg}/_link does not point to openSUSE:Factory"
						fi
					else
						echo "${pbs_prj}/${pkg} has no _link"
					fi
				else
					echo ${pbs_prj} ${pkg}
				fi
			fi
		done
	done
done

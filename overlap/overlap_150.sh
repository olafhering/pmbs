#!/bin/bash
td=`mktemp --directory --tmpdir=/dev/shm`
test -z "${td}" && exit 1
trap "rm -rf $td" EXIT

pbs_repo="openSUSE_Leap_15.0"
obs_prjs="
openSUSE:Leap:15.0:Update
openSUSE:Leap:15.0
"
pbs_prjs="
Essentials
Extra
Multimedia
Games
"
#
for pbs_prj in $pbs_prjs
do
	pbs ls ${pbs_prj} > "${td}/pbs.${pbs_prj}"
done
for obs_prj in $obs_prjs
do
	obs ls ${obs_prj} > "${td}/obs.${obs_prj}"
done
#
for pbs_prj in $pbs_prjs
do
	for pkg in `cat "${td}/pbs.${pbs_prj}"`
	do
		: ${pbs_prj}/${pkg}
		case "${pbs_prj}/${pkg}" in
Essentials/A_15.0-ffmpeg) continue ;; # unhandled (openSUSE:Leap:15.0/ffmpeg)
Essentials/A_15.0-ffmpeg2) continue ;; # unhandled (openSUSE:Leap:15.0/ffmpeg2)
Essentials/A_15.0-gstreamer-plugins-bad) continue ;; # unhandled (openSUSE:Leap:15.0/gstreamer-plugins-bad)
Essentials/A_15.0-gstreamer-plugins-libav) continue ;; # unhandled (openSUSE:Leap:15.0/gstreamer-plugins-libav)
Essentials/A_15.0-gstreamer-plugins-ugly) continue ;; # unhandled (openSUSE:Leap:15.0/gstreamer-plugins-ugly)
Essentials/A_15.0-libquicktime) continue ;; # unhandled (openSUSE:Leap:15.0/libquicktime)
Essentials/A_15.0-mjpegtools) continue ;; # unhandled (openSUSE:Leap:15.0/mjpegtools)
Essentials/A_15.0-sox) continue ;; # unhandled (openSUSE:Leap:15.0/sox)
Essentials/A_15.0-vlc) continue ;; # unhandled (openSUSE:Leap:15.0/vlc)
Essentials/build-compare) continue ;; # unhandled (openSUSE:Leap:15.0/build-compare)
Essentials/kdenlive) continue ;; # unhandled (openSUSE:Leap:15.0/kdenlive)
Essentials/libmlt) continue ;; # unhandled (openSUSE:Leap:15.0/libmlt)
Extra/yate) continue ;; # unhandled (openSUSE:Leap:15.0/yate)
Games/scummvm) continue ;; # unhandled (openSUSE:Leap:15.0/scummvm)
Multimedia/audacious-plugins) continue ;; # unhandled (openSUSE:Leap:15.0/audacious-plugins)
Multimedia/deadbeef-plugin-mpris2) continue ;; # unhandled (openSUSE:Leap:15.0/deadbeef-plugin-mpris2)
Multimedia/libhdhomerun) continue ;; # unhandled (openSUSE:Leap:15.0/libhdhomerun)
Multimedia/qmmp) continue ;; # unhandled (openSUSE:Leap:15.0/qmmp)
Multimedia/smtube) continue ;; # unhandled (openSUSE:Leap:15.0/smtube)
Multimedia/stk) continue ;; # unhandled (openSUSE:Leap:15.0/stk)
Multimedia/xine-ui) continue ;; # unhandled (openSUSE:Leap:15.0/xine-ui)
Multimedia/youtube-dl) continue ;; # unhandled (openSUSE:Leap:15.0/youtube-dl)
			*/A_15.0-*) obs_pkg=${pkg#*-} ;;
			*/A_*) continue ;;
			*) obs_pkg=$pkg ;;
		esac

		msg=
		for obs_prj in ${obs_prjs}
		do
			if grep -q "^${obs_pkg}$" "${td}/obs.${obs_prj}" &> /dev/null
			then
				if pbs r -r ${pbs_repo} -a x86_64 ${pbs_prj} ${pkg} | grep -wq disabled
				then
					if pbs cat -u ${pbs_prj} ${pkg} _link > "${td}/t" 2>/dev/null
					then
						if grep -q openSUSE.org:openSUSE: "${td}/t"
						then
							msg="`xargs -n1 < \"${td}/t\" | awk -F = '/^project/{ print $2 }'`"
							msg="${pbs_prj}/${pkg}) : nothing todo ; continue ;; # links to ${msg} (${obs_prj}/${obs_pkg})"
							msg=
						else
							msg="${pbs_prj}/${pkg}) continue;; #_link does not point to openSUSE:Factory (${obs_prj}/${obs_pkg})"
						fi
					else
						msg="${pbs_prj}/${pkg}) continue ;; # has no _link (${obs_prj}/${obs_pkg})"
					fi
					msg=
				else
					msg="${pbs_prj}/${pkg}) continue ;; # unhandled (${obs_prj}/${obs_pkg})"
				fi
				: $pkg found_in_obs=true
				break
			fi
		done

		if test -n "${msg}"
		then
			echo "${msg}"
		fi
	done
done

#!/bin/bash
td=`mktemp --directory --tmpdir=/dev/shm`
test -z "${td}" && exit 1
trap "rm -rf $td" EXIT

pbs_repo="openSUSE_Tumbleweed"
obs_prjs="
openSUSE:Factory
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
			Essentials/A_tw-ffmpeg) continue ;; # unhandled (openSUSE:Factory/ffmpeg)
			Essentials/A_tw-ffmpeg2) continue ;; # unhandled (openSUSE:Factory/ffmpeg2)
			Essentials/A_tw-freshplayerplugin) continue ;; # unhandled (openSUSE:Factory/freshplayerplugin)
			Essentials/A_tw-gstreamer-plugins-bad) continue ;; # unhandled (openSUSE:Factory/gstreamer-plugins-bad)
			Essentials/A_tw-gstreamer-plugins-libav) continue ;; # unhandled (openSUSE:Factory/gstreamer-plugins-libav)
			Essentials/A_tw-gstreamer-plugins-ugly) continue ;; # unhandled (openSUSE:Factory/gstreamer-plugins-ugly)
			Essentials/A_tw-libquicktime) continue ;; # unhandled (openSUSE:Factory/libquicktime)
			Essentials/A_tw-mjpegtools) continue ;; # unhandled (openSUSE:Factory/mjpegtools)
			Essentials/A_tw-sox) continue ;; # unhandled (openSUSE:Factory/sox)
			Essentials/A_tw-vlc) continue ;; # unhandled (openSUSE:Factory/vlc)
			Essentials/build-compare) continue ;; # unhandled (openSUSE:Factory/build-compare)
			Essentials/gettext-runtime) continue ;; # has no _link (openSUSE:Factory/gettext-runtime)
			Essentials/libmlt) continue ;; # unhandled (openSUSE:Factory/libmlt)
			Essentials/projectM-qt5) continue;; #_link does not point to openSUSE:Factory (openSUSE:Factory/projectM-qt5)
			Essentials/python-notify2) continue ;; # has no _link (openSUSE:Factory/python-notify2)
			Essentials/python-zeroconf) continue ;; # has no _link (openSUSE:Factory/python-zeroconf)
			Essentials/vlc) continue ;; # has no _link (openSUSE:Factory/vlc)
			Extra/blender) continue ;; # unhandled (openSUSE:Factory/blender)
			Extra/cowsay) continue ;; # has no _link (openSUSE:Factory/cowsay)
			Extra/libofetion) continue ;; # has no _link (openSUSE:Factory/libofetion)
			Extra/oce) continue ;; # has no _link (openSUSE:Factory/oce)
			Extra/yate) continue ;; # unhandled (openSUSE:Factory/yate)
			Multimedia/QtAV) continue ;; # has no _link (openSUSE:Factory/QtAV)
			Multimedia/audacious-plugins) continue ;; # unhandled (openSUSE:Factory/audacious-plugins)
			Multimedia/audacity) continue ;; # unhandled (openSUSE:Factory/audacity)
			Multimedia/conky) continue ;; # unhandled (openSUSE:Factory/conky)
			Multimedia/deadbeef) continue;; #_link does not point to openSUSE:Factory (openSUSE:Factory/deadbeef)
			Multimedia/deadbeef-plugin-mpris2) continue ;; # unhandled (openSUSE:Factory/deadbeef-plugin-mpris2)
			Multimedia/dvdauthor) continue ;; # has no _link (openSUSE:Factory/dvdauthor)
			Multimedia/libhdhomerun) continue ;; # unhandled (openSUSE:Factory/libhdhomerun)
			Multimedia/qmmp) continue ;; # unhandled (openSUSE:Factory/qmmp)
			Multimedia/smtube) continue ;; # unhandled (openSUSE:Factory/smtube)
			Multimedia/stk) continue ;; # unhandled (openSUSE:Factory/stk)
			Multimedia/xine-ui) continue ;; # unhandled (openSUSE:Factory/xine-ui)
			Multimedia/youtube-dl) continue ;; # unhandled (openSUSE:Factory/youtube-dl)
			Games/mame) continue;; #_link does not point to openSUSE:Factory (openSUSE:Factory/mame)
			Games/python-pysqlite) continue ;; # has no _link (openSUSE:Factory/python-pysqlite)
			Games/scummvm) continue ;; # unhandled (openSUSE:Factory/scummvm)
			*/A_tw-*) obs_pkg=${pkg#*-} ;;
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

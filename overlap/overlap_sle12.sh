#!/bin/bash
td=`mktemp --directory --tmpdir=/dev/shm`
test -z "${td}" && exit 1
trap "rm -rf $td" EXIT

pbs_repo="SLE_12"
obs_prjs="
openSUSE:Backports:SLE-12-SP3:Update
openSUSE:Backports:SLE-12-SP3
openSUSE:Backports:SLE-12-SP2:Update
openSUSE:Backports:SLE-12-SP2
openSUSE:Backports:SLE-12-SP1:Update
openSUSE:Backports:SLE-12-SP1
openSUSE:Backports:SLE-12:Update
openSUSE:Backports:SLE-12
openSUSE:Backports:SLE-12:Checks
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
Essentials/A_sle12-ffmpeg) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP2/ffmpeg)
Essentials/A_sle12-ffmpeg2) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP2/ffmpeg2)
Essentials/A_sle12-ladspa) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP1:Update/ladspa)
Essentials/A_sle12-rpmlint-backports-data) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP3/rpmlint-backports-data)
Essentials/k3b) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP3/k3b)
Essentials/kdenlive) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP3/kdenlive)
Essentials/lame) : nothing todo ; continue ;; # links to openSUSE.org:openSUSE:Factory (openSUSE:Backports:SLE-12-SP2/lame)
Essentials/libmlt) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP3/libmlt)
Essentials/movit) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP3/movit)
Essentials/twolame) : nothing todo ; continue ;; # links to openSUSE.org:openSUSE:Factory (openSUSE:Backports:SLE-12-SP2/twolame)
Essentials/wxWidgets) continue ;; # has no _link (openSUSE:Backports:SLE-12:Update/wxWidgets)
Extra/gcc6) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP2:Update/gcc6)
Multimedia/QtAV) continue ;; # has no _link (openSUSE:Backports:SLE-12-SP3/QtAV)
Multimedia/apache-rpm-macros) : nothing todo ; continue ;; # links to openSUSE.org:openSUSE:Factory (openSUSE:Backports:SLE-12-SP1/apache-rpm-macros)
Multimedia/apache-rpm-macros-control) : nothing todo ; continue ;; # links to openSUSE.org:openSUSE:Factory (openSUSE:Backports:SLE-12/apache-rpm-macros-control)
Multimedia/libsrtp) continue ;; # unhandled (openSUSE:Backports:SLE-12-SP2:Update/libsrtp)
			*/A_sle12-*) obs_pkg=${pkg#*-} ;;
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

#!/bin/bash
td=`mktemp --directory --tmpdir=/dev/shm`
test -z "${td}" && exit 1
trap "rm -rf $td" EXIT

pbs_repo="openSUSE_Leap_42.3"
obs_prjs="
openSUSE:Leap:42.3:Update
openSUSE:Leap:42.3
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
			*/A_42.3-*) obs_pkg=${pkg#*-} ;;
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

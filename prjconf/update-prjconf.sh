#!/bin/bash

export TZ=UTC
declare -i rev
td=`mktemp --directory --tmpdir=/dev/shm`
test -z "${td}" && exit 1
trap "rm -rf \"$td\"" EXIT
t="${td}/t"
d="${td}/d"
pbs='/usr/bin/osc -A https://pmbs-api.links2linux.org'
pbs=pbs
prjs="
Essentials
Multimedia
Extra
Games
"
pkg=_project
file=_config
for prj in $prjs
do
	rev_file="${prj}-${pkg}-${file}-rev.txt"
	mkdir -vp "${prj}/${pkg}"
	pushd  "${prj}/${pkg}"
		if ! test -f "${rev_file}"
		then
			echo 0 > "${rev_file}"
		fi
		read rev < "${rev_file}"
		: rev ${rev}
		#
		while true
		do
			: $((rev++))
			echo "${rev}"
			${pbs} log -r ${rev} ${prj} ${pkg} > "${t}"
			if test -s "${t}"
			then
				d="` grep '|' \"${t}\" | cut -d '|' -f 3`"
				export GIT_AUTHOR_DATE=$d
				export GIT_COMMITTER_DATE=$d
				if ${pbs} cat -r $rev ${prj} ${pkg} ${file} > ${file}
				then
					sed -i "1 i \\
${prj} ${pkg} ${file} rev ${rev}\\
" "${t}"
					git add ${file}
					git commit -v -F "${t}" ${file}
				fi
				git add "${rev_file}"
				echo "${rev}" > "${rev_file}"
				git commit -v -m "${prj} ${pkg} ${file} update rev to ${rev}" "${rev_file}"
			else
				break
			fi
		done
	popd
done

osc=pbs
t=`mktemp --directory --tmpdir=/dev/shm`
test -n "$t" || exit 1
trap "rm -rf $t" EXIT

for prj in Essentials Multimedia Extra Games
do
	mkdir "${t}/${prj}"
	mkdir -p "${prj}"
	pushd "${prj}" > /dev/null
	for pkg in ` ${osc} ls ${prj}`
	do
		mkdir "${t}/${prj}/${pkg}"
		mkdir -p "${pkg}"
		pushd "${pkg}" > /dev/null
		for file in ` ${osc} ls -e ${prj} ${pkg} `
		do
			case "${file}" in
				*.spec)
				${osc} cat -e ${prj} ${pkg} ${file} > ${t}/${file}
				if test -s ${t}/${file}
				then
					if cmp -s ${file} ${t}/${file}
					then
						: equal
					else
						cat ${t}/${file} > ${file}
					fi
				fi
				rm -f ${t}/${file}
				;;
			esac
		done
		popd > /dev/null
	done
	for dir in *
	do
		if test -d "${dir}"
		then
			if test -d "${t}/${prj}/${dir}"
			then
				rmdir "$_"
				continue
			fi
			echo "${prj}/${dir}"
		fi
	done
	rmdir "${t}/${prj}"
	popd > /dev/null
done

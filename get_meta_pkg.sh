osc=pbs
t=`mktemp --directory --tmpdir=/dev/shm`
test -n "$t" || exit 1
_exit() {
	rm -rf "$t"
}
trap _exit EXIT

for prj in Essentials Multimedia Extra Games
do
	mkdir "${t}/${prj}"
	mkdir -p "${prj}"
	pushd "${prj}" > /dev/null
	for pkg in ` ${osc} ls ${prj} `
	do
		mkdir "${t}/${prj}/${pkg}"
		mkdir -p "${pkg}"
		pushd "${pkg}" > /dev/null
		file=${pkg}.xml
		${osc} meta pkg ${prj} ${pkg} > ${t}/${file}
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

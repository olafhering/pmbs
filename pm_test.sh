#!/bin/bash
unset LANG
unset ${!LC_*}
set -x
#
export TMPDIR=/dev/shm
td=`mktemp --directory --tmpdir=/dev/shm`
test -z "${td}" && exit 1
_x() {
  rm -rf "${td}"
}
trap _x EXIT
#
use_system_repos=
while test "$#" -gt 0
do
  case "$1" in
    --system)
      use_system_repos=yes
      shift
      ;;
  *) break ;;
  esac
done
dist=$1
#
root="${td}/dist"
pkgs_xml="${td}/pkgs.xml"
pkgs_txt="${td}/pkgs.txt"
zyppd="${root}/etc/zypp"
reposd="${zyppd}/repos.d"
zypper="nice -n 19 zypper --verbose --verbose --no-refresh --gpg-auto-import-keys --non-interactive --no-gpg-checks --xmlout --root ${root}"
zypper_in="${zypper} install --force-resolution --dry-run"
#
#
create_repo() {
  local n=$1
  local t=$2
  local url=$3
  cat > "${reposd}/${n}.repo" <<_EOR_
[${n}]
name=${n}
enabled=1
autorefresh=1
baseurl=${url}
path=/
type=${t}
keeppackages=0
_EOR_
}
#
test_install() {
  local pkg
  ${zypper} lr -d
  ${zypper} ref
  ${zypper} --xmlout se --details --type package --repo pm_essentials --repo pm_multimedia --repo pm_extra --repo pm_games > ${pkgs_xml}
  sed -n '
  /^.solvable .*-debuginfo/n
  /^.solvable .*-debugsource/n
  /^.solvable / {
   s@^\(.* name="\)\([^"]\+\)\(" .* edition="\)\([^"]\+\)\(" arch="\)\(\(x86_64\|noarch\)\+\)\(".*\)@\2-\4.\6@p
  }
  ' < ${pkgs_xml} > ${pkgs_txt}
  #
  ${zypper_in} `cat ${pkgs_txt}`
  #
  for pkg in `cat ${pkgs_txt}`
  do
    ${zypper_in} ${pkg}
  done
}
#
copy_system_repos() {
  cp -avLt "${reposd}" /etc/zypp/repos.d/*.repo
  mkdir -vp "${zyppd}/services.d"
  cp -avLt "${zyppd}/services.d" /etc/zypp/services.d/*.service
  mkdir -vp "${zyppd}/credentials.d"
  cp -avLt "${zyppd}/credentials.d" /etc/zypp/credentials.d/*
}
#
do_tw() {
  if test -z "${use_system_repos}"
  then
    create_repo oss yast2  http://download.opensuse.org/tumbleweed/repo/oss
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/openSUSE_Tumbleweed
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/openSUSE_Tumbleweed
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/openSUSE_Tumbleweed
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/openSUSE_Tumbleweed
  test_install
}
#
do_15_0() {
  if test -z "${use_system_repos}"
  then
    create_repo oss            yast2  http://download.opensuse.org/distribution/leap/15.0/repo/oss
    create_repo non-oss        yast2  http://download.opensuse.org/distribution/leap/15.0/repo/non-oss
    create_repo update         rpm-md http://download.opensuse.org/update/leap/15.0/oss
    create_repo update-non-oss rpm-md http://download.opensuse.org/update/leap/15.0/non-oss
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/openSUSE_Leap_15.0
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/openSUSE_Leap_15.0
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/openSUSE_Leap_15.0
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/openSUSE_Leap_15.0
  test_install
}
#
do_42_3() {
  if test -z "${use_system_repos}"
  then
    create_repo oss            yast2  http://download.opensuse.org/distribution/leap/42.3/repo/oss
    create_repo non-oss        yast2  http://download.opensuse.org/distribution/leap/42.3/repo/non-oss
    create_repo update         rpm-md http://download.opensuse.org/update/leap/42.3/oss
    create_repo update-non-oss rpm-md http://download.opensuse.org/update/leap/42.3/non-oss
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/openSUSE_Leap_42.3
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/openSUSE_Leap_42.3
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/openSUSE_Leap_42.3
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/openSUSE_Leap_42.3
  test_install
}
#
do_42_2() {
  if test -z "${use_system_repos}"
  then
    create_repo oss            yast2  http://download.opensuse.org/distribution/leap/42.2/repo/oss
    create_repo non-oss        yast2  http://download.opensuse.org/distribution/leap/42.2/repo/non-oss
    create_repo update         rpm-md http://download.opensuse.org/update/leap/42.2/oss
    create_repo update-non-oss rpm-md http://download.opensuse.org/update/leap/42.2/non-oss
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/openSUSE_Leap_42.2
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/openSUSE_Leap_42.2
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/openSUSE_Leap_42.2
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/openSUSE_Leap_42.2
  test_install
}
#
do_42_1() {
  if test -z "${use_system_repos}"
  then
    create_repo oss            yast2  http://download.opensuse.org/distribution/leap/42.1/repo/oss
    create_repo non-oss        yast2  http://download.opensuse.org/distribution/leap/42.1/repo/non-oss
    create_repo update         rpm-md http://download.opensuse.org/update/leap/42.1/oss
    create_repo update-non-oss rpm-md http://download.opensuse.org/update/leap/42.1/non-oss
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/openSUSE_Leap_42.1
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/openSUSE_Leap_42.1
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/openSUSE_Leap_42.1
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/openSUSE_Leap_42.1
  test_install
}
#
do_13_2() {
  if test -z "${use_system_repos}"
  then
    create_repo oss            yast2  http://download.opensuse.org/distribution/13.2/repo/oss
    create_repo non-oss        yast2  http://download.opensuse.org/distribution/13.2/repo/non-oss
    create_repo update         rpm-md http://download.opensuse.org/update/13.2
    create_repo update-non-oss rpm-md http://download.opensuse.org/update/13.2
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/openSUSE_13.2
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/openSUSE_13.2
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/openSUSE_13.2
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/openSUSE_13.2
  test_install
}
#
do_13_1() {
  if test -z "${use_system_repos}"
  then
    create_repo oss            yast2  http://download.opensuse.org/distribution/13.1/repo/oss
    create_repo non-oss        yast2  http://download.opensuse.org/distribution/13.1/repo/non-oss
    create_repo update         rpm-md http://download.opensuse.org/update/13.1
    create_repo update-non-oss rpm-md http://download.opensuse.org/update/13.1
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://packman.inode.at/suse/openSUSE_13.1/Essentials
  create_repo pm_multimedia  rpm-md http://packman.inode.at/suse/openSUSE_13.1/Multimedia
  create_repo pm_extra       rpm-md http://packman.inode.at/suse/openSUSE_13.1/Extra
  create_repo pm_games       rpm-md http://packman.inode.at/suse/openSUSE_13.1/Games
  test_install
}
#
do_sle12() {
  if test -z "${use_system_repos}"
  then
    exit 1
  else
    copy_system_repos
  fi
  create_repo pm_essentials  rpm-md http://pmbs-api.links2linux.de:8080/Essentials/SLE_12
  create_repo pm_multimedia  rpm-md http://pmbs-api.links2linux.de:8080/Multimedia/SLE_12
  create_repo pm_extra       rpm-md http://pmbs-api.links2linux.de:8080/Extra/SLE_12
  create_repo pm_games       rpm-md http://pmbs-api.links2linux.de:8080/Games/SLE_12
  test_install
}
#
mkdir -vp "${reposd}"

case "${dist}" in
  tw) do_tw ;;
  15.0)  do_15_0 ;;
  42.3)  do_42_3 ;;
  42.2)  do_42_2 ;;
  42.1)  do_42_1 ;;
  13.2)  do_13_2 ;;
  13.1)  do_13_1 ;;
  sle12) use_system_repos=yes ; do_sle12 ;;
  *) ;;
esac
# vim: tw=666 ts=2 shiftwidth=2 et


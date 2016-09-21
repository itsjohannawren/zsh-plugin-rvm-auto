#!/bin/bash

__RVM_AUTO_VERSION=""

__rvm_auto_find_rc() {
	local DIR

	DIR="$(pwd)"

	if [ -f "${DIR}/.ruby-version" ] && [ -r "${DIR}/.ruby-version" ]; then
		awk '{print $1; exit 0;}' "${DIR}/.ruby-version"
		return 0

	elif [ -f "${DIR}/Gemfile" ] && [ -r "${DIR}/Gemfile" ] && grep -qE '^[\t ]*ruby ' "${DIR}/Gemfile"; then
		awk '/^\s*ruby / {gsub(/"/,"",$NF); print $NF;}' "${DIR}/Gemfile"
		return 0
	fi
	while [ "${DIR}" != "/" ]; do
		DIR="$(dirname "${DIR}")"
		if [ -f "${DIR}/.ruby-version" ] && [ -r "${DIR}/.ruby-version" ]; then
			awk '{print $1; exit 0;}' "${DIR}/.ruby-version"
			return 0

		elif [ -f "${DIR}/Gemfile" ] && [ -r "${DIR}/Gemfile" ] && grep -qE '^[\t ]*ruby ' "${DIR}/Gemfile"; then
			awk '/^\s*ruby / {gsub(/"/,"",$NF); print $NF;}' "${DIR}/Gemfile"
			return 0
		fi
	done
	return 1
}

__rvm_auto_load() {
	local RUBY_VERSION

	if ! rvm help &>/dev/null; then
		return 0
	fi

	RUBY_VERSION="$(__rvm_auto_find_rc)"
	if [ -z "${RUBY_VERSION}" ]; then
		RUBY_VERSION="default"
	fi

	if [ "${RUBY_VERSION}" != "${__RVM_AUTO_VERSION}" ]; then
		if [ "${RUBY_VERSION}" = "default" ]; then
			if rvm alias list 2>/dev/null | grep -qE '^default '; then
				rvm use default &>/dev/null
			fi
		else
			rvm use "${RUBY_VERSION}" &>/dev/null
		fi
		if [ "$?" = "0" ]; then
			__RVM_AUTO_VERSION="${RUBY_VERSION}"
		else
			echo "RVM: Failed to find suitable version for ${RUBY_VERSION}"
		fi
	fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd __rvm_auto_load
__rvm_auto_load

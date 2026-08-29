#!/bin/bash

set -e

APPNAME="${1}"
shift

RELEASETAG="${1}"
shift

TARGETARCH="${1}"
shift

if [[ -z "${APPNAME}" ]]; then
	echo "[warn] App name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${RELEASETAG}" ]]; then
	echo "[warn] Release tag name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${TARGETARCH}" ]]; then
	echo "[warn] Target architecture name from build arg is empty, exiting script..."
	exit 1
fi

echo -e "export IMAGE_RELEASE_TAG=${RELEASETAG}\n" >> '/etc/image-build-info'

release_version="${RELEASETAG//-[0-9][0-9]/}"

minecraft_bedrock_url="https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${release_version}.zip"

echo "[INFO] Web scrape URL for Bedrock is '${minecraft_bedrock_url}'"

rcurl.sh -o "/tmp/minecraftbedrockserver.zip" "${minecraft_bedrock_url}"

mkdir -p "/srv/minecraft" && unzip "/tmp/minecraftbedrockserver.zip" -d "/srv/minecraft"
rm -f "/tmp/minecraftbedrockserver.zip"

install_paths="/srv,/home/nobody"

IFS=',' read -ra install_paths_list <<< "${install_paths}"

for i in "${install_paths_list[@]}"; do
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi
done

install_paths=$(echo "${install_paths}" | tr ',' ' ')

chmod -R 775 ${install_paths}

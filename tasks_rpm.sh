#! /bin/bash

echo "Number of arguments: $#"
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
SRPMS="${SCRIPT_DIR}/my_python_rpm/build/rpmbuild/SRPMS"


# rpmファイルを作成
execBuild() {
    pushd "${SCRIPT_DIR}/my_python_rpm" > /dev/null || { echo "Failed to change directory"; exit 1; }
    gradle build
    if (( "$?" != 0 )); then
        echo "Failed gradle build"
    fi
    popd > /dev/null
}

# rebuildの実行
# rpmbuild --rebuild my_python_app-1.0-1.el7.src.rpm
execReBuild() {
    pushd "${SRPMS}" > /dev/null || { echo "Failed to change directory"; exit 1; }

    src_rpm=$(ls my_python_app-*.src.rpm) #TODO: ファイルが見つからない場合のエラー処理
    if [ -z "${src_rpm}" ]; then
        echo "Not found: ${SRPMS}/my_python_app-*.src.rpm"; exit 1;
    fi

    #TODO: rebuildによって作成されるrpmファイルの置き場 mv
    # デフォルト ~/rpmbuild/
    rpmbuild --rebuild "${src_rpm}"
    popd > /dev/null
}

printHelp() {
    echo "Options:"
    echo "  --build, -b  : 'gradle build'"
    echo "  --rebuild, -r: 'rpmbuild --rebuild my_python_app-*.src.rpm'"
}


if [[ "$#" -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
    printHelp
    exit 0
fi

while (( "$#" > 0 )); do
    case "$1" in
        --build|-b)
            {
                execBuild
                shift
            }
            ;;
        --rebuild|-r)
            {
                execReBuild
                shift
            }
            ;;
        *)
            {
                printHelp
                shift
            }
    esac
done

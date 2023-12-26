#!/usr/bin/env bash


# 修改为你的 Build Configuration 名称，确保与 Xcode 中的配置名称一致
NACTIVE_ENV='Release'

IPA_FILENAME=$1


function check_ok() {
    if [ $? != 0 ]; then
        echo -e "\033[31m Error,$1 \033[0m"
        exit 1
    fi
}


function active_build() {
  ipa_filename=$1
  scheme_dirname=$(ls -d *.xcodeproj)
  scheme_name=${scheme_dirname%%.*}

  xcodebuild archive -workspace Runner.xcworkspace -scheme $scheme_name -configuration $NACTIVE_ENV -archivePath build/Runner.xcarchive
  check_ok "生成 xcarchive 文件失败"

  # 导出 .ipa 文件
  xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/ipa
  check_ok "生成 ipa 文件失败"

  # ipa 文件命名格式：<应用名>_<大版本号-build-小版本号>_<时间>.ipa
  echo "ipa文件重命名: $ipa_filename"
  mv -f build/ipa/*.ipa  ${ipa_filename}
}


function flutter_build() {
  flutter gen-l10n || echo -e "\033[33m 执行多语言失败 \033[0m"
  # 导出 .ipa 文件
  flutter build ipa --release --export-options-plist="ExportOptions.plist"
  check_ok "生成 ipa 文件失败"

  # ipa 文件命名格式：<应用名>_<大版本号-build-小版本号>_<时间>.ipa
  echo "ipa文件重命名: $ipa_filename"
  mv build/ios/ipa/*.ipa  $ipa_filename
}


function build() {
  ipa_filename=$1
  # native/flutter
  project_type='native'

  if [[ -f 'pubspec.yaml' ]];then
     project_type='flutter'
  fi

  echo -e "\033[33m 开始【${project_type}】执行编译命令 \033[0m"
  if [[ $project_type = 'native' ]];then
    active_build $ipa_filename
  fi
  if [[ $project_type = 'flutter' ]];then
    flutter_build $ipa_filename
  fi

}

          
function main() {
  echo -e "\033[36m 当前使用的shell类型: $(ps -p $$ -o comm=)\033[0m"
  cd "$(dirname "$0")"
  pwd && ls -at1

  build $IPA_FILENAME

  echo -e "\033[33m 查看编译产物: ${ipa_filename} 和其他文件 \033[0m"
  ls ${ipa_filename}
}


main


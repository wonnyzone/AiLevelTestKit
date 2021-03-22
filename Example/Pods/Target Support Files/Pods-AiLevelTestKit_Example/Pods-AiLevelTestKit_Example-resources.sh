#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-1024.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-20@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-20@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-60@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-60@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small-40@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small-40@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_appicon.imageset/img_appicon.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_appicon.imageset/img_appicon@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_appicon.imageset/img_appicon@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_archive.imageset/img_archive.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_archive.imageset/img_archive@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_archive.imageset/img_archive@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_appicon.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_appicon@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_appicon@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_archive.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_archive@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_archive@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele5.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele5@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele5@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele6.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele6@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele6@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_female.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_female@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_female@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_kinder.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_kinder@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_kinder@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_male.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_male@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_male@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_check.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_check@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_check@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close_blk.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close_blk@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close_blk@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_cross.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_cross@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_cross@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_logo.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_logo@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_logo@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_back.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_back@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_back@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_logo.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_logo@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_logo@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_pencil.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_pencil@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_pencil@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOff.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOff@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOff@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOn.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOn@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOn@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_search.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_search@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_search@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_setting.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_setting@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_setting@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_time.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_time@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_time@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial5.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial5@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial5@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad5.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad5@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad5@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_volume.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_volume@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_volume@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wired_earphone.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wired_earphone@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wired_earphone@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wireless_earphone.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wireless_earphone@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wireless_earphone@3x.png"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AiLevelTestKit/AiLevelTestKit.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-1024.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-20@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-20@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-60@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-60@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small-40@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small-40@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/AppIcon.appiconset/Icon-Small@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_appicon.imageset/img_appicon.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_appicon.imageset/img_appicon@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_appicon.imageset/img_appicon@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_archive.imageset/img_archive.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_archive.imageset/img_archive@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/Images.xcassets/img_archive.imageset/img_archive@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_appicon.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_appicon@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_appicon@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_archive.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_archive@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_archive@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele5.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele5@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele5@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele6.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele6@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_ele6@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_female.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_female@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_female@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_kinder.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_kinder@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_kinder@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_male.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_male@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_male@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_char_mid3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_check.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_check@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_check@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close_blk.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close_blk@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_close_blk@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_cross.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_cross@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_cross@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_jtutorial_pad4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_logo.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_logo@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_logo@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_back.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_back@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_back@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_logo.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_logo@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_nav_logo@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_pencil.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_pencil@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_pencil@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOff.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOff@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOff@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOn.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOn@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_playOn@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_search.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_search@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_search@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_setting.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_setting@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_setting@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_time.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_time@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_time@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial5.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial5@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial5@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad1.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad1@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad1@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad2.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad2@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad2@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad3.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad3@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad3@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad4.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad4@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad4@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad5.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad5@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_tutorial_pad5@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_volume.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_volume@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_volume@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wired_earphone.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wired_earphone@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wired_earphone@3x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wireless_earphone.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wireless_earphone@2x.png"
  install_resource "${PODS_ROOT}/../../AiLevelTestKit/Assets/img_wireless_earphone@3x.png"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AiLevelTestKit/AiLevelTestKit.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi

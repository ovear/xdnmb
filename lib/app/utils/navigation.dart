import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/post_list.dart';
import 'extensions.dart';
import 'stack.dart';

GlobalKey<NavigatorState>? postListkey([int? index]) =>
    Get.nestedKey(ControllerStack.getKeyId(index));

void postListBack<T>({
  T? result,
  bool closeOverlays = false,
  bool canPop = true,
  int? index,
}) =>
    Get.maybePop(
        result: result,
        closeOverlays: closeOverlays,
        canPop: canPop,
        id: ControllerStack.getKeyId(index));

void popOnce([int? index]) {
  bool hasPopped = false;
  Get.until((route) {
    if (!hasPopped) {
      if (route is! PopupRoute) {
        ControllerStack.popController(index);
      }
      hasPopped = true;
      return false;
    }
    return true;
  }, id: ControllerStack.getKeyId(index));
}

void popAllPopup([int? index]) {
  Get.until((route) {
    if (route is PopupRoute) {
      return false;
    }
    return true;
  }, id: ControllerStack.getKeyId(index));
}

void openNewTabBackground(PostListController controller) =>
    ControllerStack.addNewController(controller);

void openNewTab(PostListController controller) {
  openNewTabBackground(controller);
  PostListPage.pageKey.currentState!.jumpToLast();
}

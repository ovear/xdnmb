import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/services/version.dart';
import '../routes/routes.dart';
import '../utils/toast.dart';
import '../utils/url.dart';
import '../widgets/dialog.dart';

class _AuthorSponsor extends StatelessWidget {
  const _AuthorSponsor({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('赞助'),
        subtitle: const Text(Urls.authorSponsor),
        onTap: () => launchURL(Urls.authorSponsor),
      );
}

class _AppSource extends StatelessWidget {
  const _AppSource({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('源码'),
        subtitle: const Text(Urls.appSource),
        onTap: () => launchURL(Urls.appSource),
      );
}

class _AppLicense extends StatelessWidget {
  const _AppLicense({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('开源许可证'),
        subtitle: const Text('GNU Affero General Public License Version 3'),
        onTap: () async => Get.dialog(
          ConfirmCancelDialog(
            content: await DefaultAssetBundle.of(context).loadString('LICENSE'),
            onConfirm: () => Get.back(),
          ),
        ),
      );
}

class _AppVersion extends StatelessWidget {
  const _AppVersion({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('版本'),
        subtitle: FutureBuilder<String>(
          future: Future(() async {
            final info = await PackageInfo.fromPlatform();
            return info.version;
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Text('${snapshot.data}');
            }

            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              showToast('获取版本号出现错误：${snapshot.error}');
            }

            return const SizedBox.shrink();
          },
        ),
        onTap: () => CheckAppVersionService.to.checkUpdate(),
      );
}

class SettingsController extends GetxController {}

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController());
  }
}

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
        ),
        body: ListView(
          children: const [
            ListTile(title: Text('饼干'), onTap: AppRoutes.toUser),
            ListTile(title: Text('黑名单'), onTap: AppRoutes.toBlacklist),
            ListTile(title: Text('基本设置'), onTap: AppRoutes.toBasicSettings),
            ListTile(title: Text('高级设置'), onTap: AppRoutes.toAdvancedSettings),
            ListTile(title: Text('作者'), subtitle: Text('Orzogc')),
            _AuthorSponsor(),
            _AppSource(),
            _AppLicense(),
            _AppVersion(),
          ],
        ),
      );
}

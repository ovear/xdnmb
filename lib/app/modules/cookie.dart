import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:xdnmb_api/xdnmb_api.dart' hide Image;

import '../data/models/cookie.dart';
import '../data/services/user.dart';
import '../data/services/xdnmb_client.dart';
import '../utils/exception.dart';
import '../utils/extensions.dart';
import '../utils/theme.dart';
import '../utils/toast.dart';
import '../utils/url.dart';
import '../widgets/dialog.dart';
import '../widgets/reload.dart';

class _VerifyImage extends StatelessWidget {
  const _VerifyImage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = XdnmbClientService.to.client;

    return TapToReload(
      builder: (context, child) => FutureBuilder<Uint8List>(
        future: client.getVerifyImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!);
          }

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            showToast('加载验证码失败：${exceptionMessage(snapshot.error!)}');

            return const Text('点击重新加载验证码', style: AppTheme.boldRed);
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService.to;
    String? email;
    String? password;
    String? verify;

    return LoaderOverlay(
      child: InputDialog(
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '邮箱'),
                autofocus: true,
                onSaved: (newValue) => email = newValue,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '请输入帐号邮箱' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
                onSaved: (newValue) => password = newValue,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '请输入帐号密码' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '验证码'),
                onSaved: (newValue) => verify = newValue,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '请输入验证码' : null,
              ),
              const SizedBox(height: 10.0),
              const _VerifyImage(),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final overlay = context.loaderOverlay;
                try {
                  overlay.show();
                  await user.login(
                      email: email!, password: password!, verify: verify!);

                  showToast('登陆成功');
                  Get.back();
                } catch (e) {
                  showToast('用户登陆失败：${exceptionMessage(e)}');
                } finally {
                  if (overlay.visible) {
                    overlay.hide();
                  }
                }
              }
            },
            child: const Text('登陆'),
          ),
        ],
      ),
    );
  }
}

class _Login extends StatelessWidget {
  const _Login({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService.to;

    final forgetPassword = TextButton(
      onPressed: () async => await launchURL(XdnmbUrls().resetPassword),
      child: const Text(
        '忘记密码',
        style: TextStyle(color: AppTheme.linkTextColor),
      ),
    );

    return user.isLogin
        ? ((user.isUserCookieExpired ?? true)
            ? ListTile(
                onTap: () => Get.dialog(_LoginForm()),
                title: const Text('登陆已经过期，点击重新登陆'),
                trailing: forgetPassword,
              )
            : ListTile(
                onTap: () => Get.dialog(
                  ConfirmCancelDialog(
                    content: '确定登出帐号？',
                    onConfirm: () {
                      user.logout();
                      Get.back();
                    },
                    onCancel: () => Get.back(),
                  ),
                ),
                title: const Text('登出X岛帐号'),
              ))
        : ListTile(
            onTap: () => Get.dialog(_LoginForm()),
            title: const Text('登陆X岛帐号'),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async =>
                      await launchURL(XdnmbUrls().registerAccount),
                  child: const Text(
                    '注册帐号',
                    style: TextStyle(color: AppTheme.linkTextColor),
                  ),
                ),
                forgetPassword,
              ],
            ),
          );
  }
}

class _AddCookieForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _AddCookieForm({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService.to;
    String? name;
    String? userHash;
    String? note;

    return InputDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: '名字'),
              autofocus: true,
              onSaved: (newValue) => name = newValue,
              validator: (value) =>
                  (value == null || value.isEmpty) ? '请输入饼干名字' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'userhash'),
              onSaved: (newValue) => userHash = newValue,
              validator: (value) =>
                  (value == null || value.isEmpty) ? '请输入饼干userhash' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '备注（可不填）'),
              onSaved: (newValue) => note = newValue,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (await user.addCookie(
                  name: name!,
                  userHash: userHash!,
                  note: (note?.isNotEmpty ?? false) ? note : null)) {
                showToast('饼干添加成功');
                Get.back();
              } else {
                showToast('已存在要添加的饼干');
              }
            }
          },
          child: const Text('添加'),
        ),
      ],
    );
  }
}

class _EditCookieNote extends StatelessWidget {
  final CookieData cookie;

  const _EditCookieNote(this.cookie, {super.key});

  @override
  Widget build(BuildContext context) {
    String? note;

    return InputDialog(
      content: TextFormField(
        decoration: const InputDecoration(labelText: '备注'),
        autofocus: true,
        initialValue: cookie.note,
        onChanged: (value) => note = value,
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await cookie.editNote((note?.isNotEmpty ?? false) ? note : null);
            Get.back(result: true);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

typedef _VerifyCallback = Future<void> Function(
    BuildContext context, String verify);

class _Verify extends StatelessWidget {
  final _VerifyCallback onPressed;

  final String buttonText;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _Verify({super.key, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    String? verify;

    return LoaderOverlay(
      child: InputDialog(
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '验证码'),
                autofocus: true,
                onSaved: (newValue) => verify = newValue,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '请输入验证码' : null,
              ),
              const SizedBox(height: 10.0),
              const _VerifyImage(),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await onPressed(context, verify!);
              }
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

class _Cookie extends StatelessWidget {
  final CookieData cookie;

  const _Cookie({super.key, required this.cookie});

  Future<bool?> _editNote() => Get.dialog<bool>(_EditCookieNote(cookie));

  Future<bool?> _deleteCookie() {
    final client = XdnmbClientService.to.client;
    final user = UserService.to;

    return (cookie.id == null || cookie.isDeprecated || !user.isUserCookieValid)
        ? Get.dialog<bool>(
            ConfirmCancelDialog(
              content: '确定删除该饼干？',
              onConfirm: () async {
                await cookie.delete();
                showToast('删除饼干成功');
                Get.back(result: true);
              },
              onCancel: () => Get.back(result: false),
            ),
          )
        : Get.dialog<bool>(
            _Verify(
              buttonText: '删除',
              onPressed: (context, verify) async {
                final overlay = context.loaderOverlay;
                try {
                  overlay.show();
                  await client.deleteCookie(
                      cookieId: cookie.id!, verify: verify);
                  await cookie.delete();
                  if (user.currentCookiesNum > 0) {
                    user.currentCookiesNum -= 1;
                  }

                  showToast('删除饼干成功');
                  Get.back(result: true);
                } catch (e) {
                  showToast('删除饼干失败：${exceptionMessage(e)}');
                } finally {
                  if (overlay.visible) {
                    overlay.hide();
                  }
                }
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.to;
    final theme = Theme.of(context);

    return ListTile(
      onLongPress: () {
        final textStyle = theme.textTheme.subtitle1;
        Get.dialog(
          SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () {
                  user.browseCookie = cookie.copy();
                  Get.back();
                },
                child: Text('设为浏览用的饼干', style: textStyle),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  if (await _editNote() ?? false) {
                    Get.back();
                  }
                },
                child: Text('编辑饼干备注', style: textStyle),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  if (await _deleteCookie() ?? false) {
                    Get.back();
                  }
                },
                child: Text('删除饼干', style: textStyle),
              ),
            ],
          ),
        );
      },
      title: Text(
        cookie.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: theme.textTheme.bodyText2?.fontSize),
      ),
      subtitle: (cookie.note?.isNotEmpty ?? false)
          ? Text(cookie.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.isUserCookieValid && cookie.isDeprecated)
            const Flexible(
              child: Text(
                '非登陆帐号饼干',
                style: AppTheme.boldRed,
              ),
            ),
          if (user.isUserCookieValid &&
              cookie.isDeprecated &&
              (cookie.userHash == user.browseCookie?.userHash))
            const SizedBox(width: 10.0),
          if (cookie.userHash == user.browseCookie?.userHash)
            DecoratedBox(
              decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: Text(
                  '浏览',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: theme.textTheme.bodyText2?.fontSize,
                  ),
                ),
              ),
            ),
          if (cookie.userHash == user.browseCookie?.userHash)
            const SizedBox(width: 10.0),
          IconButton(
            onPressed: _editNote,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _deleteCookie,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class CookieController extends GetxController {}

class CookieBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(CookieController());
  }
}

class CookieView extends GetView<CookieController> {
  const CookieView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService.to;

    return Scaffold(
      appBar: AppBar(
        title: const Text('饼干'),
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: user.userCookieListenable,
        builder: (context, box, child) => ListView(
          children: [
            _Login(
              key: ValueKey<int>(user.isLogin
                  ? ((user.isUserCookieExpired ?? true) ? 0 : 1)
                  : 2),
            ),
            // TODO: 扫描饼干二维码？
            ListTile(
              onTap: () => Get.dialog(_AddCookieForm()),
              title: const Text('添加自定义饼干'),
            ),
            FutureBuilder<bool>(
              future: Future(() async {
                await user.updateCookies();
                return true;
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasError) {
                  showToast('更新饼干列表出错: ${exceptionMessage(snapshot.error!)}');
                }

                return ValueListenableBuilder<Box<CookieData>>(
                  valueListenable: user.cookiesListenable,
                  builder: (context, box, child) => ValueListenableBuilder<Box>(
                    valueListenable: user.browseCookieListenable,
                    builder: (context, value, child) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('饼干列表'),
                          trailing: (user.isUserCookieValid &&
                                  snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    user.canGetCookie
                                        ? const Text(
                                            '可领取饼干',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Text('不可领取饼干',
                                            style: AppTheme.boldRed),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      '${user.currentCookiesNum}/${user.totalCookiesNum}',
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        // TODO: 重试
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasError)
                          const Text('更新饼干列表出错', style: AppTheme.boldRed),
                        if (snapshot.connectionState != ConnectionState.done)
                          const CircularProgressIndicator(),
                        ...[
                          for (final cookie in user.xdnmbCookies)
                            _Cookie(
                                key: ValueKey<CookieData>(cookie),
                                cookie: cookie)
                        ],
                        if (!user.hasXdnmbCookie)
                          const Text('没有饼干', style: AppTheme.boldRed),
                        if (user.isUserCookieValid &&
                            user.canGetCookie &&
                            user.currentCookiesNum < user.totalCookiesNum)
                          ElevatedButton(
                            onPressed: () => Get.dialog(
                              _Verify(
                                buttonText: '领取',
                                onPressed: (context, verify) async {
                                  final overlay = context.loaderOverlay;
                                  try {
                                    overlay.show();
                                    await user.addNewCookie(verify);

                                    showToast('领取新饼干成功');
                                    Get.back();
                                  } catch (e) {
                                    showToast('领取新饼干失败：${exceptionMessage(e)}');
                                  } finally {
                                    if (overlay.visible) {
                                      overlay.hide();
                                    }
                                  }
                                },
                              ),
                            ),
                            child: const Text(
                              '领取新饼干',
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ].withDividerBetween(height: 10.0, thickness: 1.0),
        ),
      ),
    );
  }
}

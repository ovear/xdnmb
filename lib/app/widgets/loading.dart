import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/theme.dart';

typedef ThumbImageBuilder = Widget Function();

// TODO: 加载语录
class Quotation extends StatelessWidget {
  final bool isTopCenter;

  const Quotation({super.key, this.isTopCenter = true});

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      '加载中',
      style: TextStyle(color: specialTextColor(), fontWeight: FontWeight.bold),
    );

    return isTopCenter
        ? Align(
            alignment: Alignment.topCenter,
            child: text,
          )
        : text;
  }
}

class QuotationLoadingIndicator extends StatelessWidget {
  const QuotationLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: const [
          Quotation(),
          Expanded(child: Center(child: CircularProgressIndicator()))
        ],
      );
}

Widget loadingThumbImageIndicatorBuilder(
        BuildContext context, String url, DownloadProgress progress) =>
    progress.progress != null
        ? CircularProgressIndicator(value: progress.progress)
        : const SizedBox.shrink();

Widget loadingImageIndicatorBuilder(BuildContext context, String url,
    DownloadProgress progress, Quotation quotation, ThumbImageBuilder builder) {
  return Stack(
    children: [
      Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: const Align(alignment: Alignment.topCenter, child: Quotation()),
      ),
      Center(child: builder()),
      if (progress.progress != null)
        Center(
          child: CircularProgressIndicator(value: progress.progress),
        ),
    ],
  );
}

Widget loadingImageErrorBuilder(
    BuildContext context, String? url, dynamic error) {
  debugPrint(url != null ? '图片 $url 加载失败: $error' : '图片加载失败: $error');

  return const Center(
    child: Text('图片加载失败', style: AppTheme.boldRed),
  );
}

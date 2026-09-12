import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class AdsenseBanner extends StatefulWidget {
  const AdsenseBanner({super.key});

  @override
  State<AdsenseBanner> createState() => _AdsenseBannerState();
}

class _AdsenseBannerState extends State<AdsenseBanner> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();

    _viewType = 'engaz-adsense-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final container = web.document.createElement('div')
          as web.HTMLDivElement;

        container.style.width = '100%';
        container.style.minHeight = '100px';
        container.style.display = 'block';

        final ad = web.document.createElement('ins')
            as web.HTMLElement;

        ad.className = 'adsbygoogle';

        ad.setAttribute(
          'style',
          'display:block;width:100%;',
        );

        ad.setAttribute(
          'data-ad-client',
          'ca-pub-2095279697107993',
        );

        ad.setAttribute(
          'data-ad-slot',
          '1401963531',
        );

        ad.setAttribute(
          'data-ad-format',
          'auto',
        );

        ad.setAttribute(
          'data-full-width-responsive',
          'true',
        );

        container.appendChild(ad);

        final script = web.document.createElement('script')
            as web.HTMLScriptElement;

        script.text = '''
          (adsbygoogle = window.adsbygoogle || []).push({});
        ''';

        container.appendChild(script);

        return container;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: HtmlElementView(
        viewType: _viewType,
      ),
    );
  }
}

import 'dart:html' as html;

String? getGoogleWebClientIdImpl() {
  final html.Element? metaTag = html.document.querySelector(
    'meta[name="google-signin-client_id"]',
  );
  final String? clientId = metaTag?.getAttribute('content')?.trim();

  if (clientId == null || clientId.isEmpty) {
    return null;
  }

  return clientId;
}

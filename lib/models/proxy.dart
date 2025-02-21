class ProxySettings {
  String protocol;
  String ip;
  int port;

  ProxySettings({
    required this.protocol,
    required this.ip,
    required this.port,
  });

  // 将ProxySettings转换为Map
  Map<String, dynamic> toMap() {
    return {
      'protocol': protocol,
      'ip': ip,
      'port': port,
    };
  }

  static ProxySettings fromMap(Map<String, dynamic> map) {
    return ProxySettings(
      protocol: map['protocol'] ?? 'Http',
      ip: map['ip'] ?? '',
      port: map['port'] ?? 0,
    );
  }
}

function FindProxyForURL(url, host) {
  if(isInNet(host, "127.0.0.1", "192.168.220.0", "192.168.16.0")) return "DIRECT";
  if(shExpMatch(url,"*minihiro.ddo.jp*", "*localhost*")) return "DIRECT";
  return "PROXY 192.168.16.8:8080; DIRECT";
}
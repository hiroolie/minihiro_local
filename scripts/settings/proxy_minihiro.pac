// nicovideo,smile,nimgへのアクセスを全てNicoCache_nl経由にする proxy.pac

function FindProxyForURL(url, host) {
    if ((shExpMatch(host, "*.nicovideo.jp")
      || shExpMatch(host, "*.smilevideo.jp")
      || shExpMatch(host, "*.nimg.jp")
        ) && url.indexOf("http:") == 0) {
        return "PROXY 192.168.16.25:8080";
    }
    return "DIRECT";
}

// nicovideo,smile,nimg�ւ̃A�N�Z�X��S��NicoCache_nl�o�R�ɂ��� proxy.pac

function FindProxyForURL(url, host) {
    if ((shExpMatch(host, "*.nicovideo.jp")
      || shExpMatch(host, "*.smilevideo.jp")
      || shExpMatch(host, "*.nimg.jp")
        ) && url.indexOf("http:") == 0) {
        return "PROXY 192.168.16.25:8080";
    }
    return "DIRECT";
}

[![Language](https://img.shields.io/badge/Swift-3.1-FFAC45.svg?style=flat)](https://swift.org/)
[![Release](https://img.shields.io/github/release/DingSoung/Network.svg)](https://github.com/DingSoung)
[![Status](https://travis-ci.org/DingSoung/Network.svg?branch=master)](https://travis-ci.org/DingSoung/Network)
[![Platform](http://img.shields.io/badge/platform-iOS-E9C2BD.svg?style=flat)](https://developer.apple.com)
[![Carthage](https://img.shields.io/badge/carthage-Compatible-yellow.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/DingSoung/Network/master/LICENSE.md)
[![Donate](https://img.shields.io/badge/donate-Alipay-00BBEE.svg)](https://qr.alipay.com/paipai/downloadQrCodeImg.resource?code=aex06042bir8odhpd1fgs00)

### Detail
This is a light weight network request lirary based on NSURLSession
support HTTP/HTTPS GET, POST and user configed network request

### Usage
add code below to your Cartfile and command `carthage update`

```
github "DingSoung/Network"
```

```Swift
Network.get(url: "http://www.guanggoo.com/", success: { (data) in
}, fail: fail)
```


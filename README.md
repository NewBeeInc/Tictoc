# Tictoc
用于swift后端的时间处理框架
## 使用说明

### 1. 支持的Swift版本

目前框架支持[Swift-3.0-preview-1-2016-06-13](https://swift.org/download/#releases).

### 2. 集成方法

使用SPM集成本依赖库, Package.swift中修改dependencies参数:

```swift
import PackageDescription

let package = Package(
    name: "PackageExample",
    targets: [],
    dependencies: [
    	.Package(url: "https://github.com/NewBeeInc/Tictoc.git", versions: Version(0,0,0)..<Version(10,0,0)
    ]
)
```


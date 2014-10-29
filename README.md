> **Qiita**
>http://qiita.com/uskiita/items/c643f5868f60b496911e

SizeClassesとXcode6でのAutoLayoutの謎マージン
===

Xcode6からSizeClassesという概念が加わったのと、AutoLayoutも微妙に変更されていて謎のMarginが出るようなので調査した結果をまとめました。

# SizeClassesとは
Xcode6からAutLayoutに加え、[SizeClasses](https://developer.apple.com/library/ios/recipes/xcode_help-IB_adaptive_sizes/chapters/AboutAdaptiveSizeDesign.html#//apple_ref/doc/uid/TP40014436-CH6-SW1)という概念が加わりました。

Xcode5では、Universalアプリを作るには、iPhone向けとiPad向けのStoryboardをそれぞれ用意していましたが、Xcode6/iOS8からは、一つのStoryboard（あるいはXib）で対応させてしまおう、というのがSizeClassesです。

考え方としては、iPhoneやiPadの特定のサイズではなく、抽象的なサイズを扱うということです。ですので、今まで以上にAutoLayoutの制約によるレイアウトデザインが重要になります。

![Xcode6のStoryboard](https://www.evernote.com/shard/s12/sh/fe29847f-3b13-49c4-b2d0-88c08c9b3f75/83bdddabb3c904e226114a011b943a95/deep/0/Main.storyboard---Edited.png)

注目すべきは赤枠で囲った２箇所です。

まず右側。StoryboardのFileインスペクタを開くと、`Use Auto Layout` の下に、`Use Size Classes`という項目が増えており、デフォルトでチェックされています。SizeClassesを使う場合にはこちらをチェックしたままにします（ちなみにSizeClassesだけ使ってAutoLayoutを使わないということはできません）。

続いて下側。 wAny hAnyとなっています。 wはWidth（ウィドゥス）、すなわち横幅で、hはHeight（ハイト）ですね。Anyはどんな大きさでもという意味で使っているのだと思います。ここをクリックすると、Viewのサイズを変更できるバルーンが出てきます。

![wAny hAny](https://www.evernote.com/shard/s12/sh/1d50ea40-f258-4459-be26-e7e504e0a85f/cd7ce42de9832ac5b268bdab2acbd676/deep/0/Main.storyboard---Edited-と-Documentation---Size-Classes-Design-Help--Changing-Constraints-and-Views-for-Size-Classes.png)

![wConpact hCompact](https://www.evernote.com/shard/s12/sh/d0dd8b04-5cdc-44b8-91fc-36533bdbb653/ffad5d6356ca324a3b512e4e54814902/deep/0/Main.storyboard---Edited.png)

![wRegular hRegular](https://www.evernote.com/shard/s12/sh/89ee0d8f-a0dd-44a6-8740-82fc4d11c2c4/d7812b63ac46c47c858e514efe13f399/deep/0/Main.storyboard---Edited-と-Documentation---Size-Classes-Design-Help--Changing-Constraints-and-Views-for-Size-Classes.png)

キャプチャは付けませんが、wCompact hRegularなども可能です。wCompact hCompactは、Apple Watchの開発環境もXcodeであることを暗に示しているようですね。


# Xcode6でのStoryboardの使い方

SizeClassesを利用するに向けて、プロジェクトの作成時に特に意識することはありません。これまで通り、必要事項を入力し、DevicesでUniversalを選択します。

![プロジェクトの新規作成画面](https://www.evernote.com/shard/s12/sh/40333113-beb3-4115-90b2-e40be6967e62/05b87b71c7ea7a0b2f3a3697f19b1a3a/deep/0/スクリーンショット-2014-09-18-14-49.png)

すると上で紹介したStoryboardのスクリーンショットと同じ画面が現れます。

では実際Constraintsの設定を見ていきます。ここでは例として、親View全体にUIWebViewを配置する、を実現します。ViewControllerのコードやOutletの設定に関する説明は割愛しますので、知りたい方は[こちら（GitHub）](https://github.com/uskithub/AutoLayoutDemo)からソースコードをダウンロードして下さい。


また、AutoLayoutに関する前提知識としてiOS7からステータスバーにViewが被るようになった、その解決策としてTop Layout GuideやBottom Layout Guideが導入されたことを知らない、良く分からない人はそちらも事前に調べておきましょう。


## まず失敗例から

View全体にWebViewを配置して実行すると、iPhone5sの大きさだと残念ながら以下の様な結果になります。

![基本形 制約なし](https://www.evernote.com/shard/s12/sh/59a9f11e-c6bc-4f28-b280-e8871e6a5631/356859a837a2ee01e980471956d8b355/deep/0/iOS-Simulator---iPhone-5s---iPhone-5s---iOS-8.0-12A365.png)

表示しているのは[うちの会社のトップページ](http://www.jibunstyle.com/)ですが、横幅が切れています。これは別にレスポンシブ対応を行っていないから切れているのではなく、ViewよりもWebViewが大きく設定されているためです。

こんな感じになってしまっています。

![重なり](https://www.evernote.com/shard/s12/sh/b98475fb-6b5b-4d46-8aef-1a5a30a6a5da/bac49be98820780ceb2151a1aa574977/deep/0/プレゼンテーション1.png)

ちなみにSafariで見るとちゃんと見ることができます:-)

![Safariで見た場合](https://www.evernote.com/shard/s12/sh/aab04a69-42e0-4a5b-805f-038b3de30e40/749ac5258c3d26ca54f2c30835a1ce91/deep/0/iOS-Simulator---iPhone-5s---iPhone-5s---iOS-8.0-12A365.png)

## 失敗例その２：Xcode5までのノリでやると…

ではConstraintsを設定しましょう。ステータスバーにかからないようにするには、WebViewをView全体ではなく、上だけステータスバーの20px分小さくするのがミソでした。

エディタエリア右下のアイコンの中から「Pin」をクリックしてバルーンを表示します。

![Pin Constraintsのバルーン](https://www.evernote.com/shard/s12/sh/dddccaca-a28c-4824-a7b3-e973b46a7a54/40d49948330586d4bf56df11e4f6c4e5/deep/0/Main.storyboard---Edited.png)

すると左右が-16となっています。Xcode5ではここは0になっていて、0にするのがセオリーでした。なので0にしてみます。上下に関しては、プルダウンをクリックし、Top Layout GuideあるいはButtom Layout Guideを選択します。

![Top Layout Guide](https://www.evernote.com/shard/s12/sh/84745d3c-dbf1-4bcf-a965-bffa1ed5d32e/db20ddf41393837f8342de03ba2915c9/deep/0/スクリーンショット-2014-09-18-17.07.45.png)

![上下左右にConstraintsを追加](https://www.evernote.com/shard/s12/sh/7fd70bf9-85ca-495f-957b-87d8ec583cc0/2ea56ee3cea9d373fd55ae00c1e450f0/deep/0/スクリーンショット-2014-10-29-21-26.png)

View Controller Sceneは以下の様になります。

![View Controller Scene](https://www.evernote.com/shard/s12/sh/139d134a-e208-4adb-80e3-521ea97b13e8/4a394024785afc57aaaf43f81c290563/deep/0/Main.storyboard---Edited.png)

意気揚々とシミュレータを実行すると、

![左右にマージンが！](https://www.evernote.com/shard/s12/sh/a5a0aea8-ce05-4032-8269-c86da832b155/dba83cce3072edc17b7692b2ce09d970/deep/0/スクリーンショット-2014-09-18-17-11.png)

左右にマージンが入ってしまっています！！

## 原因と解決策

気になったので、Xcode5で同じ手順で作ったものを、Xcode6で開いて比べてみました。比較した箇所は左右のConstraints（Horizontal Space - (-16)）のAttributesインスペクタです。

**Xcode5**
![Xcode5](https://www.evernote.com/shard/s12/sh/a6c0df08-abfd-4eff-8809-86659ba59908/5021fdf43407ed83d684bac31586a98e/deep/0/Main.storyboard.png)

**Xcode6**
![Xcode6](https://www.evernote.com/shard/s12/sh/bd1c617a-5e97-408e-861e-782f508938a9/8d91cc16fa26f866bb389847d374c743/deep/0/Main.storyboard-と-Documentation---Size-Classes-Design-Help--Changing-Constraints-and-Views-for-Size-Classes.png)

Second Itemの項目に Marginが！！これが「-16」の正体ですね。
プルダウンを開いてみました。

**Xcode5**
![Xcode5](https://www.evernote.com/shard/s12/sh/4643c34f-14f3-4e7f-b3f8-8b479fc95cac/faac756a9d243d2a46bbdd4d735f14d8/deep/0/スクリーンショット-2014-09-18-17.21.28.png)

**Xcode6**
![Xcode6](https://www.evernote.com/shard/s12/sh/e9a5f999-9df8-411c-8f38-f4ff61eb0e5f/530fb45c8045013566042e944c043a37/deep/0/スクリーンショット-2014-09-18-17.21.44.png)

こいつが犯人ですね。どうやらiOS8からViewのBoundだけではなく、設定されたMarginに対してConstraintsを設定できるようになったようです。

−16を設定するのではなく、Relative to marginを外しましょう:-)


>**参考**
>[StackOverflowでの似たようなQuestion](http://stackoverflow.com/questions/25807545/what-is-constrain-to-margin-in-storyboard-in-xcode-6)
>[Configuring Content Margins](https://developer.apple.com/LIBRARY/PRERELEASE/IOS/documentation/UIKit/Reference/UIView_Class/index.html#//apple_ref/occ/instp/UIView/layoutMargins)




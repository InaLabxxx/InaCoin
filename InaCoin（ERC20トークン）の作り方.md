# InaCoin（ERC20トークン）の作り方

# 概要

イーサリアム上でERC20規格のトークンを公開するまでの手順とソースをまとめています。

`InaCoin`と記載している箇所を自分の好きな名前に変更すれば、簡単に独自トークンを発行することが可能です。



# 環境

- Windows10
- node.js(v8.12.0)
- npm(v6.4.1)
- Truffle(v4.1.15)
- Solidity(v0.4.25)



# トークン作成までの流れ

ERC20規格に則ったトークンを、社内トークン用にアレンジしてコントラクトを作成し、テストネットである`ropsten`にデプロイするまでの流れです。



1.Truffleのインストール

2.OpenZeppelinの導入

3.コントラクトの作成

4.マイグレーションファイルの作成

5.コントラクトのデプロイ

6.コントラクトの確認



# Truffleのインストール

以下のコマンドでTruffleをインストールしてください。（node.jsはインストール済の前提）

```
$ npm install -g truffle@4.1.15
```

2018年12月のメジャーアップデートでv5系に上がっており、何も指定せずにインストールすると最新版がインストールされます。Solidityの文法にも若干変更が入っており、一緒に使う依存関係にあるライブラリがまだ対応していなかったりすると、コンパイルで失敗します。私はこれを知らずに最初ハマりました。。なので、今回はv4系で進めます。



新しくプロジェクトフォルダを作成して、`truffle init`します。

```
$ cd {自分の開発用ディレクトリまで移動}
$ mkdir InaCoin
$ cd InaCoin
$ truffle init
```



# OpenZeppelinの導入

OpenZeppelinは、イーサリアムのスマートコントラクト開発を補助するためのライブラリ。ERC20トークンの実装も含まれているため、今回はそれを使用して進めます。

また、truffle-hdwallet-providerを使って、Truffleからinfura.ioを利用できるようにします。



Truffleのプロジェクトフォルダの中で、以下のコマンドを実行します。

```
$ npm init -f
$ npm install zeppelin-solidity --save
$ npm install truffle-hdwallet-provider --save
```

これでOpenZeppelinのコードを、自分のコントラクトコードの中で使えるようになります。

インストール時のOpenZeppelinのzeppelin-solidityはv1.12.0でした。truffle-hdwallet-providerはv1.0.2でした。



# コントラクトの作成

今回のコントラクト作成で使用する言語は、Solidityです。

ERC20トークンのコードを書いていきます。`InaCoin.sol`というファイルを`contracts`フォルダの中に新規作成して、以下のコードを記述します。

```sol
pragma solidity ^0.4.18;
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract InaCoin is StandardToken {
    string public name = "INACOIN";
    string public symbol = "INA";
    uint public decimals = 18;

    mapping(address => string) public thanksMessage;

    constructor(uint _initialSupply) public {
        totalSupply_ = _initialSupply;
        balances[msg.sender] = _initialSupply;
    }

    // thanksMessage を送ると 1INAも一緒に送られる
    function thanks(address _to, string _message) public {
        transfer(_to, 1e18);
        thanksMessage[_to] = _message;
    }

    //最新の thanksMessage を見る
    function thanksMessage(address _address) public constant returns (string) {
        return thanksMessage[_address];
    }
}
```



次に記述したコードをコンパイルします。

```
$ truffle compile
```

ビルド結果は、`build/contracts`フォルダにJSONファイルで保存されます。



# マイグレーションファイルの作成

次に`InaCoin`コントラクトをデプロイするためのマイグレーションファイルを作成します。`migrations`フォルダの中に、`2_deploy_InaCoin.js`というファイルを作成し、以下のコードを記述します。

```javascript
const InaCoin = artifacts.require('./InaCoin.sol')

module.exports = (deployer) => {
  let initialSupply = 100000000e18
  deployer.deploy(InaCoin, initialSupply, {
      gas: 2000000
  })
}
```

ここでは、トークンの発行量が100,000,000 INAになるように、`InaCoin`のコンストラクタへ`initialSupply`の値を渡しています。



# コントラクトのデプロイ

テストネットである`ropsten`へのデプロイを行います。まず、デプロイに必要な情報を`truffle-config.js`に追記していきます。

```javascript
var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = process.env.ROPSTEN_MNEMONIC;
var accessToken = process.env.INFURA_ACCESS_TOKEN;

module.exports = {
  networks: {
    ropsten: {
      provider: function() {
        return new HDWalletProvider(
          mnemonic,
          "https://ropsten.infura.io/v3/" + accessToken
        );
      },
      network_id: 3,
      gas: 500000
    } 
  }
}
```



なお、デプロイ前に以下のとおり環境変数をそれぞれ設定しておく必要があります。

```
ROPSTEN_MNEMONIC = "write s.....MetaMaskのニーモニック"
INFURA_ACCESS_TOKEN = "infura.ioで取得したアクセスキー"
```



以下のコマンドでデプロイします。

```
$ truffle migrate --network ropsten
```

正常にデプロイが完了すると以下のようになります。

```
Using network 'ropsten'.

Running migration: 1_initial_migration.js
  Deploying Migrations...
  ... 0x8819206fd2d5b04ab563435a894ac295af89345...........
  Migrations: 0x03768369228110bca094......................
Saving successful migration to network...
  ... 0xe12ba2819af291ecc71cd74e19c7109a2091cd........................
Saving artifacts...
Running migration: 2_deploy_InaCoin.js
  Deploying InaCoin...
  ... 0x702d2cc2a27993a67e4cebec928f2412..............................
  InaCoin: 0xecae88f966c1ffc3acc......................
Saving successful migration to network...
  ... 0xe59d39470534fdb4dba7d8c3......................................
Saving artifacts...
```

そして`0xecae88f966c1ffc3acc......................`がInaCoinのコントラクトアドレスになります。



# コントラクトの確認

Etherscanでコントラクトを確認します。

https://ropsten.etherscan.io/token/<コントラクトアドレスを指定>

正常にトークンが発行されていることを確認できました。



# License

MIT
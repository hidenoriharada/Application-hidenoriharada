# アプリケーション開発 21X3138原田英紀

## 概要
単語を追加し, 自分だけの単語帳を作成するアプリケーション

## ホーム画面
<img src="https://github.com/user-attachments/assets/ca91278d-d8e8-4b10-bdf4-1f95b5ba8f8a" alt="Image" width="200" >

Add Wordをタップし, 単語を追加していく

## 単語入力
<img src="https://github.com/user-attachments/assets/eb2ef0e8-0205-48d7-9ba6-aa15c64de1ce" alt="Image" width="200" >

単語, 意味, 品詞を選択できる

<img src="https://github.com/user-attachments/assets/9806f158-c3dd-468b-9047-90ee8463c179" alt="Image" width="200" >

## 入力後画面
<img src="https://github.com/user-attachments/assets/575f3b42-5367-4d47-912f-63211ca33956" alt="Image" width="200" >

単語と品詞の種類を表示する

<img src="https://github.com/user-attachments/assets/89933d12-e948-4e29-923b-0ef98f1fbc46" alt="Image" width="200" >

水色のコンテナをタップすると意味の答え合わせと, 類義語の確認ができる
右下のボタンをタップすると

<img src="https://github.com/user-attachments/assets/20186f38-1a12-4563-bc9d-528e083da653" alt="Image" width="200" >

編集可能(コンテナ内のスペースを超えてしまうような入力のエラーは直せていない)

## 学習後の単語
WordList画面で理解した単語を, ほかの画面に移動させる
(コンテナ内の右にあるチェックマークを押す)

<img src="https://github.com/user-attachments/assets/2c1f67a5-c59d-494f-839e-83865616ad95" alt="Image" width="200" >

コンテナ内のごみ箱マークをタップすると, 完全に単語が消え, 右の矢印マークをタップすると, 再度WordList画面に戻る


## 設計方針
1. "WordList"画面に単語を追加する
2. 追加した画面に答えを移さず, コンテナをタップすると移るようにする
3. 追加した単語を"LearnedWords"に移すようにする
4. "LearnedWords"から"WordList"に移すようにする
5. 単語を完全に消去するボタン追加
6. 答えの画面に類義語を3つ表示するようにする

## 工夫した点
・反復学習 : 一度学習するのではなく, 二度学習することにより, 学習の効率化を図るようにした. また, 二度目に正解できなかった場合, 元の画面に戻すことにより, 覚えるスピードを上げるようにした.


・類義語 : 単語帳には, 単語のほかに類義語が掲載されているが, 大抵一つ, もしくは掲載されていない場合もある. 類義語を同時に, かつ複数取り入れることにより, 語彙力向の効率化を図るようにした.


## 動作環境
Flutter 3.27.3

Dart 3.6.1

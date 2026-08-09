class IndexListContact {
  const IndexListContact({required this.name, required this.url});

  final String name;
  final String url;
}

const List<String> indexListLetters = <String>[
  '↑',
  '☆',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  '#',
];

const List<String> indexListNames = <String>[
  '勇往无敌',
  '疯狂的迪飙',
  '磊爱可',
  '梦幻梦幻梦',
  '枫中飘瓢',
  '飞翔天使',
  '曾经第一',
  '追风幻影族长',
  '麦小姐',
  '胡格罗雅',
  'Red磊磊',
  '乐乐立立',
  '青龙爆风',
  '跑跑卡叮车',
  '山里狼',
  'supersonic超',
];

const List<String> indexListUrls = <String>[
  'https://uview-plus.jiangruyi.com/album/1.jpg',
  'https://uview-plus.jiangruyi.com/album/2.jpg',
  'https://uview-plus.jiangruyi.com/album/3.jpg',
  'https://uview-plus.jiangruyi.com/album/4.jpg',
  'https://uview-plus.jiangruyi.com/album/5.jpg',
  'https://uview-plus.jiangruyi.com/album/6.jpg',
  'https://uview-plus.jiangruyi.com/album/7.jpg',
  'https://uview-plus.jiangruyi.com/album/8.jpg',
  'https://uview-plus.jiangruyi.com/album/9.jpg',
  'https://uview-plus.jiangruyi.com/album/10.jpg',
];

List<List<IndexListContact>> buildIndexListGroups() {
  return List<List<IndexListContact>>.generate(
    indexListLetters.length,
    (groupIndex) => List<IndexListContact>.generate(
      10,
      (itemIndex) {
        final name = indexListNames[
            (groupIndex * 10 + itemIndex) % indexListNames.length];
        final url =
            indexListUrls[(groupIndex + itemIndex) % indexListUrls.length];
        return IndexListContact(name: name, url: url);
      },
    ),
  );
}

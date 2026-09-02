class IndianLanguage {
  final String code;
  final String englishName;
  final String nativeScript;

  const IndianLanguage({
    required this.code,
    required this.englishName,
    required this.nativeScript,
  });
}

class AppLanguages {
  static const List<IndianLanguage> languages = [
    IndianLanguage(code: 'en', englishName: 'English', nativeScript: 'English'),
    IndianLanguage(code: 'hi', englishName: 'Hindi', nativeScript: 'हिन्दी'),
    IndianLanguage(code: 'bn', englishName: 'Bengali', nativeScript: 'বাংলা'),
    IndianLanguage(code: 'ta', englishName: 'Tamil', nativeScript: 'தமிழ்'),
    IndianLanguage(code: 'te', englishName: 'Telugu', nativeScript: 'తెలుగు'),
    IndianLanguage(code: 'mr', englishName: 'Marathi', nativeScript: 'मराठी'),
    IndianLanguage(code: 'gu', englishName: 'Gujarati', nativeScript: 'ગુજરાતી'),
    IndianLanguage(code: 'kn', englishName: 'Kannada', nativeScript: 'ಕನ್ನಡ'),
    IndianLanguage(code: 'ml', englishName: 'Malayalam', nativeScript: 'മലയാളം'),
    IndianLanguage(code: 'or', englishName: 'Odia', nativeScript: 'ଓଡ଼ିଆ'),
    IndianLanguage(code: 'pa', englishName: 'Punjabi', nativeScript: 'ਪੰਜਾਬੀ'),
    IndianLanguage(code: 'as', englishName: 'Assamese', nativeScript: 'অসমীয়া'),
    IndianLanguage(code: 'ur', englishName: 'Urdu', nativeScript: 'اردو'),
    IndianLanguage(code: 'mai', englishName: 'Maithili', nativeScript: 'मैथिली'),
    IndianLanguage(code: 'ks', englishName: 'Kashmiri', nativeScript: 'कश्मीरी'),
    IndianLanguage(code: 'ne', englishName: 'Nepali', nativeScript: 'नेपाली'),
    IndianLanguage(code: 'sd', englishName: 'Sindhi', nativeScript: 'سنڌي'),
    IndianLanguage(code: 'sa', englishName: 'Sanskrit', nativeScript: 'संस्कृतम्'),
    IndianLanguage(code: 'kok', englishName: 'Konkani', nativeScript: 'कोंकणी'),
    IndianLanguage(code: 'mni', englishName: 'Manipuri', nativeScript: 'মৈতৈলোন্'),
    IndianLanguage(code: 'doi', englishName: 'Dogri', nativeScript: 'डोगरी'),
    IndianLanguage(code: 'brx', englishName: 'Bodo', nativeScript: 'बड़ो'),
  ];
}
